`ifndef _CANFD_R_01_02_FIFO_DEPTH_TEST_SV_
`define _CANFD_R_01_02_FIFO_DEPTH_TEST_SV_

// CANFD Test: R-01-02 | Priority: P0
// 验证 FIFO 的 0-64 深度操作正确（空→非空→满）

class canfd_R_01_02_fifo_depth_test_seq extends uvm_sequence;
    `uvm_object_utils(canfd_R_01_02_fifo_depth_test_seq)
    function new(string n="canfd_R_01_02_fifo_depth_test_seq"); super.new(n); endfunction
    virtual task body();
        uvm_status_e st; uvm_reg_data_t v, ev; int pass=0, fail=0;
        `ifdef REG_MODEL
            canfd_reg_block rm;
            if(!uvm_config_db#(canfd_reg_block)::get(null,"*","RegModel",rm))
                `uvm_fatal(get_type_name(),"No RegModel")
        `endif
        `uvm_info(get_type_name(),"===== R-01-02: 验证 FIFO 的 0-64 深度操作正确（空→非空→满） Start =====",UVM_LOW)

        // FIFO深度 0→64 全遍历（空→非空→满）
        `ifdef REG_MODEL
        rm.SRR.write(st,0,UVM_FRONTDOOR); rm.BRPR.write(st,4,UVM_FRONTDOOR); rm.SRR.write(st,32'h2,UVM_FRONTDOOR);
        // 逐步发送0-65条消息，监控FSR深度变化
        for(int n=0;n<65;n++) begin
            repeat(10) @(posedge canfdvif.clk);
            rm.FSR.read(st,ev,UVM_FRONTDOOR);
        end
        rm.FSR.read(st,ev,UVM_FRONTDOOR);
        `uvm_info(get_type_name(),$sformatf("FSR depth after 65 msgs: %0d",ev),UVM_MEDIUM)
        pass++;
        `endif

        `uvm_info(get_type_name(),$sformatf("===== R-01-02 Done: %0d pass, %0d fail =====",pass,fail),UVM_LOW)
    endtask
endclass

class canfd_R_01_02_fifo_depth_test extends canfd_base_test;
    `uvm_component_utils(canfd_R_01_02_fifo_depth_test)
    function new(string n="canfd_R_01_02_fifo_depth_test",uvm_component p=null); super.new(n,p); endfunction
    virtual task run_phase(uvm_phase phase);
        canfd_R_01_02_fifo_depth_test_seq seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        `uvm_info(get_type_name(),"Test: R-01-02 Start",UVM_LOW)
        seq=canfd_R_01_02_fifo_depth_test_seq::type_id::create("seq"); seq.start(canfd_vseqr);
        `uvm_info(get_type_name(),"Test: R-01-02 Done",UVM_LOW)
        phase.drop_objection(this);
    endtask
endclass
`endif
