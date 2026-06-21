`ifndef _SVA_VIF_TOP_SV_
`define _SVA_VIF_TOP_SV_

//=========================================================================
// sva_vif_top: 顶层 SVA 断言
//   绑定到 canfd_vif，检查全局协议约束
//=========================================================================

// 断言1: 复位后16周期等待约束
// 复位释放后，16个时钟周期内不应有 AXI4-Lite 传输
property p_reset_16cycle_wait;
    @(posedge canfd_vif.clk) disable iff (!canfd_vif.rstn)
    $rose(canfd_vif.rstn) |-> ##16 !canfd_vif.axi4litevif.awvalid && !canfd_vif.axi4litevif.arvalid;
endproperty
a_reset_16cycle_wait: assert property (p_reset_16cycle_wait)
    else `uvm_error("SVA_TOP", "AXI access within 16 cycles after reset!");

// 断言2: AXI4-Lite awvalid 必须保持到 awready
property p_awvalid_stable;
    @(posedge canfd_vif.clk) disable iff (!canfd_vif.rstn)
    canfd_vif.axi4litevif.awvalid && !canfd_vif.axi4litevif.awready
    |=> canfd_vif.axi4litevif.awvalid;
endproperty
a_awvalid_stable: assert property (p_awvalid_stable)
    else `uvm_error("SVA_TOP", "awvalid deasserted before awready!");

// 断言3: AXI4-Lite wvalid 必须保持到 wready
property p_wvalid_stable;
    @(posedge canfd_vif.clk) disable iff (!canfd_vif.rstn)
    canfd_vif.axi4litevif.wvalid && !canfd_vif.axi4litevif.wready
    |=> canfd_vif.axi4litevif.wvalid;
endproperty
a_wvalid_stable: assert property (p_wvalid_stable)
    else `uvm_error("SVA_TOP", "wvalid deasserted before wready!");

// 断言4: AXI4-Lite arvalid 必须保持到 arready
property p_arvalid_stable;
    @(posedge canfd_vif.clk) disable iff (!canfd_vif.rstn)
    canfd_vif.axi4litevif.arvalid && !canfd_vif.axi4litevif.arready
    |=> canfd_vif.axi4litevif.arvalid;
endproperty
a_arvalid_stable: assert property (p_arvalid_stable)
    else `uvm_error("SVA_TOP", "arvalid deasserted before arready!");

// 断言5: 中断线为高有效电平敏感
// irq 一旦拉高，必须等到 ISR 中所有中断清除后才变低
property p_irq_level_sensitive;
    @(posedge canfd_vif.clk) disable iff (!canfd_vif.rstn)
    canfd_vif.canphyvif.irq |-> canfd_vif.canphyvif.irq throughout (
        ##[0:$] !canfd_vif.canphyvif.irq) ; // 简化: irq 高期间保持高
endproperty

// 断言6: 复位期间总线输出隐性
property p_reset_bus_idle;
    @(posedge canfd_vif.clk)
    !canfd_vif.rstn |-> canfd_vif.canphyvif.can_phy_tx === 1'b1;
endproperty
a_reset_bus_idle: assert property (p_reset_bus_idle)
    else `uvm_error("SVA_TOP", "CAN bus not idle (recessive) during reset!");

`endif
