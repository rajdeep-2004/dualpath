# Project 9: Harvard vs Shared Memory

A tiny single-cycle 16-bit CPU (HALT, ADD, LOAD, STORE) runs the same programs on two systems:

- **Harvard**: separate instruction memory and data memory. A LOAD/STORE fetches its
  instruction and accesses its data in the same clock cycle, so every instruction takes 1 cycle.
- **Shared memory (von Neumann)**: one memory with one port for both. A LOAD/STORE needs
  2 cycles (fetch, then data), so the CPU stalls 1 cycle per LOAD/STORE.

Result: `shared cycles = Harvard cycles + number of LOAD/STOREs`.

## Requirements

- Icarus Verilog: `brew install icarus-verilog` (macOS) or `sudo apt install iverilog` (Linux)
- GTKWave (to view waveforms): `brew install --cask gtkwave` or `sudo apt install gtkwave`

## How to run

```sh
make harvard PROG=prog1    # one program on the Harvard system (prog1, prog2 or prog3)
make shared  PROG=prog1    # one program on the shared-memory system
make compare               # all programs on both systems + comparison table
make clean                 # delete sim/
```

Each run prints `PASS` or `FAIL` (with the reason) and writes a waveform to `sim/`, e.g.
`sim/harvard_prog1.vcd`. Open it with `gtkwave sim/harvard_prog1.vcd`.

Expected `make compare` output:

| Program | LOAD/STORE | Harvard cycles | Shared cycles | Extra |
|---|---|---|---|---|
| prog1 | 3 | 5 | 8 | 3 |
| prog2 | 3 | 4 | 7 | 3 |
| prog3 | 0 | 4 | 4 | 0 |

## Test programs (`programs/`)

| Program | What it does | Checks |
|---|---|---|
| prog1 | LOAD 5, LOAD 7, ADD, STORE to 0x20 | R1 = 5, R2 = 7, R3 = 12, MEM[0x20] = 12 |
| prog2 | LOAD 5, STORE to 0x3F (io_out), STORE to 0x30 (unmapped) | io_out = 5, addr_err = 1, memory unchanged |
| prog3 | Three ADDs, no memory access (control case) | R1 = R2 = R3 = 0, no extra cycles |

## Data address map (both systems)

| Address | Goes to |
|---|---|
| 0x00 – 0x2F | memory (program 0x00–0x0F, data 0x10–0x2F) |
| 0x30 – 0x3E | nothing: `addr_err` = 1, write ignored, read = 0 |
| 0x3F | output register `io_out` |

## What to look at in GTKWave

Signals live under `tb_harvard.dut` / `tb_shared.dut`: `clk`, `rst`, `i_addr` (PC), `i_data`
(instruction), `d_addr`, `d_re`, `d_we`, `d_wdata`, `d_rdata`, `addr_err`, `stall`, `phase`,
`mem_addr` (shared memory address), `u_cpu.u_rf.r1`–`r3`, `io_out`, `halted`.

- **Harvard, prog1**: during a LOAD, `i_addr` (to instruction memory) and `d_addr` (to data
  memory) are both active in the same cycle.
- **Shared, prog1**: `mem_addr` = PC with `stall` = 1, then `mem_addr` = data address in the
  next cycle (`phase` = 1).

## Files

| Folder | Contents |
|---|---|
| `rtl/` | `program_counter`, `register_file`, `cpu`, `instruction_memory`, `data_memory`, `shared_memory`, `address_decoder`, `rw_control`, `io_reg`, `shared_mem_controller`, `harvard_top`, `shared_top` |
| `tb/` | `tb_harvard.v`, `tb_shared.v` |
| `programs/` | program and data hex files |
| `sim/` | generated waveforms (not in git) |
| `docs/` | `decisions.md` (design reasons) |

## Team

| Member | Modules |
|---|---|
| Rajat | `register_file.v`, `program_counter.v` |
| Sachin | `cpu.v` |
| Anand | `address_decoder.v`, `rw_control.v`, `io_reg.v` |
| Rajdeep | `instruction_memory.v`, `data_memory.v`, `harvard_top.v`, `tb_harvard.v`, `programs/`, `Makefile`, `README.md`, `docs/decisions.md` |
| Omved | `shared_memory.v`, `shared_mem_controller.v`, `shared_top.v`, `tb_shared.v` |
