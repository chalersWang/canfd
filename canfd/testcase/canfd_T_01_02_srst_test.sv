`ifndef _CANFD_T_01_02_SRST_TEST_SV_
`define _CANFD_T_01_02_SRST_TEST_SV_

// CANFD Test: T-01-02 | Priority: P0
// 验证写 SRST=1 后所有配置寄存器恢复到默认值；验证复位后 16 个 AXI 时钟周期的等待约束

class canfd_T_01_02_srst_test_seq extends uvm_sequence;
    `uvm_object_utils(canfd_T_01_02_srst_test_seq)
    function new(string n="canfd_T_01_02_srst_test_seq"); super.new(n); endfunction
    virtual task body();
        uvm_status_e st; uvm_reg_data_t v, ev; int pass=0, fail=0;
        `ifdef REG_MODEL
            canfd_reg_block rm;
            if(!uvm_config_db#(canfd_reg_block)::get(null,"*","RegModel",rm))
                `uvm_fatal(get_type_name(),"No RegModel")
        `endif
        `uvm_info(get_type_name(),"===== T-01-02: 验证写 SRST=1 后所有配置寄存器恢复到默认值；验证复位后 16 个 AXI 时钟周期的等待约束 Start =====",UVM_LOW)

        // Step1: 修改所有配置寄存器为非默认值
        `ifdef REG_MODEL
        string ck[] = '{"BRPR","BTR","MSR","IER","DP_BRPR","DP_BTR"};
        rm.SRR.write(st,0,UVM_FRONTDOOR);
        rm.BRPR.write(st,32'h55,UVM_FRONTDOOR); rm.BTR.write(st,32'h1234,UVM_FRONTDOOR);
        rm.MSR.write(st,32'hAA,UVM_FRONTDOOR); rm.IER.write(st,32'hFFFFFFFF,UVM_FRONTDOOR);
        rm.DP_BRPR.write(st,32'h33,UVM_FRONTDOOR); rm.DP_BTR.write(st,32'h567,UVM_FRONTDOOR);
        // Step2: 写 SRST=1
        rm.SRR.write(st,32'h1,UVM_FRONTDOOR);
        // Step3: 检查所有寄存器恢复默认值
        foreach(ck[i]) begin
            uvm_reg rg=rm.get_reg_by_name(ck[i]); rg.read(st,ev,UVM_FRONTDOOR);
            if(ev===rg.get_reset()) pass++; else begin
                `uvm_error(get_type_name(),$sformatf("SRST fail: %s exp=%0h got=%0h",ck[i],rg.get_reset(),ev)); fail++;
            end
        end
        // Step4: 等待16个AXI时钟周期后访问
        repeat(16) @(posedge canfdvif.clk);
        rm.SRR.read(st,ev,UVM_FRONTDOOR);
        if(st==UVM_IS_OK) pass++; else fail++;
        `endif

        `uvm_info(get_type_name(),$sformatf("===== T-01-02 Done: %0d pass, %0d fail =====",pass,fail),UVM_LOW)
    endtask
endclass

class canfd_T_01_02_srst_test extends canfd_base_test;
    `uvm_component_utils(canfd_T_01_02_srst_test)
    function new(string n="canfd_T_01_02_srst_test",uvm_component p=null); super.new(n,p); endfunction
    virtual task run_phase(uvm_phase phase);
        canfd_T_01_02_srst_test_seq seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        `uvm_info(get_type_name(),"Test: T-01-02 Start",UVM_LOW)
        seq=canfd_T_01_02_srst_test_seq::type_id::create("seq"); seq.start(canfd_vseqr);
        `uvm_info(get_type_name(),"Test: T-01-02 Done",UVM_LOW)
        phase.drop_objection(this);
    endtask
endclass
`endif
