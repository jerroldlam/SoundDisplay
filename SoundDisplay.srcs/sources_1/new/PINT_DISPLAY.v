`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/20/2020 01:24:52 PM
// Design Name: 
// Module Name: PINT_DISPLAY
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


module PINT_DISPLAY(
    input CLOCK,
    output reg [6:0]seg=7'b1111111,
    output reg [3:0]an=4'b1111,
    input [15:0] P_in,
    input [1:0]pika,
    input poke_mode
    );
    reg count=0;
    reg [1:0]pika_count=0; 
    
    always @(posedge CLOCK) begin
    count<=count+1;
    if (poke_mode==1) begin
     if (pika==0)begin
        case(P_in)
        1:begin an=4'b1110; seg <= 7'b1000000; end //0
        3:begin an=4'b1110; seg <= 7'b1111001; end //1
        7:begin an=4'b1110; seg <= 7'b0100100; end //2
        15:begin an=4'b1110; seg <= 7'b0110000; end //3
        31:begin an=4'b1110; seg <= 7'b0011001; end //4
        63:begin an=4'b1110; seg <= 7'b0010010; end //5
        127:begin an=4'b1110; seg <= 7'b0000010; end //6
        255:begin an=4'b1110; seg <= 7'b1111000; end //7
        511:begin an=4'b1110; seg <= 7'b0000000; end //8
        1023:begin an=4'b1110; seg <= 7'b0010000; end //9
        2047:begin 
        an <= (count==1)?4'b1110:4'b1101;
        seg <= (count==1)?7'b1000000:7'b1111001;
        end //10
        4095:begin 
        an <= (count==1)?4'b1110:4'b1101;
        seg <=(count==1)?7'b1111001:7'b1111001;
        end //11
        8191:begin 
        an<=(count==1)?4'b1110:4'b1101;
        seg<=(count==1)?7'b0100100:7'b1111001;
        end //12
        16383:begin 
        an<=(count==1)?4'b1110:4'b1101;
        seg<=(count==1)?7'b0110000:7'b1111001;
        end //13
        32767:begin 
        an<=(count==1)?4'b1110:4'b1101;
        seg<=(count==1)?7'b0011001:7'b1111001;
        end //14
        65535:begin 
        an<=(count==1)?4'b1110:4'b1101;
        seg<=(count==1)?7'b0010010:7'b1111001;
        end //15
        endcase
        end// end of normal display
        
        else if (pika==1) begin
        pika_count<=pika_count+1;
        case (pika_count)
        0:begin an<=4'b1110; seg<=7'b0001000;   end //A
        1:begin an<=4'b1101; seg<=7'b0001001;  end //K
        2:begin an<=4'b1011; seg<=7'b1001111;  end //I
        3:begin an<=4'b0111; seg<=7'b0001100;   end //P
        endcase     
        end
        
        else if (pika==2) begin
        pika_count<=pika_count+1;
        case (pika_count)
        0:begin an<=4'b1110; seg<=7'b1000001;  end //U
        1:begin an<=4'b1101; seg<=7'b0001001;  end //H
        2:begin an<=4'b1011; seg<=7'b1000110;  end //C
        default: an<=4'b1111;
        endcase
        end
        
        else if (pika==3) begin
        pika_count<=pika_count+1;
        case (pika_count)
        0:begin an<=4'b1110; seg<=7'b0101011;  end //N
        1:begin an<=4'b1101; seg<=7'b1001111;  end //I
        2:begin an<=4'b1011; seg<=7'b1010101;  end //W
        default: an<=4'b1111;
        endcase
        end
        end//end of poke mode
        
        if (poke_mode==0) begin
                case(P_in)
                1:begin an=4'b1110; seg <= 7'b1000000; end //0 changed here!
                3:begin an=4'b1110; seg <= 7'b1111001; end //1
                7:begin an=4'b1110; seg <= 7'b0100100; end //2;
                15:begin an=4'b1110; seg <= 7'b0110000; end //3
                31:begin an=4'b1110; seg <= 7'b0011001; end //4
                63:begin an=4'b1110; seg <= 7'b0010010; end //5
                127:begin an=4'b1110; seg <= 7'b0000010; end //6
                255:begin an=4'b1110; seg <= 7'b1111000; end //7
                511:begin an=4'b1110; seg <= 7'b0000000; end //8
                1023:begin an=4'b1110; seg <= 7'b0010000; end //9
                2047:begin 
                an <= (count==1)?4'b1110:4'b1101;
                seg <= (count==1)?7'b1000000:7'b1111001;
                end //10
                4095:begin 
                an <= (count==1)?4'b1110:4'b1101;
                seg <=(count==1)?7'b1111001:7'b1111001;
                end //11
                8191:begin 
                an<=(count==1)?4'b1110:4'b1101;
                seg<=(count==1)?7'b0100100:7'b1111001;
                end //12
                16383:begin 
                an<=(count==1)?4'b1110:4'b1101;
                seg<=(count==1)?7'b0110000:7'b1111001;
                end //13
                32767:begin 
                an<=(count==1)?4'b1110:4'b1101;
                seg<=(count==1)?7'b0011001:7'b1111001;
                end //14
                65535:begin 
                an<=(count==1)?4'b1110:4'b1101;
                seg<=(count==1)?7'b0010010:7'b1111001;
                end //15
                endcase
    
        end
        end
        
endmodule
