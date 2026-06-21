`ifndef _CANFD_B_01_02_ILLEGAL_TEST_SV_
`define _CANFD_B_01_02_ILLEGAL_TEST_SV_

// CANFD Test: B-01-02 | Priority: P1
// 验证 BRP=1 时 ITO 未设为 0x08 的行为；验证 LBACK/SLEEP/SNOOP 同时为 1 的行为

class canfd_B_01_02_illegal_test_seq extends uvm_sequence;
    `uvm_object_utils(canfd_B_01_02_illegal_test_seq)
    function new(string n="canfd_B_01_02_illegal_test_seq"); super.new(n); endfunction
    virtual task body();
        uvm_status_e st; uvm_reg_data_t v, ev; int pass=0, fail=0;
        `ifdef REG_MODEL
            canfd_reg_block rm;
            if(!uvm_config_db#(canfd_reg_block)::get(null,"*","RegModel",rm))
                `uvm_fatal(get_type_name(),"No RegModel")
        `endif
        `uvm_info(get_type_name(),"===== B-01-02: 验证 BRP=1 时 ITO 未设为 0x08 的行为；验证 LBACK/SLEEP/SNOOP 同时为 1 的行为 Start =====",UVM_LOW)

        // BRP=1+ITO=0非法组合 + LBACK/SLEEP/SNOOP互斥
        `ifdef REG_MODEL
        // Test1: BRP=1, ITO=0x00 → 非法
        int c=0; if(ev[2]) c++; if(ev[1]) c++; if(ev[0]) c++;
        rm.SRR.write(st,0,UVM_FRONTDOOR); rm.BRPR.write(st,0,UVM_FRONTDOOR);
        rm.MSR.write(st,0,UVM_FRONTDOOR); rm.SRR.write(st,32'h2,UVM_FRONTDOOR);
        repeat(20) @(posedge canfdvif.clk);
        // Test2: LBACK+SLEEP+SNOOP 同时=1 → 互斥检查
        rm.SRR.write(st,0,UVM_FRONTDOOR); rm.MSR.write(st,32'h7,UVM_FRONTDOOR);
        rm.MSR.read(st,ev,UVM_FRONTDOOR);
        if(c<=1) pass++; else begin
            `uvm_error(get_type_name(),"Mode mutual exclusion failed"); fail++;
        end
        `endif

        `uvm_info(get_type_name(),$sformatf("===== B-01-02 Done: %0d pass, %0d fail =====",pass,fail),UVM_LOW)
    endtask
endclass

class canfd_B_01_02_illegal_test extends canfd_base_test;
    `uvm_component_utils(canfd_B_01_02_illegal_test)
    function new(string n="canfd_B_01_02_illegal_test",uvm_component p=null); super.new(n,p); endfunction
    virtual task run_phase(uvm_phase phase);
        canfd_B_01_02_illegal_test_seq seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        `uvm_info(get_type_name(),"Test: B-01-02 Start",UVM_LOW)
        seq=canfd_B_01_02_illegal_test_seq::type_id::create("seq"); seq.start(canfd_vseqr);
        `uvm_info(get_type_name(),"Test: B-01-02 Done",UVM_LOW)
        phase.drop_objection(this);
    endtask
endclass
`endif
