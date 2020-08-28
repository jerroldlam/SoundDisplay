`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
//  FILL IN THE FOLLOWING INFORMATION:
//
//  LAB SESSION DAY (Delete where applicable):THURSDAY A.M.
//
//  STUDENT A NAME: Ju Zi Hao
//  STUDENT A MATRICULATION NUMBER: A0201851R
//
//  STUDENT B NAME: Lam Tian Yu Jerrold
//  STUDENT B MATRICULATION NUMBER: A0201999R
//
//  Connect MOD Mic to top row of JA
//  Connect PMOLED DISPLAY to JB
//////////////////////////////////////////////////////////////////////////////////


module Top_Student (
    //FOR MIC INPUT
    input sw,
    input  J_MIC3_Pin3,   // Connect from this signal to Audio_Capture.v
    output J_MIC3_Pin1,   // Connect to this signal from Audio_Capture.v
    output J_MIC3_Pin4,    // Connect to this signal from Audio_Capture.v
    output [15:0] led,
    output [6:0]seg,
    output [3:0]an,
    
    //FOR OLED DISPLAY
    input CLK100MHZ,
    input btnC,
    input btnU,
    input btnD,
    input btnL,
    input btnR,
    output cs,sdin,sclk,d_cn,resn,vccen,pmoden,//output of OLED display
    input border_select,
    input border_onoff,bar_onoff,bar_extender,bar_freeze,horizontal_mode,wave_mode,
    
    //FOR POKE MODE
    input poke_mode,
    
    //For Sound improvement
    input sq_mode
    );
    
    //FOR MIC INPUT
    wire [11:0]Mic_in;
    wire [11:0]MAX;
    wire clk20k; 
    wire [15:0]Peak_Intensity;  
    wire [1:0] pika;
   
   //CLOCKS
   clk20k slow20k(CLK100MHZ,clk20k);
   
   //Audio Stuffs
   Audio_Capture AC1(CLK100MHZ,clk20k,J_MIC3_Pin3,J_MIC3_Pin1,J_MIC3_Pin4,Mic_in);
   P_Int Int1(CLK100MHZ,Mic_in,Peak_Intensity,btnD,poke_mode,pika,btnL,btnR);
   PINT_DISPLAY D0(clk20k,seg,an,Peak_Intensity,pika,poke_mode); 
   
   //Display Stuffs
   DisplayModule DM0 (CLK100MHZ,btnC,btnU,cs,sdin,sclk,d_cn,resn,vccen,pmoden,
                         border_select,border_onoff,bar_onoff,Peak_Intensity,bar_extender,bar_freeze,
                         poke_mode,horizontal_mode,wave_mode,pika,Mic_in,sq_mode);
   
   assign led = (sw ==1) ? Mic_in:Peak_Intensity;
endmodule