`ifndef _CANPHY_REG_ADAPTER_SV_
`define _%s_REG_ADAPTER_SV_

//=========================================================================
// canphy_reg_adapter: 寄存器访问总线适配器
//   将 uvm_reg_bus_op 转换为 canphy_trans，反向亦然
//=========================================================================
class canphy_reg_adapter extends uvm_reg_adapter;

    `uvm_object_utils(canphy_reg_adapter)

    function new(string name="canphy_reg_adapter");
        super.new(name);
        // supports_byte_enable: 设为 1 以支持字节级访问
        supports_byte_enable = 0;
        // provides_responses: adapter 是否处理 bus2reg
        provides_responses  = 1;
    endfunction : new

    // =====================================================================
    // reg2bus: 将 RAL 操作 (uvm_reg_bus_op) 转换为总线 transaction
    //   rw.kind:  UVM_READ / UVM_WRITE
    //   rw.addr:  目标寄存器地址
    //   rw.data:  要写入的数据 (WRITE 时)
    // =====================================================================
    virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
        canphy_trans tr;
        tr = canphy_trans::type_id::create("tr");

        tr.CFG   = (rw.kind == UVM_READ) ? canphy_trans::READ : canphy_trans::WRITE;
        tr.ADDR  = rw.addr;

        if (rw.kind == UVM_WRITE) begin
            tr.WRDATA = rw.data;
        end
        else begin
            tr.RDDATA = rw.data;  // 前门读时，此值可能是 X
        end

        `uvm_info(get_type_name(), $sformatf("reg2bus: kind=%%0s addr=%%0h data=%%0h",
            rw.kind.name(), rw.addr, rw.data), UVM_FULL)

        return tr;
    endfunction : reg2bus

    // =====================================================================
    // bus2reg: 将总线 transaction 的响应转换回 uvm_reg_bus_op
    //   bus_item: 总线返回的 transaction
    //   rw: 需要更新的 bus_op
    // =====================================================================
    virtual function void bus2reg(uvm_sequence_item bus_item,
                                   ref uvm_reg_bus_op rw);
        canphy_trans tr;
        if (!$cast(tr, bus_item)) begin
            `uvm_fatal(get_type_name(), "bus2reg: cast failed! Wrong transaction type.")
            return;
        end

        rw.kind  = (tr.CFG == canphy_trans::WRITE) ? UVM_WRITE : UVM_READ;
        rw.addr  = tr.ADDR;
        rw.data  = (tr.CFG == canphy_trans::WRITE) ? tr.WRDATA : tr.RDDATA;
        rw.status = UVM_IS_OK;

        `uvm_info(get_type_name(), $sformatf("bus2reg: kind=%%0s addr=%%0h data=%%0h",
            rw.kind.name(), rw.addr, rw.data), UVM_FULL)
    endfunction : bus2reg

endclass : canphy_reg_adapter

`endif
