library ieee;
use ieee.std_logic_1164.all;
use work.emp_device_decl.all;
use work.emp_data_types.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;

entity tm_isolation_in is
port (
  clk: in std_logic;
  in_din: in ldata( 4 * N_REGION - 1 downto 0 );
  in_dout: out t_channelsTB( tbNumSeedTypes - 1 downto 0 )
);
end;

architecture rtl of tm_isolation_in is

component tm_isolation_in_node
generic (
  seedType: natural
);
port (
  clk: in std_logic;
  node_din: in ldata( tbNumLinks - 1 downto 0 );
  node_dout: out t_channelTB
);
end component;

begin

g: for k in 0 to tbNumSeedTypes - 1 generate

constant numProjectionLayers: natural := tbNumsProjectionLayers( k );
constant high: natural := tbLimitsChannel( k + 1 ) - 1;
constant low: natural := tbLimitsChannel( k );

signal node_din: ldata( tbNumLinks - 1 downto 0 ) := ( others => nulll );
signal node_dout: t_channelTB := nulll;

begin

node_din( numProjectionLayers + tbMaxNumSeedingLayer + 1 - 1 downto 0 ) <= in_din( high downto low );
in_dout( k ) <= node_dout;

c: tm_isolation_in_node generic map ( k ) port map ( clk, node_din, node_dout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.emp_device_decl.all;
use work.emp_data_types.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;

entity tm_isolation_in_node is
generic (
  seedType: natural
);
port (
  clk: in std_logic;
  node_din: in ldata( tbNumLinks - 1 downto 0 );
  node_dout: out t_channelTB
);
end;

architecture rtl of tm_isolation_in_node is

constant numProjectionLayers: natural := tbNumsProjectionLayers( seedType );

signal desync_din: ldata( tbNumLinks - 1 downto 0 ) := ( others => nulll );
signal desync_dout: ldata( tbNumLinks - 1 downto 0 ) := ( others => nulll );
component tm_isolation_in_desync
generic (
  index: natural
);
port (
  clk: in std_logic;
  desync_din: in ldata( tbNumLinks - 1 downto 0 );
  desync_dout: out ldata( tbNumLinks - 1 downto 0 )
);
end component;

signal track_din: lword := nulll;
signal track_dout: t_trackTB := nulll;
component tm_isolation_in_track
port (
  clk: in std_logic;
  track_din: in lword;
  track_dout: out t_trackTB
);
end component;

signal stubs_din: ldata( tbMaxNumProjectionLayers - 1 downto 0 ) := ( others => nulll );
signal stubs_dout: t_stubsTB( tbMaxNumProjectionLayers - 1 downto 0 ) := ( others => nulll );
component tm_isolation_in_stubs
generic (
  seedType: natural
);
port (
  clk: in std_logic;
  stubs_din: in ldata( tbMaxNumProjectionLayers - 1 downto 0 );
  stubs_dout: out t_stubsTB( tbMaxNumProjectionLayers - 1 downto 0 )
);
end component;

signal seeds_din: ldata( tbMaxNumSeedingLayer - 1 downto 0 ) := ( others => nulll );
signal seeds_dout: t_seedsTB( tbMaxNumSeedingLayer - 1 downto 0 ) := ( others => nulll );
component tm_isolation_in_seeds
port (
  clk: in std_logic;
  seeds_din: in ldata( tbMaxNumSeedingLayer - 1 downto 0 );
  seeds_dout: out t_seedsTB( tbMaxNumSeedingLayer - 1 downto 0 )
);
end component;

begin

desync_din <= node_din;

track_din <= desync_dout( 0 );
stubs_din( numProjectionLayers - 1 downto 0 ) <= desync_dout( numProjectionLayers + 1 - 1 downto 1 );
seeds_din <= desync_dout( tbMaxNumSeedingLayer + numProjectionLayers + 1 - 1 downto numProjectionLayers + 1 );

node_dout <= ( track_dout, seeds_dout, stubs_dout );

cDesync: tm_isolation_in_desync generic map ( seedType ) port map ( clk, desync_din, desync_dout );

cTrack: tm_isolation_in_track port map ( clk, track_din, track_dout );

cStubs: tm_isolation_in_stubs generic map ( seedType ) port map ( clk, stubs_din, stubs_dout );

cSeeds: tm_isolation_in_seeds port map ( clk, seeds_din, seeds_dout );

end;


library ieee;
use ieee.std_logic_1164.all;
use work.emp_data_types.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;

entity tm_isolation_in_desync is
generic (
  index: natural
);
port (
  clk: in std_logic;
  desync_din: in ldata( tbNumLinks - 1 downto 0 );
  desync_dout: out ldata( tbNumLinks - 1 downto 0 )
);
end;

architecture rtl of tm_isolation_in_desync is

constant widthLdata: natural := 5 + LWORD_WIDTH;
constant widthRam: natural := tbNumLinks * widthLdata;
constant widthAddr: natural := width( tbNumLinks + 1 );
type t_ram is array ( 0 to 2 ** widthAddr - 1 ) of std_logic_vector( widthRam - 1 downto 0 );
function conv( std: std_logic_vector ) return ldata is
  variable links: ldata( tbNumLinks - 1 downto 0 ) := ( others => nulll );
  variable link: std_logic_vector( widthLdata - 1 downto 0 ) := ( others => '0' );
begin
  for k in links'range loop
    link := std( ( k + 1 ) * widthLdata - 1 downto k * widthLdata );
    links( k ).data  := link( widthLdata - 1 downto 5 );
    links( k ).valid          := link( 4 );
    links( k ).start          := link( 3 );
    links( k ).start_of_orbit := link( 2 );
    links( k ).strobe         := link( 1 );
    links( k ).last           := link( 0 );
  end loop;
  return links;
end function;
function conv( links: ldata ) return std_logic_vector is
  variable std: std_logic_vector( widthRam - 1 downto 0 ) := ( others => '0' );
begin
  for k in links'range loop
    std( ( k + 1 ) * widthLdata - 1 downto k * widthLdata ) := links( k ).data & links( k ).valid & links( k ).start & links( k ).start_of_orbit & links( k ).strobe & links( k ).last;
  end loop;
  return std;
end function;

signal ram: t_ram := ( others => ( others => '0' ) );
signal waddr, raddr: std_logic_vector( widthAddr - 1 downto 0 ) := ( others => '0' );
signal dout: ldata( tbNumLinks - 1 downto 0 ) := ( others => nulll );

begin

desync_dout <= dout;
waddr <= raddr + index + 1;

process ( clk ) is
begin
if rising_edge( clk ) then

  ram( uint( waddr ) ) <= conv( desync_din );
  dout <= conv( ram( uint( raddr ) ) );
  raddr <= raddr + 1;

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.emp_data_types.all;
use work.hybrid_data_types.all;
use work.hybrid_data_formats.all;

entity tm_isolation_in_track is
port (
  clk: in std_logic;
  track_din: in lword;
  track_dout: out t_trackTB
);
end;

architecture rtl of tm_isolation_in_track is

-- step 1
signal din: lword := nulll;

-- step 2
signal dout: t_trackTB := nulll;

function conv( l: std_logic_vector ) return t_trackTB is
  variable s: t_trackTB := nulll;
begin
  s.valid    := l( 1 + widthTBSeedType + widthTBInv2R + widthTBPhi0 + widthTBZ0 + widthTBCot - 1 );
  s.seedType := l(     widthTBSeedType + widthTBInv2R + widthTBPhi0 + widthTBZ0 + widthTBCot - 1 downto widthTBInv2R + widthTBPhi0 + widthTBZ0 + widthTBCot );
  s.inv2R    := l(                       widthTBInv2R + widthTBPhi0 + widthTBZ0 + widthTBCot - 1 downto                widthTBPhi0 + widthTBZ0 + widthTBCot );
  s.phi0     := l(                                      widthTBPhi0 + widthTBZ0 + widthTBCot - 1 downto                              widthTBZ0 + widthTBCot );
  s.z0       := l(                                                    widthTBZ0 + widthTBCot - 1 downto                                          widthTBCot );
  s.cot      := l(                                                                widthTBCot - 1 downto                                                   0 );
  return s;
end function;

begin

-- step 2
track_dout <= dout;

process( clk ) is
begin
if rising_edge( clk ) then

  -- step 1

  din <= track_din;

  -- step 2

  dout <= nulll;
  if din.valid = '1' then
    dout <= conv( din.data );
  elsif track_din.valid = '1' then
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

entity tm_isolation_in_stubs is
generic (
  seedType: natural
);
port (
  clk: in std_logic;
  stubs_din: in ldata( tbMaxNumProjectionLayers - 1 downto 0 );
  stubs_dout: out t_stubsTB( tbMaxNumProjectionLayers - 1 downto 0 )
);
end;

architecture rtl of tm_isolation_in_stubs is

signal dout: t_stubsTB( tbMaxNumProjectionLayers - 1 downto 0 ) := ( others => nulll );
component tm_isolation_in_stub
generic (
  layer: natural
);
port (
  clk: in std_logic;
  stub_din: in lword;
  stub_dout: out t_stubTB
);
end component;

begin

stubs_dout <= dout;

g: for k in 0 to tbNumsProjectionLayers( seedType ) - 1 generate

signal stub_din: lword := nulll;
signal stub_dout: t_stubTB := nulll;

begin

stub_din <= stubs_din( k );
dout( k ) <= stub_dout;

c: tm_isolation_in_stub generic map ( seedTypesProjectionLayers( seedType )( k ) ) port map ( clk, stub_din, stub_dout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.emp_device_decl.all;
use work.emp_data_types.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;

entity tm_isolation_in_seeds is
port (
  clk: in std_logic;
  seeds_din: in ldata( tbMaxNumSeedingLayer - 1 downto 0 );
  seeds_dout: out t_seedsTB( tbMaxNumSeedingLayer - 1 downto 0 )
);
end;

architecture rtl of tm_isolation_in_seeds is

component tm_isolation_in_seed
port (
  clk: in std_logic;
  seed_din: in lword;
  seed_dout: out t_seedTB
);
end component;

begin

g: for k in 0 to tbMaxNumSeedingLayer - 1 generate

signal seed_din: lword := nulll;
signal seed_dout: t_seedTB := nulll;

begin

seed_din <= seeds_din( k );
seeds_dout( k ) <= seed_dout;

c: tm_isolation_in_seed port map ( clk, seed_din, seed_dout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.emp_data_types.all;
use work.hybrid_tools.all;
use work.hybrid_data_types.all;
use work.hybrid_data_formats.all;

entity tm_isolation_in_seed is
port (
  clk: in std_logic;
  seed_din: in lword;
  seed_dout: out t_seedTB
);
end;

architecture rtl of tm_isolation_in_seed is

function conv( std: std_logic_vector ) return t_seedTB is
  variable s: t_seedTB := nulll;
begin
  s.valid                                := std( 1 + widthTBstubId - 1 );
  s.stubId( widthTBstubId - 1 downto 0 ) := std(     widthTBstubId - 1 downto 0 );
  return s;
end function;

-- step 1
signal din: lword := nulll;

-- step 2
signal dout: t_seedTB := nulll;

begin

-- step 2
seed_dout <= dout;

process( clk ) is
begin
if rising_edge( clk ) then

  -- step 1

  din <= seed_din;

  -- step 2

  dout <= nulll;
  if din.valid = '1' then
    dout <= conv( din.data );
  elsif seed_din.valid = '1' then
    dout.reset <= '1';
  end if;

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.emp_data_types.all;
use work.hybrid_tools.all;
use work.hybrid_data_types.all;
use work.hybrid_data_formats.all;

entity tm_isolation_in_stub is
generic (
  layer: natural
);
port (
  clk: in std_logic;
  stub_din: in lword;
  stub_dout: out t_stubTB
);
end;

architecture rtl of tm_isolation_in_stub is

-- step 1
signal din: lword := nulll;
signal stubType: std_logic_vector( widthTBstubType - 1 downto 0 ) := ( others => '0' );

-- step 2
signal dout: t_stubTB := nulll;

function f_stubType( l: lword ) return std_logic_vector is
  variable s: std_logic_vector( widthTBstubType - 1 downto 0 );
begin
  case layer is
    when 1 to 3 =>
      s := stdu( 0, widthTBstubType );
    when 4 to 6 =>
      s := stdu( 1, widthTBstubType );
    when 11 to 15 =>
      s := stdu( 2, widthTBstubType );
      if l.data( r_stubDiskType ) = ( widthTBstubDiksType - 1 downto 0 => '0' ) then
        s := stdu( 3, widthTBstubType );
      end if;
    when others => null;
  end case;
  return s;
end function;
function conv( l: std_logic_vector; t: natural ) return t_stubTB is
  variable s: t_stubTB := nulll;
  variable v0  : std_logic                                         := l( 1 + widthTBstubId + widthsTBr( 0 ) + widthsTBphi( 0 ) + widthsTBz( 0 ) - 1 );
  variable v1  : std_logic                                         := l( 1 + widthTBstubId + widthsTBr( 1 ) + widthsTBphi( 1 ) + widthsTBz( 1 ) - 1 );
  variable v2  : std_logic                                         := l( 1 + widthTBstubId + widthsTBr( 2 ) + widthsTBphi( 2 ) + widthsTBz( 2 ) - 1 );
  variable v3  : std_logic                                         := l( 1 + widthTBstubId + widthsTBr( 3 ) + widthsTBphi( 3 ) + widthsTBz( 3 ) - 1 );
  variable id0 : std_logic_vector( widthTBstubId    - 1 downto 0 ) := l(     widthTBstubId + widthsTBr( 0 ) + widthsTBphi( 0 ) + widthsTBz( 0 ) - 1 downto widthsTBr( 0 ) + widthsTBphi( 0 ) + widthsTBz( 0 ) );
  variable id1 : std_logic_vector( widthTBstubId    - 1 downto 0 ) := l(     widthTBstubId + widthsTBr( 1 ) + widthsTBphi( 1 ) + widthsTBz( 1 ) - 1 downto widthsTBr( 1 ) + widthsTBphi( 1 ) + widthsTBz( 1 ) );
  variable id2 : std_logic_vector( widthTBstubId    - 1 downto 0 ) := l(     widthTBstubId + widthsTBr( 2 ) + widthsTBphi( 2 ) + widthsTBz( 2 ) - 1 downto widthsTBr( 2 ) + widthsTBphi( 2 ) + widthsTBz( 2 ) );
  variable id3 : std_logic_vector( widthTBstubId    - 1 downto 0 ) := l(     widthTBstubId + widthsTBr( 3 ) + widthsTBphi( 3 ) + widthsTBz( 3 ) - 1 downto widthsTBr( 3 ) + widthsTBphi( 3 ) + widthsTBz( 3 ) );
  variable r0  : std_logic_vector( widthsTBr( 0 )   - 1 downto 0 ) := l(                     widthsTBr( 0 ) + widthsTBphi( 0 ) + widthsTBz( 0 ) - 1 downto                  widthsTBphi( 0 ) + widthsTBz( 0 ) );
  variable r1  : std_logic_vector( widthsTBr( 1 )   - 1 downto 0 ) := l(                     widthsTBr( 1 ) + widthsTBphi( 1 ) + widthsTBz( 1 ) - 1 downto                  widthsTBphi( 1 ) + widthsTBz( 1 ) );
  variable r2  : std_logic_vector( widthsTBr( 2 )   - 1 downto 0 ) := l(                     widthsTBr( 2 ) + widthsTBphi( 2 ) + widthsTBz( 2 ) - 1 downto                  widthsTBphi( 2 ) + widthsTBz( 2 ) );
  variable r3  : std_logic_vector( widthsTBr( 3 )   - 1 downto 0 ) := l(                     widthsTBr( 3 ) + widthsTBphi( 3 ) + widthsTBz( 3 ) - 1 downto                  widthsTBphi( 3 ) + widthsTBz( 3 ) );
  variable phi0: std_logic_vector( widthsTBphi( 0 ) - 1 downto 0 ) := l(                                      widthsTBphi( 0 ) + widthsTBz( 0 ) - 1 downto                                     widthsTBz( 0 ) );
  variable phi1: std_logic_vector( widthsTBphi( 1 ) - 1 downto 0 ) := l(                                      widthsTBphi( 1 ) + widthsTBz( 1 ) - 1 downto                                     widthsTBz( 1 ) );
  variable phi2: std_logic_vector( widthsTBphi( 2 ) - 1 downto 0 ) := l(                                      widthsTBphi( 2 ) + widthsTBz( 2 ) - 1 downto                                     widthsTBz( 2 ) );
  variable phi3: std_logic_vector( widthsTBphi( 3 ) - 1 downto 0 ) := l(                                      widthsTBphi( 3 ) + widthsTBz( 3 ) - 1 downto                                     widthsTBz( 3 ) );
  variable z0  : std_logic_vector( widthsTBz( 0 )   - 1 downto 0 ) := l(                                                         widthsTBz( 0 ) - 1 downto                                                  0 );
  variable z1  : std_logic_vector( widthsTBz( 1 )   - 1 downto 0 ) := l(                                                         widthsTBz( 1 ) - 1 downto                                                  0 );
  variable z2  : std_logic_vector( widthsTBz( 2 )   - 1 downto 0 ) := l(                                                         widthsTBz( 2 ) - 1 downto                                                  0 );
  variable z3  : std_logic_vector( widthsTBz( 3 )   - 1 downto 0 ) := l(                                                         widthsTBz( 3 ) - 1 downto                                                  0 );
begin
  case t is
    when 0 => s := ( '0', v0, ( others => '0' ), id0, resize( r0, widthTBr ), resize( phi0, widthTBphi ), resize( z0, widthTBz ) );
    when 1 => s := ( '0', v1, ( others => '0' ), id1, resize( r1, widthTBr ), resize( phi1, widthTBphi ), resize( z1, widthTBz ) );
    when 2 => s := ( '0', v2, ( others => '0' ), id2, resize( r2, widthTBr ), resize( phi2, widthTBphi ), resize( z2, widthTBz ) );
    when 3 => s := ( '0', v3, ( others => '0' ), id3, resize( r3, widthTBr ), resize( phi3, widthTBphi ), resize( z3, widthTBz ) );
    when others => null;
  end case;
  return s;
end function;

begin

-- step 2
stub_dout <= dout;

process( clk ) is
begin
if rising_edge( clk ) then

  -- step 1

  din <= stub_din;
  stubType <= f_stubType( stub_din );

  -- step 2

  dout <= nulll;
  if din.valid = '1' then
    dout <= conv( din.data, uint( stubType ) );
  elsif stub_din.valid = '1' then
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

entity tm_isolation_out is
port (
  clk: in std_logic;
  out_packet: in t_packets( 4 * N_REGION - 1 downto 0 );
  out_din: in t_channelTM;
  out_dout: out ldata( 4 * N_REGION - 1 downto 0 )
);
end;

architecture rtl of tm_isolation_out is

signal track_packet: t_packet := ( others => '0' );
signal track_din: t_trackTM := nulll;
signal track_dout: lword := nulll;
component tm_isolation_out_track
port (
  clk: in std_logic;
  track_packet: in t_packet;
  track_din: in t_trackTM;
  track_dout: out lword
);
end component;

signal stubs_packet: t_packets( numLayers - 1 downto 0 ) := ( others => ( others => '0' ) );
signal stubs_din: t_stubsTM( numLayers - 1 downto 0 ) := ( others => nulll );
signal stubs_dout: ldata( numLayers - 1 downto 0 ) := ( others => nulll );
component tm_isolation_out_stubs
port (
  clk: in std_logic;
  stubs_packet: in t_packets( numLayers - 1 downto 0 );
  stubs_din: in t_stubsTM( numLayers - 1 downto 0 );
  stubs_dout: out ldata( numLayers - 1 downto 0 )
);
end component;

begin

track_packet <= out_packet( 0 );
track_din <= out_din.track;

stubs_packet <= out_packet( numLayers + 1 - 1 downto 1 );
stubs_din <= out_din.stubs;

out_dout( 4 * N_REGION - 1 downto drNumLinks ) <= ( others => nulll );
out_dout( drNumLinks - 1 downto 0 ) <= stubs_dout & track_dout;

cTrack: tm_isolation_out_track port map ( clk, track_packet, track_din, track_dout );

cStubs: tm_isolation_out_stubs port map ( clk, stubs_packet, stubs_din, stubs_dout );

end;


library ieee;
use ieee.std_logic_1164.all;
use work.emp_data_types.all;
use work.emp_project_decl.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.hybrid_data_formats.all;

entity tm_isolation_out_track is
port (
  clk: in std_logic;
  track_packet: in t_packet;
  track_din: in t_trackTM;
  track_dout: out lword
);
end;

architecture rtl of tm_isolation_out_track is

constant widthTrack: natural := 1 + widthTMinv2R + widthTMphiT + widthTMzT;

-- sr
signal sr: t_packets( PAYLOAD_LATENCY - 1 downto 0 ) := ( others => ( others => '0' ) );

-- step 1
signal din:  t_trackTM := nulll;
signal dout: lword := nulll;

function conv( t: t_trackTM ) return std_logic_vector is
begin
  return t.valid & t.inv2R & t.phiT & t.zT;
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
use work.hybrid_config.all;
use work.hybrid_data_types.all;

entity tm_isolation_out_stubs is
port (
  clk: in std_logic;
  stubs_packet: in t_packets( numLayers - 1 downto 0 );
  stubs_din: in t_stubsTM( numLayers - 1 downto 0 );
  stubs_dout: out ldata( numLayers - 1 downto 0 )
);
end;

architecture rtl of tm_isolation_out_stubs is

component tm_isolation_out_stub
port (
  clk: in std_logic;
  stub_packet: in t_packet;
  stub_din: in t_stubTM;
  stub_dout: out lword
);
end component;

begin

g: for k in 0 to numLayers - 1 generate

signal stub_packet: t_packet := ( others => '0' );
signal stub_din: t_stubTM := nulll;
signal stub_dout: lword := nulll;

begin

stub_packet <= stubs_packet( k );
stub_din <= stubs_din( k );
stubs_dout( k ) <= stub_dout;

c: tm_isolation_out_stub port map ( clk, stub_packet, stub_din, stub_dout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.emp_data_types.all;
use work.emp_project_decl.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.hybrid_data_formats.all;

entity tm_isolation_out_stub is
port (
    clk: in std_logic;
    stub_packet: in t_packet;
    stub_din: in t_stubTM;
    stub_dout: out lword
);
end;

architecture rtl of tm_isolation_out_stub is

constant widthStub: natural := 1 + widthTMstubId + widthTMr + widthTMphi + widthTMz + widthTMdPhi + widthTMdZ;

-- sr
signal sr: t_packets( PAYLOAD_LATENCY - 1 downto 0 ) := ( others => ( others => '0' ) );

-- step 1
signal din:  t_stubTM := nulll;
signal dout: lword := nulll;

function conv( s: t_stubTM ) return std_logic_vector is
begin
  return s.valid & s.stubId & s.r & s.phi & s.z & s.dPhi & s.dZ;
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
