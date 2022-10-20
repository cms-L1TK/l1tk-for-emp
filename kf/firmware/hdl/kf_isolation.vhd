library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.emp_device_decl.all;
use work.emp_data_types.all;

entity kf_isolation_in is
port (
  clk: in std_logic;
  in_din: in ldata( 4 * N_REGION - 1 downto 0 );
  in_dout: out t_channelsZHT( numNodesKF - 1 downto 0 )
);
end;

architecture rtl of kf_isolation_in is

component kf_isolation_in_node
port (
  clk: in std_logic;
  node_din: in ldata( numLayers + 1 - 1 downto 0 );
  node_dout: out t_channelZHT
);
end component;

begin

g: for k in 0 to numNodesKF - 1 generate

signal node_din: ldata( numLayers + 1 - 1 downto 0 ) := ( others => nulll );
signal node_dout: t_channelZHT := nulll;

begin

node_din <= in_din( ( k + 1 ) * ( numLayers + 1 ) - 1 downto k * ( numLayers + 1 ) );
in_dout( k ) <= node_dout;

c: kf_isolation_in_node port map ( clk, node_din, node_dout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.emp_data_types.all;

entity kf_isolation_in_node is
port (
  clk: in std_logic;
  node_din: in ldata( numLayers + 1 - 1 downto 0 );
  node_dout: out t_channelZHT
);
end;

architecture rtl of kf_isolation_in_node is

signal track_din: lword := nulll;
signal track_dout: t_trackZHT := nulll;
component kf_isolation_in_track
port (
  clk: in std_logic;
  track_din: in lword;
  track_dout: out t_trackZHT
);
end component;

component kf_isolation_in_stub
port (
  clk: in std_logic;
  stub_din: in lword;
  stub_dout: out t_stubZHT
);
end component;

begin

track_din <= node_din( 0 );
node_dout.track <= track_dout;

c: kf_isolation_in_track port map ( clk, track_din, track_dout );

g: for k in 0 to numLayers - 1 generate

signal stub_din: lword := nulll;
signal stub_dout: t_stubZHT := nulll;

begin

stub_din <= node_din( k + 1 );
node_dout.stubs( k ) <= stub_dout;

c: kf_isolation_in_stub port map ( clk, stub_din, stub_dout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_data_types.all;
use work.hybrid_data_formats.all;
use work.emp_data_types.all;


entity kf_isolation_in_track is
port (
  clk: in std_logic;
  track_din: in lword;
  track_dout: out t_trackZHT
);
end;

architecture rtl of kf_isolation_in_track is

-- step 1
signal din: lword := nulll;

-- step 2
signal dout: t_trackZHT := nulll;

function conv( l: std_logic_vector ) return t_trackZHT is
  variable s: t_trackZHT := nulll;
begin
  s.valid  := l( 1 + widthZHTmaybe + widthZHTsector + widthZHTphiT + widthZHTinv2R + widthZHTzT + widthZHTcot - 1 );
  s.maybe  := l(     widthZHTmaybe + widthZHTsector + widthZHTphiT + widthZHTinv2R + widthZHTzT + widthZHTcot - 1 downto widthZHTsector + widthZHTphiT + widthZHTinv2R + widthZHTzT + widthZHTcot );
  s.sector := l(                     widthZHTsector + widthZHTphiT + widthZHTinv2R + widthZHTzT + widthZHTcot - 1 downto                  widthZHTphiT + widthZHTinv2R + widthZHTzT + widthZHTcot );
  s.phiT   := l(                                      widthZHTphiT + widthZHTinv2R + widthZHTzT + widthZHTcot - 1 downto                                 widthZHTinv2R + widthZHTzT + widthZHTcot );
  s.inv2R  := l(                                                     widthZHTinv2R + widthZHTzT + widthZHTcot - 1 downto                                                 widthZHTzT + widthZHTcot );
  s.zT     := l(                                                                     widthZHTzT + widthZHTcot - 1 downto                                                              widthZHTcot );
  s.cot    := l(                                                                                  widthZHTcot - 1 downto                                                                        0 );
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
use work.hybrid_data_types.all;
use work.hybrid_data_formats.all;
use work.emp_data_types.all;

entity kf_isolation_in_stub is
port (
  clk: in std_logic;
  stub_din: in lword;
  stub_dout: out t_stubZHT
);
end;

architecture rtl of kf_isolation_in_stub is

-- step 1
signal din: lword := nulll;

-- step 2
signal dout: t_stubZHT := nulll;

function conv( l: std_logic_vector ) return t_stubZHT is
  variable s: t_stubZHT := nulll;
begin
  s.valid := l( 1 + widthZHTr + widthZHTphi + widthZHTz + widthZHTdPhi + widthZHTdZ - 1 );
  s.r     := l(     widthZHTr + widthZHTphi + widthZHTz + widthZHTdPhi + widthZHTdZ - 1 downto widthZHTphi + widthZHTz + widthZHTdPhi + widthZHTdZ );
  s.phi   := l(                 widthZHTphi + widthZHTz + widthZHTdPhi + widthZHTdZ - 1 downto               widthZHTz + widthZHTdPhi + widthZHTdZ );
  s.z     := l(                               widthZHTz + widthZHTdPhi + widthZHTdZ - 1 downto                           widthZHTdPhi + widthZHTdZ );
  s.dPhi  := l(                                           widthZHTdPhi + widthZHTdZ - 1 downto                                          widthZHTdZ );
  s.dZ    := l(                                                          widthZHTdZ - 1 downto                                                   0 );
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

  -- step 2

  dout <= nulll;
  if din.valid = '1' then
    dout <= conv( din.data );
  elsif stub_din.valid = '1' then
    dout.reset <= '1';
  end if;

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.emp_device_decl.all;
use work.emp_data_types.all;

entity kf_isolation_out is
port (
  clk: in std_logic;
  out_packet: in t_packets( numNodesKF * ( numLayers + 1 ) - 1 downto 0 );
  out_din: in t_channelsKF( numNodesKF - 1 downto 0 );
  out_dout: out ldata( 4 * N_REGION - 1 downto 0 )
);
end;

architecture rtl of kf_isolation_out is

signal dout: ldata( 4 * N_REGION - 1 downto 0 ) := ( others => nulll );
component kf_isolation_out_node
port (
  clk: in std_logic;
  node_packet: in t_packets( numLayers + 1 - 1 downto 0 );
  node_din: in t_channelKF;
  node_dout: out ldata( numLayers + 1 - 1 downto 0 )
);
end component;

begin

out_dout <= dout;

node: for k in 0 to numNodesKF - 1 generate

signal node_packet: t_packets( numLayers + 1 - 1 downto 0 ) := ( others => ( others => '0' ) );
signal node_din: t_channelKF := nulll;
signal node_dout: ldata( numLayers + 1 - 1 downto 0 ) := ( others => nulll );

begin

node_packet <= out_packet( ( k + 1 ) * ( numLayers + 1 ) - 1 downto k * ( numLayers + 1 ) );
node_din <= out_din( k );
dout( ( k + 1 ) * ( numLayers + 1 ) - 1 downto k * ( numLayers + 1 ) ) <= node_dout;

c: kf_isolation_out_node port map ( clk, node_packet, node_din, node_dout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.emp_data_types.all;

entity kf_isolation_out_node is
port (
  clk: in std_logic;
  node_packet: in t_packets( numLayers + 1 - 1 downto 0 );
  node_din: in t_channelKF;
  node_dout: out ldata( numLayers + 1 - 1 downto 0 )
);
end;

architecture rtl of kf_isolation_out_node is

signal track_packet: t_packet := ( others => '0' );
signal track_din: t_trackKF := nulll;
signal track_dout: lword := nulll;
component kf_isolation_out_track
port (
  clk: in std_logic;
  track_packet: in t_packet;
  track_din: in t_trackKF;
  track_dout: out lword
);
end component;

component kf_isolation_out_stub
port (
  clk: in std_logic;
  stub_packet: in t_packet;
  stub_din: in t_stubKF;
  stub_dout: out lword
);
end component;

begin

track_packet <= node_packet( 0 );
track_din <= node_din.track;
node_dout( 0 ) <= track_dout;

c: kf_isolation_out_track port map ( clk, track_packet, track_din, track_dout );

g: for k in 0 to numLayers - 1 generate

signal stub_packet: t_packet := ( others => '0' );
signal stub_din: t_stubKF := nulll;
signal stub_dout: lword := nulll;

begin

stub_packet <= node_packet( k + 1 );
stub_din <= node_din.stubs( k );
node_dout( k + 1 ) <= stub_dout;

c: kf_isolation_out_stub port map ( clk, stub_packet, stub_din, stub_dout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_data_types.all;
use work.hybrid_data_formats.all;
use work.emp_data_types.all;
use work.emp_project_decl.all;

entity kf_isolation_out_track is
port (
  clk: in std_logic;
  track_packet: in t_packet;
  track_din: in t_trackKF;
  track_dout: out lword
);
end;

architecture rtl of kf_isolation_out_track is

constant widthTrack: natural := 1 + 1 + widthKFsector + widthKFphiT + widthKFinv2R + widthKFcot + widthKFzT;
-- sr
signal sr: t_packets( PAYLOAD_LATENCY - 1 downto 0 ) := ( others => ( others => '0' ) );

-- step 1
signal din:  t_trackKF := nulll;
signal dout: lword := nulll;

function conv( s: t_trackKF ) return std_logic_vector is
begin
  return s.valid & s.match & s.sector & s.phiT & s.inv2R & s.cot & s.zT;
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
use work.hybrid_data_types.all;
use work.hybrid_data_formats.all;
use work.emp_data_types.all;
use work.emp_project_decl.all;

entity kf_isolation_out_stub is
port (
  clk: in std_logic;
  stub_packet: in t_packet;
  stub_din: in t_stubKF;
  stub_dout: out lword
);
end;

architecture rtl of kf_isolation_out_stub is

constant widthStub: natural := 1 + widthKFr + widthKFphi + widthKFz + widthKFdPhi + widthKFdZ;
-- sr
signal sr: t_packets( PAYLOAD_LATENCY - 1 downto 0 ) := ( others => ( others => '0' ) );

-- step 1
signal din:  t_stubKF := nulll;
signal dout: lword := nulll;

function conv( s: t_stubKF ) return std_logic_vector is
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
