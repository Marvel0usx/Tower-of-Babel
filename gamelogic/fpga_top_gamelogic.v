 module fpga_top_gamelogic(SW, KEY, CLOCK_50, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, PS2_CLK, PS2_DAT);
    input [9:0] SW;
    input [3:0] KEY;
    input CLOCK_50;
    inout PS2_CLK, PS2_DAT;
    output [9:0] LEDR;
    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

    wire [7:0] p_x_out, x_out;
    wire [6:0] y_out;
    wire user_key_in;

    hex_decoder h0(
        .hex_digit(p_x_out[3:0]),
        .segments(HEX0)
    );

    hex_decoder h1(
        .hex_digit(p_x_out[7:4]),
        .segments(HEX1)
    );

    hex_decoder h2(
        .hex_digit(x_out[3:0]),
        .segments(HEX2)
    );

    hex_decoder h3(
        .hex_digit(x_out[7:4]),
        .segments(HEX3)
    );

    hex_decoder h4(
        .hex_digit(y_out[3:0]),
        .segments(HEX4)
    );

    hex_decoder h5(
        .hex_digit({1'b0, y_out[6:4]}),
        .segments(HEX5)
    );

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

    game_logic_top l(
        .clk(CLOCK_50),
        .sync(LEDR[9]),
        .resetn(KEY[0]),
        .KEY(user_key_in),
        .w_o(LEDR[0]),
        .x(x_out),
        .y(y_out),
        .prev_x(p_x_out),
        .score(LEDR[8:6]),
        .chances(LEDR[5:3]),
        .game_status(LEDR[2:1])
    );

endmodule // game_logic_top
