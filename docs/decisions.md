# Decisions

Short design reasons for the Project 9 capstone. Each entry answers a "why did you do it this
way?" question about the design.

---

## 2026-11-14 — Why the CPU is single-cycle

A multi-cycle CPU already spends several cycles per instruction (fetch, decode, execute,
memory). Then the shared memory could fetch in one of those cycles and access data in another,
and both systems would take the same time: nothing to compare. With a single-cycle CPU, the
Harvard system does fetch and data access in the same cycle, while the shared system physically
cannot (one port), so it must stall. That makes the difference visible and countable.

---

## 2026-11-14 — Shared controller reads the opcode, not `d_we`

**Context.** The first idea was that the controller stalls when the fetched instruction is a LOAD/STORE,
detected as `d_re | d_we`. But the CPU forces `d_we = 0` whenever `stall = 1`. So `stall`
would depend on `d_we`, and `d_we` on `stall`: a combinational loop. A STORE would set
`stall = 1`, which clears `d_we`, which clears `stall`, and so on.

**Decision.** The controller looks at the opcode bits of the fetched word directly
(`mem_rdata[15:12]` is 2 or 3). The behavior is the same as planned; only the
detection signal changed. File: `rtl/shared_mem_controller.v`.

---

## 2026-11-14 — `halted` is a register

HALT sets `halted` on the clock edge where it executes, and it stays 1 until reset. The PC stops
and no more registers or memory are written. Making it a register (not a combinational "this is
a HALT" wire) gives a clean cycle count: the HALT instruction itself is counted, matching
the definition ("cycles from reset release until halted = 1, including HALT"). File: `rtl/cpu.v`.

---

## 2026-11-14 — `addr_err` only during a real data access

The address decoder has an `access` input (`d_re | d_we`; in the shared system also `phase`).
Without it, an ADD would also produce some `d_addr` (from its bit fields) and `addr_err` could
flash on instructions that never touch memory. Now `addr_err` = 1 only when a LOAD/STORE really
uses an unmapped address (prog2, instruction 2). File: `rtl/address_decoder.v`.

---

## 2026-11-14 — prog3 only produces zeros

The ISA has no "load immediate" instruction and R0 is always 0, so without a LOAD nothing can
create a nonzero value. prog3 exists only as the control case: no data access means zero extra
cycles in the shared system. The adder is proven by prog1 (5 + 7 = 12).

---

## 2026-11-14 — Instruction/data separation as a comparison point

In the Harvard system a STORE writes data memory, so it can never overwrite instructions. In
the shared system, data and program live in the same memory, so a STORE to 0x00–0x0F would
overwrite the program. No test program demonstrates this (scope kept to the project sheet); it is a
talking point for the report.

---

## 2026-11-14 — Testbench and Makefile details

- **Program selection.** The Makefile passes `PROG_NUM` (1, 2, 3) to the testbench with
  `iverilog -P`. The testbench picks file names with a ternary. All names have equal length, so
  the strings stay intact.
- **R1–R3 in waveforms.** VCD files do not dump memory arrays, so `register_file.v` has named
  wires `r1`, `r2`, `r3` copied from the array.
- **"Not enough words" warning.** `$readmemh` warns when a file is shorter than the 64-word
  memory. It is harmless because every memory is zero-filled first (0x0000 = HALT). The Makefile
  filters this warning out.
- **Checked that the tests can fail.** Replacing the adder with a subtractor makes prog1 print
  `FAIL R3: got 65534, expected 12`.
