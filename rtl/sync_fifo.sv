//-------------------------------------------------------------------------
// File        : sync_fifo.sv
// Description : Synchronous FIFO with parameterized depth and data width.
//               Uses a wrap-around pointer mechanism for full/empty flags.
//-------------------------------------------------------------------------


module sync_fifo #(
  parameter DATA_WIDTH = 8,
  parameter DEPTH = 16
) (
  input logic clk,
  input logic reset_n,
  
  input logic wr_en,
  input logic [DATA_WIDTH - 1:0] data_in,
  
  input logic rd_en,
  output logic [DATA_WIDTH - 1:0] data_out,
  
  output logic empty,
  output logic full
);
  
  // Set up the memory array and pointers
  localparam PTR_WIDTH = $clog2(DEPTH);
  logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];
  logic [PTR_WIDTH:0] wr_ptr, rd_ptr;
  
  // Write data to memory and increment the write pointer
  always_ff @(posedge clk or negedge reset_n) begin
    if(!reset_n)
      wr_ptr <= 0;
    else 
      if(wr_en && !full) begin
        mem[wr_ptr[PTR_WIDTH-1:0]] <= data_in;
        wr_ptr <= wr_ptr + 1;
      end
  end
  
  // Read data from memory and increment the read pointer
  always_ff @(posedge clk or negedge reset_n) begin
    if(!reset_n) begin
      data_out <= 0;
      rd_ptr <= 0;
    end else 
      if(rd_en && !empty) begin
        data_out <= mem[rd_ptr[PTR_WIDTH-1:0]];
        rd_ptr <= rd_ptr + 1;
      end
  end
  
  // Update full and empty flags based on pointer positions
  assign empty = (wr_ptr == rd_ptr);
  assign full  = (wr_ptr[PTR_WIDTH-1:0] == rd_ptr[PTR_WIDTH-1:0]) && (wr_ptr[PTR_WIDTH]     != rd_ptr[PTR_WIDTH]);
  
endmodule