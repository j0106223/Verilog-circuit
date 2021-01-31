module I2C_CLOCK_Generator(
						iclk50,
						CLK_SDA,
						CLK_SCL
						);
input iclk50;
output reg 	CLK_SDA;
output reg 	CLK_SCL;
parameter 	CntValue = 50000000;//50MEGA
parameter 	I2C400K  = 400000;	//400K
reg [31:0]	CntSDA;
reg [31:0]	CntSCL;
reg [31:0]	delay;
always@(posedge iclk50)begin
	if(delay >= (CntValue / (I2C400K * 4)))begin
		delay	<=	delay;
		if(CntSCL >= ((CntValue / (I2C400K * 2)) - 1))begin
			CLK_SCL	<=	~CLK_SCL;
			CntSCL	<=	0;
		end else begin
			CLK_SCL	<=	CLK_SCL;
			CntSCL	<=	CntSCL + 1;
		end
	end else begin
		delay		<=	delay + 1;
		CntSCL	<=	0;
	end
end

always@(posedge iclk50)begin
	if(CntSDA >= (((CntValue / (I2C400K * 2)) - 1)))begin
		CLK_SDA	<=	~CLK_SDA;
		CntSDA	<=	0;
	end else begin
		CLK_SDA	<=	CLK_SDA;
		CntSDA	<=	CntSDA + 1;
	end
end
endmodule 