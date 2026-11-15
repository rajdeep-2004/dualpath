`timescale 1ns / 1ps
// Instruction memory (Harvard): 64 words x 16 bits, read-only.
// Asynchronous read: `data` follows `addr` immediately (no clock needed).
// Filled with zeros first (0x0000 = HALT), then the program is loaded.
module instruction_memory #(
    parameter PROG_FILE = "programs/prog1.hex"
) (
    input  [5:0]  addr,
    output [15:0] data
);
    reg [15:0] mem [0:63];
    integer i;

    initial begin
        for (i = 0; i < 64; i = i + 1)
            mem[i] = 16'h0000;
        $readmemh(PROG_FILE, mem);
    end

    assign data = mem[addr];
endmodule
