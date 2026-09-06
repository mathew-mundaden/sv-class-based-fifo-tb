//-------------------------------------------------------------------------
// File        : generator.sv
// Description : The class that generates the random transactions.
//               The transcations are passed onto the driver via the
//               'gen2drv' mailbox.
//-------------------------------------------------------------------------


class generator;
 
    
    mailbox #(transaction) gen2drv;
    int num_transactions;
    event done;
    int trans_count;
  
 
    function new(mailbox #(transaction) gen2drv, int num_transactions);
      
        this.gen2drv          = gen2drv;
        this.num_transactions = num_transactions;
        trans_count = 0;
      
    endfunction
  
  // The run() task to generate transactions according transaction number 
  // (int num_transactions) specified in testbench.sv 
  
  task run();
    
    transaction  trans;
    
    repeat (num_transactions) begin
      trans = new();
      
      if(!trans.randomize())begin
         $error("[GEN] randomize() failed on transaction %0d", trans_count);
      end
      
      gen2drv.put(trans);
      trans_count++;
    
      $display("[GEN] #%0d  wr_en=%0b rd_en=%0b data_in=%0h",
                trans_count, trans.wr_en, trans.rd_en, trans.data_in);
      
    end
    
    -> done; // An event to indicate that the generator has finished generating transactions
    
  endtask
  
endclass