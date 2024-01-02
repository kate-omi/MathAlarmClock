
module audio (
	// Inputs
	CLOCK_50,
	KEY,
	alarm_on,

	// Bidirectionals
	AUD_BCLK,
	AUD_DACLRCK,

	FPGA_I2C_SDAT,

	// Outputs
	AUD_XCK,
	AUD_DACDAT,

	FPGA_I2C_SCLK,
);

// Inputs
input				CLOCK_50;
input		[3:0]	KEY;    //only use key 0 for reset
input				alarm_on;	//controls when audio is outputted (if alarm is on)

// Bidirectionals
inout				AUD_BCLK;
inout				AUD_DACLRCK;

inout				FPGA_I2C_SDAT;

// Outputs
output				AUD_XCK;
output				AUD_DACDAT;

output				FPGA_I2C_SCLK;

// Internal Wires

wire					audio_out_allowed;
wire					write_audio_out;
wire		[31:0]		audio_data;

// Internal Registers

reg 		[18:0] 	freq_cnt;
wire 		[18:0] 	freq_value;

reg			[22:0]	pulse_cnt;		//added a pulse counter which lasts for 5MHz or 1 second
wire		[22:0]	pulse_value;

reg freq;
reg pulse;

/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/

always @(posedge CLOCK_50)
	if(freq_cnt == freq_value) begin
		freq_cnt <= 0;
		freq <= !freq;
    end else freq_cnt <= freq_cnt + 1;
	
always @(posedge CLOCK_50)		//controls the pulse counter, when it reaches 1 second the audio switches between on/off
	if (pulse_cnt == pulse_value) begin
		pulse_cnt <= 0;
		pulse <= !pulse;
	end else pulse_cnt <= pulse_cnt + 1;

/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/

assign freq_value   = 32'd16;	//high pitch
assign pulse_value  = 23'd5000000;	//1 second pulse, creates beeping

wire [31:0] sound = 
	!alarm_on ? 0 :	//if alarm is off, no sound
	pulse ? 0: 		//if pulse is on, no sound (creates beeping)
	freq ? 32'd10000000 : -32'd10000000;

assign audio_data		            = sound;
assign write_audio_out				= audio_out_allowed;

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/

Audio_Controller Audio_Controller (
	// Inputs
	.CLOCK_50					(CLOCK_50),
	.reset						(~KEY[0]),
	
	.clear_audio_out_memory		(),
	.left_channel_audio_out		(audio_data),
	.right_channel_audio_out	(audio_data),
	.write_audio_out			(write_audio_out),

	// Bidirectionals
	.AUD_BCLK					(AUD_BCLK),
	.AUD_DACLRCK				(AUD_DACLRCK),


	// Outputs
	.audio_out_allowed			(audio_out_allowed),

	.AUD_XCK					(AUD_XCK),
	.AUD_DACDAT					(AUD_DACDAT)
);

avconf #(.USE_MIC_INPUT(1)) avc (
	.FPGA_I2C_SCLK				(FPGA_I2C_SCLK),
	.FPGA_I2C_SDAT				(FPGA_I2C_SDAT),
	.CLOCK_50					(CLOCK_50),
	.reset						(~KEY[0])
);

endmodule

