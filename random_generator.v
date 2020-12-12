`timescale 1ns / 1ps

module random_gen(
    input wire clk,               
    input wire rst,               
    input wire load,              
    input wire [31:0] seed,       
    output reg [31:0] rand_num    
    );
    
    always @ (posedge clk or negedge rst)
        if (!rst)
            rand_num <= 32'b0;
        else if (load)
            rand_num <= seed;
        else
            rand_num <= {rand_num[30:0],
                         rand_num[31]^rand_num[21]^rand_num[1]^rand_num[0]};
    
endmodule
