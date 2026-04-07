
PWD       := $(shell pwd)

TB_NAME      ?= testbench

TB_HOME  = $(PWD)/tb
RTL_HOME  = $(PWD)/rtl

RTL_FILES = $(RTL_HOME)/fifo.sv \
	$(RTL_HOME)/axi_module.sv
	
TB_FILES = $(TB_HOME)/$(TB_NAME).sv

run: clean compile_and_sim

compile_and_sim:
	vlib work
	vmap work work
	vlog -sv $(RTL_FILES)
	vlog -sv $(TB_FILES)
	vsim -gui -voptargs=+acc work.$(TB_NAME) -do "add wave -r /*; run -all"

clean:
	rm -rf work
	rm -f transcript *.wlf *.vstf

