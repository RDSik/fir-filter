TOP := fir_filter

MACRO_FILE := wave.do
TCL_FILE   := project.tcl

TB_DIR := tb

SIM ?= verilator

SRC_FILES := $(wildcard \
	rtl/*.sv \
	tb/*.sv \
)

.PHONY: sim wave clean

sim: build run

build:
ifeq ($(SIM), verilator)
	$(SIM) --binary $(SRC_FILES) --trace --top $(TOP)_tb
else ifeq ($(SIM), questa)
	vsim -do $(TB_DIR)/$(MACRO_FILE)
endif

run:
ifeq ($(SIM), verilator)
	./obj_dir/V$(TOP)_tb
endif

wave:
	gtkwave $(TOP)_tb.vcd

clean:
	rm -rf obj_dir
	rm -rf work
	rm transcript
	rm *.vcd
	rm *.wlf
