`timescale 1ns / 1ps

module gomoku_strategy(
    input wire clk,                        
    input wire rst,                        
    input wire clr,                        
    input wire active,                     
    input wire random,                     
    
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
    
    output reg [12:0] black_best_score,    
    output reg [3:0] black_best_y,         
    output reg [3:0] black_best_x,         
    output reg [12:0] white_best_score,
    output reg [3:0] white_best_y,
    output reg [3:0] white_best_x
    );
    
    localparam BOARD_SIZE = 15;
    
    localparam IDLE = 1'b0,
               WORKING = 1'b1;
    
    reg state;

    wire [12:0] black_score_y, black_score_x, black_score_yx, black_score_xy;
    wire [12:0] white_score_y, white_score_x, white_score_yx, white_score_xy;
    
    wire [12:0] black_score, white_score;
    assign black_score = black_score_y + black_score_x +
                         black_score_yx + black_score_xy;
    assign white_score = white_score_y + white_score_x +
                         white_score_yx + white_score_xy;
    
    score_calculator
        calc_black_y(
            .my(black_y),
            .op(white_y),
            .score(black_score_y)
        ),
        calc_black_x(
            .my(black_x),
            .op(white_x),
            .score(black_score_x)
        ),
        calc_black_yx(
            .my(black_yx),
            .op(white_yx),
            .score(black_score_yx)
        ),
        calc_black_xy(
            .my(black_xy),
            .op(white_xy),
            .score(black_score_xy)
        ),
        calc_white_y(
            .my(white_y),
            .op(black_y),
            .score(white_score_y)
        ),
        calc_white_x(
            .my(white_x),
            .op(black_x),
            .score(white_score_x)
        ),
        calc_white_yx(
            .my(white_yx),
            .op(black_yx),
            .score(white_score_yx)
        ),
        calc_white_xy(
            .my(white_xy),
            .op(black_xy),
            .score(white_score_xy)
        );
    

    always @ (posedge clk or negedge rst) begin
        if (!rst || clr) begin
            get_y <= 4'b0;
            get_x <= 4'b0;
            black_best_score <= 0;
            black_best_y <= BOARD_SIZE / 2;
            black_best_x <= BOARD_SIZE / 2;
            white_best_score <= 0;
            white_best_y <= BOARD_SIZE / 2;
            white_best_x <= BOARD_SIZE / 2;
            
            state <= IDLE;
        end
        else if (!active && state == IDLE)
            state <= WORKING;
        else if (active && state == WORKING) begin
            if ((get_y == 4'b0 && get_x == 4'b0) ||
                black_score > black_best_score ||
                (black_score == black_best_score && random)) begin
                black_best_score <= black_score;
                black_best_y <= get_y;
                black_best_x <= get_x;
            end
            if ((get_y == 4'b0 && get_x == 4'b0) ||
                white_score > white_best_score ||
                (white_score == white_best_score && random)) begin
                white_best_score <= white_score;
                white_best_y <= get_y;
                white_best_x <= get_x;
            end
            
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
