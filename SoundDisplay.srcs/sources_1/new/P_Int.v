`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.03.2020 18:47:27
// Design Name: 
// Module Name: P_Int
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


module P_Int(
    input CLOCK,
    input [11:0] Mic_in,
    output reg [15:0] P_in = 0,
    input btnD,
    input poke_mode,
    output reg [1:0] pika=0,
    input btnL,
    input btnR
    );
    wire CLKINT;
    wire pulseD;
    wire volup;
    wire voldown;
    reg [2:0]vol=0;
    reg [3:0]scale=0;
    reg [3:0]count=0;
    reg [5:0]pika_count=0;
    reg [11:0]max=0;
    reg [4:0] HP = 16;
    CLK_INT (CLOCK,CLKINT);
    debouncer_s pulse0(CLKINT,btnD,pulseD);
    debouncer_s pulse1(CLKINT,btnL,volup);
    debouncer_s pulse2(CLKINT,btnR,voldown);
    
    always @(posedge CLKINT) begin
    //256 each led
    count<= count+1;
    if(max<Mic_in) begin
    max=Mic_in;
    end
    if ((count== 15 )&& (poke_mode==0))begin
    count <= 0;
    HP<=16;
    pika<=0;
       case(scale) //1935
       0: begin P_in <= 1; max<=0; end 
       1: begin P_in <= 3; max<=0; end 
       2: begin P_in <= 7; max<=0; end 
       3: begin P_in <= 15; max<=0; end 
       4: begin P_in <= 31; max<=0; end 
       5: begin P_in <= 63; max<=0; end 
       6: begin P_in <= 127; max<=0; end 
       7: begin P_in <= 255; max<=0; end 
       8: begin P_in <= 511; max<=0; end 
       9: begin P_in <= 1023; max<=0; end 
       10: begin P_in <= 2047; max<=0; end
       11: begin P_in <= 4095; max<=0; end
       12: begin P_in <= 8191; max<=0; end
       13: begin P_in <= 16383; max<=0;end
       14: begin P_in <= 32767; max<=0; end
       15: begin P_in <= 65535; max<=0; end
     endcase
    end
    
    if (volup==1) begin
    vol<= ((vol+1)<6)? vol+1:vol;
    end
            
    if (voldown==1) begin
    vol<= (vol!=0)? vol-1:vol;
    end
    
    case (vol)
    0:scale<=(max-2000)/130;
    1:scale<=(max-1900)/130;
    2:scale<=(max-1800)/130;
    3:scale<=(max-1700)/130;
    4:scale<=(max-1600)/130;
    5:scale<=(max-1500)/130;
    endcase
    
    if (poke_mode==1) begin
    if ((count== 15 )&& (pika==0))begin
    count <= 0;
    HP<=16; 
       case(scale) //1935
       0: begin P_in <= 1; max<=0; end 
       1: begin P_in <= 3; max<=0; end 
       2: begin P_in <= 7; max<=0; end 
       3: begin P_in <= 15; max<=0; end 
       4: begin P_in <= 31; max<=0; end 
       5: begin P_in <= 63; max<=0; end 
       6: begin P_in <= 127; max<=0; end 
       7: begin P_in <= 255; max<=0; end 
       8: begin P_in <= 511; max<=0; end 
       9: begin P_in <= 1023; max<=0; end 
       10: begin P_in <= 2047; max<=0; end
       11: begin P_in <= 4095; max<=0; end
       12: begin P_in <= 8191; max<=0; end
       13: begin P_in <= 16383; max<=0;end
       14: begin P_in <= 32767; max<=0; end
       15: begin P_in <= 65535; max<=0; end
     endcase
    end
    if (pulseD==1&&pika!=0&&pika!=3) begin
    HP<=HP-1;
    pika<=2;
    end
    if(pika==0 && ((max-2000)/130)==15)begin
    pika<=1;
    end
    
    if (pika ==1) begin
    case (HP)
    0: begin P_in <= 0; pika<=3; end
    1: begin P_in <= 1; end 
    2: begin P_in <= 3; end 
    3: begin P_in <= 7; end 
    4: begin P_in <= 15; end 
    5: begin P_in <= 31; end 
    6: begin P_in <= 63; end 
    7: begin P_in <= 127; end 
    8: begin P_in <= 255; end 
    9: begin P_in <= 511; end 
    10: begin P_in <= 1023; end 
    11: begin P_in <= 2047; end
    12: begin P_in <= 4095; end
    13: begin P_in <= 8191; end
    14: begin P_in <= 16383; end
    15: begin P_in <= 32767; end
    16: begin P_in <= 65535; end
    default: pika<=0;
    endcase
    end
    
    if (pika==2) begin
    pika_count<=pika_count+1;
    pika<=(pika_count==0)?1:2;
    end
    
    if (pika ==3) begin
    P_in<=0;
    end
    end// end of poke_mode
    
    //my improvement
    
    end// end of always block
endmodule
