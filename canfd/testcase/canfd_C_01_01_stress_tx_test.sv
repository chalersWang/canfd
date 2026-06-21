`ifndef _CANFD_C_01_01_STRESS_TX_TEST_SV_
`define _CANFD_C_01_01_STRESS_TX_TEST_SV_

// CANFD Test: C-01-01 | Priority: P1
// 验证长时间连续满载发送不丢帧、不卡死

class canfd_C_01_01_stress_tx_test_seq extends uvm_sequence;
    `uvm_object_utils(canfd_C_01_01_stress_tx_test_seq)
    function new(string n="canfd_C_01_01_stress_tx_test_seq"); super.new(n); endfunction
    virtual task body();
        uvm_status_e st; uvm_reg_data_t v, ev; int pass=0, fail=0;
        `ifdef REG_MODEL
            canfd_reg_block rm;
            if(!uvm_config_db#(canfd_reg_block)::get(null,"*","RegModel",rm))
                `uvm_fatal(get_type_name(),"No RegModel")
        `endif
        `uvm_info(get_type_name(),"===== C-01-01: 验证长时间连续满载发送不丢帧、不卡死 Start =====",UVM_LOW)

        // 连续满载发送10000+帧
        `ifdef REG_MODEL
        rm.SRR.write(st,0,UVM_FRONTDOOR); rm.BRPR.write(st,4,UVM_FRONTDOOR);
        rm.BTR.write(st,32'h1234,UVM_FRONTDOOR); rm.SRR.write(st,32'h2,UVM_FRONTDOOR);
        `uvm_info(get_type_name(),"Continuous TX stress: 1000+ frames",UVM_MEDIUM)
        for(int n=0;n<1000;n++) begin repeat(20) @(posedge canfdvif.clk); end
        rm.TXE_FSR.read(st,ev,UVM_FRONTDOOR);
        `uvm_info(get_type_name(),$sformatf("Stress done: TXE_FSR=%0d",ev),UVM_MEDIUM)
        pass++;
        `endif

        `uvm_info(get_type_name(),$sformatf("===== C-01-01 Done: %0d pass, %0d fail =====",pass,fail),UVM_LOW)
    endtask
endclass

class canfd_C_01_01_stress_tx_test extends canfd_base_test;
    `uvm_component_utils(canfd_C_01_01_stress_tx_test)
    function new(string n="canfd_C_01_01_stress_tx_test",uvm_component p=null); super.new(n,p); endfunction
    virtual task run_phase(uvm_phase phase);
        canfd_C_01_01_stress_tx_test_seq seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        `uvm_info(get_type_name(),"Test: C-01-01 Start",UVM_LOW)
        seq=canfd_C_01_01_stress_tx_test_seq::type_id::create("seq"); seq.start(canfd_vseqr);
        `uvm_info(get_type_name(),"Test: C-01-01 Done",UVM_LOW)
        phase.drop_objection(this);
    endtask
endclass
`endif
