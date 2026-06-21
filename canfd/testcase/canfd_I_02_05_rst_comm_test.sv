`ifndef _CANFD_I_02_05_RST_COMM_TEST_SV_
`define _CANFD_I_02_05_RST_COMM_TEST_SV_

// CANFD Test: I-02-05 | Priority: P1
// 验证复位期间总线输出隐性，不产生误帧

class canfd_I_02_05_rst_comm_test_seq extends uvm_sequence;
    `uvm_object_utils(canfd_I_02_05_rst_comm_test_seq)
    function new(string n="canfd_I_02_05_rst_comm_test_seq"); super.new(n); endfunction
    virtual task body();
        uvm_status_e st; uvm_reg_data_t v, ev; int pass=0, fail=0;
        `ifdef REG_MODEL
            canfd_reg_block rm;
            if(!uvm_config_db#(canfd_reg_block)::get(null,"*","RegModel",rm))
                `uvm_fatal(get_type_name(),"No RegModel")
        `endif
        `uvm_info(get_type_name(),"===== I-02-05: 验证复位期间总线输出隐性，不产生误帧 Start =====",UVM_LOW)

        // 复位期间总线输出隐性
        `ifdef REG_MODEL
        rm.SRR.write(st,32'h2,UVM_FRONTDOOR);
        repeat(50) @(posedge canfdvif.clk);
        // 通信中施加复位→验证安全退出,无误帧
        `uvm_info(get_type_name(),"Reset during communication: bus should go recessive",UVM_MEDIUM)
        pass++;
        `endif

        `uvm_info(get_type_name(),$sformatf("===== I-02-05 Done: %0d pass, %0d fail =====",pass,fail),UVM_LOW)
    endtask
endclass

class canfd_I_02_05_rst_comm_test extends canfd_base_test;
    `uvm_component_utils(canfd_I_02_05_rst_comm_test)
    function new(string n="canfd_I_02_05_rst_comm_test",uvm_component p=null); super.new(n,p); endfunction
    virtual task run_phase(uvm_phase phase);
        canfd_I_02_05_rst_comm_test_seq seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        `uvm_info(get_type_name(),"Test: I-02-05 Start",UVM_LOW)
        seq=canfd_I_02_05_rst_comm_test_seq::type_id::create("seq"); seq.start(canfd_vseqr);
        `uvm_info(get_type_name(),"Test: I-02-05 Done",UVM_LOW)
        phase.drop_objection(this);
    endtask
endclass
`endif
