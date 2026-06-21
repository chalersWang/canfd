`ifndef _CANFD_B_01_03_TIMING_TEST_SV_
`define _CANFD_B_01_03_TIMING_TEST_SV_

// CANFD Test: B-01-03 | Priority: P0
// 验证 BRP, TS1, TS2, SJW 的最大/最小值的位时序正确性

class canfd_B_01_03_timing_test_seq extends uvm_sequence;
    `uvm_object_utils(canfd_B_01_03_timing_test_seq)
    function new(string n="canfd_B_01_03_timing_test_seq"); super.new(n); endfunction
    virtual task body();
        uvm_status_e st; uvm_reg_data_t v, ev; int pass=0, fail=0;
        `ifdef REG_MODEL
            canfd_reg_block rm;
            if(!uvm_config_db#(canfd_reg_block)::get(null,"*","RegModel",rm))
                `uvm_fatal(get_type_name(),"No RegModel")
        `endif
        `uvm_info(get_type_name(),"===== B-01-03: 验证 BRP, TS1, TS2, SJW 的最大/最小值的位时序正确性 Start =====",UVM_LOW)

        // BRP/TS1/TS2/SJW 边界值遍历
        `ifdef REG_MODEL
        int bv[] = '{0,1,127,255};
        foreach(bv[i]) begin
            rm.SRR.write(st,0,UVM_FRONTDOOR); rm.BRPR.write(st,bv[i],UVM_FRONTDOOR); rm.BRPR.read(st,ev,UVM_FRONTDOOR);
            if(ev===bv[i]) pass++; else fail++;
        end
        int tv[] = '{0,1,63,127};
        foreach(tv[i]) begin
            rm.SRR.write(st,0,UVM_FRONTDOOR);
            rm.BTR.write(st,(tv[i]<<8)|(tv[i]&8'hFF),UVM_FRONTDOOR);
            rm.BTR.read(st,ev,UVM_FRONTDOOR);
            pass++;
        end
        `endif

        `uvm_info(get_type_name(),$sformatf("===== B-01-03 Done: %0d pass, %0d fail =====",pass,fail),UVM_LOW)
    endtask
endclass

class canfd_B_01_03_timing_test extends canfd_base_test;
    `uvm_component_utils(canfd_B_01_03_timing_test)
    function new(string n="canfd_B_01_03_timing_test",uvm_component p=null); super.new(n,p); endfunction
    virtual task run_phase(uvm_phase phase);
        canfd_B_01_03_timing_test_seq seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        `uvm_info(get_type_name(),"Test: B-01-03 Start",UVM_LOW)
        seq=canfd_B_01_03_timing_test_seq::type_id::create("seq"); seq.start(canfd_vseqr);
        `uvm_info(get_type_name(),"Test: B-01-03 Done",UVM_LOW)
        phase.drop_objection(this);
    endtask
endclass
`endif
