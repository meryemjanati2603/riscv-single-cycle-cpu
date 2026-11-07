module add4(
	 input [31:0] pc_current,
	 output [31:0] PCPlus4
	 );
	 
	assign PCPlus4=pc_current + 4;
	
endmodule