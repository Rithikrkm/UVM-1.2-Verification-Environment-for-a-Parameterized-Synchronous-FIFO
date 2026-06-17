//---------------------------------------------------------
// Project : UVM FIFO Verification
// File    : fifo_sequencer.sv
// Author  : Rithik Mohanan
//
// FIFO Sequencer
//
// Controls the flow of transactions from the sequence
// to the driver. In this project, the sequencer uses
// the default UVM sequencer functionality and does not
// require any custom behavior.
//---------------------------------------------------------

class fifo_sequencer extends uvm_sequencer #(fifo_transaction);

  // Register sequencer with the UVM factory
  `uvm_component_utils(fifo_sequencer)

  //-------------------------------------------------------
  // Constructor
  //-------------------------------------------------------
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

endclass
