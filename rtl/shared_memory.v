`timescale 1ns / 1ps
// Shared memory (von Neumann): 64 words x 16 bits holding BOTH the program
// and the data. It has exactly ONE port: one address, one write enable,
// one write-data, one read-data. So per cycle it can serve either an
// instruction fetch OR a data access, never both.
// Program loaded at 0x00, data file loaded at 0x10 (data files start with @10).
module shared_memory #(
    parameter PROG_FILE = "programs/prog1.hex",
    parameter DATA_FILE = "programs/prog1_data.hex"
) (
    input         clk,
    input  [5:0]  addr,
    input         we,
    input  [15:0] wdata,
    output [15:0] rdata
);
    reg [15:0] mem [0:63];
    integer i;

    initial begin
        for (i = 0; i < 64; i = i + 1)
            mem[i] = 16'h0000;
        $readmemh(PROG_FILE, mem);
        $readmemh(DATA_FILE, mem);
    end

    always @(posedge clk) begin
        if (we)
            mem[addr] <= wdata;
    end

    assign rdata = mem[addr];   // asynchronous read
endmodule
