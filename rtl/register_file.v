`timescale 1ns / 1ps
// Register file: 8 registers x 16 bits (R0..R7).
// Two read ports (combinational) and one write port (on the rising clock edge).
// R0 is hard-wired to 0: reading it always gives 0, writing it is ignored.
module register_file (
    input             clk,
    input             rst,     // synchronous, active high: all registers -> 0
    input             we,      // write enable
    input      [2:0]  waddr,   // register to write
    input      [15:0] wdata,   // value to write
    input      [2:0]  raddr1,  // first register to read
    input      [2:0]  raddr2,  // second register to read
    output     [15:0] rdata1,
    output     [15:0] rdata2
);
    reg [15:0] regs [0:7];
    integer i;

    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 8; i = i + 1)
                regs[i] <= 16'd0;
        end else if (we && waddr != 3'd0) begin
            regs[waddr] <= wdata;
        end
    end

    assign rdata1 = (raddr1 == 3'd0) ? 16'd0 : regs[raddr1];
    assign rdata2 = (raddr2 == 3'd0) ? 16'd0 : regs[raddr2];

    // Named copies of R1..R3 so they show up in the GTKWave waveform
    // (VCD files do not dump memory arrays).
    wire [15:0] r1 = regs[1];
    wire [15:0] r2 = regs[2];
    wire [15:0] r3 = regs[3];
endmodule
