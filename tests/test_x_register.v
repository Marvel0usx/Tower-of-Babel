module test_x(
    input clk,
    input resetn,
    input enable,
    input [25:0] delay,

    output [7:0] x
    );

    wire sync;

    general_counter delayed(
        .clk(clk),
	    .resetn(resetn),
	    .enable(enable),
	    .delay(delay),
	    .q(sync)
    );

    x_register x0(
        .clk(clk),
        .sync(sync),
        .resetn(resetn),
        .enable(enable),
        .curr_x_position(x)
    );

endmodule