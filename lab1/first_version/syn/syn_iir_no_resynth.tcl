# analysis of vhdl files
analyze -f vhdl -lib WORK ../src/flipflop_rst_n.vhd
analyze -f vhdl -lib WORK ../src/reg_rst_n.vhd
analyze -f vhdl -lib WORK ../src/reg_en_rst_n.vhd
analyze -f vhdl -lib WORK ../src/adder_Nbit.vhd
analyze -f vhdl -lib WORK ../src/multiplier_Nbit.vhd
analyze -f vhdl -lib WORK ../src/two_complement_Nbit.vhd
analyze -f vhdl -lib WORK ../src/datapath_IIR.vhd
analyze -f vhdl -lib WORK ../src/IIR.vhd

set power_preserve_rtl_hier_names true

# elaboration
elaborate IIR -arch structural -lib WORK

# clock creation
create_clock -name MY_CLK -period 0 {CLK}
set_dont_touch_network MY_CLK
set_fix_hold [get_clocks MY_CLK]
set_clock_uncertainty 0.07 [get_clocks MY_CLK]
set_input_delay 0.5 -max -clock MY_CLK [remove_from_collection [all_inputs] CLK]
set_output_delay 0.5 -max -clock MY_CLK [all_outputs]
set OLOAD [load_of NangateOpenCellLibrary/BUF_X4/A]
set_load $OLOAD [all_outputs]

# compilation
compile -exact_map
# creating clock AFTER the synthesis
create_clock -name MY_CLK -period 10.08 {CLK}

# ddc file saving
write -hierarchy -format ddc -output ../netlist/ddc_files/IIR_no_resynth.ddc

# report
report_power > ../netlist/results/pre_backannotation_pre_innovus/no_resynth/power.txt
report_power -net > ../netlist/results/pre_backannotation_pre_innovus/no_resynth/power_net.txt
report_power -hier > ../netlist/results/pre_backannotation_pre_innovus/no_resynth/power_hier.txt
report_timing > ../netlist/results/pre_backannotation_pre_innovus/no_resynth/timing.txt
report_area -hierarchy > ../netlist/results/pre_backannotation_pre_innovus/no_resynth/area.txt

