read_file -format ddc ../netlist/ddc_files/iir.ddc
create_clock -name CLK -period 8.96 {CLK}

ungroup -all -flatten
change_names -hierarchy -rules verilog
write_sdf ../netlist/backannotation/iir.sdf
write -f verilog -hierarchy -output ../netlist/backannotation/iir.v
write_sdc ../netlist/backannotation/iir.sdc
