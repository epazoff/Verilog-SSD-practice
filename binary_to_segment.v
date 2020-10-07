`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    
// Design Name: 
// Module Name:    binary_to_segment 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module binary_to_segment(
    input [4:0] binary_in,
    output reg [6:0] seven_out
    );
	 
//1 is off, 0 is on
always @(binary_in) 
begin
    case(binary_in)
		  //==========NUMBERS========================
			5'd0: seven_out =7'b0000001;            	//0 and O and D       
			5'd1: seven_out =7'b1001111;            	//1 and l
			5'd2: seven_out =7'b0010010;            	//2
			5'd3: seven_out =7'b0000110;            	//3
			5'd4: seven_out =7'b1001100;            	//4
			5'd5: seven_out =7'b0100100;            	//5 and S
			5'd6: seven_out =7'b0100000;            	//6
			5'd7: seven_out =7'b0001111;            	//7
			5'd8: seven_out =7'b0000000;            	//8 and B
			5'd9: seven_out =7'b0001100;            		//9
			5'd10: seven_out =7'b0001000;           	//A
			5'd11: seven_out =7'b0000000;            	//B
			5'd12: seven_out =7'b0110001;  		   	//C
			5'd13: seven_out =7'b0000001;            	//D       
			5'd14: seven_out =7'b0110000;           	//E
			5'd15: seven_out =7'b0111000; 		      	//F
		  //=========== LETTERS========================
			5'd16: seven_out= 7'b1110001;           	//L   
			5'd17: seven_out= 7'b1000010;           	//d	
			5'd18: seven_out= 7'b0011000;           	//P	
			5'd19: seven_out= 7'b1111110;           	//-	
			5'd20: seven_out= 7'b1101010;           	//n
			5'd21: seven_out= 7'b1111010;           	//r
			5'd22: seven_out= 7'b1100011;           	//u 
			5'd23: seven_out= 7'b1110010;           	//c
			5'd24: seven_out= 7'b1110000;           	//t
			5'd25: seven_out= 7'b1000100;           	//y
			5'd26: seven_out= 7'b0100100;          	//S
			5'd27: seven_out= 7'b1111111;           	//BLANK   
			default: seven_out = 7'b1111111;
    endcase
end



endmodule