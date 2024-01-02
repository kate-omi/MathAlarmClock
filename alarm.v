module alarm(
    input clock,
    input reset,

	 input alarm_set,
    input alarm_hrKEY,
    input alarm_minKEY,

    input [3:0] clock_hr,
    input [5:0] clock_min,

    input alarm_off,

    output reg [3:0] alarm_hr,
    output reg [5:0] alarm_min,
    output reg alarm
);


reg hrkeyHIGH;      //measures when key has been pressed vs held (ensures only one increment per press)
reg minkeyHIGH;     //measures when key has been pressed vs held (ensures only one increment per press)


always@(posedge clock) begin
	 if (alarm_hr == 0)
		alarm_hr <= 4'd12;

    if (reset) begin
        alarm_hr <= 4'd12;	//resets to 12:00
        alarm_min <= 6'b0;
        hrkeyHIGH <= 0;
        minkeyHIGH <= 0;
    end
    else if (alarm_set) begin
        if (alarm_hrKEY && !hrkeyHIGH)
            hrkeyHIGH <= 1;
        if (alarm_minKEY && !minkeyHIGH)
            minkeyHIGH <= 1;

        if (!alarm_hrKEY && hrkeyHIGH) begin
            if (alarm_hr != 4'd12)
                alarm_hr <= alarm_hr + 1;
            else 
                alarm_hr <= 4'b1;
            hrkeyHIGH <= 0;
        end

        if (!alarm_minKEY && minkeyHIGH) begin
            if (alarm_min != 6'd59)
                alarm_min <= alarm_min + 1;   
            else 
                alarm_min <= 6'b0;
            minkeyHIGH <= 0;
        end
    end
end

//alarm condition (Set reset block)
always@(posedge clock) begin
    if (reset || ( alarm_off && 
			((clock_hr != alarm_hr) || (clock_min != alarm_min))))
        alarm <= 1'b0;
    else if ((clock_hr == alarm_hr) && (clock_min == alarm_min))
        alarm <= 1'b1;
end

endmodule