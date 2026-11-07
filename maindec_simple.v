// MODULE : maindec
// Génère les signaux de contrôle à partir du champ opcode.

module maindec_simple (
    input  [6:0] op,           // Champ opcode (7 bits)
    output       ResultSrc,    // Sélection de la source du résultat
    output       MemWrite,     // Écriture mémoire
    output       ALUSrc,       // Sélection entrée ALU
    output       RegWrite,     // Écriture registre
    output [1:0] ImmSrc,       // Type d'immédiat (I, S, B, J, etc.)
    output [1:0] ALUOp,
    output enable,MemRead,
    output branch	 // Type d’opération ALU
);

    // Déclaration d’un vecteur de contrôle (équivalent du signal "controls")
    // Chaque bit correspond à un signal de sortie.
    
    reg [10:0] controls;  

    
    always @(*) begin
        case (op)
            7'b0000011: controls = 11'b10010100110; // lw  (Load Word)
	    7'b0100011: controls = 11'b00111000000; // sw
            7'b0110011: controls = 11'b10000010100; // R-type
            7'b0010011: controls = 11'b10010010100; // addi (type I arithmetique)
            7'b1100011: controls = 11'b01000001001; // beq  (type B)
            default:    controls = 11'b00000000000; // Valeur par défaut (instruction invalide)
        endcase
    end

    // Attribution des bits du vecteur "controls" aux sorties
    
    assign {RegWrite,        // bit 10
            ImmSrc[1],       // bit 9
            ImmSrc[0],       // bit 8
            ALUSrc,          // bit 7
            MemWrite,        // bit 6
            ResultSrc,       // bit 5
            ALUOp[1],        // bit 4
            ALUOp[0],        // bit 3
			   enable,          // bit 2
		      MemRead,         // bit 1
			   branch	}       //bit 0    
            = controls;

endmodule