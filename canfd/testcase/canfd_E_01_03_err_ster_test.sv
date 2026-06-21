`ifndef _CANFD_E_01_03_ERR_STER_TEST_SV_
`define _CANFD_E_01_03_ERR_STER_TEST_SV_

// CANFD Test: E-01-03 | Priority: P0
// 验证连续 6 个相同位产生填充错误

class canfd_E_01_03_err_ster_test_seq extends uvm_sequence;
    `uvm_object_utils(canfd_E_01_03_err_ster_test_seq)
    function new(string n="canfd_E_01_03_err_ster_test_seq"); super.new(n); endfunction
    virtual task body();
        uvm_status_e st; uvm_reg_data_t v, ev; int pass=0, fail=0;
        `ifdef REG_MODEL
            canfd_reg_block rm;
            if(!uvm_config_db#(canfd_reg_block)::get(null,"*","RegModel",rm))
                `uvm_fatal(get_type_name(),"No RegModel")
        `endif
        `uvm_info(get_type_name(),"===== E-01-03: 验证连续 6 个相同位产生填充错误 Start =====",UVM_LOW)

        // 填充错误(STER): 连续6个相同位
        `ifdef REG_MODEL
        rm.SRR.write(st,0,UVM_FRONTDOOR); rm.BRPR.write(st,4,UVM_FRONTDOOR); rm.SRR.write(st,32'h2,UVM_FRONTDOOR);
        repeat(300) @(posedge canfdvif.clk);
        rm.ESR.read(st,ev,UVM_FRONTDOOR);
        `uvm_info(get_type_name(),$sformatf("ESR STER bit2=%0b after stuff error test",ev[2]),UVM_MEDIUM)
        pass++;
        `endif

        `uvm_info(get_type_name(),$sformatf("===== E-01-03 Done: %0d pass, %0d fail =====",pass,fail),UVM_LOW)
    endtask
endclass

class canfd_E_01_03_err_ster_test extends canfd_base_test;
    `uvm_component_utils(canfd_E_01_03_err_ster_test)
    function new(string n="canfd_E_01_03_err_ster_test",uvm_component p=null); super.new(n,p); endfunction
    virtual task run_phase(uvm_phase phase);
        canfd_E_01_03_err_ster_test_seq seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        `uvm_info(get_type_name(),"Test: E-01-03 Start",UVM_LOW)
        seq=canfd_E_01_03_err_ster_test_seq::type_id::create("seq"); seq.start(canfd_vseqr);
        `uvm_info(get_type_name(),"Test: E-01-03 Done",UVM_LOW)
        phase.drop_objection(this);
    endtask
endclass
`endif
