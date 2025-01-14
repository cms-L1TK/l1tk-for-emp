library ieee;
use ieee.std_logic_1164.all;
use work.emp_device_decl.all;
use work.emp_data_types.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;

entity tm_isolation_in is
port (
  clk240: in std_logic;
  clk360: in std_logic;
  in_din: in ldata( 4 * N_REGION - 1 downto 0 );
  in_dout: out t_tracksTB( 0 to tbNumSeedTypes - 1 )
);
end;

architecture rtl of tm_isolation_in is

component tm_isolation_in_node
generic (
  seedType: natural
);
port (
  clk240: in std_logic;
  clk360: in std_logic;
  node_din: in ldata( 0 to tbNumLinks - 1 );
  node_dout: out t_trackTB
);
end component;

begin

g: for k in 0 to tbNumSeedTypes - 1 generate

signal node_din: ldata( 0 to tbNumLinks - 1 ) := ( others => nulll );
signal node_dout: t_trackTB := nulll;

constant offset: natural := tbLimitsChannel( k );
function conv ( l: ldata ) return ldata is
  variable din: ldata( 0 to tbNumLinks - 1 );
begin
  for j in 0 to 1 + tbNumsProjectionLayers( k ) + tbMaxNumSeedingLayer - 1 loop
    din( j ) := l( offset + j );
  end loop;
  return din;
end function;

begin

node_din <= conv( in_din );
in_dout( k ) <= node_dout;

c: tm_isolation_in_node generic map ( k ) port map ( clk240, clk360, node_din, node_dout );

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
  clk240: in std_logic;
  clk360: in std_logic;
  node_din: in ldata( 0 to tbNumLinks - 1 );
  node_dout: out t_trackTB
);
end;

architecture rtl of tm_isolation_in_node is

constant numProjectionLayers: natural := tbNumsProjectionLayers( seedType );

signal cdc_din: ldata( 0 to tbNumLinks - 1 ) := ( others => nulll );
signal cdc_dout: ldata( 0 to tbNumLinks - 1 ) := ( others => nulll );
component tm_isolation_in_cdc
port (
  clk240: in std_logic;
  clk360: in std_logic;
  cdc_din: in ldata( 0 to tbNumLinks - 1 );
  cdc_dout: out ldata( 0 to tbNumLinks - 1 )
);
end component;

signal track_din: lword := nulll;
signal track_reset: std_logic := '0';
signal track_valid: std_logic := '0';
signal track_dout: t_parameterTrackTB := nulll;
component tm_isolation_in_track
port (
  clk: in std_logic;
  track_din: in lword;
  track_reset: out std_logic;
  track_valid: out std_logic;
  track_dout: out t_parameterTrackTB
);
end component;

signal stubs_din: ldata( 0 to tbMaxNumProjectionLayers - 1 ) := ( others => nulll );
signal stubs_hits: std_logic_vector( 0 to tbMaxNumProjectionLayers - 1 ) := ( others => '0' );
signal stubs_dout: t_parameterStubsTB( 0 to tbMaxNumProjectionLayers - 1 ) := ( others => nulll );
component tm_isolation_in_stubs
generic (
  seedType: natural
);
port (
  clk: in std_logic;
  stubs_din: in ldata( 0 to tbMaxNumProjectionLayers - 1 );
  stubs_hits: out std_logic_vector( 0 to tbMaxNumProjectionLayers - 1 );
  stubs_dout: out t_parameterStubsTB( 0 to tbMaxNumProjectionLayers - 1 )
);
end component;

signal seeds_din: ldata( 0 to tbMaxNumSeedingLayer - 1 ) := ( others => nulll );
signal seeds_hits: std_logic_vector( 0 to tbMaxNumSeedingLayer - 1 ) := ( others => '0' );
signal seeds_dout: t_seedsTB := nulll;
component tm_isolation_in_seeds
port (
  clk: in std_logic;
  seeds_din: in ldata( 0 to tbMaxNumSeedingLayer - 1 );
  seeds_hits: out std_logic_vector( 0 to tbMaxNumSeedingLayer - 1 );
  seeds_dout: out t_seedsTB
);
end component;

