//-------------------------------------------------------------------------
// File        : interface.sv
// Description : Connects the FIFO DUT to the testbench components.
//-------------------------------------------------------------------------


interface fifo_if (input logic clk);
  
  logic reset_n;
  logic wr_en;
  logic [7:0] data_in;
  logic rd_en;
  logic [7:0] data_out;
  logic full;
  logic empty;
  
  // Clocking block prevents timing race conditions between the testbench and DUT
  
  clocking cb @(posedge clk);
    
    output wr_en, rd_en, data_in;
    input data_out, full, empty;
  
  endclocking
  
  // Modports to specify data direction and dictates what each module is allowed drive 
  // or read
  
  modport DRIVER (clocking cb, input reset_n);
    
  modport MONITOR (input clk, reset_n, wr_en, rd_en, data_in, data_out, full, empty);
  
endinterface