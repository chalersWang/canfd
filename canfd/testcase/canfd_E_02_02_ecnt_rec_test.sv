`ifndef _CANFD_E_02_02_ECNT_REC_TEST_SV_
`define _CANFD_E_02_02_ECNT_REC_TEST_SV_

// CANFD Test: E-02-02 | Priority: P1
// 验证接收错误 REC+1（正常）或 REC+8（发送方在错误被动状态），成功接收递减

class canfd_E_02_02_ecnt_rec_test_seq extends uvm_sequence;
    `uvm_object_utils(canfd_E_02_02_ecnt_rec_test_seq)
    function new(string n="canfd_E_02_02_ecnt_rec_test_seq"); super.new(n); endfunction
    virtual task body();
        uvm_status_e st; uvm_reg_data_t v, ev; int pass=0, fail=0;
        `ifdef REG_MODEL
            canfd_reg_block rm;
            if(!uvm_config_db#(canfd_reg_block)::get(null,"*","RegModel",rm))
                `uvm_fatal(get_type_name(),"No RegModel")
        `endif
        `uvm_info(get_type_name(),"===== E-02-02: 验证接收错误 REC+1（正常）或 REC+8（发送方在错误被动状态），成功接收递减 Start =====",UVM_LOW)

        // REC: 接收错误+1/+8, 成功递减
        `ifdef REG_MODEL
        uvm_reg_data_t rec0=ev&8'hFF;
        uvm_reg_data_t rec1=ev&8'hFF;
        rm.SRR.write(st,0,UVM_FRONTDOOR); rm.BRPR.write(st,4,UVM_FRONTDOOR); rm.SRR.write(st,32'h2,UVM_FRONTDOOR);
        rm.ECR.read(st,ev,UVM_FRONTDOOR);
        repeat(200) @(posedge canfdvif.clk);
        rm.ECR.read(st,ev,UVM_FRONTDOOR);
        `uvm_info(get_type_name(),$sformatf("REC: %0d→%0d (+1 normal, +8 if sender passive)",rec0,rec1),UVM_MEDIUM)
        pass++;
        `endif

        `uvm_info(get_type_name(),$sformatf("===== E-02-02 Done: %0d pass, %0d fail =====",pass,fail),UVM_LOW)
    endtask
endclass

class canfd_E_02_02_ecnt_rec_test extends canfd_base_test;
    `uvm_component_utils(canfd_E_02_02_ecnt_rec_test)
    function new(string n="canfd_E_02_02_ecnt_rec_test",uvm_component p=null); super.new(n,p); endfunction
    virtual task run_phase(uvm_phase phase);
        canfd_E_02_02_ecnt_rec_test_seq seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        `uvm_info(get_type_name(),"Test: E-02-02 Start",UVM_LOW)
        seq=canfd_E_02_02_ecnt_rec_test_seq::type_id::create("seq"); seq.start(canfd_vseqr);
        `uvm_info(get_type_name(),"Test: E-02-02 Done",UVM_LOW)
        phase.drop_objection(this);
    endtask
endclass
`endif
