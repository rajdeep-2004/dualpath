`timescale 1ns / 1ps
// Single-cycle CPU with 4 instructions. Each instruction is fetched, decoded
// and executed in one clock cycle (unless `stall` is 1).
//
//   opcode 0      HALT                  stop: halted = 1, PC stops
//   opcode 1      ADD   rd, rs1, rs2    rd = rs1 + rs2
//   opcode 2      LOAD  rd, [rs1+imm6]  rd = MEM[addr]
//   opcode 3      STORE rs2, [rs1+imm6] MEM[addr] = rs2
//   opcode 4..15  unused                treated as HALT
//
// Encoding: [15:12] opcode, [11:9] rd (or STORE value reg), [8:6] rs1,
//           [5:0] imm6 (LOAD/STORE) or [5:3] rs2 (ADD).
//
// The same CPU is used in both systems. `stall` = 1 means "the memory is busy
// this cycle": PC holds, no register write, no memory write. Harvard ties
// stall to 0; the shared-memory controller drives it.
module cpu (
    input         clk,
    input         rst,      // synchronous, active high
    input         stall,    // 1 = PC holds, no register write, no memory write
    output [5:0]  i_addr,   // = PC
    input  [15:0] i_data,   // instruction
    output [5:0]  d_addr,
    output        d_re,     // 1 for LOAD
    output        d_we,     // 1 for STORE (forced 0 when stall = 1)
    output [15:0] d_wdata,
    input  [15:0] d_rdata,
    output        halted
);
    // ---------------- Decode ----------------
    wire [3:0] opcode = i_data[15:12];
    wire [2:0] rd     = i_data[11:9];   // destination (ADD/LOAD) or value reg (STORE)
    wire [2:0] rs1    = i_data[8:6];    // first source / base address register
    wire [2:0] rs2    = i_data[5:3];    // second source (ADD only)
    wire [5:0] imm6   = i_data[5:0];    // address offset (LOAD/STORE)

    wire is_add   = (opcode == 4'd1);
    wire is_load  = (opcode == 4'd2);
    wire is_store = (opcode == 4'd3);
    wire is_halt  = ~(is_add | is_load | is_store);  // opcode 0 and 4..15

    // ---------------- Control ----------------
    reg  halted_r;
    wire run = ~stall & ~halted_r;   // 1 = this instruction finishes this cycle

    // ---------------- Register file ----------------
    wire [15:0] rdata1, rdata2;
    wire [2:0]  raddr2 = is_store ? rd : rs2;   // STORE reads its value from [11:9]
    wire [15:0] alu_sum = rdata1 + rdata2;      // the adder (ADD)
    wire [15:0] wdata   = is_load ? d_rdata : alu_sum;

    register_file u_rf (
        .clk(clk), .rst(rst),
        .we(run & (is_add | is_load)),
        .waddr(rd), .wdata(wdata),
        .raddr1(rs1), .raddr2(raddr2),
        .rdata1(rdata1), .rdata2(rdata2)
    );

    // ---------------- Program counter ----------------
    wire [5:0] pc;
    program_counter u_pc (
        .clk(clk), .rst(rst),
        .en(run & ~is_halt),
        .pc(pc)
    );

    // HALT: set `halted` when the HALT instruction executes; it stays 1 until reset.
    always @(posedge clk) begin
        if (rst)
            halted_r <= 1'b0;
        else if (run & is_halt)
            halted_r <= 1'b1;
    end

    // ---------------- Outputs ----------------
    wire [15:0] addr_sum = rdata1 + {10'd0, imm6};   // data address = R[rs1] + imm6

    assign i_addr  = pc;
    assign d_addr  = addr_sum[5:0];
    assign d_re    = is_load & ~halted_r;
    assign d_we    = is_store & run;
    assign d_wdata = rdata2;
    assign halted  = halted_r;
endmodule
