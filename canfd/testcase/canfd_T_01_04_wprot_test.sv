`ifndef _CANFD_T_01_04_WPROT_TEST_SV_
`define _CANFD_T_01_04_WPROT_TEST_SV_

// CANFD Test: T-01-04 | Priority: P1
// 验证工作模式下（CEN=1），配置寄存器不可修改

class canfd_T_01_04_wprot_test_seq extends uvm_sequence;
    `uvm_object_utils(canfd_T_01_04_wprot_test_seq)
    function new(string n="canfd_T_01_04_wprot_test_seq"); super.new(n); endfunction
    virtual task body();
        uvm_status_e st; uvm_reg_data_t v, ev; int pass=0, fail=0;
        `ifdef REG_MODEL
            canfd_reg_block rm;
            if(!uvm_config_db#(canfd_reg_block)::get(null,"*","RegModel",rm))
                `uvm_fatal(get_type_name(),"No RegModel")
        `endif
        `uvm_info(get_type_name(),"===== T-01-04: 验证工作模式下（CEN=1），配置寄存器不可修改 Start =====",UVM_LOW)

        // CEN=1工作模式下，配置寄存器不可修改
        `ifdef REG_MODEL
        rm.SRR.write(st,0,UVM_FRONTDOOR); rm.BRPR.write(st,32'h55,UVM_FRONTDOOR);
        rm.SRR.write(st,32'h2,UVM_FRONTDOOR); // CEN=1
        rm.BRPR.read(st,ev,UVM_FRONTDOOR);
        rm.BRPR.write(st,32'hAA,UVM_FRONTDOOR); // 尝试修改
        rm.BRPR.read(st,v,UVM_FRONTDOOR);
        if(v===32'h55) pass++; else begin `uvm_error(get_type_name(),"Config write protection failed"); fail++; end
        rm.SRR.write(st,0,UVM_FRONTDOOR);
        `endif

        `uvm_info(get_type_name(),$sformatf("===== T-01-04 Done: %0d pass, %0d fail =====",pass,fail),UVM_LOW)
    endtask
endclass

class canfd_T_01_04_wprot_test extends canfd_base_test;
    `uvm_component_utils(canfd_T_01_04_wprot_test)
    function new(string n="canfd_T_01_04_wprot_test",uvm_component p=null); super.new(n,p); endfunction
    virtual task run_phase(uvm_phase phase);
        canfd_T_01_04_wprot_test_seq seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        `uvm_info(get_type_name(),"Test: T-01-04 Start",UVM_LOW)
        seq=canfd_T_01_04_wprot_test_seq::type_id::create("seq"); seq.start(canfd_vseqr);
        `uvm_info(get_type_name(),"Test: T-01-04 Done",UVM_LOW)
        phase.drop_objection(this);
    endtask
endclass
`endif
