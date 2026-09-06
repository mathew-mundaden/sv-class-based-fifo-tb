//-------------------------------------------------------------------------
// File        : transaction.sv
// Description : Defines the data packet and randomization constraints.
//               This is the basic unit of data sent through the testbench.
//-------------------------------------------------------------------------


class transaction;

  rand bit       wr_en;
  rand bit       rd_en;
  rand bit [7:0] data_in;  

  bit [7:0] data_out;
  bit         full;
  bit         empty; 
  
  // The print() function needed to display the values of transaction moving
  // throughout the code
  
  function void print(string tag="[TRANS]");
    $display("%s wr_en=%0b rd_en=%0b data_in=%0h", tag, wr_en, rd_en, data_in);
  endfunction

endclass