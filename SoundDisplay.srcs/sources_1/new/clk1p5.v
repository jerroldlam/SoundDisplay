`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/22/2020 10:09:57 PM
// Design Name: 
// Module Name: clk1p5
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

//frequency: 1.5 Hz
module clk1p5(
    input CLOCK,
    output reg frequency = 1'b1
    );
    reg [25:0] COUNT =0;
    always @ (posedge CLOCK) begin
        COUNT <= COUNT + 1;
        frequency <= (COUNT == 0) ? ~frequency : frequency;
        end
endmodule
