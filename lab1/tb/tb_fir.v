//`timescale 1ns

module tb_fir ();

	wire CLK_i;
	wire RST_n_i;
	wire [8:0] DIN_i;
	wire VIN_i;
	wire [8:0] A1_i;
	wire [8:0] A2_i;
	wire [8:0] B0_i;
	wire [8:0] B1_i;
	wire [8:0] B2_i;
	wire [8:0] DOUT_i;
	wire VOUT_i;
	wire END_SIM_i;

	clk_gen CG(.END_SIM(END_SIM_i),
		.CLK(CLK_i),
		.RST_n(RST_n_i));

	data_maker DM (
		.clk(CLK_i),
		.rst_n(RST_n_i),
		.vout(VIN_i),
		.dout(DIN_i),
		.a1(A1_i),
		.a2(A2_i),
		.b0(B0_i),
		.b1(B1_i),
		.b2(B2_i),
		.end_sim(END_SIM_i)
	);

	IIR DUT (
		.din(DIN_i),
		.a1(A1_i),
		.a2(A2_i),
		.b0(B0_i),
		.b1(B1_i),
		.b2(B2_i),
		.vin(VIN_i),
		.clk(CLK_i),
		.rst_n(RST_n_i),
		.dout(DOUT_i),
		.vout(VOUT_i)
	);

	data_sink DS(.CLK(CLK_i),
		.RST_n(RST_n_i),
		.VIN(VOUT_i),
		.DIN(DOUT_i));

endmodule

		   