function conv( hitsS, hitsP: std_logic_vector ) return std_logic_vector is
  variable hits: std_logic_vector( 0 to tbNumLayers - 1 ) := ( others => '0' );
begin
  hits( 0 to tbMaxNumSeedingLayer - 1 ) := hitsS;
  for k in 0 to numProjectionLayers - 1 loop
    hits( tbMaxNumSeedingLayer + k ) := hitsP( k );
  end loop;
  return hits;
end function;

begin

cdc_din <= node_din;

track_din <= cdc_dout( 0 );
stubs_din( 0 to numProjectionLayers - 1 ) <= cdc_dout( 1 to 1 + numProjectionLayers - 1 );
seeds_din <= cdc_dout( 1 + numProjectionLayers to 1 + numProjectionLayers + tbMaxNumSeedingLayer - 1 );

node_dout <= ( ( track_reset, track_valid, conv( seeds_hits, stubs_hits ) ), track_dout, seeds_dout, stubs_dout );

cCDC: tm_isolation_in_cdc port map ( clk240, clk360, cdc_din, cdc_dout );

cTrack: tm_isolation_in_track port map ( clk240, track_din, track_reset, track_valid, track_dout );

cStubs: tm_isolation_in_stubs generic map ( seedType ) port map ( clk240, stubs_din, stubs_hits, stubs_dout );

cSeeds: tm_isolation_in_seeds port map ( clk240, seeds_din, seeds_hits, seeds_dout );

end;


library ieee;
use ieee.std_logic_1164.all;
use work.emp_data_types.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;

entity tm_isolation_in_cdc is
port (
  clk240: in std_logic;
  clk360: in std_logic;
  cdc_din: in ldata( tbNumLinks - 1 downto 0 );
  cdc_dout: out ldata( tbNumLinks - 1 downto 0 )
);
end;

architecture rtl of tm_isolation_in_cdc is

component isolation_in_cdc_node
port (
  clk240: in std_logic;
  clk360: in std_logic;
  node_din: in lword;
  node_dout: out lword
);
end component;

begin

g: for k in 0 to tbNumLinks - 1 generate

signal node_din: lword := nulll;
signal node_dout: lword := nulll;

begin

node_din <= cdc_din( k );
cdc_dout( k ) <= node_dout;

