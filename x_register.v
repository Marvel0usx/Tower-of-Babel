/* X register
 * ------------
 *
 * Module that changes the x coordinate of the current block
 * according to the control signals. It syncs with the clock
 * that drives the VGA adapter to give a nice correspondence.
 *
 * This module will only change x by a single pixel per posegde
 * of the synchornized signal.
 */

module x_register(
	input clk,		// 50MHz signal for sync resetn
	input sync,		// signal for syncing with VGA
	input resetn,	// active low resetn
	input enable,
	
	output reg [7:0] curr_x_position
	);

	// registers for internal uses
	reg [1:0] direction;

	// local variables
	localparam X_MAX = 8'b10010000,			// the right most pixel 144
		   	   LEFT  = 1'b0,				// for the use of direction register
		   	   RIGHT = 1'b1;

	// synchornized reset
	always @(negedge resetn) begin
		if (!resetn) begin
			curr_x_position <= 8'b0;
			direction <= RIGHT;
		end
	end

	always @(posedge clk) begin
		if (enable) begin
			curr_x_position <= curr_x_position;
			direction <= direction;
		end
	end

	// incrementing of x on synchronized signal
	always @(posedge sync) begin
		if (enable) begin
			if (curr_x_position == 8'b0) begin   		// meet the left boundary
				if (direction == LEFT)
					direction <= RIGHT;
				else
					direction <= direction;
				curr_x_position <= curr_x_position + 1'b1;
			end
			else if (curr_x_position == X_MAX) begin      // meet the right boundary
				if (direction == RIGHT)
					direction <= LEFT;
				else
					direction <= direction;
				curr_x_position <= curr_x_position - 1'b1;
			end
			else
				if (direction == LEFT)
					curr_x_position <= curr_x_position - 1'b1;
				else
					curr_x_position <= curr_x_position + 1'b1;
			end
		end

endmodule
