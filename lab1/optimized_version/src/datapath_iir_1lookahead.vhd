library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datapath_IIR_1lookahead is
    port(
        DIN        : in  std_logic_vector(8 downto 0); -- input sample
        EN         : in  std_logic;
        C0, C1, C2 : in  std_logic_vector(8 downto 0);
        B0, B1, B2 : in  std_logic_vector(8 downto 0);
        RST_N      : in  std_logic;
        CLK        : in  std_logic;
        DOUT       : out std_logic_vector(8 downto 0)
    );
end entity datapath_IIR_1lookahead;

architecture structural of datapath_IIR_1lookahead is

    component REG_RST_N
        generic(N : positive := 32);
        port(
            D     : in  std_logic_vector(N - 1 downto 0);
            RST_N : in  std_logic;
            CLK   : in  std_logic;
            Q     : out std_logic_vector(N - 1 downto 0)
        );
    end component REG_RST_N;

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

    component reg_N_level_rst_n
        generic(
            M : positive := 5;
            N : positive := 1
        );
        port(
            D     : in  std_logic_vector(M - 1 downto 0);
            clk   : in  std_logic;
            rst_n : in  std_logic;
            Q     : out std_logic_vector(M - 1 downto 0)
        );
    end component reg_N_level_rst_n;

    component reg_N_level_en_rst_n
        generic(
            M : positive := 5;
            N : positive := 1
        );
        port(
            D     : in  std_logic_vector(M - 1 downto 0);
            clk   : in  std_logic;
            en    : in  std_logic;
            rst_n : in  std_logic;
            Q     : out std_logic_vector(M - 1 downto 0)
        );
    end component reg_N_level_en_rst_n;

    component ADDER2_NBIT
        generic(N : positive := 32);
        port(
            ADDER_IN_A  : in  std_logic_vector(N - 1 downto 0);
            ADDER_IN_B  : in  std_logic_vector(N - 1 downto 0);
            ADDER_OUT_S : out std_logic_vector(N - 1 downto 0)
        );
    end component ADDER2_NBIT;

    component ADDER3_NBIT
        generic(N : positive := 32);
        port(
            ADDER_IN_A  : in  std_logic_vector(N - 1 downto 0);
            ADDER_IN_B  : in  std_logic_vector(N - 1 downto 0);
            ADDER_IN_C  : in  std_logic_vector(N - 1 downto 0);
            ADDER_OUT_S : out std_logic_vector(N - 1 downto 0)
        );
    end component ADDER3_NBIT;

    component MULTIPLIER_NBIT
        generic(N : positive := 32);
        port(
            MULTIPLIER_IN_A  : in  std_logic_vector(N - 1 downto 0);
            MULTIPLIER_IN_B  : in  std_logic_vector(N - 1 downto 0);
            MULTIPLIER_OUT_P : out std_logic_vector(2 * N - 1 downto 0)
        );
    end component MULTIPLIER_NBIT;

    -- first forward path signals
    signal P_MULC0_REGC0   : std_logic_vector(17 downto 0);
    signal P_REGC0_ADD0    : std_logic_vector(6 downto 0);
    signal W               : std_logic_vector(9 downto 0);
    -- feedback path signals
    signal W_DELAY_1       : std_logic_vector(9 downto 0);
    signal P_MULC1_REGC1   : std_logic_vector(19 downto 0);
    signal P_REGC1_ADD1    : std_logic_vector(6 downto 0);
    signal P_MULC2_REGC2   : std_logic_vector(19 downto 0);
    signal P_REGC2_ADD1    : std_logic_vector(6 downto 0);
    signal S_ADD1_ADD0     : std_logic_vector(6 downto 0);
    -- second forward path signals
    signal W_PIPE0_MULB0   : std_logic_vector(9 downto 0);
    signal W_PIPE0_MULB1   : std_logic_vector(9 downto 0);
    signal W_PIPE0_MULB2   : std_logic_vector(9 downto 0);
    signal P_MULB0_PIPE1   : std_logic_vector(19 downto 0);
    signal P_MULB1_PIPE1   : std_logic_vector(19 downto 0);
    signal P_MULB2_PIPE1   : std_logic_vector(19 downto 0);
    signal P_PIPE1_B0_ADD2 : std_logic_vector(6 downto 0);
    signal P_PIPE1_B1_ADD2 : std_logic_vector(6 downto 0);
    signal P_PIPE1_B2_ADD2 : std_logic_vector(6 downto 0);
    signal DOUT_DUMMY      : std_logic_vector(6 downto 0);

