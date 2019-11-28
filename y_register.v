module y_register(
    input clk,                      // 50MHz clock signal
    input resetn,                   // synchronized reset
    input load,                     // parallel load
    input [6:0] new_y_position,     // new_y_position being loaded
    
    output reg [6:0] curr_y_position
    );

    // local variables
    localparam Y_INIT     = 7'b1101000,  // initial y position, at the bottom
               UNIT_BLOCK = 5'b10000;    // width of block
    
    // register logic
    always @(posedge clk) begin
        if (!resetn)
            curr_y_position <= Y_INIT;
        else if (load)
            curr_y_position <= new_y_position;
        else
            curr_y_position <= curr_y_position;
    end
    
endmodule // y_register