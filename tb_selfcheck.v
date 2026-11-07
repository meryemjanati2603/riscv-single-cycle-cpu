`timescale 1ns/1ps
// Banc de test auto-verifiant : lance program.hex, attend la fin du programme
// (boucle finale beq x0,x0,0 a l'adresse 0x84), compare les registres et la
// memoire aux valeurs attendues, puis affiche PASS ou FAIL.
module tb_selfcheck;
    reg clk = 0;
    reg reset = 1;
    wire [31:0] Result, pc, instr, resWB;

    integer errors = 0;
    integer cycles = 0;

    mono_cycle_top dut (
        .clk(clk), .reset(reset),
        .Result(Result), .pc(pc), .instr(instr), .resWB(resWB)
    );

    always #5 clk = ~clk;

    task check_reg(input [4:0] idx, input [31:0] expected, input [255:0] name);
        reg [31:0] got;
        begin
            got = dut.RF.register[idx];
            if (got === expected)
                $display("PASS  x%0d (%0s) = %0d", idx, name, got);
            else begin
                $display("FAIL  x%0d (%0s) : attendu %0d, obtenu %0d", idx, name, expected, got);
                errors = errors + 1;
            end
        end
    endtask

    task check_mem(input integer idx, input [31:0] expected, input [255:0] name);
        reg [31:0] got;
        begin
            got = dut.DM.memory[idx];
            if (got === expected)
                $display("PASS  memory[%0d] (%0s) = %0d", idx, name, got);
            else begin
                $display("FAIL  memory[%0d] (%0s) : attendu %0d, obtenu %0d", idx, name, expected, got);
                errors = errors + 1;
            end
        end
    endtask

    // Chien de garde : le programme doit finir en moins de 200 cycles
    always @(posedge clk) begin
        cycles = cycles + 1;
        if (cycles > 200) begin
            $display("FAIL  timeout : le PC n'a jamais atteint 0x84 (pc = %h)", pc);
            $display("TEST FAILED");
            $finish;
        end
    end

    initial begin
        #22 reset = 0;
        wait (pc === 32'h84);          // fin du programme
        repeat (2) @(posedge clk);

        check_reg(0,  0,  "x0 reste a 0");
        check_reg(13, 7,  "add");
        check_reg(14, 6,  "sub");
        check_reg(15, 3,  "and");
        check_reg(17, 15, "or");
        check_reg(18, 20, "addi");
        check_reg(19, 15, "addi negatif");
        check_reg(20, 11, "lw");
        check_reg(21, 0,  "saute par beq");
        check_reg(22, 1,  "beq non pris");
        check_reg(23, 0,  "boucle beq");
        check_reg(24, 0,  "saut avant de 64 octets");
        check_reg(26, 7,  "arrivee apres le saut");
        check_mem(1,  11, "sw");

        if (errors == 0) $display("TEST PASSED : toutes les verifications sont bonnes");
        else             $display("TEST FAILED : %0d erreur(s)", errors);
        $finish;
    end
endmodule
