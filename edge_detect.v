`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/06/15 05:15:15
// Design Name: 
// Module Name: edge_detect
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


module edge_detect(CLK, RST, in, out);
    input CLK;
    input RST;
    input in;
    output out;

    reg [1:0] reg_a;
   
    always @(posedge CLK) begin
       reg_a <= {reg_a[0],in};
   end
   
   assign out = reg_a[1] ^ reg_a[0];
endmodule
