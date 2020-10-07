`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:21:03 12/09/2017 
// Design Name: 
// Module Name:    ssdModule 
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
module ssdModule(
    input [19:0] ssdIn,
	 input clk,
	 output reg [3:0] AN,
    output [6:0] ssdOut
    );
	 
	reg [4:0] seven_in;
	reg [2:0] count;

	binary_to_segment disp1(seven_in,ssdOut); 

	always @(posedge clk) begin
		
		case (count)
			0: begin
				count<=count+1'b1;
				AN <= 4'b0111;
				seven_in <= ssdIn[19:15];
			end
			1: begin
				count<=count+1'b1;
				AN <= 4'b1011;
				seven_in <= ssdIn[14:10];
			end
			2: begin
				count<=count+1'b1;
				AN <= 4'b1101;
				seven_in <=ssdIn[9:5]; 
			end
			3: begin
				count<=count+1'b1;
				AN <= 4'b1110;
				seven_in <=ssdIn[4:0]; 
			end
			default count<= 0;
		endcase
	end
	 
endmodule