begin

    -- first forward path components
    i_MULTIPLIER_C0 : component MULTIPLIER_NBIT
        generic map(
            N => 9
        )
        port map(
            MULTIPLIER_IN_A  => DIN,
            MULTIPLIER_IN_B  => C0,
            MULTIPLIER_OUT_P => P_MULC0_REGC0
        );

    i_REG_MUL_C0 : component reg_en_rst_n
        generic map(
            N => 7
        )
        port map(
            D     => P_MULC0_REGC0(16 downto 10),
            en    => EN,
            rst_n => RST_N,
            clk   => CLK,
            Q     => P_REGC0_ADD0
        );

    i_ADDER_0 : component ADDER3_NBIT
        generic map(
            N => 10
        )
        port map(
            ADDER_IN_A(9)          => P_REGC0_ADD0(6),
            ADDER_IN_A(8 downto 2) => P_REGC0_ADD0,
            ADDER_IN_A(1 downto 0) => "00",
            ADDER_IN_B(9)          => DIN(8),
            ADDER_IN_B(8 downto 0) => DIN,
            ADDER_IN_C(9)          => S_ADD1_ADD0(6),
            ADDER_IN_C(8 downto 2) => S_ADD1_ADD0,
            ADDER_IN_C(1 downto 0) => "00",
            ADDER_OUT_S            => W
        );

    -- feedback path signals
    i_REG_DEL_1 : component reg_en_rst_n
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

    i_MULTIPLIER_C1 : component MULTIPLIER_NBIT
        generic map(
            N => 10
        )
        port map(
            MULTIPLIER_IN_A             => W_DELAY_1,
            MULTIPLIER_IN_B(9)          => C1(8),
            MULTIPLIER_IN_B(8 downto 0) => C1,
            MULTIPLIER_OUT_P            => P_MULC1_REGC1
        );

    i_REG_MUL_C1 : component reg_en_rst_n
        generic map(
            N => 7
        )
        port map(
            D     => P_MULC1_REGC1(16 downto 10),
            en    => EN,
            rst_n => RST_N,
            clk   => CLK,
            Q     => P_REGC1_ADD1
        );

    i_MULTIPLIER_C2 : component MULTIPLIER_NBIT
        generic map(
            N => 10
        )
        port map(
            MULTIPLIER_IN_A             => W_DELAY_1,
            MULTIPLIER_IN_B(9)          => C2(8),
            MULTIPLIER_IN_B(8 downto 0) => C2,
            MULTIPLIER_OUT_P            => P_MULC2_REGC2
        );

    i_REG_MUL_C2 : component reg_N_level_en_rst_n
        generic map(
            M => 7,
            N => 2
        )
        port map(
            D     => P_MULC2_REGC2(16 downto 10),
            clk   => CLK,
            en    => EN,
            rst_n => RST_N,
            Q     => P_REGC2_ADD1
        );

    i_ADDER_1 : component ADDER2_NBIT
        generic map(
            N => 7
        )
        port map(
            ADDER_IN_A  => P_REGC1_ADD1,
            ADDER_IN_B  => P_REGC2_ADD1,
            ADDER_OUT_S => S_ADD1_ADD0
        );

    -- second forward path signals
    i_REG_PIPE0_B0 : component REG_RST_N
        generic map(
            N => 10
        )
        port map(
            D     => W,
            RST_N => RST_N,
            CLK   => CLK,
            Q     => W_PIPE0_MULB0
        );

    i_MULTIPLIER_B0 : component MULTIPLIER_NBIT
        generic map(
            N => 10
        )
        port map(
            MULTIPLIER_IN_A             => W_PIPE0_MULB0,
            MULTIPLIER_IN_B(9)          => B0(8),
            MULTIPLIER_IN_B(8 downto 0) => B0,
            MULTIPLIER_OUT_P            => P_MULB0_PIPE1
        );

    i_REG_PIPE1_B0 : component REG_RST_N
        generic map(
            N => 7
        )
        port map(
            D     => P_MULB0_PIPE1(16 downto 10),
            RST_N => RST_N,
            CLK   => CLK,
            Q     => P_PIPE1_B0_ADD2
        );

    i_REG_PIPE0_B1 : component REG_RST_N
        generic map(
            N => 10
        )
        port map(
            D     => W_DELAY_1,
            RST_N => RST_N,
            CLK   => CLK,
            Q     => W_PIPE0_MULB1
        );

    i_MULTIPLIER_B1 : component MULTIPLIER_NBIT
        generic map(
            N => 10
        )
        port map(
            MULTIPLIER_IN_A             => W_PIPE0_MULB1,
            MULTIPLIER_IN_B(9)          => B1(8),
            MULTIPLIER_IN_B(8 downto 0) => B1,
            MULTIPLIER_OUT_P            => P_MULB1_PIPE1
        );

    i_REG_PIPE1_B1 : component REG_RST_N
        generic map(
            N => 7
        )
        port map(
            D     => P_MULB1_PIPE1(16 downto 10),
            RST_N => RST_N,
            CLK   => CLK,
            Q     => P_PIPE1_B1_ADD2
        );

    i_REG_PIPE0_B2 : component REG_RST_N
        generic map(
            N => 10
        )
        port map(
            D     => W_DELAY_1,
            RST_N => RST_N,
            CLK   => CLK,
            Q     => W_PIPE0_MULB2
        );

    i_MULTIPLIER_B2 : component MULTIPLIER_NBIT
        generic map(
            N => 10
        )
        port map(
            MULTIPLIER_IN_A             => W_PIPE0_MULB2,
            MULTIPLIER_IN_B(9)          => B2(8),
            MULTIPLIER_IN_B(8 downto 0) => B2,
            MULTIPLIER_OUT_P            => P_MULB2_PIPE1
        );

    i_REG_PIPE1_B2 : component reg_N_level_rst_n
        generic map(
            M => 7,
            N => 2
        )
        port map(
            D     => P_MULB2_PIPE1(16 downto 10),
            clk   => CLK,
            rst_n => RST_N,
            Q     => P_PIPE1_B2_ADD2
        );

    i_ADDER_2 : component ADDER3_NBIT
        generic map(
            N => 7
        )
        port map(
            ADDER_IN_A  => P_PIPE1_B0_ADD2,
            ADDER_IN_B  => P_PIPE1_B1_ADD2,
            ADDER_IN_C  => P_PIPE1_B2_ADD2,
            ADDER_OUT_S => DOUT_DUMMY
        );

    DOUT <= DOUT_DUMMY & "00";

end architecture structural;
