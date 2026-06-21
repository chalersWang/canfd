`ifndef _CANFD_B_01_01_CEN_TEST_SV_
`define _CANFD_B_01_01_CEN_TEST_SV_

// CANFD Test: B-01-01 | Priority: P0
// 验证 CEN 从 0→1 启动和 1→0 停止的正确性

class canfd_B_01_01_cen_test_seq extends uvm_sequence;
    `uvm_object_utils(canfd_B_01_01_cen_test_seq)
    function new(string n="canfd_B_01_01_cen_test_seq"); super.new(n); endfunction
    virtual task body();
        uvm_status_e st; uvm_reg_data_t v, ev; int pass=0, fail=0;
        `ifdef REG_MODEL
            canfd_reg_block rm;
            if(!uvm_config_db#(canfd_reg_block)::get(null,"*","RegModel",rm))
                `uvm_fatal(get_type_name(),"No RegModel")
        `endif
        `uvm_info(get_type_name(),"===== B-01-01: 验证 CEN 从 0→1 启动和 1→0 停止的正确性 Start =====",UVM_LOW)

        // CEN 0→1→0 完整的使能/关闭流程
        `ifdef REG_MODEL
        rm.SRR.write(st,0,UVM_FRONTDOOR);
        rm.BRPR.write(st,4,UVM_FRONTDOOR); rm.BTR.write(st,32'h1234,UVM_FRONTDOOR);
        rm.MSR.write(st,0,UVM_FRONTDOOR); // normal mode
        // CEN=1 进入正常模式
        rm.SRR.write(st,32'h2,UVM_FRONTDOOR);
        repeat(100) @(posedge canfdvif.clk);
        rm.SR.read(st,ev,UVM_FRONTDOOR);
        if(ev[3]) pass++; else fail++; // NORMAL位应置位
        // CEN=0 回配置模式
        rm.SRR.write(st,0,UVM_FRONTDOOR);
        rm.SR.read(st,ev,UVM_FRONTDOOR);
        if(ev[0]) pass++; else fail++; // CONFIG位应置位
        `endif

        `uvm_info(get_type_name(),$sformatf("===== B-01-01 Done: %0d pass, %0d fail =====",pass,fail),UVM_LOW)
    endtask
endclass

class canfd_B_01_01_cen_test extends canfd_base_test;
    `uvm_component_utils(canfd_B_01_01_cen_test)
    function new(string n="canfd_B_01_01_cen_test",uvm_component p=null); super.new(n,p); endfunction
    virtual task run_phase(uvm_phase phase);
        canfd_B_01_01_cen_test_seq seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        `uvm_info(get_type_name(),"Test: B-01-01 Start",UVM_LOW)
        seq=canfd_B_01_01_cen_test_seq::type_id::create("seq"); seq.start(canfd_vseqr);
        `uvm_info(get_type_name(),"Test: B-01-01 Done",UVM_LOW)
        phase.drop_objection(this);
    endtask
endclass
`endif
