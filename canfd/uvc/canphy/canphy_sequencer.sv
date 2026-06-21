`ifndef _CANPHY_SEQUENCER_SV_
`define _CANPHY_SEQUENCER_SV_

class canphy_sequencer extends uvm_sequencer #(canphy_trans);
    `uvm_component_utils(canphy_sequencer)
    function new(string name="canphy_sequencer", uvm_component parent=null);
        super.new(name, parent);
    endfunction
endclass

`endif
