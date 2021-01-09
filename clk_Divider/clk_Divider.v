module clk_Divider(
							iclk		,
							reset_n	,	
							oclk
							);
parameter clkFreq = 50_000_000;
parameter hz = 1;
parameter cntCycle = ((clkFreq / (hz * 2)) - 1);
input 		iclk;
input 		reset_n;
output reg 	oclk;
reg [31:0]	cnt;
always@(posedge iclk or negedge reset_n)begin
	if(!reset_n)begin
		cnt	<=	0;
		oclk	<= 0;
	end else begin
		if(cnt >= (cntCycle))begin
			oclk	<=	~oclk;
			cnt	<=	0;
		end else begin
			oclk	<=	oclk;
			cnt	<=	cnt + 1;
		end
	end
end
endmodule 
/*
clk_Divider #(.hz()) Div1(
								.iclk		(CLOCK_50),
								.reset_n	(BUTTON[0]),
								.oclk		()
							);
*/