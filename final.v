module final (
	input CLOCK_50, 
	input [8:0] KEY, 
	input [3:0] SW,
	
	output [9:0] LEDR,

	/********HEX VARIABLES*********/
	output [6:0] HEX5,
	output [6:0] HEX4,
	output [6:0] HEX3,
	output [6:0] HEX2,
	output [6:0] HEX1,
	output [6:0] HEX0,
	
	/********AUDIO VARIABLES*********/
	//Bidirectionals
	inout				AUD_BCLK,
	inout				AUD_DACLRCK,

	inout				FPGA_I2C_SDAT,

	// Audio Outputs
	output				AUD_XCK,
	output				AUD_DACDAT,

	output				FPGA_I2C_SCLK,
	
	
	/********VGA VARIABLES*********/
	output			VGA_CLK,   				//	VGA Clock
	output			VGA_HS,					//	VGA H_SYNC
	output			VGA_VS,					//	VGA V_SYNC
	output			VGA_BLANK_N,				//	VGA BLANK
	output			VGA_SYNC_N,				//	VGA SYNC
	output	[7:0]	VGA_R,   				//	VGA Red[7:0] Changed from 10 to 8-bit DAC
	output	[7:0]	VGA_G,	 				//	VGA Green[7:0]
	output	[7:0]	VGA_B   				//	VGA Blue[7:0]
	
	);

	//alarm on/off state shared between alarm, alarm off, vga, audio, and hex display
	wire alarm_on;

	wire reset;

	//alarm data shared between hex display, alarm, and alarm off modules
	wire [3:0] alarm_hr;
	wire [5:0] alarm_min;
	
	//clock data shared between hex display, alarm, and clock modules
	wire [3:0] clock_hr;
	wire [5:0] clock_min;
	
	//temperary values to demostrate integration
	assign clock_hr = 4'd2;
	assign clock_min = 6'd1;
	
	//question vlues shared between hex display, alarm off, and keyboard modules
	wire [6:0] question_a;
	wire [6:0] question_b;
	wire [6:0] question_c;

	assign LEDR[0] = alarm_on;	//visual confirmation (useful for debugging)
	assign reset = !KEY[0];		//reset button (inverse logic)
	assign hrkey = !KEY[3];		//hr key (inverse logic)
	assign minkey = !KEY[2];	//min key (inverse logic)
	
alarm alarm_state(
	.clock(CLOCK_50),
	.reset(reset),
	
	.alarm_set(SW[0]),
	.alarm_hrKEY(hrkey),
	.alarm_minKEY(minkey),
	
	.clock_hr(clock_hr),
	.clock_min(clock_min),
	
	.alarm_off(!KEY[1]),
	
	.alarm_hr(alarm_hr),
	.alarm_min(alarm_min),
	.alarm(alarm_on)
	);
	

hexdisplay hex_control(
	.clock(CLOCK_50),
	.reset(!KEY[0]),

	.alarm_on(alarm_on),
	.question(SW[1]),
	.alarm_set(SW[0]),
	.clock_set(!SW[0]),

	.clock_hr(clock_hr),
	.clock_min(clock_min),

	.alarm_hr(alarm_hr),
	.alarm_min(alarm_min),

	.question_a(question_a),
	.question_b(question_b),
	.question_c(question_c),

	.display0(HEX0),
	.display1(HEX1),
	.display2(HEX2),
	.display3(HEX3),
	.display4(HEX4),
	.display5(HEX5)
	);
	
audio alarm_audio_output (
		.CLOCK_50(CLOCK_50),
		.KEY(KEY),
		.alarm_on(alarm_on),
		
		.AUD_BCLK(AUD_BCLK),
		.AUD_DACLRCK(AUD_DACLRCK),
		
		.FPGA_I2C_SDAT(FPGA_I2C_SDAT),
		
		.AUD_XCK(AUD_XCK),
		.AUD_DACDAT(AUD_DACDAT),
		.FPGA_I2C_SCLK(FPGA_I2C_SCLK));
		
		
vga alarm_visual_output (
	.CLOCK_50(CLOCK_50),
	.KEY(KEY),
	.alarm_on(alarm_on),
	.VGA_CLK(VGA_CLK),
	.VGA_HS(VGA_HS),
	.VGA_VS(VGA_VS),
	.VGA_BLANK_N(VGA_BLANK_N),
	.VGA_SYNC_N(VGA_SYNC_N),
	.VGA_R(VGA_R),
	.VGA_G(VGA_G),
	.VGA_B(VGA_B)
	);

endmodule

