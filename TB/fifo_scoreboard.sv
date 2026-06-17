//---------------------------------------------------------
// Project : UVM FIFO Verification
// File    : fifo_scoreboard.sv
// Author  : Rithik Mohanan
//
// FIFO Scoreboard
//
// Maintains a reference model of the FIFO using a queue.
// Incoming write operations are stored in the queue,
// while read operations are checked against DUT output.
//
// Verification Flow:
//   Write -> Store expected data
//   Read  -> Compare DUT output with expected data
//---------------------------------------------------------

class fifo_scoreboard extends uvm_component;

  // Register scoreboard with UVM factory
  `uvm_component_utils(fifo_scoreboard)

  // Analysis implementation port used to receive
  // transactions from the monitor
  uvm_analysis_imp #(fifo_transaction, fifo_scoreboard) imp;

  // Reference FIFO model
  // Mirrors the expected contents of the DUT FIFO
  bit [7:0] expected_q[$];

  // Expected data value for the next read comparison
  bit [7:0] expected_d;

  // Indicates a read occurred and comparison should
  // be performed on the following monitor transaction
  bit pending_read;

  //-------------------------------------------------------
  // Constructor
  //-------------------------------------------------------
  function new(string name, uvm_component parent);
    super.new(name, parent);
    imp = new("imp", this);
  endfunction

  //-------------------------------------------------------
  // Receives transactions from the monitor and updates
  // the reference model while checking DUT behavior.
  //-------------------------------------------------------
  function void write(fifo_transaction txn);

    //-----------------------------------------------------
    // Complete comparison for a previously requested read
    //
    // The DUT updates dout one cycle after the read
    // request, so the comparison is deferred using
    // pending_read.
    //-----------------------------------------------------
    if (pending_read) begin

      if (txn.dout == expected_d) begin

        `uvm_info("SB",
          $sformatf("PASS Expected=%0h Received=%0h",
                    expected_d,
                    txn.dout),
          UVM_LOW)

      end
      else begin

        `uvm_error("SB",
          $sformatf("FAIL Expected=%0h Received=%0h",
                    expected_d,
                    txn.dout))

      end

      pending_read = 0;

    end

    //-----------------------------------------------------
    // Reference model write operation
    //
    // If a valid write occurs, store the incoming data
    // in the reference queue.
    //-----------------------------------------------------
    if (txn.wr_en && !txn.full) begin

      expected_q.push_back(txn.data);

      `uvm_info("SB",
        $sformatf("Stored data=%0h", txn.data),
        UVM_LOW)

    end

    //-----------------------------------------------------
    // Reference model read operation
    //
    // Remove the oldest expected value from the queue
    // and schedule comparison for the next cycle.
    //-----------------------------------------------------
    if (txn.rd_en && !txn.empty) begin

      if (expected_q.size() > 0) begin

        expected_d = expected_q.pop_front();

        // DUT output will be checked on next transaction
        pending_read = 1;

      end
      else begin

        `uvm_error("SB",
          "Read occurred but expected queue is empty!")

      end

    end

  endfunction

endclass
