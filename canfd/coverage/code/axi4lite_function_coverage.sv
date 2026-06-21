`ifndef _AXI4LITE_FUNCTION_COVERAGE_SV_
`define _AXI4LITE_FUNCTION_COVERAGE_SV_

covergroup FeatureListNum_AXI4LITE with function sample(axi4lite_trans tr);
    // 访问方向覆盖
    AXI4LITE_DIR: coverpoint tr.dir {
        bins read  = {AXI4LITE_READ};
        bins write = {AXI4LITE_WRITE};
    }
    // 地址空间覆盖
    AXI4LITE_ADDR_REGION: coverpoint tr.addr {
        bins core_reg    = {[16'h0000:16'h00FF]};  // 核心寄存器
        bins tx_space    = {[16'h0100:16'h1FFF]};  // TX 消息空间
        bins rx_space    = {[16'h2000:16'h7FFF]};  // RX 消息空间
        bins out_of_range = {[16'h8000:32'hFFFFFFFF]}; // 非法地址
    }
    // 响应码覆盖
    AXI4LITE_RESP: coverpoint tr.resp {
        bins okay   = {AXI_RESP_OKAY};
        bins slverr = {AXI_RESP_SLVERR};
        bins decerr = {AXI_RESP_DECERR};
    }
    // 交叉覆盖: 方向 × 地址区域
    DIR_X_ADDR: cross AXI4LITE_DIR, AXI4LITE_ADDR_REGION;
    // 交叉覆盖: 地址区域 × 响应码
    ADDR_X_RESP: cross AXI4LITE_ADDR_REGION, AXI4LITE_RESP;
endgroup

`endif
