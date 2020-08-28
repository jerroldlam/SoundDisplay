`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/11/2020 07:51:57 PM
// Design Name: 
// Module Name: clk6p25m
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

//frequency: 6.25 mHz
module clk6p25m(
    input CLOCK,
    output reg frequency = 1'b1
    );
    reg [3:0] COUNT =0;
    always @ (posedge CLOCK) begin
        COUNT <= COUNT + 1;
        frequency <= (COUNT == 0) ? ~frequency : frequency;
        end
endmodule
