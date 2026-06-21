`ifndef _CANPHY_TRANS_SV_
`define _CANPHY_TRANS_SV_

//=========================================================================
// canphy_trans: CAN FD 帧级 transaction
//   对应 PG223 CAN FD 控制器的完整 CAN/CAN FD 帧抽象
//=========================================================================

// 帧类型枚举
typedef enum {
    CAN_STD_DATA    = 0,  // CAN 2.0 标准数据帧 (11-bit ID, 0-8B)
    CAN_EXT_DATA    = 1,  // CAN 2.0 扩展数据帧 (29-bit ID, 0-8B)
    CAN_STD_REMOTE  = 2,  // CAN 2.0 标准远程帧 (11-bit ID)
    CAN_EXT_REMOTE  = 3,  // CAN 2.0 扩展远程帧 (29-bit ID)
    CANFD_STD       = 4,  // CAN FD 标准帧 (11-bit ID, 0-64B)
    CANFD_EXT       = 5,  // CAN FD 扩展帧 (29-bit ID, 0-64B)
    ERROR_FRAME     = 6,  // 错误帧
    OVERLOAD_FRAME  = 7   // 过载帧
} can_frame_type_e;

// 错误类型枚举 (用于错误注入)
typedef enum {
    ERR_NONE        = 0,  // 无错误
    ERR_BIT         = 1,  // 位错误
    ERR_STUFF       = 2,  // 填充错误
    ERR_CRC         = 3,  // CRC 错误
    ERR_FORM        = 4,  // 格式错误
    ERR_ACK         = 5   // ACK 错误
} can_error_type_e;

// 帧方向枚举
typedef enum {
    CAN_DIR_TX      = 0,  // DUT TX: can_phy_tx 驱动的帧
    CAN_DIR_RX      = 1,  // DUT RX: can_phy_rx 注入的帧
    CAN_DIR_UNKNOWN = 2   // 未确定 (旧 monitor 的足迹)
} can_direction_e;

