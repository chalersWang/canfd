`ifndef _AXI4LITE_SEQUENCE_LIB_SV_
`define _AXI4LITE_SEQUENCE_LIB_SV_

//=========================================================================
// axi4lite_base_sequence: 基类 sequence
//=========================================================================
class axi4lite_base_sequence extends uvm_sequence #(axi4lite_trans);

    `uvm_object_utils(axi4lite_base_sequence)

    function new(string name="axi4lite_base_sequence");
        super.new(name);
    endfunction

    virtual task pre_body();
        if (starting_phase != null)
            starting_phase.raise_objection(this, get_type_name());
    endtask

    virtual task post_body();
        if (starting_phase != null)
            starting_phase.drop_objection(this, get_type_name());
    endtask

    // 封装: 单笔写
    task do_single_write(input logic [31:0] addr, input logic [31:0] data);
        `uvm_do_with(req, {
            req.dir  == AXI4LITE_WRITE;
            req.addr == addr;
            req.data == data;
        })
    endtask

    // 封装: 单笔读
    task do_single_read(input logic [31:0] addr, output logic [31:0] data);
        `uvm_do_with(req, { req.dir == AXI4LITE_READ; req.addr == addr; })
        data = req.data;
    endtask

    // 封装: 读后比对
    task do_read_check(input logic [31:0] addr, input logic [31:0] exp_data,
                       output bit pass);
        `uvm_do_with(req, { req.dir == AXI4LITE_READ; req.addr == addr; })
        pass = (req.data === exp_data);
        if (!pass)
            `uvm_error(get_type_name(), $sformatf(
                "Read mismatch @0x%08h: exp=0x%08h got=0x%08h", addr, exp_data, req.data))
    endtask

endclass

//=========================================================================
// axi4lite_reg_write_seq: 寄存器写 sequence (供 virtual sequence 调用)
//=========================================================================
class axi4lite_reg_write_seq extends axi4lite_base_sequence;
    `uvm_object_utils(axi4lite_reg_write_seq)
    logic [31:0] addr;
    logic [31:0] data;

    function new(string name="axi4lite_reg_write_seq");
        super.new(name);
    endfunction

    virtual task body();
        do_single_write(addr, data);
    endtask
endclass

//=========================================================================
// axi4lite_reg_read_seq: 寄存器读 sequence
//=========================================================================
class axi4lite_reg_read_seq extends axi4lite_base_sequence;
    `uvm_object_utils(axi4lite_reg_read_seq)
    logic [31:0] addr;
    logic [31:0] data;

    function new(string name="axi4lite_reg_read_seq");
        super.new(name);
    endfunction

    virtual task body();
        do_single_read(addr, data);
    endtask
endclass

`endif
