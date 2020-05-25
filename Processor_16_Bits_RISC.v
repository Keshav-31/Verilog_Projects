`timescale 1ns / 1ps

/* Written By: Keshav Gupta
	Date: 24 May 2020 */
	
module Processor_16_bit_RISC(clk1, clk2); 
	
	//Inputs and Outputs
	input clk1, clk2; //Two-Phase Clock
	
	
	//Register Bank and memory
	reg [15:0] regbank [127:0];
	reg [15:0] memory [1023:0];
	
	//Variables in Stage 1 to Stage 2
	reg [11:0] L12_IR;
	
	//Variables in Stage 2 to Stage 3
	reg [11:0] L23_IR;
	reg L23_Exe_type;
	
	//Variables in Stage 3 to Stage 4
	reg [15:0] L3_AC;
	reg L3_E;
	
	//Flag Variables
	reg HALTED;
	reg SKIPPED;
	
	//Internal Variables
	reg [9:0] PC;
	integer D; //To decode the opcode.
	reg [15:0] DR;
	reg [6:0] ADDR;
	reg [3:0] OPCODE;
	
	
	//Functions
	
	//Memory Reference
	parameter MR = 0;
	parameter AND=4'h0;
	parameter OR=4'h1;
	parameter XOR=4'h2;
	parameter ADD=4'h3;
	parameter SUB=4'h4;
	parameter LDA=4'h5;
	parameter STA=4'h6;
	parameter ISZ=4'h7;
	
	//Register Reference
	parameter RR = 1;
	parameter CLA = 7'b0000000;
	parameter CLE = 7'b0000001;
	parameter CMA = 7'b0000010;
	parameter CME = 7'b0000011;
	parameter CIR = 7'b0000100;
	parameter CIL = 7'b0000101;
	parameter INC = 7'b0000110;
	parameter SPA = 7'b0000111;
	parameter SNA = 7'b0001000;
	parameter SZA = 7'b0001001;
	parameter SZE = 7'b0001010;
	parameter HLT = 7'b0001011;
	

	//Stage-1
	always @ (posedge clk1)
	begin
	if(HALTED==0)
	begin
		L12_IR =  #1 memory[PC];
		PC =  #1 PC + 10'b0000000001;
	end
	end
	
	
	//Stage-2
	always @ (posedge clk2)
	if(HALTED==0)
    begin
        /*Decode*/
        /*Check the Opcode for Memory reference or Register Reference*/
		/*Send whether ALU_AC or AC_Mem*/
		D = L12_IR[10:7];
		if(D == 15)
			L23_Exe_type <= #2 RR;
		else
			L23_Exe_type <= #2 MR;
		L23_IR <= #2 L12_IR;
	end    
		
	
	
	//Stage-3
	always @ (posedge clk1)
	if(HALTED==0)
    begin
		/*Execute*/
		//Check if ALU_AC or ALU_Mem
		//Perfom the operation and put the result in L3_AC and L3_E
		//If skip or halt set the flag
		
		if(SKIPPED==0)
		begin
			case(L23_Exe_type)
				MR:	begin
							if(L23_IR[11] == 1)
								ADDR = #1 regbank[L23_IR[6:0]];
							else
								ADDR = #1 L23_IR[6:0];
							DR = #1 regbank[ADDR];
							case (L23_IR[10:7])
								ADD: {L3_E, L3_AC} <=  L3_AC + DR;
								SUB: {L3_E, L3_AC} <=  L3_AC - DR;
								AND: L3_AC <=  L3_AC & DR;
								OR: L3_AC <=  L3_AC | DR;
								XOR: L3_AC <=  L3_AC ^ DR;
                        LDA: L3_AC <=  DR;
                        STA: regbank[ADDR] <=  L3_AC;
                        ISZ: begin
                               DR <= #2 DR + 1;
                               regbank[ADDR] <=  DR;
                               if(DR==0)
                                   SKIPPED <=  1'b1;
                             end         
                        default: begin
												L3_E <= 1'bx;
												L3_AC <=  16'hxxxx;
											end
							endcase
						end
				
				RR:	begin
							case(L23_IR[6:0])
								CLA: L3_AC <= 16'b0;
								CLE: L3_E <=  0;
								CMA: L3_AC <=  ~L3_AC;
								CME: L3_E <=  ~L3_E;
								CIR: begin
											L3_AC <=  L3_AC >> 1;
											L3_AC[15] <= L3_E;
											L3_E <=  L3_AC[0];
									  end
								CIL: begin
											L3_AC <=  L3_AC << 1;
											L3_AC[0] <= L3_E;
											L3_E <=  L3_AC[15];
									  end
								INC: L3_AC <=  L3_AC + 1;
								SPA: if(L3_AC[15] == 0) 
                                 SKIPPED <= 1'b1;
                        SNA: if(L3_AC[15]==1)
											SKIPPED <= 1'b1;
                        SZA: if(L3_AC==0)
											SKIPPED <= 1'b1;
                        SZE: if(L3_E==0)
                                 SKIPPED <= 1'b1;
                        HLT: HALTED <= 1'b1;
                                
								default: begin
												L3_E <= 1'bx;
												L3_AC <= 16'hxxxx;
											end
							endcase
						end
				endcase
			
		end
        else
        begin
            SKIPPED <= 0;
            L3_AC <= L3_AC;
            L3_E <= L3_E;
        end
    end
	
endmodule
