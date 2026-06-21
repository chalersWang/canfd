`ifndef _R_03_CANFD_RANDOMIZED_TEST_SV_
`define _R_03_CANFD_RANDOMIZED_TEST_SV_

//=========================================================================
// R_03_canfd_randomized_test: 受约束随机 CAN FD 通信测试
//   随机生成 CAN 2.0 和 CAN FD 帧，涵盖各种参数组合
//   使用 UVM 受约束随机序列，每次回归用不同 seed 运行
//=========================================================================
class R_03_canfd_randomized_test extends canfd_base_test;

    `uvm_component_utils(R_03_canfd_randomized_test)

    function new(string name="R_03_canfd_randomized_test", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);

        // 初始化 CANFD
        canfd_vseqr.canfd_init();

        // 启动随机化序列
        phase.raise_objection(this, "Randomized test running");
        begin
            canfd_randomized_seq rand_seq;
            rand_seq = canfd_randomized_seq::type_id::create("rand_seq");
            rand_seq.num_frames = 50;  // 每次测试发 50 帧
            rand_seq.start(canfd_vseqr);
        end
        phase.drop_objection(this);
    endtask

endclass : R_03_canfd_randomized_test


//=========================================================================
// canfd_randomized_seq: 受约束随机 CAN 帧生成序列
//   随机选择: 帧类型、ID、DLC、FD特性、数据内容
//=========================================================================
class canfd_randomized_seq extends canfd_virtual_seq_lib;

    rand int num_frames;  // 要生成的帧数

    constraint c_num_frames {
        num_frames inside {[10:200]};
    }

    `uvm_object_utils(canfd_randomized_seq)

    function new(string name="canfd_randomized_seq");
        super.new(name);
        num_frames = 50;
    endfunction

    virtual task body();
        super.body();
        `uvm_info(get_full_name(), $sformatf("Randomized test: %0d frames", num_frames), UVM_LOW)

        for (int i = 0; i < num_frames; i++) begin
            rand_frame_t frame;
            // 随机化帧参数 (每次迭代独立随机)
            void'(std::randomize(frame) with {
                // 覆盖所有帧类型
                frame.frame_type dist {
                    CAN_STD_DATA    := 20,
                    CAN_EXT_DATA    := 15,
                    CANFD_STD       := 25,
                    CANFD_EXT       := 20,
                    CAN_STD_REMOTE  := 5,
                    CAN_EXT_REMOTE  := 5,
                    [ERROR_FRAME:OVERLOAD_FRAME] := 5
                };
                // ID 覆盖率边界
                if (frame.frame_type inside {CAN_STD_DATA, CAN_STD_REMOTE, CANFD_STD}) {
                    frame.can_id dist {
                        11'h000    := 1,
                        [1:11'h7FD] := 30,
                        11'h7FE    := 1,
                        11'h7FF    := 1
                    };
                } else {
                    frame.can_id dist {
                        29'h00000000 := 1,
                        [1:29'h1FFFFFFD] := 30,
                        29'h1FFFFFFE := 1,
                        29'h1FFFFFFF := 1
                    };
                }
                // DLC 覆盖所有有效值
                frame.dlc dist {
                    0  := 5,
                    1  := 5,
                    4  := 10,
                    8  := 20,
                    15 := 15,
                    [2:3] := 10,
                    [5:7] := 10,
                    [9:14] := 10
                };
                // FD 特性覆盖率
                if (frame.frame_type inside {CANFD_STD, CANFD_EXT}) {
                    frame.brs dist {0 := 30, 1 := 30};
                    frame.esi dist {0 := 50, 1 := 10};
                }
                // 错误注入概率 (5%)
                frame.err_inject dist {
                    ERR_NONE  := 95,
                    ERR_BIT   := 1,
                    ERR_STUFF := 1,
                    ERR_CRC   := 1,
                    ERR_FORM  := 1,
                    ERR_ACK   := 1
                };
            });

            // 发送帧
            canfd_tx_msg(
                i % 32,                    // 循环使用 32 个 TX 缓冲器
                frame.can_id,
                frame.ide,
                frame.fdf,
                frame.brs,
                frame.dlc,
                frame.data
            );

            // 等待 TXOK 或超时
            canfd_wait_txok(2000);

            // 每隔 10 帧检查状态
            if (i % 10 == 0) begin
                bit esr_pass, ecr_pass;
                canfd_check_esr(32'h0, esr_pass);  // 期望无错误
                canfd_check_ecr(8'h0, 8'h0, ecr_pass);
                `uvm_info(get_full_name(),
                    $sformatf("Frame %0d/%0d: ESR=%0b ECR=%0b",
                        i, num_frames, esr_pass, ecr_pass), UVM_MEDIUM)
            end
        end

        `uvm_info(get_full_name(), $sformatf("Randomized test done: %0d frames", num_frames), UVM_LOW)
    endtask

endclass : canfd_randomized_seq


//=========================================================================
// rand_frame_t: 随机 CAN 帧结构体 (用于 std::randomize)
//=========================================================================
typedef struct {
    rand can_frame_type_e  frame_type;
    rand logic [28:0]      can_id;
    rand logic [3:0]       dlc;
    rand logic [7:0]       data[];
    rand bit               brs;
    rand bit               esi;
    rand bit               ide;
    rand bit               rtr;
    rand bit               fdf;
    rand can_error_type_e  err_inject;
    rand int               err_bit_pos;
} rand_frame_t;

`endif
