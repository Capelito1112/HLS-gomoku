`timescale 1ns / 1ps

module gomoku_datapath(
    input wire clk,                      
    input wire rst,                      
    input wire clr,                      
    
    input wire write,                    
    input wire [3:0] write_y,            
    input wire [3:0] write_x,
    input wire write_color,              
    
    input wire [3:0] logic_y,            
    input wire [3:0] display_y,          
    input wire [3:0] consider_y,         
    input wire [3:0] consider_x,         
    
    output wire [14:0] logic_row,        
    output wire [14:0] display_black,    
    output wire [14:0] display_white,
    output reg [8:0] black_y,            
    output reg [8:0] black_x,            
    output reg [8:0] black_yx,           
    output reg [8:0] black_xy,           
    output reg [8:0] white_y,
    output reg [8:0] white_x,
    output reg [8:0] white_yx,
    output reg [8:0] white_xy
    );
    
    // Side parameters
    localparam BLACK = 1'b0,
               WHITE = 1'b1;
    
    localparam BOARD_SIZE = 15;
    
    reg [14:0] board_black [14:0];
    reg [14:0] board_white [14:0];
    
    integer y, x;
    reg [14:0] row_4b, row_3b, row_2b, row_1b, row0b,
               row1b, row2b, row3b, row4b;
    reg [14:0] row_4w, row_3w, row_2w, row_1w, row0w,
               row1w, row2w, row3w, row4w;
    
    assign logic_row = board_black[logic_y] | board_white[logic_y];
    assign display_black = board_black[display_y];
    assign display_white = board_white[display_y];
    
    always @ (negedge clk or negedge rst) begin
        if (!rst || clr) begin
            board_black[0] <= 15'b0;
            board_black[1] <= 15'b0;
            board_black[2] <= 15'b0;
            board_black[3] <= 15'b0;
            board_black[4] <= 15'b0;
            board_black[5] <= 15'b0;
            board_black[6] <= 15'b0;
            board_black[7] <= 15'b0;
            board_black[8] <= 15'b0;
            board_black[9] <= 15'b0;
            board_black[10] <= 15'b0;
            board_black[11] <= 15'b0;
            board_black[12] <= 15'b0;
            board_black[13] <= 15'b0;
            board_black[14] <= 15'b0;
            
            board_white[0] <= 15'b0;
            board_white[1] <= 15'b0;
            board_white[2] <= 15'b0;
            board_white[3] <= 15'b0;
            board_white[4] <= 15'b0;
            board_white[5] <= 15'b0;
            board_white[6] <= 15'b0;
            board_white[7] <= 15'b0;
            board_white[8] <= 15'b0;
            board_white[9] <= 15'b0;
            board_white[10] <= 15'b0;
            board_white[11] <= 15'b0;
            board_white[12] <= 15'b0;
            board_white[13] <= 15'b0;
            board_white[14] <= 15'b0;
        end
        else if (write)
            if (write_color == BLACK)
                board_black[write_y] <= board_black[write_y] |
                                        (15'b1 << write_x);
            else
                board_white[write_y] <= board_white[write_y] |
                                        (15'b1 << write_x);
    end
    
    always @ (*) begin        
        y = consider_y;
        x = consider_x;
        
        if (y - 4 >= 0) begin
            row_4b = board_black[y - 4];
            row_4w = board_white[y - 4];
        end
        else begin
            row_4b = 15'b0;
            row_4w = 15'b0;
        end
        
        if (y - 3 >= 0) begin
            row_3b = board_black[y - 3];
            row_3w = board_white[y - 3];
        end
        else begin
            row_3b = 15'b0;
            row_3w = 15'b0;
        end
        
        if (y - 2 >= 0) begin
            row_2b = board_black[y - 2];
            row_2w = board_white[y - 2];
        end
        else begin
            row_2b = 15'b0;
            row_2w = 15'b0;
        end
        
        if (y - 1 >= 0) begin
            row_1b = board_black[y - 1];
            row_1w = board_white[y - 1];
        end
        else begin
            row_1b = 15'b0;
            row_1w = 15'b0;
        end
        
        if (y >= 0 && y < BOARD_SIZE) begin
            row0b = board_black[y];
            row0w = board_white[y];
        end
        else begin
            row0b = 15'b0;
            row0w = 15'b0;
        end
        
        if (y + 1 < BOARD_SIZE) begin
            row1b = board_black[y + 1];
            row1w = board_white[y + 1];
        end
        else begin
            row1b = 15'b0;
            row1w = 15'b0;
        end
        
        if (y + 2 < BOARD_SIZE) begin
            row2b = board_black[y + 2];
            row2w = board_white[y + 2];
        end
        else begin
            row2b = 15'b0;
            row2w = 15'b0;
        end
        
        if (y + 3 < BOARD_SIZE) begin
            row3b = board_black[y + 3];
            row3w = board_white[y + 3];
        end
        else begin
            row3b = 15'b0;
            row3w = 15'b0;
        end
        
        if (y + 4 < BOARD_SIZE) begin
            row4b = board_black[y + 4];
            row4w = board_white[y + 4];
        end
        else begin
            row4b = 15'b0;
            row4w = 15'b0;
        end

        if (x - 4 >= 0) begin
            black_y[0] = row0b[x - 4];
            white_y[0] = row0w[x - 4];
            black_yx[0] = row_4b[x - 4];
            white_yx[0] = row_4w[x - 4];
            black_xy[0] = row4b[x - 4];
            white_xy[0] = row4w[x - 4];
        end
        else begin
            black_y[0] = 1'b0;
            white_y[0] = 1'b0;
            black_yx[0] = 1'b0;
            white_yx[0] = 1'b0;
            black_xy[0] = 1'b0;
            white_xy[0] = 1'b0;
        end
        
        if (x - 3 >= 0) begin
            black_y[1] = row0b[x - 3];
            white_y[1] = row0w[x - 3];
            black_yx[1] = row_3b[x - 3];
            white_yx[1] = row_3w[x - 3];
            black_xy[1] = row3b[x - 3];
            white_xy[1] = row3w[x - 3];
        end
        else begin
            black_y[1] = 1'b0;
            white_y[1] = 1'b0;
            black_yx[1] = 1'b0;
            white_yx[1] = 1'b0;
            black_xy[1] = 1'b0;
            white_xy[1] = 1'b0;
        end
        
        if (x - 2 >= 0) begin
            black_y[2] = row0b[x - 2];
            white_y[2] = row0w[x - 2];
            black_yx[2] = row_2b[x - 2];
            white_yx[2] = row_2w[x - 2];
            black_xy[2] = row2b[x - 2];
            white_xy[2] = row2w[x - 2];
        end
        else begin
            black_y[2] = 1'b0;
            white_y[2] = 1'b0;
            black_yx[2] = 1'b0;
            white_yx[2] = 1'b0;
            black_xy[2] = 1'b0;
            white_xy[2] = 1'b0;
        end
        
        if (x - 1 >= 0) begin
            black_y[3] = row0b[x - 1];
            white_y[3] = row0w[x - 1];
            black_yx[3] = row_1b[x - 1];
            white_yx[3] = row_1w[x - 1];
            black_xy[3] = row1b[x - 1];
            white_xy[3] = row1w[x - 1];
        end
        else begin
            black_y[3] = 1'b0;
            white_y[3] = 1'b0;
            black_yx[3] = 1'b0;
            white_yx[3] = 1'b0;
            black_xy[3] = 1'b0;
            white_xy[3] = 1'b0;
        end
        
        if (x >= 0 && x < BOARD_SIZE) begin
            black_y[4] = row0b[x];
            white_y[4] = row0w[x];
            black_yx[4] = row0b[x];
            white_yx[4] = row0w[x];
            black_xy[4] = row0b[x];
            white_xy[4] = row0w[x];
            
            black_x[0] = row_4b[x];
            black_x[1] = row_3b[x];
            black_x[2] = row_2b[x];
            black_x[3] = row_1b[x];
            black_x[4] = row0b[x];
            black_x[5] = row1b[x];
            black_x[6] = row2b[x];
            black_x[7] = row3b[x];
            black_x[8] = row4b[x];
            white_x[0] = row_4w[x];
            white_x[1] = row_3w[x];
            white_x[2] = row_2w[x];
            white_x[3] = row_1w[x];
            white_x[4] = row0w[x];
            white_x[5] = row1w[x];
            white_x[6] = row2w[x];
            white_x[7] = row3w[x];
            white_x[8] = row4w[x];
        end
        else begin
            black_y[4] = 1'b0;
            white_y[4] = 1'b0;
            black_yx[4] = 1'b0;
            white_yx[4] = 1'b0;
            black_xy[4] = 1'b0;
            white_xy[4] = 1'b0;
            
            black_x[0] = 1'b0;
            black_x[1] = 1'b0;
            black_x[2] = 1'b0;
            black_x[3] = 1'b0;
            black_x[4] = 1'b0;
            black_x[5] = 1'b0;
            black_x[6] = 1'b0;
            black_x[7] = 1'b0;
            black_x[8] = 1'b0;
            white_x[0] = 1'b0;
            white_x[1] = 1'b0;
            white_x[2] = 1'b0;
            white_x[3] = 1'b0;
            white_x[4] = 1'b0;
            white_x[5] = 1'b0;
            white_x[6] = 1'b0;
            white_x[7] = 1'b0;
            white_x[8] = 1'b0;
        end
        
        if (x + 1 < BOARD_SIZE) begin
            black_y[5] = row0b[x + 1];
            white_y[5] = row0w[x + 1];
            black_yx[5] = row1b[x + 1];
            white_yx[5] = row1w[x + 1];
            black_xy[5] = row_1b[x + 1];
            white_xy[5] = row_1w[x + 1];
        end
        else begin
            black_y[5] = 1'b0;
            white_y[5] = 1'b0;
            black_yx[5] = 1'b0;
            white_yx[5] = 1'b0;
            black_xy[5] = 1'b0;
            white_xy[5] = 1'b0;
        end
        
        if (x + 2 < BOARD_SIZE) begin
            black_y[6] = row0b[x + 2];
            white_y[6] = row0w[x + 2];
            black_yx[6] = row2b[x + 2];
            white_yx[6] = row2w[x + 2];
            black_xy[6] = row_2b[x + 2];
            white_xy[6] = row_2w[x + 2];
        end
        else begin
            black_y[6] = 1'b0;
            white_y[6] = 1'b0;
            black_yx[6] = 1'b0;
            white_yx[6] = 1'b0;
            black_xy[6] = 1'b0;
            white_xy[6] = 1'b0;
        end
        
        if (x + 3 < BOARD_SIZE) begin
            black_y[7] = row0b[x + 3];
            white_y[7] = row0w[x + 3];
            black_yx[7] = row3b[x + 3];
            white_yx[7] = row3w[x + 3];
            black_xy[7] = row_3b[x + 3];
            white_xy[7] = row_3w[x + 3];
        end
        else begin
            black_y[7] = 1'b0;
            white_y[7] = 1'b0;
            black_yx[7] = 1'b0;
            white_yx[7] = 1'b0;
            black_xy[7] = 1'b0;
            white_xy[7] = 1'b0;
        end
        
        if (x + 4 < BOARD_SIZE) begin
            black_y[8] = row0b[x + 4];
            white_y[8] = row0w[x + 4];
            black_yx[8] = row4b[x + 4];
            white_yx[8] = row4w[x + 4];
            black_xy[8] = row_4b[x + 4];
            white_xy[8] = row_4w[x + 4];
        end
        else begin
            black_y[8] = 1'b0;
            white_y[8] = 1'b0;
            black_yx[8] = 1'b0;
            white_yx[8] = 1'b0;
            black_xy[8] = 1'b0;
            white_xy[8] = 1'b0;
        end
    end
    
endmodule
