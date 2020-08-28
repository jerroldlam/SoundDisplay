`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.03.2020 18:55:51
// Design Name: 
// Module Name: CLK_INT
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


module CLK_INT(
    input CLOCK,
    output CLKINT
    );
    reg [19:0]count;
    always @(posedge CLOCK) begin
    count<=count+1;
    end
    assign CLKINT=count[19];
endmodule
