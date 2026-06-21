`ifndef _CANFD_I_02_03_HW_RST_TEST_SV_
`define _CANFD_I_02_03_HW_RST_TEST_SV_

// CANFD Test: I-02-03 | Priority: P0
// 验证硬件复位后所有状态正确初始化

class canfd_I_02_03_hw_rst_test_seq extends uvm_sequence;
    `uvm_object_utils(canfd_I_02_03_hw_rst_test_seq)
    function new(string n="canfd_I_02_03_hw_rst_test_seq"); super.new(n); endfunction
    virtual task body();
        uvm_status_e st; uvm_reg_data_t v, ev; int pass=0, fail=0;
        `ifdef REG_MODEL
            canfd_reg_block rm;
            if(!uvm_config_db#(canfd_reg_block)::get(null,"*","RegModel",rm))
                `uvm_fatal(get_type_name(),"No RegModel")
        `endif
        `uvm_info(get_type_name(),"===== I-02-03: 验证硬件复位后所有状态正确初始化 Start =====",UVM_LOW)

        // 硬件复位→所有寄存器恢复默认值
        `ifdef REG_MODEL
        uvm_reg rgs[$]; rm.get_registers(rgs);
        foreach(rgs[i]) begin
            rgs[i].read(st,ev,UVM_FRONTDOOR);
            if(ev===rgs[i].get_reset()) pass++; else begin
                `uvm_error(get_type_name(),$sformatf("HW reset fail: %s exp=%0h got=%0h",rgs[i].get_name(),rgs[i].get_reset(),ev)); fail++;
            end
        end
        `endif

        `uvm_info(get_type_name(),$sformatf("===== I-02-03 Done: %0d pass, %0d fail =====",pass,fail),UVM_LOW)
    endtask
endclass

class canfd_I_02_03_hw_rst_test extends canfd_base_test;
    `uvm_component_utils(canfd_I_02_03_hw_rst_test)
    function new(string n="canfd_I_02_03_hw_rst_test",uvm_component p=null); super.new(n,p); endfunction
    virtual task run_phase(uvm_phase phase);
        canfd_I_02_03_hw_rst_test_seq seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        `uvm_info(get_type_name(),"Test: I-02-03 Start",UVM_LOW)
        seq=canfd_I_02_03_hw_rst_test_seq::type_id::create("seq"); seq.start(canfd_vseqr);
        `uvm_info(get_type_name(),"Test: I-02-03 Done",UVM_LOW)
        phase.drop_objection(this);
    endtask
endclass
`endif
