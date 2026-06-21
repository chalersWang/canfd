`ifndef _CANPHY_SEQUENCE_LIB_SV_
`define _CANPHY_SEQUENCE_LIB_SV_

//=========================================================================
// canphy_base_sequence: CAN PHY 基类 sequence
//=========================================================================
class canphy_base_sequence extends uvm_sequence #(canphy_trans);

    canphy_config  canphy_cfg;

    `uvm_object_utils(canphy_base_sequence)

    function new(string name="canphy_base_sequence");
        super.new(name);
    endfunction

    virtual task pre_body();
        if (starting_phase != null)
            starting_phase.raise_objection(this, get_type_name());
        if (!uvm_config_db#(canphy_config)::get(null, get_full_name(), "canphy_config", canphy_cfg))
            `uvm_fatal(get_type_name(), "cannot get canphy_config")
    endtask

    virtual task post_body();
        if (starting_phase != null)
            starting_phase.drop_objection(this, get_type_name());
    endtask
endclass

//=========================================================================
// canphy_tx_std_frame_seq: 发送 CAN 2.0 标准数据帧
//=========================================================================
class canphy_tx_std_frame_seq extends canphy_base_sequence;
    `uvm_object_utils(canphy_tx_std_frame_seq)

    logic [10:0]  can_id;
    logic [3:0]   dlc;
    logic [7:0]   data[];

    function new(string name="canphy_tx_std_frame_seq");
        super.new(name);
    endfunction

    virtual task body();
        `uvm_do_with(req, {
            req.frame_type == CAN_STD_DATA;
            req.can_id == can_id;
            req.dlc == dlc;
            req.data.size() == dlc;
        })
        foreach (data[i]) req.data[i] = data[i];
    endtask
endclass

//=========================================================================
// canphy_tx_ext_frame_seq: 发送 CAN 2.0 扩展数据帧
//=========================================================================
class canphy_tx_ext_frame_seq extends canphy_base_sequence;
    `uvm_object_utils(canphy_tx_ext_frame_seq)

    logic [28:0]  can_id;
    logic [3:0]   dlc;
    logic [7:0]   data[];

    function new(string name="canphy_tx_ext_frame_seq");
        super.new(name);
    endfunction

    virtual task body();
        `uvm_do_with(req, {
            req.frame_type == CAN_EXT_DATA;
            req.can_id == can_id;
            req.dlc == dlc;
            req.data.size() == dlc;
        })
        foreach (data[i]) req.data[i] = data[i];
    endtask
endclass

//=========================================================================
// canphy_tx_fd_frame_seq: 发送 CAN FD 帧
//=========================================================================
class canphy_tx_fd_frame_seq extends canphy_base_sequence;
    `uvm_object_utils(canphy_tx_fd_frame_seq)

    logic [28:0]  can_id;
    bit           is_ext;
    bit           brs;
    logic [3:0]   dlc;
    logic [7:0]   data[];

    function new(string name="canphy_tx_fd_frame_seq");
        super.new(name);
    endfunction

    virtual task body();
        if (is_ext)
            `uvm_do_with(req, {
                req.frame_type == CANFD_EXT;
                req.can_id == can_id;
                req.brs == brs;
                req.dlc == dlc;
                req.data.size() == dlc_to_bytes(dlc);
            })
        else
            `uvm_do_with(req, {
                req.frame_type == CANFD_STD;
                req.can_id == can_id;
                req.brs == brs;
                req.dlc == dlc;
                req.data.size() == dlc_to_bytes(dlc);
            })
        foreach (data[i]) req.data[i] = data[i];
    endtask

    function int dlc_to_bytes(logic [3:0] d);
        case(d)
            0,1,2,3,4,5,6,7,8: return d;
            9:  return 12; 10: return 16; 11: return 20;
            12: return 24; 13: return 32; 14: return 48; 15: return 64;
            default: return 0;
        endcase
    endfunction
endclass

//=========================================================================
// canphy_tx_error_frame_seq: 发送错误帧
//=========================================================================
class canphy_tx_error_frame_seq extends canphy_base_sequence;
    `uvm_object_utils(canphy_tx_error_frame_seq)
    function new(string name="canphy_tx_error_frame_seq");
        super.new(name);
    endfunction
    virtual task body();
        `uvm_do_with(req, { req.frame_type == ERROR_FRAME; })
    endtask
endclass

//=========================================================================
// canphy_tx_remote_frame_seq: 发送远程帧
//=========================================================================
class canphy_tx_remote_frame_seq extends canphy_base_sequence;
    `uvm_object_utils(canphy_tx_remote_frame_seq)
    logic [28:0]  can_id;
    bit           is_ext;
    function new(string name="canphy_tx_remote_frame_seq");
        super.new(name);
    endfunction
    virtual task body();
        if (is_ext)
            `uvm_do_with(req, { req.frame_type == CAN_EXT_REMOTE; req.can_id == can_id; })
        else
            `uvm_do_with(req, { req.frame_type == CAN_STD_REMOTE; req.can_id == can_id; })
    endtask
endclass

//=========================================================================
// canphy_inject_error_seq: 错误注入 sequence
//=========================================================================
class canphy_inject_error_seq extends canphy_base_sequence;
    `uvm_object_utils(canphy_inject_error_seq)
    can_error_type_e  err_type;
    int               bit_pos;
    logic [28:0]      can_id;

    function new(string name="canphy_inject_error_seq");
        super.new(name);
    endfunction

    virtual task body();
        `uvm_do_with(req, {
            req.frame_type == CAN_STD_DATA;
            req.can_id == can_id;
            req.err_inject == err_type;
            req.err_bit_pos == bit_pos;
        })
    endtask
endclass

`endif
