//---------------------------------------------------------
// Project : UVM FIFO Verification
// File    : fifo.sv
// Author  : Rithik Mohanan
//
// Synchronous Parameterized FIFO
//
// Features:
//   - Configurable depth and data width
//   - Single clock operation
//   - Full and empty status flags
//   - Simultaneous read and write support
//---------------------------------------------------------

module fifo #(
  parameter DEPTH = 8,
  parameter WIDTH = 8
)(
  input  logic clk,
  input  logic rst,

  input  logic wr_en,
  input  logic rd_en,

  input  logic [WIDTH-1:0] din,
  output logic [WIDTH-1:0] dout,

  output logic full,
  output logic empty
);

  // FIFO memory array
  logic [WIDTH-1:0] mem[DEPTH];

  // Write pointer, read pointer, and occupancy count
  int wr_ptr;
  int rd_ptr;
  int count;

  //-------------------------------------------------------
  // Sequential FIFO Operation
  //
  // Handles:
  //   1. Reset
  //   2. Write operation
  //   3. Read operation
  //   4. Occupancy count update
  //-------------------------------------------------------
  always_ff @(posedge clk or posedge rst) begin

    //-----------------------------------------------------
    // Reset FIFO state
    //-----------------------------------------------------
    if (rst) begin
      wr_ptr <= 0;
      rd_ptr <= 0;
      count  <= 0;
      dout   <= 0;
    end

    else begin

      //---------------------------------------------------
      // Write Operation
      //
      // Store input data and advance write pointer if
      // FIFO is not full.
      //---------------------------------------------------
      if (wr_en && !full) begin
        mem[wr_ptr] <= din;
        wr_ptr <= (wr_ptr + 1) % DEPTH;
      end

      //---------------------------------------------------
      // Read Operation
      //
      // Transfer oldest data to output and advance read
      // pointer if FIFO is not empty.
      //---------------------------------------------------
      if (rd_en && !empty) begin
        dout <= mem[rd_ptr];
        rd_ptr <= (rd_ptr + 1) % DEPTH;
      end

      //---------------------------------------------------
      // Update FIFO occupancy count
      //
      // Write Only : Increment count
      // Read Only  : Decrement count
      // Read+Write : Count remains unchanged
      //---------------------------------------------------
      case ({wr_en && !full, rd_en && !empty})

        2'b10: count <= count + 1;

        2'b01: count <= count - 1;

        // Simultaneous read and write maintain occupancy
        2'b11: count <= count;

      endcase

    end

  end

  //-------------------------------------------------------
  // Status Flag Generation
  //-------------------------------------------------------

  // FIFO is full when occupancy reaches maximum depth
  assign full  = (count == DEPTH);

  // FIFO is empty when no valid entries are present
  assign empty = (count == 0);

endmodule
