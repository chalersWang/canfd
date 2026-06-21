`ifndef _CANFD_B_02_01_TX_STD_TEST_SV_
`define _CANFD_B_02_01_TX_STD_TEST_SV_

// CANFD Test: B-02-01 | Priority: P0
// 验证 CAN 2.0 标准格式帧 (11-bit ID, 0-8字节) 的正确发送

class canfd_B_02_01_tx_std_test_seq extends canfd_virtual_seq_lib;
    `uvm_object_utils(canfd_B_02_01_tx_std_test_seq)
    function new(string n="canfd_B_02_01_tx_std_test_seq"); super.new(n); endfunction

    virtual task body();
        int pass=0, fail=0;

        `uvm_info(get_type_name(), "===== B-02-01: CAN 2.0 Std Frame TX Test Start =====", UVM_LOW)

        // 初始化 CANFD
        canfd_init(.brp(4), .ts1(4), .ts2(3));

        // 测试多个标准帧: 遍历 ID 和 DLC
        begin
            logic [10:0] test_ids[] = '{11'h000, 11'h001, 11'h7FF, 11'h123, 11'h456};
            logic [3:0]  test_dlcs[] = '{0, 1, 4, 8};
            logic [7:0]  data_buf[];

            foreach (test_ids[i]) begin
                foreach (test_dlcs[j]) begin
                    data_buf = new[test_dlcs[j]];
                    foreach (data_buf[k]) data_buf[k] = $urandom;

                    // 发送标准帧
                    canfd_tx_std_frame(test_ids[i], test_dlcs[j], data_buf);

                    // 等待 TXOK
                    canfd_wait_txok(2000);

                    // 检查中断
                    canfd_clear_int(32'h04); // 清 TXOK
                    pass++;
                end
            end
        end

        `uvm_info(get_type_name(), $sformatf("===== B-02-01 Done: %0d frames sent =====", pass), UVM_LOW)
    endtask
endclass

class canfd_B_02_01_tx_std_test extends canfd_base_test;
    `uvm_component_utils(canfd_B_02_01_tx_std_test)
    function new(string n="canfd_B_02_01_tx_std_test", uvm_component p=null); super.new(n,p); endfunction
    virtual task run_phase(uvm_phase phase);
        canfd_B_02_01_tx_std_test_seq seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        seq = canfd_B_02_01_tx_std_test_seq::type_id::create("seq");
        seq.start(env.canfd_vseqr);
        phase.drop_objection(this);
    endtask
endclass

`endif
