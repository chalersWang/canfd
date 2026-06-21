`ifndef _AXI4LITE_DRIVER_SV_
`define _AXI4LITE_DRIVER_SV_

//=========================================================================
// axi4lite_driver: AXI4-Lite Master Driver
//   实现 AW/W/B 和 AR/R 五个通道的标准握手时序
//=========================================================================
class axi4lite_driver extends uvm_driver #(axi4lite_trans);

    virtual axi4lite_vif  vif;
    axi4lite_config       cfg;

    `uvm_component_utils(axi4lite_driver)

    function new(string name="axi4lite_driver", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual axi4lite_vif)::get(this, "", "axi4lite_vif", vif))
            `uvm_fatal("NOVIF", "axi4lite_vif not set for driver")
    endfunction

    virtual task reset_phase(uvm_phase phase);
        super.reset_phase(phase);
        vif.awvalid <= 1'b0;
        vif.wvalid  <= 1'b0;
        vif.arvalid <= 1'b0;
        vif.bready  <= 1'b0;
        vif.rready  <= 1'b0;
    endtask

    virtual task main_phase(uvm_phase phase);
        super.main_phase(phase);
        fork
            forever begin
                seq_item_port.try_next_item(req);
                if (req == null) begin
                    @(posedge vif.clk);
                    continue;
                end
                if (req.dir == AXI4LITE_WRITE)
                    do_write(req);
                else
                    do_read(req);
                seq_item_port.item_done();
            end
        join
    endtask

    //---------------------------------------------------------------------
    // do_write: AXI4-Lite 写操作
    //   AW 通道: 发送地址 → W 通道: 发送数据 → B 通道: 接收响应
    //---------------------------------------------------------------------
    virtual task do_write(axi4lite_trans tr);
        // 驱动 AW 通道
        vif.awaddr  <= tr.addr;
        vif.awvalid <= 1'b1;
        while (!vif.awready) @(posedge vif.clk);
        vif.awvalid <= 1'b0;

        // 驱动 W 通道 (可与 AW 同时)
        vif.wdata  <= tr.data;
        vif.wstrb  <= tr.wstrb;
        vif.wvalid <= 1'b1;
        while (!vif.wready) @(posedge vif.clk);
        vif.wvalid <= 1'b0;

        // 接收 B 通道响应
        vif.bready <= 1'b1;
        while (!vif.bvalid) @(posedge vif.clk);
        tr.resp = vif.bresp;
        @(posedge vif.clk);
        vif.bready <= 1'b0;
    endtask

    //---------------------------------------------------------------------
    // do_read: AXI4-Lite 读操作
    //   AR 通道: 发送地址 → R 通道: 接收数据+响应
    //---------------------------------------------------------------------
    virtual task do_read(axi4lite_trans tr);
        // 驱动 AR 通道
        vif.araddr  <= tr.addr;
        vif.arvalid <= 1'b1;
        while (!vif.arready) @(posedge vif.clk);
        vif.arvalid <= 1'b0;

        // 接收 R 通道
        vif.rready <= 1'b1;
        while (!vif.rvalid) @(posedge vif.clk);
        tr.data = vif.rdata;
        tr.resp = vif.rresp;
        @(posedge vif.clk);
        vif.rready <= 1'b0;
    endtask

endclass

`endif
