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
 *  - ld_y        "reload y"
 *  - move_on     "move on to the next row"
 *  - go_back     "go back to the current row"
 *  - inc_score   "increment score"
 *  - dec_chances "minus chances by 1"
 * --------------------
 */

module gameplay_control(
    input  clk,
    input  resetn,
    input  s,
    input  c,
    input  p,
    input  o,
    
    output reg ld_y,
    output reg enable,
    output reg move_on,
    output reg go_back,
    output reg inc_score,
    output reg dec_chances,

    output reg [1:0] game_status,
    output reg [6:0] new_y
    );

    // internal registers
    reg [3:0] curr_state, next_state;

    // predefined states
    localparam ROW_0        = 4'b0000,
               ROW_0_WAIT   = 4'b0001,
               ROW_1        = 4'b0010,
               ROW_1_WAIT   = 4'b0011,
               ROW_2        = 4'b0100,
               ROW_2_WAIT   = 4'b0101,
               ROW_3        = 4'b0110,
               ROW_3_WAIT   = 4'b0111,
               ROW_4        = 4'b1000,
               ROW_4_WAIT   = 4'b1001,
               ROW_5        = 4'b1010,
               ROW_5_WAIT   = 4'b1011,
               ROW_6        = 4'b1100,
               ROW_6_WAIT   = 4'b1101,
               WIN          = 4'b1110,
               END          = 4'b1111;

    // pixel corresponding to row
    localparam Y_ROW_0 = 7'd104,
               Y_ROW_1 = 7'd88,
               Y_ROW_2 = 7'd72,
               Y_ROW_3 = 7'd56,
               Y_ROW_4 = 7'd40,
               Y_ROW_5 = 7'd24,
               Y_ROW_6 = 7'd8;

    // state table
    always @(*) begin
        case (curr_state)
            ROW_0      : begin
                            if (~c)
                                next_state = END;
                            else
                                next_state = s ? ROW_0 : ROW_0_WAIT;
                         end
            ROW_0_WAIT : begin
                            if (~s)
                                next_state = ROW_0_WAIT;
                            else if (s)
                                next_state = ROW_1;
                            else
                                next_state <= next_state;                         
                         end
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
                                next_state = ROW_2;
                            else if (s && ~o)
                                next_state = ROW_1;
                            else
                                next_state <= next_state;                                
                         end
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
                                next_state = ROW_3;
                            else if (s && ~o)
                                next_state = ROW_2;
                            else
                                next_state <= next_state;                                
                         end
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
                                next_state = ROW_4;
                            else if (s && ~o)
                                next_state = ROW_3;
                            else
                                next_state <= next_state;
                         end
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
                                next_state = ROW_5;
                            else if (s && ~o)
                                next_state = ROW_4;
                            else
                                next_state <= next_state;
                         end
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
                                next_state = ROW_6;
                            else if (s && ~o)
                                next_state = ROW_5;
                            else
                                next_state <= next_state;
                         end
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
                                next_state = ROW_6;
                            else
                                next_state <= next_state;
                         end
            WIN        : next_state = s ? WIN : ROW_0;
            END        : next_state = s ? END : ROW_0;
            default: next_state = ROW_0;
        endcase
    end // state table

    // Output logic aka all of the datapath control signals
    always @(*) begin
        // enable for pausing the game
        move_on     = 0;
        go_back     = 0;
        inc_score   = 0;
        dec_chances = 0;
        ld_y        = 0;
        new_y       = 0;
        game_status = 2'b01;

        case (curr_state)
            ROW_0      : begin
                            ld_y = 1'b1;
                            new_y = Y_ROW_0;
                            move_on = 1'b1;
                         end
            ROW_0_WAIT : dec_chances = 1'b1;
            ROW_1      : begin
                            ld_y = 1'b1;
                            new_y = Y_ROW_1;
                            move_on = 1'b1;
                         end
            ROW_1_WAIT : dec_chances = 1'b1;
            ROW_2      : begin
                            ld_y = 1'b1;
                            new_y = Y_ROW_2;
                            move_on = 1'b1;
                         end 
            ROW_2_WAIT : dec_chances = 1'b1;
            ROW_3      : begin
                            ld_y = 1'b1;
                            new_y = Y_ROW_3;
                            move_on = 1'b1;
                         end
            ROW_3_WAIT : dec_chances = 1'b1;
            ROW_4      : begin
                            ld_y = 1'b1;
                            new_y = Y_ROW_4;
                            move_on = 1'b1;
                         end
            ROW_4_WAIT : dec_chances = 1'b1;
            ROW_5      : begin
                            ld_y = 1'b1;
                            new_y = Y_ROW_5;
                            move_on = 1'b1;
                         end
            ROW_5_WAIT : dec_chances = 1'b1;
            ROW_6      : begin
                            ld_y = 1'b1;
                            new_y = Y_ROW_6;
                            move_on = 1'b1;
                         end
            ROW_6_WAIT : dec_chances = 1'b1;
            WIN        : game_status = 2'b10;
            END        : game_status = 2'b11;
            default    : ROW_0;
        endcase
    end

endmodule // gameplay_control