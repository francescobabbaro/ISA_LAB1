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
elaborate IIR -arch STRUCTURAL -lib WORK

# clock creation
create_clock -name CLK -period 8.96 {CLK}
set_dont_touch_network CLK
#set_clock_uncertainty 0.07 [get_clocks CLK]
set OLOAD [load_of NangateOpenCellLibrary/BUF_X4/A]
set_load $OLOAD [all_outputs]

# compilation
compile -exact_map

# ddc file saving
write -hierarchy -format ddc -output ../netlist/ddc_files/iir_newclk.ddc

# report
report_power > ../netlist/results/power_newclk.txt
report_power -net > ../netlist/results/power_net_newclk.txt
report_power -hier > ../netlist/results/power_hier_newclk.txt
report_timing > ../netlist/results/timing_newclk.txt
report_area -hierarchy > ../netlist/results/area_newclk.txt

