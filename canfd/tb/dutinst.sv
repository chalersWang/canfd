//=========================================================================
// dutinst.sv: CANFD DUT 实例化
//   接口: AXI4-Lite (主机接口) + CAN PHY (总线接口) + Interrupt
//=========================================================================

// CAN PHY signals
wire        can_phy_rx;   // CAN bus RX (from external PHY)
wire        can_phy_tx;   // CAN bus TX (to external PHY)
wire        irq;          // Interrupt output

// AXI4-Lite signals
wire [31:0] awaddr;
wire        awvalid;
wire        awready;
wire [31:0] wdata;
wire [3:0]  wstrb;
wire        wvalid;
wire        wready;
wire [1:0]  bresp;
wire        bvalid;
wire        bready;
wire [31:0] araddr;
wire        arvalid;
wire        arready;
wire [31:0] rdata;
wire [1:0]  rresp;
wire        rvalid;
wire        rready;

// DUT 实例化 (端口名参考 PG223 CANFD IP)
canfd DUT (
    // Clock & Reset
    .clk              (TopVif.clk),
    .rstn             (TopVif.rstn),
    // AXI4-Lite 接口
    .s_axi_awaddr     (TopVif.axi4litevif.awaddr),
    .s_axi_awvalid    (TopVif.axi4litevif.awvalid),
    .s_axi_awready    (TopVif.axi4litevif.awready),
    .s_axi_wdata      (TopVif.axi4litevif.wdata),
    .s_axi_wstrb      (TopVif.axi4litevif.wstrb),
    .s_axi_wvalid     (TopVif.axi4litevif.wvalid),
    .s_axi_wready     (TopVif.axi4litevif.wready),
    .s_axi_bresp      (TopVif.axi4litevif.bresp),
    .s_axi_bvalid     (TopVif.axi4litevif.bvalid),
    .s_axi_bready     (TopVif.axi4litevif.bready),
    .s_axi_araddr     (TopVif.axi4litevif.araddr),
    .s_axi_arvalid    (TopVif.axi4litevif.arvalid),
    .s_axi_arready    (TopVif.axi4litevif.arready),
    .s_axi_rdata      (TopVif.axi4litevif.rdata),
    .s_axi_rresp      (TopVif.axi4litevif.rresp),
    .s_axi_rvalid     (TopVif.axi4litevif.rvalid),
    .s_axi_rready     (TopVif.axi4litevif.rready),
    // CAN PHY 接口
    .can_phy_tx       (TopVif.canphyvif.can_phy_tx),
    .can_phy_rx       (TopVif.canphyvif.can_phy_rx),
    // 中断
    .ip2bus_intrevent (TopVif.canphyvif.irq)
);
