`timescale 1ns/1ps
module tb;
  reg clk = 0;
  reg reset = 1;
  wire [31:0] Result, pc, instr, resWB;

  mono_cycle_top dut (
    .clk(clk),
    .reset(reset),
    .Result(Result),
    .pc(pc),
    .instr(instr),
    .resWB(resWB)
  );

  always #5 clk = ~clk;
  always @(posedge clk)
    $display("t=%0t pc=%h instr=%h RegWrite=%b rd1=%h rd2=%h alu=%h Result=%h resWB=%h", $time, pc, instr, dut.RegWrite, dut.rd1, dut.rd2, dut.ALUResult, Result, resWB);

  initial begin
    #22 reset = 0;
    #100 $stop;
  end
endmodule


