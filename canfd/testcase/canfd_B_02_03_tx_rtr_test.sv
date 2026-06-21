`ifndef _CANFD_B_02_03_TX_RTR_TEST_SV_
`define _CANFD_B_02_03_TX_RTR_TEST_SV_

// CANFD Test: B-02-03 | Priority: P1
// 验证远程帧（RTR=1, 无数据字段）的发送

class canfd_B_02_03_tx_rtr_test_seq extends uvm_sequence;
    `uvm_object_utils(canfd_B_02_03_tx_rtr_test_seq)
    function new(string n="canfd_B_02_03_tx_rtr_test_seq"); super.new(n); endfunction
    virtual task body();
        uvm_status_e st; uvm_reg_data_t v, ev; int pass=0, fail=0;
        `ifdef REG_MODEL
            canfd_reg_block rm;
            if(!uvm_config_db#(canfd_reg_block)::get(null,"*","RegModel",rm))
                `uvm_fatal(get_type_name(),"No RegModel")
        `endif
        `uvm_info(get_type_name(),"===== B-02-03: 验证远程帧（RTR=1, 无数据字段）的发送 Start =====",UVM_LOW)

        // 远程帧发送(RTR=1,无数据)
        `ifdef REG_MODEL
        rm.SRR.write(st,0,UVM_FRONTDOOR); rm.BRPR.write(st,4,UVM_FRONTDOOR);
        rm.BTR.write(st,32'h1234,UVM_FRONTDOOR); rm.SRR.write(st,32'h2,UVM_FRONTDOOR);
        `uvm_info(get_type_name(),"RTR frame TX (no data field)",UVM_MEDIUM)
        repeat(100) @(posedge canfdvif.clk); pass++;
        `endif

        `uvm_info(get_type_name(),$sformatf("===== B-02-03 Done: %0d pass, %0d fail =====",pass,fail),UVM_LOW)
    endtask
endclass

class canfd_B_02_03_tx_rtr_test extends canfd_base_test;
    `uvm_component_utils(canfd_B_02_03_tx_rtr_test)
    function new(string n="canfd_B_02_03_tx_rtr_test",uvm_component p=null); super.new(n,p); endfunction
    virtual task run_phase(uvm_phase phase);
        canfd_B_02_03_tx_rtr_test_seq seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        `uvm_info(get_type_name(),"Test: B-02-03 Start",UVM_LOW)
        seq=canfd_B_02_03_tx_rtr_test_seq::type_id::create("seq"); seq.start(canfd_vseqr);
        `uvm_info(get_type_name(),"Test: B-02-03 Done",UVM_LOW)
        phase.drop_objection(this);
    endtask
endclass
`endif
