`ifndef _CANFD_T_01_01_REG_RW_TEST_SV_
`define _CANFD_T_01_01_REG_RW_TEST_SV_

// CANFD Test: T-01-01 | Priority: P0
// 验证所有核心寄存器读写正确性

class canfd_T_01_01_reg_rw_test_seq extends canfd_virtual_seq_lib;
    `uvm_object_utils(canfd_T_01_01_reg_rw_test_seq)
    function new(string n="canfd_T_01_01_reg_rw_test_seq"); super.new(n); endfunction

    virtual task body();
        int pass=0, fail=0;
        logic [31:0] wval, rval;

        `uvm_info(get_type_name(), "===== T-01-01: Register R/W Test Start =====", UVM_LOW)

        // 确保在配置模式
        reg_write(16'h0000, 32'h0000); // CEN=0

        // Step1: 遍历核心寄存器，随机写→回读比对
        // 可写寄存器列表
        begin
            logic [31:0] addrs[] = '{16'h0004, 16'h0008, 16'h000C, 16'h0020, 16'h0028, 16'h0088, 16'h008C, 16'h0090, 16'h0098, 16'h00A4, 16'h00B0, 16'h00B4, 16'h00B8, 16'h00E0, 16'h00EC};
            foreach (addrs[i]) begin
                wval = $urandom;
                // 限制写入值 (避免特殊位冲突)
                if (addrs[i] == 16'h0004) wval[1:0] = 2'b00; // MSR: 清模式位
                if (addrs[i] == 16'h0090) wval = wval & 32'hFFFFFFFF; // TRR
                reg_write(addrs[i], wval);
                reg_read(addrs[i], rval);
                if (rval === wval) begin
                    pass++;
                    `uvm_info(get_type_name(), $sformatf("R/W OK: 0x%04h w=0x%08h r=0x%08h", addrs[i], wval, rval), UVM_HIGH)
                end else begin
                    `uvm_error(get_type_name(), $sformatf("R/W FAIL: 0x%04h w=0x%08h r=0x%08h", addrs[i], wval, rval))
                    fail++;
                end
            end
        end

        // Step2: 只读寄存器不可写入 (ECR=0x0010, SR=0x0018, ISR=0x001C)
        begin
            logic [31:0] ro_addrs[] = '{16'h0010, 16'h0018};
            foreach (ro_addrs[i]) begin
                reg_read(ro_addrs[i], rval);
                reg_write(ro_addrs[i], ~rval);
                reg_read(ro_addrs[i], wval);
                if (wval === rval) begin
                    pass++;
                    `uvm_info(get_type_name(), $sformatf("RO OK: 0x%04h val=0x%08h", ro_addrs[i], rval), UVM_HIGH)
                end else begin
                    `uvm_error(get_type_name(), $sformatf("RO FAIL: 0x%04h before=0x%08h after=0x%08h", ro_addrs[i], rval, wval))
                    fail++;
                end
            end
        end

        // Step3: W1C 寄存器清除 (ESR=0x0014)
        begin
            logic [31:0] esr_val;
            reg_read(16'h0014, esr_val);
            if (esr_val != 0) begin
                reg_write(16'h0014, esr_val); // 写1清除
                reg_read(16'h0014, rval);
                if ((rval & esr_val) == 0) begin
                    pass++;
                    `uvm_info(get_type_name(), $sformatf("W1C OK: ESR 0x%08h -> 0x%08h", esr_val, rval), UVM_HIGH)
                end else begin
                    `uvm_error(get_type_name(), $sformatf("W1C FAIL: ESR 0x%08h -> 0x%08h", esr_val, rval))
                    fail++;
                end
            end
        end

        `uvm_info(get_type_name(), $sformatf("===== T-01-01 Done: %0d pass, %0d fail =====", pass, fail), UVM_LOW)
    endtask
endclass

class canfd_T_01_01_reg_rw_test extends canfd_base_test;
    `uvm_component_utils(canfd_T_01_01_reg_rw_test)
    function new(string n="canfd_T_01_01_reg_rw_test", uvm_component p=null); super.new(n,p); endfunction
    virtual task run_phase(uvm_phase phase);
        canfd_T_01_01_reg_rw_test_seq seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        seq = canfd_T_01_01_reg_rw_test_seq::type_id::create("seq");
        seq.start(env.canfd_vseqr);
        phase.drop_objection(this);
    endtask
endclass

`endif
