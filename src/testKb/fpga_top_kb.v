module fpga_top_kb(CLOCK_50, KEY[0], PS2_CLK, PS2_DAT, LEDR[0]);
    input CLOCK_50;
    input [0:0] KEY;
    input PS2_CLK;
    input PS2_DAT;
    output [0:0] LEDR;

    wire gnd;

    keyboard_tracker #(parameter PULSE_OR_HOLD = 0) t0(
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
        .space(LEDR[0]),
        .enter(gnd)
    );

endmodule // fpga_top_kb