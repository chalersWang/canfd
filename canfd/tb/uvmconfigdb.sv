typedef virtual canfd_vif  canfdvif;
canfd_vif   TopVif(tb_top.i_pad_clk, tb_top.i_pad_rst_b);

initial begin
    uvm_config_db#(virtual canfd_vif)::set(null, "*", "canfd_vif", TopVif);
    uvm_config_db#(virtual canphy_vif)::set(null, "*", "canphy_vif", TopVif.canphyvif);
    uvm_config_db#(virtual axi4lite_vif)::set(null, "*", "axi4lite_vif", TopVif.axi4litevif);
    run_test();
end

`ifdef SVA_TB_TOP
    `include "./../sva/code/sva_tb_top.sv"
`endif
