`ifndef _UCSPI_SEQUENCE_LIB_SV_
`define _UCSPI_SEQUENCE_LIB_SV_

//=========================================================================
// ucspi_base_sequence: ucspi UVC 的基类 sequence
//   继承自 uvm_sequence，所有 ucspi 相关 sequence 应继承此类
//=========================================================================
class ucspi_base_sequence extends uvm_sequence#(ucspi_trans);

	ucspi_config ucspi_cfg;

	`uvm_object_utils(ucspi_base_sequence)

	function new(string name="ucspi_base_sequence");
		super.new(name);
	endfunction

	// pre_body: raise objection，确保 sequence 执行期间 phase 不结束
	virtual task pre_body();
		`uvm_info(get_type_name(), "pre_body begin", UVM_HIGH)
		// 使用 starting_phase raise objection（sequence 层面的 phase 控制）
		if (starting_phase != null)
			starting_phase.raise_objection(this, get_type_name());
		// 获取 config（若不需要可注释）
		if (!uvm_config_db#(ucspi_config)::get(null, get_full_name(), "ucspi_config", ucspi_cfg))
			`uvm_fatal(get_type_name(), "can not get ucspi_config object !!!")
		`uvm_info(get_type_name(), "pre_body end", UVM_HIGH)
	endtask : pre_body

	// body: 用户在此实现 sequence 行为
	//   默认发送一笔 transaction（使用 uvm_do 宏，自动 create+randomize+send）
	virtual task body();
		`uvm_info(get_type_name(), "body begin", UVM_MEDIUM)
		// ===== 用户代码区域 =====
		// 方式1: 使用 uvm_do 宏（推荐，一行搞定）
		// `uvm_do(req)
		//
		// 方式2: 使用 uvm_do_with 宏（带约束）
		// `uvm_do_with(req, { req.data == 8'h55; })
		//
		// 方式3: 手动控制（需要精细控制时）
		// req = ucspi_trans::type_id::create("req");
		// start_item(req);
		// assert(req.randomize());
		// finish_item(req);
		// ===== 用户代码区域结束 =====
		`uvm_info(get_type_name(), "body end", UVM_MEDIUM)
	endtask : body

	// post_body: drop objection，允许 phase 正常结束
	virtual task post_body();
		`uvm_info(get_type_name(), "post_body begin", UVM_HIGH)
		if (starting_phase != null)
			starting_phase.drop_objection(this, get_type_name());
		`uvm_info(get_type_name(), "post_body end", UVM_HIGH)
	endtask : post_body
endclass : ucspi_base_sequence

//=========================================================================
// ucspi_demo_sequence: 示例 sequence
//   生成单笔 transaction 并发送
//=========================================================================
class ucspi_demo_sequence extends ucspi_base_sequence;
	`uvm_object_utils(ucspi_demo_sequence)
	function new(string name="ucspi_demo_sequence");
		super.new(name);
	endfunction
	virtual task body();
		super.body();  // 调用基类 body
		// 示例：发送随机 transaction
		`uvm_do(req)
	endtask : body
endclass : ucspi_demo_sequence

`endif
