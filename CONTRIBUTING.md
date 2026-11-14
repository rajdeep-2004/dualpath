# Contributing: who adds what

The project is split into **5 phases**, one per team member. All code is already written and
tested. Each phase has its own branch on GitHub that contains the finished files.

Using a coding agent? Tell it to read `AGENTS.md` from your branch:
`git fetch origin && git show origin/<your-branch>:AGENTS.md`

**Your job:** copy **only your phase's files** from your phase branch into `main`, then commit
and push from **your own GitHub account**. No pull requests, no merges.

---

## Rules (read first; give these to your coding agent too)

1. **Go in phase order: 1 → 2 → 3 → 4 → 5.** Wait until the person before you has pushed.
2. **Always `git pull` on `main` before you start**, so you have everyone else's work.
3. **Copy only your own files** with `git checkout origin/<branch> -- <files>`.
   - Do **NOT** merge, rebase or cherry-pick the phase branch into `main`.
   - Do **NOT** push to the phase branch.
   - Do **NOT** touch files that belong to another phase.
   - Do **NOT** add `CONTRIBUTING.md` or `AGENTS.md` to `main` (never use `git add .`).
4. **Commit from your own account.** Check first with `git config user.name` and
   `git config user.email`; they must be yours.
5. **Push directly to `main`:** `git push origin main`.
6. **Read your files before you commit.** In the viva you must be able to explain every line.

---

## One-time setup (everyone)

1. Accept the collaborator invite email from GitHub for `rajdeep-2004/dualpath`.
2. Install Icarus Verilog: `brew install icarus-verilog` (macOS) or `sudo apt install iverilog` (Linux).
3. Clone the repo:
   ```sh
   git clone https://github.com/rajdeep-2004/dualpath.git
   cd dualpath
   ```

---

## Phase 1: Register file and program counter

| | |
|---|---|
| **Member** | Rajat |
| **Branch** | `phase-1-regfile-pc` |
| **Files** | `rtl/register_file.v`, `rtl/program_counter.v` |

**What it does.** The register file is 8 small storage boxes (R0–R7), each holding a 16-bit
number. The CPU reads two of them at a time and writes one. R0 is always 0. The program counter
(PC) holds the address of the current instruction and moves forward by 1 each cycle, unless the
CPU tells it to wait or the program has stopped.

**Steps**
```sh
git checkout main
git pull
git fetch origin
git checkout origin/phase-1-regfile-pc -- rtl/register_file.v
git commit -m "feat(rtl): add register file"
git checkout origin/phase-1-regfile-pc -- rtl/program_counter.v
git commit -m "feat(rtl): add program counter"
iverilog -g2001 -o check.vvp rtl/register_file.v rtl/program_counter.v && rm check.vvp && echo OK
git push origin main
```
**Done when:** the check prints `OK` and both files are on `main` under your name.

---

## Phase 2: CPU

| | |
|---|---|
| **Member** | Sachin |
| **Branch** | `phase-2-cpu` |
| **Files** | `rtl/cpu.v` |

**What it does.** The CPU reads one instruction and does it in one clock cycle. ADD adds two
registers. LOAD reads a number from memory into a register. STORE writes a register into memory.
HALT stops everything. It has a `stall` input: when it is 1, the CPU waits (the shared-memory
system uses this; the Harvard system never stalls it).

**Steps** (after Phase 1 is on `main`)
```sh
git checkout main
git pull
git fetch origin
git checkout origin/phase-2-cpu -- rtl/cpu.v
git commit -m "feat(rtl): add single-cycle CPU with stall input"
iverilog -g2001 -o check.vvp rtl/register_file.v rtl/program_counter.v rtl/cpu.v && rm check.vvp && echo OK
git push origin main
```
**Done when:** the check prints `OK` and `rtl/cpu.v` is on `main` under your name.

---

## Phase 3: Address decoder, read/write control, output register

| | |
|---|---|
| **Member** | Anand |
| **Branch** | `phase-3-decoder-io` |
| **Files** | `rtl/address_decoder.v`, `rtl/rw_control.v`, `rtl/io_reg.v` |

**What it does.** When the CPU reads or writes data, these decide where the address goes:
0x00–0x2F go to memory, 0x3F goes to the output register `io_out`, and 0x30–0x3E go nowhere
(the error flag `addr_err` turns on and the write is ignored). The read/write control makes sure a
write only reaches the place the address points to, and picks which data goes back to the CPU.

