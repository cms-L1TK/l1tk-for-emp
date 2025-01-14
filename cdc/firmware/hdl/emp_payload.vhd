library ieee;
use ieee.std_logic_1164.all;
use work.ipbus.all;
use work.emp_data_types.all;
use work.emp_device_decl.all;
use work.emp_ttc_decl.all;
use work.emp_slink_types.all;
use work.hybrid_data_types.all;

library UNISIM;
use UNISIM.Vcomponents.all;


entity emp_payload is
port (
  clk: in std_logic;
  rst: in std_logic;
  ipb_in: in ipb_wbus;
  clk40: in std_logic;
  clk_payload: in std_logic_vector( 2 downto 0 );
  rst_payload: in std_logic_vector( 2 downto 0 );
  clk_p: in std_logic;
  rst_loc: in std_logic_vector( N_REGION - 1 downto 0 );
  clken_loc: in std_logic_vector( N_REGION - 1 downto 0 );
  ctrs: in ttc_stuff_array( N_REGION - 1 downto 0 );
  d: in ldata( 4 * N_REGION - 1 downto 0 );
  backpressure: in std_logic_vector( SLINK_MAX_QUADS - 1 downto 0 );
  ipb_out: out ipb_rbus;
  bc0: out std_logic;
  q: out ldata( 4 * N_REGION - 1 downto 0 );
  gpio: out std_logic_vector( 29 downto 0 );
  gpio_en: out std_logic_vector( 29 downto 0 );
  slink_q: out slink_input_data_quad_array( SLINK_MAX_QUADS - 1 downto 0 )
);
end;


architecture rtl of emp_payload is


signal mmcm_clkin1: std_logic := '0';
signal mmcm_clkfbin: std_logic := '0';
signal mmcm_rst: std_logic := '0';
signal mmcm_pwrdwn: std_logic := '0';
signal mmcm_clkfbout: std_logic := '0';
signal mmcm_clkfboutb: std_logic := '0';
signal mmcm_clkout0: std_logic := '0';
signal mmcm_clkout1: std_logic := '0';
signal mmcm_locked: std_logic := '0';
component MMCME4_BASE
generic (
  CLKIN1_PERIOD: real := 25.0;
  DIVCLK_DIVIDE: integer := 1;
  CLKFBOUT_MULT_F: real := 36.0;
  CLKOUT0_DIVIDE_F: real := 4.0;
  CLKOUT1_DIVIDE: integer := 6
);
port (
  clkin1: in std_logic;
  clkfbin: in std_logic;
  rst: in std_logic;
  pwrdwn: in std_logic;
  clkfbout: out std_logic;
  clkfboutb: out std_logic;
  clkout0: out std_logic;
  clkout1: out std_logic;
  clkout2: out std_logic;
  clkout3: out std_logic;
  clkout4: out std_logic;
  clkout5: out std_logic;
  clkout6: out std_logic;
  clkout0b: out std_logic;
  clkout1b: out std_logic;
  clkout2b: out std_logic;
  clkout3b: out std_logic;
  --clkout: out std_logic_vector( 0 to 6 );
  --clkoutb: out std_logic_vector( 0 to 3 );
  locked: out std_logic
);
end component;

signal bufgFB_i: std_logic := '0';
signal bufgFB_o: std_logic := '0';
signal bufg360_i: std_logic := '0';
signal bufg360_o: std_logic := '0';
signal bufg240_i: std_logic := '0';
signal bufg240_o: std_logic := '0';
component BUFG
port (
  i: in std_logic;
  o: out std_logic
);
end component;

signal clk360: std_logic := '0';
signal clk240: std_logic := '0';
signal cdc_din: ldata( 4 * N_REGION - 1 downto 0 ) := ( others => nulll );
signal cdc_dout: ldata( 4 * N_REGION - 1 downto 0 ) := ( others => nulll );
component cdc_top
port (
  clk360: in std_logic;
  clk240: in std_logic;
  cdc_din: in ldata( 4 * N_REGION - 1 downto 0 );
  cdc_dout: out ldata( 4 * N_REGION - 1 downto 0 )
);
end component;


begin


mmcm_clkin1 <= clk40;

bufgFB_i <= mmcm_clkfbout;
mmcm_clkfbin <= bufgFB_o;

bufg360_i <= mmcm_clkout0;
clk360 <= bufg360_o;

bufg240_i <= mmcm_clkout1;
clk240 <= bufg240_o;

process ( clk360 ) is begin if rising_edge( clk360 ) then
cdc_din <= d;
q <= cdc_dout;
end if; end process;

cMMCM: MMCME4_BASE port map ( mmcm_clkin1, mmcm_clkfbin, mmcm_rst, mmcm_pwrdwn, mmcm_clkfbout, mmcm_clkfboutb, mmcm_clkout0, mmcm_clkout1, mmcm_locked );

cBufGFB: BUFG port map ( bufgFB_i, bufgFB_o );

cBufG360: BUFG port map ( bufg360_i, bufg360_o );

cBufG240: BUFG port map ( bufg240_i, bufg240_o );

cdc: cdc_top port map ( clk360, clk240, cdc_din, cdc_dout );


ipb_out <= IPB_RBUS_NULL;
bc0 <= '0';
gpio <= (others => '0');
gpio_en <= (others => '0');


end;
