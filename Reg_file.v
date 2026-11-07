module Reg_file (
    input  clk,
    input  [4:0] a1, a2, a3,
    input  [31:0] wd3,
    input  we3,
    input  enable,
    output signed [31:0] rd1, rd2,
    output signed [31:0] register13
);
    reg signed [31:0] register [0:31];
    integer i;

    initial begin
        for (i = 0; i < 32; i = i + 1)
            register[i] = 32'd0;
        register[1]  = 32'd11;
        register[3]  = 32'd2;
        register[4]  = 32'd7;
        register[8]  = 32'd8;
        register[16] = 32'd2;
        register[25] = 32'd5;
    end

    always @(posedge clk) begin
        if (we3 && (a3 != 5'd0))
            register[a3] <= wd3;
    end

    assign rd1 = (a1 == 5'd0) ? 32'd0 : register[a1];
    assign rd2 = (a2 == 5'd0) ? 32'd0 : register[a2];
    assign register13 = register[13];
endmodule

