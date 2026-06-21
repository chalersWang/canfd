`ifndef _AXI4LITE_TRANS_SV_
`define _AXI4LITE_TRANS_SV_

//=========================================================================
// axi4lite_trans: AXI4-Lite 事务级 transaction
//   一笔 transaction = 一次读或写操作
//=========================================================================
typedef enum bit { AXI4LITE_READ = 1'b0, AXI4LITE_WRITE = 1'b1 } axi4lite_dir_e;

typedef enum logic [1:0] {
    AXI_RESP_OKAY   = 2'b00,
    AXI_RESP_EXOKAY = 2'b01,
    AXI_RESP_SLVERR = 2'b10,
    AXI_RESP_DECERR = 2'b11
} axi4lite_resp_e;

class axi4lite_trans extends uvm_sequence_item;

    rand axi4lite_dir_e    dir;        // 读/写方向
    rand logic [31:0]      addr;       // 访问地址
    rand logic [31:0]      data;       // 写数据(W)/读数据(R)
    rand logic [3:0]       wstrb;      // byte enable (PG223 不使用，默认全1)
    logic [1:0]            resp;       // 响应码 (driver 填充)
    int                    latency;    // 实际握手延迟 (monitor 填充)

    // 约束: 字对齐访问
    constraint c_addr_align {
        addr[1:0] == 2'b00;  // 32-bit 对齐
    }

    // 约束: wstrb 全1 (PG223 不支持 wstrb)
    constraint c_wstrb_default {
        wstrb == 4'hF;
    }

    `uvm_object_utils_begin(axi4lite_trans)
        `uvm_field_enum(axi4lite_dir_e, dir,   UVM_ALL_ON)
        `uvm_field_int(addr,                    UVM_ALL_ON)
        `uvm_field_int(data,                    UVM_ALL_ON)
        `uvm_field_int(wstrb,                   UVM_ALL_ON)
        `uvm_field_int(resp,                    UVM_ALL_ON)
        `uvm_field_int(latency,                 UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name="axi4lite_trans");
        super.new(name);
    endfunction

    function string convert2string();
        string s;
        s = $sformatf("{dir=%s addr=0x%08h data=0x%08h resp=%s lat=%0d}",
            (dir==AXI4LITE_WRITE)?"WR":"RD", addr, data,
            (resp==AXI_RESP_OKAY)?"OKAY":
            (resp==AXI_RESP_SLVERR)?"SLVERR":
            (resp==AXI_RESP_DECERR)?"DECERR":"?", latency);
        return s;
    endfunction

endclass

`endif
