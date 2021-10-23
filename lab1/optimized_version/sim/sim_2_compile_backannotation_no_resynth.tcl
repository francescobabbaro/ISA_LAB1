vcom -93 -work work ../tb/clk_gen.vhd
vcom -93 -work work ../tb/data_maker.vhd
vcom -93 -work work ../tb/data_sink.vhd
vlog -work work ../netlist/backannotation/synopsys/IIR_1lookahead.v
vlog -work work ../tb/tb_iir_1lookahead.v

vsim -L /software/dk/nangate45/verilog/msim6.2g work.tb_iir_1lookahead
vsim -L /software/dk/nangate45/verilog/msim6.2g -sdftyp /tb_iir/DUT=../netlist/backannotation/synopsys/IIR_optimized.sdf work.tb_iir_1lookahead

vcd file ../netlist/backannotation/synopsys/vcd/IIR_1lookahead.vcd
vcd add /tb_iir_1lookahead/DUT/*

run 5 us
