module fpga_game_top(
    input CLOCK_50,
    input [0:0] KEY,

    inout PS2_CLK,
    inout PS2_DAT,

    output [9:0] LEDR,
    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5

    output VGA_CLK,   	
    output VGA_HS,		
    output VGA_VS,		
    output VGA_BLANK_N,
    output VGA_SYNC_N,	
    output [9:0] VGA_R,   	
    output [9:0] VGA_G,	 	
    output [9:0] VGA_B 
    );

    wire w_sync, gnd;
    wire user_key_in, w_bypass_erase;
    wire x_out, y_out, p_x_out;
    wire [1:0] w_game_status;

    // PS/2 keyboard input
    keyboard_tracker #(.PULSE_OR_HOLD(0)) t0(
        .clock(CLOCK_50),
        .reset(KEY[0]),
        .PS2_CLK(PS2_CLK),
        .PS2_DAT(PS2_DAT),
        
        .w(gnd),
        .a(gnd),
        .s(gnd),
        .d(gnd),
        .left(gnd),
        .right(gnd),
        .up(gnd),
        .down(gnd),
        .space(user_key_in),                // user's key in
        .enter(gnd)
    );

    // checked
    display_top d(
        .clk(CLOCK_50),
        .resetn(KEY[0]),
        .sync(w_sync),
        .game_status(w_game_status),
        .bypass_erase(w_bypass_erase),


        .prev_x(p_x_out),
        .curr_x(x_out),
        .curr_y(y_out),

		.VGA_CLK(VGA_CLK),
		.VGA_HS(VGA_HS),
		.VGA_VS(VGA_VS),
		.VGA_BLANK_N(VGA_BLANK_N),
		.VGA_SYNC_N(VGA_SYNC_N),
		.VGA_R(VGA_R),
		.VGA_G(VGA_G),
		.VGA_B(VGA_B)
    );

    // checked
    game_logic_top l(
        .clk(CLOCK_50),
        .sync(w_sync),
        .resetn(KEY[0]),
        .KEY(user_key_in),
        .w_o(LEDR[0]),
        .bypass_erase(w_bypass_erase),
        .x(x_out),
        .y(y_out),
        .prev_x(p_x_out),
        .score(LEDR[8:6]),
        .chances(LEDR[5:3]),
        .game_status(w_game_status)
    );
endmodule // fpga_game_top