
//=========================================================================
// canfd_common_task_function: CANFD 验证公共任务库
//   提供 testcase 可复用的高层操作封装
//=========================================================================

//-------------------------------------------------------------------------
// 寄存器操作任务
//-------------------------------------------------------------------------

// 写寄存器 (通过 AXI4-Lite)
task reg_write(input logic [31:0] addr, input logic [31:0] data);
    axi4lite_reg_write_seq wr_seq;
    wr_seq = axi4lite_reg_write_seq::type_id::create("wr_seq");
    wr_seq.addr = addr;
    wr_seq.data = data;
    wr_seq.start(p_sequencer.axi4lite_seqr);
endtask

// 读寄存器 (通过 AXI4-Lite)
task reg_read(input logic [31:0] addr, output logic [31:0] data);
    axi4lite_reg_read_seq rd_seq;
    rd_seq = axi4lite_reg_read_seq::type_id::create("rd_seq");
    rd_seq.addr = addr;
    rd_seq.start(p_sequencer.axi4lite_seqr);
    data = rd_seq.data;
endtask

// 读寄存器并检查
task reg_read_check(input logic [31:0] addr, input logic [31:0] exp,
                    output bit pass);
    logic [31:0] act;
    reg_read(addr, act);
    pass = (act === exp);
    if (!pass)
        `uvm_error("REG_CHECK", $sformatf(
            "Addr=0x%04h exp=0x%08h got=0x%08h", addr, exp, act))
endtask

//-------------------------------------------------------------------------
// CANFD 初始化任务
//-------------------------------------------------------------------------

// CANFD 基本初始化: 配置模式 → 设时序 → 进入工作模式
task canfd_init(input int brp=4, input int ts1=4, input int ts2=3,
                input int dp_brp=1, input int dp_ts1=2, input int dp_ts2=1);
    reg_write(16'h0000, 32'h0000);  // CEN=0, 配置模式
    reg_write(16'h0008, brp);       // BRPR
    reg_write(16'h000C, (ts1)|(ts2<<8)|(1<<16)); // BTR (SJW=1)
    reg_write(16'h0088, dp_brp);    // DP_BRPR
    reg_write(16'h008C, (dp_ts1)|(dp_ts2<<8)|(1<<16)); // DP_BTR
    reg_write(16'h0004, 32'h0000);  // MSR: Normal mode
    reg_write(16'h0000, 32'h0002);  // CEN=1, 进入工作模式
    `uvm_info("CANFD_INIT", "CANFD initialized and enabled", UVM_MEDIUM)
endtask

// 进入 Loopback 模式
task canfd_enter_loopback();
    reg_write(16'h0000, 32'h0000);  // CEN=0
    reg_write(16'h0004, 32'h0002);  // LBACK=1
    reg_write(16'h0000, 32'h0002);  // CEN=1
    `uvm_info("CANFD_INIT", "Entered Loopback mode", UVM_MEDIUM)
endtask

// 进入 Snoop 模式
task canfd_enter_snoop();
    reg_write(16'h0000, 32'h0000);  // CEN=0
    reg_write(16'h0004, 32'h0004);  // SNOOP=1
    reg_write(16'h0000, 32'h0002);  // CEN=1
    `uvm_info("CANFD_INIT", "Entered Snoop mode", UVM_MEDIUM)
endtask

