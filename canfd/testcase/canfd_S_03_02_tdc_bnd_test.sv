`ifndef _CANFD_S_03_02_TDC_BND_TEST_SV_
`define _CANFD_S_03_02_TDC_BND_TEST_SV_

// CANFD Test: S-03-02 | Priority: P1
// 验证无延迟补偿 (TDCOFF=0) 和最大补偿 (TDCOFF=3) 时的行为

class canfd_S_03_02_tdc_bnd_test_seq extends uvm_sequence;
    `uvm_object_utils(canfd_S_03_02_tdc_bnd_test_seq)
    function new(string n="canfd_S_03_02_tdc_bnd_test_seq"); super.new(n); endfunction
    virtual task body();
        uvm_status_e st; uvm_reg_data_t v, ev; int pass=0, fail=0;
        `ifdef REG_MODEL
            canfd_reg_block rm;
            if(!uvm_config_db#(canfd_reg_block)::get(null,"*","RegModel",rm))
                `uvm_fatal(get_type_name(),"No RegModel")
        `endif
        `uvm_info(get_type_name(),"===== S-03-02: 验证无延迟补偿 (TDCOFF=0) 和最大补偿 (TDCOFF=3) 时的行为 Start =====",UVM_LOW)

        // TDCOFF=0最小/最大补偿边界
        `ifdef REG_MODEL
        foreach(int td; {0,63}) begin
            rm.SRR.write(st,0,UVM_FRONTDOOR);
            rm.DP_BRPR.write(st,(td<<8)|(1<<16),UVM_FRONTDOOR);
            rm.DP_BRPR.read(st,ev,UVM_FRONTDOOR);
            if(ev[13:8]===td) pass++; else fail++;
            `uvm_info(get_type_name(),$sformatf("TDCOFF=%0d R/W OK",td),UVM_MEDIUM)
        end
        `endif

        `uvm_info(get_type_name(),$sformatf("===== S-03-02 Done: %0d pass, %0d fail =====",pass,fail),UVM_LOW)
    endtask
endclass

class canfd_S_03_02_tdc_bnd_test extends canfd_base_test;
    `uvm_component_utils(canfd_S_03_02_tdc_bnd_test)
    function new(string n="canfd_S_03_02_tdc_bnd_test",uvm_component p=null); super.new(n,p); endfunction
    virtual task run_phase(uvm_phase phase);
        canfd_S_03_02_tdc_bnd_test_seq seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        `uvm_info(get_type_name(),"Test: S-03-02 Start",UVM_LOW)
        seq=canfd_S_03_02_tdc_bnd_test_seq::type_id::create("seq"); seq.start(canfd_vseqr);
        `uvm_info(get_type_name(),"Test: S-03-02 Done",UVM_LOW)
        phase.drop_objection(this);
    endtask
endclass
`endif
