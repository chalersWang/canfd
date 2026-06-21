// Renamed from sva_vif_ucspi.sv to sva_vif_axi4lite.sv
// 保留原文件名以兼容 filelist
`ifndef _SVA_VIF_AXI4LITE_SV_
`define _SVA_VIF_AXI4LITE_SV_

//=========================================================================
// sva_vif_axi4lite: AXI4-Lite 接口断言
//=========================================================================

// 断言: 写地址必须32位对齐 (PG223: 不支持非对齐)
property p_write_addr_align;
    @(posedge axi4lite_vif.clk) disable iff (!axi4lite_vif.rstn)
    axi4lite_vif.awvalid |-> axi4lite_vif.awaddr[1:0] == 2'b00;
endproperty
a_write_addr_align: assert property (p_write_addr_align)
    else `uvm_error("SVA_AXI", "Unaligned write address!");

// 断言: 读地址必须32位对齐
property p_read_addr_align;
    @(posedge axi4lite_vif.clk) disable iff (!axi4lite_vif.rstn)
    axi4lite_vif.arvalid |-> axi4lite_vif.araddr[1:0] == 2'b00;
endproperty
a_read_addr_align: assert property (p_read_addr_align)
    else `uvm_error("SVA_AXI", "Unaligned read address!");

// 断言: 地址空间检查 (32KB = 0x8000)
property p_addr_in_range;
    @(posedge axi4lite_vif.clk) disable iff (!axi4lite_vif.rstn)
    (axi4lite_vif.awvalid || axi4lite_vif.arvalid) |-> 
    (axi4lite_vif.awaddr < 32'h8000 || axi4lite_vif.araddr < 32'h8000) 
    || (axi4lite_vif.bresp == AXI_RESP_DECERR || axi4lite_vif.rresp == AXI_RESP_DECERR);
endproperty

// 断言: bvalid 必须在写事务完成后产生
property p_bvalid_after_write;
    @(posedge axi4lite_vif.clk) disable iff (!axi4lite_vif.rstn)
    (axi4lite_vif.awvalid && axi4lite_vif.awready &&
     axi4lite_vif.wvalid && axi4lite_vif.wready)
    |-> ##[1:16] axi4lite_vif.bvalid;
endproperty
a_bvalid_after_write: assert property (p_bvalid_after_write)
    else `uvm_error("SVA_AXI", "bvalid not received after write!");

// 断言: rvalid 必须在读事务完成后产生
property p_rvalid_after_read;
    @(posedge axi4lite_vif.clk) disable iff (!axi4lite_vif.rstn)
    (axi4lite_vif.arvalid && axi4lite_vif.arready)
    |-> ##[1:16] axi4lite_vif.rvalid;
endproperty
a_rvalid_after_read: assert property (p_rvalid_after_read)
    else `uvm_error("SVA_AXI", "rvalid not received after read!");

// 覆盖属性: AXI 响应码覆盖
covergroup cg_axi_resp @(posedge axi4lite_vif.clk);
    cp_bresp: coverpoint axi4lite_vif.bresp {
        bins okay = {2'b00};
        bins slverr = {2'b10};
        bins decerr = {2'b11};
    }
    cp_rresp: coverpoint axi4lite_vif.rresp {
        bins okay = {2'b00};
        bins slverr = {2'b10};
        bins decerr = {2'b11};
    }
endgroup

cg_axi_resp  axi_resp_cg;

initial axi_resp_cg = new();

`endif
