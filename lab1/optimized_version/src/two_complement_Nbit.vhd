---------------------------------------------------------------------------------------------
-- Project: IIR filter
-- Author: Group 04
-- Date: October 2021
-- File: adder_Nbit.vhd
-- Design: IIR
---------------------------------------------------------------------------------------------
-- Description: N bit adder (behavioral)
----------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity two_complement_Nbit is
	generic(N : positive := 32);
	port(
		TWO_COMPLEMENT_IN  : in  std_logic_vector(N - 1 downto 0);
		TWO_COMPLEMENT_OUT : out std_logic_vector(N - 1 downto 0)
	);
end two_complement_Nbit;

architecture RTL of two_complement_Nbit is

	component ADDER_NBIT
		generic(N : positive := 32);
		port(
			ADDER_IN_A  : in  std_logic_vector(N - 1 downto 0);
			ADDER_IN_B  : in  std_logic_vector(N - 1 downto 0);
			ADDER_OUT_S : out std_logic_vector(N - 1 downto 0)
		);
	end component ADDER_NBIT;

	signal IN_NOT : std_logic_vector(N - 1 downto 0);

begin

	IN_NOT <= not (TWO_COMPLEMENT_IN);

	i_adder : component ADDER_NBIT
		generic map(
			N => N
		)
		port map(
			ADDER_IN_A  => IN_NOT,
			ADDER_IN_B  => std_logic_vector(to_signed(1, N)),
			ADDER_OUT_S => TWO_COMPLEMENT_OUT
		);

end RTL;

