`ifndef _CANFD_M_01_02_MODE_LB_TEST_SV_
`define _CANFD_M_01_02_MODE_LB_TEST_SV_

// CANFD Test: M-01-02 | Priority: P0
// 验证 Loopback 内部回环模式

class canfd_M_01_02_mode_lb_test_seq extends canfd_virtual_seq_lib;
    `uvm_object_utils(canfd_M_01_02_mode_lb_test_seq)
    function new(string n="canfd_M_01_02_mode_lb_test_seq"); super.new(n); endfunction

    virtual task body();
        int pass=0, fail=0;
        logic [7:0] tx_data[];
        bit result;

        `uvm_info(get_type_name(), "===== M-01-02: Loopback Mode Test Start =====", UVM_LOW)

        // 进入 Loopback 模式
        canfd_enter_loopback();

        // 发送标准帧并验证回环接收
        tx_data = '{8'h11, 8'h22, 8'h33, 8'h44};
        canfd_tx_std_frame(11'h123, 4, tx_data);

        // 等待 RXOK (回环应收到自身帧)
        canfd_wait_rxok(5000);

        // 检查接收数据
        canfd_check_rx(11'h123, 4, tx_data, result);
        if (result) begin
            pass++;
            `uvm_info(get_type_name(), "Loopback RX match ✓", UVM_MEDIUM)
        end else begin
            `uvm_error(get_type_name(), "Loopback RX mismatch!")
            fail++;
        end

        // 测试 FD 帧回环
        tx_data = new[64];
        foreach (tx_data[i]) tx_data[i] = i;
        canfd_tx_fd_frame(11'h456, 1'b0, 1'b1, 4'hF, tx_data); // 64 bytes, BRS=1

        canfd_wait_rxok(5000);
        canfd_check_rx(11'h456, 4'hF, tx_data, result);
        if (result) pass++; else fail++;

        `uvm_info(get_type_name(), $sformatf("===== M-01-02 Done: %0d pass, %0d fail =====", pass, fail), UVM_LOW)
    endtask
endclass

class canfd_M_01_02_mode_lb_test extends canfd_base_test;
    `uvm_component_utils(canfd_M_01_02_mode_lb_test)
    function new(string n="canfd_M_01_02_mode_lb_test", uvm_component p=null); super.new(n,p); endfunction
    virtual task run_phase(uvm_phase phase);
        canfd_M_01_02_mode_lb_test_seq seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        seq = canfd_M_01_02_mode_lb_test_seq::type_id::create("seq");
        seq.start(env.canfd_vseqr);
        phase.drop_objection(this);
    endtask
endclass

`endif
