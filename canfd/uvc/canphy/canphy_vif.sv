`ifndef _CANPHY_VIF_SV_
`define _CANPHY_VIF_SV_

//=========================================================================
// canphy_vif: CAN PHY 接口
//   PG223 CANFD IP 的 CAN 总线侧接口
//   tx → CAN 收发器, rx ← CAN 收发器, irq → 中断
//=========================================================================
interface canphy_vif(input logic clk, input logic rstn);

    // CAN 总线信号
    logic        can_phy_tx;      // CAN TX 输出 (DUT → PHY → Bus)
    logic        can_phy_rx;      // CAN RX 输入 (Bus → PHY → DUT)
    logic        irq;             // 中断输出

    // 位时钟 (用于 bit-level 驱动/采样)
    // 实际位时序由 DUT 配置决定，这里提供一个参考时钟
    // bit_clk 由 driver/monitor 根据 BRP/BTR 参数动态生成

    // Driver clocking block
    clocking dcb @(posedge clk);
        default input #1step output #0;
        output can_phy_rx;       // driver 驱动 rx 模拟总线数据
        input  can_phy_tx;       // driver 可观察 tx
        input  irq;
    endclocking : dcb

    // Monitor clocking block
    clocking mcb @(posedge clk);
        default input #1step;
        input can_phy_tx, can_phy_rx, irq;
    endclocking : mcb

    modport drv_mp (clocking dcb, input clk, input rstn);
    modport mon_mp (clocking mcb, input clk, input rstn);

    // CAN 总线值 (线与逻辑: 0=显性, 1=隐性)
    // 当 tx=0 时总线为显性; tx=1 且 rx=1 时总线为隐性
    function logic bus_value();
        return can_phy_tx & can_phy_rx;  // 线与
    endfunction

endinterface : canphy_vif

`endif
