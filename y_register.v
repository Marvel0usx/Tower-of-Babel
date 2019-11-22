module y_register(
    input clk,                      // 50MHz clock signal
    input resetn,                   // synchronized reset
    input enable,
    input parload,                  // parallel load
    input [6:0] value,              // value being loaded
    
    output reg [6:0] curr_y_position
    );

    // local variables
    localparam Y_INIT     = 7'b1101000,  // initial y position, at the bottom
               UNIT_BLOCK = 5'b10000;    // width of block
    
    always @(posedge clk) begin
        if (!resetn) begin
            curr_y_position <= Y_INIT;
        end
        else if (parload) begin
            curr_y_position <= value;
        end
        else if (enable)
            curr_y_position <= curr_y_position;
    end
    
endmodule // y_register