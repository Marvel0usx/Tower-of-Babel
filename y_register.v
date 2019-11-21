module y_register(
    input clk,                      // 50MHz clock signal
    input resetn,                   // synchronized reset
    input enable,
    input dec,                      // decrement signal, sent by FSM
    
    output reg [6:0] curr_y_position
    );

    // local variables
    localparam Y_INIT     = 7'b1101000,  // initial y position, at the bottom
               UNIT_BLOCK = 5'b10000;    // width of block
    
    always @(posedge clk) begin
        if (!reset) begin
            curr_y_position <= Y_INIT;
        end
        else if (enable)
            curr_y_position <= curr_y_position;
    end

    always @(posedge dec) begin
        if (enable) begin
            curr_y_position <= curr_y_position - UNIT_BLOCK;
        else
            curr_y_position <= curr_y_position;
        end
    end
    
endmodule // y_register