// 进入 Sleep 模式
task canfd_enter_sleep();
    reg_write(16'h0000, 32'h0000);  // CEN=0
    reg_write(16'h0004, 32'h0001);  // SLEEP=1
    reg_write(16'h0000, 32'h0002);  // CEN=1
    `uvm_info("CANFD_INIT", "Entered Sleep mode", UVM_MEDIUM)
endtask

// 设置 DAR 模式
task canfd_set_dar(input bit enable);
    logic [31:0] msr_val;
    reg_read(16'h0004, msr_val);
    if (enable) msr_val |= 32'h10;  // DAR=1
    else        msr_val &= ~32'h10;
    reg_write(16'h0000, 32'h0000);  // CEN=0
    reg_write(16'h0004, msr_val);
    reg_write(16'h0000, 32'h0002);  // CEN=1
endtask

//-------------------------------------------------------------------------
// TX 发送任务
//-------------------------------------------------------------------------

// 填充 TX 缓冲器并请求发送
task canfd_tx_msg(input int buf_idx, input logic [28:0] id,
                  input bit ide, input bit fdf, input bit brs,
                  input logic [3:0] dlc, input logic [7:0] data[]);
    logic [31:0] base_addr;
    logic [31:0] wdata;
    base_addr = 16'h0100 + buf_idx * 16;

    // Word 0: ID + 控制位
    wdata = {ide, ~fdf, fdf, id[28:0]};  // 简化
    reg_write(base_addr, wdata);
    // Word 1: DLC + BRS + ESI
    wdata = {28'h0, brs, 3'h0, dlc};
    reg_write(base_addr + 4, wdata);
    // Word 2+: 数据
    for (int i=0; i<data.size(); i+=4) begin
        wdata = 0;
        for (int j=0; j<4 && i+j<data.size(); j++)
            wdata[j*8 +: 8] = data[i+j];
        reg_write(base_addr + 8 + i, wdata);
    end

    // 设置 TRR 对应位请求发送
    reg_write(16'h0090, (1 << buf_idx));
    `uvm_info("CANFD_TX", $sformatf("TX buf[%0d] id=0x%07h dlc=%0d fdf=%b brs=%b",
        buf_idx, id, dlc, fdf, brs), UVM_MEDIUM)
endtask

