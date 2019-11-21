/* Overlap Detector
 * ------------------------
 * 
 * This module provides its output as an argument as an indicator for 
 * the game logic FSM to move on to the next state or to go back. It 
 * works mainly depending on values curr_x_position and prev_x_position,
 * which are the x position of the block in the previous row and that of
 * the current block. It returns 0 if the positions are not overlapping,
 * and 1 overwise.
 * 
 * ------------------------
 * Invariants
 * ------------------------
 * If any of the value of curr_x_position or prev_x_position is omitted,
 * the output q should be 0.
 *
 * ------------------------
 * Criteria for overlapping
 * ------------------------
 * 1. if curr_x_position > prev_x_position, then the two blocks overlap if 
 *    curr_x_position - prev_x_position <= 10
 * 2. if curr_x_position < prev_x_position, then the two blocks overlap if 
 *    prev_x_position - curr_x_position <= 10
 * ------------------------
 */

module overlap_detector(
	input clk,
	input resetn,
	input [7:0] curr_x_position,
	input [7:0] prev_x_position,
	output reg q
	);
	
	always @(posedge clk) begin
		if (!resetn)
			q <= 1'b0;
		else begin
			if (curr_x_position > prev_x_position) begin
				if ((curr_x_position - prev_x_position) <= 10)
					q <= 1'b1;
				else
					q <= 1'b0;
			end
			else if (prev_x_position > curr_x_position) begin
				if ((prev_x_position - curr_x_position) <= 10)
					q <= 1'b1;
				else
					q <= 1'b0;
			end
			else 
				if (prev_x_position == curr_x_position)
					q <= 1'b1;
				else
					q <= 1'b0;
		end
	end
endmodule // overlap_detector
