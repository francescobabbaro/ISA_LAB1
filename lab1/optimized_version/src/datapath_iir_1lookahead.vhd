library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datapath_iir_1lookahead is
	port(
		DIN        : in  std_logic_vector(8 downto 0); -- input sample
		EN         : in  std_logic;
		C0, C1, C2 : in  std_logic_vector(8 downto 0);
		B0, B1, B2 : in  std_logic_vector(8 downto 0);
		RST_N      : in  std_logic;
		CLK        : in  std_logic;
		DOUT       : out std_logic_vector(8 downto 0)
	);
end entity datapath_iir_1lookahead;

architecture structural of datapath_iir_1lookahead is

begin

end architecture structural;
