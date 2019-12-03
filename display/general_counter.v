/* General Counter
 * -----------------
 *
 * This module is used to produce a delay of clock by a given count. It 
 * provides synchornized signal for the VGA adapter and other use in the
 * game.
 *
 * The delayed signal will be active low.
 */

module general_counter(
	input clk,
	input resetn,
	input enable,
	input [25:0] delay,
	output q
	);
	
	// internal register for counting up
	reg [25:0] count;

	always @(posedge clk) begin
		if (!resetn)
			count <= delay;
		else if (enable) begin
			if (count == 26'b0)
				count <= delay;
			else
				count <= count - 1'b1;
		end
		else
			count <= count;
	end
	
	// send on signal when it reaches delay
	assign q = ~{|count};

endmodule // delay_counter
