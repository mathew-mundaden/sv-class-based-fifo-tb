//-------------------------------------------------------------------------
// File        : environment.sv
// Description : The container class that instantiates, connects, and 
//               manages all the verification components.
//-------------------------------------------------------------------------

class environment;

  generator  gen;
  driver     drv;
  monitor    mon;
  scoreboard scb;
  coverage   cov; 

  mailbox #(transaction) gen2drv;
  mailbox #(transaction) mon2scb;

  virtual fifo_if vif;

  function new(virtual fifo_if vif, int num_transactions);
    this.vif = vif;
    gen2drv  = new();
    mon2scb  = new();
    
    cov = new();                                
    gen = new(gen2drv, num_transactions);
    drv = new(vif, gen2drv);
    mon = new(vif, mon2scb, cov);               
    scb = new(mon2scb);
  endfunction

  task run();
    drv.reset();

    // fork...join_none runs these tasks in the background at the same time, 
    // without pausing the rest of the code in this task
    fork
      gen.run();
      drv.run();
      mon.run();
      scb.run();
    join_none

    wait(gen.done.triggered);
    
    // Drain time: Even though the generator is done, wait for the driver to empty 
    // the mailbox and give the DUT a few extra clock cycles to finish the last packets
    while (gen2drv.num() > 0) @(posedge vif.clk);
    repeat (5) @(posedge vif.clk);
    
    scb.report();
    
    $display("=================================");
    $display(" FUNCTIONAL COVERAGE: %0.2f %%", cov.fifo_cg.get_inst_coverage());
    $display("=================================");
    
  endtask
  
endclass