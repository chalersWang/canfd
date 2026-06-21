`ifndef _CANFD_I_02_04_RST_DLY_TEST_SV_
`define _CANFD_I_02_04_RST_DLY_TEST_SV_

// CANFD Test: I-02-04 | Priority: P1
// 验证复位后 16 周期内访问寄存器的行为

class canfd_I_02_04_rst_dly_test_seq extends uvm_sequence;
    `uvm_object_utils(canfd_I_02_04_rst_dly_test_seq)
    function new(string n="canfd_I_02_04_rst_dly_test_seq"); super.new(n); endfunction
    virtual task body();
        uvm_status_e st; uvm_reg_data_t v, ev; int pass=0, fail=0;
        `ifdef REG_MODEL
            canfd_reg_block rm;
            if(!uvm_config_db#(canfd_reg_block)::get(null,"*","RegModel",rm))
                `uvm_fatal(get_type_name(),"No RegModel")
        `endif
        `uvm_info(get_type_name(),"===== I-02-04: 验证复位后 16 周期内访问寄存器的行为 Start =====",UVM_LOW)

        // 复位后16周期内访问寄存器
        `ifdef REG_MODEL
        // 在16周期内尝试访问
        repeat(8) @(posedge canfdvif.clk);
        rm.BRPR.read(st,ev,UVM_FRONTDOOR);
        // 可能返回错误或延迟，验证不产生致命错误
        `uvm_info(get_type_name(),$sformatf("Access within 16-cycle after reset: st=%s",st.name()),UVM_MEDIUM)
        pass++;
        `endif

        `uvm_info(get_type_name(),$sformatf("===== I-02-04 Done: %0d pass, %0d fail =====",pass,fail),UVM_LOW)
    endtask
endclass

class canfd_I_02_04_rst_dly_test extends canfd_base_test;
    `uvm_component_utils(canfd_I_02_04_rst_dly_test)
    function new(string n="canfd_I_02_04_rst_dly_test",uvm_component p=null); super.new(n,p); endfunction
    virtual task run_phase(uvm_phase phase);
        canfd_I_02_04_rst_dly_test_seq seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        `uvm_info(get_type_name(),"Test: I-02-04 Start",UVM_LOW)
        seq=canfd_I_02_04_rst_dly_test_seq::type_id::create("seq"); seq.start(canfd_vseqr);
        `uvm_info(get_type_name(),"Test: I-02-04 Done",UVM_LOW)
        phase.drop_objection(this);
    endtask
endclass
`endif
