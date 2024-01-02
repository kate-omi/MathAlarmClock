/*****************************************************************************
 *                                                                           *
 * Module:       Altera_UP_Avalon_Audio                                      *
 * Description:                                                              *
 *      This module reads and writes data to the Audio chip on Altera's DE2  *
 *   Development and Education Board. The audio chip must be in master mode  *
 *   and the digital format must be left justified.                          *
 *                                                                           *
 *****************************************************************************/

module Audio_Controller(
	// Inputs
	CLOCK_50,
	reset,

	clear_audio_out_memory,
	left_channel_audio_out,
	right_channel_audio_out,
	write_audio_out,

	// Bidirectionals
	AUD_BCLK,
	AUD_DACLRCK,

	// Outputs
	audio_out_allowed,

	AUD_XCK,
	AUD_DACDAT
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/

localparam AUDIO_DATA_WIDTH	= 32;
localparam BIT_COUNTER_INIT	= 5'd31;

/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
// Inputs
input				CLOCK_50;
input				reset;

input				clear_audio_out_memory;
input		[AUDIO_DATA_WIDTH:1]	left_channel_audio_out;
input		[AUDIO_DATA_WIDTH:1]	right_channel_audio_out;
input				write_audio_out;

// Bidirectionals
inout				AUD_BCLK;
inout				AUD_DACLRCK;

// Outputs

output	reg			audio_out_allowed;

output				AUD_XCK;
output				AUD_DACDAT;

/*****************************************************************************
 *                 Internal wires and registers Declarations                 *
 *****************************************************************************/

// Internal Wires
wire				bclk_rising_edge;
wire				bclk_falling_edge;

wire				dac_lrclk_rising_edge;
wire				dac_lrclk_falling_edge;

wire		[7:0]	left_channel_write_space;
wire		[7:0]	right_channel_write_space;

// Internal Registers
reg				done_dac_channel_sync;

// State Machine Registers


/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/


/*****************************************************************************
 *                             Sequential logic                              *
 *****************************************************************************/

// Output Registers

always @ (posedge CLOCK_50)
begin
	if (reset == 1'b1)
		audio_out_allowed <= 1'b0;
	else if ((left_channel_write_space[7] | left_channel_write_space[6])
			& (right_channel_write_space[7] | right_channel_write_space[6]))
		audio_out_allowed <= 1'b1;
	else
		audio_out_allowed <= 1'b0;
end

// Internal Registers

always @ (posedge CLOCK_50)
begin
	if (reset == 1'b1)
		done_dac_channel_sync <= 1'b0;
	else if (dac_lrclk_falling_edge == 1'b1)
		done_dac_channel_sync <= 1'b1;
end

/*****************************************************************************
 *                            Combinational logic                            *
 *****************************************************************************/

assign AUD_BCLK		= 1'bZ;
assign AUD_DACLRCK	= 1'bZ;


/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/

Altera_UP_Clock_Edge Bit_Clock_Edges (
	// Inputs
	.clk			(CLOCK_50),
	.reset			(reset),
	
	.test_clk		(AUD_BCLK),
	
	// Bidirectionals

	// Outputs
	.rising_edge	(bclk_rising_edge),
	.falling_edge	(bclk_falling_edge)
);

Altera_UP_Clock_Edge DAC_Left_Right_Clock_Edges (
	// Inputs
	.clk			(CLOCK_50),
	.reset			(reset),
	
	.test_clk		(AUD_DACLRCK),
	
	// Bidirectionals

	// Outputs
	.rising_edge	(dac_lrclk_rising_edge),
	.falling_edge	(dac_lrclk_falling_edge)
);

Altera_UP_Audio_Out_Serializer Audio_Out_Serializer (
	// Inputs
	.clk							(CLOCK_50),
	.reset							(reset | clear_audio_out_memory),
	
	.bit_clk_rising_edge			(bclk_rising_edge),
	.bit_clk_falling_edge			(bclk_falling_edge),
	.left_right_clk_rising_edge		(done_dac_channel_sync & dac_lrclk_rising_edge),
	.left_right_clk_falling_edge	(done_dac_channel_sync & dac_lrclk_falling_edge),
	
	.left_channel_data				(left_channel_audio_out),
	.left_channel_data_en			(write_audio_out & audio_out_allowed),

	.right_channel_data				(right_channel_audio_out),
	.right_channel_data_en			(write_audio_out & audio_out_allowed),
	
	// Bidirectionals

	// Outputs
	.left_channel_fifo_write_space	(left_channel_write_space),
	.right_channel_fifo_write_space	(right_channel_write_space),

	.serial_audio_out_data			(AUD_DACDAT)
);
defparam
	Audio_Out_Serializer.AUDIO_DATA_WIDTH = AUDIO_DATA_WIDTH;

Audio_Clock Audio_Clock (
	// Inputs
	.inclk0			(CLOCK_50),
	.areset			(),

	// Outputs
	.c0				(AUD_XCK),
	.locked			()
);

endmodule

