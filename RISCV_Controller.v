// MODULE : control unit (maindec + aludec + porte PCSrc)

module RISCV_Controller (
    // ----- Entrees -----
    input  [6:0] op,            // opcode
    input  [2:0] funct3,        // funct3
    input        funct7b5,      // bit 30 de l'instruction
    input        zero,          // venant de l'ALU
    // ----- Sorties -----
    output       ResultSrc,
    output       MemWrite,
    output       ALUSrc,
    output       RegWrite,
    output [1:0] ImmSrc,
    output [2:0] ALUControl,
    output [1:0] ALUop,         // observation
    output       enable, MemRead,
    output       PCSrc
);

    wire [1:0] ALUOp;           // fil interne maindec -> aludec
    wire       branch;          // fil interne maindec -> porte ET

    maindec_simple md (
        .op(op),
        .ResultSrc(ResultSrc),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .ImmSrc(ImmSrc),
        .ALUOp(ALUOp),
        .enable(enable),
        .MemRead(MemRead),
        .branch(branch)
    );

    aludec_simple ad (
        .opb5(op[5]),
        .funct7b5(funct7b5),
        .funct3(funct3),
        .ALUOp(ALUOp),
        .ALUControl(ALUControl)
    );

    assign ALUop  = ALUOp;
    assign PCSrc  = zero & branch;   // saut si beq ET egalite

endmodule