c: isolation_in_cdc_node port map ( clk240, clk360, node_din, node_dout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.emp_data_types.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;

entity isolation_in_cdc_node is
port (
  clk240: in std_logic;
  clk360: in std_logic;
  node_din: in lword;
  node_dout: out lword
);
end;

architecture rtl of isolation_in_cdc_node is

constant widthRam: natural := LWORD_WIDTH;
constant widthAddr: natural := widthFrames;
type t_ram is array ( 0 to 2 ** widthAddr - 1 ) of std_logic_vector( widthRam - 1 downto 0 );

-- 360 step 1
signal valid: std_logic := '0';
signal waddr: std_logic_vector( widthAddr - 1 downto 0 ) := ( others => '0' );
signal ram: t_ram := ( others => ( others => '0' ) );

-- 240 step 1
signal raddr: std_logic_vector( widthAddr - 1 downto 0 ) := ( others => '0' );
signal read: lword := nulll;

-- 240 step 2
signal dout: lword := nulll;

begin

-- 240 step 2
node_dout <= dout;

process ( clk360 ) is
begin
if rising_edge( clk360 ) then

  -- step 1

  valid <= node_din.valid;
  waddr <= ( others => '0' );
  ram( uint( waddr ) ) <= node_din.data;
  if node_din.valid = '1' then
    waddr <= waddr + 1;
  end if;

end if;
end process;

process ( clk240 ) is
begin
if rising_edge( clk240 ) then

  -- step 1

  read.start <= '0';
  read.data <= ram( uint( raddr ) );
  if valid = '1' then
    read.valid <= '1';
  end if;

  -- step 2

  dout.start <= '0';
  dout.data <= read.data;
  dout.valid <= read.valid or read.start;
  if read.valid = '1' then
    raddr <= raddr + 1;
  end if;

  if uint( raddr ) = 0 and read.valid = '1' then
    dout.start <= '1';
    dout.valid <= '0';
    dout.data <= ( others => '0' );
  end if;
  if uint( raddr ) = numFramesLow - 2 then
    read.valid <= '0';
    read.start <= '1';
    raddr <= ( others => '0' );
  end if;

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.emp_data_types.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;

entity tm_isolation_in_track is
port (
  clk: in std_logic;
  track_din: in lword;
  track_reset: out std_logic;
  track_valid: out std_logic;
  track_dout: out t_parameterTrackTB
);
end;

architecture rtl of tm_isolation_in_track is

signal reset, valid: std_logic := '0';
signal dout: t_parameterTrackTB := nulll;

begin

track_reset <= reset;
track_valid <= valid;
track_dout <= dout;

process( clk ) is
begin
if rising_edge( clk ) then

  valid <= '0';
  dout <= nulll;
  reset <= track_din.start;
  if track_din.valid = '1' then
    valid         <= track_din.data( 1 + widthTBseedType + widthTBinv2R + widthTBphi0 + widthTBz0 + widthTBcot - 1 );
    dout.seedType <= track_din.data(     widthTBseedType + widthTBinv2R + widthTBphi0 + widthTBz0 + widthTBcot - 1 downto widthTBinv2R + widthTBphi0 + widthTBz0 + widthTBcot );
    dout.inv2R    <= track_din.data(                       widthTBinv2R + widthTBphi0 + widthTBz0 + widthTBcot - 1 downto                widthTBphi0 + widthTBz0 + widthTBcot );
    dout.phi0     <= track_din.data(                                      widthTBphi0 + widthTBz0 + widthTBcot - 1 downto                              widthTBz0 + widthTBcot );
    dout.z0       <= track_din.data(                                                    widthTBz0 + widthTBcot - 1 downto                                          widthTBcot );
    dout.cot      <= track_din.data(                                                                widthTBcot - 1 downto                                                   0 );
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
  stubs_din: in ldata( 0 to tbMaxNumProjectionLayers - 1 );
  stubs_hits: out std_logic_vector( 0 to tbMaxNumProjectionLayers - 1 );
  stubs_dout: out t_parameterStubsTB( 0 to tbMaxNumProjectionLayers - 1 )
);
end;

architecture rtl of tm_isolation_in_stubs is

constant numProjectionLayer: natural := tbNumsProjectionLayers( seedType );
component tm_isolation_in_stub
generic (
  layer: natural
);
port (
  clk: in std_logic;
  stub_din: in lword;
  stub_valid: out std_logic;
  stub_dout: out t_parameterStubTB
);
end component;

begin

stubs_dout( numProjectionLayer to tbMaxNumProjectionLayers - 1 ) <= ( others => nulll );

g: for k in 0 to numProjectionLayer - 1 generate

signal stub_din: lword := nulll;
signal stub_valid: std_logic := '0';
signal stub_dout: t_parameterStubTB := nulll;

begin

stub_din <= stubs_din( k );
stubs_hits( k ) <= stub_valid;
stubs_dout( k ) <= stub_dout;

c: tm_isolation_in_stub generic map ( seedTypesProjectionLayers( seedType )( k ) ) port map ( clk, stub_din, stub_valid, stub_dout );

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
  seeds_din: in ldata( 0 to tbMaxNumSeedingLayer - 1 );
  seeds_hits: out std_logic_vector( 0 to tbMaxNumSeedingLayer - 1 );
  seeds_dout: out t_seedsTB
);
end;

architecture rtl of tm_isolation_in_seeds is

