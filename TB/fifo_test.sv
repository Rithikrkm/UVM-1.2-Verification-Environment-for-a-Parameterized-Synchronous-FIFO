//---------------------------------------------------------
// Project : UVM FIFO Verification
// File    : fifo_test.sv
// Author  : Rithik Mohanan
//
// FIFO Test
//
// Top-level UVM test responsible for:
//   - Creating the verification environment
//   - Starting the stimulus sequence
//   - Controlling simulation execution using
//     UVM objections
//---------------------------------------------------------

class fifo_test extends uvm_test;

  // Register test with UVM factory
  `uvm_component_utils(fifo_test)

  // Verification environment
  fifo_env env;

  //-------------------------------------------------------
  // Constructor
  //-------------------------------------------------------
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  //-------------------------------------------------------
  // Build Phase
  //
  // Create the verification environment.
  //-------------------------------------------------------
  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    env = fifo_env::type_id::create("env", this);

  endfunction

  //-------------------------------------------------------
  // Run Phase
  //
  // Creates and starts the main FIFO sequence.
  // Objections are used to prevent the simulation
  // from ending before stimulus execution completes.
  //-------------------------------------------------------
  task run_phase(uvm_phase phase);

    fifo_sequence seq;

    // Keep simulation alive while test is running
    phase.raise_objection(this);

    // Create stimulus sequence
    seq = fifo_sequence::type_id::create("seq");

    // Start sequence on the FIFO sequencer
    seq.start(env.agent.seqr);

    // Allow time for all transactions to complete
    #200;

    // Indicate test completion
    phase.drop_objection(this);

  endtask

endclass
