`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/28/2026 06:22:57 PM
// Design Name: 
// Module Name: fifo
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module fifo
#(
    parameter WIDTH = 8,
    parameter DEPTH = 4
 )
(
    input clk,
    input aresetn,
    input [WIDTH-1:0] data_in,
    output logic [WIDTH-1:0] data_out,
    output full,
    output empty,
    input push,
    input pop
    );
    
    logic[WIDTH-1:0] mem [0:DEPTH-1];
    
    localparam POINTER_WIDTH = $clog2 (DEPTH),
             COUNTER_WIDTH = $clog2 (DEPTH + 1);

    logic [POINTER_WIDTH - 1:0] wr_ptr, rd_ptr;
    logic last_read;
    
    always @(posedge clk,negedge aresetn)
        if (~aresetn)
        begin
            wr_ptr <= '0;
            rd_ptr <= '0;
            last_read <= 1'b1;
        end
        else 
        begin
        if (push&&~full)
        begin
            if (wr_ptr == DEPTH-1)
                wr_ptr <= 0;
            else
                wr_ptr <= wr_ptr+1;
            mem[wr_ptr] <= data_in;  
            last_read <= 1'b0;             
        end
        else if (pop&&~empty)
        begin
            if (rd_ptr == DEPTH-1)
                rd_ptr <= 0;
            else
                rd_ptr <= rd_ptr+1;
            last_read <= 1'b1;
        end
        end
      
     assign data_out = mem[rd_ptr];
     assign empty = (wr_ptr==rd_ptr)&last_read;
     assign full = (wr_ptr==rd_ptr)&~last_read;

endmodule