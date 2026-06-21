`ifndef _CANFD_S_01_01_TSR_CNT_TEST_SV_
`define _CANFD_S_01_01_TSR_CNT_TEST_SV_

// CANFD Test: S-01-01 | Priority: P1
// 验证 16 位 TSR 自由运行递增正确

class canfd_S_01_01_tsr_cnt_test_seq extends uvm_sequence;
    `uvm_object_utils(canfd_S_01_01_tsr_cnt_test_seq)
    function new(string n="canfd_S_01_01_tsr_cnt_test_seq"); super.new(n); endfunction
    virtual task body();
        uvm_status_e st; uvm_reg_data_t v, ev; int pass=0, fail=0;
        `ifdef REG_MODEL
            canfd_reg_block rm;
            if(!uvm_config_db#(canfd_reg_block)::get(null,"*","RegModel",rm))
                `uvm_fatal(get_type_name(),"No RegModel")
        `endif
        `uvm_info(get_type_name(),"===== S-01-01: 验证 16 位 TSR 自由运行递增正确 Start =====",UVM_LOW)

        // TSR 16-bit自由运行计数器递增
        `ifdef REG_MODEL
        uvm_reg_data_t ts1=(ev>>16)&16'hFFFF;
        uvm_reg_data_t ts2=(v>>16)&16'hFFFF;
        rm.TSR.read(st,ev,UVM_FRONTDOOR);
        repeat(50) @(posedge canfdvif.clk);
        rm.TSR.read(st,v,UVM_FRONTDOOR);
        if(ts2>ts1) pass++; else fail++;
        `uvm_info(get_type_name(),$sformatf("TSR: %0d → %0d (monotonic)",ts1,ts2),UVM_MEDIUM)
        `endif

        `uvm_info(get_type_name(),$sformatf("===== S-01-01 Done: %0d pass, %0d fail =====",pass,fail),UVM_LOW)
    endtask
endclass

class canfd_S_01_01_tsr_cnt_test extends canfd_base_test;
    `uvm_component_utils(canfd_S_01_01_tsr_cnt_test)
    function new(string n="canfd_S_01_01_tsr_cnt_test",uvm_component p=null); super.new(n,p); endfunction
    virtual task run_phase(uvm_phase phase);
        canfd_S_01_01_tsr_cnt_test_seq seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        `uvm_info(get_type_name(),"Test: S-01-01 Start",UVM_LOW)
        seq=canfd_S_01_01_tsr_cnt_test_seq::type_id::create("seq"); seq.start(canfd_vseqr);
        `uvm_info(get_type_name(),"Test: S-01-01 Done",UVM_LOW)
        phase.drop_objection(this);
    endtask
endclass
`endif
