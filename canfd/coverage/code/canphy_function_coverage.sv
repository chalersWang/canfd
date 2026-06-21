`ifndef _CANPHY_FUNCTION_COVERAGE_SV_
`define _CANPHY_FUNCTION_COVERAGE_SV_

covergroup FeatureListNum_CANPHY with function sample(canphy_trans tr);
    // 帧类型覆盖
    CAN_FRAME_TYPE: coverpoint tr.frame_type {
        bins can_std_data   = {CAN_STD_DATA};
        bins can_ext_data   = {CAN_EXT_DATA};
        bins can_std_remote = {CAN_STD_REMOTE};
        bins can_ext_remote = {CAN_EXT_REMOTE};
        bins canfd_std      = {CANFD_STD};
        bins canfd_ext      = {CANFD_EXT};
        bins error_frame    = {ERROR_FRAME};
        bins overload_frame = {OVERLOAD_FRAME};
    }
    // DLC 覆盖
    CAN_DLC: coverpoint tr.dlc {
        bins dlc_0  = {0};
        bins dlc_1  = {1};
        bins dlc_8  = {8};
        bins dlc_9  = {9};   // 12 bytes
        bins dlc_10 = {10};  // 16 bytes
        bins dlc_12 = {12};  // 24 bytes
        bins dlc_15 = {15};  // 64 bytes
    }
    // CAN FD 特有字段
    CAN_BRS: coverpoint tr.brs {
        bins no_switch = {1'b0};
        bins switch    = {1'b1};
    }
    CAN_ESI: coverpoint tr.esi {
        bins active  = {1'b0};
        bins passive = {1'b1};
    }
    // ID 范围覆盖
    CAN_ID_RANGE: coverpoint tr.can_id {
        bins id_min    = {0};
        bins id_mid    = {[11'h100:11'h3FF]};
        bins id_max_11 = {11'h7FF};
        bins id_max_29 = {29'h1FFFFFFF};
    }
    // 错误注入覆盖
    CAN_ERR_INJECT: coverpoint tr.err_inject {
        bins no_err   = {ERR_NONE};
        bins bit_err  = {ERR_BIT};
        bins stuff_err = {ERR_STUFF};
        bins crc_err  = {ERR_CRC};
        bins form_err = {ERR_FORM};
        bins ack_err  = {ERR_ACK};
    }
    // 交叉覆盖: 帧类型 × BRS
    FRAME_X_BRS: cross CAN_FRAME_TYPE, CAN_BRS iff (tr.fdf);
    // 交叉覆盖: 帧类型 × DLC
    FRAME_X_DLC: cross CAN_FRAME_TYPE, CAN_DLC;
endgroup

`endif
