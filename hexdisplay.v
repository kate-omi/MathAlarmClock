`timescale 1ns / 1ns

module hexdisplay(
	input clock,
	input reset,

	input wire alarm_on,
	input wire question,
	input wire alarm_set,
	input wire clock_set,

	input wire [3:0] clock_hr,
	input wire [5:0] clock_min,

	input wire [3:0] alarm_hr,
	input wire [5:0] alarm_min,

	input wire [6:0] question_a,
	input wire [6:0] question_b,
	input wire [6:0] question_c,

	output wire [6:0] display0,
	output wire [6:0] display1,
	output wire [6:0] display2,
	output wire [6:0] display3,
	output wire [6:0] display4,
	output wire [6:0] display5
	);

	wire [3:0] value0;
	wire [3:0] value1;
	wire [3:0] value2;
	wire [3:0] value3;
	wire [3:0] value4;
	wire [3:0] value5;

data_decdecoder values( 	//decodes the 4-6 bit input into two 4 bit outputs which are oranized into the 7 segment display
		.clock(clock),
		.reset(reset),

		.alarm_on(alarm_on),
		.question(question),
		.alarm_set(alarm_set),
		.clock_set(clock_set),

		.clock_hr(clock_hr),
		.clock_min(clock_min),

		.alarm_hr(alarm_hr),
		.alarm_min(alarm_min),

		.question_a(question_a),
		.question_b(question_b),
		.question_c(question_c),
		
		.value0(value0),
		.value1(value1),
		.value2(value2),
		.value3(value3),
		.value4(value4),
		.value5(value5)
		);
	
	data_hexdecoder zero(.c(value0), .display(display0)); 	//decodes the 4 bit input into a 7 bit output for the 7 segment display
	data_hexdecoder one(.c(value1), .display(display1));
	data_hexdecoder two(.c(value2), .display(display2));
	data_hexdecoder three(.c(value3), .display(display3));
	data_hexdecoder four(.c(value4), .display(display4));
	data_hexdecoder five(.c(value5), .display(display5));

endmodule

module data_decdecoder (
	input clock,
	input reset,
	
	
	input alarm_on,
	input question,
	input alarm_set,
	input clock_set,
	
	input wire [3:0] clock_hr,
	input wire [5:0] clock_min,
	
	input wire [3:0] alarm_hr,
	input wire [5:0] alarm_min,
	
	input wire [6:0] question_a,
	input wire [6:0] question_b,
	input wire [6:0] question_c,
	
	output reg [3:0] value0,
	output reg [3:0] value1, 
	output reg [3:0] value2,
	output reg [3:0] value3,
	output reg [3:0] value4,
	output reg [3:0] value5	
	);
	
	always@(posedge clock) begin
		value0 <= 4'd10;
		value1 <= 4'd10;
		value2 <= 4'd10;
		value3 <= 4'd10;
		value4 <= 4'd10;
		value5 <= 4'd10;

		if (reset) begin
			value0 <= 4'd10;
			value1 <= 4'd10;
			value2 <= 4'd10;
			value3 <= 4'd10;
			value4 <= 4'd10;
			value5 <= 4'd10;
		end
		
		if (alarm_on && question) begin
			//first value
			if (question_a > 6'd9) begin
				value5 <= question_a / 6'd10;	//sets the first digit by dividing by 10
				value4 <= question_a % 6'd10;	//sets the second digit by getting remainder
			end
			else begin
				value5 <= 4'd10;
				value4 <= question_a;
			end

			//second value
			if (question_b > 6'd9) begin
				value3 <= question_b / 6'd10;
				value2 <= question_b % 6'd10;
			end
			else begin
				value3 <= 4'd10;
				value2 <= question_b;
			end

			//third value ie solution
			if (question_c > 6'd9) begin
				value1 <= question_c / 6'd10;
				value0 <= question_c % 6'd10;
			end
			else begin
				value1 <= 4'd10;
				value0 <= question_c;
			end
		end

		else if (alarm_set) begin
			//hours
			if (alarm_hr > 4'd9) begin
				value3 <= 4'd1;
				value2 <= alarm_hr - 4'd10;
			end
			else begin
				value3 <= 4'd10;
				value2 <= alarm_hr;
			end
			
			//minutes
			if (alarm_min > 6'd9) begin
				value1 <= alarm_min / 6'd10;
				value0 <= alarm_min % 6'd10;
			end
			else begin
				value1 <= 4'd0;
				value0 <= alarm_min;
			end
		end
		
		else if (clock_set) begin
			//hours
			if (clock_hr > 4'd9) begin
				value3 <= 4'd1;
				value2 <= clock_hr - 4'd10;
			end
			else begin
				value3 <= 4'd10;
				value2 <= clock_hr;
			end
			
			//minutes
			if (clock_min > 6'd9) begin
				value1 <= clock_min / 6'd10;
				value0 <= clock_min % 6'd10;
			end
			else begin
				value1 <= 4'd0;
				value0 <= clock_min;
			end
		end
	end
endmodule

module data_hexdecoder(c, display);

	input [3:0] c;
	output [6:0]display;

	assign display[0] = 
		//potential values (between 0-9)
		!((c[3]|c[2]|c[1]|!c[0])
		&(c[3]|!c[2]|c[1]|c[0])
		
		//not potential values (between A-F, which i dont want displayed)
		&(!c[3]|c[2]|!c[1]|c[0])
		&(!c[3]|c[2]|!c[1]|!c[0])
		&(!c[3]|!c[2]|c[1]|c[0])
		&(!c[3]|!c[2]|c[1]|!c[0])
		&(!c[3]|!c[2]|!c[1]|c[0])
		&(!c[3]|!c[2]|!c[1]|!c[0]));
	assign display[1] = 
		!((c[3]|!c[2]|c[1]|!c[0])
		&(c[3]|!c[2]|!c[1]|c[0])

		&(!c[3]|c[2]|!c[1]|c[0])
		&(!c[3]|c[2]|!c[1]|!c[0])
		&(!c[3]|!c[2]|c[1]|c[0])
		&(!c[3]|!c[2]|c[1]|!c[0])
		&(!c[3]|!c[2]|!c[1]|c[0])
		&(!c[3]|!c[2]|!c[1]|!c[0]));
	assign display[2] = 
		!((c[3]|c[2]|!c[1]|c[0])

		&(!c[3]|c[2]|!c[1]|c[0])
		&(!c[3]|c[2]|!c[1]|!c[0])
		&(!c[3]|!c[2]|c[1]|c[0])
		&(!c[3]|!c[2]|c[1]|!c[0])
		&(!c[3]|!c[2]|!c[1]|c[0])
		&(!c[3]|!c[2]|!c[1]|!c[0]));
	assign display[3] = 
		!((c[3]|c[2]|c[1]|!c[0])
		&(c[3]|!c[2]|c[1]|c[0])
		&(c[3]|!c[2]|!c[1]|!c[0])

		&(!c[3]|c[2]|!c[1]|c[0])
		&(!c[3]|c[2]|!c[1]|!c[0])
		&(!c[3]|!c[2]|c[1]|c[0])
		&(!c[3]|!c[2]|c[1]|!c[0])
		&(!c[3]|!c[2]|!c[1]|c[0])
		&(!c[3]|!c[2]|!c[1]|!c[0]));
	assign display[4] = 
		!((c[3]|c[2]|c[1]|!c[0])
		&(c[3]|c[2]|!c[1]|!c[0])
		&(c[3]|!c[2]|c[1]|c[0])
		&(c[3]|!c[2]|c[1]|!c[0])
		&(c[3]|!c[2]|!c[1]|!c[0])
		&(!c[3]|c[2]|c[1]|!c[0])
		
		&(!c[3]|c[2]|!c[1]|c[0])
		&(!c[3]|c[2]|!c[1]|!c[0])
		&(!c[3]|!c[2]|c[1]|c[0])
		&(!c[3]|!c[2]|c[1]|!c[0])
		&(!c[3]|!c[2]|!c[1]|c[0])
		&(!c[3]|!c[2]|!c[1]|!c[0]));
	assign display[5] = 
		!((c[3]|c[2]|c[1]|!c[0])
		&(c[3]|c[2]|!c[1]|c[0])
		&(c[3]|c[2]|!c[1]|!c[0])
		&(c[3]|!c[2]|!c[1]|!c[0])

		&(!c[3]|c[2]|!c[1]|c[0])
		&(!c[3]|c[2]|!c[1]|!c[0])
		&(!c[3]|!c[2]|c[1]|c[0])
		&(!c[3]|!c[2]|c[1]|!c[0])
		&(!c[3]|!c[2]|!c[1]|c[0])
		&(!c[3]|!c[2]|!c[1]|!c[0]));
	assign display[6] = 
		!((c[3]|c[2]|c[1]|c[0])
		&(c[3]|c[2]|c[1]|!c[0])
		&(c[3]|!c[2]|!c[1]|!c[0])

		&(!c[3]|c[2]|!c[1]|c[0])
		&(!c[3]|c[2]|!c[1]|!c[0])
		&(!c[3]|!c[2]|c[1]|c[0])
		&(!c[3]|!c[2]|c[1]|!c[0])
		&(!c[3]|!c[2]|!c[1]|c[0])
		&(!c[3]|!c[2]|!c[1]|!c[0]));
	
endmodule
