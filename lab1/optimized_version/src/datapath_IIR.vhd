---------------------------------------------------------------------------------------------
-- Project: IIR filter
-- Author: Group 04
-- Date: October 2021
-- File: datapath_IIR.vhd
-- Design: IIR
---------------------------------------------------------------------------------------------
-- Description: datapath IIR filter
----------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DATAPATH_IIR is
	port(
		DIN            : in  std_logic_vector(8 downto 0); -- input sample
		EN             : in  std_logic;
		A1_2COMPLEMENT : in  std_logic_vector(8 downto 0); -- WARNING! YOU HAVE TO PASS -a1
		A2_2COMPLEMENT : in  std_logic_vector(8 downto 0); -- WARNING! YOU HAVE TO PASS -a2
		B0             : in  std_logic_vector(8 downto 0);
		B1             : in  std_logic_vector(8 downto 0);
		B2             : in  std_logic_vector(8 downto 0);
		RST_N          : in  std_logic;
		CLK            : in  std_logic;
		DOUT           : out std_logic_vector(8 downto 0)
	);
end DATAPATH_IIR;

architecture STRUCTURAL of DATAPATH_IIR is

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

	component ADDER_NBIT
		generic(N : positive := 32);
		port(
			ADDER_IN_A  : in  std_logic_vector(N - 1 downto 0);
			ADDER_IN_B  : in  std_logic_vector(N - 1 downto 0);
			ADDER_OUT_S : out std_logic_vector(N - 1 downto 0)
		);
	end component ADDER_NBIT;

	component MULTIPLIER_NBIT
		generic(N : positive := 32);
		port(
			MULTIPLIER_IN_A  : in  std_logic_vector(N - 1 downto 0);
			MULTIPLIER_IN_B  : in  std_logic_vector(N - 1 downto 0);
			MULTIPLIER_OUT_P : out std_logic_vector(2 * N - 1 downto 0)
		);
	end component MULTIPLIER_NBIT;

	signal W            : std_logic_vector(9 downto 0);
	signal W_DELAY_1    : std_logic_vector(9 downto 0);
	signal W_DELAY_2    : std_logic_vector(9 downto 0);
	signal P_MULB0_ADD3 : std_logic_vector(19 downto 0);
	signal P_MULB1_ADD2 : std_logic_vector(19 downto 0);
	signal P_MULB2_ADD2 : std_logic_vector(19 downto 0);
	signal P_MULA1_ADD1 : std_logic_vector(19 downto 0);
	signal P_MULA2_ADD1 : std_logic_vector(19 downto 0);
	signal S_ADD2_ADD3  : std_logic_vector(7 downto 0);
	signal S_ADD1_ADD0  : std_logic_vector(7 downto 0);
	signal DOUT_DUMMY   : std_logic_vector(7 downto 0);

begin

	i_ADDER_0 : component ADDER_NBIT
		generic map(
			N => 10
		)
		port map(
			ADDER_IN_A(9)          => DIN(8),
			ADDER_IN_A(8 downto 0) => DIN,
			ADDER_IN_B(9 downto 2) => S_ADD1_ADD0,
			ADDER_IN_B(1 downto 0) => "00",
			ADDER_OUT_S            => W
		);

	-- first register delay line    
	i_reg_0 : reg_en_rst_n
		generic map(
			N => 10
		)
		port map(
			D     => W,
			en    => EN,
			rst_n => RST_N,
			clk   => CLK,
			Q     => W_DELAY_1
		);

	-- second register delay line    
	i_reg_1 : reg_en_rst_n
		generic map(
			N => 10
		)
		port map(
			D     => W_DELAY_1,
			en    => EN,
			rst_n => RST_N,
			clk   => CLK,
			Q     => W_DELAY_2
		);

	-- multiplication by coefficient a1
	i_MULTIPLIER_A1 : MULTIPLIER_NBIT
		generic map(
			N => 10
		)
		port map(
			MULTIPLIER_IN_A             => W_DELAY_1,
			MULTIPLIER_IN_B(9)          => A1_2COMPLEMENT(8),
			MULTIPLIER_IN_B(8 downto 0) => A1_2COMPLEMENT,
			MULTIPLIER_OUT_P            => P_MULA1_ADD1
		);

	-- multiplication by coefficient a2
	i_MULTIPLIER_A2 : MULTIPLIER_NBIT
		generic map(
			N => 10
		)
		port map(
			MULTIPLIER_IN_A             => W_DELAY_2,
			MULTIPLIER_IN_B(9)          => A2_2COMPLEMENT(8),
			MULTIPLIER_IN_B(8 downto 0) => A2_2COMPLEMENT,
			MULTIPLIER_OUT_P            => P_MULA2_ADD1
		);

	-- fb
	i_ADDER_1 : ADDER_NBIT
		generic map(
			N => 8
		)
		port map(
			ADDER_IN_A  => P_MULA1_ADD1(17 downto 10),
			ADDER_IN_B  => P_MULA2_ADD1(17 downto 10),
			ADDER_OUT_S => S_ADD1_ADD0
		);

	-- multiplication by coefficient b0
	i_MULTIPLIER_B0 : MULTIPLIER_NBIT
		generic map(
			N => 10
		)
		port map(
			MULTIPLIER_IN_A             => W,
			MULTIPLIER_IN_B(9)          => B0(8),
			MULTIPLIER_IN_B(8 downto 0) => B0,
			MULTIPLIER_OUT_P            => P_MULB0_ADD3
		);

	-- multiplication by coefficient b1
	i_MULTIPLIER_B1 : MULTIPLIER_NBIT
		generic map(
			N => 10
		)
		port map(
			MULTIPLIER_IN_A             => W_DELAY_1,
			MULTIPLIER_IN_B(9)          => B1(8),
			MULTIPLIER_IN_B(8 downto 0) => B1,
			MULTIPLIER_OUT_P            => P_MULB1_ADD2
		);

	-- multiplication by coefficient b2
	i_MULTIPLIER_B2 : MULTIPLIER_NBIT
		generic map(
			N => 10
		)
		port map(
			MULTIPLIER_IN_A             => W_DELAY_2,
			MULTIPLIER_IN_B(9)          => B2(8),
			MULTIPLIER_IN_B(8 downto 0) => B2,
			MULTIPLIER_OUT_P            => P_MULB2_ADD2
		);

	-- ff
	i_ADDER_2 : ADDER_NBIT
		generic map(
			N => 8
		)
		port map(
			ADDER_IN_A  => P_MULB1_ADD2(17 downto 10),
			ADDER_IN_B  => P_MULB2_ADD2(17 downto 10),
			ADDER_OUT_S => S_ADD2_ADD3
		);

	-- w*b0 + ff
	i_ADDER_3 : ADDER_NBIT
		generic map(
			N => 8
		)
		port map(
			ADDER_IN_A  => P_MULB0_ADD3(17 downto 10),
			ADDER_IN_B  => S_ADD2_ADD3,
			ADDER_OUT_S => DOUT_DUMMY
		);

	DOUT <= DOUT_DUMMY(6 downto 0) & "00";

end STRUCTURAL;
