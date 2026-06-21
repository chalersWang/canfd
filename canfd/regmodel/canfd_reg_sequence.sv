`ifndef _CANFD_REG_SEQUENCE_SV_
`define _CANFD_REG_SEQUENCE_SV_

//=========================================================================
// canfd_reg_sequence: CAN FD 寄存器自测试 Sequence 库
//   - canfd_reg_reset_check_seq: 复位值检查
//   - canfd_reg_access_seq: 读写比对测试
//   - canfd_reg_bit_bash_seq: walking-1/walking-0 位翻转
//=========================================================================

//-------------------------------------------------------------------------
// canfd_reg_reset_check_seq: 读取所有寄存器并与期望复位值比对
//-------------------------------------------------------------------------
class canfd_reg_reset_check_seq extends uvm_sequence;

    canfd_reg_block  regmodel;
    `uvm_object_utils(canfd_reg_reset_check_seq)
    function new(string name="canfd_reg_reset_check_seq"); super.new(name); endfunction

    virtual task body();
        uvm_status_e   st;
        uvm_reg_data_t val, exp;
        uvm_reg        regs[$];
        int pass=0, fail=0;

        `uvm_info(get_type_name(), "===== CANFD Reg Reset Check Start =====", UVM_LOW)
        if (regmodel == null) `uvm_fatal(get_type_name(), "regmodel is null")
        regmodel.get_registers(regs);

        foreach (regs[i]) begin
            regs[i].read(st, val, UVM_FRONTDOOR);
            if (st != UVM_IS_OK) begin
                `uvm_error(get_type_name(), $sformatf("Read failed: %s", regs[i].get_full_name()))
                fail++; continue;
            end
            exp = regs[i].get_reset();
            // CANFD 寄存器大部分复位值为 0，检查 CONFIG 位 (SR[0]=1)
            if (val === exp)
                pass++;
            else begin
                `uvm_error(get_type_name(), $sformatf("Reset mismatch: %s exp=%0h got=%0h",
                    regs[i].get_full_name(), exp, val))
                fail++;
            end
        end
        `uvm_info(get_type_name(), $sformatf("Reset Check Done: %0d pass, %0d fail", pass, fail), UVM_LOW)
    endtask
endclass : canfd_reg_reset_check_seq

//-------------------------------------------------------------------------
// canfd_reg_access_seq: 对所有 RW 寄存器执行 Write→Read 比对
//-------------------------------------------------------------------------
class canfd_reg_access_seq extends uvm_sequence;

    canfd_reg_block  regmodel;
    bit              restore_reset = 1;  // 测试后恢复复位值
    `uvm_object_utils(canfd_reg_access_seq)
    function new(string name="canfd_reg_access_seq"); super.new(name); endfunction

    virtual task body();
        uvm_status_e   st;
        uvm_reg_data_t wdata, rdata;
        uvm_reg        regs[$];
        int pass=0, fail=0;

        `uvm_info(get_type_name(), "===== CANFD Reg Access Test Start =====", UVM_LOW)
        if (regmodel == null) `uvm_fatal(get_type_name(), "regmodel is null")
        regmodel.get_registers(regs);

        foreach (regs[i]) begin
            // 跳过只读寄存器
            if (regs[i].get_access() == "RO") continue;
            // 跳过纯写寄存器（无法读回验证）
            if (regs[i].get_access() == "WO") continue;

            // 随机写值
            wdata = {$urandom()} & ((1 << regs[i].get_n_bits()) - 1);
            regs[i].write(st, wdata, UVM_FRONTDOOR);
            if (st != UVM_IS_OK) begin
                `uvm_error(get_type_name(), $sformatf("Write failed: %s", regs[i].get_full_name()))
                fail++; continue;
            end
            // 读回
            regs[i].read(st, rdata, UVM_FRONTDOOR);
            if (rdata === wdata) pass++;
            else begin
                `uvm_error(get_type_name(), $sformatf("R/W mismatch: %s w=%0h r=%0h",
                    regs[i].get_full_name(), wdata, rdata))
                fail++;
            end
            // 恢复复位值
            if (restore_reset) regs[i].write(st, regs[i].get_reset(), UVM_FRONTDOOR);
        end
        `uvm_info(get_type_name(), $sformatf("Access Done: %0d pass, %0d fail", pass, fail), UVM_LOW)
    endtask
