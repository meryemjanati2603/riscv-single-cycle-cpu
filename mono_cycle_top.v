

module mono_cycle_top (
       input wire clk,
		 input wire reset,
		 output wire [31:0] Result,
		 output wire [31:0] pc,
		 output wire [31:0] instr,
		 output wire [31:0] resWB // registre contenant le resultat du Write Back
);
			
	 wire [31:0] pc_next;
    wire [31:0] pc_current;
    wire [31:0] instruction;
    wire [31:0] data_out;
	 wire RegWrite;
	 wire [31:0] rd1, rd2;
	 wire [31:0] resultat;
	 wire [31:0] Immed  ;
	 wire ALUSrc;
	 wire [31:0] SrcB;
	 wire [2:0] ALUControl;
	 wire [31:0] ALUResult;
	 wire zero, carry;
	 wire MemWrite;
	 wire [31:0] Readdata;
	 wire ResultSrc;
	 wire [1:0] aluop;
	 wire [31:0] reg13; 
	 wire [1:0] ImmSrc;
	 wire [31:0] PCPlus4;
	 wire [31:0] PCTarget;
	 wire enable,MemRead;
	 wire PCSrc;
	 // Program Counter
    program_counter PC (
        .clk(clk),
        .reset(reset),
        .pc_next(pc_next),
        .pc_current(pc_current)
);

    // Instruction Memory
    instruction_memory IM (
        .read_addr(pc_current),
        .instruction_out(instruction)
    );

	 
	 //register file
	  
     Reg_file RF (
	  .clk(clk),
	  .a1(instruction[19:15]),
	  .a2(instruction[24:20]),
	  .a3(instruction[11:7]),
	  .we3(RegWrite),
	  .enable(enable),
	  .wd3(resultat),
	  .rd1(rd1),
	  .rd2(rd2),
	  .register13(reg13)
	    );

	  //Extend Unit
	  Extended Extend (
	  .instr(instruction),
	  .ImmSrc(ImmSrc),
	  .ImmExt(Immed)
	  );
	  
	  //Multiplexeur pour choisir entre rd2 et ImmExt (instruction de type R-type ou d'autres)
	  Multiplexer MUX1 (
	  .A(rd2),
	  .B(Immed),
	  .sel(ALUSrc),
	  .out(SrcB)
);	  
	  
	   //ALU unit 
		alu ALU (
		.rdA(rd1),
		.rdB(SrcB),
		.ALUControl(ALUControl),
		.ALUresult(ALUResult),
		.Carry(carry),
		.zero(zero)
);
		//Additionneur pour incrementer le program counter
add4 AD (
	.pc_current(pc_current),
	.PCPlus4(PCPlus4)
);
     
	  
	//additionneur pour calculer le program counter apres l'instruction jump
add2 AD2 (
	.pc_current(pc_current),
	.ImmExt(Immed),
	.PCTarget(PCTarget)
);
	
	//Multiplexeur pour choisir entre PCPlus4 et PCTarget
Multiplexer MUX3 (
	   .A(PCPlus4),
		.B(PCTarget),
		.sel(PCSrc),
		.out(pc_next)	
);
		// data_memory
		
		data_memory DM (
		.clk(clk),
		.mem_read(MemRead),
		.addr(ALUResult),
		.mem_write(MemWrite),
		.write_data(rd2),
		.read_data(Readdata)
);

   //Multiplexeur pour choisir si le resultat est de l'ALU ou de la memoire de donnees 
	   
	  Multiplexer MUX2 (
	  .A(ALUResult),
	  .B(Readdata),
	  .sel(ResultSrc),
	  .out(resultat)
);	 

		
		//control unit
		
		RISCV_Controller CONTROL (
		.op(instruction[6:0]),
		.funct3(instruction[14:12]),
		.funct7b5(instruction[30]),
		.zero(zero),
		.RegWrite(RegWrite),
		.ImmSrc(ImmSrc),
		.MemWrite(MemWrite),
		.ALUSrc(ALUSrc),
		.ResultSrc(ResultSrc),
		.ALUControl(ALUControl),
		.ALUop(aluop),
		.enable(enable),
		.MemRead(MemRead),
		.PCSrc(PCSrc)
		);
		
		
		assign Result= resultat;
		assign pc= pc_current;
		assign instr= instruction;
		assign resWB=reg13;  //registre contenent les resultas des operations
	
endmodule		
		
		 
		
		
		
		
		
			