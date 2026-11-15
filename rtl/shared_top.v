`timescale 1ns / 1ps
// Shared-memory (von Neumann) system: the same CPU, but instructions and data
// live in one memory with one port. The controller makes the CPU wait one
// extra cycle (stall) for every LOAD/STORE.
//   CPU -> shared_mem_controller -> shared_memory
//   CPU data port -> address_decoder -> rw_control -> (memory via controller) / io_reg
module shared_top #(
    parameter PROG_FILE = "programs/prog1.hex",
    parameter DATA_FILE = "programs/prog1_data.hex"
) (
    input         clk,
    input         rst,
    output        halted,
    output [15:0] io_out,
    output        addr_err
);
    // CPU signals
    wire [5:0]  i_addr;
    wire [15:0] i_data;
    wire [5:0]  d_addr;
    wire        d_re, d_we;
    wire [15:0] d_wdata, d_rdata;
    wire        stall;

    // decoder / control
    wire        sel_mem, sel_io, data_we, io_we;

    // the single memory port
    wire [5:0]  mem_addr;
    wire        mem_we;
    wire [15:0] mem_rdata;
    wire        phase;

    cpu u_cpu (
        .clk(clk), .rst(rst), .stall(stall),
        .i_addr(i_addr), .i_data(i_data),
        .d_addr(d_addr), .d_re(d_re), .d_we(d_we),
        .d_wdata(d_wdata), .d_rdata(d_rdata),
        .halted(halted)
    );

    shared_mem_controller u_ctrl (
        .clk(clk), .rst(rst),
        .pc(i_addr), .d_addr(d_addr), .data_we(data_we),
        .mem_rdata(mem_rdata),
        .mem_addr(mem_addr), .mem_we(mem_we),
        .instr(i_data), .stall(stall), .phase(phase)
    );

    address_decoder u_dec (
        .addr(d_addr), .access(phase & (d_re | d_we)),
        .sel_mem(sel_mem), .sel_io(sel_io), .addr_err(addr_err)
    );

    rw_control u_rwc (
        .d_we(d_we), .sel_mem(sel_mem), .sel_io(sel_io),
        .mem_rdata(mem_rdata), .io_rdata(io_out),
        .mem_we(data_we), .io_we(io_we), .d_rdata(d_rdata)
    );

    shared_memory #(.PROG_FILE(PROG_FILE), .DATA_FILE(DATA_FILE)) u_mem (
        .clk(clk), .addr(mem_addr), .we(mem_we),
        .wdata(d_wdata), .rdata(mem_rdata)
    );

    io_reg u_io (
        .clk(clk), .rst(rst), .we(io_we),
        .wdata(d_wdata), .io_out(io_out)
    );
endmodule
