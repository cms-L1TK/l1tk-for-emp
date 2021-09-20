library ieee;
use ieee.std_logic_1164.all;
use work.emp_device_decl.all;
use work.emp_data_types.all;
use work.emp_ttc_decl.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;

entity hybrid_format_in is
port (
  clk: in std_logic;
  in_ttc: in ttc_stuff_array( N_REGION - 1 downto 0 );
  in_din: in ldata( 4 * N_REGION - 1 downto 0 );
  in_reset: out t_resets( numQuads - 1 downto 0 );
  in_dout: out t_stubsDTC
);
end;

architecture rtl of hybrid_format_in is

component hybrid_format_in_quad
port (
  clk: in std_logic;
  quad_link: in std_logic;
  quad_ttc: in ttc_stuff_t;
  quad_reset: out t_reset
);
end component;

component hybrid_format_in_nodePS
port (
  clk: in std_logic;
  node_din: in lword;
  node_dout: out t_stubDTCPS
);
end component;

component hybrid_format_in_node2S
port (
  clk: in std_logic;
  node_din: in lword;
  node_dout: out t_stubDTC2S
);
end component;

begin

g: for k in 0 to numQuads - 1 generate

signal quad_link: std_logic := '0';
signal quad_ttc: ttc_stuff_t := TTC_STUFF_NULL;
signal quad_reset: t_reset := nulll;

begin

quad_link <= in_din( 4 * k ).valid;
quad_ttc <= in_ttc( k );
in_reset( k ) <= quad_reset;

c: hybrid_format_in_quad port map ( clk, quad_link, quad_ttc, quad_reset );

end generate;

gPS: for k in 0 to numDTCPS - 1 generate

signal node_din: lword := ( ( others => '0' ), '0', '0', '1' );
signal node_dout: t_stubDTCPS := nulll;

begin

node_din <= in_din( k );
in_dout.ps( k ) <= node_dout;

cPS: hybrid_format_in_nodePS port map ( clk, node_din, node_dout );

end generate;

g2S: for k in 0 to numDTC2S - 1 generate

signal node_din: lword := ( ( others => '0' ), '0', '0', '1' );
signal node_dout: t_stubDTC2S := nulll;

begin

node_din <= in_din( k + numDTCPS );
in_dout.ss( k ) <= node_dout;

