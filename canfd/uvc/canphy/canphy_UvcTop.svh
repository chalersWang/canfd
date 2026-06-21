`ifndef _CANPHY_UVC_TOP_SVH_
`define _CANPHY_UVC_TOP_SVH_

`include "uvm_macros.svh"

package canphy_UvcTop;

    import uvm_pkg::*;

    typedef   class canphy_config;
    typedef   class canphy_trans;
    typedef   class canphy_driver;
    typedef   class canphy_monitor;
    typedef   class canphy_sequencer;
    typedef   class canphy_agent;
    typedef   class canphy_sequence_lib;

    `include "canphy_config.sv"
    `include "canphy_trans.sv"
    `include "canphy_driver.sv"
    `include "canphy_monitor.sv"
    `include "canphy_sequencer.sv"
    `include "canphy_agent.sv"
    `include "canphy_sequence_lib.sv"

endpackage

`endif
