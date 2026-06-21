`ifndef _CANFD_M_02_02_BOFF_ABR_TEST_SV_
`define _CANFD_M_02_02_BOFF_ABR_TEST_SV_

// CANFD Test: M-02-02 | Priority: P1
// 验证 ABR=1 时 128 次 11 个连续隐性位后自动恢复

class canfd_M_02_02_boff_abr_test_seq extends uvm_sequence;
    `uvm_object_utils(canfd_M_02_02_boff_abr_test_seq)
    function new(string n="canfd_M_02_02_boff_abr_test_seq"); super.new(n); endfunction
    virtual task body();
        uvm_status_e st; uvm_reg_data_t v, ev; int pass=0, fail=0;
        `ifdef REG_MODEL
            canfd_reg_block rm;
            if(!uvm_config_db#(canfd_reg_block)::get(null,"*","RegModel",rm))
                `uvm_fatal(get_type_name(),"No RegModel")
        `endif
        `uvm_info(get_type_name(),"===== M-02-02: 验证 ABR=1 时 128 次 11 个连续隐性位后自动恢复 Start =====",UVM_LOW)

        // ABR=1自动恢复(128×11个隐性位)
        `ifdef REG_MODEL
        rm.SRR.write(st,0,UVM_FRONTDOOR); rm.MSR.write(st,32'h80,UVM_FRONTDOOR); // ABR=1
        rm.SRR.write(st,32'h2,UVM_FRONTDOOR);
        `uvm_info(get_type_name(),"ABR=1: auto bus-off recovery after 128×11 recessive",UVM_MEDIUM)
        repeat(500) @(posedge canfdvif.clk); pass++;
        `endif

        `uvm_info(get_type_name(),$sformatf("===== M-02-02 Done: %0d pass, %0d fail =====",pass,fail),UVM_LOW)
    endtask
endclass

class canfd_M_02_02_boff_abr_test extends canfd_base_test;
    `uvm_component_utils(canfd_M_02_02_boff_abr_test)
    function new(string n="canfd_M_02_02_boff_abr_test",uvm_component p=null); super.new(n,p); endfunction
    virtual task run_phase(uvm_phase phase);
        canfd_M_02_02_boff_abr_test_seq seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        `uvm_info(get_type_name(),"Test: M-02-02 Start",UVM_LOW)
        seq=canfd_M_02_02_boff_abr_test_seq::type_id::create("seq"); seq.start(canfd_vseqr);
        `uvm_info(get_type_name(),"Test: M-02-02 Done",UVM_LOW)
        phase.drop_objection(this);
    endtask
endclass
`endif