class canphy_trans extends uvm_sequence_item;

    // ===== 帧基本属性 =====
    rand can_frame_type_e  frame_type;     // 帧类型
    rand logic [28:0]      can_id;         // CAN ID (11-bit 或 29-bit)
    rand logic [3:0]       dlc;            // 数据长度码 (0-15)

    // ===== 数据字段 =====
    rand logic [7:0]       data[];         // 数据字节 (动态数组)

    // ===== CAN FD 特有字段 =====
    rand bit               brs;            // 位速率切换
    rand bit               esi;            // 错误状态指示

    // ===== 方向 =====
    rand can_direction_e    direction;      // 帧方向 (TX=来自DUT, RX=来自外部)

    // ===== 控制字段 =====
    rand bit               ide;            // ID 扩展标志 (0=标准, 1=扩展)
    rand bit               rtr;            // 远程传输请求
    rand bit               fdf;            // FD 格式标志 (0=CAN2.0, 1=CANFD)

    // ===== 错误注入 =====
    rand can_error_type_e  err_inject;     // 错误注入类型
    rand int               err_bit_pos;    // 错误注入位位置

    // ===== Monitor 填充字段 =====
    logic [15:0]           crc_calc;       // 实际计算的 CRC
    bit                    ack_received;   // 是否收到 ACK
    int                    bit_count;      // 帧总位数

    // ===== 约束 =====
    // 根据帧类型约束 IDE/RTR/FDF
    constraint c_frame_consistency {
        solve frame_type before ide, rtr, fdf, brs;
        // CAN 2.0 标准帧
        if (frame_type == CAN_STD_DATA) {
            ide == 1'b0; rtr == 1'b0; fdf == 1'b0; brs == 1'b0;
            can_id < 11'h800;  // 11-bit ID 范围
        }
        // CAN 2.0 扩展帧
        if (frame_type == CAN_EXT_DATA) {
            ide == 1'b1; rtr == 1'b0; fdf == 1'b0; brs == 1'b0;
        }
        // 远程帧
        if (frame_type == CAN_STD_REMOTE) {
            ide == 1'b0; rtr == 1'b1; fdf == 1'b0; brs == 1'b0;
            can_id < 11'h800;
            data.size() == 0;
        }
        if (frame_type == CAN_EXT_REMOTE) {
            ide == 1'b1; rtr == 1'b1; fdf == 1'b0; brs == 1'b0;
            data.size() == 0;
        }
        // CAN FD 帧
        if (frame_type == CANFD_STD) {
            ide == 1'b0; rtr == 1'b0; fdf == 1'b1;
            can_id < 11'h800;
        }
        if (frame_type == CANFD_EXT) {
            ide == 1'b1; rtr == 1'b0; fdf == 1'b1;
        }
        // 错误帧/过载帧: 无 ID/DATA
        if (frame_type == ERROR_FRAME || frame_type == OVERLOAD_FRAME) {
            data.size() == 0;
        }
    }

    // DLC 与数据长度约束
    constraint c_dlc_data_size {
        solve frame_type, dlc before data;
        if (frame_type == CAN_STD_DATA || frame_type == CAN_EXT_DATA) {
            // CAN 2.0: 0-8 字节
            dlc <= 8;
            data.size() == dlc;
        }
        if (frame_type == CANFD_STD || frame_type == CANFD_EXT) {
            // CAN FD: DLC 映射
            dlc == 0  -> data.size() == 0;
            dlc == 1  -> data.size() == 1;
            dlc == 2  -> data.size() == 2;
            dlc == 3  -> data.size() == 3;
            dlc == 4  -> data.size() == 4;
            dlc == 5  -> data.size() == 5;
            dlc == 6  -> data.size() == 6;
            dlc == 7  -> data.size() == 7;
            dlc == 8  -> data.size() == 8;
            dlc == 9  -> data.size() == 12;
            dlc == 10 -> data.size() == 16;
            dlc == 11 -> data.size() == 20;
            dlc == 12 -> data.size() == 24;
            dlc == 13 -> data.size() == 32;
            dlc == 14 -> data.size() == 48;
            dlc == 15 -> data.size() == 64;
        }
    }

    // 默认错误注入: 无
    constraint c_err_default {
        err_inject == ERR_NONE;
        err_bit_pos >= 0;
    }

    `uvm_object_utils_begin(canphy_trans)
        `uvm_field_enum(can_frame_type_e,  frame_type, UVM_ALL_ON)
        `uvm_field_int(can_id,             UVM_ALL_ON)
        `uvm_field_int(dlc,                UVM_ALL_ON)
        `uvm_field_array_int(data,         UVM_ALL_ON)
        `uvm_field_int(brs,                UVM_ALL_ON)
        `uvm_field_int(esi,                UVM_ALL_ON)
        `uvm_field_int(ide,                UVM_ALL_ON)
        `uvm_field_int(rtr,                UVM_ALL_ON)
        `uvm_field_int(fdf,                UVM_ALL_ON)
        `uvm_field_enum(can_direction_e,   direction, UVM_ALL_ON)
        `uvm_field_enum(can_error_type_e,  err_inject, UVM_ALL_ON)
        `uvm_field_int(err_bit_pos,        UVM_ALL_ON)
        `uvm_field_int(crc_calc,           UVM_ALL_ON)
        `uvm_field_int(ack_received,       UVM_ALL_ON)
        `uvm_field_int(bit_count,          UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name="canphy_trans");
        super.new(name);
    endfunction

    // DLC → 字节数 转换函数
    function int dlc_to_bytes(logic [3:0] d);
        case(d)
            0,1,2,3,4,5,6,7,8: return d;
            9:  return 12;
            10: return 16;
            11: return 20;
            12: return 24;
            13: return 32;
            14: return 48;
            15: return 64;
            default: return 0;
        endcase
    endfunction

    function string convert2string();
        string s;
        s = $sformatf("{%s id=0x%07h dlc=%0d brs=%b fdf=%b esi=%b data_sz=%0d}",
            frame_type.name(), can_id, dlc, brs, fdf, esi, data.size());
        return s;
    endfunction

endclass

`endif
