`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/12/2020 11:00:09 AM
// Design Name: 
// Module Name: clk20k
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


module clk20k(
    input CLOCK,
    output reg clk20k = 0
    );
    
    reg [12:0]count=0;
    
    always @ (posedge CLOCK) begin
    count <= count +1;
    clk20k <= (count==2500) ? ~clk20k:clk20k;
    if (count==2500) begin
    count<=0;
    end
    end
endmodule
