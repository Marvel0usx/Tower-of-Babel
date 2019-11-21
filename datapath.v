/* The Datapath for display
* 
*
*
*
*/
module datapath(clock, reset_n, x_in, y_in, update, draw_game, erase, draw_win, draw_lose, x_out, y_out, colour);

	input clock, reset_n;
	input [3:0] x_in, y_in;
	input update, draw_game, erase, draw_win, draw_lose;
	
	output [7:0] x_out; // x value that constanly update when drawing 
	output [6:0] y_out; // y value that constanly update when drawing 
	output reg [2:0] colour;
	
	reg [7:0] x;
	reg [6:0] y;
	reg enable_counter;
	wire [7:0] counter_out; // the counter count 16*16 = 256 cycles
	
	
		
	assign x_out = x + {4'b0000, counter_out[3:0]};
	assign y_out = y + {3'b000, counter_out[7:4]};
	
	
	
	
	counter_8bit c0(
		.reset_n(reset_n),
		.enable(enable_counter),
		.clock(clock),
		.counter_out(counter_out)
		);
		
		
	always @(posedge clock) begin
	
		if (!reset_n) begin // reset colour, x, y value
			x <= 8'd0;
			y <= 7'd0;
			colour <= 3'b000;
			enable_counter <= 1'b0;
		end
		
		else if (update) begin
			enable_counter <= 1'b0;
			x <=  x_in * 5'd16;
			y <= y_in * 5'd16 + 4'd8;
		end
		
		else if (draw_game) begin
			colour <= 3'b111;
			enable_counter <= 1'b1;
		end
		
		else if (erase) begin
			colour <= 3'b000;
			enable_counter <= 1'b1;
		end
			
		
	end
	
endmodule



module counter_8bit(reset_n, enable, clock, counter_out);
	
	input reset_n, enable, clock;
	output reg [7:0] counter_out;
	
	always @(posedge clock) begin
	
		if (!reset_n)
			counter_out <= 8'b00000000;
				
		else if (enable) begin
			if (counter_out == 8'b11111111)
				counter_out <= 8'd11111111;
			else 
				counter_out <= counter_out + 1;
		end
		
		else
			counter_out <= 8'b00000000;
		
	end
	
endmodule