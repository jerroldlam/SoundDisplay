`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/31/2020 10:04:18 AM
// Design Name: 
// Module Name: zap_clock
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


module zap_clock(
    input CLOCK,
    output reg frequency = 1'b1
    );
    reg [20:0] COUNT =0;
        always @ (posedge CLOCK) begin
            COUNT <= COUNT + 1;
            frequency <= (COUNT == 0) ? ~frequency : frequency;
            end
endmodule