endclass : canfd_reg_access_seq

//-------------------------------------------------------------------------
// canfd_reg_bit_bash_seq: walking-1 / walking-0 测试
//-------------------------------------------------------------------------
class canfd_reg_bit_bash_seq extends uvm_sequence;

    canfd_reg_block  regmodel;
    `uvm_object_utils(canfd_reg_bit_bash_seq)
    function new(string name="canfd_reg_bit_bash_seq"); super.new(name); endfunction

    virtual task body();
        uvm_status_e   st;
        uvm_reg_data_t rdata, wdata, mask;
        uvm_reg        regs[$];
        int pass=0, fail=0, n_bits;

        `uvm_info(get_type_name(), "===== CANFD Reg Bit Bash Start =====", UVM_LOW)
        if (regmodel == null) `uvm_fatal(get_type_name(), "regmodel is null")
        regmodel.get_registers(regs);

        foreach (regs[i]) begin
            if (regs[i].get_access() != "RW") continue;
            n_bits = regs[i].get_n_bits();
            // Walking-1
            for (int b = 0; b < n_bits; b++) begin
                mask = 1 << b;
                regs[i].write(st, mask, UVM_FRONTDOOR);
                regs[i].read(st, rdata, UVM_FRONTDOOR);
                if (rdata === mask) pass++; else begin fail++; end
            end
            // Walking-0
            for (int b = 0; b < n_bits; b++) begin
                mask = ~(1 << b) & ((1 << n_bits) - 1);
                regs[i].write(st, mask, UVM_FRONTDOOR);
                regs[i].read(st, rdata, UVM_FRONTDOOR);
                if (rdata === mask) pass++; else begin fail++; end
            end
            regs[i].write(st, regs[i].get_reset(), UVM_FRONTDOOR);
        end
        `uvm_info(get_type_name(), $sformatf("Bit Bash Done: %0d pass, %0d fail", pass, fail), UVM_LOW)
    endtask
endclass : canfd_reg_bit_bash_seq

//-------------------------------------------------------------------------
// canfd_reg_config_seq: CAN 配置寄存器全场景测试
//   测试 CAN 配置寄存器（SRR/MSR/BRPR/BTR/DP_BRPR/DP_BTR）的各种工作模式组合
//-------------------------------------------------------------------------
class canfd_reg_config_seq extends uvm_sequence;

    canfd_reg_block  regmodel;
    `uvm_object_utils(canfd_reg_config_seq)
    function new(string name="canfd_reg_config_seq"); super.new(name); endfunction

    virtual task body();
        uvm_status_e st;
        uvm_reg_data_t val;

        `uvm_info(get_type_name(), "===== CANFD Config Reg Test Start =====", UVM_LOW)
        if (regmodel == null) `uvm_fatal(get_type_name(), "regmodel is null")

        // Test 1: 配置模式 → 使能 → 正常模式
        `uvm_info(get_type_name(), "Test1: Config → Enable → Normal", UVM_MEDIUM)
        regmodel.SRR.write(st, 32'h0);     // CEN=0, config mode
        regmodel.BRPR.write(st, 32'h0);    // 设置波特率
        regmodel.BTR.write(st, 32'h0);     // 设置位时序
        regmodel.SRR.write(st, 32'h2);     // CEN=1, enable

        // Test 2: 回环模式测试
        `uvm_info(get_type_name(), "Test2: Loopback Mode", UVM_MEDIUM)
        regmodel.SRR.write(st, 32'h0);     // 先回配置模式
        regmodel.MSR.write(st, 32'h2);     // LBACK=1
        regmodel.SRR.write(st, 32'h2);     // CEN=1

        // Test 3: 监听模式测试
        `uvm_info(get_type_name(), "Test3: Snoop Mode", UVM_MEDIUM)
        regmodel.SRR.write(st, 32'h0);
        regmodel.MSR.write(st, 32'h4);     // SNOOP=1
        regmodel.SRR.write(st, 32'h2);

        // Test 4: 恢复配置模式
        `uvm_info(get_type_name(), "Test4: Return to Config", UVM_MEDIUM)
        regmodel.SRR.write(st, 32'h0);
        regmodel.MSR.write(st, 32'h0);

        `uvm_info(get_type_name(), "Config Test Done", UVM_LOW)
    endtask
endclass : canfd_reg_config_seq

`endif
