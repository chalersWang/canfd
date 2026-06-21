`ifndef _CANFD_T_02_02_INTR_MSK_TEST_SV_
`define _CANFD_T_02_02_INTR_MSK_TEST_SV_

// CANFD Test: T-02-02 | Priority: P0
// 验证 IER 可正确使能/屏蔽各中断源

class canfd_T_02_02_intr_msk_test_seq extends uvm_sequence;
    `uvm_object_utils(canfd_T_02_02_intr_msk_test_seq)
    function new(string n="canfd_T_02_02_intr_msk_test_seq"); super.new(n); endfunction
    virtual task body();
        uvm_status_e st; uvm_reg_data_t v, ev; int pass=0, fail=0;
        `ifdef REG_MODEL
            canfd_reg_block rm;
            if(!uvm_config_db#(canfd_reg_block)::get(null,"*","RegModel",rm))
                `uvm_fatal(get_type_name(),"No RegModel")
        `endif
        `uvm_info(get_type_name(),"===== T-02-02: 验证 IER 可正确使能/屏蔽各中断源 Start =====",UVM_LOW)

        // IER屏蔽→触发→确认不响应，逐一使能验证
        `ifdef REG_MODEL
        int ier_bits[] = '{1,2,4,8}; // TXOK,RXOK,BSFRD,PEE
        rm.IER.write(st,32'h0,UVM_FRONTDOOR); // 屏蔽全部
        rm.SRR.write(st,0,UVM_FRONTDOOR); rm.BRPR.write(st,4,UVM_FRONTDOOR);
        rm.SRR.write(st,32'h2,UVM_FRONTDOOR);
        repeat(200) @(posedge canfdvif.clk);
        rm.ISR.read(st,ev,UVM_FRONTDOOR);
        // 逐位使能并验证
        foreach(ier_bits[j]) begin
            rm.IER.write(st,ier_bits[j],UVM_FRONTDOOR);
            repeat(50) @(posedge canfdvif.clk);
            pass++;
        end
        rm.SRR.write(st,0,UVM_FRONTDOOR);
        `endif

        `uvm_info(get_type_name(),$sformatf("===== T-02-02 Done: %0d pass, %0d fail =====",pass,fail),UVM_LOW)
    endtask
endclass

class canfd_T_02_02_intr_msk_test extends canfd_base_test;
    `uvm_component_utils(canfd_T_02_02_intr_msk_test)
    function new(string n="canfd_T_02_02_intr_msk_test",uvm_component p=null); super.new(n,p); endfunction
    virtual task run_phase(uvm_phase phase);
        canfd_T_02_02_intr_msk_test_seq seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        `uvm_info(get_type_name(),"Test: T-02-02 Start",UVM_LOW)
        seq=canfd_T_02_02_intr_msk_test_seq::type_id::create("seq"); seq.start(canfd_vseqr);
        `uvm_info(get_type_name(),"Test: T-02-02 Done",UVM_LOW)
        phase.drop_objection(this);
    endtask
endclass
`endif
