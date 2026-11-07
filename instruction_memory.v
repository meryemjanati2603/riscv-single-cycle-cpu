module instruction_memory(
    input wire [31:0] read_addr,
    output wire [31:0] instruction_out
);

    reg [31:0] I_Mem [0:127];
    integer k;

    // Lecture combinatoire (adresse >> 2 car chaque instruction = 4 octets)
    assign instruction_out = I_Mem[read_addr >> 2];

    // Le programme n'est plus ecrit en dur : il est charge depuis program.hex
    // (produit par asm.py). Le fichier doit etre dans le dossier de simulation
    // (ou de projet Quartus).
    initial begin
        for (k = 0; k < 128; k = k + 1)
            I_Mem[k] = 32'b0;
        $readmemh("program.hex", I_Mem);
    end
endmodule
