`ifndef _CANFD_TEST_TOP_SV_
`define _CANFD_TEST_TOP_SV_

package canfd_TestTop;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import canphy_UvcTop::*;
    import axi4lite_UvcTop::*;
    import canfd_EnvTop::*;

    `include "canfd_sequence_lib.sv"
    `include "canfd_reg_sequence.sv"
    `include "canfd_base_test.sv"

endpackage

`endif
