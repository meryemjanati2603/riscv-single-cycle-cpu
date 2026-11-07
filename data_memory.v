module data_memory (
    input wire clk,
    input wire mem_read,
    input wire mem_write,
    input wire [31:0] addr,
    input wire [31:0] write_data,
    output wire [31:0] read_data
);
    reg [31:0] memory [0:32];
    integer k;

    initial begin
        for (k = 0; k <= 32; k = k + 1)
            memory[k] = 32'd0;
    end

    always @(posedge clk) begin
        if (mem_write)
            memory[addr[6:2]] <= write_data;
    end

    assign read_data = mem_read ? memory[addr[6:2]] : 32'd0;
endmodule


