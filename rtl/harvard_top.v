`timescale 1ns / 1ps
// Harvard system: the CPU has two independent paths.
//   Instruction path: PC -> instruction_memory -> instruction
//   Data path:        d_addr -> address_decoder -> rw_control -> data_memory / io_reg
// Both paths are used in the SAME clock cycle, so the CPU never stalls (stall = 0).
module harvard_top #(
    parameter PROG_FILE = "programs/prog1.hex",
    parameter DATA_FILE = "programs/prog1_data.hex"
) (
    input         clk,
    input         rst,
    output        halted,
    output [15:0] io_out,
    output        addr_err
);
    // CPU <-> memories
    wire [5:0]  i_addr;
    wire [15:0] i_data;
    wire [5:0]  d_addr;
    wire        d_re, d_we;
    wire [15:0] d_wdata, d_rdata;

    // decoder / control
    wire        sel_mem, sel_io, mem_we, io_we;
    wire [15:0] mem_rdata;
    wire        stall = 1'b0;   // separate memories: never a conflict

    cpu u_cpu (
        .clk(clk), .rst(rst), .stall(stall),
        .i_addr(i_addr), .i_data(i_data),
        .d_addr(d_addr), .d_re(d_re), .d_we(d_we),
        .d_wdata(d_wdata), .d_rdata(d_rdata),
        .halted(halted)
    );

    instruction_memory #(.PROG_FILE(PROG_FILE)) u_imem (
        .addr(i_addr), .data(i_data)
    );

    address_decoder u_dec (
        .addr(d_addr), .access(d_re | d_we),
        .sel_mem(sel_mem), .sel_io(sel_io), .addr_err(addr_err)
    );

    rw_control u_rwc (
        .d_we(d_we), .sel_mem(sel_mem), .sel_io(sel_io),
        .mem_rdata(mem_rdata), .io_rdata(io_out),
        .mem_we(mem_we), .io_we(io_we), .d_rdata(d_rdata)
    );

    data_memory #(.DATA_FILE(DATA_FILE)) u_dmem (
        .clk(clk), .addr(d_addr), .we(mem_we),
        .wdata(d_wdata), .rdata(mem_rdata)
    );

    io_reg u_io (
        .clk(clk), .rst(rst), .we(io_we),
        .wdata(d_wdata), .io_out(io_out)
    );
endmodule
