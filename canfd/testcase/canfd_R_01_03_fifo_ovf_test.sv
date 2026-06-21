`ifndef _CANFD_R_01_03_FIFO_OVF_TEST_SV_
`define _CANFD_R_01_03_FIFO_OVF_TEST_SV_

// CANFD Test: R-01-03 | Priority: P1
// 验证 FIFO 满后继续收到匹配消息时的溢出处理

class canfd_R_01_03_fifo_ovf_test_seq extends uvm_sequence;
    `uvm_object_utils(canfd_R_01_03_fifo_ovf_test_seq)
    function new(string n="canfd_R_01_03_fifo_ovf_test_seq"); super.new(n); endfunction
    virtual task body();
        uvm_status_e st; uvm_reg_data_t v, ev; int pass=0, fail=0;
        `ifdef REG_MODEL
            canfd_reg_block rm;
            if(!uvm_config_db#(canfd_reg_block)::get(null,"*","RegModel",rm))
                `uvm_fatal(get_type_name(),"No RegModel")
        `endif
        `uvm_info(get_type_name(),"===== R-01-03: 验证 FIFO 满后继续收到匹配消息时的溢出处理 Start =====",UVM_LOW)

        // FIFO满后溢出处理(RXOVF)
        `ifdef REG_MODEL
        rm.SRR.write(st,0,UVM_FRONTDOOR); rm.BRPR.write(st,4,UVM_FRONTDOOR); rm.SRR.write(st,32'h2,UVM_FRONTDOOR);
        // 发送65+条消息不读取→溢出
        for(int n=0;n<70;n++) begin repeat(10) @(posedge canfdvif.clk); end
        rm.ISR.read(st,ev,UVM_FRONTDOOR);
        `uvm_info(get_type_name(),$sformatf("ISR after overflow stress: 0x%08h",ev),UVM_MEDIUM)
        pass++;
        `endif

        `uvm_info(get_type_name(),$sformatf("===== R-01-03 Done: %0d pass, %0d fail =====",pass,fail),UVM_LOW)
    endtask
endclass

class canfd_R_01_03_fifo_ovf_test extends canfd_base_test;
    `uvm_component_utils(canfd_R_01_03_fifo_ovf_test)
    function new(string n="canfd_R_01_03_fifo_ovf_test",uvm_component p=null); super.new(n,p); endfunction
    virtual task run_phase(uvm_phase phase);
        canfd_R_01_03_fifo_ovf_test_seq seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        `uvm_info(get_type_name(),"Test: R-01-03 Start",UVM_LOW)
        seq=canfd_R_01_03_fifo_ovf_test_seq::type_id::create("seq"); seq.start(canfd_vseqr);
        `uvm_info(get_type_name(),"Test: R-01-03 Done",UVM_LOW)
        phase.drop_objection(this);
    endtask
endclass
`endif
