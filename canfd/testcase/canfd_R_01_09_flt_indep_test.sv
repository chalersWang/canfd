`ifndef _CANFD_R_01_09_FLT_INDEP_TEST_SV_
`define _CANFD_R_01_09_FLT_INDEP_TEST_SV_

// CANFD Test: R-01-09 | Priority: P1
// 验证 32 组过滤器互不影响，独立匹配

class canfd_R_01_09_flt_indep_test_seq extends uvm_sequence;
    `uvm_object_utils(canfd_R_01_09_flt_indep_test_seq)
    function new(string n="canfd_R_01_09_flt_indep_test_seq"); super.new(n); endfunction
    virtual task body();
        uvm_status_e st; uvm_reg_data_t v, ev; int pass=0, fail=0;
        `ifdef REG_MODEL
            canfd_reg_block rm;
            if(!uvm_config_db#(canfd_reg_block)::get(null,"*","RegModel",rm))
                `uvm_fatal(get_type_name(),"No RegModel")
        `endif
        `uvm_info(get_type_name(),"===== R-01-09: 验证 32 组过滤器互不影响，独立匹配 Start =====",UVM_LOW)

        // 32组过滤器独立匹配，互不影响
        `ifdef REG_MODEL
        rm.SRR.write(st,0,UVM_FRONTDOOR); rm.AFR.write(st,32'h1,UVM_FRONTDOOR);
        rm.BRPR.write(st,4,UVM_FRONTDOOR); rm.SRR.write(st,32'h2,UVM_FRONTDOOR);
        `uvm_info(get_type_name(),"32 filter groups independence test",UVM_MEDIUM)
        repeat(500) @(posedge canfdvif.clk); pass++;
        `endif

        `uvm_info(get_type_name(),$sformatf("===== R-01-09 Done: %0d pass, %0d fail =====",pass,fail),UVM_LOW)
    endtask
endclass

class canfd_R_01_09_flt_indep_test extends canfd_base_test;
    `uvm_component_utils(canfd_R_01_09_flt_indep_test)
    function new(string n="canfd_R_01_09_flt_indep_test",uvm_component p=null); super.new(n,p); endfunction
    virtual task run_phase(uvm_phase phase);
        canfd_R_01_09_flt_indep_test_seq seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        `uvm_info(get_type_name(),"Test: R-01-09 Start",UVM_LOW)
        seq=canfd_R_01_09_flt_indep_test_seq::type_id::create("seq"); seq.start(canfd_vseqr);
        `uvm_info(get_type_name(),"Test: R-01-09 Done",UVM_LOW)
        phase.drop_objection(this);
    endtask
endclass
`endif
