`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/07/2021 10:44:46 PM
// Design Name: 
// Module Name: apple
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


module apple (
  input x_clock, y_clock, SWRES,
  input [9:0] pixel_row, pixel_column,
  input vert_sync, got_apple,
  output reg is_apple
);
    reg [9:0] rand_x, rand_y;
    reg [9:0] apple_x = 10'd400, apple_y = 10'd300;
    
    always @ (posedge x_clock) begin
        if (rand_x < 790) begin
            rand_x = rand_x + 10;
        end else begin
            rand_x = 20;
        end
    end
    
    always @ (posedge y_clock) begin
        if (rand_y < 590) begin
            rand_y = rand_y + 10;
        end else begin
            rand_y = 20;
        end
    end
    
    always @ (posedge y_clock) begin
        if (got_apple) begin
            apple_x <= rand_x;
            apple_y <= rand_y;
        end
        if (!SWRES) begin
            apple_x <= 10'd400;
            apple_y <= 10'd300;
        end
    end
    
    always @ (*) begin   
        is_apple <= ((apple_x <= (pixel_column + 8)) && (apple_x >= pixel_column) && (apple_y <= (pixel_row + 8)) && ((apple_y) >= pixel_row));
	end
	
endmodule
