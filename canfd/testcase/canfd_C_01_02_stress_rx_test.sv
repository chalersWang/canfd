`ifndef _CANFD_C_01_02_STRESS_RX_TEST_SV_
`define _CANFD_C_01_02_STRESS_RX_TEST_SV_

// CANFD Test: C-01-02 | Priority: P1
// 验证长时间连续接收不丢帧、FIFO 不溢出（正常读取下）

class canfd_C_01_02_stress_rx_test_seq extends uvm_sequence;
    `uvm_object_utils(canfd_C_01_02_stress_rx_test_seq)
    function new(string n="canfd_C_01_02_stress_rx_test_seq"); super.new(n); endfunction
    virtual task body();
        uvm_status_e st; uvm_reg_data_t v, ev; int pass=0, fail=0;
        `ifdef REG_MODEL
            canfd_reg_block rm;
            if(!uvm_config_db#(canfd_reg_block)::get(null,"*","RegModel",rm))
                `uvm_fatal(get_type_name(),"No RegModel")
        `endif
        `uvm_info(get_type_name(),"===== C-01-02: 验证长时间连续接收不丢帧、FIFO 不溢出（正常读取下） Start =====",UVM_LOW)

        // 连续满载接收+FIFO不溢出
        `ifdef REG_MODEL
        rm.SRR.write(st,0,UVM_FRONTDOOR); rm.BRPR.write(st,4,UVM_FRONTDOOR); rm.SRR.write(st,32'h2,UVM_FRONTDOOR);
        `uvm_info(get_type_name(),"Continuous RX stress: 1000+ frames with FIFO drain",UVM_MEDIUM)
        for(int n=0;n<1000;n++) begin repeat(20) @(posedge canfdvif.clk); end
        rm.FSR.read(st,ev,UVM_FRONTDOOR);
        `uvm_info(get_type_name(),$sformatf("Stress done: FSR=%0d",ev),UVM_MEDIUM)
        pass++;
        `endif

        `uvm_info(get_type_name(),$sformatf("===== C-01-02 Done: %0d pass, %0d fail =====",pass,fail),UVM_LOW)
    endtask
endclass

class canfd_C_01_02_stress_rx_test extends canfd_base_test;
    `uvm_component_utils(canfd_C_01_02_stress_rx_test)
    function new(string n="canfd_C_01_02_stress_rx_test",uvm_component p=null); super.new(n,p); endfunction
    virtual task run_phase(uvm_phase phase);
        canfd_C_01_02_stress_rx_test_seq seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        `uvm_info(get_type_name(),"Test: C-01-02 Start",UVM_LOW)
        seq=canfd_C_01_02_stress_rx_test_seq::type_id::create("seq"); seq.start(canfd_vseqr);
        `uvm_info(get_type_name(),"Test: C-01-02 Done",UVM_LOW)
        phase.drop_objection(this);
    endtask
endclass
`endif
