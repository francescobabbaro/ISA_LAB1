library verilog;
use verilog.vl_types.all;
entity IIR_1lookahead is
    port(
        DIN             : in     vl_logic_vector(8 downto 0);
        C0              : in     vl_logic_vector(8 downto 0);
        C1              : in     vl_logic_vector(8 downto 0);
        C2              : in     vl_logic_vector(8 downto 0);
        B0              : in     vl_logic_vector(8 downto 0);
        B1              : in     vl_logic_vector(8 downto 0);
        B2              : in     vl_logic_vector(8 downto 0);
        VIN             : in     vl_logic;
        CLK             : in     vl_logic;
        RST_N           : in     vl_logic;
        DOUT            : out    vl_logic_vector(8 downto 0);
        VOUT            : out    vl_logic
    );
end IIR_1lookahead;
