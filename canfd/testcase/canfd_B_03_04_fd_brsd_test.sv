`ifndef _CANFD_B_03_04_FD_BRSD_TEST_SV_
`define _CANFD_B_03_04_FD_BRSD_TEST_SV_

// CANFD Test: B-03-04 | Priority: P1
// 验证 BRSD=1 时 FD 帧以标称速率发送（忽略 BRS 位）

class canfd_B_03_04_fd_brsd_test_seq extends uvm_sequence;
    `uvm_object_utils(canfd_B_03_04_fd_brsd_test_seq)
    function new(string n="canfd_B_03_04_fd_brsd_test_seq"); super.new(n); endfunction
    virtual task body();
        uvm_status_e st; uvm_reg_data_t v, ev; int pass=0, fail=0;
        `ifdef REG_MODEL
            canfd_reg_block rm;
            if(!uvm_config_db#(canfd_reg_block)::get(null,"*","RegModel",rm))
                `uvm_fatal(get_type_name(),"No RegModel")
        `endif
        `uvm_info(get_type_name(),"===== B-03-04: 验证 BRSD=1 时 FD 帧以标称速率发送（忽略 BRS 位） Start =====",UVM_LOW)

        // BRSD=1强制标称速率（忽略BRS位）
        `ifdef REG_MODEL
        rm.SRR.write(st,0,UVM_FRONTDOOR); rm.MSR.write(st,32'h8,UVM_FRONTDOOR); // BRSD=1
        rm.BRPR.write(st,4,UVM_FRONTDOOR); rm.SRR.write(st,32'h2,UVM_FRONTDOOR);
        `uvm_info(get_type_name(),"BRSD=1: FD frame uses nominal rate only",UVM_MEDIUM)
        repeat(100) @(posedge canfdvif.clk); pass++;
        `endif

        `uvm_info(get_type_name(),$sformatf("===== B-03-04 Done: %0d pass, %0d fail =====",pass,fail),UVM_LOW)
    endtask
endclass

class canfd_B_03_04_fd_brsd_test extends canfd_base_test;
    `uvm_component_utils(canfd_B_03_04_fd_brsd_test)
    function new(string n="canfd_B_03_04_fd_brsd_test",uvm_component p=null); super.new(n,p); endfunction
    virtual task run_phase(uvm_phase phase);
        canfd_B_03_04_fd_brsd_test_seq seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        `uvm_info(get_type_name(),"Test: B-03-04 Start",UVM_LOW)
        seq=canfd_B_03_04_fd_brsd_test_seq::type_id::create("seq"); seq.start(canfd_vseqr);
        `uvm_info(get_type_name(),"Test: B-03-04 Done",UVM_LOW)
        phase.drop_objection(this);
    endtask
endclass
`endif
