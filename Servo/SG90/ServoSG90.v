module ServoSG90(
						iclk		,
						reset_n	,
						Angel		,
						Control
					);//Verification OK!
input			iclk;
input 		reset_n;
input [7:0]	Angel;
output 		Control;

parameter miniPluse 	= 500;			//500us 	0.5ms
parameter maxPluse 	= 2400;			//2400us	2.4ms 
parameter cycle		= 20000;       //20000us 20ms
parameter clkValue 	= 100_000_000;	//100MHZ would choose Avalon salve interfac's system clk
parameter usValue    = 1_000_000;
parameter cycleCnt			= clkValue / usValue * cycle; 		//200w 	clk
parameter miniPluseCnt 		= clkValue / usValue * miniPluse;	//5w	   clk
parameter angelPluseUnit 	= clkValue / usValue * (maxPluse - miniPluse) / 180;// 1055 clk
reg 	[7:0]	angel;
reg 	[31:0]cnt;
always@(posedge iclk or negedge reset_n)begin
	if(!reset_n)begin
		angel	<=	0;
		cnt	<=	0;	
	end else begin
		if(cnt >= cycleCnt - 1)begin//20000us 20ms
			cnt	<=	0;
			angel	<=	Angel;
			if((Angel > 180))begin
				angel	<=	180;
			end else begin
				angel	<=	Angel;
			end
		end else begin
			cnt	<=	cnt + 1;
			angel	<=	angel;
		end
	end
end

assign Control = (cnt >= (miniPluseCnt + angel * angelPluseUnit - 1)) ? 0 : 1;
endmodule 





