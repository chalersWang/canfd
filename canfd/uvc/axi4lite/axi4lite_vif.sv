`ifndef _AXI4LITE_VIF_SV_
`define _AXI4LITE_VIF_SV_

//=========================================================================
// axi4lite_vif: AXI4-Lite 接口 (PG223 CANFD 主机接口)
//=========================================================================
interface axi4lite_vif(input logic clk, input logic rstn);

    // AXI4-Lite 信号
    logic [31:0] awaddr;
    logic        awvalid;
    logic        awready;
    logic [31:0] wdata;
    logic [3:0]  wstrb;
    logic        wvalid;
    logic        wready;
    logic [1:0]  bresp;
    logic        bvalid;
    logic        bready;
    logic [31:0] araddr;
    logic        arvalid;
    logic        arready;
    logic [31:0] rdata;
    logic [1:0]  rresp;
    logic        rvalid;
    logic        rready;

    // Driver clocking block (ACTIVE 模式)
    clocking dcb @(posedge clk);
        default input #1step output #0;
        output awaddr, awvalid, wdata, wstrb, wvalid, bready,
               araddr, arvalid, rready;
        input  awready, wready, bresp, bvalid,
               arready, rdata, rresp, rvalid;
    endclocking : dcb

    // Monitor clocking block (PASSIVE 模式)
    clocking mcb @(posedge clk);
        default input #1step;
        input awaddr, awvalid, awready, wdata, wstrb, wvalid, wready,
              bresp, bvalid, bready, araddr, arvalid, arready,
              rdata, rresp, rvalid, rready;
    endclocking : mcb

    modport drv_mp (clocking dcb, input clk, input rstn);
    modport mon_mp (clocking mcb, input clk, input rstn);

endinterface : axi4lite_vif

`endif
