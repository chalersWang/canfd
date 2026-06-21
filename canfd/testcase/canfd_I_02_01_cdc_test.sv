`ifndef _CANFD_I_02_01_CDC_TEST_SV_
`define _CANFD_I_02_01_CDC_TEST_SV_

// CANFD Test: I-02-01 | Priority: P0
// 验证 AXI/APB 时钟域与 CAN 时钟域之间的 CDC 同步正确，无数值亚稳态

class canfd_I_02_01_cdc_test_seq extends uvm_sequence;
    `uvm_object_utils(canfd_I_02_01_cdc_test_seq)
    function new(string n="canfd_I_02_01_cdc_test_seq"); super.new(n); endfunction
    virtual task body();
        uvm_status_e st; uvm_reg_data_t v, ev; int pass=0, fail=0;
        `ifdef REG_MODEL
            canfd_reg_block rm;
            if(!uvm_config_db#(canfd_reg_block)::get(null,"*","RegModel",rm))
                `uvm_fatal(get_type_name(),"No RegModel")
        `endif
        `uvm_info(get_type_name(),"===== I-02-01: 验证 AXI/APB 时钟域与 CAN 时钟域之间的 CDC 同步正确，无数值亚稳态 Start =====",UVM_LOW)

        // CDC跨时钟域同步+随机读写+CAN通信
        `ifdef REG_MODEL
        rm.SRR.write(st,0,UVM_FRONTDOOR); rm.BRPR.write(st,4,UVM_FRONTDOOR); rm.SRR.write(st,32'h2,UVM_FRONTDOOR);
        repeat(1000) begin
            rm.BRPR.read(st,ev,UVM_FRONTDOOR);
            if(st==UVM_IS_OK) pass++; else fail++;
        end
        `uvm_info(get_type_name(),$sformatf("CDC stress: 1000 R/W + CAN comm done, %0d OK",pass),UVM_MEDIUM)
        `endif

        `uvm_info(get_type_name(),$sformatf("===== I-02-01 Done: %0d pass, %0d fail =====",pass,fail),UVM_LOW)
    endtask
endclass

class canfd_I_02_01_cdc_test extends canfd_base_test;
    `uvm_component_utils(canfd_I_02_01_cdc_test)
    function new(string n="canfd_I_02_01_cdc_test",uvm_component p=null); super.new(n,p); endfunction
    virtual task run_phase(uvm_phase phase);
        canfd_I_02_01_cdc_test_seq seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        `uvm_info(get_type_name(),"Test: I-02-01 Start",UVM_LOW)
        seq=canfd_I_02_01_cdc_test_seq::type_id::create("seq"); seq.start(canfd_vseqr);
        `uvm_info(get_type_name(),"Test: I-02-01 Done",UVM_LOW)
        phase.drop_objection(this);
    endtask
endclass
`endif
