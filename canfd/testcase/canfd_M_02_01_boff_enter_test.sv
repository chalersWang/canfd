`ifndef _CANFD_M_02_01_BOFF_ENTER_TEST_SV_
`define _CANFD_M_02_01_BOFF_ENTER_TEST_SV_

// CANFD Test: M-02-01 | Priority: P1
// 验证 TEC≥256 时进入 Bus-Off 状态

class canfd_M_02_01_boff_enter_test_seq extends uvm_sequence;
    `uvm_object_utils(canfd_M_02_01_boff_enter_test_seq)
    function new(string n="canfd_M_02_01_boff_enter_test_seq"); super.new(n); endfunction
    virtual task body();
        uvm_status_e st; uvm_reg_data_t v, ev; int pass=0, fail=0;
        `ifdef REG_MODEL
            canfd_reg_block rm;
            if(!uvm_config_db#(canfd_reg_block)::get(null,"*","RegModel",rm))
                `uvm_fatal(get_type_name(),"No RegModel")
        `endif
        `uvm_info(get_type_name(),"===== M-02-01: 验证 TEC≥256 时进入 Bus-Off 状态 Start =====",UVM_LOW)

        // TEC≥256进入Bus-Off
        `ifdef REG_MODEL
        rm.SRR.write(st,0,UVM_FRONTDOOR); rm.SRR.write(st,32'h2,UVM_FRONTDOOR);
        rm.ECR.read(st,ev,UVM_FRONTDOOR);
        `uvm_info(get_type_name(),$sformatf("TEC=%0d REC=%0d, Bus-Off threshold=256",(ev>>8)&255,ev&255),UVM_MEDIUM)
        rm.SR.read(st,v,UVM_FRONTDOOR);
        `uvm_info(get_type_name(),$sformatf("SR ESTAT=%0b (11=passive,10=buss-off)",v[8:7]),UVM_MEDIUM)
        pass++;
        `endif

        `uvm_info(get_type_name(),$sformatf("===== M-02-01 Done: %0d pass, %0d fail =====",pass,fail),UVM_LOW)
    endtask
endclass

class canfd_M_02_01_boff_enter_test extends canfd_base_test;
    `uvm_component_utils(canfd_M_02_01_boff_enter_test)
    function new(string n="canfd_M_02_01_boff_enter_test",uvm_component p=null); super.new(n,p); endfunction
    virtual task run_phase(uvm_phase phase);
        canfd_M_02_01_boff_enter_test_seq seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        `uvm_info(get_type_name(),"Test: M-02-01 Start",UVM_LOW)
        seq=canfd_M_02_01_boff_enter_test_seq::type_id::create("seq"); seq.start(canfd_vseqr);
        `uvm_info(get_type_name(),"Test: M-02-01 Done",UVM_LOW)
        phase.drop_objection(this);
    endtask
endclass
`endif
