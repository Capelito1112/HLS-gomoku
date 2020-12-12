`timescale 1ns / 1ps

module vga_display(
    input wire clk,
    input wire rst,              
    
    input wire [3:0] cursor_y,          
    input wire [3:0] cursor_x,
    input wire black_is_player,         
    input wire white_is_player,        
    input wire crt_player,              
    input wire game_running,            
    input wire [1:0] winner,        
    
    input wire [14:0] display_black,   
    input wire [14:0] display_white,
    
    output wire [3:0] display_y,        
    output wire sync_h,                
    output wire sync_v,                
    output wire [3:0] r,               
    output wire [3:0] g,               
    output wire [3:0] b                
    );
    
    // Side parameters
    localparam BLACK = 1'b0,
               WHITE = 1'b1;
    
    localparam BOARD_SIZE = 15,
               GRID_SIZE = 29,
               GRID_X_BEGIN = 30,
               GRID_X_END = 464,
               GRID_Y_BEGIN = 35,
               GRID_Y_END = 469;
    
    localparam SIDE_BLACK_X_BEGIN = 545,
               SIDE_BLACK_X_END = 616,
               SIDE_BLACK_Y_BEGIN = 432,
               SIDE_BLACK_Y_END = 450,
               SIDE_WHITE_X_BEGIN = 545,
               SIDE_WHITE_X_END = 616,
               SIDE_WHITE_Y_BEGIN = 452,
               SIDE_WHITE_Y_END = 470;
    
    localparam CRT_BLACK_X_BEGIN = 510,
               CRT_BLACK_X_END = 541,
               CRT_BLACK_Y_BEGIN = 435,
               CRT_BLACK_Y_END = 448,
               CRT_WHITE_X_BEGIN = 510,
               CRT_WHITE_X_END = 541,
               CRT_WHITE_Y_BEGIN = 455,
               CRT_WHITE_Y_END = 468;
    
    localparam TITLE_X_BEGIN = 530,
               TITLE_X_END = 615,
               TITLE_Y_BEGIN = 30,
               TITLE_Y_END = 423;
    
    localparam RES_X_BEGIN = 115,
               RES_X_END = 380,
               RES_Y_BEGIN = 3,
               RES_Y_END = 30;
               
    localparam INST_X_BEGIN = 1,
               INST_X_END = 605,
               INST_Y_BEGIN = 1,
               INST_Y_END = 30;
    reg sig;
    reg [25:0] count;
    parameter count_1s = 26'd24999999;
    
    always @( posedge clk) begin
        if(count == count_1s)
            count <= 26'b0;
        else
            count <= count + 26'b1;
    end
    always @( posedge clk) begin
        if (count == count_1s)
            sig <= !sig;
        else
            sig <= sig;
    end
               
    
    

    wire video_on;
    wire [9:0] x, y;
    vga_sync
        sync(
            .clk(clk),
            .rst(rst),
            .sync_h(sync_h),
            .sync_v(sync_v),
            .video_on(video_on),
            .x(x),
            .y(y)
        );
    
    reg [11:0] rgb;
    assign r = video_on ? rgb[11:8] : 4'b0;
    assign g = video_on ? rgb[7:4]  : 4'b0;
    assign b = video_on ? rgb[3:0]  : 4'b0;
    
    reg [3:0] row, col;
    integer delta_x, delta_y;
    assign display_y = row < BOARD_SIZE ? row : 4'b0;
    
    wire [28:0] chess_piece_data;
    pic_chess_piece chess_piece(x >= GRID_X_BEGIN && x <= GRID_X_END &&
                                y >= GRID_Y_BEGIN && y <= GRID_Y_END,
                                delta_y + GRID_SIZE/2, chess_piece_data);
    
    wire [71:0] black_player_data, black_ai_data,
                white_player_data, white_ai_data;
    pic_side_player black_player(x >= SIDE_BLACK_X_BEGIN &&
                                 x <= SIDE_BLACK_X_END &&
                                 y >= SIDE_BLACK_Y_BEGIN &&
                                 y <= SIDE_BLACK_Y_END,
                                 y - SIDE_BLACK_Y_BEGIN, black_player_data),
                    white_player(x >= SIDE_WHITE_X_BEGIN &&
                                 x <= SIDE_WHITE_X_END &&
                                 y >= SIDE_WHITE_Y_BEGIN &&
                                 y <= SIDE_WHITE_Y_END,
                                 y - SIDE_WHITE_Y_BEGIN, white_player_data);
    pic_side_ai black_ai(x >= SIDE_BLACK_X_BEGIN && x <= SIDE_BLACK_X_END &&
                         y >= SIDE_BLACK_Y_BEGIN && y <= SIDE_BLACK_Y_END,
                         y - SIDE_BLACK_Y_BEGIN, black_ai_data),
                white_ai(x >= SIDE_WHITE_X_BEGIN && x <= SIDE_WHITE_X_END &&
                         y >= SIDE_WHITE_Y_BEGIN && y <= SIDE_WHITE_Y_END,
                         y - SIDE_WHITE_Y_BEGIN, white_ai_data);
    
    wire [31:0] black_ptr_data, white_ptr_data;
    pic_crt_ptr black_ptr(x >= CRT_BLACK_X_BEGIN && x <= CRT_BLACK_X_END &&
                          y >= CRT_BLACK_Y_BEGIN && y <= CRT_BLACK_Y_END,
                          y - CRT_BLACK_Y_BEGIN, black_ptr_data),
                white_ptr(x >= CRT_WHITE_X_BEGIN && x <= CRT_WHITE_X_END &&
                          y >= CRT_WHITE_Y_BEGIN && y <= CRT_WHITE_Y_END,
                          y - CRT_WHITE_Y_BEGIN, white_ptr_data);
    
    wire [85:0] title_data;
    pic_title title(x >= TITLE_X_BEGIN && x <= TITLE_X_END &&
                    y >= TITLE_Y_BEGIN && y <= TITLE_Y_END,
                    y - TITLE_Y_BEGIN, title_data);
                    
    wire [85:0] win_data;
    pic_win win(x >= TITLE_X_BEGIN && x <= TITLE_X_END &&
                    y >= TITLE_Y_BEGIN && y <= TITLE_Y_END,
                    y - TITLE_Y_BEGIN, win_data);
    
    wire [265:0] black_wins_data, white_wins_data, res_draw_data;
    pic_black_wins black_wins(x >= RES_X_BEGIN && x <= RES_X_END &&
                              y >= RES_Y_BEGIN && y <= RES_Y_END,
                              y - RES_Y_BEGIN, black_wins_data);
    pic_white_wins white_wins(x >= RES_X_BEGIN && x <= RES_X_END &&
                              y >= RES_Y_BEGIN && y <= RES_Y_END,
                              y - RES_Y_BEGIN, white_wins_data);
    pic_res_draw res_draw(x >= RES_X_BEGIN && x <= RES_X_END &&
                          y >= RES_Y_BEGIN && y <= RES_Y_END,
                          y - RES_Y_BEGIN, res_draw_data);
    
    wire [604:0] inst_data;
    pic_inst_draw inst_draw(x >= INST_X_BEGIN && x <= INST_X_END &&
                          y >= INST_Y_BEGIN && y <= INST_Y_END,
                          y - INST_Y_BEGIN, inst_data);
   
    always @ (x or y) begin
        if (y >= GRID_Y_BEGIN &&
            y < GRID_Y_BEGIN + GRID_SIZE)
            row = 4'b0000;
        else if (y >= GRID_Y_BEGIN + GRID_SIZE &&
                 y < GRID_Y_BEGIN + GRID_SIZE*2)
            row = 4'b0001;
        else if (y >= GRID_Y_BEGIN + GRID_SIZE*2 &&
                 y < GRID_Y_BEGIN + GRID_SIZE*3)
            row = 4'b0010;
        else if (y >= GRID_Y_BEGIN + GRID_SIZE*3 &&
                 y < GRID_Y_BEGIN + GRID_SIZE*4)
            row = 4'b0011;
        else if (y >= GRID_Y_BEGIN + GRID_SIZE*4 &&
                 y < GRID_Y_BEGIN + GRID_SIZE*5)
            row = 4'b0100;
        else if (y >= GRID_Y_BEGIN + GRID_SIZE*5 &&
                 y < GRID_Y_BEGIN + GRID_SIZE*6)
            row = 4'b0101;
        else if (y >= GRID_Y_BEGIN + GRID_SIZE*6 &&
                 y < GRID_Y_BEGIN + GRID_SIZE*7)
            row = 4'b0110;
        else if (y >= GRID_Y_BEGIN + GRID_SIZE*7 &&
                 y < GRID_Y_BEGIN + GRID_SIZE*8)
            row = 4'b0111;
        else if (y >= GRID_Y_BEGIN + GRID_SIZE*8 &&
                 y < GRID_Y_BEGIN + GRID_SIZE*9)
            row = 4'b1000;
        else if (y >= GRID_Y_BEGIN + GRID_SIZE*9 &&
                 y < GRID_Y_BEGIN + GRID_SIZE*10)
            row = 4'b1001;
        else if (y >= GRID_Y_BEGIN + GRID_SIZE*10 &&
                 y < GRID_Y_BEGIN + GRID_SIZE*11)
            row = 4'b1010;
        else if (y >= GRID_Y_BEGIN + GRID_SIZE*11 &&
                 y < GRID_Y_BEGIN + GRID_SIZE*12)
            row = 4'b1011;
        else if (y >= GRID_Y_BEGIN + GRID_SIZE*12 &&
                 y < GRID_Y_BEGIN + GRID_SIZE*13)
            row = 4'b1100;
        else if (y >= GRID_Y_BEGIN + GRID_SIZE*13 &&
                 y < GRID_Y_BEGIN + GRID_SIZE*14)
            row = 4'b1101;
        else if (y >= GRID_Y_BEGIN + GRID_SIZE*14 &&
                 y < GRID_Y_BEGIN + GRID_SIZE*15)
            row = 4'b1110;
        else
            row = 4'b1111;
        
        if (x >= GRID_X_BEGIN &&
            x < GRID_X_BEGIN + GRID_SIZE)
            col = 4'b0000;
        else if (x >= GRID_X_BEGIN + GRID_SIZE &&
                 x < GRID_X_BEGIN + GRID_SIZE*2)
            col = 4'b0001;
        else if (x >= GRID_X_BEGIN + GRID_SIZE*2 &&
                 x < GRID_X_BEGIN + GRID_SIZE*3)
            col = 4'b0010;
        else if (x >= GRID_X_BEGIN + GRID_SIZE*3 &&
                 x < GRID_X_BEGIN + GRID_SIZE*4)
            col = 4'b0011;
        else if (x >= GRID_X_BEGIN + GRID_SIZE*4 &&
                 x < GRID_X_BEGIN + GRID_SIZE*5)
            col = 4'b0100;
        else if (x >= GRID_X_BEGIN + GRID_SIZE*5 &&
                 x < GRID_X_BEGIN + GRID_SIZE*6)
            col = 4'b0101;
        else if (x >= GRID_X_BEGIN + GRID_SIZE*6 &&
                 x < GRID_X_BEGIN + GRID_SIZE*7)
            col = 4'b0110;
        else if (x >= GRID_X_BEGIN + GRID_SIZE*7 &&
                 x < GRID_X_BEGIN + GRID_SIZE*8)
            col = 4'b0111;
        else if (x >= GRID_X_BEGIN + GRID_SIZE*8 &&
                 x < GRID_X_BEGIN + GRID_SIZE*9)
            col = 4'b1000;
        else if (x >= GRID_X_BEGIN + GRID_SIZE*9 &&
                 x < GRID_X_BEGIN + GRID_SIZE*10)
            col = 4'b1001;
        else if (x >= GRID_X_BEGIN + GRID_SIZE*10 &&
                 x < GRID_X_BEGIN + GRID_SIZE*11)
            col = 4'b1010;
        else if (x >= GRID_X_BEGIN + GRID_SIZE*11 &&
                 x < GRID_X_BEGIN + GRID_SIZE*12)
            col = 4'b1011;
        else if (x >= GRID_X_BEGIN + GRID_SIZE*12 &&
                 x < GRID_X_BEGIN + GRID_SIZE*13)
            col = 4'b1100;
        else if (x >= GRID_X_BEGIN + GRID_SIZE*13 &&
                 x < GRID_X_BEGIN + GRID_SIZE*14)
            col = 4'b1101;
        else if (x >= GRID_X_BEGIN + GRID_SIZE*14 &&
                 x < GRID_X_BEGIN + GRID_SIZE*15)
            col = 4'b1110;
        else
            col = 4'b1111;
        
        delta_x = GRID_X_BEGIN + col*GRID_SIZE + GRID_SIZE/2 - x;
        delta_y = GRID_Y_BEGIN + row*GRID_SIZE + GRID_SIZE/2 - y;
    end
    
    always @ (posedge clk) begin
        if (x >= GRID_X_BEGIN && x <= GRID_X_END &&
            y >= GRID_Y_BEGIN && y <= GRID_Y_END) begin
             if (display_black[col] &&
                chess_piece_data[delta_x + GRID_SIZE/2])
                rgb <= 12'h000;
            else if (display_white[col] &&
                     chess_piece_data[delta_x + GRID_SIZE/2])
                rgb <= 12'hfff;
            else if (row == cursor_y && col == cursor_x &&
                    (delta_x == GRID_SIZE/2 || delta_x == -(GRID_SIZE/2) ||
                     delta_y == GRID_SIZE/2 || delta_y == -(GRID_SIZE/2)))
                rgb <= 12'hf00;
            else if (delta_x == 0 || delta_y == 0)
                rgb <= 12'hda6;
            else if (delta_x == 1 || delta_y == 1)
                rgb <= 12'h751;
            else
                rgb <= 12'hc81;
        end
        else if (x >= CRT_BLACK_X_BEGIN && x <= CRT_BLACK_X_END &&
                 y >= CRT_BLACK_Y_BEGIN && y <= CRT_BLACK_Y_END) begin
            rgb <= game_running && crt_player == BLACK && 
                   black_ptr_data[CRT_BLACK_X_END - x] ? 12'h000 : 12'hc81;
        end
        else if (x >= CRT_WHITE_X_BEGIN && x <= CRT_WHITE_X_END &&
                 y >= CRT_WHITE_Y_BEGIN && y <= CRT_WHITE_Y_END) begin
            rgb <= game_running && crt_player == WHITE && 
                   white_ptr_data[CRT_WHITE_X_END - x] ? 12'hfff : 12'hc81;
        end
        else if (x >= SIDE_BLACK_X_BEGIN && x <= SIDE_BLACK_X_END &&
                 y >= SIDE_BLACK_Y_BEGIN && y <= SIDE_BLACK_Y_END) begin
            if (black_is_player)
                rgb <= black_player_data[SIDE_BLACK_X_END - x] ?
                       12'h000 : 12'hc81;
            else
                rgb <= black_ai_data[SIDE_BLACK_X_END - x] ? 12'h000 : 12'hc81;
        end
        else if (x >= SIDE_WHITE_X_BEGIN && x <= SIDE_WHITE_X_END &&
                 y >= SIDE_WHITE_Y_BEGIN && y <= SIDE_WHITE_Y_END) begin
            if (white_is_player)
                rgb <= white_player_data[SIDE_WHITE_X_END - x] ? 
                       12'hfff : 12'hc81;
            else
                rgb <= white_ai_data[SIDE_WHITE_X_END - x] ? 12'hfff : 12'hc81;
        end
        else if (x >= TITLE_X_BEGIN && x <= TITLE_X_END &&
                 y >= TITLE_Y_BEGIN && y <= TITLE_Y_END) begin
                    if (winner == 2'b00) 
                        rgb <= (title_data[TITLE_X_END - x]) ? 12'hade : 12'hc81;
                    else
                        rgb <= (win_data[TITLE_X_END - x]) ? 12'hade : 12'hc81;
        end
        else if (x >= INST_X_BEGIN && x <= INST_X_END &&
                 y >= INST_Y_BEGIN && y <= INST_Y_END) begin
                    if (game_running == 0)
                        rgb <= inst_data[INST_X_END-x] ? 12'hade & {12{sig}}:12'hc81;
                    else if (x >= RES_X_BEGIN && x <= RES_X_END &&
                             y >= RES_Y_BEGIN && y <= RES_Y_END) begin
                        case (winner)
                        2'b00: rgb <= 12'hc81;
                        2'b01: rgb <= black_wins_data[RES_X_END - x] ? 12'h000 : 12'hc81;
                        2'b10: rgb <= white_wins_data[RES_X_END - x] ? 12'hfff : 12'hc81;
                        2'b11: rgb <= res_draw_data[RES_X_END - x] ? 12'hfff : 12'hc81;
                        endcase
                        end
                        else
                            rgb <= 12'hc81;
        end
        else
            rgb <= 12'hc81;
    end

endmodule
