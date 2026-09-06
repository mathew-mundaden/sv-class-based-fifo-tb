//-------------------------------------------------------------------------
// File        : monitor.sv
// Description : Passively samples DUT signals, passes valid transactions to 
//               the scoreboard, and collects functional coverage.
//-------------------------------------------------------------------------

class monitor;

  virtual fifo_if.MONITOR vif;
  mailbox #(transaction) mon2scb;
  coverage cov; 

  function new(virtual fifo_if.MONITOR vif, mailbox #(transaction) mon2scb, coverage cov);
    this.vif     = vif;
    this.mon2scb = mon2scb;
    this.cov     = cov;
  endfunction

  task run();
    transaction trans;
    bit rd_pending = 0; 

    forever begin
      // Sample on negedge to ensure all posedge-driven hardware signals are completely stable
      @(negedge vif.clk);

      // Flush internal state and skip sampling during reset
      if (!vif.reset_n) begin
        rd_pending = 0;
        continue;
      end

      // Unconditionally capture the current interface state for coverage metrics
      begin
        transaction cov_trans = new();
        cov_trans.wr_en   = vif.wr_en;
        cov_trans.rd_en   = vif.rd_en;
        cov_trans.full    = vif.full;
        cov_trans.empty   = vif.empty;
        cov_trans.data_in = vif.data_in;
        cov.sample(cov_trans);
      end

      // Capture the DUT's output data from a read that was triggered in the previous cycle
      if (rd_pending) begin
        trans          = new();
        trans.rd_en    = 1'b1;
        trans.wr_en    = 1'b0;
        trans.data_out = vif.data_out; 
        trans.empty    = vif.empty;
        trans.full     = vif.full;

        mon2scb.put(trans);
        trans.print("[MON-RD]");
      end

      // Capture valid write data immediately as it enters the DUT
      if (vif.wr_en && !vif.full) begin
        trans         = new();
        trans.wr_en   = 1'b1;
        trans.rd_en   = 1'b0;
        trans.data_in = vif.data_in;
        trans.empty   = vif.empty;
        trans.full    = vif.full;

        mon2scb.put(trans);
        trans.print("[MON-WR]");
      end

      // Flag a valid read request so its corresponding output is captured on the next clock edge
      rd_pending = (vif.rd_en && !vif.empty);
    end
  endtask

endclass