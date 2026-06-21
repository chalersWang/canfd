`ifndef _UCSPI_CONFIG_SV_
`define _UCSPI_CONFIG_SV_

//=========================================================================
// ucspi_config: 全局验证环境配置类
//   集中管理所有子组件的配置参数
//   通过 uvm_config_db#(ucspi_config)::set/get 在层次间传递
//=========================================================================
class ucspi_config extends uvm_object;

	// ===== 全局仿真控制参数 =====
	int        drain_time       = 100;  // main_phase 结束前的 drain 时钟数
	int        max_quit_count   = 0;    // 最大允许 UVM_ERROR 数（0=不限）
	int        verbosity        = UVM_MEDIUM;  // 全局日志级别
	bit        coverage_enable  = 1;    // 是否启用覆盖率收集
	bit        check_enable     = 1;    // 是否启用 scoreboard 比对
	bit        xz_check_enable  = 1;    // 是否启用 X/Z 检查

	// ===== UVM Event Pool（跨组件同步，替代独立 event 类） =====
	// 使用方式: uvm_event_pool::get_global("clk_ready").trigger();
	// 不再使用独立的 xx_event 类，减少对象传递开销

	`uvm_object_utils_begin(ucspi_config)
		`uvm_field_int(drain_time,       UVM_ALL_ON)
		`uvm_field_int(max_quit_count,   UVM_ALL_ON)
		`uvm_field_int(verbosity,        UVM_ALL_ON)
		`uvm_field_int(coverage_enable,  UVM_ALL_ON)
		`uvm_field_int(check_enable,     UVM_ALL_ON)
		`uvm_field_int(xz_check_enable,  UVM_ALL_ON)
	`uvm_object_utils_end

	function new(string name="ucspi_config");
		super.new(name);
	endfunction : new

endclass : ucspi_config

`endif
