library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity IIR_1lookahead is
	port(
		DIN        : in  std_logic_vector(8 downto 0);
		C0, C1, C2 : in  std_logic_vector(8 downto 0); -- new coefficients due to look-ahead
		B0, B1, B2 : in  std_logic_vector(8 downto 0);
		VIN        : in  std_logic;
		CLK        : in  std_logic;
		RST_N      : in  std_logic;
		DOUT       : out std_logic_vector(8 downto 0);
		VOUT       : out std_logic);
end entity IIR_1lookahead;

architecture structural of IIR_1lookahead is

	-----------------------component declaration----------------------------------------------
	component datapath_IIR_1lookahead
		port(
			DIN        : in  std_logic_vector(8 downto 0);
			EN         : in  std_logic;
			C0, C1, C2 : in  std_logic_vector(8 downto 0);
			B0, B1, B2 : in  std_logic_vector(8 downto 0);
			RST_N      : in  std_logic;
			CLK        : in  std_logic;
			DOUT       : out std_logic_vector(8 downto 0)
		);
	end component datapath_IIR_1lookahead;

	component REG_RST_N is
		generic(
			N : positive := 32
		);
		port(
			D     : in  std_logic_vector(N - 1 downto 0);
			RST_N : in  std_logic;
			CLK   : in  std_logic;
			Q     : out std_logic_vector(N - 1 downto 0)
		);
	end component REG_RST_N;

	component flipflop_rst_n
		port(
			D     : in  std_logic;
			clk   : in  std_logic;
			rst_n : in  std_logic;
			Q     : out std_logic
		);
	end component flipflop_rst_n;

	component flip_flop_N_level_rst_n
		generic(N : positive);
		port(
			D     : in  std_logic;
			clk   : in  std_logic;
			rst_n : in  std_logic;
			Q     : out std_logic
		);
	end component flip_flop_N_level_rst_n;

	component reg_en_rst_n
		generic(N : positive := 32);
		port(
			D     : in  std_logic_vector(N - 1 downto 0);
			en    : in  std_logic;
			rst_n : in  std_logic;
			clk   : in  std_logic;
			Q     : out std_logic_vector(N - 1 downto 0)
		);
	end component reg_en_rst_n;

	----------------signals declaration---------------------
	signal DIN_REGIN_DP, DOUT_DP_REGOUT    : std_logic_vector(8 downto 0);
	signal VIN_FROM_REGIN, VIN_FROM_PIPE   : std_logic;
	signal C0_REG_DP, C1_REG_DP, C2_REG_DP : std_logic_vector(8 downto 0);
	signal B0_REG_DP, B1_REG_DP, B2_REG_DP : std_logic_vector(8 downto 0);

	---------------------MAIN-----------------------------
begin

	i_input_register_DIN : component reg_en_rst_n
		generic map(
			N => 9
		)
		port map(
			D     => DIN,
			en    => VIN,
			rst_n => RST_N,
			clk   => CLK,
			Q     => DIN_REGIN_DP
		);

	i_input_register_VIN : component flipflop_rst_n
		port map(
			D     => VIN,
			clk   => CLK,
			rst_n => RST_N,
			Q     => VIN_FROM_REGIN
		);

	i_input_register_C0 : component REG_RST_N
		generic map(
			N => 9
		)
		port map(
			D     => C0,
			RST_N => RST_N,
			CLK   => CLK,
			Q     => C0_REG_DP
		);

	i_input_register_C1 : component REG_RST_N
		generic map(
			N => 9
		)
		port map(
			D     => C1,
			RST_N => RST_N,
			CLK   => CLK,
			Q     => C1_REG_DP
		);

	i_input_register_C2 : component REG_RST_N
		generic map(
			N => 9
		)
		port map(
			D     => C2,
			RST_N => RST_N,
			CLK   => CLK,
			Q     => C2_REG_DP
		);

	i_input_register_B0 : component REG_RST_N
		generic map(
			N => 9
		)
		port map(
			D     => B0,
			RST_N => RST_N,
			CLK   => CLK,
			Q     => B0_REG_DP
		);

	i_input_register_B1 : component REG_RST_N
		generic map(
			N => 9
		)
		port map(
			D     => B1,
			RST_N => RST_N,
			CLK   => CLK,
			Q     => B1_REG_DP
		);

	i_input_register_B2 : component REG_RST_N
		generic map(
			N => 9
		)
		port map(
			D     => B2,
			RST_N => RST_N,
			CLK   => CLK,
			Q     => B2_REG_DP
		);

	i_DP : component datapath_IIR_1lookahead
		port map(
			DIN   => DIN_REGIN_DP,
			EN    => VIN,
			C0    => C0_REG_DP,
			C1    => C1_REG_DP,
			C2    => C2_REG_DP,
			B0    => B0_REG_DP,
			B1    => B1_REG_DP,
			B2    => B2_REG_DP,
			RST_N => RST_N,
			CLK   => CLK,
			DOUT  => DOUT_DP_REGOUT
		);

	i_output_register_DOUT : component REG_RST_N
		generic map(
			N => 9
		)
		port map(
			D     => DOUT_DP_REGOUT,
			RST_N => RST_N,
			CLK   => CLK,
			Q     => DOUT
		);

	i_pipe_register_VOUT : component flip_flop_N_level_rst_n
		generic map(
			N => 2
		)
		port map(
			D     => VIN_FROM_REGIN,
			clk   => CLK,
			rst_n => RST_N,
			Q     => VIN_FROM_PIPE
		);

	i_output_register_VOUT : component flipflop_rst_n
		port map(
			D     => VIN_FROM_PIPE,
			clk   => CLK,
			rst_n => RST_N,
			Q     => VOUT
		);

end architecture structural;