c2S: hybrid_format_in_node2S port map ( clk, node_din, node_dout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.emp_ttc_decl.all;
use work.hybrid_tools.all;
use work.hybrid_data_types.all;
use work.hybrid_data_formats.all;
use work.tracklet_config.all;

entity hybrid_format_in_quad is
port (
  clk: in std_logic;
  quad_link: in std_logic;
  quad_ttc: in ttc_stuff_t;
  quad_reset: out t_reset
);
end;

architecture rtl of hybrid_format_in_quad is

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
  if uint( counter ) = numFrames - 1 then
    reset.bx <= incr( reset.bx );
  end if;
  if quad_link = '1' and link = '0' then
    ready <= '0';
    counter <= ( others => '0' );
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

entity hybrid_format_in_nodePS is
port (
  clk: in std_logic;
  node_din: in lword;
  node_dout: out t_stubDTCPS
);
end;

architecture rtl of hybrid_format_in_nodePS is

-- step 1
signal din: lword := ( ( others => '0' ), '0', '0', '1' );

-- step 2
signal dout: t_stubDTCPS := nulll;

function conv( l: std_logic_vector ) return t_stubDTCPS is
    variable s: t_stubDTCPS := nulll;
begin
  s.bx    := l( LWORD_WIDTH - 2 downto LWORD_WIDTH - 4 );
  s.r     := l( widthPSr + widthPSz + widthPSphi + widthPSbend + widthPSlayer + 1 - 1 downto widthPSz + widthPSphi + widthPSbend + widthPSlayer + 1 );
  s.z     := l(            widthPSz + widthPSphi + widthPSbend + widthPSlayer + 1 - 1 downto            widthPSphi + widthPSbend + widthPSlayer + 1 );
  s.phi   := l(                       widthPSphi + widthPSbend + widthPSlayer + 1 - 1 downto                         widthPSbend + widthPSlayer + 1 );
  s.bend  := l(                                    widthPSbend + widthPSlayer + 1 - 1 downto                                       widthPSlayer + 1 );
  s.layer := l(                                                  widthPSlayer + 1 - 1 downto                                                      1 );
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

entity hybrid_format_in_node2S is
port (
  clk: in std_logic;
  node_din: in lword;
  node_dout: out t_stubDTC2S
);
end;

architecture rtl of hybrid_format_in_node2S is

-- step 1
signal din: lword := ( ( others => '0' ), '0', '0', '1' );

-- step 2
signal dout: t_stubDTC2S := nulll;

function conv( l: std_logic_vector ) return t_stubDTC2S is
    variable s: t_stubDTC2S := nulll;
begin
  s.bx    := l( LWORD_WIDTH - 2 downto LWORD_WIDTH - 4 );
  s.r     := l( width2Sr + width2Sz + width2Sphi + width2Sbend + width2Slayer + 1 - 1 downto width2Sz + width2Sphi + width2Sbend + width2Slayer + 1 );
  s.z     := l(            width2Sz + width2Sphi + width2Sbend + width2Slayer + 1 - 1 downto            width2Sphi + width2Sbend + width2Slayer + 1 );
  s.phi   := l(                       width2Sphi + width2Sbend + width2Slayer + 1 - 1 downto                         width2Sbend + width2Slayer + 1 );
  s.bend  := l(                                    width2Sbend + width2Slayer + 1 - 1 downto                                       width2Slayer + 1 );
  s.layer := l(                                                  width2Slayer + 1 - 1 downto                                                      1 );
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

entity hybrid_format_out is
port (
  clk: in std_logic;
  out_packet: in std_logic_vector( numLinksTracklet - 1 downto 0 );
  out_din: in t_candTracklet;
  out_dout: out ldata( 4 * N_REGION - 1 downto 0 )
);
end;

architecture rtl of hybrid_format_out is

signal dout: ldata( 4 * N_REGION - 1 downto 0 ) := ( others => ( ( others => '0' ), '0', '0', '1' ) );

signal track_packet: std_logic := '0';
signal track_din: t_trackTracklet := nulll;
signal track_dout: lword :=( ( others => '0' ), '0', '0', '1' );
component hybrid_format_out_track
port (
  clk: in std_logic;
  track_packet: in std_logic;
  track_din: in t_trackTracklet;
  track_dout: out lword
);
end component;

component hybrid_format_out_stub
port (
  clk: in std_logic;
  stub_packet: in std_logic;
  stub_din: in t_stubTracklet;
  stub_dout: out lword
);
end component;

begin

out_dout <= dout;

track_packet <= out_packet( 0 );
track_din <= out_din.track;
dout( 0 ) <= track_dout;

cTrack: hybrid_format_out_track port map ( clk, track_packet, track_din, track_dout );

gStubs: for k in 0 to numStubsTracklet - 1 generate

signal stub_packet: std_logic := '0';
signal stub_din: t_stubTracklet := nulll;
signal stub_dout: lword := ( ( others => '0' ), '0', '0', '1' );

begin

stub_packet <= out_packet( k + 1 );
stub_din <= out_din.stubs( k );
dout( k + 1 ) <= stub_dout;

cStub: hybrid_format_out_stub port map ( clk, stub_packet, stub_din, stub_dout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;

use work.emp_data_types.all;
use work.emp_project_decl.all;

use work.hybrid_data_types.all;
use work.hybrid_data_formats.all;

entity hybrid_format_out_track is
port (
  clk: in std_logic;
  track_packet: in std_logic;
  track_din: in t_trackTracklet;
  track_dout: out lword
);
end;

architecture rtl of hybrid_format_out_track is

constant widthTrack: natural := 1 + widthTrackletSeedType + widthTrackletInv2R + widthTrackletPhi0 + widthTrackletZ0 + widthTrackletCot;
-- sr
signal sr: std_logic_vector( PAYLOAD_LATENCY - 1 downto 0 ) := ( others => '0' );

-- step 1
signal din:  t_trackTracklet := nulll;
signal dout: lword := ( ( others => '0' ), '0', '0', '1' );

function conv( s: t_trackTracklet ) return std_logic_vector is
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

  dout.valid <= '0';
  dout.data <= ( others => '0' );
  if sr( sr'high ) = '1' then
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

entity hybrid_format_out_stub is
port (
  clk: in std_logic;
  stub_packet: in std_logic;
  stub_din: in t_stubTracklet;
  stub_dout: out lword
);
end;

architecture rtl of hybrid_format_out_stub is

constant widthStub: natural := 1 + widthTrackletTrackId + widthTrackletStubId + widthTrackletR + widthTrackletPhi + widthTrackletZ;
-- sr
signal sr: std_logic_vector( PAYLOAD_LATENCY - 1 downto 0 ) := ( others => '0' );

-- step 1
signal din:  t_stubTracklet := nulll;
signal dout: lword := ( ( others => '0' ), '0', '0', '1' );

function conv( s: t_stubTracklet ) return std_logic_vector is
begin
  return s.valid & s.trackId & s.stubId & s.r & s.phi & s.z;
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

  dout.valid <= '0';
  dout.data <= ( others => '0' );
  if sr( sr'high ) = '1' then
    dout.valid <= '1';
    dout.data( widthStub - 1 downto 0  ) <= conv( din );
  end if;

end if;
end process;

end;
