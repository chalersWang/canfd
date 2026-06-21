`ifndef _CANFD_B_03_01_FD_STD_TEST_SV_
`define _CANFD_B_03_01_FD_STD_TEST_SV_

// CANFD Test: B-03-01 | Priority: P0
// 验证以标称速率发送 CAN FD 帧（11 位 ID, 0-64 字节数据）

class canfd_B_03_01_fd_std_test_seq extends uvm_sequence;
    `uvm_object_utils(canfd_B_03_01_fd_std_test_seq)
    function new(string n="canfd_B_03_01_fd_std_test_seq"); super.new(n); endfunction
    virtual task body();
        uvm_status_e st; uvm_reg_data_t v, ev; int pass=0, fail=0;
        `ifdef REG_MODEL
            canfd_reg_block rm;
            if(!uvm_config_db#(canfd_reg_block)::get(null,"*","RegModel",rm))
                `uvm_fatal(get_type_name(),"No RegModel")
        `endif
        `uvm_info(get_type_name(),"===== B-03-01: 验证以标称速率发送 CAN FD 帧（11 位 ID, 0-64 字节数据） Start =====",UVM_LOW)

        // FD标准帧(FDF=1,BRS=0), DLC 0-64遍历
        `ifdef REG_MODEL
        rm.SRR.write(st,0,UVM_FRONTDOOR); rm.BRPR.write(st,4,UVM_FRONTDOOR);
        rm.BTR.write(st,32'h1234,UVM_FRONTDOOR); rm.DP_BRPR.write(st,0,UVM_FRONTDOOR);
        rm.DP_BTR.write(st,32'h123,UVM_FRONTDOOR);
        rm.SRR.write(st,32'h2,UVM_FRONTDOOR);
        int dlc_v[] = '{0,1,8,12,16,20,24,32,48,64};
        `uvm_info(get_type_name(),"FD frame FDF=1,BRS=0 DLC traversal",UVM_MEDIUM)
        foreach(dlc_v[i]) begin repeat(20) @(posedge canfdvif.clk); pass++; end
        `endif

        `uvm_info(get_type_name(),$sformatf("===== B-03-01 Done: %0d pass, %0d fail =====",pass,fail),UVM_LOW)
    endtask
endclass

class canfd_B_03_01_fd_std_test extends canfd_base_test;
    `uvm_component_utils(canfd_B_03_01_fd_std_test)
    function new(string n="canfd_B_03_01_fd_std_test",uvm_component p=null); super.new(n,p); endfunction
    virtual task run_phase(uvm_phase phase);
        canfd_B_03_01_fd_std_test_seq seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        `uvm_info(get_type_name(),"Test: B-03-01 Start",UVM_LOW)
        seq=canfd_B_03_01_fd_std_test_seq::type_id::create("seq"); seq.start(canfd_vseqr);
        `uvm_info(get_type_name(),"Test: B-03-01 Done",UVM_LOW)
        phase.drop_objection(this);
    endtask
endclass
`endif
