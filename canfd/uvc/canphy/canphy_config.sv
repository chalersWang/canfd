`ifndef _CANPHY_CONFIG_SV_
`define _CANPHY_CONFIG_SV_

class canphy_config extends uvm_object;

    // 位时序参数 (与 DUT BRPR/BTR 配置同步)
    int          brp       = 5;     // 波特率预分频 (实际=brp+1)
    int          ts1       = 4;     // 时间段1 (实际=ts1+1)
    int          ts2       = 3;     // 时间段2 (实际=ts2+1)
    int          sjw       = 1;     // 同步跳转宽度
    // 数据相位
    int          dp_brp    = 1;     // 数据相位预分频
    int          dp_ts1    = 2;
    int          dp_ts2    = 1;
    int          dp_sjw    = 1;
    int          tdc_off   = 0;     // 发送延迟补偿

    // 仿真控制
    bit          coverage_enable = 1;
    bit          check_enable    = 1;
    bit          xz_check_enable = 1;

    // 计算属性
    int          bit_time_ns;      // 一个标称位的时间(ns)
    int          dp_bit_time_ns;   // 一个数据相位位的时间(ns)

    `uvm_object_utils_begin(canphy_config)
        `uvm_field_int(brp,        UVM_ALL_ON)
        `uvm_field_int(ts1,        UVM_ALL_ON)
        `uvm_field_int(ts2,        UVM_ALL_ON)
        `uvm_field_int(sjw,        UVM_ALL_ON)
        `uvm_field_int(dp_brp,     UVM_ALL_ON)
        `uvm_field_int(dp_ts1,     UVM_ALL_ON)
        `uvm_field_int(dp_ts2,     UVM_ALL_ON)
        `uvm_field_int(dp_sjw,     UVM_ALL_ON)
        `uvm_field_int(tdc_off,    UVM_ALL_ON)
        `uvm_field_int(coverage_enable, UVM_ALL_ON)
        `uvm_field_int(check_enable,    UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name="canphy_config");
        super.new(name);
        update_timing();
    endfunction

    function void update_timing();
        // CAN_CLK=50MHz → 20ns per cycle
        // Tq = 20ns * (brp+1)
        // bit_time = Tq * (1 + (ts1+1) + (ts2+1))
        bit_time_ns    = 20 * (brp + 1) * (1 + (ts1 + 1) + (ts2 + 1));
        dp_bit_time_ns = 20 * (dp_brp + 1) * (1 + (dp_ts1 + 1) + (dp_ts2 + 1));
    endfunction

endclass

`endif
