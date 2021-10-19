---------------------------------------------------------------------------------------------
-- Project: IIR filter
-- Author: Group 04
-- Date: October 2021
-- File: IIR.vhd
-- Design: behavioural
---------------------------------------------------------------------------------------------
-- Description: This is the top-level entity of an IIR filter of the II order, working
--on 9 bit.
----------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity IIR is
    port(
        DIN        : in  std_logic_vector(8 downto 0);
        A1, A2     : in  std_logic_vector(8 downto 0);
        B0, B1, B2 : in  std_logic_vector(8 downto 0);
        VIN        : in  std_logic;
        CLK        : in  std_logic;
        RST_N      : in  std_logic;
        DOUT       : out std_logic_vector(8 downto 0);
        VOUT       : out std_logic);
end entity IIR;

architecture structural of IIR is

    -----------------------component declaration----------------------------------------------
    component two_complement_Nbit
        generic(N : positive := 32);
        port(
            TWO_COMPLEMENT_IN  : in  std_logic_vector(N - 1 downto 0);
            TWO_COMPLEMENT_OUT : out std_logic_vector(N - 1 downto 0)
        );
    end component two_complement_Nbit;

    component DATAPATH_IIR
        port(
            DIN            : in  std_logic_vector(8 downto 0);
            EN             : in  std_logic;
            A1_2COMPLEMENT : in  std_logic_vector(8 downto 0);
            A2_2COMPLEMENT : in  std_logic_vector(8 downto 0);
            B0             : in  std_logic_vector(8 downto 0);
            B1             : in  std_logic_vector(8 downto 0);
            B2             : in  std_logic_vector(8 downto 0);
            RST_N          : in  std_logic;
            CLK            : in  std_logic;
            DOUT           : out std_logic_vector(8 downto 0)
        );
    end component DATAPATH_IIR;

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
    signal DIN_REGIN_DP, DOUT_DP_REGOUT                 : std_logic_vector(8 downto 0);
    signal VIN_FROM_REGIN                               : std_logic;
    signal A1_2COMPLEMENT, A2_2COMPLEMENT               : std_logic_vector(8 downto 0);
    signal A1_2COMPLEMENT_REG_DP, A2_2COMPLEMENT_REG_DP : std_logic_vector(8 downto 0);
    signal B0_REG_DP, B1_REG_DP, B2_REG_DP              : std_logic_vector(8 downto 0);

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

    i_two_complement_A1 : component two_complement_Nbit
        generic map(
            N => 9
        )
        port map(
            TWO_COMPLEMENT_IN  => A1,
            TWO_COMPLEMENT_OUT => A1_2COMPLEMENT
        );

    i_two_complement_A2 : component two_complement_Nbit
        generic map(
            N => 9
        )
        port map(
            TWO_COMPLEMENT_IN  => A2,
            TWO_COMPLEMENT_OUT => A2_2COMPLEMENT
        );

    i_input_register_A1 : component REG_RST_N
        generic map(
            N => 9
        )
        port map(
            D     => A1_2COMPLEMENT,
            RST_N => RST_N,
            CLK   => CLK,
            Q     => A1_2COMPLEMENT_REG_DP
        );

    i_input_register_A2 : component REG_RST_N
        generic map(
            N => 9
        )
        port map(
            D     => A2_2COMPLEMENT,
            RST_N => RST_N,
            CLK   => CLK,
            Q     => A2_2COMPLEMENT_REG_DP
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

    i_DP : component DATAPATH_IIR
        port map(
            DIN            => DIN_REGIN_DP,
            EN             => VIN,
            A1_2COMPLEMENT => A1_2COMPLEMENT_REG_DP,
            A2_2COMPLEMENT => A2_2COMPLEMENT_REG_DP,
            B0             => B0_REG_DP,
            B1             => B1_REG_DP,
            B2             => B2_REG_DP,
            RST_N          => RST_N,
            CLK            => CLK,
            DOUT           => DOUT_DP_REGOUT
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

    i_output_register_VOUT : component flipflop_rst_n
        port map(
            D     => VIN_FROM_REGIN,
            clk   => CLK,
            rst_n => RST_N,
            Q     => VOUT
        );

end architecture structural;
