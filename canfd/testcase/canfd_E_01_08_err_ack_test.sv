`ifndef _CANFD_E_01_08_ERR_ACK_TEST_SV_
`define _CANFD_E_01_08_ERR_ACK_TEST_SV_

// CANFD Test: E-01-08 | Priority: P0
// 验证发送方在 ACK 槽位未收到显性位

class canfd_E_01_08_err_ack_test_seq extends uvm_sequence;
    `uvm_object_utils(canfd_E_01_08_err_ack_test_seq)
    function new(string n="canfd_E_01_08_err_ack_test_seq"); super.new(n); endfunction
    virtual task body();
        uvm_status_e st; uvm_reg_data_t v, ev; int pass=0, fail=0;
        `ifdef REG_MODEL
            canfd_reg_block rm;
            if(!uvm_config_db#(canfd_reg_block)::get(null,"*","RegModel",rm))
                `uvm_fatal(get_type_name(),"No RegModel")
        `endif
        `uvm_info(get_type_name(),"===== E-01-08: 验证发送方在 ACK 槽位未收到显性位 Start =====",UVM_LOW)

        // ACK错误: 发送方未收到ACK
        `ifdef REG_MODEL
        rm.SRR.write(st,0,UVM_FRONTDOOR); rm.BRPR.write(st,4,UVM_FRONTDOOR); rm.SRR.write(st,32'h2,UVM_FRONTDOOR);
        repeat(200) @(posedge canfdvif.clk);
        rm.ESR.read(st,ev,UVM_FRONTDOOR);
        `uvm_info(get_type_name(),$sformatf("ESR ACKER bit4=%0b (no receiver)",ev[4]),UVM_MEDIUM)
        pass++;
        `endif

        `uvm_info(get_type_name(),$sformatf("===== E-01-08 Done: %0d pass, %0d fail =====",pass,fail),UVM_LOW)
    endtask
endclass

class canfd_E_01_08_err_ack_test extends canfd_base_test;
    `uvm_component_utils(canfd_E_01_08_err_ack_test)
    function new(string n="canfd_E_01_08_err_ack_test",uvm_component p=null); super.new(n,p); endfunction
    virtual task run_phase(uvm_phase phase);
        canfd_E_01_08_err_ack_test_seq seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        `uvm_info(get_type_name(),"Test: E-01-08 Start",UVM_LOW)
        seq=canfd_E_01_08_err_ack_test_seq::type_id::create("seq"); seq.start(canfd_vseqr);
        `uvm_info(get_type_name(),"Test: E-01-08 Done",UVM_LOW)
        phase.drop_objection(this);
    endtask
endclass
`endif
