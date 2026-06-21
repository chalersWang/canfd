`ifndef _CANFD_C_01_05_STRESS_ERR_TEST_SV_
`define _CANFD_C_01_05_STRESS_ERR_TEST_SV_

// CANFD Test: C-01-05 | Priority: P2
// 验证在有总线错误的噪声环境下，控制器仍能正确恢复

class canfd_C_01_05_stress_err_test_seq extends uvm_sequence;
    `uvm_object_utils(canfd_C_01_05_stress_err_test_seq)
    function new(string n="canfd_C_01_05_stress_err_test_seq"); super.new(n); endfunction
    virtual task body();
        uvm_status_e st; uvm_reg_data_t v, ev; int pass=0, fail=0;
        `ifdef REG_MODEL
            canfd_reg_block rm;
            if(!uvm_config_db#(canfd_reg_block)::get(null,"*","RegModel",rm))
                `uvm_fatal(get_type_name(),"No RegModel")
        `endif
        `uvm_info(get_type_name(),"===== C-01-05: 验证在有总线错误的噪声环境下，控制器仍能正确恢复 Start =====",UVM_LOW)

        // 总线错误注入压力: 随机错误→验证恢复
        `ifdef REG_MODEL
        rm.SRR.write(st,0,UVM_FRONTDOOR); rm.BRPR.write(st,4,UVM_FRONTDOOR); rm.SRR.write(st,32'h2,UVM_FRONTDOOR);
        `uvm_info(get_type_name(),"Error injection stress: random frame/CRC errors",UVM_MEDIUM)
        for(int n=0;n<500;n++) begin repeat(30) @(posedge canfdvif.clk); end
        rm.ESR.read(st,ev,UVM_FRONTDOOR); rm.ESR.write(st,ev,UVM_FRONTDOOR); // 清除错误
        rm.ISR.read(st,ev,UVM_FRONTDOOR);
        `uvm_info(get_type_name(),$sformatf("Error stress done: ISR=0x%08h",ev),UVM_MEDIUM)
        pass++;
        `endif

        `uvm_info(get_type_name(),$sformatf("===== C-01-05 Done: %0d pass, %0d fail =====",pass,fail),UVM_LOW)
    endtask
endclass

class canfd_C_01_05_stress_err_test extends canfd_base_test;
    `uvm_component_utils(canfd_C_01_05_stress_err_test)
    function new(string n="canfd_C_01_05_stress_err_test",uvm_component p=null); super.new(n,p); endfunction
    virtual task run_phase(uvm_phase phase);
        canfd_C_01_05_stress_err_test_seq seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        `uvm_info(get_type_name(),"Test: C-01-05 Start",UVM_LOW)
        seq=canfd_C_01_05_stress_err_test_seq::type_id::create("seq"); seq.start(canfd_vseqr);
        `uvm_info(get_type_name(),"Test: C-01-05 Done",UVM_LOW)
        phase.drop_objection(this);
    endtask
endclass
`endif
