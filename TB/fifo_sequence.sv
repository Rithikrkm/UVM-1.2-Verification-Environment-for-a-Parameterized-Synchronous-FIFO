//---------------------------------------------------------
// Project : UVM FIFO Verification
// File    : fifo_sequence.sv
// Author  : Rithik Mohanan
//
// Generates randomized FIFO transactions and sends them
// to the sequencer for execution.
//
// Traffic Profile:
//   - Write operations favored (70%)
//   - Read operations allowed (50%)
//---------------------------------------------------------

class fifo_sequence extends uvm_sequence #(fifo_transaction);

  `uvm_object_utils(fifo_sequence)

  function new(string name = "fifo_sequence");
    super.new(name);
  endfunction

  task body();

    fifo_transaction txn;

    // Generate 20 randomized FIFO transactions
    repeat(20) begin

      // Create a new transaction object
      txn = fifo_transaction::type_id::create("txn");

      // Request permission from sequencer to send item
      start_item(txn);

      // Bias stimulus toward write operations so that
      // data is available in the FIFO for future reads
      assert(txn.randomize() with {
        wr_en dist {1:=70, 0:=30};
        rd_en dist {1:=50, 0:=50};
      });

      // Send transaction to driver
      finish_item(txn);

      `uvm_info("SEQ",
        $sformatf("Generated data=%0h wr=%0b rd=%0b",
                  txn.data,
                  txn.wr_en,
                  txn.rd_en),
        UVM_LOW)

    end

  endtask

endclass
