`ifndef _CANFD_REG_ADAPTER_SV_
`define _CANFD_REG_ADAPTER_SV_

//=========================================================================
// canfd_reg_adapter: UVM Reg → AXI4-Lite 适配器
//   将 uvm_reg_bus_op 转换为 axi4lite_trans
//=========================================================================
class canfd_reg_adapter extends uvm_reg_adapter;

    `uvm_object_utils(canfd_reg_adapter)

    function new(string name="canfd_reg_adapter");
        super.new(name);
        supports_byte_enable = 0;
        provides_responses    = 1;
    endfunction

    virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
        axi4lite_trans tr = axi4lite_trans::type_id::create("tr");
        tr.dir  = (rw.kind == UVM_WRITE) ? AXI4LITE_WRITE : AXI4LITE_READ;
        tr.addr = rw.addr;
        if (rw.kind == UVM_WRITE)
            tr.data = rw.data;
        tr.wstrb = 4'hF;
        return tr;
    endfunction

    virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
        axi4lite_trans tr;
        if (!$cast(tr, bus_item))
            `uvm_fatal(get_type_name(), "bus2reg: cast to axi4lite_trans failed")
        rw.kind   = (tr.dir == AXI4LITE_WRITE) ? UVM_WRITE : UVM_READ;
        rw.addr   = tr.addr;
        rw.data   = tr.data;
        rw.status = (tr.resp == AXI_RESP_OKAY) ? UVM_IS_OK : UVM_NOT_OK;
    endfunction

endclass : canfd_reg_adapter

`endif
