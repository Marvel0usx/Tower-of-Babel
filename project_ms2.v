//`include "PS2_Keyboard_Controller.v"


module project_ms2(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B,   						//	VGA Blue[9:0]
		
		HEX_0,
		HEX_1
	);

	input CLOCK_50;	

	input [3:0] KEY;		// key[0] - active-low, sychronous reset
	input [9:0] SW;
	

	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	output [6:0] HEX0;	// chances
	output [6:0] HEX1;	// scores

//	output [6:0] HEX4;	// win
//	output [6:0] HEX5;	// lose
//	output [9:0] LEDR;	// row

	wire enter;
	wire [7:0] x;
	wire [6:0] y;
	wire [2:0] colour;
	wire plot;
	
	
	CTS cts0(
		.clock(CLOCK_50), 
		.reset_n(KEY[0]), 
		.enter(!KEY[3]),
		.vga_x(x), 
		.vga_y(y), 
		.vga_colour(colour), 
		.enable_plot(plot)
		);
	
	
	vga_adapter VGA(
		.resetn(KEY[0]),
		.clock(CLOCK_50),
		.colour(colour),
		.x(x),
		.y(y),
		.plot(plot),
		.VGA_R(VGA_R),
		.VGA_G(VGA_G),
		.VGA_B(VGA_B),
		.VGA_HS(VGA_HS),
		.VGA_VS(VGA_VS),
		.VGA_BLANK(VGA_BLANK_N),
		.VGA_SYNC(VGA_SYNC_N),
		.VGA_CLK(VGA_CLK));
	defparam VGA.RESOLUTION = "160x120";
	defparam VGA.MONOCHROME = "FALSE";
	defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
	defparam VGA.BACKGROUND_IMAGE = "black.mif";
		
	hex_decoder h0(
		.hex_digit(x), 
		.segments(HEX0)
		);
		
	hex_decoder h1(
		.hex_digit(y), 
		.segments(HEX1)
		);
//		
//	hex_decoder h2(
//		.hex_digit({3'b000, win_o}), 
//		.segments(HEX4)
//		);
//	
//	hex_decoder h3(
//		.hex_digit({3'b000, lose_o}), 
//		.segments(HEX5)
//		);

endmodule



module CTS(clock, reset_n, enter, vga_x, vga_y, vga_colour, enable_plot);

	input clock, reset_n;
	input enter; // where to use!!!
	output [7:0] vga_x, 
	output [6:0] vga_y;
	output [2:0] vga_colour;
	output enable_plot;
	
	
	wire x, y;
	wire enable_game, phase;
	wire update, draw_game, erase, draw_win, draw_lose;
	
	
//	assign vga_x = 8'd0;
//	assign vga_y = 7'd0;
//	assign vga_colour = 3'd0;
	
	
	
	game_logic_top game0(
		.clk(Clock),
		.resetn(reset_n),
		.sync(),
		 
		.o(),
		.x(x),
		.y(y),
		.score(),
		.chance(),
		.game_status(phase) 
	)
	

	
	control_display cd0(
		.clock(clock), 
		.reset_n(reset_n), 
		
		.phase(phase), 
		.update(update), 
		.draw_game(draw_game), 
		.erase(erase), 
		.draw_win(draw_win), 
		.draw_lose(draw_lose),
		.enable_plot(enable_plot)
		);

	

	datapath d0(
		.clock(clock),
		.reset_n(reset_n),
		.x_in(x),
		.y_in(y),
		.update(update),
		.draw_game(draw_game),
		.erase(erase),
		.draw_win(draw_win),
		.draw_lose(draw_lose),
		
		.x_out(vga_x),
		.y_out(vga_y),
		.colour(vga_colour)
		);


		
		
endmodule



