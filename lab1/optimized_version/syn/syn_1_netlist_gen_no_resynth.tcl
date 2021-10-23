read_file -format ddc ../netlist/ddc_files/IIR_no_resynth.ddc

ungroup -all -flatten
change_names -hierarchy -rules verilog
write_sdf ../netlist/backannotation/synopsys/IIR_no_resynth.sdf
write -f verilog -hierarchy -output ../netlist/backannotation/synopsys/IIR_no_resynth.v
write_sdc ../netlist/backannotation/synopsys/IIR_no_resynth.sdc
