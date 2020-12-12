`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/06/15 11:09:11
// Design Name: 
// Module Name: chat_remove
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


module chat_remove(
    input clk,
    input rst,
    input in,
    output out
    );
    
    reg [4:0] shift;
    
    always@ (posedge clk) begin
        shift <= {shift[3:0],in};
    end
    
    assign out = &shift;
endmodule