component tm_isolation_in_seed
port (
  clk: in std_logic;
  seed_din: in lword;
  seed_valid: out std_logic;
  seed_dout: out std_logic_vector( widthTBstubId - 1 downto 0 )
);
end component;

begin

g: for k in 0 to tbMaxNumSeedingLayer - 1 generate

signal seed_din: lword := nulll;
signal seed_valid: std_logic := '0';
signal seed_dout: std_logic_vector( widthTBstubId - 1 downto 0 ) := ( others => '0' );

begin

seed_din <= seeds_din( k );
seeds_hits( k ) <= seed_valid;
seeds_dout( k ) <= seed_dout;

c: tm_isolation_in_seed port map ( clk, seed_din, seed_valid, seed_dout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.emp_data_types.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;

entity tm_isolation_in_seed is
port (
  clk: in std_logic;
  seed_din: in lword;
  seed_valid: out std_logic;
  seed_dout: out std_logic_vector( widthTBstubId - 1 downto 0 )
);
end;

architecture rtl of tm_isolation_in_seed is

signal valid: std_logic := '0';
signal dout: std_logic_vector( widthTBstubId - 1 downto 0 ) := ( others => '0' );

begin

seed_valid <= valid;
seed_dout <= dout;

process( clk ) is
begin
if rising_edge( clk ) then

  valid <= seed_din.data( widthTBstubId );
  dout <= seed_din.data( widthTBstubId - 1 downto 0 );

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.emp_data_types.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;

entity tm_isolation_in_stub is
generic (
  layer: natural
);
port (
  clk: in std_logic;
  stub_din: in lword;
  stub_valid: out std_logic;
  stub_dout: out t_parameterStubTB
);
end;

architecture rtl of tm_isolation_in_stub is

signal valid: std_logic := '0';
signal dout: t_parameterStubTB := nulll;

begin

stub_valid <= valid;
stub_dout <= dout;

process( clk ) is
begin
if rising_edge( clk ) then

  case layer is
    when 1 to 3 =>
      valid       <=           stub_din.data( widthTBstubId + widthsTBr( 0 ) + widthsTBphi( 0 ) + widthsTBz( 0 ) );
      dout.stubId <=           stub_din.data( widthTBstubId + widthsTBr( 0 ) + widthsTBphi( 0 ) + widthsTBz( 0 ) - 1 downto widthsTBr( 0 ) + widthsTBphi( 0 ) + widthsTBz( 0 ) );
      dout.r      <=   resize( stub_din.data(                 widthsTBr( 0 ) + widthsTBphi( 0 ) + widthsTBz( 0 ) - 1 downto                  widthsTBphi( 0 ) + widthsTBz( 0 ) ), widthTBr   );
      dout.phi    <=   resize( stub_din.data(                                  widthsTBphi( 0 ) + widthsTBz( 0 ) - 1 downto                                     widthsTBz( 0 ) ), widthTBphi );
      dout.z      <=   resize( stub_din.data(                                                     widthsTBz( 0 ) - 1 downto                                                  0 ), widthTBz   );
    when 4 to 6 =>
      valid       <=           stub_din.data( widthTBstubId + widthsTBr( 1 ) + widthsTBphi( 1 ) + widthsTBz( 1 ) );
      dout.stubId <=           stub_din.data( widthTBstubId + widthsTBr( 1 ) + widthsTBphi( 1 ) + widthsTBz( 1 ) - 1 downto widthsTBr( 1 ) + widthsTBphi( 1 ) + widthsTBz( 1 ) );
      dout.r      <=   resize( stub_din.data(                 widthsTBr( 1 ) + widthsTBphi( 1 ) + widthsTBz( 1 ) - 1 downto                  widthsTBphi( 1 ) + widthsTBz( 1 ) ), widthTBr   );
      dout.phi    <=   resize( stub_din.data(                                  widthsTBphi( 1 ) + widthsTBz( 1 ) - 1 downto                                     widthsTBz( 1 ) ), widthTBphi );
      dout.z      <=   resize( stub_din.data(                                                     widthsTBz( 1 ) - 1 downto                                                  0 ), widthTBz   );
    when 11 to 15 =>
      valid       <=           stub_din.data( widthTBstubId + widthsTBr( 2 ) + widthsTBphi( 2 ) + widthsTBz( 2 ) );
      dout.stubId <=           stub_din.data( widthTBstubId + widthsTBr( 2 ) + widthsTBphi( 2 ) + widthsTBz( 2 ) - 1 downto widthsTBr( 2 ) + widthsTBphi( 2 ) + widthsTBz( 2 ) );
      dout.r      <=   resize( stub_din.data(                 widthsTBr( 2 ) + widthsTBphi( 2 ) + widthsTBz( 2 ) - 1 downto                  widthsTBphi( 2 ) + widthsTBz( 2 ) ), widthTBr   );
      dout.phi    <=   resize( stub_din.data(                                  widthsTBphi( 2 ) + widthsTBz( 2 ) - 1 downto                                     widthsTBz( 2 ) ), widthTBphi );
      dout.z      <=   resize( stub_din.data(                                                     widthsTBz( 2 ) - 1 downto                                                  0 ), widthTBz   );
      if stub_din.data( r_stubDiskType ) = ( widthTBstubDiksType - 1 downto 0 => '0' ) then
        valid       <=         stub_din.data( widthTBstubId + widthsTBr( 3 ) + widthsTBphi( 3 ) + widthsTBz( 3 ) );
        dout.stubId <=         stub_din.data( widthTBstubId + widthsTBr( 3 ) + widthsTBphi( 3 ) + widthsTBz( 3 ) - 1 downto widthsTBr( 3 ) + widthsTBphi( 3 ) + widthsTBz( 3 ) );
        dout.r      <= resize( stub_din.data(                 widthsTBr( 3 ) + widthsTBphi( 3 ) + widthsTBz( 3 ) - 1 downto                  widthsTBphi( 3 ) + widthsTBz( 3 ) ), widthTBr   );
        dout.phi    <= resize( stub_din.data(                                  widthsTBphi( 3 ) + widthsTBz( 3 ) - 1 downto                                     widthsTBz( 3 ) ), widthTBphi );
        dout.z      <= resize( stub_din.data(                                                     widthsTBz( 3 ) - 1 downto                                                  0 ), widthTBz   );
      end if;
    when others =>
      valid <= '0';
      dout <= nulll;
  end case;

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
  out_din: in t_trackTM;
  out_dout: out ldata( 4 * N_REGION - 1 downto 0 )
);
end;

