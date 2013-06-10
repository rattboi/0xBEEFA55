
#src_v=$(wildcard *.v)
src_sv=$(wildcard *.sv)

all:
	vlog -O5 +cover $(src_v) $(src_sv) 
	vsim -c -do questa.tcl -coverage -voptargs="+cover=bcfst" testbench
report: 
	vsim -c -do report.tcl
once:
	vlib work

