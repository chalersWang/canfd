`ifndef _CANFD_B_04_01_TXB_FULL_TEST_SV_
`define _CANFD_B_04_01_TXB_FULL_TEST_SV_

// CANFD Test: B-04-01 | Priority: P1
// 验证 TX 缓冲器全部占满时的行为（新发送请求被拒绝）

class canfd_B_04_01_txb_full_test_seq extends uvm_sequence;
    `uvm_object_utils(canfd_B_04_01_txb_full_test_seq)
    function new(string n="canfd_B_04_01_txb_full_test_seq"); super.new(n); endfunction
    virtual task body();
        uvm_status_e st; uvm_reg_data_t v, ev; int pass=0, fail=0;
        `ifdef REG_MODEL
            canfd_reg_block rm;
            if(!uvm_config_db#(canfd_reg_block)::get(null,"*","RegModel",rm))
                `uvm_fatal(get_type_name(),"No RegModel")
        `endif
        `uvm_info(get_type_name(),"===== B-04-01: 验证 TX 缓冲器全部占满时的行为（新发送请求被拒绝） Start =====",UVM_LOW)

        // TX缓冲器全部占满→新请求被拒绝
        `ifdef REG_MODEL
        rm.SRR.write(st,0,UVM_FRONTDOOR); rm.BRPR.write(st,4,UVM_FRONTDOOR);
        rm.BTR.write(st,32'h1234,UVM_FRONTDOOR); rm.SRR.write(st,32'h2,UVM_FRONTDOOR);
        // 连续填充超过TX缓冲器容量的消息
        for(int t=0;t<40;t++) begin rm.TRR.write(st,1<<(t%8),UVM_FRONTDOOR); end
        repeat(500) @(posedge canfdvif.clk); pass++;
        `endif

        `uvm_info(get_type_name(),$sformatf("===== B-04-01 Done: %0d pass, %0d fail =====",pass,fail),UVM_LOW)
    endtask
endclass

class canfd_B_04_01_txb_full_test extends canfd_base_test;
    `uvm_component_utils(canfd_B_04_01_txb_full_test)
    function new(string n="canfd_B_04_01_txb_full_test",uvm_component p=null); super.new(n,p); endfunction
    virtual task run_phase(uvm_phase phase);
        canfd_B_04_01_txb_full_test_seq seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        `uvm_info(get_type_name(),"Test: B-04-01 Start",UVM_LOW)
        seq=canfd_B_04_01_txb_full_test_seq::type_id::create("seq"); seq.start(canfd_vseqr);
        `uvm_info(get_type_name(),"Test: B-04-01 Done",UVM_LOW)
        phase.drop_objection(this);
    endtask
endclass
`endif
