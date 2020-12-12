`timescale 1ns / 1ps

module gomoku_logic(
    input wire clk_slow,            
    input wire clk_fast,            
    input wire rst,                 
    input wire random,              
    
    input wire key_up,              
    input wire key_down,            
    input wire key_left,            
    input wire key_right,           
    input wire key_ok,              
    input wire key_switch,          
    
    input wire [8:0] black_y,       
    input wire [8:0] black_x,       
    input wire [8:0] black_yx,      
    input wire [8:0] black_xy,      
    input wire [8:0] white_y,
    input wire [8:0] white_x,
    input wire [8:0] white_yx,
    input wire [8:0] white_xy,
    input wire [14:0] chess_row,
    input debug,    
    
    output wire [3:0] consider_y,   
    output wire [3:0] consider_x,   
    
    output reg data_clr,            
    output reg data_write,          
    
    output reg [3:0] cursor_y,      
    output reg [3:0] cursor_x,      
    output reg black_is_player,     
    output reg white_is_player,     
    output reg crt_player,          
    output reg game_running,        
    output reg [1:0] winner         
    );
    
    localparam BLACK = 1'b0,
               WHITE = 1'b1;
    
    localparam BOARD_SIZE = 15;
    
    localparam IDLE = 3'b000,
               MOVE = 3'b001,
               WAIT = 3'b010,
               DECIDE = 3'b011,
               PUT_CHESS = 3'b100,
               PUT_END = 3'b101,
               CHECK = 3'b110,
               GAME_END = 3'b111;
    
    localparam WAIT_TIME = 400;
    localparam WAIT_TIME_DEBUG = 40;
    
    reg [2:0] state;         
    reg [8:0] wait_count;
    reg [7:0] move_count;    
    

    reg strategy_clr, strategy_active;
    wire [3:0] strategy_y, strategy_x;
    wire [12:0] black_best_score;
    wire [3:0] black_best_y, black_best_x;
    wire [12:0] white_best_score;
    wire [3:0] white_best_y, white_best_x;
    gomoku_strategy
        strategy(
            .clk(clk_fast),
            .rst(rst),
            .clr(strategy_clr),
            .active(strategy_active),
            .random(random),
            .black_y(black_y),
            .black_x(black_x),
            .black_yx(black_yx),
            .black_xy(black_xy),
            .white_y(white_y),
            .white_x(white_x),
            .white_yx(white_yx),
            .white_xy(white_xy),
            .get_y(strategy_y),
            .get_x(strategy_x),
            .black_best_score(black_best_score),
            .black_best_y(black_best_y),
            .black_best_x(black_best_x),
            .white_best_score(white_best_score),
            .white_best_y(white_best_y),
            .white_best_x(white_best_x)
        );
    

    reg win_clr, win_active;
    wire [3:0] win_y, win_x;
    wire is_win;
    win_checker
        checker(
            .clk(clk_fast),
            .rst(rst),
            .clr(win_clr),
            .active(win_active),
            .black_y(black_y),
            .black_x(black_x),
            .black_yx(black_yx),
            .black_xy(black_xy),
            .white_y(white_y),
            .white_x(white_x),
            .white_yx(white_yx),
            .white_xy(white_xy),
            .get_y(win_y),
            .get_x(win_x),
            .is_win(is_win)
        );
    
    assign consider_y = strategy_y | win_y;
    assign consider_x = strategy_x | win_x;
    
    always @ (posedge clk_slow or negedge rst) begin
        if (!rst) begin
            cursor_y <= BOARD_SIZE;
            cursor_x <= BOARD_SIZE;
            {white_is_player, black_is_player} <= 2'b01;
            crt_player <= BLACK;
            game_running <= 1'b0;
            winner <= 2'b00;
            
            state <= IDLE;
            move_count <= 8'b0;
            data_clr <= 1'b0;
            data_write <= 1'b0;
            strategy_clr <= 1'b0;
            strategy_active <= 1'b0;
            win_clr <= 1'b0;
            win_active <= 1'b0;
        end
        else begin
            case (state)
            IDLE:
                if (key_ok) begin
                    cursor_y <= BOARD_SIZE/2;
                    cursor_x <= BOARD_SIZE/2;
                    crt_player <= BLACK;
                    game_running <= 1'b1;
                    winner <= 2'b00;                 
                    state <= MOVE;
                    move_count <= 8'b0;
                    data_clr <= 1'b1;
                    strategy_clr <= 1'b1;
                    win_clr <= 1'b1;
                end
                else if (key_switch)
                    {white_is_player, black_is_player} <= 
                    {white_is_player, black_is_player} + 2'b1;
                else
                    state <= IDLE;
            
            MOVE: begin
                data_clr <= 1'b0;
                strategy_clr <= 1'b0;
                win_clr <= 1'b0;
                
                if ((crt_player == BLACK && black_is_player) ||
                    (crt_player == WHITE && white_is_player)) begin

                    if (key_up && cursor_y > 0)
                        cursor_y <= cursor_y - 1'b1;
                    else if (key_down && cursor_y < BOARD_SIZE - 1)
                        cursor_y <= cursor_y + 1'b1;
                    if (key_left && cursor_x > 0)
                        cursor_x <= cursor_x - 1'b1;
                    else if (key_right && cursor_x < BOARD_SIZE - 1)
                        cursor_x <= cursor_x + 1'b1;
                        
                    if (key_ok)
                        state <= PUT_CHESS;
                end
                else begin
                    strategy_active <= 1'b1;
                    state <= WAIT;
                    wait_count <= 0;
                end
            end
            
            WAIT:
                if (debug == 0) begin
                    if (wait_count >= WAIT_TIME)
                        state <= DECIDE;
                    else
                        wait_count <= wait_count + 1'b1;
                end
                else begin
                    if (wait_count >= WAIT_TIME_DEBUG)
                        state <= DECIDE;
                    else
                        wait_count <= wait_count + 1'b1;
                end
            
            DECIDE: begin
                strategy_active <= 1'b0;
                if (black_best_score > white_best_score ||
                    (black_best_score == white_best_score &&
                    crt_player == BLACK)) begin
                    cursor_y <= black_best_y;
                    cursor_x <= black_best_x;
                end
                else begin
                    cursor_y <= white_best_y;
                    cursor_x <= white_best_x;
                end
                
                state <= PUT_CHESS;
            end
            
            PUT_CHESS:
                if (!chess_row[cursor_x]) begin
                    move_count <= move_count + 8'b1;
                    data_write <= 1'b1;
                    state <= PUT_END;
                end
                else
                    state <= MOVE;
            
            PUT_END: begin
                data_write <= 1'b0;
                win_active <= 1'b1;
                state <= CHECK;
            end
            
            CHECK: begin
                win_active <= 1'b0;
                if (is_win || move_count == BOARD_SIZE * BOARD_SIZE)
                    state <= GAME_END;
                else begin
                    crt_player <= ~crt_player;
                    state <= MOVE;
                end
            end
            
            GAME_END: begin
                if (is_win)
                    winner <= 2'b01 << crt_player;
                else
                    winner <= 2'b11;
                
                if(key_ok)begin
                    state <= IDLE;
                    game_running <= 1'b0;
                end
                else begin
                    state <= GAME_END;
                
                end
                end
            
            endcase
        end
    end
    
endmodule
