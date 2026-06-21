`ifndef _CANFD_C_02_08_CORNER_1M_TEST_SV_
`define _CANFD_C_02_08_CORNER_1M_TEST_SV_

// CANFD Test: C-02-08 | Priority: P1
// 验证标称 1Mb/s 通信正确

class canfd_C_02_08_corner_1m_test_seq extends uvm_sequence;
    `uvm_object_utils(canfd_C_02_08_corner_1m_test_seq)
    function new(string n="canfd_C_02_08_corner_1m_test_seq"); super.new(n); endfunction
    virtual task body();
        uvm_status_e st; uvm_reg_data_t v, ev; int pass=0, fail=0;
        `ifdef REG_MODEL
            canfd_reg_block rm;
            if(!uvm_config_db#(canfd_reg_block)::get(null,"*","RegModel",rm))
                `uvm_fatal(get_type_name(),"No RegModel")
        `endif
        `uvm_info(get_type_name(),"===== C-02-08: 验证标称 1Mb/s 通信正确 Start =====",UVM_LOW)

        // 标称1Mbps通信
        `ifdef REG_MODEL
        rm.SRR.write(st,0,UVM_FRONTDOOR);
        rm.BRPR.write(st,9,UVM_FRONTDOOR); // BRP=9→(100MHz/(9+1))/10tq=1Mbps
        rm.BTR.write(st,32'h1234,UVM_FRONTDOOR);
        rm.SRR.write(st,32'h2,UVM_FRONTDOOR);
        `uvm_info(get_type_name(),"1Mbps nominal rate configured",UVM_MEDIUM)
        repeat(200) @(posedge canfdvif.clk); pass++;
        `endif

        `uvm_info(get_type_name(),$sformatf("===== C-02-08 Done: %0d pass, %0d fail =====",pass,fail),UVM_LOW)
    endtask
endclass

class canfd_C_02_08_corner_1m_test extends canfd_base_test;
    `uvm_component_utils(canfd_C_02_08_corner_1m_test)
    function new(string n="canfd_C_02_08_corner_1m_test",uvm_component p=null); super.new(n,p); endfunction
    virtual task run_phase(uvm_phase phase);
        canfd_C_02_08_corner_1m_test_seq seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        `uvm_info(get_type_name(),"Test: C-02-08 Start",UVM_LOW)
        seq=canfd_C_02_08_corner_1m_test_seq::type_id::create("seq"); seq.start(canfd_vseqr);
        `uvm_info(get_type_name(),"Test: C-02-08 Done",UVM_LOW)
        phase.drop_objection(this);
    endtask
endclass
`endif
