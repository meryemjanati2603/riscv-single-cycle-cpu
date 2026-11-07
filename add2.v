module add2 (
   input [31:0] pc_current,
	input [ 31:0] ImmExt,
	output [31:0] PCTarget
	);
	
	assign PCTarget= pc_current + ImmExt;
	
endmodule