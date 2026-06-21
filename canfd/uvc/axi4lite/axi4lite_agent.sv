`ifndef _AXI4LITE_AGENT_SV_
`define _AXI4LITE_AGENT_SV_

class axi4lite_agent extends uvm_agent;

    uvm_active_passive_enum  is_active = UVM_ACTIVE;
    axi4lite_driver          axi4lite_drv;
    axi4lite_sequencer       axi4lite_seqr;
    axi4lite_monitor         axi4lite_mon;
    axi4lite_config          cfg;

    `uvm_component_utils_begin(axi4lite_agent)
        `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
    `uvm_field_utils_end

    function new(string name="axi4lite_agent", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        uvm_config_db#(uvm_active_passive_enum)::get(this, "", "is_active", is_active);
        if (is_active == UVM_ACTIVE) begin
            axi4lite_drv  = axi4lite_driver::type_id::create("axi4lite_drv", this);
            axi4lite_seqr = axi4lite_sequencer::type_id::create("axi4lite_seqr", this);
        end
        axi4lite_mon = axi4lite_monitor::type_id::create("axi4lite_mon", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if (is_active == UVM_ACTIVE) begin
            axi4lite_drv.seq_item_port.connect(axi4lite_seqr.seq_item_export);
            axi4lite_drv.rsp_port.connect(axi4lite_seqr.rsp_export);
        end
    endfunction

endclass

`endif