// 发送 CAN 2.0 标准帧
task canfd_tx_std_frame(input logic [10:0] id, input logic [3:0] dlc,
                         input logic [7:0] data[]);
    canfd_tx_msg(0, id, 1'b0, 1'b0, 1'b0, dlc, data);
endtask

// 发送 CAN FD 帧
task canfd_tx_fd_frame(input logic [28:0] id, input bit is_ext,
                        input bit brs, input logic [3:0] dlc,
                        input logic [7:0] data[]);
    canfd_tx_msg(0, id, is_ext, 1'b1, brs, dlc, data);
endtask

//-------------------------------------------------------------------------
// RX 接收检查任务
//-------------------------------------------------------------------------

// 读取 RX FIFO 并检查
task canfd_check_rx(input logic [28:0] exp_id, input logic [3:0] exp_dlc,
                    input logic [7:0] exp_data[], output bit pass);
    logic [31:0] rx_data;
    logic [28:0] got_id;
    logic [3:0]  got_dlc;

    // 读取 RX FIFO 消息空间 (0x2000+)
    reg_read(16'h2000, rx_data);
    got_id = rx_data[28:0];
    got_dlc = rx_data[3:0];  // 简化

    pass = (got_id == exp_id);
    if (pass && exp_data.size() > 0) begin
        for (int i=0; i<exp_data.size(); i++) begin
            reg_read(16'h2008 + i*4, rx_data);
            if (rx_data[7:0] != exp_data[i]) begin
                pass = 0;
                break;
            end
        end
    end

    if (!pass)
        `uvm_error("RX_CHECK", $sformatf(
            "RX mismatch: exp_id=0x%07h got_id=0x%07h", exp_id, got_id))
endtask

// 检查中断状态
task canfd_check_int(input int bit_pos, input bit expect_set,
                     output bit pass);
    logic [31:0] isr_val;
    reg_read(16'h001C, isr_val);
    pass = (isr_val[bit_pos] == expect_set);
    if (!pass)
        `uvm_error("INT_CHECK", $sformatf(
            "ISR[%0d]: exp=%b got=%b", bit_pos, expect_set, isr_val[bit_pos]))
endtask

// 清除中断
task canfd_clear_int(input logic [31:0] mask);
    reg_write(16'h0024, mask);
endtask

//-------------------------------------------------------------------------
// 错误注入任务
//-------------------------------------------------------------------------

// 通过 CAN PHY 注入错误帧
task canfd_inject_error(input can_error_type_e err_type, input int bit_pos);
    canphy_inject_error_seq err_seq;
    err_seq = canphy_inject_error_seq::type_id::create("err_seq");
    err_seq.err_type = err_type;
    err_seq.bit_pos  = bit_pos;
    err_seq.can_id   = 29'h100;
    err_seq.start(p_sequencer.canphy_seqr);
    `uvm_info("ERR_INJECT", $sformatf("Injected %s at bit %0d", err_type.name(), bit_pos), UVM_MEDIUM)
endtask

// 检查 ESR 错误标志
task canfd_check_esr(input logic [31:0] exp_mask, output bit pass);
    logic [31:0] esr_val;
    reg_read(16'h0014, esr_val);
    pass = ((esr_val & exp_mask) == exp_mask);
    if (!pass)
        `uvm_error("ESR_CHECK", $sformatf(
            "ESR: exp_mask=0x%08h got=0x%08h", exp_mask, esr_val))
endtask

// 检查错误计数器
task canfd_check_ecr(input bit [7:0] exp_tec, input bit [7:0] exp_rec,
                     output bit pass);
    logic [31:0] ecr_val;
    reg_read(16'h0010, ecr_val);
    pass = (ecr_val[7:0] == exp_tec && ecr_val[15:8] == exp_rec);
    if (!pass)
        `uvm_error("ECR_CHECK", $sformatf(
            "ECR: exp TEC=%0d REC=%0d got TEC=%0d REC=%0d",
            exp_tec, exp_rec, ecr_val[7:0], ecr_val[15:8]))
endtask

//-------------------------------------------------------------------------
// 过滤器配置任务
//-------------------------------------------------------------------------

// 配置 ID 过滤器 (FIFO模式)
task canfd_config_filter(input int fifo_id, input int filter_idx,
                         input logic [28:0] id, input logic [28:0] mask,
                         input bit ide);
    logic [31:0] afr_val;
    logic [31:0] filter_addr;

    // 过滤器存储在 TX Block RAM 的特定区域
    filter_addr = 16'h1F00 + fifo_id * 16'h80 + filter_idx * 8;
    reg_write(filter_addr, {ide, 3'h0, id});
    reg_write(filter_addr + 4, mask);

    // 使能过滤器
    reg_read(16'h00E0, afr_val);
    afr_val |= (1 << (fifo_id * 16 + filter_idx));
    reg_write(16'h00E0, afr_val);
endtask

//-------------------------------------------------------------------------
// 等待任务
//-------------------------------------------------------------------------

// 等待中断
task canfd_wait_int(input int timeout_cycles = 10000);
    logic [31:0] isr_val;
    int i;
    for (i=0; i<timeout_cycles; i++) begin
        reg_read(16'h001C, isr_val);
        if (isr_val != 0) return;
        repeat(10) @(posedge p_sequencer.clk);
    end
    `uvm_warning("WAIT_INT", $sformatf("No interrupt after %0d cycles", timeout_cycles))
endtask

// 等待 TXOK 中断
task canfd_wait_txok(input int timeout_cycles = 5000);
    logic [31:0] isr_val;
    int i;
    for (i=0; i<timeout_cycles; i++) begin
        reg_read(16'h001C, isr_val);
        if (isr_val[2]) return;  // TXOK
        repeat(10) @(posedge p_sequencer.clk);
    end
    `uvm_error("WAIT_TXOK", $sformatf("No TXOK after %0d cycles", timeout_cycles))
endtask

// 等待 RXOK 中断
task canfd_wait_rxok(input int timeout_cycles = 5000);
    logic [31:0] isr_val;
    int i;
    for (i=0; i<timeout_cycles; i++) begin
        reg_read(16'h001C, isr_val);
        if (isr_val[3]) return;  // RXOK
        repeat(10) @(posedge p_sequencer.clk);
    end
    `uvm_error("WAIT_RXOK", $sformatf("No RXOK after %0d cycles", timeout_cycles))
endtask
