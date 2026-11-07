// MODULE : aludec
// Genere ALUControl a partir de ALUOp, funct3, funct7b5 et opb5.
//   ALUOp 00 : lw, sw          -> addition
//   ALUOp 01 : beq             -> soustraction (pour tester l'egalite)
//   ALUOp 10 : type R et addi  -> on regarde funct3
//
// ALUControl : 000 add | 001 sub | 010 and | 011 or

module aludec_simple (
    input        opb5,        // bit 5 de l'opcode (1 pour type R, 0 pour addi)
    input        funct7b5,    // bit 30 de l'instruction
    input  [2:0] funct3,      // bits 14 a 12 de l'instruction
    input  [1:0] ALUOp,
    output reg [2:0] ALUControl
);

    always @(*) begin
        case (ALUOp)
            2'b00: ALUControl = 3'b000;              // lw, sw : add
            2'b01: ALUControl = 3'b001;              // beq : sub
            2'b10: begin
                case (funct3)
                    // sub seulement si type R (opb5 = 1) ET funct7b5 = 1.
                    // Pour addi, le bit 30 fait partie de la constante.
                    3'b000: ALUControl = (opb5 & funct7b5) ? 3'b001 : 3'b000;
                    3'b110: ALUControl = 3'b011;     // or
                    3'b111: ALUControl = 3'b010;     // and
                    default: ALUControl = 3'bxxx;
                endcase
            end
            default: ALUControl = 3'bxxx;
        endcase
    end
endmodule
