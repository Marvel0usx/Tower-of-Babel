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
    input enable,                       // enable x to shift
    input save_x,
    input ld_x,                         // below are control signals from FSM
    input ld_y,                         // load new y value
    input ld_d,
    input inc_score,
    input dec_chances,
    input new_direction,
    input [7:0] new_x_position,
    input [6:0] new_y_position,

    output o,                           // overlapping
    output reg c,                       // chances left
    output [7:0] curr_x_position,       // current x position to display
    output [7:0] out_prev_x_position,   // debug: previour x
    output [6:0] curr_y_position,       // current y position to display
    output reg [3:0] chances,
    output reg [3:0] score
    );

    // internal registers
    reg [7:0] prev_x_position;

    // wires and assignment
    assign out_prev_x_position = prev_x_position;
    
    // local variables
    localparam CHANCES = 4'b1010;

    // import modules
    x_register x(
        .clk(clk),
        .sync(sync),
        .resetn(resetn),
        .enable(enable),
        .load_x(ld_x),
        .load_direction(ld_d),
        .new_direction(new_direction),
        .new_x_position(new_x_position),
        .curr_x_position(curr_x_position)
    );

    y_register y(
        .clk(clk),                              // 50MHz clock signal
        .resetn(resetn),                        // synchronized reset
        .load(ld_y),
        .new_y_position(new_y_position),
        .curr_y_position(curr_y_position)
    );

    overlap_detector o0(
        .clk(clk),
        .resetn(resetn),
        .curr_x_position(curr_x_position),
        .prev_x_position(prev_x_position),
        .q(o)
	);

    // registers x, y, score, chances with repective logic
    always @(posedge clk) begin
        if (!resetn) begin
            prev_x_position <= 0;
            chances <= CHANCES;
            score <= 0;
        end
        else begin
            if (save_x)
                prev_x_position <= curr_x_position;
            else
                prev_x_position <= prev_x_position;
            // update chances register
            if (dec_chances) begin
                if (chances > 0)
                    chances <= chances - 1'b1;
                else
                    chances <= 0;
            end
            else chances <= chances;
            // update score register
            if (inc_score)
                score <= score + 1'b1;        // overflow!!
            else
                score <= score;
            // update c flag
            if (chances > 0)
                c <= 1;
            else
                c <= 0;
        end
    end
endmodule // gameplay_datapath

