module I2C_WRITE(
						reset_n,
						GO,
						ADDR,
						REG_ADDR,
						SDA_CLK,
						SCL_CLK,
						iSDA,
						oSDA,
						oSCL,
						SDA_DIR,
						BUSY,
						ACK_err,
						WRITE_DATA,
						OK
					);//Verification OK!
input 		reset_n;
input 		GO;
input [6:0]	ADDR;
input [7:0]	REG_ADDR;
input [7:0]	WRITE_DATA;
input 		SDA_CLK;
input 		SCL_CLK;
input 		iSDA;
output 		oSDA;
output		oSCL;
output		SDA_DIR;
output		BUSY;
output 		ACK_err;
output 		OK;


reg 		SDA;
reg		SDA_EN;
reg		SCL_EN;
reg [7:0]state;
reg [6:0]addr;
reg [7:0]reg_addr;
reg 		ack;
reg      ack_err;
reg [7:0]data;
reg      ok;
reg 		busy;

assign oSDA 		= SDA;
assign oSCL 		= ( SCL_EN ) ? SCL_CLK : 1;
assign SDA_DIR 	= SDA_EN;
assign BUSY 		= busy;		//only not busy at state = IDLE
assign ACK_err 	= ack_err;
assign OK			= ok;
always@(posedge SDA_CLK or negedge reset_n)begin
	if(!reset_n)begin
		addr		<= 0;
		reg_addr	<= 0;
		data		<= 0;
		SDA		<= 1;	//make SDA stay High
		SDA_EN	<= 1;	//make SDA stay High
		state		<= 0;
		busy		<= 0;
		ack_err	<= 0;
		ok			<= 0;
	end else begin
		addr		<= addr;
		reg_addr	<= reg_addr;
		data		<= data;
		SDA		<= SDA;
		SDA_EN	<= 1;
		state		<= state;
		busy		<= 1;
		ack_err	<= ack_err;
		ok			<= 0;
		case(state)
			0:begin
					if(GO)begin
						addr		<= ADDR;
						reg_addr	<= REG_ADDR;
						data		<= WRITE_DATA;
						state		<= state + 1;
					end else begin
						busy		<= 0;
						state		<= state;
					end
			  end
			1:begin
					SDA	<= 0;//Drop to start
					state	<= state + 1;
			  end
			2:begin//begin transmit addr
					SDA	<= addr[6];
					state	<= state + 1;
			  end
			3:begin
					SDA	<= addr[5];
					state	<= state + 1;
			  end
			4:begin
					SDA	<= addr[4];
					state <= state + 1;
			  end
			5:begin
					SDA	<= addr[3];
					state <= state + 1;
			  end
			6:begin
					SDA	<= addr[2];
					state <= state + 1;
			  end
			7:begin
					SDA	<= addr[1];
					state <= state + 1;
			  end
			8:begin
					SDA	<= addr[0];
					state <= state + 1;
			  end
			9:begin								//Write bit (0)
					SDA	<= 0;
					state	<= state + 1;
			  end
			10:begin								//ACK Release SDA control
					SDA_EN<= 0;
					state	<= state + 1;
				end
			11:begin
					if(ack == 0)begin			//ack successful, begin register address transmition
						SDA	<= reg_addr[7];
						state	<= state + 1;
					end else begin				
						state	<= 29;			//go to wait to stop the communication 
					end
				end
			12:begin
					SDA	<= reg_addr[6];
					state	<= state + 1;
				end
			13:begin
					SDA	<= reg_addr[5];
					state	<= state + 1;
				end
			14:begin
					SDA	<= reg_addr[4];
					state	<= state + 1;
				end
			15:begin
					SDA	<= reg_addr[3];
					state	<= state + 1;
				end
			16:begin
					SDA	<= reg_addr[2];
					state	<= state + 1;
				end
			17:begin
					SDA	<= reg_addr[1];
					state	<= state + 1;
				end
			18:begin
					SDA	<= reg_addr[0];
					state	<= state + 1;
				end
			19:begin								//ACK Release SDA control,
					SDA_EN<= 0;
					state	<= state + 1;
				end
			20:begin
					if(ack == 0)begin			//ack successful, begin data address transmit
						SDA	<= data[7];
						state	<= state + 1;
					end else begin
						state	<= 29;				//go to wait to stop the communication 
					end
					
				end
			21:begin
					SDA	<= data[6];
					state	<= state + 1;
				end
			22:begin
					SDA	<= data[5];
					state	<= state + 1;
				end
			23:begin
					SDA	<= data[4];
					state	<= state + 1;
				end
			24:begin
					SDA	<= data[3];
					state	<= state + 1;
				end
			25:begin
					SDA	<= data[2];
					state	<= state + 1;
				end
			26:begin
					SDA	<= data[1];
					state	<= state + 1;
				end
			27:begin
					SDA	<= data[0];
					state	<= state + 1;
				end
			28:begin								//ACK Release SDA control
					SDA_EN<= 0;
					state	<= state + 1;
				end
			29:begin
					SDA	<= 0;				//pull down wait to stop,always wait to stop communication so dont need to check ack
					state	<= state + 1;	//always wait to stop communication so no need to check ack
					ok		<= 1;
					if(ack == 0)begin
						ack_err	<= 0;
					end else begin
						ack_err	<= 1;
					end
				end
			30:begin							//completed stop communication
					SDA	<= 1;
					state	<= 0;
				end
			default:begin
							state	<= 0;
					  end
		endcase
	end
end

always@(posedge SCL_CLK or negedge reset_n)begin
	if(!reset_n)begin
		ack	<= 0;
		SCL_EN<=	0;
	end else begin
		ack	<= ack;
		SCL_EN<=	1;
		case(state)
			0:begin
					SCL_EN<=	0;
			  end
			1:begin
					SCL_EN<=	0;
			  end
			11:begin				//ACK1
					ack	<= iSDA;
				end
			20:begin				//ACK2
					ack	<= iSDA;
				end
			29:begin				//ACK3
					ack	<= iSDA;
				end
			30:begin
					SCL_EN<=	0;
				end
			default:ack	<= ack;
		endcase
	end
end




endmodule 