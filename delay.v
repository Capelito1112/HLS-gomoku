`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/06/14 11:35:54
// Design Name: 
// Module Name: delay
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


module delay(
    input CLK,
    input RST,
    input in,
    output out);
    reg [25:0] count;
    reg out_r;
    parameter count_s = 26'd200;    
    
    parameter IDLE = 1'b0; 
    parameter RUN = 1'b1;
    reg state; 
    
    always @(posedge CLK) begin
        if(!RST) begin
            count <= 0;
            out_r <= 0;
        end
        else begin 
            case (state)
            IDLE: begin
                    count <= 0;
                    out_r <= 0;
                    if(in)
                        state <= RUN;
                 end
            RUN: begin
                    if (count == count_s) begin
                        count <= 0;
                        out_r <= 1;
                        state <= IDLE;
                    end
                    else begin
                        count <= count + 1;
                        out_r <= 0;
                    end   
                 end
             default:state <= IDLE;
            endcase
        end
    end
assign out = out_r;

endmodule
