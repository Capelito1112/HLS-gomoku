`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/06/13 14:19:43
// Design Name: 
// Module Name: pulser
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

module pulser(
    input       clk,
    input       rst,
    input       in,

    output out
    );

   reg r1,r2,r3;
   always @(posedge clk) begin
        r1 <= in;
        r2 <= r1;
        r3 <= r2;
    end
    
    assign out = r2 & ~r3;
endmodule
