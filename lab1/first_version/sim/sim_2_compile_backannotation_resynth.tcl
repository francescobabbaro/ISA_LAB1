vlib work
vcom -93 -work work ../tb/clk_gen.vhd
vcom -93 -work work ../tb/data_maker.vhd
vcom -93 -work work ../tb/data_sink.vhd
vlog -work work ../netlist/backannotation/synopsys/IIR_resynth.v
vlog -work work ../tb/tb_iir.v

vsim -L /software/dk/nangate45/verilog/msim6.2g work.tb_iir
vsim -L /software/dk/nangate45/verilog/msim6.2g -sdftyp /tb_iir/DUT=../netlist/backannotation/synopsys/IIR_resynth.sdf work.tb_iir

vcd file ../netlist/backannotation/synopsys/vcd/IIR_resynth.vcd
vcd add /tb_iir/DUT/*

run 5 us
