library ieee;
use ieee.std_logic_1164.all;
use work.ipbus.all;
use work.emp_data_types.all;
use work.emp_device_decl.all;
use work.emp_ttc_decl.all;
use work.emp_slink_types.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.hybrid_data_formats.all;


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


signal clk240: std_logic := '0';
signal clk360: std_logic := '0';

signal in_din: ldata( 4 * N_REGION - 1 downto 0 ) := ( others => nulll );
signal in_dout: t_tracksTB( 0 to tbNumSeedTypes - 1 ) := ( others => nulll );
component tm_isolation_in
port (
  clk240: in std_logic;
  clk360: in std_logic;
  in_din: in ldata( 4 * N_REGION - 1 downto 0 );
  in_dout: out t_tracksTB( 0 to tbNumSeedTypes - 1 )
);
end component;

signal tm_packet: t_packets( 0 to tbNumSeedTypes - 1 ) := ( others => nulll );
signal tm_din: t_tracksTB( 0 to tbNumSeedTypes - 1 );
signal tm_dout: t_trackTM := nulll;
component tm_top
port (
  clk240: in std_logic;
  clk360: in std_logic;
  tm_packet: in t_packets( tbNumSeedTypes - 1 downto 0 );
  tm_din: in t_tracksTB( 0 to tbNumSeedTypes - 1 );
  tm_dout: out t_trackTM
);
end component;

signal out_packet: t_packets( 4 * N_REGION - 1 downto 0 ) := ( others => nulll );
signal out_din: t_trackTM := nulll;
signal out_dout: ldata( 4 * N_REGION - 1 downto 0 ) := ( others => nulll );
component tm_isolation_out
port (
  clk: in std_logic;
  out_packet: in t_packets( 4 * N_REGION - 1 downto 0 );
  out_din: in t_trackTM;
  out_dout: out ldata( 4 * N_REGION - 1 downto 0 )
);
end component;

function convOut( l: ldata ) return t_packets is
  variable s: t_packets( 4 * N_REGION - 1 downto 0 );
begin
  for k in s'range loop
    s( k ).start_of_orbit := l( k ).start_of_orbit;
    s( k ).valid := l( k ).valid;    
  end loop;
  return s;
end;
function convTM( l: ldata ) return t_packets is
  variable s: t_packets( 0 to tbNumSeedTypes - 1 );
begin
  for k in s'range loop
    s( k ).start_of_orbit := l( k ).start_of_orbit;
    s( k ).valid := l( k ).valid;    
  end loop;
  return s;
end;


begin


clk240 <= clk_payload( 0 );
clk360 <= clk_p;

in_din <= d;

tm_packet <= convTM( d );
tm_din <= in_dout;

out_packet <=  convOut( d );
out_din <= tm_dout;

q <= out_dout;

fin: tm_isolation_in port map ( clk240, clk360, in_din, in_dout );

tm: tm_top port map ( clk240, clk360, tm_packet, tm_din, tm_dout );

fout: tm_isolation_out port map ( clk360, out_packet, out_din, out_dout );


ipb_out <= IPB_RBUS_NULL;
bc0 <= '0';
gpio <= (others => '0');
gpio_en <= (others => '0');


end;
