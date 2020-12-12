`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/06/13 14:18:49
// Design Name: 
// Module Name: debouncer
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


module debouncer(
    input clk,
    input rst,
    input in,

    output reg out
    );

  reg out_r,buffer;
  reg [15:0] count;

  always @(posedge clk or negedge rst)
    if(!rst) count <= 0;
    else count <= count + 1;

  always @(posedge clk)
    if(count==0)
      begin
        buffer <= in;
        out <= buffer;
      end
endmodule

