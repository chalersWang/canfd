`ifndef _UCSPI_AGENT_SV_
`define _UCSPI_AGENT_SV_

//=========================================================================
// ucspi_agent: ucspi UVC 的顶层 agent
//   UVM_ACTIVE: 例化 driver + sequencer + monitor
//   UVM_PASSIVE: 仅例化 monitor
//   内建 agent_callback，支持 agent 级扩展
//=========================================================================
class ucspi_agent extends uvm_agent;

	// is_active 控制 agent 工作模式（active=可驱动，passive=纯监控）
	uvm_active_passive_enum is_active = UVM_ACTIVE;

	// 子组件句柄
	ucspi_driver    ucspi_drv;
	ucspi_sequencer ucspi_seqr;
	ucspi_monitor   ucspi_mon;

	// agent callback 池（供用户注册扩展）
	`uvm_register_cb(ucspi_agent, ucspi_agent_callback)

	`uvm_component_utils_begin(ucspi_agent)
		`uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
		`uvm_field_object(ucspi_drv,  UVM_ALL_ON)
		`uvm_field_object(ucspi_mon,  UVM_ALL_ON)
		`uvm_field_object(ucspi_seqr, UVM_ALL_ON)
	`uvm_component_utils_end

	function new(string name="ucspi_agent",uvm_component parent=null);
		super.new(name,parent);
		//`uvm_info(get_full_name(),"new() begin ...",UVM_LOW)
		//`uvm_info(get_full_name(),"new() end ...",UVM_LOW)
	endfunction

	//build_phase
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		`uvm_info(get_full_name(),"build_phase begin ...",UVM_LOW)
		// 从 config_db 获取 is_active（可由 env/test 通过 config_db 覆盖）
		uvm_config_db#(uvm_active_passive_enum)::get(this,"","is_active",is_active);
		if(is_active==UVM_ACTIVE)begin
		    ucspi_drv  = ucspi_driver::type_id::create("ucspi_drv", this);
		    ucspi_seqr = ucspi_sequencer::type_id::create("ucspi_seqr", this);
		end
		ucspi_mon = ucspi_monitor::type_id::create("ucspi_mon", this);
		`uvm_info(get_full_name(),"build_phase end ...",UVM_LOW)
	endfunction

	//connect_phase
	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		`uvm_info(get_full_name(),"connect_phase begin ...",UVM_LOW)
		// 仅在 ACTIVE 模式连接 driver ↔ sequencer 的 TLM 端口
		if(is_active==UVM_ACTIVE)begin
		    ucspi_drv.seq_item_port.connect(ucspi_seqr.seq_item_export);
		    // rsp_port 用于 driver→sequencer 的响应回传
		    ucspi_drv.rsp_port.connect(ucspi_seqr.rsp_export);
		end
		`uvm_info(get_full_name(),"connect_phase end ...",UVM_LOW)
	endfunction

	/*
	//end_of_elaboration_phase
	virtual function void end_of_elaboration_phase(uvm_phase phase);
		super.end_of_elaboration_phase(phase);
		//`uvm_info(get_full_name(),"end_of_elaboration_phase begin ...",UVM_LOW)
		//`uvm_info(get_full_name(),"end_of_elaboration_phase end ...",UVM_LOW)
	endfunction
	*/

	/*
	//start_of_simulation_phase
	virtual function void start_of_simulation_phase(uvm_phase phase);
		super.start_of_simulation_phase(phase);
		//`uvm_info(get_full_name(),"start_of_simulation_phase begin ...",UVM_LOW)
		//`uvm_info(get_full_name(),"start_of_simulation_phase end ...",UVM_LOW)
	endfunction
	*/

	/*
	//run_phase
	virtual task run_phase(uvm_phase phase);
		super.run_phase(phase);
		//`uvm_info(get_full_name(),"run_phase begin ...",UVM_LOW)
		//`uvm_info(get_full_name(),"run_phase end ...",UVM_LOW)
	endtask

	*/

	/*
	//extract_phase
	virtual function void extract_phase(uvm_phase phase);
		super.extract_phase(phase);
		//`uvm_info(get_full_name(),"extract_phase begin ...",UVM_LOW)
		//`uvm_info(get_full_name(),"extract_phase end ...",UVM_LOW)
	endfunction
	*/

	/*
	//check_phase
	virtual function void check_phase(uvm_phase phase);
		super.check_phase(phase);
		//`uvm_info(get_full_name(),"check_phase begin ...",UVM_LOW)
		//`uvm_info(get_full_name(),"check_phase end ...",UVM_LOW)
	endfunction
	*/

	/*
	//report_phase
	virtual function void report_phase(uvm_phase phase);
		super.report_phase(phase);
		//`uvm_info(get_full_name(),"report_phase begin ...",UVM_LOW)
		//`uvm_info(get_full_name(),"report_phase end ...",UVM_LOW)
	endfunction
	*/

	/*
	//final_phase
	virtual function void final_phase(uvm_phase phase);
		super.final_phase(phase);
		//`uvm_info(get_full_name(),"final_phase begin ...",UVM_LOW)
		//`uvm_info(get_full_name(),"final_phase end ...",UVM_LOW)
	endfunction
	*/

endclass : ucspi_agent

	//=========================================================================
	// ucspi_agent_callback: Agent 回调基类
	//   当需要在 agent 层面注入行为（如全局错误注入、协议拦截等）时使用
	//=========================================================================
	class ucspi_agent_callback extends uvm_callback;
		`uvm_object_utils(ucspi_agent_callback)
		function new(string name="ucspi_agent_callback");
			super.new(name);
		endfunction
	endclass : ucspi_agent_callback

`endif