architecture rtl of tm_isolation_out is

signal track_packet: t_packet := ( others => '0' );
signal track_din: t_parameterTrackTM := nulll;
signal track_valid: std_logic := '0';
signal track_dout: lword := nulll;
component tm_isolation_out_track
port (
  clk: in std_logic;
  track_packet: in t_packet;
  track_din: in t_parameterTrackTM;
  track_valid: in std_logic;
  track_dout: out lword
);
end component;

signal stubs_packet: t_packets( 0 to tmNumLayers - 1 ) := ( others => ( others => '0' ) );
signal stubs_din: t_parameterStubsTM( 0 to tmNumLayers - 1 ) := ( others => nulll );
signal stubs_hits: std_logic_vector( 0 to tmNumLayers - 1 ) := ( others => '0' );
signal stubs_dout: ldata( 0 to tmNumLayers - 1 ) := ( others => nulll );
component tm_isolation_out_stubs
port (
  clk: in std_logic;
  stubs_packet: in t_packets( 0 to tmNumLayers - 1 );
  stubs_din: in t_parameterStubsTM( 0 to tmNumLayers - 1 );
  stubs_hits: in std_logic_vector( 0 to tmNumLayers - 1 );
  stubs_dout: out ldata( 0 to tmNumLayers - 1 )
);
end component;

