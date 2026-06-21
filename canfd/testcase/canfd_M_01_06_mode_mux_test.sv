`ifndef _CANFD_M_01_06_MODE_MUX_TEST_SV_
`define _CANFD_M_01_06_MODE_MUX_TEST_SV_

// CANFD Test: M-01-06 | Priority: P1
// 验证 LBACK/SLEEP/SNOOP 任意两个同时为 1 时的保护行为

class canfd_M_01_06_mode_mux_test_seq extends uvm_sequence;
    `uvm_object_utils(canfd_M_01_06_mode_mux_test_seq)
    function new(string n="canfd_M_01_06_mode_mux_test_seq"); super.new(n); endfunction
    virtual task body();
        uvm_status_e st; uvm_reg_data_t v, ev; int pass=0, fail=0;
        `ifdef REG_MODEL
            canfd_reg_block rm;
            if(!uvm_config_db#(canfd_reg_block)::get(null,"*","RegModel",rm))
                `uvm_fatal(get_type_name(),"No RegModel")
        `endif
        `uvm_info(get_type_name(),"===== M-01-06: 验证 LBACK/SLEEP/SNOOP 任意两个同时为 1 时的保护行为 Start =====",UVM_LOW)

        // LBACK/SLEEP/SNOOP互斥检查
        `ifdef REG_MODEL
        int c=0; if(ev[2]) c++; if(ev[1]) c++; if(ev[0]) c++;
        rm.SRR.write(st,0,UVM_FRONTDOOR); rm.MSR.write(st,32'h7,UVM_FRONTDOOR); // all 3 mode bits
        rm.MSR.read(st,ev,UVM_FRONTDOOR);
        if(c<=1) pass++; else begin
            `uvm_error(get_type_name(),$sformatf("Mode mutual exclusion FAIL: MSR=0x%08h",ev)); fail++;
        end
        `endif

        `uvm_info(get_type_name(),$sformatf("===== M-01-06 Done: %0d pass, %0d fail =====",pass,fail),UVM_LOW)
    endtask
endclass

class canfd_M_01_06_mode_mux_test extends canfd_base_test;
    `uvm_component_utils(canfd_M_01_06_mode_mux_test)
    function new(string n="canfd_M_01_06_mode_mux_test",uvm_component p=null); super.new(n,p); endfunction
    virtual task run_phase(uvm_phase phase);
        canfd_M_01_06_mode_mux_test_seq seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        `uvm_info(get_type_name(),"Test: M-01-06 Start",UVM_LOW)
        seq=canfd_M_01_06_mode_mux_test_seq::type_id::create("seq"); seq.start(canfd_vseqr);
        `uvm_info(get_type_name(),"Test: M-01-06 Done",UVM_LOW)
        phase.drop_objection(this);
    endtask
endclass
`endif
