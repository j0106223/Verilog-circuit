module clkdiv1s(iClk50M,command,oClk1s);
parameter CntValue = 50000000;
input         iClk50M;
input [31:0]command;
output reg oClk1s;
reg [31:0] cnt;
always@(posedge iClk50M)begin
    if( cnt >= ((CntValue/(command*2))-1) )begin//very stable hz
        oClk1s <= ~ oClk1s;
              cnt <= 0;
    end
    else begin
        oClk1s <= oClk1s;  
              cnt <= cnt +1;
    end
end
endmodule


/*
clkdiv1s test(.iClk50M(CLOCK_50),
              .command(),
              .oClk1s());
*/