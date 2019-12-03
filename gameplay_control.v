/* Gameplay control
 * ------------------
 *
 * This module takes care of the game logic by implementing a
 * FSM. It controls the gameplay_datapath module and provides
 * player an interactive experience.
 * -------------------
 * 
 * Parameters: 
 *  - s "key for placing blocks"
 *  - c "remaining chances are greater than zero"
 *  - p "pause game"
 *  - o "overlap detected"
 *
 * Outputs:
 *  - ld_x              "load value to x_register"
 *  - ld_y              "load value to y_register"
 *  - ld_d              "load value to direction register"
 *  - enable            "enable x to shift"
 *  - save_x            "save the current x to register prev_x_register"
 *  - inc_row           "increment the row number"
 *  - inc_score         "increment score"
 *  - dec_chances       "minus chances by 1"
 *  - game_status       "game status code for display FSM"
 * --------------------
 */

module gameplay_control(
    input  clk,
    input  resetn,
    input  s,
    input  c,
    input  p,
    input  o,
    
    output reg ld_x,
    output reg ld_y,
    output reg ld_d,
    output reg enable,
    output reg save_x,
    output reg inc_row,
    output reg inc_score,
    output reg dec_chances,
    
    output reg [1:0] game_status
    );

    // internal registers
    reg [4:0] curr_state, next_state;

    // predefined states
    localparam ROW_0_PREP = 4'd0,
               ROW_0      = 4'd1,
               ROW_0_HOLD = 4'd2,
               PREP_NEXT  = 4'd3,
               NEXT_ROW   = 4'd4,
               ROW_HOLD   = 4'd5,
               JUDGE      = 4'd6,
               ROW_FAIL   = 4'd7,
               END        = 4'd8;

    // state table
    always @(*) begin
        case (curr_state)
            ROW_0_PREP : next_state = ROW_0;
            ROW_0      : next_state = s ? ROW_0 : ROW_0_HOLD;
            ROW_0_HOLD : next_state = s ? PREP_NEXT : ROW_0_HOLD;
            PREP_NEXT  : next_state = NEXT_ROW;
            NEXT_ROW   : begin
                            if (~c)
                                next_state = END;
                            else
                                next_state = s ? NEXT_ROW : ROW_HOLD;
                         end
            ROW_HOLD   : next_state = s ? JUDGE : ROW_HOLD;
            JUDGE      : next_state = o ? PREP_NEXT : ROW_FAIL;
            ROW_FAIL   : next_state = NEXT_ROW;
            default    : next_state = ROW_0_PREP;
        endcase
    end // state table

    // output logic aka all of the datapath control signals
    always @(*) begin
        // initializing signals to datapath
        ld_x        = 0;                    // parallel load x register
        ld_y        = 0;                    // parallel load y register
        ld_d        = 0;                    // parallel load direction
        enable      = 0;                    // enable for incrementing x_register
        save_x      = 0;                    // save current x value
        inc_row     = 0;                    // move on to the next row
        inc_score   = 0;                    // increasing score
        dec_chances = 0;                    // decreasing chances

        // game_status for display FSM
        game_status = 2'b01;

        // state table output
        case (curr_state)
            ROW_0_PREP : begin
                            ld_x = 1'b1;
                            ld_y = 1'b1;
                            ld_d = 1'b1;
                         end
            ROW_0      : enable = 1'b1;
            ROW_0_HOLD : enable = 1'b1;
            PREP_NEXT  : begin
                            ld_x = 1'b1;
                            ld_y = 1'b1;
                            ld_d = 1'b1;
                            save_x = 1'b1;
                            inc_row = 1'b1;
                            inc_score = 1'b1;
                            dec_chances = 1'b1;
                         end
            NEXT_ROW   : enable = 1'b1;
            ROW_HOLD   : enable = 1'b1;
            ROW_FAIL   : begin
                            ld_x = 1'b1;
                            ld_y = 1'b1;
                            ld_d = 1'b1;
                            dec_chances = 1'b1;
                         end
            END        : game_status = 2'b10;
				default    : game_status = 2'b10;
        endcase
    end

    // updating states
    always @(posedge clk) begin
        if (!resetn)
            curr_state <= ROW_0_PREP;
        else
            curr_state <= next_state;
    end

endmodule // gameplay_control