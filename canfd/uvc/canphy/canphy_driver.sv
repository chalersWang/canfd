`ifndef _CANPHY_DRIVER_SV_
`define _CANPHY_DRIVER_SV_

//=========================================================================
// canphy_driver: CAN PHY 帧级驱动器
//   职责: 将 canphy_trans (帧级) 序列化为 bit-level 信号驱动到 rx
//   支持: CAN 2.0/CAN FD 帧发送、错误注入、位时序控制
//=========================================================================
class canphy_driver extends uvm_driver #(canphy_trans);

    virtual canphy_vif    vif;
    canphy_config         cfg;

    `uvm_component_utils(canphy_driver)

    function new(string name="canphy_driver", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual canphy_vif)::get(this, "", "canphy_vif", vif))
            `uvm_fatal("NOVIF", "canphy_vif not set for driver")
    endfunction

    virtual task reset_phase(uvm_phase phase);
        super.reset_phase(phase);
        vif.can_phy_rx <= 1'b1;  // 隐性 (idle)
    endtask

    virtual task main_phase(uvm_phase phase);
        super.main_phase(phase);
        fork
            forever begin
                seq_item_port.try_next_item(req);
                if (req == null) begin
                    @(posedge vif.clk);
                    continue;
                end
                drive_frame(req);
                seq_item_port.item_done();
            end
        join
    endtask

    //---------------------------------------------------------------------
    // drive_frame: 根据帧类型驱动
    //---------------------------------------------------------------------
    virtual task drive_frame(canphy_trans tr);
        `uvm_info(get_type_name(), $sformatf("Driving frame: %s", tr.convert2string()), UVM_HIGH)

        case (tr.frame_type)
            ERROR_FRAME:    drive_error_frame();
            OVERLOAD_FRAME: drive_overload_frame();
            default:        drive_can_frame(tr);
        endcase

        // 帧间间隔 (IMF: 3 个隐性位)
        repeat(3) drive_bit(1'b1, cfg.bit_time_ns);
    endtask

    //---------------------------------------------------------------------
    // drive_can_frame: CAN/CAN FD 数据帧序列化
    //---------------------------------------------------------------------
    virtual task drive_can_frame(canphy_trans tr);
        bit    bit_stream[];
        int    idx = 0;

        // 1. 构建原始位流 (不含填充)
        // SOF
        bit    stuffed[];
        int    stuff_idx = 0;
        int    same_count = 1;
        bit    last_bit;
        logic [16:0] crc;
        int crc_width = tr.fdf ? 17 : 15;
        int bit_time;
        bit_stream = new[bit_stream.size()+1]; bit_stream[idx++] = 1'b0;

        // 仲裁段: ID + RTR/IDE/FDF
        if (!tr.ide) begin
            // 11-bit ID
            for (int i=10; i>=0; i--) begin
                bit_stream = new[bit_stream.size()+1]; bit_stream[idx++] = tr.can_id[i];
            end
            // RTR
            bit_stream = new[bit_stream.size()+1]; bit_stream[idx++] = tr.rtr;
            // IDE=0
            bit_stream = new[bit_stream.size()+1]; bit_stream[idx++] = 1'b0;
            // r0
            bit_stream = new[bit_stream.size()+1]; bit_stream[idx++] = 1'b0;
        end else begin
            // 11-bit ID (high)
            for (int i=10; i>=0; i--) begin
                bit_stream = new[bit_stream.size()+1]; bit_stream[idx++] = tr.can_id[i+18];
            end
            // SRR=1
            bit_stream = new[bit_stream.size()+1]; bit_stream[idx++] = 1'b1;
            // IDE=1
            bit_stream = new[bit_stream.size()+1]; bit_stream[idx++] = 1'b1;
            // 18-bit ID (low)
            for (int i=17; i>=0; i--) begin
                bit_stream = new[bit_stream.size()+1]; bit_stream[idx++] = tr.can_id[i];
            end
            // RTR
            bit_stream = new[bit_stream.size()+1]; bit_stream[idx++] = tr.rtr;
            // r1, r0
            bit_stream = new[bit_stream.size()+1]; bit_stream[idx++] = 1'b0;
            bit_stream = new[bit_stream.size()+1]; bit_stream[idx++] = 1'b0;
        end

        // CAN FD 特有: FDF + BRS + ESI
        if (tr.fdf) begin
            bit_stream = new[bit_stream.size()+1]; bit_stream[idx++] = 1'b1;  // FDF
            bit_stream = new[bit_stream.size()+1]; bit_stream[idx++] = tr.brs; // BRS
            bit_stream = new[bit_stream.size()+1]; bit_stream[idx++] = tr.esi; // ESI
        end

        // DLC (4 bits)
        for (int i=3; i>=0; i--) begin
            bit_stream = new[bit_stream.size()+1]; bit_stream[idx++] = tr.dlc[i];
        end

        // 数据段 (如果不是远程帧)
        if (!tr.rtr) begin
            foreach (tr.data[i]) begin
                for (int j=7; j>=0; j--) begin
                    bit_stream = new[bit_stream.size()+1]; bit_stream[idx++] = tr.data[i][j];
                end
            end
        end

        // 2. 应用位填充 (每5个相同位后插入一个反相位)

        if (bit_stream.size() > 0) begin
            stuffed = new[1]; stuffed[0] = bit_stream[0]; stuff_idx = 1;
            last_bit = bit_stream[0];

            for (int i=1; i<bit_stream.size(); i++) begin
                stuffed = new[stuffed.size()+1]; stuffed[stuff_idx++] = bit_stream[i];
                if (bit_stream[i] == last_bit) begin
                    same_count++;
                    if (same_count == 5) begin
                        // 插入反相位
                        stuffed = new[stuffed.size()+1]; stuffed[stuff_idx++] = ~bit_stream[i];
                        same_count = 1;
                        last_bit = ~bit_stream[i];
                    end
                end else begin
                    same_count = 1;
                    last_bit = bit_stream[i];
                end
            end
        end

        // 3. 计算 CRC (17-bit for CAN FD, 15-bit for CAN 2.0)
        // 这里简化: 使用 15-bit CRC for CAN 2.0, 17-bit for CAN FD
        crc = calc_crc(bit_stream, tr.fdf);

        // 4. 追加 CRC (不含填充的 CRC 计算结果，但传输时需填充)
        // CRC 序列不进行位填充
        for (int i=crc_width-1; i>=0; i--) begin
            stuffed = new[stuffed.size()+1]; stuffed[stuff_idx++] = crc[i];
        end

        // CRC 分隔符 (1 recessive)
        stuffed = new[stuffed.size()+1]; stuffed[stuff_idx++] = 1'b1;

        // ACK 槽 (1 bit, 发送方发隐性，等待接收方拉低)
        stuffed = new[stuffed.size()+1]; stuffed[stuff_idx++] = 1'b1;

        // ACK 分隔符 (1 recessive)
        stuffed = new[stuffed.size()+1]; stuffed[stuff_idx++] = 1'b1;

        // EOF (7 recessive)
        repeat(7) begin
            stuffed = new[stuffed.size()+1]; stuffed[stuff_idx++] = 1'b1;
        end

        // 5. 驱动位流到 bus
        bit_time = cfg.bit_time_ns;  // 标称位时间
        for (int i=0; i<stuffed.size(); i++) begin
            // BRS=1 时，数据段使用快速速率
            if (tr.fdf && tr.brs && i >= get_brs_pos(tr)) begin
                bit_time = cfg.dp_bit_time_ns;
            end

            // 错误注入
            if (tr.err_inject != ERR_NONE && i == tr.err_bit_pos) begin
                drive_bit(~stuffed[i], bit_time);  // 驱动反相位
            end else begin
                drive_bit(stuffed[i], bit_time);
            end
        end

        tr.bit_count = stuffed.size();
    endtask

    //---------------------------------------------------------------------
    // drive_bit: 按位时序驱动一个 bit
    //---------------------------------------------------------------------
    virtual task drive_bit(bit val, int bit_time_ns);
        int cycles_per_bit;
        cycles_per_bit = bit_time_ns / 20;  // 20ns per clk cycle (50MHz)
        if (cycles_per_bit < 1) cycles_per_bit = 1;
        vif.can_phy_rx <= val;
        repeat(cycles_per_bit) @(posedge vif.clk);
    endtask

    //---------------------------------------------------------------------
    // drive_error_frame: 驱动错误帧 (6 个连续显性位)
    //---------------------------------------------------------------------
    virtual task drive_error_frame();
        repeat(6) drive_bit(1'b0, cfg.bit_time_ns);
        repeat(8) drive_bit(1'b1, cfg.bit_time_ns);  // 错误界定符
    endtask

    //---------------------------------------------------------------------
    // drive_overload_frame: 驱动过载帧
    //---------------------------------------------------------------------
    virtual task drive_overload_frame();
        repeat(6) drive_bit(1'b0, cfg.bit_time_ns);
        repeat(8) drive_bit(1'b1, cfg.bit_time_ns);
    endtask

    //---------------------------------------------------------------------
    // calc_crc: CRC 计算 (简化版)
    //   CAN 2.0: 15-bit CRC, poly=0x4599
    //   CAN FD:  17-bit CRC, poly=0x1685B
    //---------------------------------------------------------------------
    function logic [16:0] calc_crc(bit bit_stream[], bit is_fd);
        logic [16:0] crc;
        logic [16:0] poly;
        int    width;

        if (is_fd) begin
            crc = 17'h0;
            poly = 17'h1685B;
            width = 17;
        end else begin
            crc = 15'h0;
            poly = 15'h4599;
            width = 15;
        end

        foreach (bit_stream[i]) begin
            if (bit_stream[i] ^ crc[width-1])
                crc = ((crc << 1) ^ poly) & ((1<<width)-1);
            else
                crc = (crc << 1) & ((1<<width)-1);
        end
        return crc;
    endfunction

    //---------------------------------------------------------------------
    // get_brs_pos: 获取 BRS 位在 stuffed stream 中的位置 (简化)
    //---------------------------------------------------------------------
    function int get_brs_pos(canphy_trans tr);
        // 简化: 返回一个估计值 (SOF + ID + RTR/IDE + FDF + BRS)
        if (!tr.ide) return 1 + 11 + 1 + 1 + 1 + 1;  // SOF+ID11+RTR+IDE0+r0+FDF
        else return 1 + 11 + 1 + 1 + 18 + 1 + 2 + 1; // SOF+ID11+SRR+IDE1+ID18+RTR+r1r0+FDF
    endfunction

endclass

`endif
