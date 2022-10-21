library ieee;
use ieee.std_logic_1164.all;
use work.ipbus.all;
use work.emp_data_types.all;
use work.emp_device_decl.all;
use work.emp_ttc_decl.all;
use work.emp_slink_types.all;

use work.hybrid_config.all;
use work.hybrid_data_types.all;


entity emp_payload is
  port (
    clk: in std_logic;
    rst: in std_logic;
    ipb_in: in ipb_wbus;
    clk_payload: in std_logic_vector( 2 downto 0 );
    rst_payload: in std_logic_vector( 2 downto 0 );
    clk40: in  std_logic;
    clk_p: in std_logic;
    rst_loc: in std_logic_vector( N_REGION - 1 downto 0 );
    clken_loc: in std_logic_vector( N_REGION - 1 downto 0 );
    ctrs: in ttc_stuff_array;
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


--signal d_mapped : ldata( numInputLinks - 1 downto 0);   -- mapped data in
--signal q_mapped : ldata( numLinksTFP - 1 downto 0);  -- mapped data out

signal in_ttc: ttc_stuff_array( N_REGION - 1 downto 0 ) := ( others => TTC_STUFF_NULL );
signal in_din: ldata( 4 * N_REGION - 1 downto 0 ) := ( others => nulll );
signal in_reset: t_resets( numPPquads - 1 downto 0 ) := ( others => nulll );
signal in_dout: t_stubsDTC := nulll;
component tracklet_isolation_in
port (
  clk: in std_logic;
  in_ttc: in ttc_stuff_array( N_REGION - 1 downto 0 );
  in_din: in ldata( 4 * N_REGION - 1 downto 0 );
  in_reset: out t_resets( numPPquads - 1 downto 0 );
  in_dout: out t_stubsDTC
);
end component;

signal tracklet_reset: t_resets( numPPquads - 1 downto 0 ) := ( others => nulll );
signal tracklet_din: t_stubsDTC := nulll;
signal tracklet_dout: t_channlesTB( numSeedTypes - 1 downto 0 ) := ( others => nulll );
component tracklet_top
port (
  clk: in std_logic;
  tracklet_reset: in t_resets( numPPquads - 1 downto 0 );
  tracklet_din: in t_stubsDTC;
  tracklet_dout: out t_channlesTB( numSeedTypes - 1 downto 0 )
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

signal kf_din: t_channelsZHT( numNodesKF - 1 downto 0 ) := ( others => nulll );
signal kf_dout: t_channelsKF( numNodesKF - 1 downto 0 ) := ( others => nulll );
component kf_top
port (
  clk: in std_logic;
  kf_din: in t_channelsZHT( numNodesKF - 1 downto 0 );
  kf_dout: out t_channelsKF( numNodesKF - 1 downto 0 )
);
end component;

signal kfout_din: t_channelsKF( numNodesKF - 1 downto 0 ) := ( others => nulll );
signal kfout_dout: t_frames( numLinksTFP - 1 downto 0 ) := ( others => ( others => '0' ) );
component kfout_top
  port(
    clk: in std_logic;
    kfout_din: in t_channelsKF( numNodesKF - 1 downto 0 );
    kfout_dout: out t_frames( numLinksTFP - 1 downto 0 )
  );
end component;

signal out_packet: t_packets( numLinksTFP - 1 downto 0 ) := ( others => ( others => '0' ) );
signal out_din: t_frames( numLinksTFP - 1 downto 0 ) := ( others => ( others => '0' ) );
signal out_dout: ldata( numLinksTFP - 1 downto 0 ) := ( others => nulll );
component kfout_isolation_out
port (
    clk: in std_logic;
    out_packet: in t_packets( numLinksTFP - 1 downto 0 );
    out_din: in t_frames( numLinksTFP - 1 downto 0 );
    out_dout: out ldata( numLinksTFP - 1 downto 0 )
);
end component;

function conv( l: ldata ) return t_packets is
    variable s: t_packets( numLinksTFP - 1 downto 0 );
begin
    for k in s'range loop
        s( k ).valid := l( k ).valid;
        s( k ).start_of_orbit := l( k ).start_of_orbit;
    end loop;
    return s;
end;

begin

-- LinkMapInstance : entity work.link_map
--   port map(
--     d        => d,
--     d_mapped => d_mapped,
--     q_mapped => q_mapped,
--     q        => q
-- );

in_ttc <= ctrs;
in_din <= d;

tracklet_reset <= in_reset;
tracklet_din <= in_dout;

kfin_din <= tracklet_dout;

kf_din <= kfin_dout;
kfout_din <= kf_dout;

out_packet <=  conv( d );
out_din <= kfout_dout;


q(0) <= out_dout(0);
q(1) <= out_dout(1);
q(0) <= out_dout(0);
q(1) <= out_dout(1);
q(0).strobe <= '1';
q(0).start  <= '0';
q(1).strobe <= '1';
q(1).start  <= '0';


fin: tracklet_isolation_in port map ( clk_p, in_ttc, in_din, in_reset, in_dout );

tracklet: tracklet_top port map ( clk_p, tracklet_reset, tracklet_din, tracklet_dout );

kfin: kfin_top port map ( clk_p, kfin_din, kfin_dout );

kf: kf_top port map ( clk_p, kf_din, kf_dout );

kfout: kfout_top port map ( clk_p, kfout_din, kfout_dout);

fout: kfout_isolation_out port map ( clk_p, out_packet, out_din, out_dout );


ipb_out <= IPB_RBUS_NULL;
bc0 <= '0';
gpio <= (others => '0');
gpio_en <= (others => '0');
slink_q <= ( others => SLINK_INPUT_DATA_ARRAY_NULL );


end;
