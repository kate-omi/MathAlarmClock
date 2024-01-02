// Part 2 skeleton

module vga(
	CLOCK_50,						//	On Board 50 MHz
	KEY,							// On Board Keys, reset
		
	alarm_on,						// Signals new vga screen (switches between on screen and off screen)
		
	// The ports below are for the VGA output.
	VGA_CLK,   						//	VGA Clock
	VGA_HS,							//	VGA H_SYNC
	VGA_VS,							//	VGA V_SYNC
	VGA_BLANK_N,					//	VGA BLANK
	VGA_SYNC_N,						//	VGA SYNC
	VGA_R,   						//	VGA Red[9:0]
	VGA_G,	 						//	VGA Green[9:0]
	VGA_B   						//	VGA Blue[9:0]
);

	input			CLOCK_50;				// 50 MHz
	input	[3:0]	KEY;					// maps to reset
	input 			alarm_on;				// changes current screen

	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;			//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[7:0]	VGA_R;   				//	VGA Red[7:0] Changed from 10 to 8-bit DAC
	output	[7:0]	VGA_G;	 				//	VGA Green[7:0]
	output	[7:0]	VGA_B;   				//	VGA Blue[7:0]
	
	//connects reset button
	wire resetn;
	assign resetn = KEY[0];
	
	//connects vga information
	wire [2:0] colour;
	wire [8:0] x;
	wire [7:0] y;
	wire writeEn;

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
		defparam 
				VGA.RESOLUTION = "320x240",
				VGA.MONOCHROME = "FALSE",
				VGA.BITS_PER_COLOUR_CHANNEL = 1,
				VGA.BACKGROUND_IMAGE = "black.mif";
	 
	vga_rom rom (
	.clock(CLOCK_50),
	.reset(!resetn),
	.alarm_on(alarm_on),
	.x(x),
	.y(y),
	.colour(colour),
	.plot(writeEn),
	);
endmodule