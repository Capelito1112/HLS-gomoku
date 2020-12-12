`timescale 1ns / 1ps

module clk_divider(
    input wire clk,              
    input wire rst,              
    output reg [31:0] clk_div    
    );
    
    always @ (posedge clk or negedge rst)
        if (!rst)
            clk_div <= 32'b0;
        else
            clk_div <= clk_div + 1;
    
endmodule
