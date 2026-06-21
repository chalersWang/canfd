`ifndef _CANPHY_AGENT_SV_
`define _CANPHY_AGENT_SV_

class canphy_agent extends uvm_agent;

    uvm_active_passive_enum  is_active = UVM_ACTIVE;
    canphy_driver            canphy_drv;
    canphy_sequencer         canphy_seqr;
    canphy_monitor           canphy_mon;
    canphy_config            cfg;

    `uvm_component_utils_begin(canphy_agent)
        `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
    `uvm_field_utils_end

    function new(string name="canphy_agent", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        uvm_config_db#(uvm_active_passive_enum)::get(this, "", "is_active", is_active);
        if (is_active == UVM_ACTIVE) begin
            canphy_drv  = canphy_driver::type_id::create("canphy_drv", this);
            canphy_seqr = canphy_sequencer::type_id::create("canphy_seqr", this);
        end
        canphy_mon = canphy_monitor::type_id::create("canphy_mon", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if (is_active == UVM_ACTIVE) begin
            canphy_drv.seq_item_port.connect(canphy_seqr.seq_item_export);
            canphy_drv.rsp_port.connect(canphy_seqr.rsp_export);
        end
    endfunction

endclass : canphy_agent

`endif
