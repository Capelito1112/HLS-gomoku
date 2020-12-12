`timescale 1ns / 1ps

module score_calculator(
    input wire [8:0] my,       
    input wire [8:0] op,       
    output reg [12:0] score    
    );
    
    wire [8:0] next;
    assign next = my | 9'b000010000;
    
    wire score2, score4, score5, score8, score15,score40, score70, score300, score2000;
    
    pattern_five pattern2000(next, score2000);
    pattern_four pattern300(next, op, score300);
    pattern_ffour pattern70(next, op, score70);    
    pattern_three pattern40(next, op, score40);
    pattern_fthree pattern15(next, op, score15);
    pattern_two pattern8(next, op, score8);
    pattern_sthree pattern5(next, op, score5);
    pattern_ftwo pattern4(next, op, score4);
    pattern_stwo pattern2(next, op, score2);
    
    
    
    always @ (*)
        if (my[4] || op[4])
            score = 0;
        else if (score2000)
            score = 2000;
        else if (score300)
            score = 300;
        else if (score70)
            score = 70;
        else if (score40)
            score = 40;
        else if (score15)
            score = 15;
        else if (score8)
            score = 8;
        else if (score5)
            score = 5;
        else if (score4)
            score = 4;
        else if (score2)
            score = 2;
        else
            score = 1;
    
endmodule
