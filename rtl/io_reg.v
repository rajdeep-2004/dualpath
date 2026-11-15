`timescale 1ns / 1ps
// Output register at data address 0x3F (a tiny "output port").
// Loads `wdata` on the rising clock edge when `we` is 1.
module io_reg (
    input             clk,
    input             rst,     // synchronous, active high: io_out -> 0
    input             we,
    input      [15:0] wdata,
    output reg [15:0] io_out
);
    always @(posedge clk) begin
        if (rst)
            io_out <= 16'd0;
        else if (we)
            io_out <= wdata;
    end
endmodule
