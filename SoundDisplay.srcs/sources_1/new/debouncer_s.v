`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.03.2020 15:16:05
// Design Name: 
// Module Name: debouncer_s
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


module debouncer_s(
    input CLOCK,
    input button,
    output pulse
);
    wire A0,A1;
    dff dff0 (CLOCK,button,A0);
    dff dff1 (CLOCK,A0,A1);
    assign pulse = A0 & ~A1;
endmodule
