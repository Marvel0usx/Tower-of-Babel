/* Gameplay Datapath
 * ------------------
 *
 * This module integrates all registers and counters that 
 * will be used to run the game. It sends back signal of the
 * curr_x_position and curr_y_position to the display.
 * 
 * The corresponding control signals are sent by gameplay_control
 * FSM.
 */

module gameplay_datapath(
    input clk,                          // 50MHz clock
    input sync,                         // synchronized signal for x_register
    input resetn,                       // synchronized reset
    input enable,                       // enable or pause the game
    input move_on,                      // reset x and load new y
    input ld_y,                         // load new y value
    input inc_score,
    input dec_chances,
    input [6:0] y_value,

    output o,                           // overlapping
    output c,                           // chances left
    output [7:0] curr_x_position,       // current x position to display
    output [6:0] curr_y_position,       // current y position to display
    );

    // internal registers
    reg [7:0] prev_x_position;
    reg [3:0] chances;
    reg [6:0] score;
    
    // local variables
    localparam CHANCES = 4'b1010;

    // import modules
    x_register x(
        .clk(clk),
        .sync(sync),
        .resetn(resetn && ~move_on), // reset register x when FSM goes to another
        .enable(enable),
        .curr_x_position(curr_x_position)
    );

    y_register y(
        .clk(clk),                              // 50MHz clock signal
        .resetn(resetn),                        // synchronized reset
        .enable(enable),
        .parload(ld_y),
        .value(y_value),
        .curr_y_position(curr_y_position)
    );

    overlap_detector o0(
        .clk(clk),
        .resetn(resetn),
        .curr_x_position(curr_x_position),
        .prev_x_position(prev_x_position),
        .q(o)
	);

    // assign to chances flag
    assign c = (chances > 0) ? 1'b1 : 1'b0;

    // registers x, y, score, chances with repective logic
    always @(posedge clk) begin
        if (!resetn) begin
            prev_x_position <= 0;
            chances <= CHANCES;
            score <= 0;
        end
        else begin
            if (dec_chances) begin
                if (chances > 0)
                    chances <= chances - 1;
                else
                    chances <= 0;
            end
            if (inc_score) begin
                score <= score + 4'b1010;        // overflow!!
            end
            if (move_on) begin
                prev_x_position <= curr_x_position;
            end
        end
    end

endmodule // gameplay_datapath

