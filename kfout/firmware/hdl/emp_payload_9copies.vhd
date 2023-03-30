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

  CONSTANT OutLinkMapping : INTEGER_VECTOR( 0 TO 17 ) := ( 4,5,6,7,8,9,10,11,12,13,14,15,64,65,66,67,68,69 );
  CONSTANT InLinkMapping : INTEGER_VECTOR( 0 TO 71 ) := ( 0,1,2,3,4,5,6,7,
                                                          8,9,10,11,12,13,14,15,
                                                         16,17,18,19,20,21,22,23,
                                                         24,25,26,27,28,29,30,31,
                                                         32,33,34,35,36,37,38,39,
                                                         40,41,42,43,44,45,46,47,
                                                         48,49,50,51,52,53,54,55,
                                                         56,57,58,59,60,61,62,63,
                                                         64,65,66,67,68,69,70,71
                                                        );

component kfout_isolation_in
    port (
        clk     : in std_logic;
        in_din  : in ldata( 7 downto 0 );
        in_dout : out t_channelsKF( numNodesKF - 1 downto 0 )
    );
end component;

component kfout_top
    port(
        clk: in std_logic;
        kfout_din: in t_channelsKF( numNodesKF - 1 downto 0 );
        kfout_dout: out t_frames( numLinksTFP - 1 downto 0 )
    );
end component;

component kfout_isolation_out
    port (
        clk: in std_logic;
        out_packet: in t_packets( numLinksTFP - 1 downto 0 );
        out_din: in t_frames( numLinksTFP - 1 downto 0 );
        out_dout: out ldata( 1 downto 0 )
    );
end component;

function conv( l: ldata; LinkMap : INTEGER_VECTOR ) return t_packets is
    variable s: t_packets( numLinksTFP - 1 downto 0 );
begin
    for k in s'range loop
        s( k ).valid := l( LinkMap( k ) ).valid;
        s( k ).start_of_orbit := l(  LinkMap( k ) ).start_of_orbit;
    end loop;
    return s;
end;


begin

g1 : FOR i IN 0 TO 8 GENERATE
    
    signal in_din: ldata( 7 downto 0 ) :=  ( others => nulll );
    signal in_dout: t_channelsKF( numNodesKF - 1 downto 0 ) := ( others => nulll );

    signal kfout_din: t_channelsKF( numNodesKF - 1 downto 0 ) := ( others => nulll );
    signal kfout_dout: t_frames( numLinksTFP - 1 downto 0 ) := ( others => ( others => '0' ) );

    signal out_packet: t_packets( numLinksTFP - 1 downto 0 ) := ( others => ( others => '0' ) );
    signal out_din: t_frames( numLinksTFP - 1 downto 0 ) := ( others => ( others => '0' ) );
    signal out_dout: ldata( 1 downto 0 ) := ( others => nulll );

BEGIN

    in_din <= d( InLinkMapping(i*8 + 7) DOWNTO InLinkMapping(i*8) );

    kfout_din <= in_dout;

    out_packet <=  conv( d( InLinkMapping(i*8 + 7) DOWNTO InLinkMapping(i*8) ) , (InLinkMapping(i*8 + 1),InLinkMapping(i*8)));
    out_din <= kfout_dout;

    q( OutLinkMapping(2*i + 1)).strobe <= '1';
    q( OutLinkMapping(2*i) ).strobe <= '1';
    q( OutLinkMapping(2*i + 1) ).start  <= '0';
    q( OutLinkMapping(2*i) ).start  <= '0';

    q( OutLinkMapping(2*i + 1) DOWNTO OutLinkMapping(2*i) ) <= out_dout( 1 DOWNTO 0 );

    fin: kfout_isolation_in port map ( clk_p, in_din, in_dout );

    kfout: kfout_top port map ( clk_p, kfout_din, kfout_dout);

    fout: kfout_isolation_out port map ( clk_p, out_packet, out_din, out_dout );

END GENERATE;

ipb_out <= IPB_RBUS_NULL;
bc0 <= '0';
gpio <= (others => '0');
gpio_en <= (others => '0');
slink_q <= ( others => SLINK_INPUT_DATA_ARRAY_NULL );


end;