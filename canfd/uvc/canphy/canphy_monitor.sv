`ifndef _CANPHY_MONITOR_SV_
`define _CANPHY_MONITOR_SV_

//=========================================================================
// canphy_monitor: CAN PHY 帧级监控器
//   职责: 同时监控 can_phy_tx (DUT 发送) 和 can_phy_rx (外部注入),
//         解析出完整的 CAN/CAN FD 帧，标记方向后发送给 scoreboard
//=========================================================================
class canphy_monitor extends uvm_monitor;

    virtual canphy_vif       vif;
    canphy_config            cfg;

    // 多 analysis_port: 向后兼容 + TX/RX 分别
    uvm_analysis_port #(canphy_trans)  mon_analysis_port;
    uvm_analysis_port #(canphy_trans)  mon_tx_analysis_port;
    uvm_analysis_port #(canphy_trans)  mon_rx_analysis_port;

    `uvm_register_cb(canphy_monitor, canphy_monitor_callback)

    `uvm_component_utils(canphy_monitor)

    function new(string name="canphy_monitor", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon_analysis_port    = new("mon_analysis_port", this);
        mon_tx_analysis_port = new("mon_tx_analysis_port", this);
        mon_rx_analysis_port = new("mon_rx_analysis_port", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if (!uvm_config_db#(virtual canphy_vif)::get(this, "", "canphy_vif", vif))
            `uvm_fatal("NOVIF", "canphy_vif not set for monitor")
    endfunction

    //---------------------------------------------------------------------
    // run_phase: 并行监控 TX 和 RX 总线
    //   TX 线程: 监控 can_phy_tx (DUT 发出的帧)
    //   RX 线程: 监控 can_phy_rx (外部注入到 DUT 的帧)
    //---------------------------------------------------------------------
    virtual task run_phase(uvm_phase phase);
        fork
            monitor_tx_bus();
            monitor_rx_bus();
        join
    endtask

    //---------------------------------------------------------------------
    // monitor_tx_bus: 监控 DUT TX 方向 (can_phy_tx 信号)
    //---------------------------------------------------------------------
    virtual task monitor_tx_bus();
        bit prev_tx = 1'b1;

        forever begin
            @(posedge vif.clk);

            // 检测 SOF: can_phy_tx 从隐性→显性
            if (prev_tx === 1'b1 && vif.can_phy_tx === 1'b0) begin
                capture_frame(CAN_DIR_TX);
            end
            prev_tx = vif.can_phy_tx;
        end
    endtask

    //---------------------------------------------------------------------
    // monitor_rx_bus: 监控外部 RX 方向 (can_phy_rx 信号)
    //---------------------------------------------------------------------
    virtual task monitor_rx_bus();
        bit prev_rx = 1'b1;

        forever begin
            @(posedge vif.clk);

            // 检测 SOF: can_phy_rx 从隐性→显性 (外部注入帧)
            if (prev_rx === 1'b1 && vif.can_phy_rx === 1'b0) begin
                capture_frame(CAN_DIR_RX);
            end
            prev_rx = vif.can_phy_rx;
        end
    endtask

    //---------------------------------------------------------------------
    // capture_frame: 捕获并解析一个完整 CAN 帧
    //   dir: 帧方向 (CAN_DIR_TX 或 CAN_DIR_RX)
    //   根据方向选择监控的物理信号
    //---------------------------------------------------------------------
    virtual task capture_frame(input can_direction_e dir);
        bit bit_queue[$];
        bit sampled_bit;
        bit signal_val;
        int bit_time = cfg.bit_time_ns;
        int cycles_per_bit = bit_time / 20;

        // 采样 SOF (已检测到)
        bit_queue.push_back(1'b0);

        // 持续采样直到检测到 EOF (7 个连续隐性位)
        int consecutive_recessive = 0;
        int max_bits = 200; // 安全上限

        for (int i=0; i<max_bits; i++) begin
            // 在采样点采样 (TS1 结束处)
            repeat(cycles_per_bit) @(posedge vif.clk);

            // 根据方向选择对应的物理信号
            signal_val = (dir == CAN_DIR_TX) ? vif.can_phy_tx : vif.can_phy_rx;
            sampled_bit = signal_val;
            bit_queue.push_back(sampled_bit);

            if (sampled_bit == 1'b1) begin
                consecutive_recessive++;
                if (consecutive_recessive >= 7) break; // 检测到 EOF
            end else begin
                consecutive_recessive = 0;
            end
        end

        // 解析位流为帧事务 (传入方向)
        parse_frame(bit_queue, dir);
    endtask : capture_frame

    //---------------------------------------------------------------------
    // parse_frame: 将位队列解析为 canphy_trans
    //   设置方向标志，写入对应的 analysis_port
    //---------------------------------------------------------------------
    virtual function void parse_frame(ref bit bit_queue[$], input can_direction_e dir);
        canphy_trans frame;
        bit destuffed[];

        // 1. 位去填充
        int same_count = 1;
        bit last_bit;

        if (bit_queue.size() > 0) begin
            destuffed = new[1]; destuffed[0] = bit_queue[0]; int idx = 1;
            last_bit = bit_queue[0];

            for (int i=1; i<bit_queue.size() && i<150; i++) begin
                if (bit_queue[i] == last_bit) begin
                    same_count++;
                    if (same_count == 5) begin
                        // 跳过下一个填充位 (如果存在)
                        if (i+1 < bit_queue.size()) i++;
                        same_count = 1;
                        if (i+1 < bit_queue.size()) begin
                            last_bit = bit_queue[i+1];
                            destuffed = new[destuffed.size()+1];
                            destuffed[destuffed.size()-1] = bit_queue[i+1];
                        end
                        continue;
                    end
                end else begin
                    same_count = 1;
                    last_bit = bit_queue[i];
                end
                destuffed = new[destuffed.size()+1];
                destuffed[destuffed.size()-1] = bit_queue[i];
            end
        end

        if (destuffed.size() < 20) return; // 太短，忽略

        frame = canphy_trans::type_id::create("frame");

        // 2. 解析帧字段 (从 destuffed 数组)
        int pos = 0;

        // SOF (1 bit)
        pos = 1;

        // ID (11 bits)
        frame.can_id = 0;
        for (int i=0; i<11 && pos<destuffed.size(); i++)
            frame.can_id[10-i] = destuffed[pos++];

        // RTR (1 bit)
        if (pos < destuffed.size()) frame.rtr = destuffed[pos++];

        // IDE (1 bit)
        if (pos < destuffed.size()) frame.ide = destuffed[pos++];

        if (frame.ide) begin
            // 扩展帧: 18-bit ID + RTR + r1 + r0
            for (int i=0; i<18 && pos<destuffed.size(); i++)
                frame.can_id[17-i] = destuffed[pos++];
            if (pos < destuffed.size()) frame.rtr = destuffed[pos++];
            pos += 2; // r1, r0
        end

        // FDF (1 bit)
        if (pos < destuffed.size()) frame.fdf = destuffed[pos++];

        if (frame.fdf) begin
            // CAN FD: BRS + ESI + DLC(4)
            if (pos < destuffed.size()) frame.brs = destuffed[pos++];
            if (pos < destuffed.size()) frame.esi = destuffed[pos++];
        end else begin
            pos++; // r0
        end

        // DLC (4 bits)
        frame.dlc = 0;
        for (int i=0; i<4 && pos<destuffed.size(); i++)
            frame.dlc[3-i] = destuffed[pos++];

        // 数据段
        int data_bytes = frame.dlc_to_bytes(frame.dlc);
        if (!frame.rtr && data_bytes > 0) begin
            frame.data = new[data_bytes];
            for (int i=0; i<data_bytes && pos+7<destuffed.size(); i++) begin
                for (int j=7; j>=0; j--)
                    frame.data[i][j] = destuffed[pos++];
            end
        end

        // 设置帧类型
        if (frame.fdf)
            frame.frame_type = frame.ide ? CANFD_EXT : CANFD_STD;
        else if (frame.rtr)
            frame.frame_type = frame.ide ? CAN_EXT_REMOTE : CAN_STD_REMOTE;
        else
            frame.frame_type = frame.ide ? CAN_EXT_DATA : CAN_STD_DATA;

        // 设置方向
        frame.direction = dir;
        frame.bit_count = destuffed.size();

        `uvm_info(get_type_name(), $sformatf("Captured [%s]: %s",
            dir.name(), frame.convert2string()), UVM_HIGH)

        // 写入 analysis_port (向后兼容 + 带方向)
        mon_analysis_port.write(frame);
        case (dir)
            CAN_DIR_TX: mon_tx_analysis_port.write(frame);
            CAN_DIR_RX: mon_rx_analysis_port.write(frame);
        endcase
    endfunction

endclass

`endif
