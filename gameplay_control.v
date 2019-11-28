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
 *  - inc_score         "increment score"
 *  - dec_chances       "minus chances by 1"
 *  - new_direction     "value to be loaded to direction register"
 *  - game_status       "game status code for display FSM"
 *  - new_x_position    "value to be loaded to x_register"
 *  - new_y_position    "value to be loaded to y_register"
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
    output reg inc_score,
    output reg dec_chances,
    output reg new_direction,
    
    output reg [1:0] game_status,
    output reg [7:0] new_x_position,
    output reg [6:0] new_y_position
    );

    // internal registers
    reg [5:0] curr_state, next_state;

    // predefined states
    localparam ROW_0_PREP   = 5'd0,
               ROW_0        = 5'd1,
               ROW_0_WAIT   = 5'd2,
               ROW_1_PREP   = 5'd3,
               ROW_1        = 5'd4,
               ROW_1_WAIT   = 5'd5,
               ROW_2_PREP   = 5'd6,
               ROW_2        = 5'd7,
               ROW_2_WAIT   = 5'd8,
               ROW_3_PREP   = 5'd9,
               ROW_3        = 5'd10,
               ROW_3_WAIT   = 5'd11,
               ROW_4_PREP   = 5'd12,
               ROW_4        = 5'd13,
               ROW_4_WAIT   = 5'd14,
               ROW_5_PREP   = 5'd15,
               ROW_5        = 5'd16,
               ROW_5_WAIT   = 5'd17,
               ROW_6_PREP   = 5'd18,
               ROW_6        = 5'd19,
               ROW_6_WAIT   = 5'd20,
               WIN          = 5'd21,
               END          = 5'd22;

    // pixel corresponding to row
    localparam Y_ROW_0 = 7'd104,
               Y_ROW_1 = 7'd88,
               Y_ROW_2 = 7'd72,
               Y_ROW_3 = 7'd56,
               Y_ROW_4 = 7'd40,
               Y_ROW_5 = 7'd24,
               Y_ROW_6 = 7'd8;
    
    // pixel cooresponding to column
    localparam X_INIT   = 8'b0,
               X_END    = 8'd144,
               GO_LEFT  = 1'b0,
               GO_RIGHT = 1'b1;

    // state table
    always @(*) begin
        case (curr_state)
            ROW_0_PREP : next_state = ROW_0;
            ROW_0      : next_state = s ? ROW_0 : ROW_0_WAIT;
            ROW_0_WAIT : begin
                            if (~s)
                                next_state = ROW_0_WAIT;
                            else if (s)
                                next_state = ROW_1_PREP;
                            else
                                next_state = next_state;                         
                         end
            ROW_1_PREP : next_state = ROW_1;
            ROW_1      : begin
                            if (~c)
                                next_state = END;
                            else
                                next_state = s ? ROW_1 : ROW_1_WAIT;
                         end
            ROW_1_WAIT : begin
                            if (~s)
                                next_state = ROW_1_WAIT;
                            else if (s && o)
                                next_state = ROW_2_PREP;
                            else if (s && ~o)
                                next_state = ROW_1_PREP;
                            else
                                next_state = next_state;                            
                         end
            ROW_2_PREP : next_state = ROW_2;
            ROW_2      : begin
                            if (~c)
                                next_state = END;
                            else
                                next_state = s ? ROW_2 : ROW_2_WAIT;
                         end
            ROW_2_WAIT : begin
                            if (~s)
                                next_state = ROW_2_WAIT;
                            else if (s && o)
                                next_state = ROW_3_PREP;
                            else if (s && ~o)
                                next_state = ROW_2_PREP;
                            else
                                next_state = next_state;                                
                         end
            ROW_3_PREP : next_state = ROW_3;
            ROW_3      : begin
                            if (~c)
                                next_state = END;
                            else
                                next_state = s ? ROW_3 : ROW_3_WAIT;
                         end
            ROW_3_WAIT : begin
                            if (~s)
                                next_state = ROW_3_WAIT;
                            else if (s && o)
                                next_state = ROW_4_PREP;
                            else if (s && ~o)
                                next_state = ROW_3_PREP;
                            else
                                next_state = next_state;
                         end
            ROW_4_PREP : next_state = ROW_4;
            ROW_4      : begin
                            if (~c)
                                next_state = END;
                            else
                                next_state = s ? ROW_4 : ROW_4_WAIT;
                         end
            ROW_4_WAIT : begin
                            if (~s)
                                next_state = ROW_4_WAIT;
                            else if (s && o)
                                next_state = ROW_5_PREP;
                            else if (s && ~o)
                                next_state = ROW_4_PREP;
                            else
                                next_state = next_state;
                         end
            ROW_5_PREP : next_state = ROW_5;
            ROW_5      : begin
                            if (~c)
                                next_state = END;
                            else
                                next_state = s ? ROW_5 : ROW_5_WAIT;
                         end
            ROW_5_WAIT : begin
                            if (~s)
                                next_state = ROW_5_WAIT;
                            else if (s && o)
                                next_state = ROW_6_PREP;
                            else if (s && ~o)
                                next_state = ROW_5_PREP;
                            else
                                next_state = next_state;
                         end
            ROW_6_PREP : next_state = ROW_6;
            ROW_6      : begin
                            if (~c)
                                next_state = END;
                            else
                                next_state = s ? ROW_6 : ROW_6_WAIT;
                         end
            ROW_6_WAIT : begin
                            if (~s)
                                next_state = ROW_6_WAIT;
                            else if (s && o)
                                next_state = WIN;
                            else if (s && ~o)
                                next_state = ROW_6_PREP;
                            else
                                next_state = next_state;
                         end
            WIN        : next_state = s ? WIN : ROW_0;
            END        : next_state = s ? END : ROW_0;
            default: next_state = ROW_0;
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
        inc_score   = 0;                    // increasing score
        dec_chances = 0;                    // decreasing chances
        new_direction  = 0;
        new_x_position = 0;
        new_y_position = 0;

        // game_status for display FSM
        game_status = 2'b01;

        // state table output
        case (curr_state)
            ROW_0_PREP : begin
                            ld_x = 1'b1;
                            ld_y = 1'b1;
                            ld_d = 1'b1;
                            new_direction  = GO_RIGHT;
                            new_x_position = X_INIT;
                            new_y_position = Y_ROW_0;
                         end
            ROW_0      : enable = 1'b1;
            ROW_0_WAIT : enable = 1'b1;
            ROW_1_PREP : begin
                            ld_x = 1'b1;
                            ld_y = 1'b1;
                            ld_d = 1'b1;
                            save_x = 1'b1;
                            new_direction  = GO_LEFT;
                            new_x_position = X_END;
                            new_y_position = Y_ROW_1;
                            dec_chances = 1'b1;
                            inc_score   = 1'b1;
                         end
            ROW_1      : enable = 1'b1;
            ROW_1_WAIT : enable = 1'b1;
            ROW_2_PREP : begin
                            ld_x = 1'b1;
                            ld_y = 1'b1;
                            ld_d = 1'b1;
                            save_x = 1'b1;
                            new_direction  = GO_RIGHT;
                            new_x_position = X_INIT;
                            new_y_position = Y_ROW_2;
                            dec_chances = 1'b1;
                            inc_score   = 1'b1;
                         end
            ROW_2      : enable = 1'b1;
            ROW_2_WAIT : enable = 1'b1;
            ROW_3_PREP : begin
                            ld_x = 1'b1;
                            ld_y = 1'b1;
                            ld_d = 1'b1;
                            save_x = 1'b1;
                            new_direction  = GO_LEFT;                            
                            new_x_position = X_END;
                            new_y_position = Y_ROW_3;
                            dec_chances = 1'b1;
                            inc_score   = 1'b1;
                         end
            ROW_3      : enable = 1'b1;
            ROW_3_WAIT : enable = 1'b1;
            ROW_4_PREP : begin
                            ld_x = 1'b1;
                            ld_y = 1'b1;
                            ld_d = 1'b1;
                            save_x = 1'b1;
                            new_direction  = GO_RIGHT;                            
                            new_x_position = X_INIT;
                            new_y_position = Y_ROW_4;
                            dec_chances = 1'b1;
                            inc_score   = 1'b1;
                         end
            ROW_4      : enable = 1'b1;
            ROW_4_WAIT : enable = 1'b1;
            ROW_5_PREP : begin
                            ld_x = 1'b1;
                            ld_y = 1'b1;
                            ld_d = 1'b1;
                            save_x = 1'b1;
                            new_direction  = GO_LEFT;                            
                            new_x_position = X_END;
                            new_y_position = Y_ROW_5;
                            dec_chances = 1'b1;
                            inc_score   = 1'b1;
                         end
            ROW_5      : enable = 1'b1;
            ROW_5_WAIT : enable = 1'b1;
            ROW_6_PREP : begin
                            ld_x = 1'b1;
                            ld_y = 1'b1;
                            ld_d = 1'b1;
                            save_x = 1'b1;
                            new_direction  = GO_RIGHT;                            
                            new_x_position = X_INIT;
                            new_y_position = Y_ROW_6;
                            dec_chances = 1'b1;
                            inc_score   = 1'b1;
                         end
            ROW_6      : enable = 1'b1;
            ROW_6_WAIT : enable = 1'b1;
            WIN        : game_status = 2'b10;
            END        : game_status = 2'b11;
            default    : ROW_0;
        endcase
    end

endmodule // gameplay_control