//-------------------------------------------------------------------------
// File        : driver.sv
// Description : Fetches transactions from the 'gen2drv' mailbox and drives 
//               them synchronously onto the DUT interface.
//-------------------------------------------------------------------------


class driver;
  
  virtual fifo_if.DRIVER vif;
  mailbox #(transaction) gen2drv;
  transaction trans;
  
  function new( virtual fifo_if.DRIVER vif , mailbox #(transaction) gen2drv );
    
    this.vif = vif;
    this.gen2drv = gen2drv;
    
  endfunction
  
  task reset();
    
    // Used for diagnosing the reset_n is enabled or disabled for debugging
    
    $display("[DRV] Waiting for reset release... Current reset_n = %b", vif.reset_n);
    
    wait(!vif.reset_n);  
    vif.cb.wr_en   <= 0;
    vif.cb.rd_en   <= 0;
    vif.cb.data_in <= 0;
     
    wait(vif.reset_n);
    
    $display("[DRV] Reset released, driver starting");
    
  endtask
  
  // Task that gets the transaction from mailbox and drives it to the DUT interface
  
  task run();  
  
    forever begin
      
      @(vif.cb)
      
      gen2drv.get(trans);
      
      vif.cb.wr_en <= trans.wr_en;
      vif.cb.rd_en <= trans.rd_en;
      vif.cb.data_in <= trans.data_in;
    
      trans.print("[DRV]");
    
    end
  
  endtask
  
endclass
    