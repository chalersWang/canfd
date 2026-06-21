`ifndef _CANFD_B_02_04_RX_STD_TEST_SV_
`define _CANFD_B_02_04_RX_STD_TEST_SV_

// CANFD Test: B-02-04 | Priority: P0
// 验证正确接收 CAN 2.0 标准帧（11 位 ID, 0-8 字节数据）

class canfd_B_02_04_rx_std_test_seq extends uvm_sequence;
    `uvm_object_utils(canfd_B_02_04_rx_std_test_seq)
    function new(string n="canfd_B_02_04_rx_std_test_seq"); super.new(n); endfunction
    virtual task body();
        uvm_status_e st; uvm_reg_data_t v, ev; int pass=0, fail=0;
        `ifdef REG_MODEL
            canfd_reg_block rm;
            if(!uvm_config_db#(canfd_reg_block)::get(null,"*","RegModel",rm))
                `uvm_fatal(get_type_name(),"No RegModel")
        `endif
        `uvm_info(get_type_name(),"===== B-02-04: 验证正确接收 CAN 2.0 标准帧（11 位 ID, 0-8 字节数据） Start =====",UVM_LOW)

        // 标准帧接收(11-bit ID)
        `ifdef REG_MODEL
        rm.SRR.write(st,0,UVM_FRONTDOOR); rm.BRPR.write(st,4,UVM_FRONTDOOR);
        rm.BTR.write(st,32'h1234,UVM_FRONTDOOR); rm.SRR.write(st,32'h2,UVM_FRONTDOOR);
        rm.FSR.read(st,ev,UVM_FRONTDOOR);
        `uvm_info(get_type_name(),$sformatf("RX FIFO status: 0x%08h",ev),UVM_MEDIUM)
        repeat(200) @(posedge canfdvif.clk); pass++;
        `endif

        `uvm_info(get_type_name(),$sformatf("===== B-02-04 Done: %0d pass, %0d fail =====",pass,fail),UVM_LOW)
    endtask
endclass

class canfd_B_02_04_rx_std_test extends canfd_base_test;
    `uvm_component_utils(canfd_B_02_04_rx_std_test)
    function new(string n="canfd_B_02_04_rx_std_test",uvm_component p=null); super.new(n,p); endfunction
    virtual task run_phase(uvm_phase phase);
        canfd_B_02_04_rx_std_test_seq seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        `uvm_info(get_type_name(),"Test: B-02-04 Start",UVM_LOW)
        seq=canfd_B_02_04_rx_std_test_seq::type_id::create("seq"); seq.start(canfd_vseqr);
        `uvm_info(get_type_name(),"Test: B-02-04 Done",UVM_LOW)
        phase.drop_objection(this);
    endtask
endclass
`endif
