`timescale 1ns / 1ps

/*Written By: KESHAV GUPTA
	Date: 25 May, 2020 */
	
module processortest;

	// Inputs
	reg clk1;
	reg clk2;

	
	integer i;
	// Instantiate the Unit Under Test (UUT)
	Processor_16_bit_RISC uut (
		.clk1(clk1), 
		.clk2(clk2));

	initial begin
		// Initialize Inputs
		clk1 = 0;
		clk2 = 0;
		repeat (20) // Generating two-phase clock
		begin
		
			#5 clk1 = 1; #5 clk1 = 0;
			
			#5 clk2 = 1; #5 clk2 = 0;
		end 
	end
	initial begin
		#8;
		repeat(6) begin
		$display("IR1 = %b and PC = %d", uut.L12_IR, uut.PC);
		#10;
		$display("IR2 = %b and EXE_TYPE= %b", uut.L23_IR, uut.L23_Exe_type);
		#10;
		$display("AC = %b E = %b and ADDR= %b DR = %b", uut.L3_AC, uut.L3_E, uut.ADDR, uut.DR);
		$display("__________________");
		end
	end
	initial begin
	
		for(i=0; i<128; i=i+1)
			uut.regbank[i] = i+1;
		uut.memory[0]=12'b001010000000;	
		uut.memory[1]=12'b000110000001;
		uut.memory[2]=12'b011110000010;
		uut.memory[3]=12'b011110001000;
		uut.memory[4]=12'b001010000011;
		uut.memory[5]=12'b001010000110;
		uut.SKIPPED = 0;
		uut.HALTED=0;
		uut.PC=10'b0000000000;
	end
	
	
endmodule

