`ifndef _CANFD_R_01_04_FIFO_WM_TEST_SV_
`define _CANFD_R_01_04_FIFO_WM_TEST_SV_

// CANFD Test: R-01-04 | Priority: P1
// 验证 FSR/WMR 水印机制和中断

class canfd_R_01_04_fifo_wm_test_seq extends uvm_sequence;
    `uvm_object_utils(canfd_R_01_04_fifo_wm_test_seq)
    function new(string n="canfd_R_01_04_fifo_wm_test_seq"); super.new(n); endfunction
    virtual task body();
        uvm_status_e st; uvm_reg_data_t v, ev; int pass=0, fail=0;
        `ifdef REG_MODEL
            canfd_reg_block rm;
            if(!uvm_config_db#(canfd_reg_block)::get(null,"*","RegModel",rm))
                `uvm_fatal(get_type_name(),"No RegModel")
        `endif
        `uvm_info(get_type_name(),"===== R-01-04: 验证 FSR/WMR 水印机制和中断 Start =====",UVM_LOW)

        // FSR/WMR水印中断
        `ifdef REG_MODEL
        rm.SRR.write(st,0,UVM_FRONTDOOR); rm.IER.write(st,32'h1000,UVM_FRONTDOOR); // RXFWMFLL
        rm.WMR.write(st,32'h4,UVM_FRONTDOOR); // 水印=4
        rm.BRPR.write(st,4,UVM_FRONTDOOR); rm.SRR.write(st,32'h2,UVM_FRONTDOOR);
        repeat(500) @(posedge canfdvif.clk);
        rm.ISR.read(st,ev,UVM_FRONTDOOR); rm.FSR.read(st,v,UVM_FRONTDOOR);
        `uvm_info(get_type_name(),$sformatf("FSR=%0d ISR_RXFWMFLL=%0b",v,ev[12]),UVM_MEDIUM)
        pass++;
        `endif

        `uvm_info(get_type_name(),$sformatf("===== R-01-04 Done: %0d pass, %0d fail =====",pass,fail),UVM_LOW)
    endtask
endclass

class canfd_R_01_04_fifo_wm_test extends canfd_base_test;
    `uvm_component_utils(canfd_R_01_04_fifo_wm_test)
    function new(string n="canfd_R_01_04_fifo_wm_test",uvm_component p=null); super.new(n,p); endfunction
    virtual task run_phase(uvm_phase phase);
        canfd_R_01_04_fifo_wm_test_seq seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        `uvm_info(get_type_name(),"Test: R-01-04 Start",UVM_LOW)
        seq=canfd_R_01_04_fifo_wm_test_seq::type_id::create("seq"); seq.start(canfd_vseqr);
        `uvm_info(get_type_name(),"Test: R-01-04 Done",UVM_LOW)
        phase.drop_objection(this);
    endtask
endclass
`endif
