`timescale 1ns / 1ps

module gomoku_top(
    input wire clk,         
    input wire rst,         
    input key_ok,
    input key_left,
    input key_right,
    input key_up,
    input key_down,
    input key_switch,
    input key_debug,
    output wire sync_h,   
    output wire sync_v,   
    output wire [3:0] r,  
    output wire [3:0] g,  
    output wire [3:0] b   
    );
    
    wire left,right,up,down,center,switch,debug;
    
    wire [3:0] consider_y, consider_x, cursor_y, cursor_x;
    wire data_clr, data_write;
    wire black_is_player, white_is_player, crt_player, game_running;
    wire [1:0] winner;
    
    wire [8:0] black_y, black_x, black_yx, black_xy,
               white_y, white_x, white_yx, white_xy;
    wire [14:0] logic_row, display_black, display_white;
    
    wire [3:0] display_y;
    
    wire [31:0] rand_num;
    wire [31:0] clk_div;
    assign debug = key_debug;
    
    btn_handle bh(
    .clk_fast(clk_div[6]),
    .clk_slow(clk_div[16]),
    .rst(rst),
    .btnC(key_ok), 
    .btnR(key_right), 
    .btnL(key_left), 
    .btnU(key_up),
    .btnD(key_down), 
    .inswitch(key_switch),
    .left(left),
    .right(right),
    .up(up),
    .down(down),
    .center(center),
    .switch(switch)
    );
    
    gomoku_logic
        game_logic(
            .clk_slow(clk_div[16]),
            .clk_fast(clk_div[6]),
            .rst(rst),
            .random(rand_num[0]),
            .key_up(up),
            .key_down(down),
            .key_left(left),
            .key_right(right),
            .key_ok(center),
            .key_switch(switch),
            .black_y(black_y),
            .black_x(black_x),
            .black_yx(black_yx),
            .black_xy(black_xy),
            .white_y(white_y),
            .white_x(white_x),
            .white_yx(white_yx),
            .white_xy(white_xy),
            .chess_row(logic_row),
            .debug(debug),
            .consider_y(consider_y),
            .consider_x(consider_x),
            .data_clr(data_clr),
            .data_write(data_write),
            .cursor_y(cursor_y),
            .cursor_x(cursor_x),
            .black_is_player(black_is_player),
            .white_is_player(white_is_player),
            .crt_player(crt_player),
            .game_running(game_running),
            .winner(winner)
        );
    
    gomoku_datapath
        data(
            .clk(clk_div[16]),
            .rst(rst),
            .clr(data_clr),
            .write(data_write),
            .write_y(cursor_y),
            .write_x(cursor_x),
            .write_color(crt_player),
            .logic_y(cursor_y),
            .display_y(display_y),
            .consider_y(consider_y),
            .consider_x(consider_x),
            .logic_row(logic_row),
            .display_black(display_black),
            .display_white(display_white),
            .black_y(black_y),
            .black_x(black_x),
            .black_yx(black_yx),
            .black_xy(black_xy),
            .white_y(white_y),
            .white_x(white_x),
            .white_yx(white_yx),
            .white_xy(white_xy)
        );
    
    
    vga_display
        display(
            .clk(clk_div[1]),
            .rst(rst),
            .cursor_y(cursor_y),
            .cursor_x(cursor_x),
            .black_is_player(black_is_player),
            .white_is_player(white_is_player),
            .crt_player(crt_player),
            .game_running(game_running),
            .winner(winner),
            .display_black(display_black),
            .display_white(display_white),
            .display_y(display_y),
            .sync_h(sync_h),
            .sync_v(sync_v),
            .r(r),
            .g(g),
            .b(b)
        );
    
    random_gen
        rand(
            .clk(clk_div[6]),
            .rst(rst),
            .load(center),
            .seed(clk_div),
            .rand_num(rand_num)
        );
    
    clk_divider
        divider(
            .clk(clk),
            .rst(rst),
            .clk_div(clk_div)
        );
    
endmodule
