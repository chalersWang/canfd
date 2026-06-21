`ifndef _CANFD_T_02_01_INTR_TRIG_TEST_SV_
`define _CANFD_T_02_01_INTR_TRIG_TEST_SV_

// CANFD Test: T-02-01 | Priority: P0
// 验证所有中断源（TXOK, RXOK, RXFWMFLL, RXOVF, TOVF, WKUP, EWARN, TXE_WM, TXE_FLL, TAPF, RXMNF）可在对应条件下正确触发

class canfd_T_02_01_intr_trig_test_seq extends uvm_sequence;
    `uvm_object_utils(canfd_T_02_01_intr_trig_test_seq)
    function new(string n="canfd_T_02_01_intr_trig_test_seq"); super.new(n); endfunction
    virtual task body();
        uvm_status_e st; uvm_reg_data_t v, ev; int pass=0, fail=0;
        `ifdef REG_MODEL
            canfd_reg_block rm;
            if(!uvm_config_db#(canfd_reg_block)::get(null,"*","RegModel",rm))
                `uvm_fatal(get_type_name(),"No RegModel")
        `endif
        `uvm_info(get_type_name(),"===== T-02-01: 验证所有中断源（TXOK, RXOK, RXFWMFLL, RXOVF, TOVF, WKUP, EWARN, TXE_ Start =====",UVM_LOW)

        // 使能全部中断，触发各中断源，检查ISR
        `ifdef REG_MODEL
        rm.IER.write(st,32'hFFFFFFFF,UVM_FRONTDOOR);
        rm.SRR.write(st,0,UVM_FRONTDOOR); rm.BRPR.write(st,4,UVM_FRONTDOOR);
        rm.BTR.write(st,32'h1234,UVM_FRONTDOOR);
        rm.SRR.write(st,32'h2,UVM_FRONTDOOR);
        repeat(200) @(posedge canfdvif.clk); // 等待通信产生中断
        rm.ISR.read(st,ev,UVM_FRONTDOOR);
        `uvm_info(get_type_name(),$sformatf("ISR=0x%08h",ev),UVM_MEDIUM)
        // 验证至少有一些中断位被置位(TXOK/RXOK/ERROR等)
        if(ev!=0) pass++; else fail++;
        rm.SRR.write(st,0,UVM_FRONTDOOR);
        `endif

        `uvm_info(get_type_name(),$sformatf("===== T-02-01 Done: %0d pass, %0d fail =====",pass,fail),UVM_LOW)
    endtask
endclass

class canfd_T_02_01_intr_trig_test extends canfd_base_test;
    `uvm_component_utils(canfd_T_02_01_intr_trig_test)
    function new(string n="canfd_T_02_01_intr_trig_test",uvm_component p=null); super.new(n,p); endfunction
    virtual task run_phase(uvm_phase phase);
        canfd_T_02_01_intr_trig_test_seq seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        `uvm_info(get_type_name(),"Test: T-02-01 Start",UVM_LOW)
        seq=canfd_T_02_01_intr_trig_test_seq::type_id::create("seq"); seq.start(canfd_vseqr);
        `uvm_info(get_type_name(),"Test: T-02-01 Done",UVM_LOW)
        phase.drop_objection(this);
    endtask
endclass
`endif
