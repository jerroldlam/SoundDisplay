`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/20/2020 12:38:22 PM
// Design Name: 
// Module Name: DisplayModule
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


module DisplayModule(
    input CLK100MHZ,
    input btnC,
    input btnU,
    output cs, sdin, sclk, d_cn, resn, vccen, pmoden,//output of OLED display
    input border_select,
    input border_onoff, bar_onoff,
    input [25:0] peak_in,
    input bar_extender, bar_freeze, poke_mode,horizontal_mode,wave_mode,
    input [1:0] pika,
    input [11:0] Mic_in,
    input sq_mode
    );
    
    //FOR OLED DISPLAY
        wire clk6p25m; wire reset; wire clk1p5;
        reg [15:0] oled_data = 0;
        wire colour_button; //pulse from up button to toggle colour
        reg [1:0] colour_state = 0; //variable to switch bewteen 3 colour schemes
        reg [15:0] bg_colour = 0; //background colour code
        reg [15:0] border_colour = 0; //border colour code
        wire [12:0] pixel_index; // 0 to 6143, 96X96
        //no need yet
        wire frame_begin, sending_pixels, sample_pixel;
        wire [4:0] teststate;
        reg [6:0] bar_bias;
        reg [6:0] bar_low = 42;
        reg [6:0] bar_high = 52;
        reg [15:0] p_in = 0;
        
        //FOR BAR CONTROL COLOUR CODE
            //LOW VOLUME CODE
        reg [15:0] low_colour1 = 0;
        reg [15:0] low_colour2 = 0;
        reg [15:0] low_colour3 = 0;
        reg [15:0] low_colour4 = 0;
        reg [15:0] low_colour5 = 0;
            //MED VOLUME CODE
        reg [15:0] medium_colour1 = 0;
        reg [15:0] medium_colour2 = 0;
        reg [15:0] medium_colour3 = 0;
        reg [15:0] medium_colour4 = 0;
        reg [15:0] medium_colour5 = 0;
            //HIGH VOLUME CODE
        reg [15:0] high_colour1 = 0;
        reg [15:0] high_colour2 = 0;
        reg [15:0] high_colour3 = 0;
        reg [15:0] high_colour4 = 0;
        reg [15:0] high_colour5 = 0;
        
        //WAVE MODE
        reg [15:0] wave1 = 0;
        reg [15:0] wave2 = 0;
        reg [15:0] wave3 = 0;
        reg [15:0] wave4 = 0;
        reg [15:0] wave5 = 0;
        reg [15:0] wave6 = 0;
        reg [15:0] wave7 = 0;
        reg [15:0] wave8 = 0;
        reg [15:0] wave9 = 0;
        reg [15:0] wave10 = 0;
        reg [15:0] wave11 = 0;
        reg [15:0] wave_counter = 0;
        
        //POKE MODE
        reg [6:0] x = 0;
        reg [6:0] y = 0;
        reg [6:0] move_x = 28;
        reg [6:0] move_y = 0;
        wire zap;
        
        //sq_mode
        reg [5:0]value=0;
        reg [6:0]base_y=0;
        reg [6:0]base_x=15;
        reg [6:0]max_y=65;
        reg [6:0]max_x=81;
        
        //clocks section
        clk6p25m clk6p25m0 (CLK100MHZ,clk6p25m);
        clk1p5 clk1p50 (CLK100MHZ,clk1p5);
        zap_clock zap0 (CLK100MHZ,zap);
        
        //debouncers
        debouncer debouncerC (CLK100MHZ, btnC, reset);
        debouncer debouncerU (CLK100MHZ, btnU, colour_button);
        
        //MIC AND OLED DISPLAY INSTANTIATIONS
        Oled_Display Oled_Display (clk6p25m, reset, frame_begin, sending_pixels,
              sample_pixel, pixel_index, oled_data, cs, sdin, sclk, d_cn, resn, vccen,
              pmoden,teststate);
              
        //MISC STUFF
              
         //FOR COLOUR SELECTION
                 always @ (posedge clk6p25m) begin
                    if (poke_mode == 0) begin
                     if(colour_button == 1)
                         colour_state <= ((colour_state + 1) < 3)? (colour_state + 1) : 0;
                         
                     case (colour_state)
                     
                         //BG:BLACK, BORDER:WHITE, LOW:GREEN, MED:YELLOW, HIGH:RED
                         0: begin 
                             bg_colour = (p_in[15] == 1) ? ((clk1p5 == 1) ? 16'hFFFF : 16'h0000 )  : 16'h0000; 
                             border_colour <= (border_onoff == 0) ? 16'hFFFF : bg_colour; 
                             
                             low_colour1 <= (bar_onoff == 0) ? ((p_in[1] == 1) ? 16'h07E0 : bg_colour) : bg_colour; 
                             low_colour2 <= (bar_onoff == 0) ? ((p_in[2] == 1) ? 16'h07E0 : bg_colour) : bg_colour;
                             low_colour3 <= (bar_onoff == 0) ? ((p_in[3] == 1) ? 16'h07E0 : bg_colour) : bg_colour;
                             low_colour4 <= (bar_onoff == 0) ? ((p_in[4] == 1) ? 16'h07E0 : bg_colour) : bg_colour;
                             low_colour5 <= (bar_onoff == 0) ? ((p_in[5] == 1) ? 16'h07E0 : bg_colour) : bg_colour;
                             
                             medium_colour1 <= (bar_onoff == 0) ? ((p_in[6] == 1) ? 16'hFFE0 : bg_colour): bg_colour;
                             medium_colour2 <= (bar_onoff == 0) ? ((p_in[7] == 1) ? 16'hFFE0 : bg_colour): bg_colour;
                             medium_colour3 <= (bar_onoff == 0) ? ((p_in[8] == 1) ? 16'hFFE0 : bg_colour): bg_colour;
                             medium_colour4 <= (bar_onoff == 0) ? ((p_in[9] == 1) ? 16'hFFE0 : bg_colour): bg_colour;
                             medium_colour5 <= (bar_onoff == 0) ? ((p_in[10] == 1) ? 16'hFFE0 : bg_colour): bg_colour;
                      
                             high_colour1 <= (bar_onoff == 0) ? ((p_in[11] == 1) ? 16'hF000 : bg_colour): bg_colour;
                             high_colour2 <= (bar_onoff == 0) ? ((p_in[12] == 1) ? 16'hF000 : bg_colour): bg_colour;
                             high_colour3 <= (bar_onoff == 0) ? ((p_in[13] == 1) ? 16'hF000 : bg_colour): bg_colour;
                             high_colour4 <= (bar_onoff == 0) ? ((p_in[14] == 1) ? 16'hF000 : bg_colour): bg_colour;
                             high_colour5 <= (bar_onoff == 0) ? ((p_in[15] == 1) ? 16'hF000 : bg_colour): bg_colour; end
                             
                         //BG:RED, BORDER:GREEN, LOW:WHITE, MED:LIGHT BLUE, HIGH:BLUE
                         1: begin 
                             bg_colour = (p_in[15] == 1) ? ((clk1p5 == 1) ? 16'h07E0 : 16'hF000 )  : 16'hF000;
                             border_colour <= (border_onoff == 0) ? 16'h07E0 : bg_colour; 
                             
                             low_colour1 <= (bar_onoff == 0) ? ((p_in[1] == 1) ? 16'hFFFF : bg_colour) : bg_colour; 
                             low_colour2 <= (bar_onoff == 0) ? ((p_in[2] == 1) ? 16'hFFFF : bg_colour) : bg_colour;
                             low_colour3 <= (bar_onoff == 0) ? ((p_in[3] == 1) ? 16'hFFFF : bg_colour) : bg_colour;
                             low_colour4 <= (bar_onoff == 0) ? ((p_in[4] == 1) ? 16'hFFFF : bg_colour) : bg_colour;
                             low_colour5 <= (bar_onoff == 0) ? ((p_in[5] == 1) ? 16'hFFFF : bg_colour) : bg_colour;
                             
                             medium_colour1 <= (bar_onoff == 0) ? ((p_in[6] == 1) ? 16'h07FF : bg_colour): bg_colour;
                             medium_colour2 <= (bar_onoff == 0) ? ((p_in[7] == 1) ? 16'h07FF : bg_colour): bg_colour;
                             medium_colour3 <= (bar_onoff == 0) ? ((p_in[8] == 1) ? 16'h07FF : bg_colour): bg_colour;
                             medium_colour4 <= (bar_onoff == 0) ? ((p_in[9] == 1) ? 16'h07FF : bg_colour): bg_colour;
                             medium_colour5 <= (bar_onoff == 0) ? ((p_in[10] == 1) ? 16'h07FF : bg_colour): bg_colour;
                              
                             high_colour1 <= (bar_onoff == 0) ? ((p_in[11] == 1) ? 16'h001F : bg_colour): bg_colour;
                             high_colour2 <= (bar_onoff == 0) ? ((p_in[12] == 1) ? 16'h001F : bg_colour): bg_colour;
                             high_colour3 <= (bar_onoff == 0) ? ((p_in[13] == 1) ? 16'h001F : bg_colour): bg_colour;
                             high_colour4 <= (bar_onoff == 0) ? ((p_in[14] == 1) ? 16'h001F : bg_colour): bg_colour;
                             high_colour5 <= (bar_onoff == 0) ? ((p_in[15] == 1) ? 16'h001F : bg_colour): bg_colour; end                        
                             
                         //BG:GREY, BORDER:PURPLE, LOW:YELLOW, MED:RED, HIGH:BLACK
                         2: begin 
                             bg_colour = (p_in[15] == 1) ? ((clk1p5 == 1) ? 16'hF81F : 16'h38E7 )  : 16'h38E7; 
                             border_colour <= (border_onoff == 0) ? 16'hF81F : bg_colour; 
                             
                             low_colour1 <= (bar_onoff == 0) ? ((p_in[1] == 1) ? 16'hFFE0 : bg_colour) : bg_colour; 
                             low_colour2 <= (bar_onoff == 0) ? ((p_in[2] == 1) ? 16'hFFE0 : bg_colour) : bg_colour;
                             low_colour3 <= (bar_onoff == 0) ? ((p_in[3] == 1) ? 16'hFFE0 : bg_colour) : bg_colour;
                             low_colour4 <= (bar_onoff == 0) ? ((p_in[4] == 1) ? 16'hFFE0 : bg_colour) : bg_colour;
                             low_colour5 <= (bar_onoff == 0) ? ((p_in[5] == 1) ? 16'hFFE0 : bg_colour) : bg_colour;
                             
                             medium_colour1 <= (bar_onoff == 0) ? ((p_in[6] == 1) ? 16'hF000 : bg_colour): bg_colour;
                             medium_colour2 <= (bar_onoff == 0) ? ((p_in[7] == 1) ? 16'hF000 : bg_colour): bg_colour;
                             medium_colour3 <= (bar_onoff == 0) ? ((p_in[8] == 1) ? 16'hF000 : bg_colour): bg_colour;
                             medium_colour4 <= (bar_onoff == 0) ? ((p_in[9] == 1) ? 16'hF000 : bg_colour): bg_colour;
                             medium_colour5 <= (bar_onoff == 0) ? ((p_in[10] == 1) ? 16'hF000 : bg_colour): bg_colour;
                             
                             high_colour1 <= (bar_onoff == 0) ? ((p_in[11] == 1) ? 16'h0000 : bg_colour): bg_colour;
                             high_colour2 <= (bar_onoff == 0) ? ((p_in[12] == 1) ? 16'h0000 : bg_colour): bg_colour;
                             high_colour3 <= (bar_onoff == 0) ? ((p_in[13] == 1) ? 16'h0000 : bg_colour): bg_colour;
                             high_colour4 <= (bar_onoff == 0) ? ((p_in[14] == 1) ? 16'h0000 : bg_colour): bg_colour;
                             high_colour5 <= (bar_onoff == 0) ? ((p_in[15] == 1) ? 16'h0000 : bg_colour): bg_colour; end 
                              
                     endcase
                 end
                 end //OUTERMOST END
                 
                 //BLOCK FOR OLED DISPLAY CONTROL
                 always @ (posedge CLK100MHZ) begin 
                 
                 x = pixel_index % 96;
                 y = pixel_index / 96;
                 
                 if (poke_mode == 0) begin
                 if (sq_mode==0) begin //sq mode
                    if(horizontal_mode == 0) begin
                        if (wave_mode == 0) begin
                 //DRAWING BORDERS 
                     //DRAWING BORDER - 1 PIXEL
                 if (border_select == 0) begin
                     if ((pixel_index % 96) == 0)
                         oled_data <= border_colour;
                     else if ((pixel_index % 96) == 95)
                         oled_data <= border_colour;
                     else if ((pixel_index / 96) == 0)
                         oled_data <= border_colour;
                     else if ((pixel_index / 96) == 63)
                         oled_data <= border_colour;
                     
                     //DRAWING BARS
                     else if ((pixel_index % 96) > (bar_low - bar_bias) && (pixel_index % 96) < (bar_high + bar_bias)) begin    
                     
                      //DRAWING HIGH BARS   
                      if((pixel_index / 96) == 10 || (pixel_index / 96) == 11)
                         oled_data <= high_colour5;
                     else if((pixel_index / 96) == 13 || (pixel_index / 96) == 14)
                         oled_data <= high_colour4;
                     else if((pixel_index / 96) == 16 || (pixel_index / 96) == 17)
                         oled_data <= high_colour3;
                     else if((pixel_index / 96) == 19 || (pixel_index / 96) == 20)
                         oled_data <= high_colour2;
                     else if((pixel_index / 96) == 22 || (pixel_index / 96) == 23)
                         oled_data <= high_colour1;
                         
                     //DRAWING MED BARS
                     else if((pixel_index / 96) == 25 || (pixel_index / 96) == 26)
                         oled_data <= medium_colour5;
                     else if((pixel_index / 96) == 28 || (pixel_index / 96) == 29)
                         oled_data <= medium_colour4;
                     else if((pixel_index / 96) == 31 || (pixel_index / 96) == 32)
                         oled_data <= medium_colour3;
                     else if((pixel_index / 96) == 34 || (pixel_index / 96) == 35)
                         oled_data <= medium_colour2;
                     else if((pixel_index / 96) == 37 || (pixel_index / 96) == 38)
                         oled_data <= medium_colour1;
                                                                         
                     //DRAWING LOW BARS
                     else if((pixel_index / 96) == 40 || (pixel_index / 96) == 41)
                         oled_data <= low_colour5;
                     else if((pixel_index / 96) == 43 || (pixel_index / 96) == 44)
                         oled_data <= low_colour4;
                     else if((pixel_index / 96) == 46 || (pixel_index / 96) == 47)
                         oled_data <= low_colour3;
                     else if((pixel_index / 96) == 49 || (pixel_index / 96) == 50)
                         oled_data <= low_colour2;
                     else if((pixel_index / 96) == 52 || (pixel_index / 96) == 53)
                         oled_data <= low_colour1;
                     end                                                                                                                                                      
                     else
                         oled_data <= bg_colour;
                 end //END OF DRAWING BORDER - 1 PIXEL
                     
                     //DRAWING BORDER - 3 PIXELS
                 if (border_select == 1) begin
                     if ((pixel_index % 96) == 0 || (pixel_index % 96) == 1 || (pixel_index % 96) == 2 )
                             oled_data <= border_colour;
                     else if ((pixel_index % 96) == 95 ||(pixel_index % 96) == 94 ||(pixel_index % 96) == 93 )
                             oled_data <= border_colour;
                     else if ((pixel_index / 96) <= 2)
                             oled_data <= border_colour;
                     else if ((pixel_index /96) >= 61)
                             oled_data <= border_colour;
                             
                     //DRAWING BARS
                     else if ((pixel_index % 96) > (bar_low - bar_bias) && (pixel_index % 96) < (bar_high + bar_bias)) begin   
                            
                      //DRAWING HIGH BARS   
                             if((pixel_index / 96) == 10 || (pixel_index / 96) == 11)
                                oled_data <= high_colour5;
                            else if((pixel_index / 96) == 13 || (pixel_index / 96) == 14)
                                oled_data <= high_colour4;
                            else if((pixel_index / 96) == 16 || (pixel_index / 96) == 17)
                                oled_data <= high_colour3;
                            else if((pixel_index / 96) == 19 || (pixel_index / 96) == 20)
                                oled_data <= high_colour2;
                            else if((pixel_index / 96) == 22 || (pixel_index / 96) == 23)
                                oled_data <= high_colour1;
                                
                            //DRAWING MED BARS
                            else if((pixel_index / 96) == 25 || (pixel_index / 96) == 26)
                                oled_data <= medium_colour5;
                            else if((pixel_index / 96) == 28 || (pixel_index / 96) == 29)
                                oled_data <= medium_colour4;
                            else if((pixel_index / 96) == 31 || (pixel_index / 96) == 32)
                                oled_data <= medium_colour3;
                            else if((pixel_index / 96) == 34 || (pixel_index / 96) == 35)
                                oled_data <= medium_colour2;
                            else if((pixel_index / 96) == 37 || (pixel_index / 96) == 38)
                                oled_data <= medium_colour1;
                                                                                
                            //DRAWING LOW BARS
                            else if((pixel_index / 96) == 40 || (pixel_index / 96) == 41)
                                oled_data <= low_colour5;
                            else if((pixel_index / 96) == 43 || (pixel_index / 96) == 44)
                                oled_data <= low_colour4;
                            else if((pixel_index / 96) == 46 || (pixel_index / 96) == 47)
                                oled_data <= low_colour3;
                            else if((pixel_index / 96) == 49 || (pixel_index / 96) == 50)
                                oled_data <= low_colour2;
                            else if((pixel_index / 96) == 52 || (pixel_index / 96) == 53)
                                oled_data <= low_colour1;
                     end           
                     else
                             oled_data <= bg_colour;
                     end //END OF DRAWING BORDER - 3 PIXELS
                     //END OF DRAWING BORDER
                     end // END OF WAVE MODE 0
                 end // END OF HORIZONTAL MODE 0
                 end // END of sq mode
                 
                 if (poke_mode == 0) begin
                    if (horizontal_mode == 1) begin //HORIZONTAL MODE ACTIVATED
                        if (wave_mode == 0) begin
                    
                    //DRAWING BORDER - 1 PIXEL
                         if (border_select == 0) begin 
                                  if ((pixel_index % 96) == 0)
                                oled_data <= border_colour;
                             else if ((pixel_index % 96) == 95)
                                oled_data <= border_colour;
                             else if ((pixel_index / 96) == 0)
                                oled_data <= border_colour;
                             else if ((pixel_index / 96) == 63)
                                oled_data <= border_colour;
                                
                     //DRAWING BARS
                        else if ((pixel_index / 96) > 5 && (pixel_index / 96) < 90)
                        
                        //DRAWING HIGH BARS
                            if ((pixel_index % 96) == 11 || (pixel_index % 96) == 12 || (pixel_index % 96) == 13 || (pixel_index % 96) == 14)
                                oled_data <= high_colour5; 
                        else if ((pixel_index % 96) == 16 || (pixel_index % 96) == 17 || (pixel_index % 96) == 18 || (pixel_index % 96) == 19)
                                oled_data <= high_colour4;
                        else if ((pixel_index % 96) == 21 || (pixel_index % 96) == 22 || (pixel_index % 96) == 23 || (pixel_index % 96) == 24)
                                oled_data <= high_colour3;
                        else if ((pixel_index % 96) == 26 || (pixel_index % 96) == 27 || (pixel_index % 96) == 28 || (pixel_index % 96) == 29)
                                oled_data <= high_colour2; 
                        else if ((pixel_index % 96) == 31 || (pixel_index % 96) == 32 || (pixel_index % 96) == 33 || (pixel_index % 96) == 34)
                                oled_data <= high_colour1;
                                
                        //DRAWING MED BARS
                        else if ((pixel_index % 96) == 36 || (pixel_index % 96) == 37 || (pixel_index % 96) == 38 || (pixel_index % 96) == 39)
                                oled_data <= medium_colour5; 
                        else if ((pixel_index % 96) == 41 || (pixel_index % 96) == 42 || (pixel_index % 96) == 43 || (pixel_index % 96) == 44)
                                oled_data <= medium_colour4;
                        else if ((pixel_index % 96) == 46 || (pixel_index % 96) == 47 || (pixel_index % 96) == 48 || (pixel_index % 96) == 49)
                                oled_data <= medium_colour3;
                        else if ((pixel_index % 96) == 51 || (pixel_index % 96) == 52 || (pixel_index % 96) == 53 || (pixel_index % 96) == 54)
                                oled_data <= medium_colour2;
                        else if ((pixel_index % 96) == 56 || (pixel_index % 96) == 57 || (pixel_index % 96) == 58 || (pixel_index % 96) == 59)
                                oled_data <= medium_colour1;
                                
                        //DRAWING LOW BARS
                        else if ((pixel_index % 96) == 61 || (pixel_index % 96) == 62 || (pixel_index % 96) == 63 || (pixel_index % 96) == 64)
                                oled_data <= low_colour5; 
                        else if ((pixel_index % 96) == 66 || (pixel_index % 96) == 67 || (pixel_index % 96) == 68 || (pixel_index % 96) == 69)
                                oled_data <= low_colour4;
                        else if ((pixel_index % 96) == 71 || (pixel_index % 96) == 72 || (pixel_index % 96) == 73 || (pixel_index % 96) == 74)
                                oled_data <= low_colour3;
                        else if ((pixel_index % 96) == 76 || (pixel_index % 96) == 77 || (pixel_index % 96) == 78 || (pixel_index % 96) == 79)
                                oled_data <= low_colour2;
                        else if ((pixel_index % 96) == 81 || (pixel_index % 96) == 82 || (pixel_index % 96) == 83 || (pixel_index % 96) == 84)
                                 oled_data <= low_colour1;
                                 
                            else oled_data <= bg_colour;           
                    end //END OF 1 PIXEL BORDER
                    
                    if (border_select == 1) begin
                    
                    //DRAWING 3 PIXEL BORDER
                        if ((pixel_index % 96) == 0 || (pixel_index % 96) == 1 || (pixel_index % 96) == 2 )
                                oled_data <= border_colour;
                   else if ((pixel_index % 96) == 95 ||(pixel_index % 96) == 94 ||(pixel_index % 96) == 93 )
                                oled_data <= border_colour;
                   else if ((pixel_index / 96) <= 2)
                                oled_data <= border_colour;
                   else if ((pixel_index /96) >= 61)
                                oled_data <= border_colour;
                                
                        //DRAWING BARS
                             else if ((pixel_index / 96) > 5 && (pixel_index / 96) < 90)
                                                        
                                      //DRAWING HIGH BARS
                                   if ((pixel_index % 96) == 11 || (pixel_index % 96) == 12 || (pixel_index % 96) == 13 || (pixel_index % 96) == 14)
                                         oled_data <= high_colour5; 
                              else if ((pixel_index % 96) == 16 || (pixel_index % 96) == 17 || (pixel_index % 96) == 18 || (pixel_index % 96) == 19)
                                         oled_data <= high_colour4;
                              else if ((pixel_index % 96) == 21 || (pixel_index % 96) == 22 || (pixel_index % 96) == 23 || (pixel_index % 96) == 24)
                                         oled_data <= high_colour3;
                              else if ((pixel_index % 96) == 26 || (pixel_index % 96) == 27 || (pixel_index % 96) == 28 || (pixel_index % 96) == 29)
                                         oled_data <= high_colour2;
                              else if ((pixel_index % 96) == 31 || (pixel_index % 96) == 32 || (pixel_index % 96) == 33 || (pixel_index % 96) == 34)
                                         oled_data <= high_colour1;
                                                                
                                     //DRAWING MED BARS
                              else if ((pixel_index % 96) == 36 || (pixel_index % 96) == 37 || (pixel_index % 96) == 38 || (pixel_index % 96) == 39)
                                         oled_data <= medium_colour5; 
                              else if ((pixel_index % 96) == 41 || (pixel_index % 96) == 42 || (pixel_index % 96) == 43 || (pixel_index % 96) == 44)
                                         oled_data <= medium_colour4;
                              else if ((pixel_index % 96) == 46 || (pixel_index % 96) == 47 || (pixel_index % 96) == 48 || (pixel_index % 96) == 49)
                                         oled_data <= medium_colour3;
                              else if ((pixel_index % 96) == 51 || (pixel_index % 96) == 52 || (pixel_index % 96) == 53 || (pixel_index % 96) == 54)
                                         oled_data <= medium_colour2;
                              else if ((pixel_index % 96) == 56 || (pixel_index % 96) == 57 || (pixel_index % 96) == 58 || (pixel_index % 96) == 59)
                                         oled_data <= medium_colour1;
                                                                
                                    //DRAWING LOW BARS
                              else if ((pixel_index % 96) == 61 || (pixel_index % 96) == 62 || (pixel_index % 96) == 63 || (pixel_index % 96) == 64)
                                         oled_data <= low_colour5; 
                              else if ((pixel_index % 96) == 66 || (pixel_index % 96) == 67 || (pixel_index % 96) == 68 || (pixel_index % 96) == 69)
                                         oled_data <= low_colour4;
                              else if ((pixel_index % 96) == 71 || (pixel_index % 96) == 72 || (pixel_index % 96) == 73 || (pixel_index % 96) == 74)
                                         oled_data <= low_colour3;
                              else if ((pixel_index % 96) == 76 || (pixel_index % 96) == 77 || (pixel_index % 96) == 78 || (pixel_index % 96) == 79)
                                         oled_data <= low_colour2;
                              else if ((pixel_index % 96) == 81 || (pixel_index % 96) == 82 || (pixel_index % 96) == 83 || (pixel_index % 96) == 84)
                                         oled_data <= low_colour1;
                                                                 
                                    else oled_data <= bg_colour;
                    end //WAVE MODE 0
                    end //END OF 3 PIXEL BORDER
                    end //END OF HORIZONTAL MODE 1
                   end
                   
                    if (poke_mode == 0) begin
                        if (wave_mode == 1) begin
                            
                            case(colour_state)
                                0: begin //BLUE WAVE
                                    oled_data[0] <= Mic_in[7];
                                    oled_data[1] <= Mic_in[8];
                                    oled_data[2] <= Mic_in[9];
                                    oled_data[3] <= Mic_in[10];
                                    oled_data[4] <= Mic_in[11]; 
                                    oled_data[11:5] <= 0; end
                                    
                                1:  begin // RED WAVE
                                    oled_data[11] <= Mic_in[7];
                                    oled_data[12] <= Mic_in[8];
                                    oled_data[13] <= Mic_in[9];
                                    oled_data[14] <= Mic_in[10];
                                    oled_data[15] <= Mic_in[11]; 
                                    oled_data[10:0] <= 0; end
                                    
                                2: begin //GREEN WAVE
                                    oled_data [4:0] <= 0;
                                    oled_data[5] <= Mic_in[6];
                                    oled_data[6] <= Mic_in[7];
                                    oled_data[7] <= Mic_in[8];
                                    oled_data[8] <= Mic_in[9];
                                    oled_data[9] <= Mic_in[10];
                                    oled_data[10] <= Mic_in[11]; 
                                    oled_data[15:11] <= 0;end
                            endcase
                            
                        end
                    end
                    
                 //   end //END OF NORMAL SOUND BAR MODE
                 
                 
                 //MULTIPLEX FOR EXTENDING THE BARS
                 bar_bias <= (bar_extender == 1)? 8 : 0;
                 
                 //FREEZING THE INPUTS
                 if (bar_freeze == 1)
                    p_in <= p_in;
                 else
                    p_in <= peak_in;
                 
                 end //END OF SOUND BAR MODE
             
             
              
            //START OF POKE MODE
            if (poke_mode == 1) begin
                case (pika)
                0: begin // TWO POKEBALL
                    //SCENE 0 (2 POKEBALLS)
                              //POKEBALL (TOP LEFT)
                                //BLACK PART
                                     if (x == 1 && y >= 7 && y <= 12) oled_data <= 0;    
                                else if (x == 2 && y >= 5 && y <= 6) oled_data <= 0;
                                else if (x == 2 && y >= 10 && y <= 14) oled_data <= 0;
                                else if (x == 3 && y == 4) oled_data <= 0;
                                else if (x == 3 && y >= 11 && y <= 12) oled_data <= 0;
                                else if (x == 3 && y == 15) oled_data <= 0;
                                else if (x == 4 && y == 3) oled_data <= 0;
                                else if (x == 4 && y >= 12 && y <= 13) oled_data <= 0;
                                else if (x == 4 && y == 16) oled_data <= 0;
                                else if (x == 5 && y == 2) oled_data <= 0;
                                else if (x == 5 && y >= 12 && y <= 14) oled_data <= 0;
                                else if (x == 5 && y == 17) oled_data <= 0;
                                else if (x == 6 && y == 2) oled_data <= 0;
                                else if (x == 6 && y == 11) oled_data <= 0;
                                else if (x == 6 && y == 15) oled_data <= 0;
                                else if (x == 6 && y == 17) oled_data <= 0;
                                else if (x == 7 && y == 1) oled_data <= 0;
                                else if (x == 7 && y == 11) oled_data <= 0;
                                else if (x == 7 && y == 15) oled_data <= 0;
                                else if (x == 7 && y == 18) oled_data <= 0;  
                                else if (x == 8 && y == 1) oled_data <= 0;
                                else if (x == 8 && y == 11) oled_data <= 0;
                                else if (x == 8 && y == 15) oled_data <= 0;
                                else if (x == 8 && y == 18) oled_data <= 0;
                                else if (x == 9 && y == 1) oled_data <= 0;
                                else if (x == 9 && y >= 12 && y <= 14) oled_data <= 0;
                                else if (x == 9 && y == 18) oled_data <= 0;
                                else if (x == 10 && y == 1) oled_data <= 0;
                                else if (x == 10 && y >= 13 && y <= 14) oled_data <= 0;
                                else if (x == 10 && y == 18) oled_data <= 0;
                                else if (x == 11 && y == 1) oled_data <= 0;
                                else if (x == 11 && y >= 13 && y <= 14) oled_data <= 0;
                                else if (x == 11 && y == 18) oled_data <= 0;
                                else if (x == 12 && y == 1) oled_data <= 0;
                                else if (x == 12 && y >= 13 && y <= 14) oled_data <= 0;
                                else if (x == 12 && y == 18) oled_data <= 0;
                                else if (x == 13 && y == 2) oled_data <= 0;
                                else if (x == 13 && y >= 13 && y <= 14) oled_data <= 0;
                                else if (x == 13 && y == 17) oled_data <= 0;
                                else if (x == 14 && y == 2) oled_data <= 0;
                                else if (x == 14 && y >= 12 && y <= 13) oled_data <= 0;
                                else if (x == 14 && y == 17) oled_data <= 0;
                                else if (x == 15 && y == 3) oled_data <= 0;
                                else if (x == 15 && y >= 12 && y <= 13) oled_data <= 0;
                                else if (x == 15 && y == 16) oled_data <= 0;
                                else if (x == 16 && y == 4) oled_data <= 0;
                                else if (x == 16 && y == 12) oled_data <= 0;
                                else if (x == 16 && y == 15) oled_data <= 0;
                                else if (x == 17 && y >= 5 && y <= 6) oled_data <= 0;
                                else if (x == 17 && y >= 11 && y <= 14) oled_data <= 0;
                                else if (x == 18 && y >= 7 && y <= 12) oled_data <= 0;
                                
                                //GREY SHADOW OF POKEBALL
                                else if (x == 3 && y >= 13 && y <= 14) oled_data <= 16'h5ACB;
                                else if (x == 4 && y == 15) oled_data <= 16'h5ACB;
                                else if (x == 5 && y == 16) oled_data <= 16'h5ACB;
                                else if (y == 17 && x >= 7 && x <= 12) oled_data <= 16'h5ACB;
                                else if (y == 16 && x >= 13 && x <= 14) oled_data <= 16'h5ACB;
                                else if (x == 15 && y == 15) oled_data <= 16'h5ACB;
                                else if (x == 16 && y >= 13 && y <= 14) oled_data <= 16'h5ACB;
                                
                                //RED PART OF POKEBALL
                                else if (x == 2 && y >= 7 && y <= 9) oled_data <= 16'hF800;
                                else if (x == 3 && y >= 5 && y <= 10) oled_data <= 16'hF800;
                                else if (x == 4 && y == 4) oled_data <= 16'hF800;
                                else if (x == 4 && y >= 7 && y <= 11) oled_data <= 16'hF800;
                                else if (x == 5 && y == 3) oled_data <= 16'hF800;
                                else if (x == 5 && y >= 8 && y <= 11) oled_data <= 16'hF800;
                                else if (x == 6 && y == 3) oled_data <= 16'hF800;
                                else if (x == 6 && y >= 8 && y <= 10) oled_data <= 16'hF800;
                                else if (x == 7 && y >= 2 && y <= 4) oled_data <= 16'hF800;
                                else if (x == 7 && y >= 7 && y <= 10) oled_data <= 16'hF800;
                                else if (x == 8 && y >= 2 && y <= 10) oled_data <= 16'hF800;
                                else if (x == 9 && y >= 2 && y <= 11) oled_data <= 16'hF800;
                                else if (x == 10 && y >= 2 && y <= 12) oled_data <= 16'hF800;
                                else if (x == 11 && y >= 2 && y <= 12) oled_data <= 16'hF800;
                                else if (x == 12 && y >= 2 && y <= 12) oled_data <= 16'hF800;
                                else if (x == 13 && y >= 3 && y <= 12) oled_data <= 16'hF800;
                                else if (x == 14 && y >= 3 && y <= 11) oled_data <= 16'hF800;
                                else if (x == 15 && y >= 4 && y <= 11) oled_data <= 16'hF800;
                                else if (x == 16 && y >= 5 && y <= 11) oled_data <= 16'hF800;
                                else if (x == 17 && y >= 7 && y <= 10) oled_data <= 16'hF800;
                                
                                //CENTRE CIRCLE OF POKEBALL
                                else if (x == 6 && y >= 12 && y <= 14) oled_data <= (clk1p5 == 1) ? 16'hFFFF : 16'hF7E0;
                                else if (x == 7 && y >= 12 && y <= 14) oled_data <= (clk1p5 == 1) ? 16'hFFFF : 16'hF7E0;
                                else if (x == 8 && y >= 12 && y <= 14) oled_data <= (clk1p5 == 1) ? 16'hFFFF : 16'hF7E0;
                                
                                //WHITE BASE OF POKEBALL
                                else if (x == 4 && y == 14) oled_data <= 16'hFFFF;
                                else if (x == 5 && y == 15) oled_data <= 16'hFFFF;
                                else if (y == 16 && x >= 6 && x <= 12) oled_data <= 16'hFFFF;
                                else if (y == 15 && x >= 9 && x <= 14) oled_data <= 16'hFFFF;
                                else if (y == 14 && x >= 14 && x <= 15) oled_data <= 16'hFFFF;
                                
                                //THE SHINE
                                else if (x == 5 && y >= 5 && y <= 6) oled_data <= 16'hFFFF;
                                else if (x == 6 && y >= 5 && y <= 6) oled_data <= 16'hFFFF;
                                else if (x == 4 && y >= 5 && y <= 6) oled_data <= 16'hFD1F;
                                else if (x == 7 && y >= 5 && y <= 6) oled_data <= 16'hFD1F;
                                else if (y == 4 && x >= 5 && x <= 6) oled_data <= 16'hFD1F;
                                else if (y == 7 && x >= 5 && x <= 6) oled_data <= 16'hFD1F;
                                
                             //POKEBALL (BOTTOM RIGHT) X+77 y+44
                                //BLACK PART
                                             else if (x == 1+77 && y >= 7+44 && y <= 12+44) oled_data <= 0;    
                                             else if (x == 2+77 && y >= 5+44 && y <= 6+44) oled_data <= 0;
                                             else if (x == 2+77 && y >= 10+44 && y <= 14+44) oled_data <= 0;
                                             else if (x == 3+77 && y == 4+44) oled_data <= 0;
                                             else if (x == 3+77 && y >= 11+44 && y <= 12+44) oled_data <= 0;
                                             else if (x == 3+77 && y == 15+44) oled_data <= 0;
                                             else if (x == 4+77 && y == 3+44) oled_data <= 0;
                                             else if (x == 4+77 && y >= 12+44 && y <= 13+44) oled_data <= 0;
                                             else if (x == 4+77 && y == 16+44) oled_data <= 0;
                                             else if (x == 5+77 && y == 2+44) oled_data <= 0;
                                             else if (x == 5+77 && y >= 12+44 && y <= 14+44) oled_data <= 0;
                                             else if (x == 5+77 && y == 17+44) oled_data <= 0;
                                             else if (x == 6+77 && y == 2+44) oled_data <= 0;
                                             else if (x == 6+77 && y == 11+44) oled_data <= 0;
                                             else if (x == 6+77 && y == 15+44) oled_data <= 0;
                                             else if (x == 6+77 && y == 17+44) oled_data <= 0;
                                             else if (x == 7+77 && y == 1+44) oled_data <= 0;
                                             else if (x == 7+77 && y == 11+44) oled_data <= 0;
                                             else if (x == 7+77 && y == 15+44) oled_data <= 0;
                                             else if (x == 7+77 && y == 18+44) oled_data <= 0;  
                                             else if (x == 8+77 && y == 1+44) oled_data <= 0;
                                             else if (x == 8+77 && y == 11+44) oled_data <= 0;
                                             else if (x == 8+77 && y == 15+44) oled_data <= 0;
                                             else if (x == 8+77 && y == 18+44) oled_data <= 0;
                                             else if (x == 9+77 && y == 1+44) oled_data <= 0;
                                             else if (x == 9+77 && y >= 12+44 && y <= 14+44) oled_data <= 0;
                                             else if (x == 9+77 && y == 18+44) oled_data <= 0;
                                             else if (x == 10+77 && y == 1+44) oled_data <= 0;
                                             else if (x == 10+77 && y >= 13+44 && y <= 14+44) oled_data <= 0;
                                             else if (x == 10+77 && y == 18+44) oled_data <= 0;
                                             else if (x == 11+77 && y == 1+44) oled_data <= 0;
                                             else if (x == 11+77 && y >= 13+44 && y <= 14+44) oled_data <= 0;
                                             else if (x == 11+77 && y == 18+44) oled_data <= 0;
                                             else if (x == 12+77 && y == 1+44) oled_data <= 0;
                                             else if (x == 12+77 && y >= 13+44 && y <= 14+44) oled_data <= 0;
                                             else if (x == 12+77 && y == 18+44) oled_data <= 0;
                                             else if (x == 13+77 && y == 2+44) oled_data <= 0;
                                             else if (x == 13+77 && y >= 13+44 && y <= 14+44) oled_data <= 0;
                                             else if (x == 13+77 && y == 17+44) oled_data <= 0;
                                             else if (x == 14+77 && y == 2+44) oled_data <= 0;
                                             else if (x == 14+77 && y >= 12+44 && y <= 13+44) oled_data <= 0;
                                             else if (x == 14+77 && y == 17+44) oled_data <= 0;
                                             else if (x == 15+77 && y == 3+44) oled_data <= 0;
                                             else if (x == 15+77 && y >= 12+44 && y <= 13+44) oled_data <= 0;
                                             else if (x == 15+77 && y == 16+44) oled_data <= 0;
                                             else if (x == 16+77 && y == 4+44) oled_data <= 0;
                                             else if (x == 16+77 && y == 12+44) oled_data <= 0;
                                             else if (x == 16+77 && y == 15+44) oled_data <= 0;
                                             else if (x == 17+77 && y >= 5+44 && y <= 6+44) oled_data <= 0;
                                             else if (x == 17+77 && y >= 11+44 && y <= 14+44) oled_data <= 0;
                                             else if (x == 18+77 && y >= 7+44 && y <= 12+44) oled_data <= 0;
                                             
                                             //GREY SHADOW OF POKEBALL
                                             else if (x == 3+77 && y >= 13+44 && y <= 14+44) oled_data <= 16'h5ACB;
                                             else if (x == 4+77 && y == 15+44) oled_data <= 16'h5ACB;
                                             else if (x == 5+77 && y == 16+44) oled_data <= 16'h5ACB;
                                             else if (y == 17+44 && x >= 7+77 && x <= 12+77) oled_data <= 16'h5ACB;
                                             else if (y == 16+44 && x >= 13+77 && x <= 14+77) oled_data <= 16'h5ACB;
                                             else if (x == 15+77 && y == 15+44) oled_data <= 16'h5ACB;
                                             else if (x == 16+77 && y >= 13+44 && y <= 14+44) oled_data <= 16'h5ACB;
                                             
                                             //RED PART OF POKEBALL
                                             else if (x == 2+77 && y >= 7+44 && y <= 9+44) oled_data <= 16'hF800;
                                             else if (x == 3+77 && y >= 5+44 && y <= 10+44) oled_data <= 16'hF800;
                                             else if (x == 4+77 && y == 4+44) oled_data <= 16'hF800;
                                             else if (x == 4+77 && y >= 7+44 && y <= 11+44) oled_data <= 16'hF800;
                                             else if (x == 5+77 && y == 3+44) oled_data <= 16'hF800;
                                             else if (x == 5+77 && y >= 8+44 && y <= 11+44) oled_data <= 16'hF800;
                                             else if (x == 6+77 && y == 3+44) oled_data <= 16'hF800;
                                             else if (x == 6+77 && y >= 8+44 && y <= 10+44) oled_data <= 16'hF800;
                                             else if (x == 7+77 && y >= 2+44 && y <= 4+44) oled_data <= 16'hF800;
                                             else if (x == 7+77 && y >= 7+44 && y <= 10+44) oled_data <= 16'hF800;
                                             else if (x == 8+77 && y >= 2+44 && y <= 10+44) oled_data <= 16'hF800;
                                             else if (x == 9+77 && y >= 2+44 && y <= 11+44) oled_data <= 16'hF800;
                                             else if (x == 10+77 && y >= 2+44 && y <= 12+44) oled_data <= 16'hF800;
                                             else if (x == 11+77 && y >= 2+44 && y <= 12+44) oled_data <= 16'hF800;
                                             else if (x == 12+77 && y >= 2+44 && y <= 12+44) oled_data <= 16'hF800;
                                             else if (x == 13+77 && y >= 3+44 && y <= 12+44) oled_data <= 16'hF800;
                                             else if (x == 14+77 && y >= 3+44 && y <= 11+44) oled_data <= 16'hF800;
                                             else if (x == 15+77 && y >= 4+44 && y <= 11+44) oled_data <= 16'hF800;
                                             else if (x == 16+77 && y >= 5+44 && y <= 11+44) oled_data <= 16'hF800;
                                             else if (x == 17+77 && y >= 7+44 && y <= 10+44) oled_data <= 16'hF800;
                                             
                                             //CENTRE CIRCLE OF POKEBALL
                                             else if (x == 6+77 && y >= 12+44 && y <= 14+44) oled_data <= (clk1p5 == 1) ? 16'hFFFF : 16'hF7E0;
                                             else if (x == 7+77 && y >= 12+44 && y <= 14+44) oled_data <= (clk1p5 == 1) ? 16'hFFFF : 16'hF7E0;
                                             else if (x == 8+77 && y >= 12+44 && y <= 14+44) oled_data <= (clk1p5 == 1) ? 16'hFFFF : 16'hF7E0;
                                             
                                             //WHITE BASE OF POKEBALL
                                             else if (x == 4+77 && y == 14+44) oled_data <= 16'hFFFF;
                                             else if (x == 5+77 && y == 15+44) oled_data <= 16'hFFFF;
                                             else if (y == 16+44 && x >= 6+77 && x <= 12+77) oled_data <= 16'hFFFF;
                                             else if (y == 15+44 && x >= 9+77 && x <= 14+77) oled_data <= 16'hFFFF;
                                             else if (y == 14+44 && x >= 14+77 && x <= 15+77) oled_data <= 16'hFFFF;
                                             
                                             //THE SHINE
                                             else if (x == 5+77 && y >= 5+44 && y <= 6+44) oled_data <= 16'hFFFF;
                                             else if (x == 6+77 && y >= 5+44 && y <= 6+44) oled_data <= 16'hFFFF;
                                             else if (x == 4+77 && y >= 5+44 && y <= 6+44) oled_data <= 16'hFD1F;
                                             else if (x == 7+77 && y >= 5+44 && y <= 6+44) oled_data <= 16'hFD1F;
                                             else if (y == 4+44 && x >= 5+77 && x <= 6+77) oled_data <= 16'hFD1F;
                                             else if (y == 7+44 && x >= 5+77 && x <= 6+77) oled_data <= 16'hFD1F;
                                
                                else oled_data <= 16'h01A0; 
                                end //END OF SCENE 0 (2 POKEBALLS)
                     1: begin //PIKACHU AND CHARMANDER
                            //SCENE 1 - PIKACHU AND CHARMANDER
                                     //CHARMANDER
                                         //BLACK COLOURS
                                                  if (x == 21 && y >= 6+move_y && y <= 8+move_y) oled_data <= 0;     
                                             else if (x == 20 && y == 5+move_y) oled_data <= 0;
                                             else if (x == 20 && y == 9+move_y) oled_data <= 0;
                                             else if (x == 19 && y >= 3+move_y && y <= 4+move_y) oled_data <= 0;
                                             else if (x == 19 && y == 10+move_y) oled_data <= 0;
                                             else if (x == 18 && y == 2+move_y) oled_data <= 0;
                                             else if (x == 18 && y == 10+move_y) oled_data <= 0;
                                             else if (x == 17 && y == 1+move_y) oled_data <= 0;
                                             else if (x == 17 && y == 11+move_y) oled_data <= 0;
                                             else if (x == 17 && y == 14+move_y) oled_data <= 0;
                                             else if (x == 16 && y == 1+move_y) oled_data <= 0;
                                             else if (x == 16 && y >= 7+move_y && y <= 8+move_y) oled_data <= 0;
                                             else if (x == 16 && y >= 11 && y <= 13+move_y) oled_data <= 0;
                                             else if (x == 16 && y == 15+move_y) oled_data <= 0;
                                             else if (x == 15 && y == 1+move_y) oled_data <= 0;
                                             else if (x == 15 && y >= 6+move_y && y <= 8+move_y) oled_data <= 0;
                                             else if (x == 15 && y == 11+move_y) oled_data <= 0;
                                             else if (x == 15 && y >= 14+move_y && y <= 15+move_y) oled_data <= 0;
                                             else if (x == 14 && y == 1+move_y) oled_data <= 0;
                                             else if (x == 14 && y == 15+move_y) oled_data <= 0;
                                             else if (x == 13 && y == 2+move_y) oled_data <= 0;
                                             else if (x == 13 && y == 12+move_y) oled_data <= 0;
                                             else if (x == 13 && y == 16+move_y) oled_data <= 0;
                                             else if (x == 12 && y >= 3+move_y && y <= 4+move_y) oled_data <= 0; 
                                             else if (x == 12 && y == 11+move_y) oled_data <= 0;
                                             else if (x == 12 && y == 13+move_y) oled_data <= 0;
                                             else if (x == 12 && y >= 16+move_y && y <= 17+move_y) oled_data <= 0;
                                             else if (x == 11 && y >= 5+move_y && y <= 6+move_y) oled_data <= 0;  
                                             else if (x == 11 && y == 13+move_y) oled_data <= 0;
                                             else if (x == 11 && y == 16+move_y) oled_data <= 0;
                                             else if (x == 11 && y == 18+move_y) oled_data <= 0;
                                             else if (x == 10 && y >= 7+move_y && y <= 8+move_y) oled_data <= 0;
                                             else if (x == 10 && y == 18+move_y) oled_data <= 0;
                                             else if (x == 9 && y == 9+move_y) oled_data <= 0;
                                             else if (x == 9 && y == 16+move_y) oled_data <= 0;
                                             else if (x == 9 && y == 18+move_y) oled_data <= 0;
                                             else if (x == 8 && y >= 10+move_y && y <= 11+move_y) oled_data <= 0;
                                             else if (x == 8 && y >= 15+move_y && y <= 18+move_y) oled_data <= 0;
                                             else if (x == 7 && y >= 11+move_y && y <= 15+move_y) oled_data <= 0;
                                             else if (x == 6 && y >= 5+move_y && y <= 7+move_y) oled_data <= 0;
                                             else if (x == 6 && y == 10+move_y) oled_data <= 0;
                                             else if (x == 6 && y == 14+move_y) oled_data <= 0;
                                             else if (x == 5 && y >= 2+move_y && y <= 4+move_y) oled_data <= 0;
                                             else if (x == 5 && y >= 8+move_y && y <= 9+move_y) oled_data <= 0;
                                             else if (x == 5 && y == 13+move_y) oled_data <= 0;
                                             else if (x == 4 && y == 1+move_y) oled_data <= 0;
                                             else if (x == 4 && y >= 11+move_y && y <= 12+move_y) oled_data <= 0;
                                             else if (x == 3 && y == 2+move_y) oled_data <= 0;
                                             else if (x == 3 && y >= 8+move_y && y <= 10+move_y) oled_data <= 0;
                                             else if (x == 2 && y >= 3+move_y && y <= 4+move_y) oled_data <= 0;
                                             else if (x == 2 && y == 8+move_y) oled_data <= 0;
                                             else if (x == 1 && y >= 5+move_y && y <= 7+move_y) oled_data <= 0; 
                                             
                                             //YELLOW DETAILS
                                             else if (x == 15 && y >= 12+move_y && y <= 13+move_y) oled_data <= 16'hFF80;
                                             else if (x == 14 && y >= 12+move_y && y <= 14+move_y) oled_data <= 16'hFF80;
                                             else if (x == 13 && y >= 13+move_y && y <= 15+move_y) oled_data <= 16'hFF80;
                                             else if (x == 12 && y >= 14+move_y && y <= 15+move_y) oled_data <= 16'hFF80;
                                             else if (x == 4 && y >= 7+move_y && y <= 8+move_y) oled_data <= 16'hFF80;
                                             else if (x == 3 && y >= 6+move_y && y <= 7+move_y) oled_data <= 16'hFF80;
                                             
                                             //WHITE DETAILS
                                             else if (x == 16 && y == 6+move_y) oled_data <= 16'hFFFF;
                                             else if (x == 16 && y == 14+move_y) oled_data <= 16'hFFFF;
                                             else if (x == 11 && y == 17+move_y) oled_data <= 16'hFFFF;
                                             else if (x == 9 && y == 17+move_y) oled_data <= 16'hFFFF;
                                             
                                             //ORANGE BODY
                                             else if (x == 20 && y >= 6+move_y && y <= 8+move_y) oled_data <= 16'hFD40;
                                             else if (x == 19 && y >= 5+move_y && y <= 9+move_y) oled_data <= 16'hFD40;
                                             else if (x == 18 && y >= 3+move_y && y <= 9+move_y) oled_data <= 16'hFD40;
                                             else if (x == 17 && y >= 2+move_y && y <= 10+move_y) oled_data <= 16'hFD40;
                                             else if (x == 16 && y >= 2+move_y && y <= 5+move_y) oled_data <= 16'hFD40;
                                             else if (x == 16 && y >= 9+move_y && y <= 10+move_y) oled_data <= 16'hFD40;
                                             else if (x == 15 && y >= 2+move_y && y <= 5+move_y) oled_data <= 16'hFD40;
                                             else if (x == 15 && y >= 9+move_y && y <= 10+move_y) oled_data <= 16'hFD40;
                                             else if (x == 14 && y >= 2+move_y && y <= 11+move_y) oled_data <= 16'hFD40;
                                             else if (x == 13 && y >= 3+move_y && y <= 11+move_y) oled_data <= 16'hFD40;
                                             else if (x == 12 && y >= 5+move_y && y <= 10+move_y) oled_data <= 16'hFD40;
                                             else if (x == 12 && y == 12+move_y) oled_data <= 16'hFD40;
                                             else if (x == 11 && y >= 7+move_y && y <= 12+move_y) oled_data <= 16'hFD40;
                                             else if (x == 11 && y >= 14+move_y && y <= 15+move_y) oled_data <= 16'hFD40;
                                             else if (x == 10 && y >= 9+move_y && y <= 17+move_y) oled_data <= 16'hFD40;
                                             else if (x == 9 && y >= 10+move_y && y <= 15+move_y) oled_data <= 16'hFD40;
                                             else if (x == 8 && y >= 12+move_y && y <= 14+move_y) oled_data <= 16'hFD40;
                                             else if (x == 6 && y >= 11+move_y && y <= 13+move_y) oled_data <= 16'hFD40;
                                             else if (x == 5 && y >= 10+move_y && y <= 12+move_y) oled_data <= 16'hFD40;
                                             else if (x == 4 && y >= 9+move_y && y <= 10+move_y) oled_data <= 16'hFD40;
                                             
                                             //RED TAIL
                                             else if (x == 5 && y >= 5+move_y && y <= 7+move_y) oled_data <= 16'hF800;
                                             else if (x == 4 && y >= 2+move_y && y <= 6+move_y) oled_data <= 16'hF800;
                                             else if (x == 3 && y >= 3+move_y && y <= 5+move_y) oled_data <= 16'hF800;
                                             else if (x == 2 && y >= 5+move_y && y <= 7+move_y) oled_data <= 16'hF800;
                                            // END OF CHARMANDER
                           
                                 //PIKACHU
                                 //OUTLINE
                                 else if ((x == 33+move_x && y == 8) ||(y == 9 && x > 32+move_x && x < 34+move_x)||(y==10 && x > 30+move_x && x < 34+move_x )) 
                                         oled_data <= 0;     
                                 else if ((y==11 && x > 30+move_x && x < 35+move_x)||(y==12 && x > 30+move_x && x < 35+move_x))
                                         oled_data <= 0;
                                 else if ((y==13 && x > 30+move_x && x < 36+move_x)||(y==13 && x > 57+move_x && x < 61+move_x))
                                         oled_data <= 0;
                                 else if ((y==14 && x > 29+move_x && x < 36+move_x)||(y==14 && x > 54+move_x && x <61+move_x))
                                         oled_data <= 0;
                                 else if ((y==15 && x > 29+move_x && x < 34+move_x)||(y==15 && x == 35+move_x ) || (y==15 &&  x> 52+move_x && x < 61+move_x))
                                         oled_data <= 0;
                                 else if ((y==16 && x > 29+move_x && x < 33+move_x)|| (y==16 && x ==36+move_x ) || (y==16 && x > 50+move_x && x < 60+move_x && x!=53+move_x))
                                         oled_data <= 0;
                                 else if ((y==17 && x == 30+move_x)||(y==17 && x == 31+move_x)|| (y==17 && x == 36+move_x )|| (y==17 && x == 51+move_x )||(y==17 && x > 53+move_x && x < 60+move_x))
                                         oled_data <= 0;
                                 else if ((y==18 && x == 31+move_x )||(y==18 && x == 36+move_x)|| (y==18 && x == 48+move_x)|| (y==18 && x == 49+move_x)||(y==18 && x>54+move_x && x <59+move_x ))
                                         oled_data <= 0;
                                 else if ((y==19 && x == 31+move_x )||(y==19 && x == 36+move_x)||(y==19 && x == 47+move_x)||(y==19 && x > 54+move_x && x < 58+move_x))
                                         oled_data <= 0;
                                 else if ((y==20 && x == 32+move_x )|| (y==20 && x > 35+move_x && x <47+move_x )||(y==20 && x == 55+move_x )||(y==20 && x == 56+move_x ))
                                         oled_data <= 0;
                                 else if ((y==21 && x == 32+move_x )|| (y==21 && x == 35+move_x )||(y==21 && x == 36+move_x )||(y==21 && x == 54+move_x  ))
                                         oled_data <= 0;
                                 else if ((y==22 && x == 33+move_x )|| (y==22 && x == 52+move_x )|| (y==22 && x == 53+move_x)|| (y==22 && x == 64+move_x)|| (y==22 && x == 65+move_x))
                                         oled_data <= 0;
                                 else if ((y==23 && x == 32+move_x )|| (y==23 && x == 50+move_x )|| (y==23 && x == 51+move_x)|| (y==23 && x == 62+move_x)|| (y==23 && x == 63+move_x)|| (y==23 && x == 66+move_x))
                                         oled_data <= 0;
                                 else if ((y==24 && x == 31+move_x )|| (y==24 && x == 44+move_x )|| (y==24 && x == 45+move_x)|| (y==24 && x == 50+move_x)|| (y==24 && x == 61+move_x)|| (y==24 && x == 66+move_x))
                                         oled_data <= 0;
                                 else if ((y==25 && x == 31+move_x )||(y==25 && x == 33+move_x )|| (y==25 && x == 34+move_x )|| (y==25 && x == 43+move_x)|| (y==25 && x == 45+move_x)|| (y==25 && x == 46+move_x)|| (y==25 && x == 51+move_x)|| (y==25 && x == 60+move_x)|| (y==25 && x == 66+move_x))
                                         oled_data <= 0;
                                 else if ((y==26 && x == 30+move_x )||(y==26 && x == 32+move_x )||(y==26 && x == 34+move_x )||(y==26 && x == 43+move_x )||(y==26 && x == 44+move_x )||(y==26 && x == 46+move_x )||(y==26 && x == 51+move_x )||(y==26 && x == 58+move_x )||(y==26 && x == 59+move_x )||(y==26 && x == 67+move_x ))
                                         oled_data <= 0;
                                 else if ((y==27 && x == 30+move_x )||(y==27 && x == 32+move_x )|| (y==27 && x == 33+move_x )||(y==27 && x == 44+move_x )||(y==27 && x == 45+move_x )||(y==27 && x == 51+move_x )||(y==27 && x == 57+move_x )||(y==27 && x == 67+move_x ))
                                         oled_data <= 0;
                                 else if ((y==28 && x == 29+move_x )||(y==28 && x == 32+move_x )||(y==28 && x == 33+move_x )||(y==28 && x == 37+move_x )||(y==28 && x == 52+move_x )||(y==28 && x == 55+move_x )||(y==28 && x == 56+move_x )||(y==28 && x == 67+move_x ))
                                         oled_data <= 0;
                                 else if ((y==29 && x ==29+move_x)||(y==29 && x >51+move_x && x<55+move_x)||(y==29 && x ==67+move_x))
                                         oled_data <= 0;
                                 else if ((y==30 && x == 29+move_x)||(y==30 && x == 36+move_x)||(y==30 && x > 50+move_x && x < 56+move_x && x!= 53+move_x)||(y==30 && x ==67+move_x)) 
                                         oled_data <= 0;
                                 else if ((y==31 && x ==28+move_x)||(y==31 && x ==30+move_x)||(y==31 && x ==50+move_x)||(y==31 && x ==52+move_x)||(y==31 && x ==56+move_x)||(y==31 && x ==67+move_x))
                                         oled_data <= 0;
                                 else if ((y==32 && x ==27+move_x)||(y==32 && x ==29+move_x)||(y==32 && x ==30+move_x)||(y==32 && x ==50+move_x)||(y==32 && x ==55+move_x)||(y==32 && x ==56+move_x)||(y==32 && x ==65+move_x)||(y==32 && x ==66+move_x))
                                         oled_data <= 0;
                                 else if ((y==33 && x ==26+move_x)||(y==33 && x ==31+move_x)||(y==33 && x ==49+move_x)||(y==33 && x ==56+move_x)||(y==33 && x ==63+move_x)||(y==33 && x ==64+move_x))
                                         oled_data <= 0;
                                 else if ((y==34 && x ==27+move_x)||(y==34 && x ==32+move_x)||(y==34 && x ==48+move_x)||(y==34 && x ==55+move_x)||(y==34 && x ==61+move_x)||(y==34 && x ==62+move_x))
                                         oled_data <= 0;
                                 else if ((y==35 && x ==27+move_x)||(y==35 && x ==32+move_x)||(y==35 && x ==33+move_x)||(y==35 && x ==55+move_x)||(y==35 && x ==60+move_x))
                                         oled_data <= 0;
                                 else if ((y==36 && x ==28+move_x)||(y==36 && x ==32+move_x)||(y==36 && x ==54+move_x)||(y==36 && x ==55+move_x)||(y==36 && x ==59+move_x))
                                         oled_data <= 0;
                                 else if ((y==37 && x ==29+move_x)||(y==37 && x ==53+move_x)||(y==37 && x ==56+move_x)||(y==37 && x ==60+move_x))
                                         oled_data <= 0;
                                 else if ((y==38 && x ==30+move_x)||(y==38 && x ==31+move_x)||(y==38 && x ==53+move_x)||(y==38 && x ==57)||(y==38 && x ==61))
                                         oled_data <= 0;
                                 else if ((y==39 && x ==31+move_x)||(y==39 && x >49+move_x && x<53+move_x)||(y==39 && x ==55+move_x)||(y==39 && x ==56+move_x)||(y==39 && x ==62+move_x))
                                         oled_data <= 0;
                                 else if ((y==40 && x ==30+move_x)||(y==40 && x >51+move_x && x<55+move_x)||(y==40 && x ==60+move_x)||(y==40 && x ==61+move_x))
                                         oled_data <= 0;
                                 else if ((y==41 && x ==30+move_x)||(y>40 && y<49 && x ==51+move_x)||(y==41 && x ==52+move_x)||(y==41 && x ==58+move_x)||(y==41 && x ==59+move_x))
                                         oled_data <= 0;
                                 else if ((y==42 && x ==29+move_x)||(y==42 && x ==56+move_x)||(y==42 && x ==57+move_x))
                                         oled_data <= 0;
                                 else if ((y==43 && x>27+move_x && x <31+move_x)||(y==43 && x ==55+move_x)) 
                                         oled_data <= 0;
                                 else if ((y==44 && x ==27+move_x)||(y==44 && x ==30+move_x)||(y==44 && x ==31+move_x)||(y==44 && x ==56+move_x))
                                         oled_data <= 0;
                                 else if ((y==45 && x ==27+move_x)||(y==45 && x ==28+move_x)||(y==45 && x ==30+move_x)||(y==45 && x ==32+move_x)||(y==45 && x ==57+move_x))
                                         oled_data <= 0;
                                 else if ((y==46 && x ==27+move_x)||(y==46 && x ==32+move_x)||(y==46 && x ==58+move_x))
                                         oled_data <= 0;
                                 else if ((y==47 && x ==28+move_x)||(y==47 && x ==33+move_x)||(y==47 && x>54+move_x && x <58+move_x))
                                         oled_data <= 0;
                                 else if ((y==48 && x ==29+move_x)||(y==48 && x >49+move_x && x<55+move_x))
                                         oled_data <= 0;
                                 else if ((y==49 && x ==29+move_x)||(y==49 && x ==33+move_x)||(y==49 && x ==50+move_x))
                                         oled_data <= 0;
                                 else if ((y==50 && x >28+move_x && x<33+move_x)||(y==50 && x ==49+move_x)||(y==50 && x ==50+move_x))
                                         oled_data <= 0;
                                 else if ((y==51 && x >32+move_x && x<39+move_x)||(y==51 && x ==49+move_x))
                                         oled_data <= 0;
                                 else if ((y==52 && x >37+move_x && x<41+move_x)||(y==52 && x >45+move_x && x<49+move_x))
                                         oled_data <= 0;
                                 else if ((y==53 && x >39+move_x && x<47+move_x))
                                         oled_data <= 0;
                                 else if ((y==54 && x ==40+move_x)||(y==54 && x ==45+move_x))
                                         oled_data <= 0;
                                 else if ((y==55 && x ==40+move_x)||(y==55 && x ==45+move_x))
                                         oled_data <= 0;
                                 else if ((y==56 && x ==40+move_x)||(y==56 && x ==42+move_x)||(y==56 && x ==44+move_x))
                                         oled_data <= 0;
                                 else if ((y==57 && x >40+move_x && x<44+move_x))
                                         oled_data <= 0;
                                 
                                 //RED
                                 else if ((x==30+move_x && y ==29) || (x==30+move_x && y ==30) || (x==41+move_x && y ==29)) 
                                         oled_data <= 16'hF000;
                                 else if ((x==31+move_x && y ==31)||(x==31+move_x && y ==32))
                                         oled_data <= 16'hF000;
                                 else if ((y>29 && y < 33 && x>36+move_x && x<41+move_x )||(x==38+move_x && y ==33)||(x==39+move_x && y ==33))
                                         oled_data <= 16'hF000;
                                 else if ((y>28 && y < 32 && x>45+move_x && x<50+move_x)||(x==47+move_x && y ==28)||(x==48+move_x && y ==28)||(x==47+move_x && y ==32)||(x==48+move_x && y ==32))
                                         oled_data <= 16'hF000;
                                 
                                 //Yellow
                                 else if ((x==34+move_x && y==15))
                                         oled_data <= 16'hFFE0;
                                 else if ((y==16 && x==53+move_x)||(y==16 && x>32+move_x && x<36+move_x))
                                         oled_data <= 16'hFFE0;
                                 else if ((y==17 && x>31+move_x && x<36+move_x)||(y==17 && x>50+move_x && x<54+move_x))
                                         oled_data <= 16'hFFE0;
                                 else if ((y==18 && x>31+move_x && x<36+move_x)||(y==18 && x>49+move_x && x<55+move_x))
                                         oled_data <= 16'hFFE0;
                                 else if ((y==19 && x>31+move_x && x<36+move_x)||(y==19 && x>47+move_x && x<55+move_x))
                                         oled_data <= 16'hFFE0;
                                 else if ((y==20 && x>32+move_x && x<36+move_x)||(y==20 && x>46+move_x && x<55+move_x))
                                         oled_data <= 16'hFFE0;
                                 else if ((y==21 && x==33+move_x)||(y==21 && x==34+move_x)||(y==21 && x>36+move_x && x<54+move_x))
                                         oled_data <= 16'hFFE0;
                                 else if ((y==22 && x>33+move_x && x<52+move_x))
                                         oled_data <= 16'hFFE0;
                                 else if ((y==23 && x>32+move_x && x<50+move_x)||(y==23 && x==64+move_x)||(y==23 && x==65+move_x))
                                         oled_data <= 16'hFFE0;
                                 else if ((y==24 && x> 31+move_x && x<50+move_x && x!=44+move_x && x != 45+move_x)||(y==24 && x>61+move_x && x<66+move_x))
                                         oled_data <= 16'hFFE0;
                                 else if ((y==25 && x==32+move_x)||(y==25 && x>34+move_x && x<43+move_x)||(y==25 && x>46+move_x && x<51+move_x)||(y==25 && x>60+move_x && x<66+move_x))
                                         oled_data <= 16'hFFE0;
                                 else if ((y==26 && x==31+move_x)||(y==26 && x>34+move_x && x<43+move_x)||(y==26 && x>46+move_x && x<51+move_x)||(y==26 && x>59+move_x && x<67+move_x))
                                         oled_data <= 16'hFFE0;
                                 else if ((y==27 && x==31+move_x)||(y==27 && x>33+move_x && x<44+move_x)||(y==27 && x>46+move_x && x<51+move_x)||(y==27 && x>57+move_x && x<67+move_x))
                                         oled_data <= 16'hFFE0;
                                 else if ((y==28 && x==30+move_x)||(y==28 && x==31+move_x)||(y==28 && x>33+move_x && x<47+move_x && x!= 37+move_x)||(y==28 && x>48+move_x && x<52+move_x)||(y==28 && x>56+move_x && x<67+move_x))
                                         oled_data <= 16'hFFE0;
                                 else if ((y==29 && x==50+move_x)||(y==29 && x==51+move_x)||(y==29 && x>30+move_x && x<46+move_x && x!=41+move_x)||(y==29 && x>54+move_x && x<67+move_x))
                                         oled_data <= 16'hFFE0;
                                 else if ((y==30 && x>30+move_x && x<36+move_x)||(y==30 && x>40+move_x && x<46+move_x)||(y==30 && x==50+move_x)||(y==30 && x==53+move_x)||(y==30 && x>55+move_x && x<67+move_x))
                                         oled_data <= 16'hFFE0;
                                 else if ((y==31 && x>31+move_x && x<37+move_x)||(y==31 && x>40+move_x && x<46+move_x)||(y==31 && x>50+move_x && x<67+move_x && x!= 52+move_x && x!= 56+move_x))
                                         oled_data <= 16'hFFE0;
                                 else if ((y==32 && x==28+move_x)||(y==32 && x>31+move_x && x<36+move_x)||(y==32 && x>40+move_x && x<47+move_x)||(y==32 && x==49+move_x)||(y==32 && x>50+move_x && x<65+move_x && x!=55+move_x && x!=56+move_x))
                                         oled_data <= 16'hFFE0;
                                 else if ((y==33 && x>26+move_x && x<60+move_x)||(y==33 && x>31+move_x && x<63+move_x && x != 38+move_x && x!=39+move_x && x!= 49+move_x && x!= 56+move_x))
                                         oled_data <= 16'hFFE0;
                                 else if ((y==34 && x>27+move_x && x<31+move_x)||(y==34 && x>32+move_x && x<61+move_x && x!=48+move_x && x!=55+move_x))
                                         oled_data <= 16'hFFE0;
                                 else if ((y==35 && x>27+move_x && x<60+move_x && x!=32+move_x && x!= 33+move_x && x!= 55+move_x))
                                         oled_data <= 16'hFFE0;
                                 else if ((y==36 && x>28+move_x && x<59+move_x && x!=32+move_x && x!=54+move_x && x!= 55+move_x))
                                         oled_data <= 16'hFFE0;
                                 else if ((y==37 && x>29+move_x && x<53+move_x)||(y==37 && x>56+move_x && x<60+move_x))
                                         oled_data <= 16'hFFE0;
                                 else if ((y==38 && x>31+move_x && x<53+move_x)||(y==38 && x>57+move_x && x<61+move_x))
                                         oled_data <= 16'hFFE0;
                                 else if ((y==39 && x>31+move_x && x<50+move_x)||(y==39 && x>56+move_x && x<62+move_x))
                                         oled_data <= 16'hFFE0;
                                 else if ((y==40 && x>30+move_x && x<52+move_x)||(y==40 && x>54+move_x && x<60+move_x))
                                         oled_data <= 16'hFFE0;
                                 else if ((y==41 && x>30+move_x && x<58+move_x && x!=51+move_x && x != 52+move_x))
                                         oled_data <= 16'hFFE0;
                                 else if ((y==42 && x>29+move_x && x<56+move_x && x!=51+move_x))
                                         oled_data <= 16'hFFE0;
                                 else if ((y==43 && x>30+move_x && x<55+move_x && x!=51+move_x))
                                         oled_data <= 16'hFFE0;
                                 else if ((y==44 && x>27+move_x && x<56+move_x && x!=30+move_x && x!=31+move_x && x!=51+move_x))
                                         oled_data <= 16'hFFE0;
                                 else if ((y==45 && x==29+move_x)||(y==45 && x==31+move_x)||(y==45 && x>32+move_x && x<57+move_x && x!=51+move_x))
                                         oled_data <= 16'hFFE0;
                                 else if ((y==46 && x>27+move_x && x<58+move_x && x!=32+move_x && x!=51+move_x))
                                         oled_data <= 16'hFFE0;
                                 else if ((y==47 && x>28+move_x && x<55+move_x && x!=33+move_x && x!=51+move_x))
                                         oled_data <= 16'hFFE0;
                                 else if ((y==48 && x>29+move_x && x<50+move_x && x!=33+move_x))
                                         oled_data <= 16'hFFE0;
                                 else if ((y==49 && x>29+move_x && x<50+move_x && x!=33+move_x))
                                         oled_data <= 16'hFFE0;
                                 else if ((y==50 && x>32+move_x && x<49+move_x))
                                         oled_data <= 16'hFFE0;
                                 else if ((y==51 && x>38+move_x && x<49+move_x))
                                         oled_data <= 16'hFFE0;
                                 else if ((y==52 && x>40+move_x && x<46+move_x))
                                         oled_data <= 16'hFFE0;
                                 else if ((y==54 && x>40+move_x && x<45+move_x))
                                         oled_data <= 16'hFFE0;
                                 else if ((y==55 && x>40+move_x && x<45+move_x))
                                         oled_data <= 16'hFFE0;
                                 else if ((y==56 && x==41+move_x)||(y==56 && x==43+move_x))
                                         oled_data <= 16'hFFE0;
                                 else if ((x == 45+move_x && y == 26) || (x == 44+move_x && y == 25) || (x == 33+move_x && y == 26))
                                         oled_data <= 16'hFFFF;
                                 //END PIKACHU
                                 //background
                                 else  oled_data <= 16'h01A0;
                         end  //END OF SCENE 1
                   2: begin // PIKACHU CHARMANDER AND ZAP
                        //SCENE 2 - PIKACHU, CHARMANDER AND ZAP 
                         //CHARMANDER
                                                  //BLACK COLOURS
                                                           if (x == 21 && y >= 6+move_y && y <= 8+move_y) oled_data <= (zap == 0) ? 0 : 16'hFFFF;     
                                                      else if (x == 20 && y == 5+move_y) oled_data <= (zap == 0) ? 0 : 16'hFFFF;
                                                      else if (x == 20 && y == 9+move_y) oled_data <= (zap == 0) ? 0 : 16'hFFFF;
                                                      else if (x == 19 && y >= 3+move_y && y <= 4+move_y) oled_data <= (zap == 0) ? 0 : 16'hFFFF;
                                                      else if (x == 19 && y == 10+move_y) oled_data <= (zap == 0) ? 0 : 16'hFFFF;
                                                      else if (x == 18 && y == 2+move_y) oled_data <= (zap == 0) ? 0 : 16'hFFFF;
                                                      else if (x == 18 && y == 10+move_y) oled_data <= (zap == 0) ? 0 : 16'hFFFF;
                                                      else if (x == 17 && y == 1+move_y) oled_data <= (zap == 0) ? 0 : 16'hFFFF;
                                                      else if (x == 17 && y == 11+move_y) oled_data <= (zap == 0) ? 0 : 16'hFFFF;
                                                      else if (x == 17 && y == 14+move_y) oled_data <= (zap == 0) ? 0 : 16'hFFFF;
                                                      else if (x == 16 && y == 1+move_y) oled_data <= (zap == 0) ? 0 : 16'hFFFF;
                                                      else if (x == 16 && y >= 7+move_y && y <= 8+move_y) oled_data <= (zap == 0) ? 0 : 16'hFFFF;
                                                      else if (x == 16 && y >= 11 && y <= 13+move_y) oled_data <= (zap == 0) ? 0 : 16'hFFFF;
                                                      else if (x == 16 && y == 15+move_y) oled_data <= (zap == 0) ? 0 : 16'hFFFF;
                                                      else if (x == 15 && y == 1+move_y) oled_data <= (zap == 0) ? 0 : 16'hFFFF;
                                                      else if (x == 15 && y >= 6+move_y && y <= 8+move_y) oled_data <= (zap == 0) ? 0 : 16'hFFFF;
                                                      else if (x == 15 && y == 11+move_y) oled_data <= (zap == 0) ? 0 : 16'hFFFF;
                                                      else if (x == 15 && y >= 14+move_y && y <= 15+move_y) oled_data <= (zap == 0) ? 0 : 16'hFFFF;
                                                      else if (x == 14 && y == 1+move_y) oled_data <= (zap == 0) ? 0 : 16'hFFFF;
                                                      else if (x == 14 && y == 15+move_y) oled_data <= (zap == 0) ? 0 : 16'hFFFF;
                                                      else if (x == 13 && y == 2+move_y) oled_data <= (zap == 0) ? 0 : 16'hFFFF;
                                                      else if (x == 13 && y == 12+move_y) oled_data <= (zap == 0) ? 0 : 16'hFFFF;
                                                      else if (x == 13 && y == 16+move_y) oled_data <= (zap == 0) ? 0 : 16'hFFFF;
                                                      else if (x == 12 && y >= 3+move_y && y <= 4+move_y) oled_data <= (zap == 0) ? 0 : 16'hFFFF; 
                                                      else if (x == 12 && y == 11+move_y) oled_data <= (zap == 0) ? 0 : 16'hFFFF;
                                                      else if (x == 12 && y == 13+move_y) oled_data <= (zap == 0) ? 0 : 16'hFFFF;
                                                      else if (x == 12 && y >= 16+move_y && y <= 17+move_y) oled_data <= (zap == 0) ? 0 : 16'hFFFF;
                                                      else if (x == 11 && y >= 5+move_y && y <= 6+move_y) oled_data <= (zap == 0) ? 0 : 16'hFFFF;  
                                                      else if (x == 11 && y == 13+move_y) oled_data <= (zap == 0) ? 0 : 16'hFFFF;
                                                      else if (x == 11 && y == 16+move_y) oled_data <= (zap == 0) ? 0 : 16'hFFFF;
                                                      else if (x == 11 && y == 18+move_y) oled_data <= (zap == 0) ? 0 : 16'hFFFF;
                                                      else if (x == 10 && y >= 7+move_y && y <= 8+move_y) oled_data <= (zap == 0) ? 0 : 16'hFFFF;
                                                      else if (x == 10 && y == 18+move_y) oled_data <= (zap == 0) ? 0 : 16'hFFFF;
                                                      else if (x == 9 && y == 9+move_y) oled_data <= (zap == 0) ? 0 : 16'hFFFF;
                                                      else if (x == 9 && y == 16+move_y) oled_data <= (zap == 0) ? 0 : 16'hFFFF;
                                                      else if (x == 9 && y == 18+move_y) oled_data <= (zap == 0) ? 0 : 16'hFFFF;
                                                      else if (x == 8 && y >= 10+move_y && y <= 11+move_y) oled_data <= (zap == 0) ? 0 : 16'hFFFF;
                                                      else if (x == 8 && y >= 15+move_y && y <= 18+move_y) oled_data <= (zap == 0) ? 0 : 16'hFFFF;
                                                      else if (x == 7 && y >= 11+move_y && y <= 15+move_y) oled_data <= (zap == 0) ? 0 : 16'hFFFF;
                                                      else if (x == 6 && y >= 5+move_y && y <= 7+move_y) oled_data <= (zap == 0) ? 0 : 16'hFFFF;
                                                      else if (x == 6 && y == 10+move_y) oled_data <= (zap == 0) ? 0 : 16'hFFFF;
                                                      else if (x == 6 && y == 14+move_y) oled_data <= (zap == 0) ? 0 : 16'hFFFF;
                                                      else if (x == 5 && y >= 2+move_y && y <= 4+move_y) oled_data <= (zap == 0) ? 0 : 16'hFFFF;
                                                      else if (x == 5 && y >= 8+move_y && y <= 9+move_y) oled_data <= (zap == 0) ? 0 : 16'hFFFF;
                                                      else if (x == 5 && y == 13+move_y) oled_data <= (zap == 0) ? 0 : 16'hFFFF;
                                                      else if (x == 4 && y == 1+move_y) oled_data <= (zap == 0) ? 0 : 16'hFFFF;
                                                      else if (x == 4 && y >= 11+move_y && y <= 12+move_y) oled_data <= (zap == 0) ? 0 : 16'hFFFF;
                                                      else if (x == 3 && y == 2+move_y) oled_data <= (zap == 0) ? 0 : 16'hFFFF;
                                                      else if (x == 3 && y >= 8+move_y && y <= 10+move_y) oled_data <= (zap == 0) ? 0 : 16'hFFFF;
                                                      else if (x == 2 && y >= 3+move_y && y <= 4+move_y) oled_data <= (zap == 0) ? 0 : 16'hFFFF;
                                                      else if (x == 2 && y == 8+move_y) oled_data <= (zap == 0) ? 0 : 16'hFFFF;
                                                      else if (x == 1 && y >= 5+move_y && y <= 7+move_y) oled_data <= (zap == 0) ? 0 : 16'hFFFF; 
                                                      
                                                      //YELLOW DETAILS
                                                      else if (x == 15 && y >= 12+move_y && y <= 13+move_y) oled_data <= (zap == 0) ? 16'hFF80 : 16'hFFFF;
                                                      else if (x == 14 && y >= 12+move_y && y <= 14+move_y) oled_data <= (zap == 0) ? 16'hFF80 : 16'hFFFF;
                                                      else if (x == 13 && y >= 13+move_y && y <= 15+move_y) oled_data <= (zap == 0) ? 16'hFF80 : 16'hFFFF;
                                                      else if (x == 12 && y >= 14+move_y && y <= 15+move_y) oled_data <= (zap == 0) ? 16'hFF80 : 16'hFFFF;
                                                      else if (x == 4 && y >= 7+move_y && y <= 8+move_y) oled_data <= (zap == 0) ? 16'hFF80 : 16'hFFFF;
                                                      else if (x == 3 && y >= 6+move_y && y <= 7+move_y) oled_data <= (zap == 0) ? 16'hFF80 : 16'hFFFF;
                                                      
                                                      //WHITE DETAILS
                                                      else if (x == 16 && y == 6+move_y) oled_data <= 16'hFFFF;
                                                      else if (x == 16 && y == 14+move_y) oled_data <= 16'hFFFF;
                                                      else if (x == 11 && y == 17+move_y) oled_data <= 16'hFFFF;
                                                      else if (x == 9 && y == 17+move_y) oled_data <= 16'hFFFF;
                                                      
                                                      //ORANGE BODY
                                                      else if (x == 20 && y >= 6+move_y && y <= 8+move_y) oled_data <= (zap == 0) ? 16'hFD40 : 16'hFFFF;
                                                      else if (x == 19 && y >= 5+move_y && y <= 9+move_y) oled_data <= (zap == 0) ? 16'hFD40 : 16'hFFFF;
                                                      else if (x == 18 && y >= 3+move_y && y <= 9+move_y) oled_data <= (zap == 0) ? 16'hFD40 : 16'hFFFF;
                                                      else if (x == 17 && y >= 2+move_y && y <= 10+move_y) oled_data <= (zap == 0) ? 16'hFD40 : 16'hFFFF;
                                                      else if (x == 16 && y >= 2+move_y && y <= 5+move_y) oled_data <= (zap == 0) ? 16'hFD40 : 16'hFFFF;
                                                      else if (x == 16 && y >= 9+move_y && y <= 10+move_y) oled_data <= (zap == 0) ? 16'hFD40 : 16'hFFFF;
                                                      else if (x == 15 && y >= 2+move_y && y <= 5+move_y) oled_data <= (zap == 0) ? 16'hFD40 : 16'hFFFF;
                                                      else if (x == 15 && y >= 9+move_y && y <= 10+move_y) oled_data <= (zap == 0) ? 16'hFD40 : 16'hFFFF;
                                                      else if (x == 14 && y >= 2+move_y && y <= 11+move_y) oled_data <= (zap == 0) ? 16'hFD40 : 16'hFFFF;
                                                      else if (x == 13 && y >= 3+move_y && y <= 11+move_y) oled_data <= (zap == 0) ? 16'hFD40 : 16'hFFFF;
                                                      else if (x == 12 && y >= 5+move_y && y <= 10+move_y) oled_data <= (zap == 0) ? 16'hFD40 : 16'hFFFF;
                                                      else if (x == 12 && y == 12+move_y) oled_data <= (zap == 0) ? 16'hFD40 : 16'hFFFF;
                                                      else if (x == 11 && y >= 7+move_y && y <= 12+move_y) oled_data <= (zap == 0) ? 16'hFD40 : 16'hFFFF;
                                                      else if (x == 11 && y >= 14+move_y && y <= 15+move_y) oled_data <= (zap == 0) ? 16'hFD40 : 16'hFFFF;
                                                      else if (x == 10 && y >= 9+move_y && y <= 17+move_y) oled_data <= (zap == 0) ? 16'hFD40 : 16'hFFFF;
                                                      else if (x == 9 && y >= 10+move_y && y <= 15+move_y) oled_data <= (zap == 0) ? 16'hFD40 : 16'hFFFF;
                                                      else if (x == 8 && y >= 12+move_y && y <= 14+move_y) oled_data <= (zap == 0) ? 16'hFD40 : 16'hFFFF;
                                                      else if (x == 6 && y >= 11+move_y && y <= 13+move_y) oled_data <= (zap == 0) ? 16'hFD40 : 16'hFFFF;
                                                      else if (x == 5 && y >= 10+move_y && y <= 12+move_y) oled_data <= (zap == 0) ? 16'hFD40 : 16'hFFFF;
                                                      else if (x == 4 && y >= 9+move_y && y <= 10+move_y) oled_data <= (zap == 0) ? 16'hFD40 : 16'hFFFF;
                                                      
                                                      //RED TAIL
                                                      else if (x == 5 && y >= 5+move_y && y <= 7+move_y) oled_data <= (zap == 0) ? 16'hF800 : 16'hFFFF;
                                                      else if (x == 4 && y >= 2+move_y && y <= 6+move_y) oled_data <= (zap == 0) ? 16'hF800 : 16'hFFFF;
                                                      else if (x == 3 && y >= 3+move_y && y <= 5+move_y) oled_data <= (zap == 0) ? 16'hF800 : 16'hFFFF;
                                                      else if (x == 2 && y >= 5+move_y && y <= 7+move_y) oled_data <= (zap == 0) ? 16'hF800 : 16'hFFFF;
                                                     // END OF CHARMANDER
                               
                                     //PIKACHU
                                     //OUTLINE
                                     else if ((x == 33+move_x && y == 8) ||(y == 9 && x > 32+move_x && x < 34+move_x)||(y==10 && x > 30+move_x && x < 34+move_x )) 
                                             oled_data <= 0;     
                                     else if ((y==11 && x > 30+move_x && x < 35+move_x)||(y==12 && x > 30+move_x && x < 35+move_x))
                                             oled_data <= 0;
                                     else if ((y==13 && x > 30+move_x && x < 36+move_x)||(y==13 && x > 57+move_x && x < 61+move_x))
                                             oled_data <= 0;
                                     else if ((y==14 && x > 29+move_x && x < 36+move_x)||(y==14 && x > 54+move_x && x <61+move_x))
                                             oled_data <= 0;
                                     else if ((y==15 && x > 29+move_x && x < 34+move_x)||(y==15 && x == 35+move_x ) || (y==15 &&  x> 52+move_x && x < 61+move_x))
                                             oled_data <= 0;
                                     else if ((y==16 && x > 29+move_x && x < 33+move_x)|| (y==16 && x ==36+move_x ) || (y==16 && x > 50+move_x && x < 60+move_x && x!=53+move_x))
                                             oled_data <= 0;
                                     else if ((y==17 && x == 30+move_x)||(y==17 && x == 31+move_x)|| (y==17 && x == 36+move_x )|| (y==17 && x == 51+move_x )||(y==17 && x > 53+move_x && x < 60+move_x))
                                             oled_data <= 0;
                                     else if ((y==18 && x == 31+move_x )||(y==18 && x == 36+move_x)|| (y==18 && x == 48+move_x)|| (y==18 && x == 49+move_x)||(y==18 && x>54+move_x && x <59+move_x ))
                                             oled_data <= 0;
                                     else if ((y==19 && x == 31+move_x )||(y==19 && x == 36+move_x)||(y==19 && x == 47+move_x)||(y==19 && x > 54+move_x && x < 58+move_x))
                                             oled_data <= 0;
                                     else if ((y==20 && x == 32+move_x )|| (y==20 && x > 35+move_x && x <47+move_x )||(y==20 && x == 55+move_x )||(y==20 && x == 56+move_x ))
                                             oled_data <= 0;
                                     else if ((y==21 && x == 32+move_x )|| (y==21 && x == 35+move_x )||(y==21 && x == 36+move_x )||(y==21 && x == 54+move_x  ))
                                             oled_data <= 0;
                                     else if ((y==22 && x == 33+move_x )|| (y==22 && x == 52+move_x )|| (y==22 && x == 53+move_x)|| (y==22 && x == 64+move_x)|| (y==22 && x == 65+move_x))
                                             oled_data <= 0;
                                     else if ((y==23 && x == 32+move_x )|| (y==23 && x == 50+move_x )|| (y==23 && x == 51+move_x)|| (y==23 && x == 62+move_x)|| (y==23 && x == 63+move_x)|| (y==23 && x == 66+move_x))
                                             oled_data <= 0;
                                     else if ((y==24 && x == 31+move_x )|| (y==24 && x == 44+move_x )|| (y==24 && x == 45+move_x)|| (y==24 && x == 50+move_x)|| (y==24 && x == 61+move_x)|| (y==24 && x == 66+move_x))
                                             oled_data <= 0;
                                     else if ((y==25 && x == 31+move_x )||(y==25 && x == 33+move_x )|| (y==25 && x == 34+move_x )|| (y==25 && x == 43+move_x)|| (y==25 && x == 45+move_x)|| (y==25 && x == 46+move_x)|| (y==25 && x == 51+move_x)|| (y==25 && x == 60+move_x)|| (y==25 && x == 66+move_x))
                                             oled_data <= 0;
                                     else if ((y==26 && x == 30+move_x )||(y==26 && x == 32+move_x )||(y==26 && x == 34+move_x )||(y==26 && x == 43+move_x )||(y==26 && x == 44+move_x )||(y==26 && x == 46+move_x )||(y==26 && x == 51+move_x )||(y==26 && x == 58+move_x )||(y==26 && x == 59+move_x )||(y==26 && x == 67+move_x ))
                                             oled_data <= 0;
                                     else if ((y==27 && x == 30+move_x )||(y==27 && x == 32+move_x )|| (y==27 && x == 33+move_x )||(y==27 && x == 44+move_x )||(y==27 && x == 45+move_x )||(y==27 && x == 51+move_x )||(y==27 && x == 57+move_x )||(y==27 && x == 67+move_x ))
                                             oled_data <= 0;
                                     else if ((y==28 && x == 29+move_x )||(y==28 && x == 32+move_x )||(y==28 && x == 33+move_x )||(y==28 && x == 37+move_x )||(y==28 && x == 52+move_x )||(y==28 && x == 55+move_x )||(y==28 && x == 56+move_x )||(y==28 && x == 67+move_x ))
                                             oled_data <= 0;
                                     else if ((y==29 && x ==29+move_x)||(y==29 && x >51+move_x && x<55+move_x)||(y==29 && x ==67+move_x))
                                             oled_data <= 0;
                                     else if ((y==30 && x == 29+move_x)||(y==30 && x == 36+move_x)||(y==30 && x > 50+move_x && x < 56+move_x && x!= 53+move_x)||(y==30 && x ==67+move_x)) 
                                             oled_data <= 0;
                                     else if ((y==31 && x ==28+move_x)||(y==31 && x ==30+move_x)||(y==31 && x ==50+move_x)||(y==31 && x ==52+move_x)||(y==31 && x ==56+move_x)||(y==31 && x ==67+move_x))
                                             oled_data <= 0;
                                     else if ((y==32 && x ==27+move_x)||(y==32 && x ==29+move_x)||(y==32 && x ==30+move_x)||(y==32 && x ==50+move_x)||(y==32 && x ==55+move_x)||(y==32 && x ==56+move_x)||(y==32 && x ==65+move_x)||(y==32 && x ==66+move_x))
                                             oled_data <= 0;
                                     else if ((y==33 && x ==26+move_x)||(y==33 && x ==31+move_x)||(y==33 && x ==49+move_x)||(y==33 && x ==56+move_x)||(y==33 && x ==63+move_x)||(y==33 && x ==64+move_x))
                                             oled_data <= 0;
                                     else if ((y==34 && x ==27+move_x)||(y==34 && x ==32+move_x)||(y==34 && x ==48+move_x)||(y==34 && x ==55+move_x)||(y==34 && x ==61+move_x)||(y==34 && x ==62+move_x))
                                             oled_data <= 0;
                                     else if ((y==35 && x ==27+move_x)||(y==35 && x ==32+move_x)||(y==35 && x ==33+move_x)||(y==35 && x ==55+move_x)||(y==35 && x ==60+move_x))
                                             oled_data <= 0;
                                     else if ((y==36 && x ==28+move_x)||(y==36 && x ==32+move_x)||(y==36 && x ==54+move_x)||(y==36 && x ==55+move_x)||(y==36 && x ==59+move_x))
                                             oled_data <= 0;
                                     else if ((y==37 && x ==29+move_x)||(y==37 && x ==53+move_x)||(y==37 && x ==56+move_x)||(y==37 && x ==60+move_x))
                                             oled_data <= 0;
                                     else if ((y==38 && x ==30+move_x)||(y==38 && x ==31+move_x)||(y==38 && x ==53+move_x)||(y==38 && x ==57)||(y==38 && x ==61))
                                             oled_data <= 0;
                                     else if ((y==39 && x ==31+move_x)||(y==39 && x >49+move_x && x<53+move_x)||(y==39 && x ==55+move_x)||(y==39 && x ==56+move_x)||(y==39 && x ==62+move_x))
                                             oled_data <= 0;
                                     else if ((y==40 && x ==30+move_x)||(y==40 && x >51+move_x && x<55+move_x)||(y==40 && x ==60+move_x)||(y==40 && x ==61+move_x))
                                             oled_data <= 0;
                                     else if ((y==41 && x ==30+move_x)||(y>40 && y<49 && x ==51+move_x)||(y==41 && x ==52+move_x)||(y==41 && x ==58+move_x)||(y==41 && x ==59+move_x))
                                             oled_data <= 0;
                                     else if ((y==42 && x ==29+move_x)||(y==42 && x ==56+move_x)||(y==42 && x ==57+move_x))
                                             oled_data <= 0;
                                     else if ((y==43 && x>27+move_x && x <31+move_x)||(y==43 && x ==55+move_x)) 
                                             oled_data <= 0;
                                     else if ((y==44 && x ==27+move_x)||(y==44 && x ==30+move_x)||(y==44 && x ==31+move_x)||(y==44 && x ==56+move_x))
                                             oled_data <= 0;
                                     else if ((y==45 && x ==27+move_x)||(y==45 && x ==28+move_x)||(y==45 && x ==30+move_x)||(y==45 && x ==32+move_x)||(y==45 && x ==57+move_x))
                                             oled_data <= 0;
                                     else if ((y==46 && x ==27+move_x)||(y==46 && x ==32+move_x)||(y==46 && x ==58+move_x))
                                             oled_data <= 0;
                                     else if ((y==47 && x ==28+move_x)||(y==47 && x ==33+move_x)||(y==47 && x>54+move_x && x <58+move_x))
                                             oled_data <= 0;
                                     else if ((y==48 && x ==29+move_x)||(y==48 && x >49+move_x && x<55+move_x))
                                             oled_data <= 0;
                                     else if ((y==49 && x ==29+move_x)||(y==49 && x ==33+move_x)||(y==49 && x ==50+move_x))
                                             oled_data <= 0;
                                     else if ((y==50 && x >28+move_x && x<33+move_x)||(y==50 && x ==49+move_x)||(y==50 && x ==50+move_x))
                                             oled_data <= 0;
                                     else if ((y==51 && x >32+move_x && x<39+move_x)||(y==51 && x ==49+move_x))
                                             oled_data <= 0;
                                     else if ((y==52 && x >37+move_x && x<41+move_x)||(y==52 && x >45+move_x && x<49+move_x))
                                             oled_data <= 0;
                                     else if ((y==53 && x >39+move_x && x<47+move_x))
                                             oled_data <= 0;
                                     else if ((y==54 && x ==40+move_x)||(y==54 && x ==45+move_x))
                                             oled_data <= 0;
                                     else if ((y==55 && x ==40+move_x)||(y==55 && x ==45+move_x))
                                             oled_data <= 0;
                                     else if ((y==56 && x ==40+move_x)||(y==56 && x ==42+move_x)||(y==56 && x ==44+move_x))
                                             oled_data <= 0;
                                     else if ((y==57 && x >40+move_x && x<44+move_x))
                                             oled_data <= 0;
                                     
                                     //RED
                                     else if ((x==30+move_x && y ==29) || (x==30+move_x && y ==30) || (x==41+move_x && y ==29)) 
                                             oled_data <= 16'hF000;
                                     else if ((x==31+move_x && y ==31)||(x==31+move_x && y ==32))
                                             oled_data <= 16'hF000;
                                     else if ((y>29 && y < 33 && x>36+move_x && x<41+move_x )||(x==38+move_x && y ==33)||(x==39+move_x && y ==33))
                                             oled_data <= 16'hF000;
                                     else if ((y>28 && y < 32 && x>45+move_x && x<50+move_x)||(x==47+move_x && y ==28)||(x==48+move_x && y ==28)||(x==47+move_x && y ==32)||(x==48+move_x && y ==32))
                                             oled_data <= 16'hF000;
                                     
                                     //Yellow
                                     else if ((x==34+move_x && y==15))
                                             oled_data <= 16'hFFE0;
                                     else if ((y==16 && x==53+move_x)||(y==16 && x>32+move_x && x<36+move_x))
                                             oled_data <= 16'hFFE0;
                                     else if ((y==17 && x>31+move_x && x<36+move_x)||(y==17 && x>50+move_x && x<54+move_x))
                                             oled_data <= 16'hFFE0;
                                     else if ((y==18 && x>31+move_x && x<36+move_x)||(y==18 && x>49+move_x && x<55+move_x))
                                             oled_data <= 16'hFFE0;
                                     else if ((y==19 && x>31+move_x && x<36+move_x)||(y==19 && x>47+move_x && x<55+move_x))
                                             oled_data <= 16'hFFE0;
                                     else if ((y==20 && x>32+move_x && x<36+move_x)||(y==20 && x>46+move_x && x<55+move_x))
                                             oled_data <= 16'hFFE0;
                                     else if ((y==21 && x==33+move_x)||(y==21 && x==34+move_x)||(y==21 && x>36+move_x && x<54+move_x))
                                             oled_data <= 16'hFFE0;
                                     else if ((y==22 && x>33+move_x && x<52+move_x))
                                             oled_data <= 16'hFFE0;
                                     else if ((y==23 && x>32+move_x && x<50+move_x)||(y==23 && x==64+move_x)||(y==23 && x==65+move_x))
                                             oled_data <= 16'hFFE0;
                                     else if ((y==24 && x> 31+move_x && x<50+move_x && x!=44+move_x && x != 45+move_x)||(y==24 && x>61+move_x && x<66+move_x))
                                             oled_data <= 16'hFFE0;
                                     else if ((y==25 && x==32+move_x)||(y==25 && x>34+move_x && x<43+move_x)||(y==25 && x>46+move_x && x<51+move_x)||(y==25 && x>60+move_x && x<66+move_x))
                                             oled_data <= 16'hFFE0;
                                     else if ((y==26 && x==31+move_x)||(y==26 && x>34+move_x && x<43+move_x)||(y==26 && x>46+move_x && x<51+move_x)||(y==26 && x>59+move_x && x<67+move_x))
                                             oled_data <= 16'hFFE0;
                                     else if ((y==27 && x==31+move_x)||(y==27 && x>33+move_x && x<44+move_x)||(y==27 && x>46+move_x && x<51+move_x)||(y==27 && x>57+move_x && x<67+move_x))
                                             oled_data <= 16'hFFE0;
                                     else if ((y==28 && x==30+move_x)||(y==28 && x==31+move_x)||(y==28 && x>33+move_x && x<47+move_x && x!= 37+move_x)||(y==28 && x>48+move_x && x<52+move_x)||(y==28 && x>56+move_x && x<67+move_x))
                                             oled_data <= 16'hFFE0;
                                     else if ((y==29 && x==50+move_x)||(y==29 && x==51+move_x)||(y==29 && x>30+move_x && x<46+move_x && x!=41+move_x)||(y==29 && x>54+move_x && x<67+move_x))
                                             oled_data <= 16'hFFE0;
                                     else if ((y==30 && x>30+move_x && x<36+move_x)||(y==30 && x>40+move_x && x<46+move_x)||(y==30 && x==50+move_x)||(y==30 && x==53+move_x)||(y==30 && x>55+move_x && x<67+move_x))
                                             oled_data <= 16'hFFE0;
                                     else if ((y==31 && x>31+move_x && x<37+move_x)||(y==31 && x>40+move_x && x<46+move_x)||(y==31 && x>50+move_x && x<67+move_x && x!= 52+move_x && x!= 56+move_x))
                                             oled_data <= 16'hFFE0;
                                     else if ((y==32 && x==28+move_x)||(y==32 && x>31+move_x && x<36+move_x)||(y==32 && x>40+move_x && x<47+move_x)||(y==32 && x==49+move_x)||(y==32 && x>50+move_x && x<65+move_x && x!=55+move_x && x!=56+move_x))
                                             oled_data <= 16'hFFE0;
                                     else if ((y==33 && x>26+move_x && x<60+move_x)||(y==33 && x>31+move_x && x<63+move_x && x != 38+move_x && x!=39+move_x && x!= 49+move_x && x!= 56+move_x))
                                             oled_data <= 16'hFFE0;
                                     else if ((y==34 && x>27+move_x && x<31+move_x)||(y==34 && x>32+move_x && x<61+move_x && x!=48+move_x && x!=55+move_x))
                                             oled_data <= 16'hFFE0;
                                     else if ((y==35 && x>27+move_x && x<60+move_x && x!=32+move_x && x!= 33+move_x && x!= 55+move_x))
                                             oled_data <= 16'hFFE0;
                                     else if ((y==36 && x>28+move_x && x<59+move_x && x!=32+move_x && x!=54+move_x && x!= 55+move_x))
                                             oled_data <= 16'hFFE0;
                                     else if ((y==37 && x>29+move_x && x<53+move_x)||(y==37 && x>56+move_x && x<60+move_x))
                                             oled_data <= 16'hFFE0;
                                     else if ((y==38 && x>31+move_x && x<53+move_x)||(y==38 && x>57+move_x && x<61+move_x))
                                             oled_data <= 16'hFFE0;
                                     else if ((y==39 && x>31+move_x && x<50+move_x)||(y==39 && x>56+move_x && x<62+move_x))
                                             oled_data <= 16'hFFE0;
                                     else if ((y==40 && x>30+move_x && x<52+move_x)||(y==40 && x>54+move_x && x<60+move_x))
                                             oled_data <= 16'hFFE0;
                                     else if ((y==41 && x>30+move_x && x<58+move_x && x!=51+move_x && x != 52+move_x))
                                             oled_data <= 16'hFFE0;
                                     else if ((y==42 && x>29+move_x && x<56+move_x && x!=51+move_x))
                                             oled_data <= 16'hFFE0;
                                     else if ((y==43 && x>30+move_x && x<55+move_x && x!=51+move_x))
                                             oled_data <= 16'hFFE0;
                                     else if ((y==44 && x>27+move_x && x<56+move_x && x!=30+move_x && x!=31+move_x && x!=51+move_x))
                                             oled_data <= 16'hFFE0;
                                     else if ((y==45 && x==29+move_x)||(y==45 && x==31+move_x)||(y==45 && x>32+move_x && x<57+move_x && x!=51+move_x))
                                             oled_data <= 16'hFFE0;
                                     else if ((y==46 && x>27+move_x && x<58+move_x && x!=32+move_x && x!=51+move_x))
                                             oled_data <= 16'hFFE0;
                                     else if ((y==47 && x>28+move_x && x<55+move_x && x!=33+move_x && x!=51+move_x))
                                             oled_data <= 16'hFFE0;
                                     else if ((y==48 && x>29+move_x && x<50+move_x && x!=33+move_x))
                                             oled_data <= 16'hFFE0;
                                     else if ((y==49 && x>29+move_x && x<50+move_x && x!=33+move_x))
                                             oled_data <= 16'hFFE0;
                                     else if ((y==50 && x>32+move_x && x<49+move_x))
                                             oled_data <= 16'hFFE0;
                                     else if ((y==51 && x>38+move_x && x<49+move_x))
                                             oled_data <= 16'hFFE0;
                                     else if ((y==52 && x>40+move_x && x<46+move_x))
                                             oled_data <= 16'hFFE0;
                                     else if ((y==54 && x>40+move_x && x<45+move_x))
                                             oled_data <= 16'hFFE0;
                                     else if ((y==55 && x>40+move_x && x<45+move_x))
                                             oled_data <= 16'hFFE0;
                                     else if ((y==56 && x==41+move_x)||(y==56 && x==43+move_x))
                                             oled_data <= 16'hFFE0;
                                     else if ((x == 45+move_x && y == 26) || (x == 44+move_x && y == 25) || (x == 33+move_x && y == 26))
                                             oled_data <= 16'hFFFF;
                                     //END PIKACHU
                                     
                                     //START LIGHTNING
                                     else if (y == 22 && x >= 18 && x <= 20) oled_data <= 16'hFFE0;
                                     else if (y == 22 && x == 33) oled_data <= 16'hFFE0;
                                     else if (y == 23 && x >= 18 && x <= 22) oled_data <= 16'hFFE0;
                                     else if (y == 23 && x >= 33 && x <= 35) oled_data <= 16'hFFE0;
                                     else if (y == 24 && x >= 19 && x <= 24) oled_data <= 16'hFFE0;
                                     else if (y == 24 && x >= 33 && x <= 36) oled_data <= 16'hFFE0;
                                     else if (y == 25 && x >= 20 && x <= 26) oled_data <= 16'hFFE0;
                                     else if (y == 25 && x >= 33 && x <= 37) oled_data <= 16'hFFE0;
                                     else if (y == 26 && x >= 21 && x <= 28) oled_data <= 16'hFFE0;
                                     else if (y == 26 && x >= 33 && x <= 39) oled_data <= 16'hFFE0;
                                     else if (y == 27 && x >= 22 && x <= 30) oled_data <= 16'hFFE0;
                                     else if (y == 27 && x >= 33 && x <= 40) oled_data <= 16'hFFE0;
                                     else if (y == 28 && x >= 23 && x <= 41) oled_data <= 16'hFFE0;
                                     else if (y == 29 && x >= 25 && x <= 42) oled_data <= 16'hFFE0;
                                     else if (y == 30 && x >= 27 && x <= 43) oled_data <= 16'hFFE0;
                                     else if (y == 31 && x >= 28 && x <= 45) oled_data <= 16'hFFE0;
                                     else if (y == 32 && x >= 30 && x <= 46) oled_data <= 16'hFFE0;
                                     else if (y == 33 && x >= 31 && x <= 48) oled_data <= 16'hFFE0;
                                     else if (y == 34 && x >= 33 && x <= 38) oled_data <= 16'hFFE0;
                                     else if (y == 34 && x >= 41 && x <= 49) oled_data <= 16'hFFE0;
                                     else if (y == 35 && x >= 34 && x <= 38) oled_data <= 16'hFFE0;
                                     else if (y == 35 && x >= 43 && x <= 50) oled_data <= 16'hFFE0;
                                     else if (y == 36 && x >= 36 && x <= 38) oled_data <= 16'hFFE0;
                                     else if (y == 36 && x >= 45 && x <= 51) oled_data <= 16'hFFE0;
                                     else if (y == 37 && x >= 50 && x <= 52) oled_data <= 16'hFFE0;
                                     
                                     //background
                                     else oled_data <= (zap == 1) ? 16'h01A0 : 16'hFFFF;
                         end  //END OF SCENE 2 - PIKA ZAP
                         
                   3:begin // JUST PIKA
                        //SCENE 3 - JUST PIKA
                           //PIKACHU
                                             //OUTLINE
                                              if ((x == 33+move_x && y == 8) ||(y == 9 && x > 32+move_x && x < 34+move_x)||(y==10 && x > 30+move_x && x < 34+move_x )) 
                                                     oled_data <= 0;     
                                             else if ((y==11 && x > 30+move_x && x < 35+move_x)||(y==12 && x > 30+move_x && x < 35+move_x))
                                                     oled_data <= 0;
                                             else if ((y==13 && x > 30+move_x && x < 36+move_x)||(y==13 && x > 57+move_x && x < 61+move_x))
                                                     oled_data <= 0;
                                             else if ((y==14 && x > 29+move_x && x < 36+move_x)||(y==14 && x > 54+move_x && x <61+move_x))
                                                     oled_data <= 0;
                                             else if ((y==15 && x > 29+move_x && x < 34+move_x)||(y==15 && x == 35+move_x ) || (y==15 &&  x> 52+move_x && x < 61+move_x))
                                                     oled_data <= 0;
                                             else if ((y==16 && x > 29+move_x && x < 33+move_x)|| (y==16 && x ==36+move_x ) || (y==16 && x > 50+move_x && x < 60+move_x && x!=53+move_x))
                                                     oled_data <= 0;
                                             else if ((y==17 && x == 30+move_x)||(y==17 && x == 31+move_x)|| (y==17 && x == 36+move_x )|| (y==17 && x == 51+move_x )||(y==17 && x > 53+move_x && x < 60+move_x))
                                                     oled_data <= 0;
                                             else if ((y==18 && x == 31+move_x )||(y==18 && x == 36+move_x)|| (y==18 && x == 48+move_x)|| (y==18 && x == 49+move_x)||(y==18 && x>54+move_x && x <59+move_x ))
                                                     oled_data <= 0;
                                             else if ((y==19 && x == 31+move_x )||(y==19 && x == 36+move_x)||(y==19 && x == 47+move_x)||(y==19 && x > 54+move_x && x < 58+move_x))
                                                     oled_data <= 0;
                                             else if ((y==20 && x == 32+move_x )|| (y==20 && x > 35+move_x && x <47+move_x )||(y==20 && x == 55+move_x )||(y==20 && x == 56+move_x ))
                                                     oled_data <= 0;
                                             else if ((y==21 && x == 32+move_x )|| (y==21 && x == 35+move_x )||(y==21 && x == 36+move_x )||(y==21 && x == 54+move_x  ))
                                                     oled_data <= 0;
                                             else if ((y==22 && x == 33+move_x )|| (y==22 && x == 52+move_x )|| (y==22 && x == 53+move_x)|| (y==22 && x == 64+move_x)|| (y==22 && x == 65+move_x))
                                                     oled_data <= 0;
                                             else if ((y==23 && x == 32+move_x )|| (y==23 && x == 50+move_x )|| (y==23 && x == 51+move_x)|| (y==23 && x == 62+move_x)|| (y==23 && x == 63+move_x)|| (y==23 && x == 66+move_x))
                                                     oled_data <= 0;
                                             else if ((y==24 && x == 31+move_x )|| (y==24 && x == 44+move_x )|| (y==24 && x == 45+move_x)|| (y==24 && x == 50+move_x)|| (y==24 && x == 61+move_x)|| (y==24 && x == 66+move_x))
                                                     oled_data <= 0;
                                             else if ((y==25 && x == 31+move_x )||(y==25 && x == 33+move_x )|| (y==25 && x == 34+move_x )|| (y==25 && x == 43+move_x)|| (y==25 && x == 45+move_x)|| (y==25 && x == 46+move_x)|| (y==25 && x == 51+move_x)|| (y==25 && x == 60+move_x)|| (y==25 && x == 66+move_x))
                                                     oled_data <= 0;
                                             else if ((y==26 && x == 30+move_x )||(y==26 && x == 32+move_x )||(y==26 && x == 34+move_x )||(y==26 && x == 43+move_x )||(y==26 && x == 44+move_x )||(y==26 && x == 46+move_x )||(y==26 && x == 51+move_x )||(y==26 && x == 58+move_x )||(y==26 && x == 59+move_x )||(y==26 && x == 67+move_x ))
                                                     oled_data <= 0;
                                             else if ((y==27 && x == 30+move_x )||(y==27 && x == 32+move_x )|| (y==27 && x == 33+move_x )||(y==27 && x == 44+move_x )||(y==27 && x == 45+move_x )||(y==27 && x == 51+move_x )||(y==27 && x == 57+move_x )||(y==27 && x == 67+move_x ))
                                                     oled_data <= 0;
                                             else if ((y==28 && x == 29+move_x )||(y==28 && x == 32+move_x )||(y==28 && x == 33+move_x )||(y==28 && x == 37+move_x )||(y==28 && x == 52+move_x )||(y==28 && x == 55+move_x )||(y==28 && x == 56+move_x )||(y==28 && x == 67+move_x ))
                                                     oled_data <= 0;
                                             else if ((y==29 && x ==29+move_x)||(y==29 && x >51+move_x && x<55+move_x)||(y==29 && x ==67+move_x))
                                                     oled_data <= 0;
                                             else if ((y==30 && x == 29+move_x)||(y==30 && x == 36+move_x)||(y==30 && x > 50+move_x && x < 56+move_x && x!= 53+move_x)||(y==30 && x ==67+move_x)) 
                                                     oled_data <= 0;
                                             else if ((y==31 && x ==28+move_x)||(y==31 && x ==30+move_x)||(y==31 && x ==50+move_x)||(y==31 && x ==52+move_x)||(y==31 && x ==56+move_x)||(y==31 && x ==67+move_x))
                                                     oled_data <= 0;
                                             else if ((y==32 && x ==27+move_x)||(y==32 && x ==29+move_x)||(y==32 && x ==30+move_x)||(y==32 && x ==50+move_x)||(y==32 && x ==55+move_x)||(y==32 && x ==56+move_x)||(y==32 && x ==65+move_x)||(y==32 && x ==66+move_x))
                                                     oled_data <= 0;
                                             else if ((y==33 && x ==26+move_x)||(y==33 && x ==31+move_x)||(y==33 && x ==49+move_x)||(y==33 && x ==56+move_x)||(y==33 && x ==63+move_x)||(y==33 && x ==64+move_x))
                                                     oled_data <= 0;
                                             else if ((y==34 && x ==27+move_x)||(y==34 && x ==32+move_x)||(y==34 && x ==48+move_x)||(y==34 && x ==55+move_x)||(y==34 && x ==61+move_x)||(y==34 && x ==62+move_x))
                                                     oled_data <= 0;
                                             else if ((y==35 && x ==27+move_x)||(y==35 && x ==32+move_x)||(y==35 && x ==33+move_x)||(y==35 && x ==55+move_x)||(y==35 && x ==60+move_x))
                                                     oled_data <= 0;
                                             else if ((y==36 && x ==28+move_x)||(y==36 && x ==32+move_x)||(y==36 && x ==54+move_x)||(y==36 && x ==55+move_x)||(y==36 && x ==59+move_x))
                                                     oled_data <= 0;
                                             else if ((y==37 && x ==29+move_x)||(y==37 && x ==53+move_x)||(y==37 && x ==56+move_x)||(y==37 && x ==60+move_x))
                                                     oled_data <= 0;
                                             else if ((y==38 && x ==30+move_x)||(y==38 && x ==31+move_x)||(y==38 && x ==53+move_x)||(y==38 && x ==57)||(y==38 && x ==61))
                                                     oled_data <= 0;
                                             else if ((y==39 && x ==31+move_x)||(y==39 && x >49+move_x && x<53+move_x)||(y==39 && x ==55+move_x)||(y==39 && x ==56+move_x)||(y==39 && x ==62+move_x))
                                                     oled_data <= 0;
                                             else if ((y==40 && x ==30+move_x)||(y==40 && x >51+move_x && x<55+move_x)||(y==40 && x ==60+move_x)||(y==40 && x ==61+move_x))
                                                     oled_data <= 0;
                                             else if ((y==41 && x ==30+move_x)||(y>40 && y<49 && x ==51+move_x)||(y==41 && x ==52+move_x)||(y==41 && x ==58+move_x)||(y==41 && x ==59+move_x))
                                                     oled_data <= 0;
                                             else if ((y==42 && x ==29+move_x)||(y==42 && x ==56+move_x)||(y==42 && x ==57+move_x))
                                                     oled_data <= 0;
                                             else if ((y==43 && x>27+move_x && x <31+move_x)||(y==43 && x ==55+move_x)) 
                                                     oled_data <= 0;
                                             else if ((y==44 && x ==27+move_x)||(y==44 && x ==30+move_x)||(y==44 && x ==31+move_x)||(y==44 && x ==56+move_x))
                                                     oled_data <= 0;
                                             else if ((y==45 && x ==27+move_x)||(y==45 && x ==28+move_x)||(y==45 && x ==30+move_x)||(y==45 && x ==32+move_x)||(y==45 && x ==57+move_x))
                                                     oled_data <= 0;
                                             else if ((y==46 && x ==27+move_x)||(y==46 && x ==32+move_x)||(y==46 && x ==58+move_x))
                                                     oled_data <= 0;
                                             else if ((y==47 && x ==28+move_x)||(y==47 && x ==33+move_x)||(y==47 && x>54+move_x && x <58+move_x))
                                                     oled_data <= 0;
                                             else if ((y==48 && x ==29+move_x)||(y==48 && x >49+move_x && x<55+move_x))
                                                     oled_data <= 0;
                                             else if ((y==49 && x ==29+move_x)||(y==49 && x ==33+move_x)||(y==49 && x ==50+move_x))
                                                     oled_data <= 0;
                                             else if ((y==50 && x >28+move_x && x<33+move_x)||(y==50 && x ==49+move_x)||(y==50 && x ==50+move_x))
                                                     oled_data <= 0;
                                             else if ((y==51 && x >32+move_x && x<39+move_x)||(y==51 && x ==49+move_x))
                                                     oled_data <= 0;
                                             else if ((y==52 && x >37+move_x && x<41+move_x)||(y==52 && x >45+move_x && x<49+move_x))
                                                     oled_data <= 0;
                                             else if ((y==53 && x >39+move_x && x<47+move_x))
                                                     oled_data <= 0;
                                             else if ((y==54 && x ==40+move_x)||(y==54 && x ==45+move_x))
                                                     oled_data <= 0;
                                             else if ((y==55 && x ==40+move_x)||(y==55 && x ==45+move_x))
                                                     oled_data <= 0;
                                             else if ((y==56 && x ==40+move_x)||(y==56 && x ==42+move_x)||(y==56 && x ==44+move_x))
                                                     oled_data <= 0;
                                             else if ((y==57 && x >40+move_x && x<44+move_x))
                                                     oled_data <= 0;
                                             
                                             //RED
                                             else if ((x==30+move_x && y ==29) || (x==30+move_x && y ==30) || (x==41+move_x && y ==29)) 
                                                     oled_data <= 16'hF000;
                                             else if ((x==31+move_x && y ==31)||(x==31+move_x && y ==32))
                                                     oled_data <= 16'hF000;
                                             else if ((y>29 && y < 33 && x>36+move_x && x<41+move_x )||(x==38+move_x && y ==33)||(x==39+move_x && y ==33))
                                                     oled_data <= 16'hF000;
                                             else if ((y>28 && y < 32 && x>45+move_x && x<50+move_x)||(x==47+move_x && y ==28)||(x==48+move_x && y ==28)||(x==47+move_x && y ==32)||(x==48+move_x && y ==32))
                                                     oled_data <= 16'hF000;
                                             
                                             //Yellow
                                             else if ((x==34+move_x && y==15))
                                                     oled_data <= 16'hFFE0;
                                             else if ((y==16 && x==53+move_x)||(y==16 && x>32+move_x && x<36+move_x))
                                                     oled_data <= 16'hFFE0;
                                             else if ((y==17 && x>31+move_x && x<36+move_x)||(y==17 && x>50+move_x && x<54+move_x))
                                                     oled_data <= 16'hFFE0;
                                             else if ((y==18 && x>31+move_x && x<36+move_x)||(y==18 && x>49+move_x && x<55+move_x))
                                                     oled_data <= 16'hFFE0;
                                             else if ((y==19 && x>31+move_x && x<36+move_x)||(y==19 && x>47+move_x && x<55+move_x))
                                                     oled_data <= 16'hFFE0;
                                             else if ((y==20 && x>32+move_x && x<36+move_x)||(y==20 && x>46+move_x && x<55+move_x))
                                                     oled_data <= 16'hFFE0;
                                             else if ((y==21 && x==33+move_x)||(y==21 && x==34+move_x)||(y==21 && x>36+move_x && x<54+move_x))
                                                     oled_data <= 16'hFFE0;
                                             else if ((y==22 && x>33+move_x && x<52+move_x))
                                                     oled_data <= 16'hFFE0;
                                             else if ((y==23 && x>32+move_x && x<50+move_x)||(y==23 && x==64+move_x)||(y==23 && x==65+move_x))
                                                     oled_data <= 16'hFFE0;
                                             else if ((y==24 && x> 31+move_x && x<50+move_x && x!=44+move_x && x != 45+move_x)||(y==24 && x>61+move_x && x<66+move_x))
                                                     oled_data <= 16'hFFE0;
                                             else if ((y==25 && x==32+move_x)||(y==25 && x>34+move_x && x<43+move_x)||(y==25 && x>46+move_x && x<51+move_x)||(y==25 && x>60+move_x && x<66+move_x))
                                                     oled_data <= 16'hFFE0;
                                             else if ((y==26 && x==31+move_x)||(y==26 && x>34+move_x && x<43+move_x)||(y==26 && x>46+move_x && x<51+move_x)||(y==26 && x>59+move_x && x<67+move_x))
                                                     oled_data <= 16'hFFE0;
                                             else if ((y==27 && x==31+move_x)||(y==27 && x>33+move_x && x<44+move_x)||(y==27 && x>46+move_x && x<51+move_x)||(y==27 && x>57+move_x && x<67+move_x))
                                                     oled_data <= 16'hFFE0;
                                             else if ((y==28 && x==30+move_x)||(y==28 && x==31+move_x)||(y==28 && x>33+move_x && x<47+move_x && x!= 37+move_x)||(y==28 && x>48+move_x && x<52+move_x)||(y==28 && x>56+move_x && x<67+move_x))
                                                     oled_data <= 16'hFFE0;
                                             else if ((y==29 && x==50+move_x)||(y==29 && x==51+move_x)||(y==29 && x>30+move_x && x<46+move_x && x!=41+move_x)||(y==29 && x>54+move_x && x<67+move_x))
                                                     oled_data <= 16'hFFE0;
                                             else if ((y==30 && x>30+move_x && x<36+move_x)||(y==30 && x>40+move_x && x<46+move_x)||(y==30 && x==50+move_x)||(y==30 && x==53+move_x)||(y==30 && x>55+move_x && x<67+move_x))
                                                     oled_data <= 16'hFFE0;
                                             else if ((y==31 && x>31+move_x && x<37+move_x)||(y==31 && x>40+move_x && x<46+move_x)||(y==31 && x>50+move_x && x<67+move_x && x!= 52+move_x && x!= 56+move_x))
                                                     oled_data <= 16'hFFE0;
                                             else if ((y==32 && x==28+move_x)||(y==32 && x>31+move_x && x<36+move_x)||(y==32 && x>40+move_x && x<47+move_x)||(y==32 && x==49+move_x)||(y==32 && x>50+move_x && x<65+move_x && x!=55+move_x && x!=56+move_x))
                                                     oled_data <= 16'hFFE0;
                                             else if ((y==33 && x>26+move_x && x<60+move_x)||(y==33 && x>31+move_x && x<63+move_x && x != 38+move_x && x!=39+move_x && x!= 49+move_x && x!= 56+move_x))
                                                     oled_data <= 16'hFFE0;
                                             else if ((y==34 && x>27+move_x && x<31+move_x)||(y==34 && x>32+move_x && x<61+move_x && x!=48+move_x && x!=55+move_x))
                                                     oled_data <= 16'hFFE0;
                                             else if ((y==35 && x>27+move_x && x<60+move_x && x!=32+move_x && x!= 33+move_x && x!= 55+move_x))
                                                     oled_data <= 16'hFFE0;
                                             else if ((y==36 && x>28+move_x && x<59+move_x && x!=32+move_x && x!=54+move_x && x!= 55+move_x))
                                                     oled_data <= 16'hFFE0;
                                             else if ((y==37 && x>29+move_x && x<53+move_x)||(y==37 && x>56+move_x && x<60+move_x))
                                                     oled_data <= 16'hFFE0;
                                             else if ((y==38 && x>31+move_x && x<53+move_x)||(y==38 && x>57+move_x && x<61+move_x))
                                                     oled_data <= 16'hFFE0;
                                             else if ((y==39 && x>31+move_x && x<50+move_x)||(y==39 && x>56+move_x && x<62+move_x))
                                                     oled_data <= 16'hFFE0;
                                             else if ((y==40 && x>30+move_x && x<52+move_x)||(y==40 && x>54+move_x && x<60+move_x))
                                                     oled_data <= 16'hFFE0;
                                             else if ((y==41 && x>30+move_x && x<58+move_x && x!=51+move_x && x != 52+move_x))
                                                     oled_data <= 16'hFFE0;
                                             else if ((y==42 && x>29+move_x && x<56+move_x && x!=51+move_x))
                                                     oled_data <= 16'hFFE0;
                                             else if ((y==43 && x>30+move_x && x<55+move_x && x!=51+move_x))
                                                     oled_data <= 16'hFFE0;
                                             else if ((y==44 && x>27+move_x && x<56+move_x && x!=30+move_x && x!=31+move_x && x!=51+move_x))
                                                     oled_data <= 16'hFFE0;
                                             else if ((y==45 && x==29+move_x)||(y==45 && x==31+move_x)||(y==45 && x>32+move_x && x<57+move_x && x!=51+move_x))
                                                     oled_data <= 16'hFFE0;
                                             else if ((y==46 && x>27+move_x && x<58+move_x && x!=32+move_x && x!=51+move_x))
                                                     oled_data <= 16'hFFE0;
                                             else if ((y==47 && x>28+move_x && x<55+move_x && x!=33+move_x && x!=51+move_x))
                                                     oled_data <= 16'hFFE0;
                                             else if ((y==48 && x>29+move_x && x<50+move_x && x!=33+move_x))
                                                     oled_data <= 16'hFFE0;
                                             else if ((y==49 && x>29+move_x && x<50+move_x && x!=33+move_x))
                                                     oled_data <= 16'hFFE0;
                                             else if ((y==50 && x>32+move_x && x<49+move_x))
                                                     oled_data <= 16'hFFE0;
                                             else if ((y==51 && x>38+move_x && x<49+move_x))
                                                     oled_data <= 16'hFFE0;
                                             else if ((y==52 && x>40+move_x && x<46+move_x))
                                                     oled_data <= 16'hFFE0;
                                             else if ((y==54 && x>40+move_x && x<45+move_x))
                                                     oled_data <= 16'hFFE0;
                                             else if ((y==55 && x>40+move_x && x<45+move_x))
                                                     oled_data <= 16'hFFE0;
                                             else if ((y==56 && x==41+move_x)||(y==56 && x==43+move_x))
                                                     oled_data <= 16'hFFE0;
                                             else if ((x == 45+move_x && y == 26) || (x == 44+move_x && y == 25) || (x == 33+move_x && y == 26))
                                                     oled_data <= 16'hFFFF;
                                             else oled_data <= 16'h01A0;
                                             //END PIKACHU
                                      end // END OF SCENE 3 - JUST PIKA          
             endcase // END CASE OF pika
                 end // POKE MODE END
                 
          if (sq_mode==1) begin
          if (poke_mode==0)begin
          if ((y)>=(base_y+value)&&(y)<(max_y-value)&&(x)>(base_x+value)&&(x)<(max_x-value)) begin
             if (p_in[0]==1 && p_in[6]==0 && p_in[11]==0) begin
             oled_data<=low_colour1;
             end
             else if (p_in[6]==1 && p_in[11]==0)begin
             oled_data<=medium_colour1;
             end
             else if (p_in[11]==1)begin
             oled_data<=high_colour1;
             end
          
          end
          else begin
          oled_data<=bg_colour;
          end
          
          case(p_in)
                  1:begin value<=30; end //0
                  3:begin value<=28; end //1
                  7:begin value<=26; end //2;
                  15:begin value<=24; end //3
                  31:begin value<=22; end //4
                  63:begin value<=20; end //5
                  127:begin value<=18; end //6
                  255:begin value<=16; end //7
                  511:begin value<=14; end //8
                  1023:begin value<=12; end //9
                  2047:begin value<=10; end //10
                  4095:begin value<=8; end //11
                  8191:begin value<=6; end //12
                  16383:begin value<=4; end //13
                  32767:begin value<=2; end //14
                  65535:begin value<=0; end //15
          endcase
          end //poke_mode==0
          end//sq mode==1
            end // OUTERMOST END    
endmodule
