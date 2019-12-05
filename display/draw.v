module draw(
    input clk,
    input resetn,
    input vga_en,
    input draw,
    input update,

	input [7:0] x_in,
	input [6:0] y_in,
	input [4:0] width, height,
	input [2:0] c_in,

	output [7:0] x_out,
	output [6:0] y_out,
	output [2:0] c_out,
	output reg draw_done,
    );
    
	reg [7:0] x_counter, x_origin;
	reg [6:0] y_counter, y_origin;
    
	// draw logic

    always @(posedge clk)
    	begin
    		if (!draw || !resetn) begin     // everything is onhold and reset
    			draw_done <= 0;
    			start     <= 0;
    			x_counter <= 0;     
    			y_counter <= 0;
    			x_origin  <= 0;
    			y_origin  <= 0;
    			c_out     <= 3'b0;
    		end
            else if (update) begin          // updates x, y, and color
                x_origin <= x_in;
                y_origin <= y_in;
                c_out <= c_in;
            end
    		else if (draw && !draw_done) begin
    			if (vga_en) begin
    				if (x_counter < width-1)
                        x_counter <= x_counter + 1;
    				else if (x_counter == width - 1) begin
    					x_counter <= 0; 
    					if (y_counter < height - 1)
    						y_counter <= y_counter + 1;
    					else if (y_counter == height - 1)
    						draw_done = 1;
    				end
    			end
    		end
    	end

    // assign output signals
	assign x_out = x_origin + x_counter;
	assign y_out = y_origin + y_counter;
    
endmodule // display_datapath