`ifndef _SVA_VIF_CANPHY_SV_
`define _SVA_VIF_CANPHY_SV_

//=========================================================================
// sva_vif_canphy: CAN PHY 接口断言
//=========================================================================

// 断言: SOF 必须是显性位 (0)
property p_sof_dominant;
    @(posedge canphy_vif.clk) disable iff (!canphy_vif.rstn)
    $fell(canphy_vif.can_phy_tx) |-> canphy_vif.can_phy_tx === 1'b0;
endproperty
a_sof_dominant: assert property (p_sof_dominant)
    else `uvm_error("SVA_CANPHY", "SOF not dominant!");

// 断言: 总线空闲时为隐性 (1)
// 简化: 长时间无下降沿时 tx 应为 1
property p_idle_recessive;
    @(posedge canphy_vif.clk) disable iff (!canphy_vif.rstn)
    ##100 canphy_vif.can_phy_tx throughout (1'b1) |-> canphy_vif.can_phy_tx === 1'b1;
endproperty

// 断言: 错误帧后总线必须回到隐性
property p_error_recovery;
    @(posedge canphy_vif.clk) disable iff (!canphy_vif.rstn)
    // 检测6个连续显性位 (错误帧标志)
    (canphy_vif.can_phy_tx === 1'b0 [*6]) |=> ##[1:20] canphy_vif.can_phy_tx === 1'b1;
endproperty
a_error_recovery: assert property (p_error_recovery)
    else `uvm_error("SVA_CANPHY", "Bus not recessive after error frame!");

// 覆盖属性: 总线有活动 (TX 翻转)
covergroup cg_canphy_activity @(posedge canphy_vif.clk);
    cp_tx: coverpoint canphy_vif.can_phy_tx {
        bins dominant = {1'b0};
        bins recessive = {1'b1};
    }
    cp_irq: coverpoint canphy_vif.irq {
        bins low = {1'b0};
        bins high = {1'b1};
    }
endgroup

cg_canphy_activity  canphy_act_cg;

initial canphy_act_cg = new();

`endif
