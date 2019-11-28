module testFSM(
    input clk,
    input ld_x,
    input [9:0] new_x,
    input enable,
    input resetn,
    output reg [9:0] x
    );

    always @(posedge clk) begin
        if (!resetn)
            x <= 10'b0;
        else begin
            if (ld_x)
                x <= new_x;
            else begin
                if (enable)
                    x <= x - 1;
                else
                    x <= x;
            end
        end        
    end

endmodule