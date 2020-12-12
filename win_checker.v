`timescale 1ns / 1ps

module win_checker(
    input wire clk,               
    input wire rst,               
    input wire clr,               
    input wire active,            
    
    input wire [8:0] black_y,     
    input wire [8:0] black_x,     
    input wire [8:0] black_yx,    
    input wire [8:0] black_xy,    
    input wire [8:0] white_y,
    input wire [8:0] white_x,
    input wire [8:0] white_yx,
    input wire [8:0] white_xy,
    
    output reg [3:0] get_y,       
    output reg [3:0] get_x,       
    output reg is_win             
    );
    
    localparam BOARD_SIZE = 15;
    
    localparam IDLE = 1'b0,
               WORKING = 1'b1;
    
    reg state;  
    
    wire b0, b1, b2, b3, w0, w1, w2, w3;
    pattern_five pattern_b0(black_y, b0),
                 pattern_b1(black_x, b1),
                 pattern_b2(black_yx, b2),
                 pattern_b3(black_xy, b3),
                 pattern_w0(white_y, w0),
                 pattern_w1(white_x, w1),
                 pattern_w2(white_yx, w2),
                 pattern_w3(white_xy, w3);
    
    always @ (posedge clk or negedge rst) begin
        if (!rst || clr) begin
            get_y <= 4'b0;
            get_x <= 4'b0;
            is_win <= 0;
            
            state <= IDLE;
        end
        else if (!active && state == IDLE)
            state <= WORKING;
        else if (active && state == WORKING) begin
            if (get_y == 4'b0 && get_x == 4'b0)
                is_win <= b0 | b1 | b2 | b3 | w0 | w1 | w2 | w3;
            else
                is_win <= is_win | b0 | b1 | b2 | b3 | w0 | w1 | w2 | w3;
            
            if (get_x == BOARD_SIZE - 1) begin
                if (get_y == BOARD_SIZE - 1) begin
                    get_y <= 4'b0;
                    get_x <= 4'b0;
                    state <= IDLE;
                end
                else begin
                    get_y <= get_y + 1'b1;
                    get_x <= 4'b0;
                end
            end
            else
                get_x <= get_x + 1'b1;
        end
    end
    
endmodule
