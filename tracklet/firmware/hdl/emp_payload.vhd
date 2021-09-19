library ieee;
use ieee.std_logic_1164.all;
use work.ipbus.all;
use work.emp_data_types.all;
use work.emp_device_decl.all;
use work.emp_ttc_decl.all;

use work.hybrid_config.all;
use work.hybrid_tools.all;
use work.hybrid_data_types.all;
use work.tracklet_config.all;
use work.tracklet_data_types.all;


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


signal in_ttc: ttc_stuff_array( N_REGION - 1 downto 0 ) := ( others => TTC_STUFF_NULL );
signal in_din: ldata( 4 * N_REGION - 1 downto 0 ) := ( others => ( ( others => '0' ), '0', '0', '1' ) );
signal in_reset: t_resets( numQuads - 1 downto 0 ) := ( others => nulll );
signal in_dout: t_stubsDTC := nulll;
component hybrid_format_in
port (
  clk: in std_logic;
  in_ttc: in ttc_stuff_array( N_REGION - 1 downto 0 );
  in_din: in ldata( 4 * N_REGION - 1 downto 0 );
  in_reset: out t_resets( numQuads - 1 downto 0 );
  in_dout: out t_stubsDTC
);
end component;

signal tracklet_reset: t_resets( numQuads - 1 downto 0 ) := ( others => nulll );
signal tracklet_din: t_stubsDTC := nulll;
signal tracklet_dout: t_candTracklet := nulll;
component hybrid_tracklet
port (
  clk: in std_logic;
  tracklet_reset: in t_resets( numQuads - 1 downto 0 );
  tracklet_din: in t_stubsDTC;
  tracklet_dout: out t_candTracklet
);
end component;

signal out_packet: std_logic_vector( numLinksTracklet - 1 downto 0 ) := ( others => '0' );
signal out_din: t_candTracklet := nulll;
signal out_dout: ldata( 4 * N_REGION - 1 downto 0 ) := ( others => ( ( others => '0' ), '0', '0', '1' ) );
component hybrid_format_out
port (
  clk: in std_logic;
  out_packet: in std_logic_vector( numLinksTracklet - 1 downto 0 );
  out_din: in t_candTracklet;
  out_dout: out ldata( 4 * N_REGION - 1 downto 0 )
);
end component;

function conv( l: ldata ) return std_logic_vector is
  variable s: std_logic_vector( numLinksTracklet - 1 downto 0 );
begin
  for k in s'range loop
    s( k ) := l( k ).valid;    
  end loop;
  return s;
end;


begin


in_ttc <= ctrs;
in_din <= d;

tracklet_reset <= in_reset;
tracklet_din <= in_dout;

out_packet <=  conv( d );
out_din <= tracklet_dout;

q <= out_dout;

fin: hybrid_format_in port map ( clk_p, in_ttc, in_din, in_reset, in_dout );

tracklet: hybrid_tracklet port map ( clk_p, tracklet_reset, tracklet_din, tracklet_dout );

fout: hybrid_format_out port map ( clk_p, out_packet, out_din, out_dout );


ipb_out <= IPB_RBUS_NULL;
bc0 <= '0';
gpio <= (others => '0');
gpio_en <= (others => '0');


end;
