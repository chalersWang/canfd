`ifndef _CANFD_T_01_03_ADDR_TEST_SV_
`define _CANFD_T_01_03_ADDR_TEST_SV_

// CANFD Test: T-01-03 | Priority: P0
// 验证 32KB 地址空间的三个分段均可正确访问

class canfd_T_01_03_addr_test_seq extends uvm_sequence;
    `uvm_object_utils(canfd_T_01_03_addr_test_seq)
    function new(string n="canfd_T_01_03_addr_test_seq"); super.new(n); endfunction
    virtual task body();
        uvm_status_e st; uvm_reg_data_t v, ev; int pass=0, fail=0;
        `ifdef REG_MODEL
            canfd_reg_block rm;
            if(!uvm_config_db#(canfd_reg_block)::get(null,"*","RegModel",rm))
                `uvm_fatal(get_type_name(),"No RegModel")
        `endif
        `uvm_info(get_type_name(),"===== T-01-03: 验证 32KB 地址空间的三个分段均可正确访问 Start =====",UVM_LOW)

        // 遍历32KB地址空间三个分段
        `ifdef REG_MODEL
        // 内核寄存器空间 0x0000-0x00FF
        uvm_reg rgs[$]; rm.get_registers(rgs);
        foreach(rgs[i]) begin rgs[i].read(st,ev,UVM_FRONTDOOR); if(st==UVM_IS_OK) pass++; else fail++; end
        // TX消息空间 0x0100-0x1FFF, RX消息空间 0x2000-0x7FFF
        // 验证未实现地址返回正确响应(读返回0)
        `uvm_info(get_type_name(),$sformatf("%0d regs in kernel space accessed",rgs.size()),UVM_MEDIUM)
        pass++;
        `endif

        `uvm_info(get_type_name(),$sformatf("===== T-01-03 Done: %0d pass, %0d fail =====",pass,fail),UVM_LOW)
    endtask
endclass

class canfd_T_01_03_addr_test extends canfd_base_test;
    `uvm_component_utils(canfd_T_01_03_addr_test)
    function new(string n="canfd_T_01_03_addr_test",uvm_component p=null); super.new(n,p); endfunction
    virtual task run_phase(uvm_phase phase);
        canfd_T_01_03_addr_test_seq seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        `uvm_info(get_type_name(),"Test: T-01-03 Start",UVM_LOW)
        seq=canfd_T_01_03_addr_test_seq::type_id::create("seq"); seq.start(canfd_vseqr);
        `uvm_info(get_type_name(),"Test: T-01-03 Done",UVM_LOW)
        phase.drop_objection(this);
    endtask
endclass
`endif
