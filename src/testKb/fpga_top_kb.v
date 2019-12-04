module fpga_top_kb(CLOCK_50, KEY, PS2_CLK, PS2_DAT, LEDR, GPIO_0, GPIO_1);
    input CLOCK_50;
    input [3:0] KEY;
    input PS2_CLK;
    input PS2_DAT;
    output [9:0] LEDR;
    inout [35:0] GPIO_0, GPIO_1;

    keyboard_adapter kb(
        .clk(CLOCK_50),
        .resetn(KEY[0]),
        .PS2_DAT(PS2_DAT),
        .PS2_CLK(PS2_CLK),
        .s(LEDR[0]),
        .GPIO_0(GPIO_0),
        .GPIO_1(GPIO_1)
    );

endmodule // fpga_top_kb