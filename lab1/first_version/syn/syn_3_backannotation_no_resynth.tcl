read_verilog -netlist ../netlist/backannotation/synopsys/IIR_no_resynth.v
create_clock -name MY_CLK -period 10.03 {CLK}
read_saif -input ../netlist/backannotation/synopsys/saif/IIR_no_resynth.saif -instance tb_iir/DUT -unit ns -scale 1 > ../netlist/backannotation/synopsys/backannotation_notes_no_resynth.txt

report_power > ../netlist/results/post_backannotation_pre_innovus/no_resynth/power.txt
report_power -net > ../netlist/results/post_backannotation_pre_innovus/no_resynth/power_net.txt
report_power -hier > ../netlist/results/post_backannotation_pre_innovus/no_resynth/power_hier.txt
