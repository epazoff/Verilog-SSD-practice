`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:50:29 12/08/2017 
// Design Name: 
// Module Name:    FSM 
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
module FSM(
	input clk,
	input clr,
	input rst,
	input ent,
	input chg,
	input [3:0] sw,
	input [3:0] blsw,
	output [3:0] AN, 
	output [6:0] ssd,
	output reg [7:0]led
    );
	 
	 reg [15:0] password; //initialize to 0
	 reg [15:0] enteredPass0;
	 reg [15:0] enteredPass1;
	 reg [7:0] currState; //initialize to IDLE
	 reg [19:0] ssdIn;
	 reg [7:0] nextState;
	 reg [7:0] lastState;
	 reg [1:0] try;
	 reg [15:0] hold;
	 reg [15:0] hold1;
	 
	 
	 
	 //state booleans
	 reg locking;
	 reg unlocking;
	 reg old;
	 reg new0;
	 reg new1;
	 reg idle;
	 reg blocked;
	 
	 parameter IDLE = 8'b00000000, UNLOCKED = 8'b00000001, LOCKED = 8'b00000010, BLOCKED = 8'b00000100; //CHANGE= 8'b000001000;
	 parameter PASSENTRY0 = 8'b00001000, PASSENTRY1 = 8'b00010000, PASSENTRY2 = 8'b00100000, PASSENTRY3 = 8'b01000000;
	 parameter blank=5'b11011, dash=5'b10011, tryDisp = 15'b110001010111001;
	 parameter sec = 11'b10000000000;
	 
	 wire clkD;
	 clk_divider c0(clk, rst, clkD);
	 
	 wire entD;
	 debouncer d0(clkD, rst, ent, entD);
	 
	 wire chgD;
	 debouncer d1(clkD, rst, chg, chgD);
	 
	 wire clrD;
	 debouncer d2(clkD, rst, clr, clrD);
	 
	 
	 
	 ssdModule s1(ssdIn, clkD, AN, ssd); 

	function checkpass;
		input [15:0] pass;
		input [15:0]entered_chars;
		if (pass==entered_chars)begin
			checkpass=1;
		end
		else begin
			checkpass=0;
		end
	endfunction
	 
	//WORKS 
	 initial begin
		password = 0;
		enteredPass0=16'b1010101011010101;
		enteredPass1=16'b1010101000000101;
		currState = IDLE;
		lastState = IDLE;
		nextState = IDLE;
		unlocking = 0;
		locking = 0;
	   old = 0;
		new0 = 0;
		new1 = 0;
		idle = 1;
		blocked = 0;
		ssdIn = 0;
		hold=0;
		hold1=0;
		try = 0;
	 end
	 
	 
	 always@(*) begin //assigning next state stuff
		case(currState)
				IDLE: begin 
					if(entD == 1) nextState = LOCKED;
					else nextState = IDLE;
				end
				LOCKED: begin
					if(entD == 1) begin 
						nextState = PASSENTRY0;
						lastState = LOCKED;
					end
					else nextState = LOCKED;
				end
				UNLOCKED: begin
					if(entD == 1) begin
						nextState = PASSENTRY0;
						lastState = UNLOCKED;
					end
					else if(chgD == 1) begin
						lastState = UNLOCKED;
						nextState = PASSENTRY0;//make this into a combination block, the sequential block is to assign nextState, then we assign nextState to currentState 
					end
					else nextState = UNLOCKED;
				end
				//=========ANY PASSWORD ENTRY===============
				PASSENTRY0: begin
					if(entD == 1) nextState = PASSENTRY1; //DIGITS ARE SAVED IN NEXT ALWAYS BLOCK
					else if(clrD == 1) nextState = PASSENTRY0; //DIGITS ARE RESET IN NEXT ALWAYS BLOCK
					else nextState = PASSENTRY0;
				end
				PASSENTRY1: begin
					if(entD == 1) nextState = PASSENTRY2; 
					else if(clrD == 1) nextState = PASSENTRY0; 
					else nextState = PASSENTRY1;
				end
				PASSENTRY2: begin
					if(entD == 1) nextState = PASSENTRY3; 
					else if(clrD == 1) nextState = PASSENTRY0; 
					else nextState = PASSENTRY2;
				end
				PASSENTRY3: begin
					if(entD == 1 && unlocking && password == enteredPass0&&try<3) begin
						nextState = UNLOCKED;
					end
					else if(entD == 1 && unlocking && password !== enteredPass0&& try<3) begin
						nextState = PASSENTRY0;
					end
					else if(entD == 1 && locking && password == enteredPass0&& try<3) begin
						nextState = LOCKED;
					end
					else if(entD == 1 && locking && password !== enteredPass0&& try<3) begin
						nextState = PASSENTRY0;
					end
					else if(entD == 1 && old && password == enteredPass0&& try<3) begin //CHECK PASSOWRDS IN DIFFERNET BLOCK
						nextState = PASSENTRY0;
					end
					else if(entD == 1 && old && password !== enteredPass0&& try<3) begin //CHECK PASSOWRDS IN DIFFERNET BLOCK
						nextState = PASSENTRY0;
					end
					else if(entD == 1 && new0) begin
						nextState = PASSENTRY0;
					end
					else if(entD == 1 && new1) nextState = PASSENTRY0;
					else if(entD == 1 && locking && enteredPass0 == enteredPass1) nextState = UNLOCKED;
					else if(entD == 1&& (unlocking || locking /*|| old || new1*/) && try >= 3) nextState = BLOCKED;
					else if(clrD == 1) nextState = PASSENTRY0; 
					else nextState = PASSENTRY3;
				end					
				BLOCKED: begin
					if(entD == 1 && blsw == 4'b1010) nextState = LOCKED;
					else nextState = BLOCKED; // set blocked boolean
				end
				default: nextState = IDLE;
			endcase
	 end

	
	//REGISTER MANAGEMENT, BOOLEANS, PASSWORDS
	 always@(posedge clkD) begin////boolean assignments
	 //case statement based on nextState, reassign the booleans appropriately
	 //locking,unlocking,blocked, new0,new1,old,idle 
		case(nextState) 
		    IDLE: begin
					unlocking<=0;
					locking <=0;
					old <= 0;
					new0 <= 0;
					new1 <= 0;
					idle <= 1;
					blocked <= 0;
					try<=0;
					end
			 LOCKED: begin
					unlocking <= 1;
					locking <= 0;
					old <= 0;
					new0 <= 0;
					new1 <= 0;
					idle <= 0;
					blocked <= 0;
					try <= try;
					end
			 UNLOCKED: begin 
					unlocking <= 0;
					locking <= locking;
					old <= old;
					new0 <= new0;
					new1 <= new1;
					idle <= 0;
					blocked <= 0;
					try<=try;
				end
			 PASSENTRY0: begin
				case(lastState) //lastState
					LOCKED: begin
						unlocking <= 1;
						locking <= 0;
						old <= 0;
						new0 <= 0;
						new1 <= 0;
						idle <= 0;
						blocked <= 0;
						try <= try;
					end
					UNLOCKED: begin
						if(chgD == 1) begin
							unlocking <= 0;
							locking <= 0;
							old <= 1;
							new0 <= 0;
							new1 <= 0;
							idle <= 0;
							blocked <= 0;
							try <= try;
						end
						else begin
							unlocking <= 0;
							locking <= 1;
							old <= 0;
							new0 <= 0;
							new1 <= 0;
							idle <= 0;
							blocked <= 0;
							try <= try;
						end
					end
				endcase
			 end
			 PASSENTRY3: begin
				if (entD == 1) begin			 
					if((unlocking 	&& password !== enteredPass0) || (locking && password !== enteredPass0)) try <= try + 1'b1;
//					|| (old 			&& password !== enteredPass0)
//					|| (new1 		&& enteredPass0 !== enteredPass1)
					else try <= 0;
					if (old) begin
						old <= 0;
						new0 <= 1;
						new1 <= 0;
						locking<=0;
					end
					else if(new0) begin
						old <= 0;
						new0 <= 0;
						new1 <= 1;
						locking<=0;
					end
					else if (new1) begin
						old <= 0;
						new0 <= 0;
						new1 <= 0;
						locking<=1;
					end
					else begin
						old <= 0;
						new0 <= 0;
						new1 <= 0;
						locking<=1;
					end     
				end
			 end
			 BLOCKED: begin
				blocked <= 1;
				try <= 0;
			end
			 default: begin
				unlocking <= unlocking;
				old <= old;
				new0 <= new0;
				new1 <= new1;
				idle <= idle;
				blocked <= blocked;
				try <= try;
			 end
		endcase
	 end
	 
	 
	 always@(posedge clkD or posedge rst) begin
		if(rst==1) begin
			currState <= IDLE;
		end	
		else
		currState <= nextState;
	 end

	 
	 always@(posedge clkD) begin 
		case(currState) //HERE IS WHERE WE CONTROL WHAT WE WANT TO DISPLAY---Look at directions for display  
			IDLE:begin 
				ssdIn <= 		20'b00001100011000001110; //display IdLE
			   led   <=        8'b00000000;
				end
			UNLOCKED: begin
//				hold1 <= hold1 + 1'b1;
//				if(hold1 < sec ) begin
//					if(enteredPass0 == enteredPass1) ssdIn <= 20'b00101101101011110111; //Succ
//					else if(enteredPass0 !== enteredPass1) begin
//						ssdIn <= 20'b10110101000010110111; //unSu
//						enteredPass0 <=16'b1010101011010101;
//						enteredPass1 <=16'b1010101000000101;
//					end
//				end
					//else begin
					ssdIn <= 	20'b00000100100111010100; //display open
					led   <=        8'b11111110;
					//end
			end
			LOCKED: begin 
				ssdIn <= 		20'b01100100000010110001;  //display Clsd
				led   <=        8'b11111111;
				end
			BLOCKED:begin
				ssdIn <= 		20'b01000010000100001000; //display 8888
				led   <=        8'b10011010;
				end
			PASSENTRY0:	begin  //DISPLAY TRYS
				hold <= hold + 1'b1;
				if (hold<sec) begin
					if(old) begin
						ssdIn <= {blank,15'b000000000110001};//display old
					end
					else if(new0) begin
						ssdIn <= {blank,15'b101000111010110};// display nEu
					end
					else if(new1) begin
						ssdIn <= {20'b10101101000111010110}; //display rnEu
					end
					else if(locking) begin
						if (try == 0) begin
							ssdIn<= {tryDisp,5'b00011};
						end
						else if (try == 1) begin
							ssdIn<= {tryDisp,5'b00010};
						end
						else if (try == 2) begin
							ssdIn<= {tryDisp, 5'b00001};
						end
						else begin
							ssdIn <= {15'b011101010110101, blank};// display Err
						end
					end
					else if(unlocking) begin
						if (try == 0) begin
							ssdIn<= {tryDisp,5'b00011};
						end
						else if (try == 1) begin
							ssdIn<= {tryDisp,5'b00010};
						end
						else if (try == 2) begin
							ssdIn<= {tryDisp,5'b00001};
						end
						else begin
							ssdIn <= {15'b011101010110101, blank};// display Err
						end
					end
					else begin end
				end
				else if(unlocking) ssdIn <= {1'b0,sw,blank,blank,blank};
				else ssdIn <= {1'b0,sw,blank,blank,blank};
			end
			PASSENTRY1: begin
				if(unlocking) ssdIn <= {dash,1'b0, sw, blank, blank};
				else ssdIn <= {1'b0,enteredPass0[3:0],1'b0, sw, blank, blank};
				hold <= 0;
			end
			PASSENTRY2: begin
				if(unlocking) ssdIn <= {dash, dash, 1'b0, sw, blank};
				else ssdIn <= {1'b0,enteredPass0[3:0],1'b0, enteredPass0[7:4],1'b0, sw, blank};
			end
			PASSENTRY3: begin
				if(unlocking) ssdIn <= {dash, dash, dash, 1'b0, sw};
				else ssdIn <= {1'b0,enteredPass0[3:0],1'b0, enteredPass0[7:4],1'b0, enteredPass0[11:8],1'b0, sw};
			end
			default: begin ssdIn <= {blank, blank, blank, blank}; end
		
		endcase	

		case(currState)
			IDLE: begin
				password<=0;
				enteredPass0 <=16'b1010101011010101;
				enteredPass1 <=16'b1010101000000101;
			end		
			PASSENTRY0: begin //HERE WE CONTROL WHERE TO SAVE THE CURRENT PASSWORD BEING ENTERED 
				if(locking == 1 || unlocking == 1 || old == 1 || new0 == 1) enteredPass0[3:0] <= sw;
				else if(new1 == 1) enteredPass1[3:0] <= sw;
				else enteredPass0[3:0] <= sw;
			end
			PASSENTRY1: begin
				if(locking == 1 || unlocking == 1 || old == 1 || new0 == 1) enteredPass0[7:4] <= sw;
				else if(new1 == 1) enteredPass1[7:4] <= sw;
				else enteredPass0[7:4] <= sw;
			end
			PASSENTRY2: begin
				if(locking == 1 || unlocking == 1 || old == 1 || new0 == 1) enteredPass0[11:8] <= sw;
				else if(new1 == 1) enteredPass1[11:8] <= sw;
				else enteredPass0[11:8] <= sw;
			end
			PASSENTRY3: begin
				if(locking == 1 || unlocking == 1 || old == 1 || new0 == 1) enteredPass0[15:12] <= sw;
				else if(new1 == 1) enteredPass1[15:12] <= sw;
				else enteredPass0[15:12] <= sw;
			end
		endcase
		
		if(entD == 1 &&lastState==UNLOCKED && enteredPass0 == enteredPass1) begin
			password <= enteredPass0;
			ssdIn <= 20'b00101101101011110111;
		end
/***************************************************************************************************************************
THIS IS WHERE WE WERE TRYING TO IMPLEMENT THE DISPLAY TO SAY 'SUCC' AND 'UNSC' FOR CORRECT PASSWORD CHANGE.
/***************************************************************************************************************************	
	hold1 <= hold1 + 1'b1;
	if(hold1 < sec ) begin
		if(entD == 1 &&lastState==UNLOCKED && enteredPass0 == enteredPass1) begin
			password <= enteredPass0;
			ssdIn <= 20'b00101101101011110111;
		end
		else if(entD == 1 && lastState==UNLOCKED) ssdIn <= 20'b10110101000010110111;//Unsc
	end  
/***************************************************************************************************************************
/****************************************************************************************************************************/
end
endmodule
