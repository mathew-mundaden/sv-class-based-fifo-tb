// -----------------------------------------------------------------------------
// File        : scoreboard.sv
// Description : Golden reference model and data checker for the FIFO.
// -----------------------------------------------------------------------------

class scoreboard;

  mailbox #(transaction) mon2scb;
  bit [7:0] ref_queue[$]; // SystemVerilog queue acting as the ideal golden model

  int pass_count  = 0;
  int error_count = 0;

  function new(mailbox #(transaction) mon2scb);
    this.mon2scb = mon2scb;
  endfunction

  task run();
    transaction trans;
    bit [7:0] expected_data;

    forever begin
      mon2scb.get(trans);

      if (trans.wr_en) begin
        ref_queue.push_back(trans.data_in);
      end

      if (trans.rd_en) begin
        // Guard against popping an empty queue during simulated underflow
        if (ref_queue.size() == 0) begin
          $error("[SCB] UNDERFLOW: Read performed when reference model was empty!");
          error_count++;
        end else begin
          expected_data = ref_queue.pop_front();
          
          if (trans.data_out !== expected_data) begin
            $error("[SCB] DATA MISMATCH: Expected=%0h Actual=%0h", expected_data, trans.data_out);
            error_count++;
          end else begin
            $display("[SCB] PASS: Data matched = %0h", trans.data_out);
            pass_count++;
          end
        end
      end
    end
  endtask

  function void report();
    $display("\n=================================");
    $display("        SIMULATION REPORT        ");
    $display("  PASSED: %0d    FAILED: %0d     ", pass_count, error_count);
    $display("=================================\n");
  endfunction

endclass