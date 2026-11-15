`timescale 1ns / 1ps
// Data memory (Harvard): 64 words x 16 bits.
// Asynchronous read; write happens on the rising clock edge when `we` is 1.
// Filled with zeros, then the data file is loaded (data files start with @10).
module data_memory #(
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
        $readmemh(DATA_FILE, mem);
    end

    always @(posedge clk) begin
        if (we)
            mem[addr] <= wdata;
    end

    assign rdata = mem[addr];
endmodule
