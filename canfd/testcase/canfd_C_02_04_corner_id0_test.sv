`ifndef _CANFD_C_02_04_CORNER_ID0_TEST_SV_
`define _CANFD_C_02_04_CORNER_ID0_TEST_SV_

// CANFD Test: C-02-04 | Priority: P1
// 验证 ID=0 的帧（最高优先级）

class canfd_C_02_04_corner_id0_test_seq extends uvm_sequence;
    `uvm_object_utils(canfd_C_02_04_corner_id0_test_seq)
    function new(string n="canfd_C_02_04_corner_id0_test_seq"); super.new(n); endfunction
    virtual task body();
        uvm_status_e st; uvm_reg_data_t v, ev; int pass=0, fail=0;
        `ifdef REG_MODEL
            canfd_reg_block rm;
            if(!uvm_config_db#(canfd_reg_block)::get(null,"*","RegModel",rm))
                `uvm_fatal(get_type_name(),"No RegModel")
        `endif
        `uvm_info(get_type_name(),"===== C-02-04: 验证 ID=0 的帧（最高优先级） Start =====",UVM_LOW)

        // 最小ID=0(最高优先级)
        `ifdef REG_MODEL
        rm.SRR.write(st,0,UVM_FRONTDOOR); rm.BRPR.write(st,4,UVM_FRONTDOOR); rm.SRR.write(st,32'h2,UVM_FRONTDOOR);
        `uvm_info(get_type_name(),"Min ID=0 (highest priority) frame",UVM_MEDIUM)
        repeat(100) @(posedge canfdvif.clk); pass++;
        `endif

        `uvm_info(get_type_name(),$sformatf("===== C-02-04 Done: %0d pass, %0d fail =====",pass,fail),UVM_LOW)
    endtask
endclass

class canfd_C_02_04_corner_id0_test extends canfd_base_test;
    `uvm_component_utils(canfd_C_02_04_corner_id0_test)
    function new(string n="canfd_C_02_04_corner_id0_test",uvm_component p=null); super.new(n,p); endfunction
    virtual task run_phase(uvm_phase phase);
        canfd_C_02_04_corner_id0_test_seq seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        `uvm_info(get_type_name(),"Test: C-02-04 Start",UVM_LOW)
        seq=canfd_C_02_04_corner_id0_test_seq::type_id::create("seq"); seq.start(canfd_vseqr);
        `uvm_info(get_type_name(),"Test: C-02-04 Done",UVM_LOW)
        phase.drop_objection(this);
    endtask
endclass
`endif
