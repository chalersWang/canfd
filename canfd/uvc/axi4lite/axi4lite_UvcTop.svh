`ifndef _AXI4LITE_UVC_TOP_SVH_
`define _AXI4LITE_UVC_TOP_SVH_

`include "uvm_macros.svh"

package axi4lite_UvcTop;

    import uvm_pkg::*;

    typedef class axi4lite_config;
    typedef class axi4lite_trans;
    typedef class axi4lite_driver;
    typedef class axi4lite_monitor;
    typedef class axi4lite_sequencer;
    typedef class axi4lite_agent;
    typedef class axi4lite_sequence_lib;

    `include "axi4lite_config.sv"
    `include "axi4lite_trans.sv"
    `include "axi4lite_driver.sv"
    `include "axi4lite_monitor.sv"
    `include "axi4lite_sequencer.sv"
    `include "axi4lite_agent.sv"
    `include "axi4lite_sequence_lib.sv"

endpackage

`endif
