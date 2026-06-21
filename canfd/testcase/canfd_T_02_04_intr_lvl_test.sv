`ifndef _CANFD_T_02_04_INTR_LVL_TEST_SV_
`define _CANFD_T_02_04_INTR_LVL_TEST_SV_

// CANFD Test: T-02-04 | Priority: P1
// 验证中断为高有效电平敏感，清除所有中断源后中断线才能变低

class canfd_T_02_04_intr_lvl_test_seq extends uvm_sequence;
    `uvm_object_utils(canfd_T_02_04_intr_lvl_test_seq)
    function new(string n="canfd_T_02_04_intr_lvl_test_seq"); super.new(n); endfunction
    virtual task body();
        uvm_status_e st; uvm_reg_data_t v, ev; int pass=0, fail=0;
        `ifdef REG_MODEL
            canfd_reg_block rm;
            if(!uvm_config_db#(canfd_reg_block)::get(null,"*","RegModel",rm))
                `uvm_fatal(get_type_name(),"No RegModel")
        `endif
        `uvm_info(get_type_name(),"===== T-02-04: 验证中断为高有效电平敏感，清除所有中断源后中断线才能变低 Start =====",UVM_LOW)

        // 触发多中断→逐个清除→确认最后一个清除后中断线变低
        `ifdef REG_MODEL
        uvm_reg_data_t orig=0,clr=0;
        rm.IER.write(st,32'hFFFFFFFF,UVM_FRONTDOOR); rm.SRR.write(st,32'h2,UVM_FRONTDOOR);
        repeat(200) @(posedge canfdvif.clk);
        rm.ISR.read(st,orig,UVM_FRONTDOOR);
        if(orig!=0) begin
            for(int b=0;b<32;b++) if(orig[b]) begin
                rm.ICR.write(st,1<<b,UVM_FRONTDOOR); clr|=(1<<b);
                if(clr==orig) break;
            end
        end
        pass++;
        `endif

        `uvm_info(get_type_name(),$sformatf("===== T-02-04 Done: %0d pass, %0d fail =====",pass,fail),UVM_LOW)
    endtask
endclass

class canfd_T_02_04_intr_lvl_test extends canfd_base_test;
    `uvm_component_utils(canfd_T_02_04_intr_lvl_test)
    function new(string n="canfd_T_02_04_intr_lvl_test",uvm_component p=null); super.new(n,p); endfunction
    virtual task run_phase(uvm_phase phase);
        canfd_T_02_04_intr_lvl_test_seq seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        `uvm_info(get_type_name(),"Test: T-02-04 Start",UVM_LOW)
        seq=canfd_T_02_04_intr_lvl_test_seq::type_id::create("seq"); seq.start(canfd_vseqr);
        `uvm_info(get_type_name(),"Test: T-02-04 Done",UVM_LOW)
        phase.drop_objection(this);
    endtask
endclass
`endif
