library ieee;
use ieee.std_logic_1164.all;
use work.emp_device_decl.all;
use work.emp_data_types.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;

entity kfin_isolation_in is
port (
  clk: in std_logic;
  in_din: in ldata( 4 * N_REGION - 1 downto 0 );
  in_dout: out t_channlesTB( numSeedTypes - 1 downto 0 )
);
end;

architecture rtl of kfin_isolation_in is

component kfin_isolation_in_node
generic (
  seedType: natural
);
port (
  clk: in std_logic;
  node_din: in ldata( numLinksTB - 1 downto 0 );
  node_dout: out t_channelTB
);
end component;

begin

g: for k in 0 to numSeedTypes - 1 generate

signal node_din: ldata( numLinksTB - 1 downto 0 ) := ( others => ( ( others => '0' ), '0', '0', '1' ) );
signal node_dout: t_channelTB := nulll;

begin

node_din( numsProjectionLayers( k ) + 1 - 1 downto 0 ) <= in_din( limitsChannelTB( k + 1 ) - 1 downto limitsChannelTB( k ) );
in_dout( k ) <= node_dout;

c: kfin_isolation_in_node generic map ( k ) port map ( clk, node_din, node_dout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.emp_device_decl.all;
use work.emp_data_types.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;

entity kfin_isolation_in_node is
generic (
  seedType: natural
);
port (
  clk: in std_logic;
  node_din: in ldata( numLinksTB - 1 downto 0 );
  node_dout: out t_channelTB
);
end;

architecture rtl of kfin_isolation_in_node is

signal track_din: lword := ( ( others => '0' ), '0', '0', '1' );
signal track_dout: t_trackTB := nulll;
component kfin_isolation_in_track
port (
  clk: in std_logic;
  track_din: in lword;
  track_dout: out t_trackTB
);
end component;

signal stubs: t_stubsTB( node_dout.stubs'range ) := ( others => nulll );
component kfin_isolation_in_stub
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

track_din <= node_din( 0 );
node_dout <= ( track_dout, stubs );

c: kfin_isolation_in_track port map ( clk, track_din, track_dout );

g: for k in 0 to numsProjectionLayers( seedType ) - 1 generate

signal stub_din: lword := ( ( others => '0' ), '0', '0', '1' );
signal stub_dout: t_stubTB := nulll;

begin

stub_din <= node_din( k + 1 );
stubs( k ) <= stub_dout;

c: kfin_isolation_in_stub generic map ( seedTypesProjectionLayers( seedType )( k ) ) port map ( clk, stub_din, stub_dout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.emp_data_types.all;
use work.hybrid_data_types.all;
use work.hybrid_data_formats.all;

entity kfin_isolation_in_track is
port (
  clk: in std_logic;
  track_din: in lword;
  track_dout: out t_trackTB
);
end;

architecture rtl of kfin_isolation_in_track is

-- step 1
signal din: lword := ( ( others => '0' ), '0', '0', '1' );

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
use work.emp_data_types.all;
use work.hybrid_tools.all;
use work.hybrid_data_types.all;
use work.hybrid_data_formats.all;

entity kfin_isolation_in_stub is
generic (
  layer: natural
);
port (
  clk: in std_logic;
  stub_din: in lword;
  stub_dout: out t_stubTB
);
end;

architecture rtl of kfin_isolation_in_stub is

-- step 1
signal din: lword := ( ( others => '0' ), '0', '0', '1' );
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
  variable v0  : std_logic                                         := l( 1 + widthsTBr( 0 ) + widthsTBphi( 0 ) + widthsTBz( 0 ) - 1 );
  variable v1  : std_logic                                         := l( 1 + widthsTBr( 1 ) + widthsTBphi( 1 ) + widthsTBz( 1 ) - 1 );
  variable v2  : std_logic                                         := l( 1 + widthsTBr( 2 ) + widthsTBphi( 2 ) + widthsTBz( 2 ) - 1 );
  variable v3  : std_logic                                         := l( 1 + widthsTBr( 3 ) + widthsTBphi( 3 ) + widthsTBz( 3 ) - 1 );
  variable r0  : std_logic_vector( widthsTBr( 0 )   - 1 downto 0 ) := l(     widthsTBr( 0 ) + widthsTBphi( 0 ) + widthsTBz( 0 ) - 1 downto widthsTBphi( 0 ) + widthsTBz( 0 ) );
  variable r1  : std_logic_vector( widthsTBr( 1 )   - 1 downto 0 ) := l(     widthsTBr( 1 ) + widthsTBphi( 1 ) + widthsTBz( 1 ) - 1 downto widthsTBphi( 1 ) + widthsTBz( 1 ) );
  variable r2  : std_logic_vector( widthsTBr( 2 )   - 1 downto 0 ) := l(     widthsTBr( 2 ) + widthsTBphi( 2 ) + widthsTBz( 2 ) - 1 downto widthsTBphi( 2 ) + widthsTBz( 2 ) );
  variable r3  : std_logic_vector( widthsTBr( 3 )   - 1 downto 0 ) := l(     widthsTBr( 3 ) + widthsTBphi( 3 ) + widthsTBz( 3 ) - 1 downto widthsTBphi( 3 ) + widthsTBz( 3 ) );
  variable phi0: std_logic_vector( widthsTBphi( 0 ) - 1 downto 0 ) := l(                      widthsTBphi( 0 ) + widthsTBz( 0 ) - 1 downto                    widthsTBz( 0 ) );
  variable phi1: std_logic_vector( widthsTBphi( 1 ) - 1 downto 0 ) := l(                      widthsTBphi( 1 ) + widthsTBz( 1 ) - 1 downto                    widthsTBz( 1 ) );
  variable phi2: std_logic_vector( widthsTBphi( 2 ) - 1 downto 0 ) := l(                      widthsTBphi( 2 ) + widthsTBz( 2 ) - 1 downto                    widthsTBz( 2 ) );
  variable phi3: std_logic_vector( widthsTBphi( 3 ) - 1 downto 0 ) := l(                      widthsTBphi( 3 ) + widthsTBz( 3 ) - 1 downto                    widthsTBz( 3 ) );
  variable z0  : std_logic_vector( widthsTBz( 0 )   - 1 downto 0 ) := l(                                         widthsTBz( 0 ) - 1 downto                                 0 );
  variable z1  : std_logic_vector( widthsTBz( 1 )   - 1 downto 0 ) := l(                                         widthsTBz( 1 ) - 1 downto                                 0 );
  variable z2  : std_logic_vector( widthsTBz( 2 )   - 1 downto 0 ) := l(                                         widthsTBz( 2 ) - 1 downto                                 0 );
  variable z3  : std_logic_vector( widthsTBz( 3 )   - 1 downto 0 ) := l(                                         widthsTBz( 3 ) - 1 downto                                 0 );
begin
  case t is
    when 0 => s := ( '0', v0, ( others => '0' ), ( others => '0' ), resize( r0, widthTBr ), resize( phi0, widthTBphi ), resize( z0, widthTBz ) );
    when 1 => s := ( '0', v1, ( others => '0' ), ( others => '0' ), resize( r1, widthTBr ), resize( phi1, widthTBphi ), resize( z1, widthTBz ) );
    when 2 => s := ( '0', v2, ( others => '0' ), ( others => '0' ), resize( r2, widthTBr ), resize( phi2, widthTBphi ), resize( z2, widthTBz ) );
    when 3 => s := ( '0', v3, ( others => '0' ), ( others => '0' ), resize( r3, widthTBr ), resize( phi3, widthTBphi ), resize( z3, widthTBz ) );
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

entity kfin_isolation_out is
port (
  clk: in std_logic;
  out_packet: in std_logic;
  out_din: in t_channelsZHT( numSeedTypes - 1 downto 0 );
  out_dout: out ldata( 4 * N_REGION - 1 downto 0 )
);
end;

architecture rtl of kfin_isolation_out is

signal dout: ldata( 4 * N_REGION - 1 downto 0 ) := ( others => ( ( others => '0' ), '0', '0', '1' ) );
component kfin_isolation_out_node
port (
  clk: in std_logic;
  node_packet: in std_logic_vector( numLayers + 1 - 1 downto 0 );
  node_din: in t_channelZHT;
  node_dout: out ldata( numLayers + 1 - 1 downto 0 )
);
end component;

begin

out_dout <= dout;

node: for k in 0 to numSeedTypes - 1 generate

signal node_packet: std_logic_vector( numLayers + 1 - 1 downto 0 ) := ( others => '0' );
signal node_din: t_channelZHT := nulll;
signal node_dout: ldata( numLayers + 1 - 1 downto 0 ) := ( others => ( ( others => '0' ), '0', '0', '1' ) );

begin

node_packet <= ( others => out_packet );
node_din <= out_din( k );
dout( ( k + 1 ) * ( numLayers + 1 ) - 1 downto k * ( numLayers + 1 ) ) <= node_dout;

c: kfin_isolation_out_node port map ( clk, node_packet, node_din, node_dout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.emp_data_types.all;
use work.emp_project_decl.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;

entity kfin_isolation_out_node is
port (
  clk: in std_logic;
  node_packet: in std_logic_vector( numLayers + 1 - 1 downto 0 );
  node_din: in t_channelZHT;
  node_dout: out ldata( numLayers + 1 - 1 downto 0 )
);
end;

architecture rtl of kfin_isolation_out_node is

signal track_packet: std_logic := '0';
signal track_din: t_trackZHT := nulll;
signal track_dout: lword := ( ( others => '0' ), '0', '0', '1' );
component kfin_isolation_out_track
port (
  clk: in std_logic;
  track_packet: in std_logic;
  track_din: in t_trackZHT;
  track_dout: out lword
);
end component;

component kfin_isolation_out_stub
port (
  clk: in std_logic;
  stub_packet: in std_logic;
  stub_din: in t_stubZHT;
  stub_dout: out lword
);
end component;

begin

track_packet <= node_packet( 0 );
track_din <= node_din.track;
node_dout( 0 ) <= track_dout;

c: kfin_isolation_out_track port map ( clk, track_packet, track_din, track_dout );

g: for k in 0 to numLayers - 1 generate

signal stub_packet: std_logic := '0';
signal stub_din: t_stubZHT := nulll;
signal stub_dout: lword := ( ( others => '0' ), '0', '0', '1' );

begin

stub_packet <= node_packet( k + 1 );
stub_din <= node_din.stubs( k );
node_dout( k + 1 ) <= stub_dout;

c: kfin_isolation_out_stub port map ( clk, stub_packet, stub_din, stub_dout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.emp_data_types.all;
use work.emp_project_decl.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.hybrid_data_formats.all;

entity kfin_isolation_out_track is
port (
    clk: in std_logic;
    track_packet: in std_logic;
    track_din: in t_trackZHT;
    track_dout: out lword
);
end;

architecture rtl of kfin_isolation_out_track is

constant widthTrack: natural := 1 + widthZHTmaybe + widthZHTsector + widthZHTphiT + widthZHTinv2R + widthZHTzT + widthZHTcot;
--constant widthTrack: natural := 1 + widthZHTsector + widthZHTphiT + widthZHTinv2R + widthZHTzT + widthZHTcot;
-- sr
signal sr: std_logic_vector( PAYLOAD_LATENCY - 1 downto 0 ) := ( others => '0' );

-- step 1
signal din:  t_trackZHT := nulll;
signal dout: lword := ( ( others => '0' ), '0', '0', '1' );

function conv( s: t_trackZHT ) return std_logic_vector is
begin
    return s.valid & s.maybe & s.sector & s.phiT & s.inv2R & s.zT & s.cot;
    --return s.valid & s.sector & s.phiT & s.inv2R & s.zT & s.cot;
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
  if msb( sr ) = '1' then
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
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.hybrid_data_formats.all;

entity kfin_isolation_out_stub is
port (
    clk: in std_logic;
    stub_packet: in std_logic;
    stub_din: in t_stubZHT;
    stub_dout: out lword
);
end;

architecture rtl of kfin_isolation_out_stub is

constant widthStub: natural := 1 + widthZHTr + widthZHTphi + widthZHTz + widthZHTdPhi + widthZHTdZ;

-- sr
signal sr: std_logic_vector( PAYLOAD_LATENCY - 1 downto 0 ) := ( others => '0' );

-- step 1
signal din:  t_stubZHT := nulll;
signal dout: lword := ( ( others => '0' ), '0', '0', '1' );

function conv( s: t_stubZHT ) return std_logic_vector is
begin
    return s.valid & s.r & s.phi & s.z & s.dPhi & s.dZ;
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
  if msb( sr ) = '1' then
    dout.valid <= '1';
    dout.data( widthStub - 1 downto 0  ) <= conv( din );
  end if;

end if;
end process;

end;
