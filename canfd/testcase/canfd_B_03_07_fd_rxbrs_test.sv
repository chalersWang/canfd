`ifndef _CANFD_B_03_07_FD_RXBRS_TEST_SV_
`define _CANFD_B_03_07_FD_RXBRS_TEST_SV_

// CANFD Test: B-03-07 | Priority: P1
// 验证接收 BRS=1 的 FD 帧时数据段速率切换正确

class canfd_B_03_07_fd_rxbrs_test_seq extends uvm_sequence;
    `uvm_object_utils(canfd_B_03_07_fd_rxbrs_test_seq)
    function new(string n="canfd_B_03_07_fd_rxbrs_test_seq"); super.new(n); endfunction
    virtual task body();
        uvm_status_e st; uvm_reg_data_t v, ev; int pass=0, fail=0;
        `ifdef REG_MODEL
            canfd_reg_block rm;
            if(!uvm_config_db#(canfd_reg_block)::get(null,"*","RegModel",rm))
                `uvm_fatal(get_type_name(),"No RegModel")
        `endif
        `uvm_info(get_type_name(),"===== B-03-07: 验证接收 BRS=1 的 FD 帧时数据段速率切换正确 Start =====",UVM_LOW)

        // FD帧BRS=1速率切换接收
        `ifdef REG_MODEL
        rm.SRR.write(st,0,UVM_FRONTDOOR); rm.BRPR.write(st,9,UVM_FRONTDOOR);
        rm.DP_BRPR.write(st,0,UVM_FRONTDOOR); rm.DP_BTR.write(st,32'h123,UVM_FRONTDOOR);
        rm.SRR.write(st,32'h2,UVM_FRONTDOOR);
        `uvm_info(get_type_name(),"FD BRS=1 rate switch RX",UVM_MEDIUM)
        repeat(200) @(posedge canfdvif.clk); pass++;
        `endif

        `uvm_info(get_type_name(),$sformatf("===== B-03-07 Done: %0d pass, %0d fail =====",pass,fail),UVM_LOW)
    endtask
endclass

class canfd_B_03_07_fd_rxbrs_test extends canfd_base_test;
    `uvm_component_utils(canfd_B_03_07_fd_rxbrs_test)
    function new(string n="canfd_B_03_07_fd_rxbrs_test",uvm_component p=null); super.new(n,p); endfunction
    virtual task run_phase(uvm_phase phase);
        canfd_B_03_07_fd_rxbrs_test_seq seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        `uvm_info(get_type_name(),"Test: B-03-07 Start",UVM_LOW)
        seq=canfd_B_03_07_fd_rxbrs_test_seq::type_id::create("seq"); seq.start(canfd_vseqr);
        `uvm_info(get_type_name(),"Test: B-03-07 Done",UVM_LOW)
        phase.drop_objection(this);
    endtask
endclass
`endif
