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
	input enable,	// enable x shifting
	input load_x,
	input load_direction,
	input new_direction,
	input [7:0] new_x_position,
	
	output reg [7:0] curr_x_position
	);

	// registers for internal uses
	reg direction;

	// local variables
	localparam X_MAX = 8'b10010000,						// the right most pixel 144
		   	   LEFT  = 1'b0,							// for the use of direction register
		   	   RIGHT = 1'b1;

	always @(posedge clk) begin
		if (!resetn) begin					            // resetn and load sync with clock
			curr_x_position <= 8'b0;
			direction <= 1'b1;
		end
		else begin
			if (load_x)
				curr_x_position <= new_x_position;
			else 
				curr_x_position <= curr_x_position;
			
			if (load_direction)
				direction <= new_direction;
			else
				direction <= direction;
			
			if (!sync) begin							// incrementing of x on synchronized signal
				if (enable) begin
					if (curr_x_position == 8'b0) begin   		// meet the left boundary
						if (direction == LEFT)
							direction <= RIGHT;
						else
							direction <= direction;
						curr_x_position <= curr_x_position + 1'b1;
					end
					else if (curr_x_position == X_MAX) begin    // meet the right boundary
						if (direction == RIGHT)
							direction <= LEFT;
						else
							direction <= direction;
						curr_x_position <= curr_x_position - 1'b1;
					end
					else begin
						if (direction == LEFT)
							curr_x_position <= curr_x_position - 1'b1;
						else
							curr_x_position <= curr_x_position + 1'b1;
					end
				end
				else begin
					curr_x_position <= curr_x_position;
					direction <= direction;
				end
			end
		end
	end
endmodule