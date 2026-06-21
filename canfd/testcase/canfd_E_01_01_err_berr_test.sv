`ifndef _CANFD_E_01_01_ERR_BERR_TEST_SV_
`define _CANFD_E_01_01_ERR_BERR_TEST_SV_

// CANFD Test: E-01-01 | Priority: P0
// 验证位错误 (BERR) 检测

class canfd_E_01_01_err_berr_test_seq extends canfd_virtual_seq_lib;
    `uvm_object_utils(canfd_E_01_01_err_berr_test_seq)
    function new(string n="canfd_E_01_01_err_berr_test_seq"); super.new(n); endfunction

    virtual task body();
        int pass=0, fail=0;
        bit result;

        `uvm_info(get_type_name(), "===== E-01-01: Bit Error (BERR) Test Start =====", UVM_LOW)

        // 初始化 CANFD (Loopback 模式用于自测)
        canfd_init(.brp(4), .ts1(4), .ts2(3));

        // 使能错误中断
        reg_write(16'h0020, 32'h000); // 先清 IER
        canfd_clear_int(32'hFFF);

        // 注入位错误
        canfd_inject_error(ERR_BIT, 15); // 在 ID 段注入位错误

        // 等待并检查
        repeat(5000) @(posedge p_sequencer.clk);

        // 检查 ESR BERR 位 [4]
        canfd_check_esr(32'h010, result); // BERR = bit 4
        if (result) begin
            pass++;
            `uvm_info(get_type_name(), "BERR detected ✓", UVM_MEDIUM)
        end else begin
            `uvm_error(get_type_name(), "BERR not detected!")
            fail++;
        end

        // 检查 TEC 增加
        canfd_check_ecr(8'h08, 8'h00, result); // TEC 应 +8
        if (result) pass++; else fail++;

        `uvm_info(get_type_name(), $sformatf("===== E-01-01 Done: %0d pass, %0d fail =====", pass, fail), UVM_LOW)
    endtask
endclass

class canfd_E_01_01_err_berr_test extends canfd_base_test;
    `uvm_component_utils(canfd_E_01_01_err_berr_test)
    function new(string n="canfd_E_01_01_err_berr_test", uvm_component p=null); super.new(n,p); endfunction
    virtual task run_phase(uvm_phase phase);
        canfd_E_01_01_err_berr_test_seq seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        seq = canfd_E_01_01_err_berr_test_seq::type_id::create("seq");
        seq.start(env.canfd_vseqr);
        phase.drop_objection(this);
    endtask
endclass

`endif
