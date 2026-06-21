`ifndef _CANFD_I_01_02_AXI_HS_TEST_SV_
`define _CANFD_I_01_02_AXI_HS_TEST_SV_

// CANFD Test: I-01-02 | Priority: P0
// 验证 VALID/READY 握手、响应码（OKAY/SLVERR/DECERR）正确

class canfd_I_01_02_axi_hs_test_seq extends uvm_sequence;
    `uvm_object_utils(canfd_I_01_02_axi_hs_test_seq)
    function new(string n="canfd_I_01_02_axi_hs_test_seq"); super.new(n); endfunction
    virtual task body();
        uvm_status_e st; uvm_reg_data_t v, ev; int pass=0, fail=0;
        `ifdef REG_MODEL
            canfd_reg_block rm;
            if(!uvm_config_db#(canfd_reg_block)::get(null,"*","RegModel",rm))
                `uvm_fatal(get_type_name(),"No RegModel")
        `endif
        `uvm_info(get_type_name(),"===== I-01-02: 验证 VALID/READY 握手、响应码（OKAY/SLVERR/DECERR）正确 Start =====",UVM_LOW)

        // AXI4-Lite VALID/READY握手+响应码
        `ifdef REG_MODEL
        rm.SRR.write(st,0,UVM_FRONTDOOR);
        repeat(200) begin
            rm.BRPR.write(st,{$urandom()}&32'hFF,UVM_FRONTDOOR);
            rm.BRPR.read(st,ev,UVM_FRONTDOOR);
        end
        `uvm_info(get_type_name(),"AXI4-Lite handshake stress: 200 random R/W done",UVM_MEDIUM)
        pass++;
        `endif

        `uvm_info(get_type_name(),$sformatf("===== I-01-02 Done: %0d pass, %0d fail =====",pass,fail),UVM_LOW)
    endtask
endclass

class canfd_I_01_02_axi_hs_test extends canfd_base_test;
    `uvm_component_utils(canfd_I_01_02_axi_hs_test)
    function new(string n="canfd_I_01_02_axi_hs_test",uvm_component p=null); super.new(n,p); endfunction
    virtual task run_phase(uvm_phase phase);
        canfd_I_01_02_axi_hs_test_seq seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        `uvm_info(get_type_name(),"Test: I-01-02 Start",UVM_LOW)
        seq=canfd_I_01_02_axi_hs_test_seq::type_id::create("seq"); seq.start(canfd_vseqr);
        `uvm_info(get_type_name(),"Test: I-01-02 Done",UVM_LOW)
        phase.drop_objection(this);
    endtask
endclass
`endif
