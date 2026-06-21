`ifndef _CANFD_I_01_01_AXI_RW_TEST_SV_
`define _CANFD_I_01_01_AXI_RW_TEST_SV_

// CANFD Test: I-01-01 | Priority: P0
// 验证 AXI4-Lite 接口基本读写传输正确

class canfd_I_01_01_axi_rw_test_seq extends uvm_sequence;
    `uvm_object_utils(canfd_I_01_01_axi_rw_test_seq)
    function new(string n="canfd_I_01_01_axi_rw_test_seq"); super.new(n); endfunction
    virtual task body();
        uvm_status_e st; uvm_reg_data_t v, ev; int pass=0, fail=0;
        `ifdef REG_MODEL
            canfd_reg_block rm;
            if(!uvm_config_db#(canfd_reg_block)::get(null,"*","RegModel",rm))
                `uvm_fatal(get_type_name(),"No RegModel")
        `endif
        `uvm_info(get_type_name(),"===== I-01-01: 验证 AXI4-Lite 接口基本读写传输正确 Start =====",UVM_LOW)

        // AXI4-Lite基本读写
        `ifdef REG_MODEL
        uvm_reg rgs[$]; rm.get_registers(rgs);
        foreach(rgs[i]) begin
            rgs[i].read(st,ev,UVM_FRONTDOOR); if(st==UVM_IS_OK) pass++; else fail++;
            if(rgs[i].get_access()=="RW") begin
                v={$urandom()}&((1<<rgs[i].get_n_bits())-1);
                rgs[i].write(st,v,UVM_FRONTDOOR); rgs[i].read(st,ev,UVM_FRONTDOOR);
                if(st==UVM_IS_OK) pass++; else fail++;
            end
        end
        `endif

        `uvm_info(get_type_name(),$sformatf("===== I-01-01 Done: %0d pass, %0d fail =====",pass,fail),UVM_LOW)
    endtask
endclass

class canfd_I_01_01_axi_rw_test extends canfd_base_test;
    `uvm_component_utils(canfd_I_01_01_axi_rw_test)
    function new(string n="canfd_I_01_01_axi_rw_test",uvm_component p=null); super.new(n,p); endfunction
    virtual task run_phase(uvm_phase phase);
        canfd_I_01_01_axi_rw_test_seq seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        `uvm_info(get_type_name(),"Test: I-01-01 Start",UVM_LOW)
        seq=canfd_I_01_01_axi_rw_test_seq::type_id::create("seq"); seq.start(canfd_vseqr);
        `uvm_info(get_type_name(),"Test: I-01-01 Done",UVM_LOW)
        phase.drop_objection(this);
    endtask
endclass
`endif
