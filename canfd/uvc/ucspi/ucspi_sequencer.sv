`ifndef _UCSPI_SEQUENCER_SV_
`define _UCSPI_SEQUENCER_SV_

class ucspi_sequencer extends uvm_sequencer#(ucspi_trans);

	`uvm_component_utils(ucspi_sequencer)

	function new(string name="ucspi_sequencer",uvm_component parent=null);
		super.new(name,parent);
		//`uvm_info(get_full_name(),"new() begin ...",UVM_LOW)
		//`uvm_info(get_full_name(),"new() end ...",UVM_LOW)
	endfunction

endclass

`endif
