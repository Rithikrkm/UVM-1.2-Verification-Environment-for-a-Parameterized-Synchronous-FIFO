//---------------------------------------------------------
// Project : UVM FIFO Verification
// File    : fifo_monitor.sv
// Author  : Rithik Mohanan
//
// FIFO Monitor
//
// Passively observes FIFO interface activity,
// collects signal information into transaction
// objects, and forwards them to the scoreboard
// through an analysis port.
//---------------------------------------------------------

class fifo_monitor extends uvm_component;

  // Register monitor with UVM factory
  `uvm_component_utils(fifo_monitor)

  // Virtual interface connected to the DUT
  virtual fifo_if vif;

  // Analysis port used to broadcast sampled
  // transactions to subscribers (scoreboard)
  uvm_analysis_port #(fifo_transaction) ap;

  //-------------------------------------------------------
  // Constructor
  //-------------------------------------------------------
  function new(string name, uvm_component parent);

    super.new(name, parent);

    ap = new("ap", this);

  endfunction

  //-------------------------------------------------------
  // Retrieve virtual interface from UVM config database
  //-------------------------------------------------------
  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    if(!uvm_config_db#(virtual fifo_if)::get(this, "", "vif", vif))
      `uvm_fatal("MON", "Virtual Interface Not Found")

  endfunction

  //-------------------------------------------------------
  // Continuously sample DUT activity.
  //
  // For every clock cycle:
  //   1. Create a transaction object
  //   2. Capture interface signals
  //   3. Send transaction to scoreboard
  //-------------------------------------------------------
  task run_phase(uvm_phase phase);

    fifo_transaction txn;

    forever begin

      // Sample signals on rising clock edge
      @(posedge vif.clk);

      // Create a transaction to hold sampled data
      txn = fifo_transaction::type_id::create("txn");

      // Capture DUT interface activity
      txn.data  = vif.din;
      txn.dout  = vif.dout;
      txn.full  = vif.full;
      txn.empty = vif.empty;
      txn.wr_en = vif.wr_en;
      txn.rd_en = vif.rd_en;

      // Broadcast transaction to analysis components
      ap.write(txn);

    end

  endtask

endclass
