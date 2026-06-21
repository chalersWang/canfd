`ifndef _UCSPI_UVC_TOP_SVH_
`define _UCSPI_UVC_TOP_SVH_

`include "uvm_macros.svh"

package ucspi_UvcTop;

	import uvm_pkg::*;

	typedef   class ucspi_config;
	typedef   class ucspi_trans;
	typedef   class ucspi_driver;
	typedef   class ucspi_monitor;
	typedef   class ucspi_sequencer;
	typedef   class ucspi_agent;
	typedef   class ucspi_sequence_lib;

	`include "ucspi_config.sv"
	`include "ucspi_trans.sv"
	`include "ucspi_driver.sv"
	`include "ucspi_monitor.sv"
	`include "ucspi_sequencer.sv"
	`include "ucspi_agent.sv"
	`include "ucspi_sequence_lib.sv"

endpackage

`endif
