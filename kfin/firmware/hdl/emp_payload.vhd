library ieee;
use ieee.std_logic_1164.all;
use work.ipbus.all;
use work.emp_data_types.all;
use work.emp_device_decl.all;
use work.emp_ttc_decl.all;

use work.hybrid_config.all;
use work.hybrid_data_types.all;


entity emp_payload is
port (
  clk: in std_logic;
  rst: in std_logic;
  ipb_in: in ipb_wbus;
  clk_payload: in std_logic_vector( 2 downto 0 );
  rst_payload: in std_logic_vector( 2 downto 0 );
  clk_p: in std_logic;
  rst_loc: in std_logic_vector( N_REGION - 1 downto 0 );
  clken_loc: in std_logic_vector( N_REGION - 1 downto 0 );
  ctrs: in ttc_stuff_array;
  d: in ldata( 4 * N_REGION - 1 downto 0 );
  ipb_out: out ipb_rbus;
  bc0: out std_logic;
  q: out ldata( 4 * N_REGION - 1 downto 0 );
  gpio: out std_logic_vector( 29 downto 0 );
  gpio_en: out std_logic_vector( 29 downto 0 )
);
end;


architecture rtl of emp_payload is


signal in_din: ldata( 4 * N_REGION - 1 downto 0 ) := ( others => ( ( others => '0' ), '0', '0', '1' ) );
signal in_dout: t_channlesTB( numSeedTypes - 1 downto 0 ) := ( others => nulll );
component kfin_isolation_in
port (
  clk: in std_logic;
  in_din: in ldata( 4 * N_REGION - 1 downto 0 );
  in_dout: out t_channlesTB( numSeedTypes - 1 downto 0 )
);
end component;

signal kfin_din: t_channlesTB( numSeedTypes - 1 downto 0 ) := ( others => nulll );
signal kfin_dout: t_channelsZHT( numSeedTypes - 1 downto 0 ) := ( others => nulll );
component kfin_top
port (
  clk: in std_logic;
  kfin_din: in t_channlesTB( numSeedTypes - 1 downto 0 );
  kfin_dout: out t_channelsZHT( numSeedTypes - 1 downto 0 )
);
end component;

signal out_packet: std_logic := '0';
signal out_din: t_channelsZHT( numSeedTypes - 1 downto 0 ) := ( others => nulll );
signal out_dout: ldata( 4 * N_REGION - 1 downto 0 ) := ( others => ( ( others => '0' ), '0', '0', '1' ) );
component kfin_isolation_out
port (
  clk: in std_logic;
  out_packet: in std_logic;
  out_din: in t_channelsZHT( numSeedTypes - 1 downto 0 );
  out_dout: out ldata( 4 * N_REGION - 1 downto 0 )
);
end component;


begin


in_din <= d;

kfin_din <= in_dout;

out_packet <=  d( 0 ).valid;
out_din <= kfin_dout;

q <= out_dout;

fin: kfin_isolation_in port map ( clk_p, in_din, in_dout );

kfin: kfin_top port map ( clk_p, kfin_din, kfin_dout );

fout: kfin_isolation_out port map ( clk_p, out_packet, out_din, out_dout );


ipb_out <= IPB_RBUS_NULL;
bc0 <= '0';
gpio <= (others => '0');
gpio_en <= (others => '0');


end;
