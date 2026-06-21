`ifndef _UCSPI_MONITOR_SV_
`define _UCSPI_MONITOR_SV_

//=========================================================================
// ucspi_monitor: 从接口采集 transaction，通过 analysis_port 广播
//   使用 run_phase 持续监控（监控类组件适合 run_phase，因其需全仿真期间运行）
//   内建 monitor_callback 支持用户扩展
//=========================================================================
class ucspi_monitor extends uvm_monitor;

	virtual ucspi_vif       vif;
	ucspi_trans             ucspi_tr;

	uvm_analysis_port #(ucspi_trans)    mon_analysis_port;
	`uvm_register_cb(ucspi_monitor, ucspi_monitor_callback)

	`uvm_component_utils(ucspi_monitor)

	function new(string name="ucspi_monitor",uvm_component parent=null);
		super.new(name,parent);
		//`uvm_info(get_full_name(),"new() begin ...",UVM_LOW)
		//`uvm_info(get_full_name(),"new() end ...",UVM_LOW)
	endfunction

	//build_phase
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		`uvm_info(get_full_name(),"build_phase begin ...",UVM_LOW)
		mon_analysis_port=new("mon_analysis_port",this);
		`uvm_info(get_full_name(),"build_phase end ...",UVM_LOW)
	endfunction

	//connect_phase
	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		`uvm_info(get_full_name(),"connect_phase begin ...",UVM_LOW)
		if(!uvm_config_db#(virtual ucspi_vif)::get(this,"","ucspi_vif",vif))
		    `uvm_fatal("ucspi_monitor","virtual interface must be set for it!!!")
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
	//reset_phase
	virtual task reset_phase(uvm_phase phase);
		super.reset_phase(phase);
		//`uvm_info(get_full_name(),"reset_phase begin ...",UVM_LOW)
		//`uvm_info(get_full_name(),"reset_phase end ...",UVM_LOW)
	endtask

	*/

	//=========================================================================
	// run_phase: 持续监控 DUT 信号，每个时钟周期采集一次 transaction
	//   X/Z 检查：通过 `ifdef CHECK_SIGNAL_XZ_UCSPI 宏控制
	//   覆盖率采集：通过 `ifdef COVERAGE_UCSPI 宏控制
	//   注意：原来使用 forever fork join，会导致每个时钟周期创建一个
	//   永不释放的线程，内存持续增长。已修复为串行 @(posedge vif.clk) 模式。
	//=========================================================================
	virtual task run_phase(uvm_phase phase);
		`uvm_info(get_type_name(), "run_phase begin", UVM_MEDIUM)

		forever begin

			// --- 1. 等待时钟边沿（不再用 fork，避免线程泄漏） ---
			@(posedge vif.clk);

			// --- 2. X/Z 检查（通过宏控制，不影响正常采集） ---
			`ifdef CHECK_SIGNAL_XZ_UCSPI
				// 检查所有信号是否存在 X 或 Z 状态
				if($isunknown(vif.UC_CS_spi_di)==1)
					`uvm_error(get_type_name(), $sformatf("signal:UC_CS_spi_di is X/Z at %0t", $time))
				if($isunknown(vif.UC_RD_spi_clk)==1)
					`uvm_error(get_type_name(), $sformatf("signal:UC_RD_spi_clk is X/Z at %0t", $time))
				if($isunknown(vif.UC_WR_spi_sel)==1)
					`uvm_error(get_type_name(), $sformatf("signal:UC_WR_spi_sel is X/Z at %0t", $time))
				if($isunknown(vif.UC_ADDR)==1)
					`uvm_error(get_type_name(), $sformatf("signal:UC_ADDR is X/Z at %0t", $time))
				if($isunknown(vif.UC_DATA)==1)
					`uvm_error(get_type_name(), $sformatf("signal:UC_DATA is X/Z at %0t", $time))
				if($isunknown(vif.UC_BUSY_spi_do)==1)
					`uvm_error(get_type_name(), $sformatf("signal:UC_BUSY_spi_do is X/Z at %0t", $time))
			`endif

			// --- 3. 创建 transaction 并采样接口信号 ---
			ucspi_tr = ucspi_trans::type_id::create("ucspi_tr");
			ucspi_tr.UC_CS_spi_di = vif.UC_CS_spi_di;
			ucspi_tr.UC_RD_spi_clk = vif.UC_RD_spi_clk;
			ucspi_tr.UC_WR_spi_sel = vif.UC_WR_spi_sel;
			ucspi_tr.UC_ADDR = vif.UC_ADDR;
			ucspi_tr.UC_DATA = vif.UC_DATA;
			ucspi_tr.UC_BUSY_spi_do = vif.UC_BUSY_spi_do;

			// --- 4. 调用回调：pre_collect ---
			`uvm_do_callbacks(ucspi_monitor, ucspi_monitor_callback, pre_collect(this, ucspi_tr))

			// --- 5. 广播 transaction（始终执行，不依赖宏） ---
			mon_analysis_port.write(ucspi_tr);

			// --- 6. 调用回调：post_collect ---
			`uvm_do_callbacks(ucspi_monitor, ucspi_monitor_callback, post_collect(this, ucspi_tr))
		end
		`uvm_info(get_type_name(), "run_phase end", UVM_MEDIUM)
	endtask : run_phase

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

endclass : ucspi_monitor

	//=========================================================================
	// ucspi_monitor_callback: Monitor 回调基类
	//   用户可继承此类扩展 monitor 行为（如注入错误、修改采集数据等）
	//=========================================================================
	class ucspi_monitor_callback extends uvm_callback;
		`uvm_object_utils(ucspi_monitor_callback)
		function new(string name="ucspi_monitor_callback");
			super.new(name);
		endfunction

		// 在 monitor 采样后、write 前调用，可修改 transaction
		virtual function void pre_collect(ucspi_monitor mon, ucspi_trans tr);
		endfunction

		// 在 monitor write 后调用
		virtual function void post_collect(ucspi_monitor mon, ucspi_trans tr);
		endfunction
	endclass : ucspi_monitor_callback

`endif
