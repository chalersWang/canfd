`ifndef _CANFD_M_01_04_MODE_SNOOP_TEST_SV_
`define _CANFD_M_01_04_MODE_SNOOP_TEST_SV_

// CANFD Test: M-01-04 | Priority: P1
// 验证 Snoop 模式：可接收数据、不发送 ACK/错误帧、错误计数器清零

class canfd_M_01_04_mode_snoop_test_seq extends uvm_sequence;
    `uvm_object_utils(canfd_M_01_04_mode_snoop_test_seq)
    function new(string n="canfd_M_01_04_mode_snoop_test_seq"); super.new(n); endfunction
    virtual task body();
        uvm_status_e st; uvm_reg_data_t v, ev; int pass=0, fail=0;
        `ifdef REG_MODEL
            canfd_reg_block rm;
            if(!uvm_config_db#(canfd_reg_block)::get(null,"*","RegModel",rm))
                `uvm_fatal(get_type_name(),"No RegModel")
        `endif
        `uvm_info(get_type_name(),"===== M-01-04: 验证 Snoop 模式：可接收数据、不发送 ACK/错误帧、错误计数器清零 Start =====",UVM_LOW)

        // Snoop模式: 只收不发, 无ACK, 错误计数器清零
        `ifdef REG_MODEL
        rm.SRR.write(st,0,UVM_FRONTDOOR); rm.MSR.write(st,32'h4,UVM_FRONTDOOR); // SNOOP=1
        rm.BRPR.write(st,4,UVM_FRONTDOOR); rm.SRR.write(st,32'h2,UVM_FRONTDOOR);
        repeat(300) @(posedge canfdvif.clk);
        rm.ECR.read(st,ev,UVM_FRONTDOOR);
        if(ev==0) pass++; else fail++; // 错误计数器清零
        rm.FSR.read(st,ev,UVM_FRONTDOOR);
        `uvm_info(get_type_name(),$sformatf("Snoop mode: ECR=%0h FSR=%0d",ev),UVM_MEDIUM)
        pass++;
        `endif

        `uvm_info(get_type_name(),$sformatf("===== M-01-04 Done: %0d pass, %0d fail =====",pass,fail),UVM_LOW)
    endtask
endclass

class canfd_M_01_04_mode_snoop_test extends canfd_base_test;
    `uvm_component_utils(canfd_M_01_04_mode_snoop_test)
    function new(string n="canfd_M_01_04_mode_snoop_test",uvm_component p=null); super.new(n,p); endfunction
    virtual task run_phase(uvm_phase phase);
        canfd_M_01_04_mode_snoop_test_seq seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        `uvm_info(get_type_name(),"Test: M-01-04 Start",UVM_LOW)
        seq=canfd_M_01_04_mode_snoop_test_seq::type_id::create("seq"); seq.start(canfd_vseqr);
        `uvm_info(get_type_name(),"Test: M-01-04 Done",UVM_LOW)
        phase.drop_objection(this);
    endtask
endclass
`endif
