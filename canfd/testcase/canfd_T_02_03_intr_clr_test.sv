`ifndef _CANFD_T_02_03_INTR_CLR_TEST_SV_
`define _CANFD_T_02_03_INTR_CLR_TEST_SV_

// CANFD Test: T-02-03 | Priority: P0
// 验证 ICR 写 1 可正确清除对应中断标志

class canfd_T_02_03_intr_clr_test_seq extends uvm_sequence;
    `uvm_object_utils(canfd_T_02_03_intr_clr_test_seq)
    function new(string n="canfd_T_02_03_intr_clr_test_seq"); super.new(n); endfunction
    virtual task body();
        uvm_status_e st; uvm_reg_data_t v, ev; int pass=0, fail=0;
        `ifdef REG_MODEL
            canfd_reg_block rm;
            if(!uvm_config_db#(canfd_reg_block)::get(null,"*","RegModel",rm))
                `uvm_fatal(get_type_name(),"No RegModel")
        `endif
        `uvm_info(get_type_name(),"===== T-02-03: 验证 ICR 写 1 可正确清除对应中断标志 Start =====",UVM_LOW)

        // 触发中断→ICR写1清除→ISR确认清除
        `ifdef REG_MODEL
        rm.IER.write(st,32'hFFFFFFFF,UVM_FRONTDOOR); rm.SRR.write(st,32'h2,UVM_FRONTDOOR);
        repeat(200) @(posedge canfdvif.clk);
        rm.ISR.read(st,v,UVM_FRONTDOOR);
        if(v!=0) begin
            rm.ICR.write(st,v,UVM_FRONTDOOR); // 写1清除
            rm.ISR.read(st,ev,UVM_FRONTDOOR);
            if((ev&v)==0) pass++; else fail++;
            // ICR写0不误清除
            rm.ISR.read(st,v,UVM_FRONTDOOR); rm.ICR.write(st,0,UVM_FRONTDOOR);
            rm.ISR.read(st,ev,UVM_FRONTDOOR);
            if(ev===v) pass++; else fail++;
        end
        rm.SRR.write(st,0,UVM_FRONTDOOR);
        `endif

        `uvm_info(get_type_name(),$sformatf("===== T-02-03 Done: %0d pass, %0d fail =====",pass,fail),UVM_LOW)
    endtask
endclass

class canfd_T_02_03_intr_clr_test extends canfd_base_test;
    `uvm_component_utils(canfd_T_02_03_intr_clr_test)
    function new(string n="canfd_T_02_03_intr_clr_test",uvm_component p=null); super.new(n,p); endfunction
    virtual task run_phase(uvm_phase phase);
        canfd_T_02_03_intr_clr_test_seq seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        `uvm_info(get_type_name(),"Test: T-02-03 Start",UVM_LOW)
        seq=canfd_T_02_03_intr_clr_test_seq::type_id::create("seq"); seq.start(canfd_vseqr);
        `uvm_info(get_type_name(),"Test: T-02-03 Done",UVM_LOW)
        phase.drop_objection(this);
    endtask
endclass
`endif
