/* Row Counter
 * -----------------
 *
 * This module counts the row that the player is in.
 */

module row_counter(
    input clk,
    input resetn,
    input inc_row,

    output reg new_direction,
    output reg [6:0] new_y_position,
    output reg [7:0] new_x_position
    );
    
    // internal register
    reg [4:0] r;
    
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

    always @(posedge clk) begin
        if (!resetn)
            r <= 5'b0;
        else begin
            if (inc_row)
                r <= r + 1;
            else
                r <= r;
        end
    end

    always @(*) begin
        case (r)
            5'd0: begin
                    new_y_position = Y_ROW_0;
                    new_x_position = X_INIT;
                    new_direction = GO_RIGHT;
                  end
            5'd1: begin
                    new_direction  = GO_LEFT;
                    new_x_position = X_END;
                    new_y_position = Y_ROW_1;
                  end
            5'd2: begin
                    new_direction  = GO_RIGHT;
                    new_x_position = X_INIT;
                    new_y_position = Y_ROW_2;
                  end
            5'd3: begin
                    new_direction  = GO_LEFT;                            
                    new_x_position = X_END;
                    new_y_position = Y_ROW_3;
                  end
            5'd4: begin
                    new_direction  = GO_RIGHT;                            
                    new_x_position = X_INIT;
                    new_y_position = Y_ROW_4;
                  end
            5'd5: begin
                    new_direction  = GO_LEFT;                            
                    new_x_position = X_END;
                    new_y_position = Y_ROW_5;
                  end
            5'd6: begin
                    new_direction  = GO_RIGHT;                            
                    new_x_position = X_INIT;
                    new_y_position = Y_ROW_6;
                  end
            default: begin
				        new_direction  = GO_RIGHT;                            
                    new_x_position = X_INIT;
						  new_y_position = Y_ROW_0;
						end
        endcase
    end
endmodule // row_counter