**Steps** (after Phase 2 is on `main`)
```sh
git checkout main
git pull
git fetch origin
git checkout origin/phase-3-decoder-io -- rtl/address_decoder.v
git commit -m "feat(rtl): add address decoder"
git checkout origin/phase-3-decoder-io -- rtl/rw_control.v
git commit -m "feat(rtl): add read/write control"
git checkout origin/phase-3-decoder-io -- rtl/io_reg.v
git commit -m "feat(rtl): add io_out register"
iverilog -g2001 -o check.vvp rtl/address_decoder.v rtl/rw_control.v rtl/io_reg.v && rm check.vvp && echo OK
git push origin main
```
**Done when:** the check prints `OK` and the three files are on `main` under your name.

---

## Phase 4: Harvard system (memories, top level, testbench, programs, Makefile, README)

| | |
|---|---|
| **Member** | Rajdeep |
| **Branch** | `phase-4-harvard` |
| **Files** | `rtl/instruction_memory.v`, `rtl/data_memory.v`, `rtl/harvard_top.v`, `tb/tb_harvard.v`, `programs/` (6 hex files), `Makefile`, `README.md`, `docs/decisions.md` |

**What it does.** Adds two separate memories: one only for instructions, one only for data. It
connects them to the CPU and the address decoder. Because the paths are separate, an instruction
and its data are used in the same clock cycle, so every instruction takes 1 cycle. It also adds
the 3 test programs, the testbench that runs them and checks the answers, the Makefile (shortcut
commands) and the README (how to run). After this phase the Harvard system runs end to end.

**Steps** (after Phase 3 is on `main`)
```sh
git checkout main
git pull
git fetch origin
git checkout origin/phase-4-harvard -- rtl/instruction_memory.v rtl/data_memory.v
git commit -m "feat(rtl): add instruction and data memories"
git checkout origin/phase-4-harvard -- programs/
git commit -m "feat(programs): add test programs and data"
git checkout origin/phase-4-harvard -- rtl/harvard_top.v tb/tb_harvard.v
git commit -m "feat(harvard): add Harvard top level and testbench"
git checkout origin/phase-4-harvard -- Makefile README.md docs/decisions.md
git commit -m "docs: add Makefile, README and design notes"
make harvard PROG=prog1
make harvard PROG=prog2
make harvard PROG=prog3
git push origin main
```
**Done when:** all three runs print `PASS` with cycles 5, 4 and 4.

---

## Phase 5: Shared-memory system and comparison

| | |
|---|---|
| **Member** | Omved |
| **Branch** | `phase-5-shared` |
| **Files** | `rtl/shared_memory.v`, `rtl/shared_mem_controller.v`, `rtl/shared_top.v`, `tb/tb_shared.v` |

**What it does.** Adds one single memory that holds both instructions and data, with only one
port (one "door"). A small controller takes turns at that door: one cycle to fetch the
instruction, then, for LOAD/STORE, one extra cycle for the data, during which it pauses the CPU
(`stall`). The testbench runs the same 3 programs. `make compare` then prints the Harvard vs
shared cycle table, the main result of the project.

**Steps** (after Phase 4 is on `main`)
```sh
git checkout main
git pull
git fetch origin
git checkout origin/phase-5-shared -- rtl/shared_memory.v
git commit -m "feat(rtl): add single-port shared memory"
git checkout origin/phase-5-shared -- rtl/shared_mem_controller.v
git commit -m "feat(rtl): add shared memory controller with stall"
git checkout origin/phase-5-shared -- rtl/shared_top.v tb/tb_shared.v
git commit -m "feat(shared): add shared top level and testbench"
make compare
git push origin main
```
**Done when:** `make compare` prints this table:

| Program | LOAD/STORE | Harvard cycles | Shared cycles | Extra |
|---|---|---|---|---|
| prog1 | 3 | 5 | 8 | 3 |
| prog2 | 3 | 4 | 7 | 3 |
| prog3 | 0 | 4 | 4 | 0 |

---

## After all 5 phases

Rajdeep checks that `main` has every file and `make compare` matches the table above. Then the
five phase branches are deleted.

## If something goes wrong

- **`git push` is rejected:** someone pushed before you. Run `git pull`, then `git push origin main` again.
- **`git checkout origin/...` says "invalid reference":** run `git fetch origin` first.
- **A check fails:** do not push. Make sure the earlier phases are on `main` (`git pull`), then ask Rajdeep.
