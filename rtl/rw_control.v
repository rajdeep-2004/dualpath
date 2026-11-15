`timescale 1ns / 1ps
// Read/write control (combinational).
// Write: the CPU's write enable only reaches the target the decoder selected.
// Read:  the CPU gets memory data, the io_out value, or 0 for unmapped addresses.
module rw_control (
    input         d_we,       // write request from the CPU
    input         sel_mem,
    input         sel_io,
    input  [15:0] mem_rdata,  // data read from memory
    input  [15:0] io_rdata,   // current io_out value
    output        mem_we,
    output        io_we,
    output [15:0] d_rdata     // read data back to the CPU
);
    assign mem_we  = d_we & sel_mem;
    assign io_we   = d_we & sel_io;
    assign d_rdata = sel_mem ? mem_rdata :
                     sel_io  ? io_rdata  :
                               16'd0;
endmodule
