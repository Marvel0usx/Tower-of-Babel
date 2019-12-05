module display_top
	(
		clk,						//	On Board 50 MHz
		// Your inputs and outputs here
        resetn,
        sync,
        game_status,
        bypass_erase,

        // coordinates
        prev_x,
        curr_x,
        curr_y,

		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,					//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			clk;				//	50 MHz
    input           resetn;
    input           sync;
    input   [1:0]   game_status;
    input           bypass_erase;

    input   [7:0]   prev_x;
    input   [7:0]   curr_x;
    input   [6:0]   curr_y;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	// Create the colour, x, y and vga_en wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(clk),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(w_to_vga_en),
			/* Signals for the DAC to drive the monitor. */
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
			
	// Put your code here. Your code should produce signals x,y,colour and vga_en/plot
	// for the VGA controller, in addition to any other functionality your design may require.
    wire w_to_vga_en;
    wire w_done_draw, w_done_erase;
    wire w_to_dp_draw, w_to_dp_erase, w_to_dp_update;
    wire w_to_dp_draw_end, w_to_dp_draw_start;

    // Instansiate datapath
    draw d0(
        .clk(clk),
        .resetn(resetn),
        .vga_en(w_to_vga_en),
        .draw(w_to_dp_draw),
        .update(w_to_dp_update),

        .x_in(curr_x),
        .y_in(curr_y),
        .width(5'd16),
        .height(5'd16),
        .c_in(3'b111),

        .x_out(x),
        .y_out(y),
        .c_out(colour),
        .draw_done(w_done_draw)
    );

    draw e0(
        .clk(clk),
        .resetn(resetn),
        .vga_en(w_to_vga_en),
        .draw(w_to_dp_erase),
        .update(w_to_dp_update),

        .x_in(prev_x),
        .y_in(curr_y),
        .width(5'd16),
        .height(5'd16),
        .c_in(3'b0),

        .x_out(x),
        .y_out(y),
        .c_out(colour),
        .draw_done(w_done_erase)
    );

    // Instansiate FSM control
    display_control d1(
        .clk(clk),
        .sync(sync),
        .resetn(resetn),
        .bypass_erase(bypass_erase),
        .done_draw(w_done_draw),
        .done_erase(w_done_erase),
        .game_status(game_status),

        .vga_en(w_to_vga_en),
        .draw(w_to_dp_draw),
        .erase(w_to_dp_erase),
        .update(w_to_dp_update),
        .draw_start(w_to_dp_draw_start),
        .draw_end(w_to_dp_draw_end)
    );
    
endmodule