function conv( track: lword; stubs: ldata ) return ldata is
  variable res: ldata( 4 * N_REGION - 1 downto 0 ) := ( others => nulll );
begin
  res( 0 ) := track;
  for k in stubs'range loop
    res( k + 1 ) := stubs( k );
  end loop;
  return res;
end function;

function conv( p: t_packets ) return t_packets is
  variable res: t_packets( 0 to tmNumLayers - 1 ) := ( others => ( others => '0' ) );
begin
  for k in 0 to tmNumLayers - 1 loop
    res( k ) := p( k + 1 );
  end loop;
  return res;
end function;

begin

track_packet <= out_packet( 0 );
track_din <= out_din.track;
track_valid <= out_din.meta.valid;

stubs_packet <= conv( out_packet );
stubs_din <= out_din.stubs;
stubs_hits <= out_din.meta.hits;

out_dout <= conv( track_dout, stubs_dout );

cTrack: tm_isolation_out_track port map ( clk, track_packet, track_din, track_valid, track_dout );

cStubs: tm_isolation_out_stubs port map ( clk, stubs_packet, stubs_din, stubs_hits, stubs_dout );

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
  track_din: in t_parameterTrackTM;
  track_valid: in std_logic;
  track_dout: out lword
);
end;

architecture rtl of tm_isolation_out_track is

constant widthTrack: natural := 1 + widthTMinv2R + widthTMphiT + widthTMzT;

-- sr
signal sr: t_packets( PAYLOAD_LATENCY - 1 downto 0 ) := ( others => ( others => '0' ) );

-- step 1
signal dout: lword := nulll;

function conv( v: std_logic; t: t_parameterTrackTM ) return std_logic_vector is
begin
  return v & t.inv2R & t.phiT & t.zT;
end function;

begin

-- step 1
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
    dout.data( widthTrack - 1 downto 0  ) <= conv( track_valid, track_din );
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
  stubs_packet: in t_packets( 0 to tmNumLayers - 1 );
  stubs_din: in t_parameterStubsTM( 0 to tmNumLayers - 1 );
  stubs_hits: in std_logic_vector( 0 to tmNumLayers - 1 );
  stubs_dout: out ldata( 0 to tmNumLayers - 1 )
);
end;

architecture rtl of tm_isolation_out_stubs is

component tm_isolation_out_stub
port (
  clk: in std_logic;
  stub_packet: in t_packet;
  stub_din: in t_parameterStubTM;
  stub_valid: in std_logic;
  stub_dout: out lword
);
end component;

begin

g: for k in 0 to tmNumLayers - 1 generate

signal stub_packet: t_packet := ( others => '0' );
signal stub_din: t_parameterStubTM := nulll;
signal stub_valid: std_logic := '0';
signal stub_dout: lword := nulll;

begin

stub_packet <= stubs_packet( k );
stub_din <= stubs_din( k );
stub_valid <= stubs_hits( k );
stubs_dout( k ) <= stub_dout;

c: tm_isolation_out_stub port map ( clk, stub_packet, stub_din, stub_valid, stub_dout );

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
  stub_din: in t_parameterStubTM;
  stub_valid: in std_logic;
  stub_dout: out lword
);
end;

architecture rtl of tm_isolation_out_stub is

constant widthStub: natural := 1 + widthTMstubId + 1 + widthTMr + widthTMphi + widthTMz;

-- sr
signal sr: t_packets( PAYLOAD_LATENCY - 1 downto 0 ) := ( others => ( others => '0' ) );

-- step 1
signal dout: lword := nulll;

function conv( v: std_logic; s: t_parameterStubTM ) return std_logic_vector is
begin
  return v & s.stubId & s.pst & s.r & s.phi & s.z;
end function;

begin

-- step 1
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
    dout.data( widthStub - 1 downto 0  ) <= conv( stub_valid, stub_din );
  end if;

end if;
end process;

end;
