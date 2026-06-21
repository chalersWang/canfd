`ifndef _CANFD_VIF_SV_
`define _CANFD_VIF_SV_

//=========================================================================
// canfd_vif: CANFD 顶层 virtual interface
//   包含 AXI4-Lite 接口 + CAN PHY 接口
//=========================================================================
interface canfd_vif(input logic clk, input logic rstn);

    string  TestCaseName;

    // AXI4-Lite 子接口
    axi4lite_vif  axi4litevif(clk, rstn);
    // CAN PHY 子接口
    canphy_vif    canphyvif(clk, rstn);

endinterface

`endif
