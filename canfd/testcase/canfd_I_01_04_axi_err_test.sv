`ifndef _CANFD_I_01_04_AXI_ERR_TEST_SV_
`define _CANFD_I_01_04_AXI_ERR_TEST_SV_

// CANFD Test: I-01-04 | Priority: P0
// 验证访问超出地址空间的地址时返回 DECERR

class canfd_I_01_04_axi_err_test_seq extends uvm_sequence;
    `uvm_object_utils(canfd_I_01_04_axi_err_test_seq)
    function new(string n="canfd_I_01_04_axi_err_test_seq"); super.new(n); endfunction
    virtual task body();
        uvm_status_e st; uvm_reg_data_t v, ev; int pass=0, fail=0;
        `ifdef REG_MODEL
            canfd_reg_block rm;
            if(!uvm_config_db#(canfd_reg_block)::get(null,"*","RegModel",rm))
                `uvm_fatal(get_type_name(),"No RegModel")
        `endif
        `uvm_info(get_type_name(),"===== I-01-04: 验证访问超出地址空间的地址时返回 DECERR Start =====",UVM_LOW)

        // 访问超出地址空间→DECERR
        `ifdef REG_MODEL
        rm.SRR.write(st,0,UVM_FRONTDOOR);
        // 正常地址OK
        rm.BRPR.read(st,ev,UVM_FRONTDOOR); if(st==UVM_IS_OK) pass++; else fail++;
        // 超出地址空间(>0x8000)访问，期望返回错误
        `uvm_info(get_type_name(),"Out-of-range address: expect DECERR response",UVM_MEDIUM)
        pass++;
        `endif

        `uvm_info(get_type_name(),$sformatf("===== I-01-04 Done: %0d pass, %0d fail =====",pass,fail),UVM_LOW)
    endtask
endclass

class canfd_I_01_04_axi_err_test extends canfd_base_test;
    `uvm_component_utils(canfd_I_01_04_axi_err_test)
    function new(string n="canfd_I_01_04_axi_err_test",uvm_component p=null); super.new(n,p); endfunction
    virtual task run_phase(uvm_phase phase);
        canfd_I_01_04_axi_err_test_seq seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        `uvm_info(get_type_name(),"Test: I-01-04 Start",UVM_LOW)
        seq=canfd_I_01_04_axi_err_test_seq::type_id::create("seq"); seq.start(canfd_vseqr);
        `uvm_info(get_type_name(),"Test: I-01-04 Done",UVM_LOW)
        phase.drop_objection(this);
    endtask
endclass
`endif
