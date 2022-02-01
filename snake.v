`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/11/2021 09:31:37 AM
// Design Name: 
// Module Name: lab8
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


module snake (
  input CLK100MHZ,
  input [3:0] BTN,
  input [2:0] SW,
  output [3:0] VGA_RED, VGA_GREEN, VGA_BLUE,
  output VGA_HS, VGA_VS
);

  wire is_head, is_body, is_apple, collided;
  reg is_border, moveSnake, got_apple, mv_clk = 0;
  reg [25:0] counter = 0;
  wire [9:0] pixel_row_int, pixel_col_int;
  wire [3:0] vga_red_int, vga_green_int, vga_blue_int, red_data, green_data, blue_data;
  wire video_blank_int, video_clock_int, v_sync_int, h_sync_int, clk40M;

  // generate 40 MHz clock from board oscillator
  clk_wiz_0 clk_40M_gen (
    .clk_out1(clk_40M),
    .clk_in1(CLK100MHZ)
  );
  
  always @ (posedge CLK100MHZ) begin
    if (counter < (SW[2] ? 4999999 : 9999999)) begin
        counter <= counter + 1;
    end
    else begin 
        counter <= 0;
        mv_clk <= ~mv_clk;
    end
 end

  head head_inst (
    .pixel_row(pixel_row_int),
    .pixel_column(pixel_col_int),
    .mv_clk(mv_clk),
    .VGA_clk(clk_40M),
    .got_apple(got_apple),
    .SWRES(SW[0]),
    .SWPAUSE(SW[1]),
    .BTNU(BTN[0]),
    .BTNL(BTN[1]),
    .BTNR(BTN[2]),
    .BTND(BTN[3]),
    .body_on(is_body),
    .head_on(is_head),
    .collided(collided)
  );
  
  apple apple_inst (
    .pixel_row(pixel_row_int),
    .pixel_column(pixel_col_int),
    .SWRES(SW[0]),
    .x_clock(CLK100MHZ),
    .y_clock(clk_40M),
    .vert_sync(v_sync_int),
    .got_apple(got_apple),
    .is_apple(is_apple)
  );
  
  always @ (clk_40M) begin
    got_apple <= (is_head & is_apple);
  end
  
  
  always @ (*) begin
      if ((pixel_row_int < 10 | pixel_row_int > 590) | 
        (pixel_col_int < 10 | pixel_col_int > 790)) begin
        is_border = 1'b1;
      end
      else begin
        is_border = 1'b0;
      end
  end
  
  
  // if showing ball display red, otherwise display white (all ones)
  assign red_data = ~SW[0] ? 4'b0000 : (collided | is_apple) ? 4'b1111 : 4'b0000;
  assign green_data = (~SW[0] | collided) ? 4'b0000 : (is_head | is_body) ? 4'b1111 : 4'b0000;
  assign blue_data = (~SW[0] | collided) ? 4'b0000 : is_border ? 4'b1111 : 4'b0000;
    
  vga_sync vga_sync_int (
    .clock_40mhz(clk_40M),
    .reset(1'b0),
    .red(red_data),
    .green(green_data),
    .blue(blue_data),
    .red_out(vga_red_int),
    .blue_out(vga_blue_int),
    .green_out(vga_green_int),
    .horiz_sync_out(h_sync_int),
    .vert_sync_out(v_sync_int),
    .pixel_row(pixel_row_int),
    .pixel_col(pixel_col_int)
  );

  assign VGA_VS = v_sync_int;
  assign VGA_HS = h_sync_int;
  assign VGA_RED = vga_red_int;
  assign VGA_GREEN = vga_green_int;
  assign VGA_BLUE = vga_blue_int;

endmodule
