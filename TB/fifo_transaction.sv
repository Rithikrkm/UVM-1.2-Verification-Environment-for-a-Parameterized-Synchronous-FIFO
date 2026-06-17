//---------------------------------------------------------
// Project : UVM FIFO Verification
// File    : fifo_transaction.sv
// Author  : Rithik Mohanan
//
// Description:
// Sequence item representing a FIFO transaction.
//---------------------------------------------------------

class fifo_transaction extends uvm_sequence_item;

  // Randomized stimulus fields
  rand bit [7:0] data;
  rand bit wr_en;
  rand bit rd_en;

  // Observed DUT outputs
  bit [7:0] dout;
  bit full;
  bit empty;

  // Prevent idle transaction generation
  constraint valid_op { !(wr_en==0 && rd_en==0); }

  // Register transaction with UVM factory
  `uvm_object_utils(fifo_transaction)

  //-------------------------------------------------------
  // Constructor
  //-------------------------------------------------------
  function new(string name = "fifo_transaction");
    super.new(name);
  endfunction

endclass
