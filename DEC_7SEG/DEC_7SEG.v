module DEC_7SEG(Hex_digit, oHEX);
input [3:0] Hex_digit;
output [6:0] oHEX;
reg [6:0] segment_data;
always @(Hex_digit)
case (Hex_digit)
        4'b 0000: segment_data = 7'b 0111111;
        4'b 0001: segment_data = 7'b 0000110;
        4'b 0010: segment_data = 7'b 1011011;
        4'b 0011: segment_data = 7'b 1001111;
        4'b 0100: segment_data = 7'b 1100110;
        4'b 0101: segment_data = 7'b 1101101;
        4'b 0110: segment_data = 7'b 1111101;
        4'b 0111: segment_data = 7'b 0000111;
        4'b 1000: segment_data = 7'b 1111111;
        4'b 1001: segment_data = 7'b 1101111;
        4'b 1010: segment_data = 7'b 1110111;
        4'b 1011: segment_data = 7'b 1111100;
        4'b 1100: segment_data = 7'b 0111001;
        4'b 1101: segment_data = 7'b 1011110;
        4'b 1110: segment_data = 7'b 1111001;
        4'b 1111: segment_data = 7'b 1110001;
        default: segment_data = 7'b 0111110;
endcase
/* extract segment data bits and invert */
/* LED driver circuit is inverted */
assign oHEX  = ~segment_data;
endmodule



/*
wire SEG0,SEG1,SEG2,SEG3
DEC_7SEG hex0(
	         .Hex_digit(SEG0),
             .oHEX(HEX0_D)
	        );

DEC_7SEG hex1(
	         .Hex_digit(SEG1),
             .oHEX(HEX1_D)
	        );

DEC_7SEG hex2(
	         .Hex_digit(SEG2),
             .oHEX(HEX2_D)
	        );

DEC_7SEG hex3(
	         .Hex_digit(SEG3),
             .oHEX(HEX3_D)
	        );