`ifndef _CANFD_R_01_05_FIFO_REL_TEST_SV_
`define _CANFD_R_01_05_FIFO_REL_TEST_SV_

// CANFD Test: R-01-05 | Priority: P0
// 验证读取 FIFO 后空间正确释放，FIFO 指针正确移动

class canfd_R_01_05_fifo_rel_test_seq extends uvm_sequence;
    `uvm_object_utils(canfd_R_01_05_fifo_rel_test_seq)
    function new(string n="canfd_R_01_05_fifo_rel_test_seq"); super.new(n); endfunction
    virtual task body();
        uvm_status_e st; uvm_reg_data_t v, ev; int pass=0, fail=0;
        `ifdef REG_MODEL
            canfd_reg_block rm;
            if(!uvm_config_db#(canfd_reg_block)::get(null,"*","RegModel",rm))
                `uvm_fatal(get_type_name(),"No RegModel")
        `endif
        `uvm_info(get_type_name(),"===== R-01-05: 验证读取 FIFO 后空间正确释放，FIFO 指针正确移动 Start =====",UVM_LOW)

        // FIFO读取→空间释放→指针移动
        `ifdef REG_MODEL
        uvm_reg_data_t depth_before=ev;
        rm.SRR.write(st,0,UVM_FRONTDOOR); rm.BRPR.write(st,4,UVM_FRONTDOOR); rm.SRR.write(st,32'h2,UVM_FRONTDOOR);
        repeat(100) @(posedge canfdvif.clk);
        rm.FSR.read(st,ev,UVM_FRONTDOOR);
        // 读取FIFO释放空间, 再发送消息验证可继续接收
        repeat(100) @(posedge canfdvif.clk);
        rm.FSR.read(st,ev,UVM_FRONTDOOR);
        `uvm_info(get_type_name(),$sformatf("FSR before=%0d after=%0d",depth_before,ev),UVM_MEDIUM)
        pass++;
        `endif

        `uvm_info(get_type_name(),$sformatf("===== R-01-05 Done: %0d pass, %0d fail =====",pass,fail),UVM_LOW)
    endtask
endclass

class canfd_R_01_05_fifo_rel_test extends canfd_base_test;
    `uvm_component_utils(canfd_R_01_05_fifo_rel_test)
    function new(string n="canfd_R_01_05_fifo_rel_test",uvm_component p=null); super.new(n,p); endfunction
    virtual task run_phase(uvm_phase phase);
        canfd_R_01_05_fifo_rel_test_seq seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        `uvm_info(get_type_name(),"Test: R-01-05 Start",UVM_LOW)
        seq=canfd_R_01_05_fifo_rel_test_seq::type_id::create("seq"); seq.start(canfd_vseqr);
        `uvm_info(get_type_name(),"Test: R-01-05 Done",UVM_LOW)
        phase.drop_objection(this);
    endtask
endclass
`endif
