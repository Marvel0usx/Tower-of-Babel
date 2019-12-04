/* Game Speed Counter
 * -----------------
 *
 * This module is used to produce a delay of frames and provides synchornized 
 * signal for both the shifting of blocks and the VGA adapter.
 *
 * The delayed signal will be active high.
 */

module game_speed_counter(
	input clk,
	input resetn,
   input load,
   input [2:0] difficulty,
	
	output q
	);

	// value to delay the 50MHz signal to 60Hz
	localparam D = 26'b11001011011100110101;
	
	// internal register for counting up
	reg [25:0] count;

	always @(posedge clk) begin
		if (!resetn)
			count <= D;
		else if (load)
			count <= difficulty * D;
		else begin
			if (count == 5'b0)
				count <= difficulty * D;
			else
				count <= count - 1'b1;
		end
	end
	
	// send on signal when it reaches delay
	assign q = ~{|count};

endmodule // delay_counter
