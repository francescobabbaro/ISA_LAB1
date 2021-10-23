//`timescale 1ns

module tb_iir ();

	wire CLK_i;
	wire RST_n_i;
	wire [8:0] DIN_i;
	wire VIN_i;
	wire [8:0] C0_i;
	wire [8:0] C1_i;
	wire [8:0] C2_i;
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
		.c0(C0_i),
		.c1(C1_i),
		.c2(C2_i),
		.b0(B0_i),
		.b1(B1_i),
		.b2(B2_i),
		.end_sim(END_SIM_i)
	);

	IIR_1lookahead DUT (
		.din(DIN_i),
		.c0(C0_i),
		.c1(C1_i),
		.c2(C2_i),
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

		   
