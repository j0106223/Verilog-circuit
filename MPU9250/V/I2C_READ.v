module I2C_READ(
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
						READ_DATA,
						OK);//Verification OK!
input 		reset_n;
input 		GO;
input  [6:0]ADDR;
input  [7:0]REG_ADDR;
input 		SDA_CLK;
input 		SCL_CLK;
input 		iSDA;
output 		oSDA;
output 		oSCL;
output 		SDA_DIR;
output 		BUSY;//waitRequest
output 		ACK_err;
output [7:0]READ_DATA;
output		OK;

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
assign READ_DATA 	= data;
assign OK			= ok;
always@(posedge SDA_CLK or negedge reset_n)begin
	if(!reset_n)begin
		addr		<= 0;
		reg_addr	<= 0;
		SDA		<= 1;	//make SDA stay High
		SDA_EN	<= 1;	//make SDA stay High
		state		<= 0; 
		busy		<= 0;
		ack_err	<= 0;
		ok			<= 0;
	end else begin
		addr		<= addr;
		reg_addr	<= reg_addr;
		SDA		<= SDA;
		SDA_EN	<= 1;
		state		<= state;
		busy		<= 1;
		ack_err	<= ack_err;
		ok			<= 0;
		case(state)
			0:begin//IDLE
					if(GO)begin
						addr		<= ADDR;
						reg_addr	<= REG_ADDR;
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
					if(ack == 0)begin			//ack successful, begin register address transmit
						SDA	<= reg_addr[7];
						state	<= state + 1;
					end else begin				
						state	<= 40;			//go to wait to stop the communication 
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
			19:begin								//ACK Release SDA control
					SDA_EN<= 0;
					state	<= state + 1;
				end
			20:begin								//SDA PULL UP wait to restart
					if(ack == 0)begin			//ack successful
						SDA	<= 1;
						state	<= state + 1;
					end else begin
						state	<= 40;			//go to wait to stop communication
					end
				end
			21:begin								//Start again ,pull down SDA
					SDA	<= 0;
					state	<= state + 1;
				end
			22:begin								//begin transmit Device I2C address again
					SDA	<= addr[6];
					state	<= state + 1;
			   end
			23:begin
					SDA	<= addr[5];
					state	<= state + 1;
			   end
			24:begin
					SDA	<= addr[4];
					state	<= state + 1;
			   end
			25:begin
					SDA	<= addr[3];
					state	<= state + 1;
			   end
			26:begin
					SDA	<= addr[2];
					state	<= state + 1;
			   end
			27:begin
					SDA	<= addr[1];
					state	<= state + 1;
			   end
			28:begin
					SDA	<= addr[0];
					state	<= state + 1;
			   end
			29:begin							//read(1)
					SDA	<= 1;
					state	<= state + 1;
				end
			30:begin							//ACK Release SDA control
					SDA_EN<= 0;
					state	<= state + 1;
				end
			31:begin							//begin to receive [7:0]data, wati to receive data[7]
					if(ack == 0)begin		//ack successful,
						state	<= state+1;
					end else begin
						state	<= 40;		//go to wait to stop communication
					end
					SDA_EN <= 0;
				end
			32:begin							//wati to receive data[6]
					SDA_EN<= 0;
					state	<= state + 1;		
				end 
			33:begin							//wati to receive data[5]
					SDA_EN<= 0;
					state	<= state + 1;		
				end 
			34:begin							//wati to receive data[4]
					SDA_EN<= 0;
					state	<= state + 1;		
				end 
			35:begin							//wati to receive data[3]
					SDA_EN<= 0;
					state	<= state + 1;		
				end 
			36:begin							//wati to receive data[2]
					SDA_EN<= 0;
					state	<= state + 1;		
				end 
			37:begin							//wati to receive data[1]
					SDA_EN<= 0;
					state	<= state + 1;		
				end 
			38:begin							//wati to receive data[0]
					SDA_EN<= 0;
					state	<= state + 1;		
				end 
			39:begin							//NACK Pull high
					SDA	<= 1;
					state	<= state + 1;
				end
			40:begin
					SDA	<= 0;				//pull down wait to stop
					state	<= state + 1;
					ok		<= 1;
					if(ack == 0)begin
						ack_err	<= 0;
					end else begin
						ack_err	<= 1;
					end
				end
			41:begin							//completed stop communication
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
		ack 	<= 0;
		data	<= 0;
		SCL_EN<= 0;
	end else begin
		ack	<= ack;
		data	<= data;
		SCL_EN<=1;
		case(state)
			0:begin//IDLE disable SCL
					SCL_EN	<=	0;
			  end
			1:begin//IDLE disable SCL
					SCL_EN	<=	0;
			  end
			21:begin//
					SCL_EN	<=	0;
				end
			11:begin				//ACK1
					ack		<= iSDA;
				end
			20:begin				//ACK2
					ack		<= iSDA;
				end
			31:begin				//ACK3
					ack		<= iSDA;
				end
			32:begin				//begin receive [7:0]data
					data[7]	<= iSDA;
				end
			33:begin
					data[6]	<= iSDA;
				end
			34:begin
					data[5]	<= iSDA;
				end
			35:begin
					data[4]	<= iSDA;
				end
			36:begin
					data[3]	<= iSDA;
				end
			37:begin
					data[2]	<= iSDA;
				end
			38:begin
					data[1]	<= iSDA;
				end
			39:begin
					data[0]	<= iSDA;
				end
			41:begin
					SCL_EN	<=	0;
				end
			default:begin
							ack	<= ack;
							data	<= data;
					  end
		endcase
	end
end
endmodule 