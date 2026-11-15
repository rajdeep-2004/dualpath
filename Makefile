# Project 9 - Harvard vs shared memory
#   make harvard PROG=prog1   run one program on the Harvard system
#   make shared  PROG=prog1   run one program on the shared-memory system
#   make compare              run all programs on both systems, print the table
#   make clean                delete simulation output
#   make help                 show this list

IVERILOG ?= iverilog
VVP      ?= vvp
PROG     ?= prog1
PROGRAMS  = prog1 prog2 prog3
PROG_NUM  = $(subst prog,,$(PROG))

RTL_CPU = rtl/program_counter.v rtl/register_file.v rtl/cpu.v \
          rtl/address_decoder.v rtl/rw_control.v rtl/io_reg.v

HARVARD_SRC = $(RTL_CPU) rtl/instruction_memory.v rtl/data_memory.v \
              rtl/harvard_top.v tb/tb_harvard.v

SHARED_SRC  = $(RTL_CPU) rtl/shared_memory.v rtl/shared_mem_controller.v \
              rtl/shared_top.v tb/tb_shared.v

# Simulator noise that is expected and harmless (memories are zero-filled first).
NOISE = 'VCD info|Not enough words|\$$finish called'

.PHONY: help harvard shared compare clean check-prog

help:
	@sed -n '2,6p' Makefile | sed 's/^#//'

check-prog:
	@case " $(PROGRAMS) " in *" $(PROG) "*) ;; \
	  *) echo "Unknown PROG=$(PROG). Use one of: $(PROGRAMS)"; exit 1 ;; esac

harvard: check-prog
	@mkdir -p sim
	@$(IVERILOG) -g2001 -Wall -Ptb_harvard.PROG_NUM=$(PROG_NUM) -o sim/harvard_$(PROG).vvp $(HARVARD_SRC)
	@$(VVP) -n sim/harvard_$(PROG).vvp | grep -Ev $(NOISE)

shared: check-prog
	@mkdir -p sim
	@$(IVERILOG) -g2001 -Wall -Ptb_shared.PROG_NUM=$(PROG_NUM) -o sim/shared_$(PROG).vvp $(SHARED_SRC)
	@$(VVP) -n sim/shared_$(PROG).vvp | grep -Ev $(NOISE)

compare:
	@mkdir -p sim
	@for p in $(PROGRAMS); do \
		$(MAKE) -s harvard PROG=$$p; \
		$(MAKE) -s shared PROG=$$p; \
	done > sim/results.txt
	@echo "| Program | LOAD/STORE | Harvard cycles | Shared cycles | Extra |"
	@echo "|---|---|---|---|---|"
	@awk '$$1 == "RESULT" { ops[$$3] = $$5; cyc[$$2, $$3] = $$6 } \
	     END { for (i = 1; i <= 3; i++) { p = "prog" i; \
	           printf "| %s | %s | %s | %s | %d |\n", p, ops[p], cyc["harvard", p], \
	                  cyc["shared", p], cyc["shared", p] - cyc["harvard", p] } }' sim/results.txt
	@if grep -q FAIL sim/results.txt; then \
		echo ""; echo "Some checks FAILED:"; grep FAIL sim/results.txt; exit 1; \
	else \
		echo ""; echo "All 6 runs PASS."; \
	fi

clean:
	rm -rf sim
