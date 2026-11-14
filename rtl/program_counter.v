`timescale 1ns / 1ps
// Program counter: holds the address of the current instruction.
// Goes +1 on each rising clock edge when `en` is 1, otherwise holds its value.
// The CPU sets en = 0 during a stall or after HALT.
module program_counter (
    input            clk,
    input            rst,  // synchronous, active high: PC -> 0
    input            en,   // 1 = move to the next instruction
    output reg [5:0] pc
);
    always @(posedge clk) begin
        if (rst)
            pc <= 6'd0;
        else if (en)
            pc <= pc + 6'd1;
    end
endmodule
