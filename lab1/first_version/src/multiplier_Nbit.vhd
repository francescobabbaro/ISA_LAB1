---------------------------------------------------------------------------------------------
-- Project: IIR filter
-- Author: Group 04
-- Date: October 2021
-- File: multiplier_Nbit.vhd
-- Design: IIR
---------------------------------------------------------------------------------------------
-- Description: N bit multiplier (behavioral)
----------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MULTIPLIER_NBIT is
    generic(N : positive := 32);
    port(
        MULTIPLIER_IN_A  : in  std_logic_vector(N - 1 downto 0);
        MULTIPLIER_IN_B  : in  std_logic_vector(N - 1 downto 0);
        MULTIPLIER_OUT_P : out std_logic_vector(2 * N - 1 downto 0)
    );
end MULTIPLIER_NBIT;

architecture BEHAVIORAL of MULTIPLIER_NBIT is

begin

    MULTIPLIER_OUT_P <= std_logic_vector(signed(MULTIPLIER_IN_A) * signed(MULTIPLIER_IN_B));

end BEHAVIORAL;
