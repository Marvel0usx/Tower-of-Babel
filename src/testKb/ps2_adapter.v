/* Keyboard Adapter
 * ------------------
 *
 * This module is used for reading PS-2 keyboard input and
 * send this input signal to the game control through game_logic_to.v
 * as the input signal 's'. It will be used in the game to move the 
 * focus to the next row.
 * 
 */

module keyboard_adapter(
    input clk,                      // 50MHz clock
    input resetn,                   // active-low sync reset signal
    input PS2_DAT,                  // PS2 data and clock lines
    input PS2_CLK,

    output reg s,                       // s signal used by gamelogic FSM
    inout [35:0] GPIO_0, GPIO_1     // GPIO Connections
    );

    //  set all inout ports to tri-state
    assign  GPIO_0    =  36'hzzzzzzzzz;
    assign  GPIO_1    =  36'hzzzzzzzzz;

    wire [7:0] scan_code;
    wire read, scan_ready;
    reg [7:0] scan_history[1:2];

    always @(posedge scan_ready) begin
        scan_history[2] <= scan_history[1];
        scan_history[1] <= scan_code;
    end
    // END OF PS2 KB SETUP

    // keyboard section
    oneshot pulse(
        .pulse_out(read),
        .trigger_in(scan_ready),
        .clk(clk)
    );

    keyboard kb(
        .keyboard_clk(PS2_CLK),
        .keyboard_data(PS2_DAT),
        .clock50(clk),
        .reset(~resetn),
        .read(read),
        .scan_ready(scan_ready),
        .scan_code(scan_code)
    );

    // detecting for [SPACE] key
    always @(posedge clk) begin
        if (!resetn) begin
            s <= 1'b0;
            scan_history[1] = 8'b0;
            scan_history[2] = 8'b0;
        end
        else if (scan_history[1] == 'h29)
            s <= 1'b1;
        else if (scan_history[1] == 'hF)
            s <= 1'b0;
        else
            s <= s;
    end

endmodule // keyboard_adapter