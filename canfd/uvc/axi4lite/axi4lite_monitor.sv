`ifndef _AXI4LITE_MONITOR_SV_
`define _AXI4LITE_MONITOR_SV_

//=========================================================================
// axi4lite_monitor: 监控 AXI4-Lite 总线事务
//   检测完整的读写事务，通过 analysis_port 发送给 scoreboard
//=========================================================================
class axi4lite_monitor extends uvm_monitor;

    virtual axi4lite_vif   vif;
    axi4lite_config        cfg;

    uvm_analysis_port #(axi4lite_trans)  mon_analysis_port;

    `uvm_component_utils(axi4lite_monitor)

    function new(string name="axi4lite_monitor", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon_analysis_port = new("mon_analysis_port", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if (!uvm_config_db#(virtual axi4lite_vif)::get(this, "", "axi4lite_vif", vif))
            `uvm_fatal("NOVIF", "axi4lite_vif not set for monitor")
    endfunction

    virtual task run_phase(uvm_phase phase);
        axi4lite_trans  wr_tr, rd_tr;
        logic [31:0]    aw_addr_q, ar_addr_q;
        logic [31:0]    w_data_q;
        bit             aw_done, w_done, ar_done;

        forever begin
            @(posedge vif.clk);

            //--- 写通道监控: AW + W → B ---
            if (vif.awvalid && vif.awready) begin
                aw_addr_q = vif.awaddr;
                aw_done = 1;
            end
            if (vif.wvalid && vif.wready) begin
                w_data_q = vif.wdata;
                w_done = 1;
            end
            if (aw_done && w_done && vif.bvalid && vif.bready) begin
                wr_tr = axi4lite_trans::type_id::create("wr_tr");
                wr_tr.dir  = AXI4LITE_WRITE;
                wr_tr.addr = aw_addr_q;
                wr_tr.data = w_data_q;
                wr_tr.resp = vif.bresp;
                mon_analysis_port.write(wr_tr);
                `uvm_info(get_type_name(), $sformatf("MON WR: %s", wr_tr.convert2string()), UVM_HIGH)
                aw_done = 0;
                w_done = 0;
            end

            //--- 读通道监控: AR → R ---
            if (vif.arvalid && vif.arready) begin
                ar_addr_q = vif.araddr;
                ar_done = 1;
            end
            if (ar_done && vif.rvalid && vif.rready) begin
                rd_tr = axi4lite_trans::type_id::create("rd_tr");
                rd_tr.dir  = AXI4LITE_READ;
                rd_tr.addr = ar_addr_q;
                rd_tr.data = vif.rdata;
                rd_tr.resp = vif.rresp;
                mon_analysis_port.write(rd_tr);
                `uvm_info(get_type_name(), $sformatf("MON RD: %s", rd_tr.convert2string()), UVM_HIGH)
                ar_done = 0;
            end
        end
    endtask

endclass

`endif
