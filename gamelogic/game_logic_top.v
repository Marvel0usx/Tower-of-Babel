/* Game Logic Toplevel Module
 * --------------------------
 * 
 * This module encapsulates all components that drives the backend of the
 * game, which are gameplay_control.v and gameplay_datapath.v. It also 
 * provides with output registers that is used by the display module.
 * --------------------------
 *
 * NOTE: please manually reset first
 *--------------------------- 
 *
 * Parameters:
 *  - clk           "50MHz clock"
 *  - reset         "synchronized reset"
 *
 * Outputs:
 *  - x             "x position of the block"
 *  - y             "y position of the block"
 *  - sync          "synchronizing signal from delay counter"
 *  - bypass		  "bypass VGA erase"
 *  - score         "score of the player"
 *  - chances       "remaining chances"
 *  - o             "overlapping flag"
 *  - game_status   "game status for display FSM"
 */
 
module game_logic_top(
    input clk,
    input resetn,
    input KEY,
    
    output sync,
    output w_o,
	 output bypass_erase,
    output [7:0] prev_x,
    output [7:0] x,
    output [6:0] y,
    output [3:0] score,
    output [3:0] chances,
    output [1:0] game_status
    );

    // gameplay_control module I/O wires
    wire w_c, w_p;
    wire w_ld_x, w_ld_y, w_ld_d, w_ld_df;
    wire w_enable, w_save_x;
    wire w_inc_row, w_inc_score, w_dec_chances;

    // gameplay_datapath module I/O wires
	 assign bypass_erase = w_inc_row;


    gameplay_control c0(
        .clk(clk),
        .resetn(resetn),
        .s(KEY),
        .c(w_c),
        .p(w_p),
        .o(w_o),

        .ld_x(w_ld_x),
        .ld_y(w_ld_y),
        .ld_d(w_ld_d),
		  .ld_df(w_ld_df),
        .enable(w_enable),
        .save_x(w_save_x),
        .inc_row(w_inc_row),
        .inc_score(w_inc_score),
        .dec_chances(w_dec_chances),
        .game_status(game_status)
    );

    gameplay_datapath d0(
        .clk(clk),
        .resetn(resetn),
        .enable(w_enable),
        .save_x(w_save_x),
        .ld_x(w_ld_x),
        .ld_y(w_ld_y),
        .ld_d(w_ld_d),
		  .ld_df(w_ld_df),
        .inc_row(w_inc_row),
        .inc_score(w_inc_score),
        .dec_chances(w_dec_chances),
        
        .sync(sync),
        .o(w_o),    
        .c(w_c),
        .curr_x_position(x),
        .out_prev_x_position(prev_x),               //debug
        .curr_y_position(y),
        .chances(chances),
        .score(score)
    );

endmodule // game_logic_top