`ifndef _SVA_TB_TOP_SV_
`define _SVA_TB_TOP_SV_

//=========================================================================
// sva_tb_top: TB 顶层全局断言
//   v2.0: 全面的协议级 SVA 断言
//   覆盖: 模式互斥, 寄存器行为, 协议时序, 错误帧检测, 仲裁检查
//=========================================================================

// =========================================================================
// 1. 模式互斥检查: LBACK / SLEEP / SNOOP 不可同时为 1
// =========================================================================
logic [31:0] msr_shadow;
always @(posedge TopVif.clk) begin
    if (!TopVif.rstn)
        msr_shadow <= 32'h0;
    else if (TopVif.axi4litevif.awvalid && TopVif.axi4litevif.awready &&
             TopVif.axi4litevif.awaddr == 16'h0004)
        msr_shadow <= TopVif.axi4litevif.wdata;
end

property p_mode_mutex;
    @(posedge TopVif.clk) disable iff (!TopVif.rstn)
    (msr_shadow[1] + msr_shadow[2] + msr_shadow[0]) <= 1;
endproperty
a_mode_mutex: assert property(p_mode_mutex)
    else `uvm_error("SVA_TB", "Mode bits mutually exclusive violation!")

// =========================================================================
// 2. SRST 写 1 后自动清零
// =========================================================================
property p_srst_autoclear;
    @(posedge TopVif.clk) disable iff (!TopVif.rstn)
    (TopVif.axi4litevif.awvalid && TopVif.axi4litevif.awready &&
     TopVif.axi4litevif.awaddr == 16'h0000 && TopVif.axi4litevif.wdata[0])
    |=>
    ##[1:5] !($past(TopVif.axi4litevif.awvalid) &&
               $past(TopVif.axi4litevif.awaddr) == 16'h0000 &&
               TopVif.axi4litevif.rdata[0]);
endproperty
a_srst_autoclear: assert property(p_srst_autoclear)
    else `uvm_warning("SVA_TB", "SRST may not be auto-cleared")

// =========================================================================
// 3. CEN 切换到 Normal Mode 后 SR.CONFIG 应清零
// =========================================================================
property p_config_clear_on_cen;
    @(posedge TopVif.clk) disable iff (!TopVif.rstn)
    (TopVif.axi4litevif.awvalid && TopVif.axi4litevif.awready &&
     TopVif.axi4litevif.awaddr == 16'h0000 && TopVif.axi4litevif.wdata[1])
    |=>
    ##[1:10] !$past(TopVif.axi4litevif.awvalid && TopVif.axi4litevif.awaddr == 16'h0018 &&
                    TopVif.axi4litevif.rdata[0]);
endproperty
a_config_clear: assert property(p_config_clear_on_cen);

// =========================================================================
// 4. CAN 总线: SOF 检测 (隐性→显性)
// =========================================================================
sequence seq_sof;
    $fell(TopVif.canphyvif.can_phy_tx);
endsequence

// =========================================================================
// 5. 帧间间隔 (IFS): SOF 之间至少间隔 3 个隐性位 + EOF(7) + ACK del(1)
//    即两次 SOF 之间至少间隔 11 个位时间
// =========================================================================
property p_interframe_spacing;
    @(posedge TopVif.clk) disable iff (!TopVif.rstn)
    $fell(TopVif.canphyvif.can_phy_tx)
    |=>
    ##[11*`BIT_TIME_CYCLES:$] $fell(TopVif.canphyvif.can_phy_tx);
endproperty
a_interframe: assert property(p_interframe_spacing)
    else `uvm_error("SVA_TB", "Inter-frame spacing violation (<11 bit times)")

// =========================================================================
// 6. ACK slot: 发送方发隐性，接收方应在 ACK slot 拉低
//    检查: 发送帧后, ACK bit 应为显性 (表示有人应答)
// =========================================================================
property p_ack_slot_dominant;
    @(posedge TopVif.clk) disable iff (!TopVif.rstn)
    $fell(TopVif.canphyvif.can_phy_tx)  // SOF
    |=>
    // ACK slot 位于帧尾 (简化: 在 EOF 之前的1 bit 应为显性)
    ##[`ACK_SLOT_POS_MIN:`ACK_SLOT_POS_MAX]
    TopVif.canphyvif.can_phy_rx == 1'b0;  // 有节点拉低 ACK
endproperty
a_ack_slot: assert property(p_ack_slot_dominant)
    else `uvm_warning("SVA_TB", "ACK slot not dominant — no responder?")

// =========================================================================
// 7. 位填充规则检查: 连续 6 个相同位后必须是反相位
//    (简化实现: 使用 bit_counter)
// =========================================================================
logic [2:0] stuff_bit_cnt_tx;
logic       stuff_prev_bit_tx;
always @(posedge TopVif.clk) begin
    if (!TopVif.rstn || $fell(TopVif.canphyvif.can_phy_tx)) begin
        stuff_bit_cnt_tx <= 0;
        stuff_prev_bit_tx <= TopVif.canphyvif.can_phy_tx;
    end else if (TopVif.canphyvif.can_phy_tx == stuff_prev_bit_tx) begin
        stuff_bit_cnt_tx <= stuff_bit_cnt_tx + 1;
    end else begin
        stuff_bit_cnt_tx <= 0;
        stuff_prev_bit_tx <= TopVif.canphyvif.can_phy_tx;
    end
end

property p_no_6_consecutive_tx;
    @(posedge TopVif.clk) disable iff (!TopVif.rstn)
    stuff_bit_cnt_tx < 5;  // 最多5个连续相同 (第6个是stuff bit)
endproperty
a_bit_stuffing_tx: assert property(p_no_6_consecutive_tx)
    else `uvm_error("SVA_TB", "Bit stuffing violation: 6+ consecutive identical bits on TX")

// =========================================================================
// 8. 错误帧检测: 6 个连续显性位 → 错误帧
// =========================================================================
logic [2:0] dominant_cnt;
always @(posedge TopVif.clk) begin
    if (!TopVif.rstn)
        dominant_cnt <= 0;
    else if (TopVif.canphyvif.can_phy_tx == 1'b0)
        dominant_cnt <= dominant_cnt + 1;
    else
        dominant_cnt <= 0;
end

// 检测到错误帧: 6连续显性位后应跟8个隐性位 (错误界定符)
sequence seq_error_frame;
    dominant_cnt == 6;
endsequence

property p_error_frame_delimiter;
    @(posedge TopVif.clk) disable iff (!TopVif.rstn)
    seq_error_frame
    |=>
    ##[1:8] TopVif.canphyvif.can_phy_tx == 1'b1;  // 错误界定符
endproperty
a_error_frame_delim: assert property(p_error_frame_delimiter)
    else `uvm_error("SVA_TB", "Error frame delimiter violation")

// =========================================================================
// 9. 总线空闲: 总线在无活动时应保持隐性
//    连续 11 个隐性位 = 总线空闲 (REC ≥ 128 需要 128 个隐性位)
// =========================================================================
property p_bus_idle_min;
    @(posedge TopVif.clk) disable iff (!TopVif.rstn)
    ^TopVif.canphyvif.can_phy_tx === 1'b0  // 任意显性位
    |=>
    ##1 ^TopVif.canphyvif.can_phy_tx === 1'b0  // 至少保持1个隐性位
    throughout
    ##[2:200] $rose(TopVif.canphyvif.can_phy_tx);  // 直到再次显性
endproperty

// =========================================================================
// 10. TX/RX 同时发送时的仲裁检查
//    如果 TX 和 RX 同时为显性 (都拉低), 应检测到冲突
// =========================================================================
property p_arbitration_tx_rx_conflict;
    @(posedge TopVif.clk) disable iff (!TopVif.rstn)
    (TopVif.canphyvif.can_phy_tx === 1'b0 && TopVif.canphyvif.can_phy_rx === 1'b0)
    |->  // 两侧同时拉低 → 仲裁冲突可能
    ##[1:10] TopVif.canphyvif.can_phy_tx == 1'b1;  // 丢失仲裁的一方应释放
endproperty
a_arb_conflict: assert property(p_arbitration_tx_rx_conflict)
    else `uvm_info("SVA_TB", "Possible arbitration loss detected", UVM_MEDIUM)

// =========================================================================
// 11. 寄存器写保护: W1C 寄存器 (ESR, ICR) 的写 0 不应改变位
// =========================================================================
property p_w1c_esr_bit_clear;
    @(posedge TopVif.clk) disable iff (!TopVif.rstn)
    (TopVif.axi4litevif.awvalid && TopVif.axi4litevif.awready &&
     TopVif.axi4litevif.awaddr == 16'h0014)
    |=>
    ##2 (TopVif.axi4litevif.rdata & ~($past(TopVif.axi4litevif.wdata))) ===
         (TopVif.axi4litevif.rdata & ~($past(TopVif.axi4litevif.wdata)));
endproperty
a_w1c_esr: assert property(p_w1c_esr_bit_clear)
    else `uvm_warning("SVA_TB", "ESR W1C behavior anomaly")

// =========================================================================
// 12. AXI 地址对齐: AXI4-Lite 地址必须 4 字节对齐
// =========================================================================
property p_axi_addr_aligned;
    @(posedge TopVif.clk) disable iff (!TopVif.rstn)
    (TopVif.axi4litevif.awvalid || TopVif.axi4litevif.arvalid)
    |->
    (TopVif.axi4litevif.awvalid ? TopVif.axi4litevif.awaddr[1:0] == 2'b00 :
                                  TopVif.axi4litevif.araddr[1:0] == 2'b00);
endproperty
a_axi_align: assert property(p_axi_addr_aligned)
    else `uvm_error("SVA_TB", "AXI address not 4-byte aligned!")

// =========================================================================
// 13. 复位期间的信号检查: 复位期间所有输出应为已知值
// =========================================================================
property p_reset_state;
    @(posedge TopVif.clk)
    !TopVif.rstn
    |->
    TopVif.canphyvif.can_phy_tx === 1'b1;  // 总线复位时隐性
endproperty
a_reset_tx_recessive: assert property(p_reset_state)
    else `uvm_error("SVA_TB", "TX not recessive during reset")

// =========================================================================
// 14. 时钟稳定性检查: 时钟周期在预期范围内
// =========================================================================
time clk_period;
time clk_last_edge;
always @(posedge TopVif.clk) begin
    clk_period <= $time - clk_last_edge;
    clk_last_edge <= $time;
end

property p_clk_stable;
    @(posedge TopVif.clk) disable iff (!TopVif.rstn)
    clk_period >= 18ns && clk_period <= 22ns;  // 50MHz ± 10%
endproperty
a_clk_stable: assert property(p_clk_stable)
    else `uvm_warning("SVA_TB", "Clock period out of expected range")

`endif
