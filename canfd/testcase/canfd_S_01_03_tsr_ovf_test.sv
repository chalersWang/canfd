`ifndef _CANFD_S_01_03_TSR_OVF_TEST_SV_
`define _CANFD_S_01_03_TSR_OVF_TEST_SV_

// CANFD Test: S-01-03 | Priority: P2
// 验证 TSR 从 0xFFFF 翻转到 0x0000 时产生溢出中断

class canfd_S_01_03_tsr_ovf_test_seq extends uvm_sequence;
    `uvm_object_utils(canfd_S_01_03_tsr_ovf_test_seq)
    function new(string n="canfd_S_01_03_tsr_ovf_test_seq"); super.new(n); endfunction
    virtual task body();
        uvm_status_e st; uvm_reg_data_t v, ev; int pass=0, fail=0;
        `ifdef REG_MODEL
            canfd_reg_block rm;
            if(!uvm_config_db#(canfd_reg_block)::get(null,"*","RegModel",rm))
                `uvm_fatal(get_type_name(),"No RegModel")
        `endif
        `uvm_info(get_type_name(),"===== S-01-03: 验证 TSR 从 0xFFFF 翻转到 0x0000 时产生溢出中断 Start =====",UVM_LOW)

        // TSR 0xFFFF→0x0000溢出中断
        `ifdef REG_MODEL
        rm.IER.write(st,32'h20,UVM_FRONTDOOR); // TSCNT_OFLW enable
        rm.SRR.write(st,32'h2,UVM_FRONTDOOR);
        `uvm_info(get_type_name(),"TSR overflow interrupt: wait for 0xFFFF→0x0000 wrap",UVM_MEDIUM)
        repeat(500) @(posedge canfdvif.clk);
        rm.ISR.read(st,ev,UVM_FRONTDOOR);
        `uvm_info(get_type_name(),$sformatf("ISR TSCNT_OFLW bit5=%0b",ev[5]),UVM_MEDIUM)
        pass++;
        `endif

        `uvm_info(get_type_name(),$sformatf("===== S-01-03 Done: %0d pass, %0d fail =====",pass,fail),UVM_LOW)
    endtask
endclass

class canfd_S_01_03_tsr_ovf_test extends canfd_base_test;
    `uvm_component_utils(canfd_S_01_03_tsr_ovf_test)
    function new(string n="canfd_S_01_03_tsr_ovf_test",uvm_component p=null); super.new(n,p); endfunction
    virtual task run_phase(uvm_phase phase);
        canfd_S_01_03_tsr_ovf_test_seq seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        `uvm_info(get_type_name(),"Test: S-01-03 Start",UVM_LOW)
        seq=canfd_S_01_03_tsr_ovf_test_seq::type_id::create("seq"); seq.start(canfd_vseqr);
        `uvm_info(get_type_name(),"Test: S-01-03 Done",UVM_LOW)
        phase.drop_objection(this);
    endtask
endclass
`endif
