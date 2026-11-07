

//==================== ALU ====================

module alu (
    input  signed [31:0] rdA,
    input  signed [31:0] rdB,
    input  [2:0]  ALUControl, // 3-bit control
    output reg signed [31:0] ALUresult,
    output Carry, zero
);
    reg Cout;
    assign Carry = Cout;
    assign zero  = ~|ALUresult;

    always @(*) begin
        ALUresult = 32'b0;
        Cout = 1'b0;
        case (ALUControl)
            3'b000: {Cout, ALUresult} = rdA + rdB;
            3'b001: ALUresult = rdA - rdB;
            3'b010: ALUresult = rdA & rdB;   // and
            3'b011: ALUresult = rdA | rdB;   // or
            default: ALUresult = 32'b0;
        endcase
    end
endmodule


