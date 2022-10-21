library ieee;
use ieee.std_logic_1164.all;
use work.emp_device_decl.all;
use work.emp_data_types.all;
use work.emp_ttc_decl.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;

entity tracklet_isolation_in is
port (
  clk: in std_logic;
  in_ttc: in ttc_stuff_array( N_REGION - 1 downto 0 );
  in_din: in ldata( 4 * N_REGION - 1 downto 0 );
  in_reset: out t_resets( numPPquads - 1 downto 0 );
  in_dout: out t_stubsDTC
);
end;

architecture rtl of tracklet_isolation_in is

component tracklet_isolation_in_quad
port (
  clk: in std_logic;
  quad_link: in std_logic;
  quad_ttc: in ttc_stuff_t;
  quad_reset: out t_reset
);
end component;

component tracklet_isolation_in_nodePS
port (
  clk: in std_logic;
  node_din: in lword;
  node_dout: out t_stubDTCPS
);
end component;

component tracklet_isolation_in_node2S
port (
  clk: in std_logic;
  node_din: in lword;
  node_dout: out t_stubDTC2S
);
end component;

begin

g: for k in 0 to numPPquads - 1 generate

signal quad_link: std_logic := '0';
signal quad_ttc: ttc_stuff_t := TTC_STUFF_NULL;
signal quad_reset: t_reset := nulll;

begin

quad_link <= in_din( 4 * k ).valid;
quad_ttc <= in_ttc( k );
in_reset( k ) <= quad_reset;

c: tracklet_isolation_in_quad port map ( clk, quad_link, quad_ttc, quad_reset );

end generate;

