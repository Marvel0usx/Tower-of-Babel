 module fpga_top(SW, KEY, CLOCK_50, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
    input [9:0] SW;
    input [3:0] KEY;
    input CLOCK_50;
    output [9:0] LEDR;
    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

    wire [7:0] p_x_out, x_out;
    wire [6:0] y_out;

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

    game_logic_top logic(
        .clk(CLOCK_50),
        .sync(KEY[1]),
        .resetn(KEY[0]),
        .KEY(KEY[3]),
        .o(LEDR[0]),
        .x(p_x_out),
        .y(y_out),
        .score(LEDR[9:6]),
        .chance(LEDR[5:3]),
        .game_status(LEDR[2:1])
    );

endmodule // game_logic_top

module hex_decoder(hex_digit, segments);
    input [3:0] hex_digit;
    output reg [6:0] segments;
   
    always @(*)
        case (hex_digit)
            4'h0: segments = 7'b100_0000;
            4'h1: segments = 7'b111_1001;
            4'h2: segments = 7'b010_0100;
            4'h3: segments = 7'b011_0000;
            4'h4: segments = 7'b001_1001;
            4'h5: segments = 7'b001_0010;
            4'h6: segments = 7'b000_0010;
            4'h7: segments = 7'b111_1000;
            4'h8: segments = 7'b000_0000;
            4'h9: segments = 7'b001_1000;
            4'hA: segments = 7'b000_1000;
            4'hB: segments = 7'b000_0011;
            4'hC: segments = 7'b100_0110;
            4'hD: segments = 7'b010_0001;
            4'hE: segments = 7'b000_0110;
            4'hF: segments = 7'b000_1110;   
            default: segments = 7'h7f;
        endcase
endmodule
