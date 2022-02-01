module head (
  input [9:0] pixel_row, pixel_column,
  input mv_clk, VGA_clk, got_apple,
  input BTNU, BTND, BTNL, BTNR, SWRES, SWPAUSE,
  output reg body_on, head_on, collided
);

  wire [9:0] head_size;
  reg [6:0] length;
  reg is_on [126:0];
  reg [9:0] snake_y_motion, snake_y_pos [126:0], snake_x_motion, snake_x_pos [126:0];
  integer a,i,j,k;

  // fix the ball size and horizontal position
  assign head_size = 10'd8;
  
  always @ (posedge VGA_clk) begin
    if (!SWRES) begin
        length = 5'd4;
        for (a = 0; a < 127; a = a + 1) begin
            if (a < length) begin
                is_on[a] = 1;
            end else
                is_on[a] = 0;
        end
     end
     if (got_apple) begin
        if (length < 127) begin
            is_on[length] = 1;
            length = length + 1;
        end
     end
  end
 
  
  
  
  // generate motion and vertical position of the ball
  
  always @ (posedge mv_clk) begin
    if (!SWRES) begin
        for ( i = 3; i >= 0; i = i - 1) begin
            snake_y_pos[i] = 10'd300;
            snake_x_pos[i] = 10'd50 - (i * 10'd10);
        end 
        snake_x_motion = 10'd10;
        snake_y_motion = 10'd0;  
        collided = 1'b0;      
    end    
    
    if (BTNU) begin
        if(snake_y_motion != 10'd10) begin
            snake_x_motion = 10'd0;
            snake_y_motion = -10'd10;
        end
    end
    else if (BTNL) begin
        if(snake_x_motion != 10'd10) begin
            snake_y_motion = 10'd0;
            snake_x_motion = -10'd10;
        end
    end
    else if (BTND) begin
        if(snake_y_motion != -10'd10) begin
            snake_x_motion = 10'd0;
            snake_y_motion = 10'd10;
        end
    end
    else if (BTNR) begin
        if(snake_x_motion != -10'd10) begin
            snake_y_motion = 10'd0;
            snake_x_motion = 10'd10;
        end
    end
    
    if((snake_x_pos[0] <= 10 || snake_x_pos[0] > 790) | ( snake_y_pos[0] <= 10 | snake_y_pos[0] > 590)) begin
        collided = 1'b1;
    end
    
    for (j = 126; j > 0; j = j - 1) begin
        if (is_on[j]) begin
            if((snake_x_pos[0] == snake_x_pos[j]) & (snake_y_pos[0] == snake_y_pos[j])) begin
                collided = 1'b1;
            end
        end
    end
    
    if (!SWPAUSE && !collided) begin
        for (j = 126; j > 0; j = j - 1) begin
            snake_x_pos[j] = snake_x_pos[j-1];
            snake_y_pos[j] = snake_y_pos[j-1];
        end
        snake_y_pos[0] = snake_y_pos[0] + snake_y_motion;
        snake_x_pos[0] = snake_x_pos[0] + snake_x_motion;
    end
  end

  // based on the current pixels and the current position of the ball, determine whether you should show the ball or the background
  always @ (*) begin
    body_on = 1'b0;
    head_on = 1'b0;
    for ( k = 126; k > 0; k = k - 1) begin
        if (is_on[k]) begin
           if ((snake_x_pos[k] <= (pixel_column + head_size)) && (snake_x_pos[k] >= pixel_column) && (snake_y_pos[k] <= (pixel_row + head_size)) && ((snake_y_pos[k]) >= pixel_row)) begin
              body_on = 1'b1;
           end
        end
    end
    if ((snake_x_pos[0] <= (pixel_column + head_size)) && (snake_x_pos[0] >= pixel_column) && (snake_y_pos[0] <= (pixel_row + head_size)) && ((snake_y_pos[0]) >= pixel_row)) begin
          head_on = 1'b1;
    end
  end

endmodule
