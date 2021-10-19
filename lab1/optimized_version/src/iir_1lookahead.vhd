library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity iir_1lookahead is
	port(
		DIN        : in  std_logic_vector(8 downto 0);
		C0, C1, C2 : in  std_logic_vector(8 downto 0); -- new coefficients due to look-ahead
		B0, B1, B2 : in  std_logic_vector(8 downto 0);
		VIN        : in  std_logic;
		CLK        : in  std_logic;
		RST_N      : in  std_logic;
		DOUT       : out std_logic_vector(8 downto 0);
		VOUT       : out std_logic);
end entity iir_1lookahead;

architecture structural of iir_1lookahead is

begin

end architecture structural;
