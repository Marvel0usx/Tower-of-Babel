module display_control(
	input clk,
	input sync,
	input resetn,
	input bypass_erase,
	input done_draw,
	input done_erase,
	input [1:0] game_status,

	output reg vga_en,
	output reg draw,
	output reg erase,
	output reg update,
	output reg draw_start,
	output reg draw_end
	);

	reg [5:0] current_state, next_state;

	localparam DRAW_START_SCREEN 	= 3'd1,
			   ON_HOLD 				= 3'd2,
			   ERASE 				= 3'd3,
			   DRAW_GAMEOVER_SCREEN = 3'd4,
			   UPDATE 				= 3'b5,
			   DRAW   				= 3'b6;

	//State Table
    always @(*) begin: state_table 
		case (current_state)  
				DRAW_START_SCREEN : begin
									if (game_status == 2'b0)
										next_state = DRAW_START_SCREEN;
									else if (game_status == 2'b01)
										next_state = ON_HOLD;
									else
										next_state = next_state;
									end
				ON_HOLD : begin
					if (sync) begin
						if (bypass_erase)
							next_state = UPDATE;
						else
							next_state = ERASE;
					end
					else
						next_state = ON_HOLD;
				end				
				
				ERASE : next_state = done_erase ? UPDATE : ERASE;					

				UPDATE :begin
					if (game_status == 2'b01)
						next_state = DRAW;
					else if (game_status == 2'b10)
						next_state = DRAW_GAMEOVER_SCREEN;
					else
						next_state = next_state;
				end

				DRAW: next_state = done_draw ? ON_HOLD : DRAW;
				
				DRAW_GAMEOVER_SCREEN: next_state = DRAW_GAMEOVER_SCREEN;
			default: next_state = DRAW_START_SCREEN;
        endcase
    end // state_table

    //control signal change code
    always @(*) begin: enable_signal
		vga_en   = 1'b1;
		draw 	 = 1'b0;
		update   = 1'b0;
		erase    = 1'b0;
		draw_end = 1'b0;
		draw_start = 1'b0;
		  
        case (current_state)
				DRAW_START_SCREEN : draw_start = 1'b1;
				ERASE : erase = 1'b1;
				UPDATE : begin
					update = 1'b1;
					vga_en = 1'b0;
				end
				DRAW : draw = 1'b1;
				DRAW_GAMEOVER_SCREEN : draw_end = 1'b1;			
				default: begin
					vga_en = 1'b0;					
				end
        endcase
    end // enable_signals

	// updating states on posedge
	always @(posedge clk) begin
		if (!resetn)
			current_state <= DRAW_START_SCREEN;
		else
			current_state <= next_state;
	end
endmodule