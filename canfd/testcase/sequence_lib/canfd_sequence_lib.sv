`ifndef _CANFD_SEQUENCE_LIB_SV_
`define _CANFD_SEQUENCE_LIB_SV_

class canfd_virtual_seq_lib extends uvm_sequence;

    canfd_config     canfd_cfg;
    canfd_event      canfd_evt;

    `uvm_object_utils_begin(canfd_virtual_seq_lib)
    `uvm_object_utils_end

    `uvm_declare_p_sequencer(canfd_virtual_sequencer)

    function new(string name="canfd_virtual_seq_lib");
        super.new(name);
        canfd_cfg = new();
        canfd_evt = new();
        set_automatic_phase_objection(1);
    endfunction

    virtual task pre_body();
        `uvm_info(get_full_name(), "pre_body() begin", UVM_LOW)
        if (starting_phase != null)
            starting_phase.raise_objection(this, "virtual sequence raise_objection");
        if (!uvm_config_db#(canfd_config)::get(null, get_full_name(), "canfd_config", canfd_cfg))
            `uvm_fatal(get_type_name(), "Can't get config object!")
        if (!uvm_config_db#(canfd_event)::get(null, get_full_name(), "canfd_event", canfd_evt))
            `uvm_fatal(get_type_name(), "Can't get event object!")
        `uvm_info(get_full_name(), "pre_body end", UVM_LOW)
    endtask

    virtual task body();
        // 基类 body: 子类 override
    endtask

    virtual task post_body();
        `uvm_info(get_full_name(), "post_body() begin", UVM_LOW)
        if (starting_phase != null)
            starting_phase.drop_objection(this);
        `uvm_info(get_full_name(), "post_body end", UVM_LOW)
    endtask

    `include "canfd_common_task_function.sv"

endclass

`endif
