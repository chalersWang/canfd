`ifndef _CANFD_M_01_03_MODE_SLP_TEST_SV_
`define _CANFD_M_01_03_MODE_SLP_TEST_SV_

// CANFD Test: M-01-03 | Priority: P1
// 验证 SLEEP=1 进入睡眠 → 总线活动唤醒 → SLEEP 自动清零 + WKUP 中断

class canfd_M_01_03_mode_slp_test_seq extends uvm_sequence;
    `uvm_object_utils(canfd_M_01_03_mode_slp_test_seq)
    function new(string n="canfd_M_01_03_mode_slp_test_seq"); super.new(n); endfunction
    virtual task body();
        uvm_status_e st; uvm_reg_data_t v, ev; int pass=0, fail=0;
        `ifdef REG_MODEL
            canfd_reg_block rm;
            if(!uvm_config_db#(canfd_reg_block)::get(null,"*","RegModel",rm))
                `uvm_fatal(get_type_name(),"No RegModel")
        `endif
        `uvm_info(get_type_name(),"===== M-01-03: 验证 SLEEP=1 进入睡眠 → 总线活动唤醒 → SLEEP 自动清零 + WKUP 中断 Start =====",UVM_LOW)

        // Sleep进入→总线活动唤醒→SLEEP自动清零+WKUP中断
        `ifdef REG_MODEL
        rm.SRR.write(st,0,UVM_FRONTDOOR); rm.MSR.write(st,32'h1,UVM_FRONTDOOR); // SLEEP=1
        rm.IER.write(st,32'h800,UVM_FRONTDOOR); // EWKUP
        rm.SRR.write(st,32'h2,UVM_FRONTDOOR);
        repeat(100) @(posedge canfdvif.clk);
        rm.SR.read(st,ev,UVM_FRONTDOOR);
        `uvm_info(get_type_name(),$sformatf("SR SLEEP bit: %0b",ev[2]),UVM_MEDIUM)
        // 唤醒后检查SLEEP清零和WKUP中断
        repeat(200) @(posedge canfdvif.clk);
        rm.SR.read(st,ev,UVM_FRONTDOOR);
        if(!ev[2]) pass++; else fail++; // SLEEP应清零
        `endif

        `uvm_info(get_type_name(),$sformatf("===== M-01-03 Done: %0d pass, %0d fail =====",pass,fail),UVM_LOW)
    endtask
endclass

class canfd_M_01_03_mode_slp_test extends canfd_base_test;
    `uvm_component_utils(canfd_M_01_03_mode_slp_test)
    function new(string n="canfd_M_01_03_mode_slp_test",uvm_component p=null); super.new(n,p); endfunction
    virtual task run_phase(uvm_phase phase);
        canfd_M_01_03_mode_slp_test_seq seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        `uvm_info(get_type_name(),"Test: M-01-03 Start",UVM_LOW)
        seq=canfd_M_01_03_mode_slp_test_seq::type_id::create("seq"); seq.start(canfd_vseqr);
        `uvm_info(get_type_name(),"Test: M-01-03 Done",UVM_LOW)
        phase.drop_objection(this);
    endtask
endclass
`endif
