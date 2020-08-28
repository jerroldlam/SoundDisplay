`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/11/2020 08:00:25 PM
// Design Name: 
// Module Name: debouncer
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


module debouncer(
    input CLOCK,
    input button,
    output pulse
    );
    wire clk; wire A0,A1;
    debounce_clock debounce_clock (CLOCK,clk);
    dff dff0 (clk,button,A0);
    dff dff1 (clk,A0,A1);
    assign pulse = A0 & ~A1;
endmodule

module debounce_clock(
    input CLOCK,
    output reg frequency = 1'b1
    );
    
    reg[3:0] COUNT = 0;
    always @(posedge CLOCK) begin
    COUNT <= COUNT + 1;
    frequency <= (COUNT == 0) ? ~frequency : frequency;
    end
endmodule

module dff(
    input DFF_CLOCK, D, 
    output reg Q = 0);
    
    always @ (posedge DFF_CLOCK) begin
        Q <= D;
    end
endmodule
