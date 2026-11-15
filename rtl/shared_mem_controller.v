`timescale 1ns / 1ps
// Shared-memory controller: shares the ONE memory port between instruction
// fetch and data access by taking turns.
//
//   phase 0 (fetch): memory address = PC, no write. The CPU gets the memory
//                    output as its instruction. If it is a LOAD/STORE, the
//                    data access cannot happen this cycle (the port is busy
//                    fetching), so: stall = 1, save the instruction in IR,
//                    go to phase 1. Otherwise the instruction finishes now.
//   phase 1 (data):  the CPU gets IR as its instruction. Memory address =
//                    d_addr, write allowed. stall = 0, the instruction
//                    finishes, go back to phase 0.
//
// LOAD/STORE is detected from the opcode bits of the fetched word. (Using
// the CPU's d_we would form a loop: the CPU forces d_we = 0 while stalled.)
module shared_mem_controller (
    input             clk,
    input             rst,        // synchronous, active high: phase -> 0
    input      [5:0]  pc,         // from the CPU (i_addr)
    input      [5:0]  d_addr,     // from the CPU
    input             data_we,    // memory write request from rw_control
    input      [15:0] mem_rdata,  // shared memory read data
    output     [5:0]  mem_addr,   // to the shared memory port
    output            mem_we,     // to the shared memory port
    output     [15:0] instr,      // to the CPU (i_data)
    output            stall,      // to the CPU
    output reg        phase
);
    reg [15:0] IR;

    wire [3:0] fetched_op = mem_rdata[15:12];
    wire       is_mem_op  = (fetched_op == 4'd2) || (fetched_op == 4'd3);  // LOAD or STORE

    assign stall    = ~phase & is_mem_op;
    assign instr    = phase ? IR : mem_rdata;
    assign mem_addr = phase ? d_addr : pc;
    assign mem_we   = phase & data_we;

    always @(posedge clk) begin
        if (rst) begin
            phase <= 1'b0;
            IR    <= 16'h0000;
        end else if (stall) begin
            IR    <= mem_rdata;   // remember the LOAD/STORE for the data cycle
            phase <= 1'b1;
        end else begin
            phase <= 1'b0;
        end
    end
endmodule
