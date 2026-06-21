`ifndef _CANFD_BASE_TEST_SV_
`define _CANFD_BASE_TEST_SV_

//=========================================================================
// canfd_base_test: 所有 CANFD testcase 的基类
//   职责: 例化 env、连接 vif、配置 regmodel、提供公共 run_phase 框架
//=========================================================================
class canfd_base_test extends uvm_test;

    canfd_env               env;
    virtual canfd_vif       canfdvif;

    // 寄存器模型相关
    `ifdef REG_MODEL
    canfd_reg_block         RegModel;
    canfd_reg_adapter       reg_adp;
    `endif

    `uvm_component_utils_begin(canfd_base_test)
        `uvm_field_object(env, UVM_ALL_ON)
    `uvm_field_utils_end

    function new(string name="canfd_base_test", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    //---------------------------------------------------------------------
    // build_phase: 创建 env，获取 vif，构建 regmodel
    //---------------------------------------------------------------------
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name(), "build_phase begin", UVM_LOW)

        // 获取顶层 virtual interface
        if (!uvm_config_db#(virtual canfd_vif)::get(this, "", "canfd_vif", canfdvif))
            `uvm_fatal("NOVIF", "canfd_vif not found in config_db")

        // 创建 env
        env = canfd_env::type_id::create("env", this);

        // 寄存器模型构建
        `ifdef REG_MODEL
        RegModel = canfd_reg_block::type_id::create("RegModel", this);
        RegModel.build();
        RegModel.lock_model();
        uvm_config_db#(canfd_reg_block)::set(this, "*", "RegModel", RegModel);

        reg_adp = canfd_reg_adapter::type_id::create("reg_adp", this);
        `endif

        `uvm_info(get_type_name(), "build_phase end", UVM_LOW)
    endfunction

    //---------------------------------------------------------------------
    // connect_phase: 连接 regmodel 到 AXI4-Lite sequencer
    //---------------------------------------------------------------------
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name(), "connect_phase begin", UVM_LOW)

        `ifdef REG_MODEL
        // 将 regmodel 的 default_map 连到 AXI4-Lite agent 的 sequencer
        if (env.axi4lite_agt != null) begin
            RegModel.default_map.set_sequencer(env.axi4lite_agt.axi4lite_seqr, reg_adp);
            RegModel.default_map.set_auto_predict(1);
        end
        `endif

        `uvm_info(get_type_name(), "connect_phase end", UVM_LOW)
    endfunction

    //---------------------------------------------------------------------
    // end_of_elaboration_phase: 打印拓扑
    //---------------------------------------------------------------------
    virtual function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        uvm_top.print_topology();
    endfunction

    //---------------------------------------------------------------------
    // run_phase: 基础 run_phase（子类可 override 并调用 super）
    //---------------------------------------------------------------------
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name(), "run_phase begin", UVM_LOW)

        // 等待复位释放
        @(posedge canfdvif.rstn);
        repeat(20) @(posedge canfdvif.clk); // 复位后等待 16+ 周期

        `uvm_info(get_type_name(), "run_phase: reset released, DUT ready", UVM_LOW)
    endtask

    //---------------------------------------------------------------------
    // report_phase: 打印验证结果摘要
    //---------------------------------------------------------------------
    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info(get_type_name(), "report_phase: test done", UVM_LOW)
    endfunction

endclass : canfd_base_test

`endif
