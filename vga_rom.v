module vga_rom (
	input clock,
	input reset,
	input alarm_on,
	input KEY,

	output wire plot,
	output wire [2:0] colour,
	output wire [9:0] x,
	output wire [8:0] y
);

wire on;
wire off;
wire done;

data datapath (
	.clk(clock),
	.reset(reset),
	.on(on),
	.off(off),
	.plot(plot),
	.done(done),
	.x(x),
	.y(y),
	.colour(colour)
);

control controlpath (
	.clk(clock),
	.reset(reset),
	.done(done),
	.alarm_on(alarm_on),
	.on(on),
	.off(off),
	.plot(plot)
);

endmodule

module data (
	input clk,
	input reset,

	input on,
	input off,
	input plot,

	output reg done,
	output wire [9:0] x,
	output wire [8:0] y,
	output wire [2:0] colour
	);

	reg  [16:0] address;
	wire [2:0] on_colour;
	wire [2:0] off_colour;

	reg [8:0] x_address;
	reg [7:0] y_address;
	reg [2:0] colour_reg;
	
	a_on onmiff (
	.clock (clk),
	.address (address),
	.q(on_colour)
	);

	a_off offmiff (
	.clock(clk),
	.address(address),
	.q(off_colour)
	);
	
	assign x = x_address;
	assign y = y_address;
	assign colour = colour_reg;

	always@(posedge clk) begin
		if (reset) begin
			address <= 0;
			y_address <= 0;
			x_address <= 0;
			colour_reg <= 0;
			done <= 0;
		end

		else if (plot) begin
			if (address < 17'd76800) begin
				address <= address + 1'b1;
				done <= 0;
			end
			else begin
				address <= 0;
				done <= 1;
			end

			if (x_address < 9'd319) begin
				x_address <= x_address + 1;
			end
			else begin
				if (y_address < 8'd239) begin
					y_address <= y_address + 1;
				end
				else begin
					y_address <= 0;
				end
				x_address <= 0;
			end

			if (on) begin
				colour_reg <= on_colour;
			end
			else if (off) begin
				colour_reg <= off_colour;
			end
		end
		else begin
			address <= 0;
			x_address <= 0;
			y_address <= 0;
			end
	end
endmodule

module control(
	input clk,
	input reset,
	input done,
	input alarm_on,
	
	output reg on,
	output reg off,
	output reg plot
	);
	
	reg [5:0] current_state, next_state;
	
	localparam  S_START			 = 5'd0,
					S_WAIT_OFF		 = 5'd1,
					S_ALARM_OFF      = 5'd2,
					S_WAIT_ON		 = 5'd3,
					S_ALARM_ON		 = 5'd4;
					
	always@(*)
	begin: state_table
		case (current_state)
			S_START: 		next_state = alarm_on ? S_WAIT_ON : S_WAIT_OFF;
			S_WAIT_OFF: 	next_state = alarm_on ? S_WAIT_OFF : S_ALARM_OFF;
			S_ALARM_OFF: 	next_state = done ? S_WAIT_ON : S_ALARM_OFF;
			S_WAIT_ON: 		next_state = alarm_on ? S_ALARM_ON : S_WAIT_ON;
			S_ALARM_ON: 	next_state = done ? S_WAIT_OFF : S_ALARM_ON;
			default: next_state = S_START;
		endcase
	end 
	 
	always@(*)
	begin: enable_signals
		//by default make all signals 0
		on = 0;
		off = 0;
		plot = 0;
		
		case (current_state)
			S_ALARM_OFF: begin
				off = 1;
				plot = 1;
			end
			S_ALARM_ON: begin
				on = 1;
				plot = 1;
			end
		endcase
	end
	
	// current_state registers
    always@(posedge clk)
    begin: state_FFs
        if (reset)
				current_state <= S_START;
        else
            current_state <= next_state;
    end // state_FFS
endmodule