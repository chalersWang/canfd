`ifndef _CANFD_B_03_02_FD_BRS_TEST_SV_
`define _CANFD_B_03_02_FD_BRS_TEST_SV_

// CANFD Test: B-03-02 | Priority: P0
// 验证 CAN FD 帧位速率切换 (BRS=1)

class canfd_B_03_02_fd_brs_test_seq extends canfd_virtual_seq_lib;
    `uvm_object_utils(canfd_B_03_02_fd_brs_test_seq)
    function new(string n="canfd_B_03_02_fd_brs_test_seq"); super.new(n); endfunction

    virtual task body();
        int pass=0;
        logic [7:0] data_buf[];

        `uvm_info(get_type_name(), "===== B-03-02: CAN FD BRS Test Start =====", UVM_LOW)

        // 初始化: 标称 1Mb/s, 数据 8Mb/s
        canfd_init(.brp(0), .ts1(6), .ts2(1), .dp_brp(0), .dp_ts1(1), .dp_ts2(0));

        // 测试 BRS=1 的 FD 帧, 各种数据长度
        begin
            logic [3:0] test_dlcs[] = '{0, 1, 8, 9, 12, 15};
            foreach (test_dlcs[i]) begin
                int n_bytes;
                case (test_dlcs[i])
                    0,1,2,3,4,5,6,7,8: n_bytes = test_dlcs[i];
                    9: n_bytes = 12; 10: n_bytes = 16; 11: n_bytes = 20;
                    12: n_bytes = 24; 13: n_bytes = 32; 14: n_bytes = 48; 15: n_bytes = 64;
                endcase
                data_buf = new[n_bytes];
                foreach (data_buf[j]) data_buf[j] = $urandom;

                canfd_tx_fd_frame(11'h100 + i, 1'b0, 1'b1, test_dlcs[i], data_buf);
                canfd_wait_txok(5000);
                canfd_clear_int(32'h04);
                pass++;
            end
        end

        // 测试 BRS=0 的 FD 帧 (标称速率)
        data_buf = new[8];
        foreach (data_buf[i]) data_buf[i] = 8'hAA;
        canfd_tx_fd_frame(11'h200, 1'b0, 1'b0, 4'h8, data_buf);
        canfd_wait_txok(5000);
        canfd_clear_int(32'h04);
        pass++;

        `uvm_info(get_type_name(), $sformatf("===== B-03-02 Done: %0d frames tested =====", pass), UVM_LOW)
    endtask
endclass

class canfd_B_03_02_fd_brs_test extends canfd_base_test;
    `uvm_component_utils(canfd_B_03_02_fd_brs_test)
    function new(string n="canfd_B_03_02_fd_brs_test", uvm_component p=null); super.new(n,p); endfunction
    virtual task run_phase(uvm_phase phase);
        canfd_B_03_02_fd_brs_test_seq seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        seq = canfd_B_03_02_fd_brs_test_seq::type_id::create("seq");
        seq.start(env.canfd_vseqr);
        phase.drop_objection(this);
    endtask
endclass

`endif
