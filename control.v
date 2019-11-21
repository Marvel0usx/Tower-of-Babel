/* The control for display
* 
*
*
*
*/
module control_display(clock, reset_n, phase, update, draw_game, erase, draw_win, draw_lose, enable_plot);

	input clock, reset_n;
	input [1:0] phase;
	
	// this outputs are like enable either 1 or 0
	output reg update, draw_game, erase, draw_win, draw_lose, enable_plot;
	
	wire draw_counter_out, erase_counter_out; 
	
	reg enable_draw_counter, enable_erase_counter;
	reg [2:0] current_state, next_state;
	
	localparam  S_UPDATE = 3'd0,
					S_DRAW_GAME = 3'd1,
					S_ERASE = 3'd2,
					S_DRAW_WIN = 3'd3,
					S_DRAW_LOSE = 4'd4;

					
	
	my_counter count_draw(
		.clock(clock),
		.reset_n(reset_n),
		.in(26'd12480000),
		.enable(enable_draw_counter),
		.out(draw_counter_out)
		);
	
	
	my_counter count_erase(
		.clock(clock),
		.reset_n(reset_n),
		.in(26'd12000000),				// 20000
		.enable(enable_erase_counter),
		.out(erase_counter_out)
		);
		
		
	
	// state table
	always @(*) begin
		case (current_state)
		
			S_UPDATE: begin
				if (phase == 2'b01) 
					next_state = S_DRAW_GAME;
				else if (phase == 2'b10)
					next_state = S_DRAW_WIN;
				else if (phase == 2'b11)
					next_state = S_DRAW_LOSE;
				else
					next_state = S_UPDATE;
			end
			
			S_DRAW_GAME: next_state = draw_counter_out ? S_ERASE : S_DRAW_GAME;
			
			S_ERASE: next_state = erase_counter_out ? S_UPDATE : S_ERASE;
			
			S_DRAW_WIN: begin
				if (phase == 2'b00)
					next_state = S_UPDATE;
				else
					next_state = S_DRAW_WIN;
			end
			
			S_DRAW_LOSE: begin
				if (phase == 2'b00)
					next_state = S_UPDATE;
				else
					next_state = S_DRAW_LOSE;
			end
			
			default: next_state = S_UPDATE;
		endcase
	end
	
	

	always @(*) begin
		
		update = 1'b0;
		draw_game = 1'b0; 
		erase = 1'b0; 
		draw_win = 1'b0; 
		draw_lose = 1'b0;
		enable_draw_counter = 1'b0;
		enable_erase_counter = 1'b0;
		enable_plot = 1'b1;
			
		case (current_state)
			S_UPDATE: begin
				update = 1'b1;
				enable_plot = 1'b0;
			end
			S_DRAW_GAME: begin
				draw_game = 1'b1;
				enable_draw_counter = 1'b1;
			end
			S_ERASE: begin
				erase = 1'b0;
				enable_erase_counter = 1'b1;
			end
			S_DRAW_WIN: begin
				draw_win = 1'b1;
			end
			S_DRAW_LOSE: begin
				draw_lose = 1'b1;
			end

		endcase
	end
	
	
	always @(posedge clock) begin
		
		if (!reset_n)
			current_state <= S_UPDATE;
			
		else
			current_state <= next_state;
	
	end
	
	
	
	// set another enable, which only enable when counting down given input "in" to 0

module my_counter(clock, reset_n, in, enable, out);

	input clock, reset_n, enable;
	input [25:0] in;
	output out;
	reg [25:0] count;
	
	always @(posedge clock)
	begin
		if (!reset_n)
			count <= in;
		else if (enable)
			begin
				if (count == 26'd0)
					count <= in;
				else 
					count <= count - 1'b1;
			end
	end
	
	// only counting to 0, out = 1
	assign out = ~(|count);
	
endmodule

