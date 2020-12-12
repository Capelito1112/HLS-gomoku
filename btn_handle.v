`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/06/13 14:12:47
// Design Name: 
// Module Name: btn_handle
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


module btn_handle(
    input clk_fast,
    input clk_slow,
    input rst,
    input btnC, 
    input btnR, 
    input btnL, 
    input btnU,
    input btnD, 
    input inswitch,
    output left,
    output right,
    output up,
    output down,
    output center,
    output switch
    );
    

    wire [4:0] db;
    debouncer dbC (clk_fast, rst, btnC, db[0]);
    debouncer dbL (clk_fast, rst, btnL, db[1]);
    debouncer dbR (clk_fast, rst, btnR, db[2]);
    debouncer dbU (clk_fast, rst, btnU, db[3]);
    debouncer dbD (clk_fast, rst, btnD, db[4]);


    pulser eC (clk_slow, rst, db[0], center);
    pulser eL (clk_slow, rst, db[1], left);
    pulser eR (clk_slow, rst, db[2], right);
    pulser eU (clk_slow, rst, db[3], up);
    pulser eD (clk_slow, rst, db[4], down);
    pulser eSwitch (clk_slow, rst, db[3], switch);

    

   
endmodule
