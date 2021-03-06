module MPU9250(
					CLOCK_50,
					reset_n,
					I2C_SDA,
					I2C_SCL,
					ACCEL_XOUT,
					ACCEL_YOUT,
					ACCEL_ZOUT,
					GYRO_XOUT,
					GYRO_YOUT,
					GYRO_ZOUT,
					);
`include "mpu9250.h"
input 	CLOCK_50;
input 	reset_n;
inout 	I2C_SDA;
output 	I2C_SCL;

//output reg [7:0] 	WHO_AM_I;
output [15:0] ACCEL_XOUT;
output [15:0] ACCEL_YOUT;
output [15:0] ACCEL_ZOUT;
output [15:0] GYRO_XOUT;
output [15:0] GYRO_YOUT;
output [15:0] GYRO_ZOUT;
assign ACCEL_XOUT = { AX_H, AX_L };
assign ACCEL_YOUT = { AY_H, AY_L };
assign ACCEL_ZOUT = { AZ_H, AZ_L };
assign GYRO_XOUT = { GX_H, GX_L };
assign GYRO_YOUT = { GY_H, GY_L };
assign GYRO_ZOUT = { GZ_H, GZ_L };
reg [7:0]	AX_H; 
reg [7:0]	AX_L; 
reg [7:0]	AY_H;
reg [7:0]	AY_L;
reg [7:0]	AZ_H;
reg [7:0]	AZ_L;
reg [7:0]	GX_H;
reg [7:0]	GX_L;
reg [7:0]	GY_H;
reg [7:0]	GY_L;
reg [7:0]	GZ_H;
reg [7:0]	GZ_L;
//reg [7:0]	HXH;
//reg [7:0]	HXL;
//reg [7:0]	HYH;
//reg [7:0]	HYL;
//reg [7:0]	HZH;
//reg [7:0]	HZL;



reg [6:0]	DEVICE_ID;
reg [7:0]	REG_ADDRESS;

reg [7:0]	state;
reg [7:0]	counter;
reg [31:0]	delay;

//parameter clkValue = 50_000_000;
//parameter usValue  = 1000;
//parameter powerOn  = 100;//100ms
always@(posedge clk_scl or negedge reset_n)begin
	if(!reset_n)begin
		state			<= 0;
		counter		<= 0;
		delay			<= 0;
		DEVICE_ID	<= 0;
		REG_ADDRESS	<= 0;
		W_GO			<= 0;
		R_GO			<= 0;
		W_DATA		<= 0;
		AX_H			<=	0;
		AX_L			<=	0;
	end else begin
		state			<= state;
		counter		<= counter;
		delay			<= delay;
		DEVICE_ID	<= DEVICE_ID;
		REG_ADDRESS	<= REG_ADDRESS;
		W_GO			<= W_GO;
		R_GO			<= R_GO;
		W_DATA		<= W_DATA;
		case(state)
			0:begin//power on delay
					if(delay >= 12000)begin
						delay	<= 0;
						state	<= state + 1;
					end else begin
						delay	<= delay + 1;
						state	<= state;
					end
			  end
			
			1:begin//write config
					W_GO		<= 1;
					R_GO		<= 0;
					case(counter)
						0:{ DEVICE_ID, REG_ADDRESS, W_DATA } <= { MPU9250_ID, PWR_MGMT_1, 	8'h02};
						1:{ DEVICE_ID, REG_ADDRESS, W_DATA } <= { MPU9250_ID, PWR_MGMT_2, 	8'h00};
						2:{ DEVICE_ID, REG_ADDRESS, W_DATA } <= { MPU9250_ID, CONFIG, 			8'h00};
						3:{ DEVICE_ID, REG_ADDRESS, W_DATA } <= { MPU9250_ID, GYRO_CONFIG, 	8'h18};
						4:{ DEVICE_ID, REG_ADDRESS, W_DATA } <= { MPU9250_ID, ACCEL_CONFIG, 	8'h00};
						5:{ DEVICE_ID, REG_ADDRESS, W_DATA } <= { MPU9250_ID, ACCEL_CONFIG_2,8'h09};
						6:{ DEVICE_ID, REG_ADDRESS, W_DATA } <= { MPU9250_ID, USER_CTRL,		8'h00};
						7:{ DEVICE_ID, REG_ADDRESS, W_DATA } <= { MPU9250_ID, INT_PIN_CFG,	8'h02};
						default:;
					endcase	
					counter	<= counter + 1;
					state		<= state + 1;		
			  end
			2:begin//get W_OK and go back
					if(W_OK)begin
						if(counter >= 7)begin
							counter	<= 0;
							state		<= state + 1;	
						end else begin
							state		<= state - 1;//Back to write config
						end
					end else begin
						state	<= state;
					end
			  end
			3:begin//Read data
					R_GO		<= 1;
					W_GO		<= 0;
					case(counter)
						0:{  DEVICE_ID, REG_ADDRESS } <= { MPU9250_ID, ACCEL_XOUT_H };
						1:{  DEVICE_ID, REG_ADDRESS } <= { MPU9250_ID, ACCEL_XOUT_L };
						2:{  DEVICE_ID, REG_ADDRESS } <= { MPU9250_ID, ACCEL_YOUT_H };
						3:{  DEVICE_ID, REG_ADDRESS } <= { MPU9250_ID, ACCEL_YOUT_L };
						4:{  DEVICE_ID, REG_ADDRESS } <= { MPU9250_ID, ACCEL_ZOUT_H };
						5:{  DEVICE_ID, REG_ADDRESS } <= { MPU9250_ID, ACCEL_ZOUT_L };
						6:{  DEVICE_ID, REG_ADDRESS } <= { MPU9250_ID, GYRO_XOUT_H };
						7:{  DEVICE_ID, REG_ADDRESS } <= { MPU9250_ID, GYRO_XOUT_L };
						8:{  DEVICE_ID, REG_ADDRESS } <= { MPU9250_ID, GYRO_YOUT_H };
						9:{  DEVICE_ID, REG_ADDRESS } <= { MPU9250_ID, GYRO_YOUT_L };
						10:{ DEVICE_ID, REG_ADDRESS } <= { MPU9250_ID, GYRO_ZOUT_H };
						11:{ DEVICE_ID, REG_ADDRESS } <= { MPU9250_ID, GYRO_ZOUT_L };
						default:;
					endcase
					state	<=	state+1;
			  end//read register data
			4:if(R_OK)begin//get R_OK and repeat
					case(counter)
						0:AX_H 	<= R_DATA;
						1:AX_L 	<= R_DATA;
						2:AY_H 	<= R_DATA;
						3:AY_L 	<= R_DATA;
						4:AZ_H 	<= R_DATA;
						5:AZ_L 	<= R_DATA;
						6:GX_H 	<= R_DATA;
						7:GX_L 	<= R_DATA;
						8:GY_H 	<= R_DATA;
						9:GY_L 	<= R_DATA;
						10:GZ_H	<= R_DATA;
						11:GZ_L	<= R_DATA;
						default:;
					endcase
					
					if(counter >= 11)begin
						counter	<= 0;	
					end else begin
						counter	<= counter + 1;
					end
					state	<= state - 1;
			  end else begin
					state	<= state;
			  end 
			default:state	<= 0;
		endcase
	end
end


assign I2C_SDA = 	(W_GO & W_SDA_DIR) ? W_oSDA :
						(R_GO & R_SDA_DIR) ? R_oSDA : 1'bz;
assign I2C_SCL = 	(W_GO) ? W_oSCL :
						(R_GO) ? R_oSCL : 1'b1 ;

reg 			R_GO;						
wire 			R_OK;
wire [7:0]	R_DATA;
wire 			R_BUSY;
wire 			R_SDA_DIR;
wire 			R_ACK_err;
wire 			R_oSDA;
wire 			R_oSCL;

wire[7:0]	status;
assign status[0] 	= R_GO;
assign status[1] 	= W_GO;
assign status[2] 	= R_BUSY | W_BUSY;
assign status[3] 	= R_ACK_err | W_ACK_err;
assign status[7:4]= 0;//reserve
I2C_READ Read_module(
						.reset_n			(reset_n			),
						.GO				(R_GO				),
						.ADDR				(DEVICE_ID		),
						.REG_ADDR		(REG_ADDRESS	),
						.SDA_CLK			(clk_sda			),
						.SCL_CLK			(clk_scl			),
						.iSDA				(I2C_SDA			),
						.oSDA				(R_oSDA			),
						.oSCL				(R_oSCL			),
						.SDA_DIR			(R_SDA_DIR		),
						.BUSY				(R_BUSY			),
						.ACK_err			(R_ACK_err		),
						.READ_DATA		(R_DATA			),
						.OK				(R_OK				)
						);
reg			W_GO;
wire 			W_OK;
reg [7:0]	W_DATA;
wire 			W_BUSY;
wire 			W_SDA_DIR;
wire 			W_ACK_err;
wire 			W_oSDA;
wire 			W_oSCL; 						
I2C_WRITE Write_module(
						.reset_n			(reset_n			),
						.GO				(W_GO				),
						.ADDR				(DEVICE_ID		),
						.REG_ADDR		(REG_ADDRESS	),
						.SDA_CLK			(clk_sda			),
						.SCL_CLK			(clk_scl			),
						.iSDA				(I2C_SDA			),
						.oSDA				(W_oSDA			),
						.oSCL				(W_oSCL			),
						.SDA_DIR			(W_SDA_DIR		),
						.BUSY				(W_BUSY			),
						.ACK_err			(W_ACK_err		),
						.WRITE_DATA		(W_DATA			),
						.OK				(W_OK				)
					);
wire clk_sda;
wire clk_scl;
I2C_CLOCK_Generator CLOCK_Generator(
						.iclk50			(CLOCK_50),
						.CLK_SDA			(clk_sda	),
						.CLK_SCL			(clk_scl	)
						);

endmodule 