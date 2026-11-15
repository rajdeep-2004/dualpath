`timescale 1ns / 1ps
// Testbench for the Harvard system.
// Pick the program with the PROG_NUM parameter (1, 2 or 3); the Makefile sets it:
//   make harvard PROG=prog1
// Runs until `halted`, checks the expected results, prints PASS/FAIL and a
// RESULT line used by `make compare`, and dumps a VCD into sim/.
module tb_harvard;
    parameter PROG_NUM = 1;
    parameter MAX_CYCLES = 200;

    // All three names have the same length, so the ternary keeps them intact.
    localparam PROG_FILE = (PROG_NUM == 1) ? "programs/prog1.hex" :
                           (PROG_NUM == 2) ? "programs/prog2.hex" :
                                             "programs/prog3.hex";
    localparam DATA_FILE = (PROG_NUM == 1) ? "programs/prog1_data.hex" :
                           (PROG_NUM == 2) ? "programs/prog2_data.hex" :
                                             "programs/prog3_data.hex";
    localparam VCD_FILE  = (PROG_NUM == 1) ? "sim/harvard_prog1.vcd" :
                           (PROG_NUM == 2) ? "sim/harvard_prog2.vcd" :
                                             "sim/harvard_prog3.vcd";

    reg clk = 1'b0;
    reg rst = 1'b1;
    wire        halted, addr_err;
    wire [15:0] io_out;

    harvard_top #(.PROG_FILE(PROG_FILE), .DATA_FILE(DATA_FILE)) dut (
        .clk(clk), .rst(rst), .halted(halted), .io_out(io_out), .addr_err(addr_err)
    );

    always #5 clk = ~clk;   // 10 ns clock period

    // ---------------- Counters (sampled on every rising edge) ----------------
    integer cycles   = 0;   // cycles from reset release until halted
    integer mem_ops  = 0;   // LOAD/STORE instructions executed
    integer overlap  = 0;   // cycles with an instruction fetch AND a data access
    reg     saw_addr_err = 1'b0;

    always @(posedge clk) begin
        if (!rst && !halted) begin
            cycles = cycles + 1;
            if (dut.d_re || dut.d_we) begin
                mem_ops = mem_ops + 1;
                overlap = overlap + 1;   // Harvard fetches every cycle, so every data access overlaps
            end
            if (addr_err)
                saw_addr_err = 1'b1;
        end
    end

    // ---------------- Checks ----------------
    integer errors = 0;

    task check;
        input [255:0] name;
        input [15:0]  got;
        input [15:0]  expected;
        begin
            if (got !== expected) begin
                $display("  FAIL %0s: got %0d, expected %0d", name, got, expected);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        $dumpfile(VCD_FILE);
        $dumpvars(0, tb_harvard);

        repeat (2) @(posedge clk);
        rst <= 1'b0;

        while (!halted && cycles < MAX_CYCLES)
            @(posedge clk);
        @(negedge clk);

        if (!halted) begin
            $display("  FAIL: did not halt within %0d cycles", MAX_CYCLES);
            errors = errors + 1;
        end

        case (PROG_NUM)
            1: begin
                check("R1", dut.u_cpu.u_rf.r1, 16'd5);
                check("R2", dut.u_cpu.u_rf.r2, 16'd7);
                check("R3", dut.u_cpu.u_rf.r3, 16'd12);
                check("MEM[0x20]", dut.u_dmem.mem[6'h20], 16'd12);
                check("cycles", cycles, 16'd5);
            end
            2: begin
                check("io_out", io_out, 16'd5);
                check("addr_err seen", saw_addr_err, 16'd1);
                check("MEM[0x30] (unmapped write ignored)", dut.u_dmem.mem[6'h30], 16'd0);
                check("MEM[0x3F] (io write, not memory)", dut.u_dmem.mem[6'h3F], 16'd0);
                check("cycles", cycles, 16'd4);
            end
            default: begin
                check("R1", dut.u_cpu.u_rf.r1, 16'd0);
                check("R2", dut.u_cpu.u_rf.r2, 16'd0);
                check("R3", dut.u_cpu.u_rf.r3, 16'd0);
                check("cycles", cycles, 16'd4);
            end
        endcase

        $display("harvard prog%0d: %0s | cycles=%0d load_store=%0d fetch+data_same_cycle=%0d",
                 PROG_NUM, (errors == 0) ? "PASS" : "FAIL", cycles, mem_ops, overlap);
        $display("RESULT harvard prog%0d %0s %0d %0d",
                 PROG_NUM, (errors == 0) ? "PASS" : "FAIL", mem_ops, cycles);
        $finish;
    end
endmodule
