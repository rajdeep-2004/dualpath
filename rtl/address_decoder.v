`timescale 1ns / 1ps
// Address decoder (combinational): decides where a data address goes.
//
//   0x00 - 0x2F  memory          -> sel_mem
//   0x30 - 0x3E  nothing         -> addr_err (write ignored, read = 0)
//   0x3F         output register -> sel_io
//
// `access` is 1 only when the CPU is really doing a LOAD or STORE, so
// addr_err does not flash on ADD/HALT instructions.
module address_decoder (
    input  [5:0] addr,
    input        access,
    output       sel_mem,
    output       sel_io,
    output       addr_err
);
    wire in_mem = (addr <= 6'h2F);
    wire in_io  = (addr == 6'h3F);

    assign sel_mem  = in_mem;
    assign sel_io   = in_io;
    assign addr_err = access & ~in_mem & ~in_io;
endmodule
