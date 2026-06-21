`ifndef _CANFD_FUNCTION_COVERAGE_SV_
`define _CANFD_FUNCTION_COVERAGE_SV_

//=========================================================================
// canfd_function_coverage: CANFD 功能覆盖率模型
//   对齐 81 个 VFP 验证功能点，覆盖 6 大分类
//=========================================================================

//=========================================================================
// 1. 寄存器访问覆盖率 (T: T-01 ~ T-02)
//=========================================================================
covergroup cg_reg_access;
    // 核心寄存器地址覆盖
    cp_reg_addr: coverpoint reg_addr {
        bins SRR     = {16'h0000};
        bins MSR     = {16'h0004};
        bins BRPR    = {16'h0008};
        bins BTR     = {16'h000C};
        bins ECR     = {16'h0010};
        bins ESR     = {16'h0014};
        bins SR      = {16'h0018};
        bins ISR     = {16'h001C};
        bins IER     = {16'h0020};
        bins ICR     = {16'h0024};
        bins TSR     = {16'h0028};
        bins DP_BRPR = {16'h0088};
        bins DP_BTR  = {16'h008C};
        bins TRR     = {16'h0090};
        bins TCR     = {16'h0098};
        bins AFR     = {16'h00E0};
        bins FSR     = {16'h00E8};
        bins WMR     = {16'h00EC};
    }
    // 访问方向
    cp_dir: coverpoint reg_dir {
        bins read  = {0};
        bins write = {1};
    }
    // 地址空间分区
    cp_region: coverpoint reg_addr {
        bins core_reg   = {[16'h0000:16'h00FF]};
        bins tx_space   = {[16'h0100:16'h1FFF]};
        bins rx_space   = {[16'h2000:16'h7FFF]};
        bins illegal    = {[16'h8000:32'hFFFFFFFF]};
    }
    DIR_X_ADDR: cross cp_dir, cp_reg_addr;
    DIR_X_REGION: cross cp_dir, cp_region;
endgroup

//=========================================================================
// 2. CAN 通信帧覆盖率 (B: B-01 ~ B-04)
//=========================================================================
covergroup cg_can_frame with function sample(canphy_trans tr);
    // 帧类型 (8种)
    cp_frame_type: coverpoint tr.frame_type {
        bins can_std_data   = {CAN_STD_DATA};
        bins can_ext_data   = {CAN_EXT_DATA};
        bins can_std_remote = {CAN_STD_REMOTE};
        bins can_ext_remote = {CAN_EXT_REMOTE};
        bins canfd_std      = {CANFD_STD};
        bins canfd_ext      = {CANFD_EXT};
        bins error_frame    = {ERROR_FRAME};
        bins overload_frame = {OVERLOAD_FRAME};
    }
    // DLC 分布 (CAN 2.0: 0-8, CAN FD: 0-15)
    cp_dlc: coverpoint tr.dlc {
        bins dlc_0  = {0};
        bins dlc_1  = {1};
        bins dlc_4  = {4};
        bins dlc_8  = {8};
        bins dlc_9  = {9};
        bins dlc_10 = {10};
        bins dlc_12 = {12};
        bins dlc_14 = {14};
        bins dlc_15 = {15};
    }
    // ID 范围
    cp_id_range: coverpoint tr.can_id {
        bins id_0      = {0};
        bins id_low    = {[1:11'h0FF]};
        bins id_mid    = {[11'h100:11'h3FF]};
        bins id_high   = {[11'h400:11'h7FE]};
        bins id_max11  = {11'h7FF};
        bins id_max29  = {29'h1FFFFFFF};
    }
    // CAN FD 特有字段
    cp_brs: coverpoint tr.brs;
    cp_esi: coverpoint tr.esi;
    // 交叉覆盖
    FRAME_X_DLC: cross cp_frame_type, cp_dlc;
    FRAME_X_BRS: cross cp_frame_type, cp_brs iff (tr.fdf);
    FRAME_X_ESI: cross cp_frame_type, cp_esi iff (tr.fdf);
    FRAME_X_ID:  cross cp_frame_type, cp_id_range;
endgroup

//=========================================================================
// 3. 工作模式覆盖率 (M: M-01 ~ M-02)
//=========================================================================
covergroup cg_work_mode;
    // CEN 状态
    cp_cen: coverpoint cen_state {
        bins config = {0};  // CEN=0 配置模式
        bins active = {1};  // CEN=1 工作模式
    }
    // 模式位组合
    cp_mode_bits: coverpoint mode_bits {
        bins normal       = 3'b000;  // LBACK=0,SLEEP=0,SNOOP=0
        bins loopback     = 3'b100;  // LBACK=1
        bins sleep        = 3'b010;  // SLEEP=1
        bins snoop        = 3'b001;  // SNOOP=1
        // 互斥组合 (不应出现)
        illegal bins illegal_2bits = {3'b110, 3'b101, 3'b011};
        illegal bins illegal_3bits = {3'b111};
    }
    // DAR 模式
    cp_dar: coverpoint dar_state {
        bins auto_retransmit = {0};
        bins single_shot     = {1};
    }
    // BRSD
    cp_brsd: coverpoint brsd_state {
        bins brs_enabled  = {0};
        bins brs_disabled = {1};
    }
    // 总线关闭恢复
    cp_bus_recovery: coverpoint recovery_mode {
        bins auto   = {0};  // ABR=1
        bins manual = {1};  // SBR=1
        bins none   = {2};  // 未触发
    }
    CEN_X_MODE: cross cp_cen, cp_mode_bits;
endgroup

//=========================================================================
// 4. 错误处理覆盖率 (E: E-01 ~ E-02)
//=========================================================================
covergroup cg_error_handling with function sample(canphy_trans tr);
    // 错误注入类型
    cp_err_type: coverpoint tr.err_inject {
        bins no_err    = {ERR_NONE};
        bins bit_err   = {ERR_BIT};
        bins stuff_err = {ERR_STUFF};
        bins crc_err   = {ERR_CRC};
        bins form_err  = {ERR_FORM};
        bins ack_err   = {ERR_ACK};
    }
    // 错误相位 (标称 vs 快速数据)
    cp_err_phase: coverpoint tr.fdf {
        bins nominal = {1'b0};  // CAN 2.0 (标称相位)
        bins fast    = {1'b1};  // CAN FD (可能含快速相位)
    }
    // 错误位置
    cp_err_pos: coverpoint tr.err_bit_pos {
        bins early    = {[0:20]};
        bins middle   = {[21:80]};
        bins late     = {[81:200]};
    }
    ERR_X_PHASE: cross cp_err_type, cp_err_phase;
    ERR_X_POS:   cross cp_err_type, cp_err_pos;
endgroup

//=========================================================================
// 5. 接口时序覆盖率 (I: I-01 ~ I-02)
//=========================================================================
covergroup cg_interface_timing;
    // AXI 握手延迟
    cp_aw_latency: coverpoint aw_latency {
        bins zero_delay = {0};
        bins short      = {[1:4]};
        bins medium     = {[5:15]};
        bins long       = {[16:31]};
    }
    cp_ar_latency: coverpoint ar_latency {
        bins zero_delay = {0};
        bins short      = {[1:4]};
        bins medium     = {[5:15]};
        bins long       = {[16:31]};
    }
    // 地址对齐
    cp_addr_align: coverpoint addr_align {
        bins aligned     = {1};
        bins unaligned   = {0};
    }
endgroup

//=========================================================================
// 6. FIFO/缓冲器边界覆盖率 (R + C: 边界)
//=========================================================================
covergroup cg_fifo_boundary;
    // RX FIFO 深度覆盖
    cp_rx_fifo_depth: coverpoint rx_fifo_depth {
        bins empty      = {0};
        bins near_empty = {[1:4]};
        bins mid        = {[5:30]};
        bins near_full  = {[31:63]};
        bins full       = {64};
        bins overflow   = {65};
    }
    // TX 缓冲器占用
    cp_tx_buf_used: coverpoint tx_buf_used {
        bins none   = {0};
        bins partial= {[1:15]};
        bins most   = {[16:31]};
        bins full   = {32};
    }
    // 水印触发
    cp_watermark: coverpoint watermark_hit {
        bins no_hit  = {0};
        bins hit     = {1};
    }
endgroup

//=========================================================================
// 7. 特殊功能覆盖率 (S: S-01 ~ S-03)
//=========================================================================
covergroup cg_special_features;
    // TSR 时间戳
    cp_tsr_value: coverpoint tsr_value {
        bins zero     = {0};
        bins mid      = {[1:16'hFFFE]};
        bins overflow = {16'hFFFF};
    }
    // TDC 补偿值
    cp_tdc_off: coverpoint tdc_off {
        bins off_0 = {0};
        bins off_1 = {1};
        bins off_2 = {2};
        bins off_3 = {3};
    }
    // 波特率组合
    cp_bitrate: coverpoint bitrate_setting {
        bins nominal_1M   = {0};  // 1 Mb/s 标称
        bins data_8M      = {1};  // 8 Mb/s 数据
        bins mixed        = {2};  // 混合 (BRS)
    }
endgroup

`endif
