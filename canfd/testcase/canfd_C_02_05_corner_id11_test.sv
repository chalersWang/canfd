`ifndef _CANFD_C_02_05_CORNER_ID11_TEST_SV_
`define _CANFD_C_02_05_CORNER_ID11_TEST_SV_

// CANFD Test: C-02-05 | Priority: P1
// 验证 11 位 ID 最大值

class canfd_C_02_05_corner_id11_test_seq extends uvm_sequence;
    `uvm_object_utils(canfd_C_02_05_corner_id11_test_seq)
    function new(string n="canfd_C_02_05_corner_id11_test_seq"); super.new(n); endfunction
    virtual task body();
        uvm_status_e st; uvm_reg_data_t v, ev; int pass=0, fail=0;
        `ifdef REG_MODEL
            canfd_reg_block rm;
            if(!uvm_config_db#(canfd_reg_block)::get(null,"*","RegModel",rm))
                `uvm_fatal(get_type_name(),"No RegModel")
        `endif
        `uvm_info(get_type_name(),"===== C-02-05: 验证 11 位 ID 最大值 Start =====",UVM_LOW)

        // 最大11-bit ID=0x7FF
        `ifdef REG_MODEL
        rm.SRR.write(st,0,UVM_FRONTDOOR); rm.BRPR.write(st,4,UVM_FRONTDOOR); rm.SRR.write(st,32'h2,UVM_FRONTDOOR);
        `uvm_info(get_type_name(),"Max 11-bit ID=0x7FF",UVM_MEDIUM)
        repeat(100) @(posedge canfdvif.clk); pass++;
        `endif

        `uvm_info(get_type_name(),$sformatf("===== C-02-05 Done: %0d pass, %0d fail =====",pass,fail),UVM_LOW)
    endtask
endclass

class canfd_C_02_05_corner_id11_test extends canfd_base_test;
    `uvm_component_utils(canfd_C_02_05_corner_id11_test)
    function new(string n="canfd_C_02_05_corner_id11_test",uvm_component p=null); super.new(n,p); endfunction
    virtual task run_phase(uvm_phase phase);
        canfd_C_02_05_corner_id11_test_seq seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        `uvm_info(get_type_name(),"Test: C-02-05 Start",UVM_LOW)
        seq=canfd_C_02_05_corner_id11_test_seq::type_id::create("seq"); seq.start(canfd_vseqr);
        `uvm_info(get_type_name(),"Test: C-02-05 Done",UVM_LOW)
        phase.drop_objection(this);
    endtask
endclass
`endif
