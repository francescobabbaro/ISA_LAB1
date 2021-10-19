
read_verilog -netlist ../netlist/backannotation/iir.v
create_clock -name CLK -period 8.96 {CLK}
read_saif -input ../netlist/backannotation/saif/iir_syn.saif -instance tb_iir/DUT -unit ns -scale 1 > ../netlist/backannotation_notes.txt
#create_clock -name CLK -period 8.96 {CLK}

report_power > ../netlist/results/power_backannotation.txt
report_power -net > ../netlist/results/power_net_backannotation.txt
report_power -hier > ../netlist/results/power_hier_backannotation.txt
