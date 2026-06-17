//---------------------------------------------------------
// Project : UVM FIFO Verification
// File    : tb_top.sv
// Author  : Rithik Mohanan
//
// Contains:
//   - FIFO verification package
//   - Top-level testbench
//   - DUT instantiation
//   - Clock/Reset generation
//   - UVM test startup
//---------------------------------------------------------

`include "fifo_if.sv"

//---------------------------------------------------------
// FIFO Verification Package
//
// Collects all UVM components into a single package
// so they can be imported using:
//
//   import fifo_pkg::*;
//---------------------------------------------------------
package fifo_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // Transaction definition
  `include "fifo_transaction.sv"

  // Stimulus generation
  `include "fifo_sequence.sv"

  // Sequence execution control
  `include "fifo_sequencer.sv"

  // Drives DUT interface
  `include "fifo_driver.sv"

  // Samples DUT activity
  `include "fifo_monitor.sv"

  // Reference model and checking
  `include "fifo_scoreboard.sv"

  // Driver + Sequencer + Monitor
  `include "fifo_agent.sv"

  // Connects agent and scoreboard
  `include "fifo_env.sv"

  // Top-level UVM test
  `include "fifo_test.sv"

endpackage


//---------------------------------------------------------
// Top-Level Testbench
//
// Responsibilities:
//   - Instantiate DUT
//   - Generate clock and reset
//   - Provide interface to UVM components
//   - Launch UVM test
//---------------------------------------------------------
module tb_top;

  import uvm_pkg::*;
  import fifo_pkg::*;

  // Interface instance used by DUT and UVM TB
  fifo_if vif();

  //-------------------------------------------------------
  // DUT Instance
  //-------------------------------------------------------
  fifo uut(
    .clk(vif.clk),
    .rst(vif.rst),
    .wr_en(vif.wr_en),
    .rd_en(vif.rd_en),
    .din(vif.din),
    .dout(vif.dout),
    .full(vif.full),
    .empty(vif.empty)
  );

  //-------------------------------------------------------
  // 100 MHz Clock Generation
  // Clock Period = 10 ns
  //-------------------------------------------------------
  initial begin
    vif.clk = 0;
  end

  always #5 vif.clk = ~vif.clk;

  //-------------------------------------------------------
  // Apply reset at start of simulation
  //-------------------------------------------------------
  initial begin
    vif.rst = 1;
    #20;
    vif.rst = 0;
  end

  //-------------------------------------------------------
  // Enable waveform dumping for debug
  //-------------------------------------------------------
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end

  //-------------------------------------------------------
  // Configure virtual interface and start UVM test
  //-------------------------------------------------------
  initial begin

    // Make interface accessible to all UVM components
    uvm_config_db#(virtual fifo_if)::set(
      null,
      "*",
      "vif",
      vif
    );

    run_test("fifo_test");

  end

endmodule
