`ifndef _CANFD_E_01_06_ERR_FMER_TEST_SV_
`define _CANFD_E_01_06_ERR_FMER_TEST_SV_

// CANFD Test: E-01-06 | Priority: P1
// 验证固定格式位（CRC 分隔符/ACK 分隔符/EOF）非法时的检测

class canfd_E_01_06_err_fmer_test_seq extends uvm_sequence;
    `uvm_object_utils(canfd_E_01_06_err_fmer_test_seq)
    function new(string n="canfd_E_01_06_err_fmer_test_seq"); super.new(n); endfunction
    virtual task body();
        uvm_status_e st; uvm_reg_data_t v, ev; int pass=0, fail=0;
        `ifdef REG_MODEL
            canfd_reg_block rm;
            if(!uvm_config_db#(canfd_reg_block)::get(null,"*","RegModel",rm))
                `uvm_fatal(get_type_name(),"No RegModel")
        `endif
        `uvm_info(get_type_name(),"===== E-01-06: 验证固定格式位（CRC 分隔符/ACK 分隔符/EOF）非法时的检测 Start =====",UVM_LOW)

        // 格式错误(FMER): CRC分隔符等固定位非法
        `ifdef REG_MODEL
        rm.SRR.write(st,0,UVM_FRONTDOOR); rm.BRPR.write(st,4,UVM_FRONTDOOR); rm.SRR.write(st,32'h2,UVM_FRONTDOOR);
        repeat(300) @(posedge canfdvif.clk);
        rm.ESR.read(st,ev,UVM_FRONTDOOR);
        `uvm_info(get_type_name(),$sformatf("ESR FMER bit1=%0b",ev[1]),UVM_MEDIUM)
        pass++;
        `endif

        `uvm_info(get_type_name(),$sformatf("===== E-01-06 Done: %0d pass, %0d fail =====",pass,fail),UVM_LOW)
    endtask
endclass

class canfd_E_01_06_err_fmer_test extends canfd_base_test;
    `uvm_component_utils(canfd_E_01_06_err_fmer_test)
    function new(string n="canfd_E_01_06_err_fmer_test",uvm_component p=null); super.new(n,p); endfunction
    virtual task run_phase(uvm_phase phase);
        canfd_E_01_06_err_fmer_test_seq seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        `uvm_info(get_type_name(),"Test: E-01-06 Start",UVM_LOW)
        seq=canfd_E_01_06_err_fmer_test_seq::type_id::create("seq"); seq.start(canfd_vseqr);
        `uvm_info(get_type_name(),"Test: E-01-06 Done",UVM_LOW)
        phase.drop_objection(this);
    endtask
endclass
`endif
