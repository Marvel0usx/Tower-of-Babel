module display_top
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input   [9:0]   SW;
	input   [3:0]   KEY;

	// Declare your inputs and outputs here
	input 
	
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn;
	assign resetn = KEY[0];
	
	wire update, draw_game, erase, draw_end, resetc;
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;
	

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.
    	
	datapath d0(
		.clock(CLOCK_50), 
		.reset_n(resetn),
		.x_in(SW[9:7]),
		.y_in(SW[6:4]),
		.update(update),
		.draw_game(draw_game),
		.erase(erase),
		.draw_end(draw_end),
		.resetc(resetc),
		
		.x_out(x), 
		.y_out(y), 
		.colour_out(colour)
		);

    // Instansiate FSM control
    // control c0(...);
	 
	 control c0(
		.clock(CLOCK_50), 
		.reset_n(resetn), 
		.sync(SW[3]),
		.move_level(SW[2]),
		.phase(SW[1:0]),
		
		.resetc(resetc),
		.update(update),
		.draw_game(draw_game),
		.erase(erase),
		.draw_end(draw_end),
		.wren(writeEn)
		);
	 
    
endmodule



module control(clock, reset_n, sync, move_level, phase, update, draw_game, erase, draw_end, resetc, wren);

	input clock, reset_n, sync, move_level;
	input [1:0] phase;
	
	output reg update, draw_game, erase, draw_end, resetc;
	output reg wren;
	
	reg enable_erase_counter;
	
	reg [2:0] current_state, next_state;
	
	localparam 	S_ERASE = 3'd0,
					S_UPDATE = 3'd1,
					S_DRAW_GAME = 3'd2,
					S_DRAW_RESETC =3'd3, 
					S_DRAW_END = 3'd4;
					
					
	counter_9bit counter_erase(
		.reset_n(reset_n),
		.enable(enable_erase_counter),
		.clock(clock),
		.out(erase_counter_out)
	);
	
	
	
	// state table
	always @(*) begin	
		case (current_state)
		
			S_UPDATE: begin
				if (phase == 2'b01) 
					next_state = S_DRAW_GAME;
				else if (phase == 2'b00) begin
					next_state = S_UPDATE;
				end
				
				else
					next_state = S_DRAW_END;
			end
			
			S_DRAW_GAME: begin
				if (!sync)
					next_state = S_DRAW_GAME;
				else if (!move_level) begin
					next_state = S_DRAW_RESETC;
				end
				
				else
					next_state = S_UPDATE;
				
			end
			
			S_DRAW_RESETC: next_state = S_ERASE;
			
			S_ERASE: next_state =  erase_counter_out ? S_UPDATE : S_ERASE;
			
			S_DRAW_END: next_state = S_DRAW_END;
			
			default: next_state = S_ERASE;
			
		endcase
	end
	
	

	always @(*) begin
		
		update = 1'b0;
		draw_game = 1'b0; 
		erase = 1'b0; 
		draw_end = 1'b0; 
		wren = 1'b0;
		resetc = 1'b0;
		enable_erase_counter = 1'b0;
			
		case (current_state)
			S_UPDATE: begin
				update = 1'b1;
			end
			S_DRAW_GAME: begin
				wren = 1'b1;
				draw_game = 1'b1;
			end
			S_DRAW_RESETC: begin
				resetc = 1'b1;
			end
			S_ERASE: begin
				wren = 1'b1;
				erase = 1'b1;
				enable_erase_counter = 1'b1;
			end
			S_DRAW_END: begin
				draw_end = 1'b1;
			end

		endcase
	end
	
	
	always @(posedge clock) begin
		
		if (!reset_n)
			current_state <= S_ERASE;
			
		else
			current_state <= next_state;
	
	end	

endmodule


module datapath(clock, reset_n, x_in, y_in, update, draw_game, erase, draw_end, resetc, x_out, y_out, colour_out);

	input [7:0] x_in;
	input [6:0] y_in;
	input  clock, reset_n;
	input update, draw_game, erase, draw_end, resetc;
	
	output [7:0] x_out;
	output [6:0] y_out;
	output reg [2:0] colour_out;
	
	reg [7:0] x;
	reg [6:0] y;
	reg enable_counter;
	wire [7:0] counter_out;
	
	counter_8bit c0(
		.reset_n(reset_n),
		.enable(enable_counter),
		.clock(clock),
		.counter_out(counter_out)
		);
		
	
	assign x_out = x + {4'b0000, counter_out[3:0]};
	assign y_out = y + {3'b000, counter_out[7:4]};
	
	
	
	always @(posedge clock) begin
		
		if (!reset_n) begin
			x <= 8'd0;
			y <= 7'd0;
			colour_out <= 3'b000;
			enable_counter <= 1'b0;
		end
		
		else if (resetc) begin
			enable_counter <= 1'b0;
		end
		
		else if (update) begin
			x <= x_in;
			y <= y_in;
			enable_counter <= 1'b0;
		end
		
		else if (draw_game) begin
			colour_out <= 3'b111;
			enable_counter <= 1'b1;
		end
		
		else if (erase) begin
			colour_out <= 3'b001;
			enable_counter <= 1'b1;
		end
							
	end
	
	
endmodule

// 0~255
 module counter_8bit(reset_n, enable, clock, counter_out);
	
	input reset_n, enable, clock;
	
	output reg [7:0] counter_out;
	
	always @(posedge clock) begin
	
		if (!reset_n)
			counter_out <= 8'b11111111;
		
		else if (enable) begin	
		
				if (counter_out == 8'b11111111)
					counter_out <= 8'd0;
				else 
					counter_out <= counter_out + 1;							
		end
		
		else
			counter_out <= 8'b11111111;
		
	end
	
endmodule


// 512 -> 0
 module counter_9bit(reset_n, enable, clock, out);
	
	input reset_n, enable, clock;
	
	output out;
	
	reg [8:0] counter;
	
	always @(posedge clock) begin
	
		if (!reset_n)
			counter <= 9'b111111111;
		
		else if (enable) begin	
		
				if (counter == 9'd0)
					counter <= 9'd0;
				else 
					counter <= counter - 1;							
		end
		
		else
			counter <= 9'b111111111;
	end
	
	assign out = ~(|counter);
	
endmodule
