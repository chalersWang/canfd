`ifndef _AXI4LITE_CONFIG_SV_
`define _AXI4LITE_CONFIG_SV_

class axi4lite_config extends uvm_object;

    int          addr_width   = 32;
    int          data_width   = 32;
    int          wait_cycles  = 4;    // 默认 AW/W handshake 间隔
    bit          has_wstrb    = 0;    // PG223 不支持 wstrb
    bit          check_enable = 1;

    `uvm_object_utils_begin(axi4lite_config)
        `uvm_field_int(addr_width,   UVM_ALL_ON)
        `uvm_field_int(data_width,   UVM_ALL_ON)
        `uvm_field_int(wait_cycles,  UVM_ALL_ON)
        `uvm_field_int(has_wstrb,    UVM_ALL_ON)
        `uvm_field_int(check_enable, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name="axi4lite_config");
        super.new(name);
    endfunction

endclass

`endif