gPS: for k in 0 to numTypedStubs( t_stubTypes'pos( LayerPS ) ) - 1 generate

signal node_din: lword := nulll;
signal node_dout: t_stubDTCPS := nulll;

begin

node_din <= in_din( k );
in_dout.ps( k ) <= node_dout;

cPS: tracklet_isolation_in_nodePS port map ( clk, node_din, node_dout );

end generate;

g2S: for k in 0 to numTypedStubs( t_stubTypes'pos( Layer2S ) ) - 1 generate

signal node_din: lword := nulll;
signal node_dout: t_stubDTC2S := nulll;

begin

node_din <= in_din( k + numTypedStubs( t_stubTypes'pos( LayerPS ) ) );
in_dout.ss( k ) <= node_dout;

c2S: tracklet_isolation_in_node2S port map ( clk, node_din, node_dout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.emp_ttc_decl.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.hybrid_data_formats.all;
use work.tracklet_config.all;

entity tracklet_isolation_in_quad is
port (
  clk: in std_logic;
  quad_link: in std_logic;
  quad_ttc: in ttc_stuff_t;
  quad_reset: out t_reset
);
end;

architecture rtl of tracklet_isolation_in_quad is

signal link, ready: std_logic := '0';
signal reset: t_reset := nulll;
signal counter: std_logic_vector( widthFrames - 1 downto 0 ) := ( others => '0' );

begin

quad_reset <= reset;

process ( clk ) is
begin
if rising_edge( clk ) then

  link <= quad_link;
  reset.reset <= '0';
  counter <= incr( counter );
  if quad_link = '1' and link = '0' then
    ready <= '0';
    counter <= ( others => '0' );
    reset.bx <= incr( reset.bx );
    if ready = '1' then
      reset.start <= '1';
      reset.bx <= ( others => '0' );
    end if;
  end if;
  if reset.start = '1' and quad_link = '0' and uint( counter ) = numFrames + 1 - 1 then
    reset.start <= '0';
  end if;
  if uint( quad_ttc.bctr ) = 0 and uint( quad_ttc.pctr ) = 0 and ready = '0' then
    reset.reset <= '1';
    ready <= '1';
    reset.start <= '0';
  end if;

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.emp_data_types.all;
use work.hybrid_data_types.all;
use work.hybrid_data_formats.all;

entity tracklet_isolation_in_nodePS is
port (
  clk: in std_logic;
  node_din: in lword;
  node_dout: out t_stubDTCPS
);
end;

architecture rtl of tracklet_isolation_in_nodePS is

-- step 1
signal din: lword := nulll;

-- step 2
signal dout: t_stubDTCPS := nulll;

function conv( l: std_logic_vector ) return t_stubDTCPS is
  variable s: t_stubDTCPS := nulll;
begin
  s.r     := l( widthsIRr( 0 ) + widthsIRz( 0 ) + widthsIRphi( 0 ) + widthsIRbend( 0 ) + widthIRlayer + 1 - 1 downto widthsIRz( 0 ) + widthsIRphi( 0 ) + widthsIRbend( 0 ) + widthIRlayer + 1 );
  s.z     := l(                  widthsIRz( 0 ) + widthsIRphi( 0 ) + widthsIRbend( 0 ) + widthIRlayer + 1 - 1 downto                  widthsIRphi( 0 ) + widthsIRbend( 0 ) + widthIRlayer + 1 );
  s.phi   := l(                                   widthsIRphi( 0 ) + widthsIRbend( 0 ) + widthIRlayer + 1 - 1 downto                                     widthsIRbend( 0 ) + widthIRlayer + 1 );
  s.bend  := l(                                                      widthsIRbend( 0 ) + widthIRlayer + 1 - 1 downto                                                         widthIRlayer + 1 );
  s.layer := l(                                                                          widthIRlayer + 1 - 1 downto                                                                        1 );
  s.valid := l( 0 );
  return s;
end function;

begin

-- step 2
node_dout <= dout;

process( clk ) is
begin
if rising_edge( clk ) then

  -- step 1

  din <= node_din;

  -- step 2

  dout <= nulll;
  if din.valid = '1' then
    dout <= conv( din.data );
  elsif node_din.valid = '1' then
    dout.reset <= '1';
  end if;

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;

use work.emp_data_types.all;

use work.hybrid_data_types.all;
use work.hybrid_data_formats.all;

entity tracklet_isolation_in_node2S is
port (
  clk: in std_logic;
  node_din: in lword;
  node_dout: out t_stubDTC2S
);
end;

architecture rtl of tracklet_isolation_in_node2S is

-- step 1
signal din: lword := nulll;

-- step 2
signal dout: t_stubDTC2S := nulll;

function conv( l: std_logic_vector ) return t_stubDTC2S is
    variable s: t_stubDTC2S := nulll;
begin
  s.r     := l( widthsIRr( 1 ) + widthsIRz( 1 ) + widthsIRphi( 1 ) + widthsIRbend( 1 ) + widthIRlayer + 1 - 1 downto widthsIRz( 1 ) + widthsIRphi( 1 ) + widthsIRbend( 1 ) + widthIRlayer + 1 );
  s.z     := l(                  widthsIRz( 1 ) + widthsIRphi( 1 ) + widthsIRbend( 1 ) + widthIRlayer + 1 - 1 downto                  widthsIRphi( 1 ) + widthsIRbend( 1 ) + widthIRlayer + 1 );
  s.phi   := l(                                   widthsIRphi( 1 ) + widthsIRbend( 1 ) + widthIRlayer + 1 - 1 downto                                     widthsIRbend( 1 ) + widthIRlayer + 1 );
  s.bend  := l(                                                      widthsIRbend( 1 ) + widthIRlayer + 1 - 1 downto                                                         widthIRlayer + 1 );
  s.layer := l(                                                                          widthIRlayer + 1 - 1 downto                                                                        1 );
  s.valid := l( 0 );
  return s;
end function;

begin

-- step 2
node_dout <= dout;

process( clk ) is
begin
if rising_edge( clk ) then

  -- step 1

  din <= node_din;

  -- step 2

  dout <= nulll;
  if din.valid = '1' then
    dout <= conv( din.data );
  elsif node_din.valid = '1' then
    dout.reset <= '1';
  end if;

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;

use work.emp_device_decl.all;
use work.emp_data_types.all;

use work.hybrid_config.all;
use work.hybrid_data_types.all;

entity tracklet_isolation_out is
port (
  clk: in std_logic;
  out_packet: in t_packets( limitsChannelTB( numSeedTypes ) - 1 downto 0 );
  out_din: in t_channlesTB( numSeedTypes - 1 downto 0 );
  out_dout: out ldata( 4 * N_REGION - 1 downto 0 )
);
end;

architecture rtl of tracklet_isolation_out is

signal dout: ldata( 4 * N_REGION - 1 downto 0 ) := ( others => nulll );

component tracklet_isolation_out_track
port (
  clk: in std_logic;
  track_packet: in t_packet;
  track_din: in t_trackTB;
  track_dout: out lword
);
end component;

component tracklet_isolation_out_stub
port (
  clk: in std_logic;
  stub_packet: in t_packet;
  stub_din: in t_stubTB;
  stub_dout: out lword
);
end component;

begin

out_dout <= dout;

gSeedTypes: for k in 0 to numSeedTypes - 1 generate

signal track_packet: t_packet := ( others => '0' );
signal track_din: t_trackTB := nulll;
signal track_dout: lword :=nulll;

begin

track_packet <= out_packet( limitsChannelTB( k ) );
track_din <= out_din( k ).track;
dout( limitsChannelTB( k ) ) <= track_dout;

cTrack: tracklet_isolation_out_track port map ( clk, track_packet, track_din, track_dout );

gStubs: for j in 0 to numsProjectionLayers( k ) - 1 generate

signal stub_packet: t_packet := ( others => '0' );
signal stub_din: t_stubTB := nulll;
signal stub_dout: lword := nulll;

begin

stub_packet <= out_packet( j + 1 );
stub_din <= out_din( k ).stubs( j );
dout( limitsChannelTB( k ) + j + 1 ) <= stub_dout;

cStub: tracklet_isolation_out_stub port map ( clk, stub_packet, stub_din, stub_dout );

end generate;

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;

use work.emp_data_types.all;
use work.emp_project_decl.all;

use work.hybrid_data_types.all;
use work.hybrid_data_formats.all;

entity tracklet_isolation_out_track is
port (
  clk: in std_logic;
  track_packet: in t_packet;
  track_din: in t_trackTB;
  track_dout: out lword
);
end;

architecture rtl of tracklet_isolation_out_track is

constant widthTrack: natural := 1 + widthTBseedType + widthTBinv2R + widthTBphi0 + widthTBz0 + widthTBcot;
-- sr
signal sr: t_packets( PAYLOAD_LATENCY - 1 downto 0 ) := ( others => ( others => '0' ) );

-- step 1
signal din:  t_trackTB := nulll;
signal dout: lword := nulll;

function conv( s: t_trackTB ) return std_logic_vector is
begin
  return s.valid & s.seedType & s.inv2R & s.phi0 & s.z0 & s.cot;
end function;

begin

-- step 1
din <= track_din;
track_dout <= dout;

process( clk ) is
begin
if rising_edge( clk ) then

  -- sr

  sr <= sr( sr'high - 1 downto 0 ) & track_packet;

  -- step 1

  dout.start_of_orbit <= sr( sr'high ).start_of_orbit;
  dout.valid <= '0';
  dout.data <= ( others => '0' );
  if sr( sr'high ).valid = '1' then
    dout.valid <= '1';
    dout.data( widthTrack - 1 downto 0  ) <= conv( din );
  end if;

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;

use work.emp_data_types.all;
use work.emp_project_decl.all;

use work.hybrid_data_types.all;
use work.hybrid_data_formats.all;

entity tracklet_isolation_out_stub is
port (
  clk: in std_logic;
  stub_packet: in t_packet;
  stub_din: in t_stubTB;
  stub_dout: out lword
);
end;

architecture rtl of tracklet_isolation_out_stub is

constant widthStub: natural := 1 + widthsTBr( 0 ) + widthsTBphi( 0 ) + widthsTBz( 0 );
-- sr
signal sr: t_packets( PAYLOAD_LATENCY - 1 downto 0 ) := ( others => ( others => '0' ) );

-- step 1
signal din:  t_stubTB := nulll;
signal dout: lword := nulll;

function conv( s: t_stubTB ) return std_logic_vector is
begin
  return s.valid & s.r( widthsTBr( 0 ) - 1 downto 0 ) & s.phi( widthsTBphi( 0 ) - 1 downto 0 ) & s.z( widthsTBz( 0 ) - 1 downto 0 );
end function;

begin

-- step 1
din <= stub_din;
stub_dout <= dout;

process( clk ) is
begin
if rising_edge( clk ) then

  -- sr

  sr <= sr( sr'high - 1 downto 0 ) & stub_packet;

  -- step 1

  dout.start_of_orbit <= sr( sr'high ).start_of_orbit;
  dout.valid <= '0';
  dout.data <= ( others => '0' );
  if sr( sr'high ).valid = '1' then
    dout.valid <= '1';
    dout.data( widthStub - 1 downto 0  ) <= conv( din );
  end if;

end if;
end process;

end;
