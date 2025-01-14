library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.tm_data_types.all;

entity tm_unify is
generic (
  seedType: natural
);
port (
  clk: in std_logic;
  unify_din: in t_trackTB;
  unify_dout: out t_trackU
);
end;

architecture rtl of tm_unify is

constant tbNumProjectionLayers: natural := tbNumsProjectionLayers( seedType );

signal meta_din: t_metaTB := nulll;
signal meta_dout: t_metaTB := nulll;
component unify_meta
port (
  clk: in std_logic;
  meta_din: in t_metaTB;
  meta_dout: out t_metaTB
);
end component;

signal track_din: t_parameterTrackTB := nulll;
signal track_valid: std_logic := '0';
signal track_dout: t_parameterTrackU := nulll;
component unify_track
port (
  clk: in std_logic;
  track_din: in t_parameterTrackTB;
  track_valid: out std_logic;
  track_dout: out t_parameterTrackU
);
end component;

signal seeds_din: t_seedsTB := nulll;
signal seeds_track: t_parameterTrackTB := nulll;
signal seeds_dout: t_parameterStubsU( 0 to tbMaxNumSeedingLayer - 1 ) := ( others => nulll );
component unify_seeds
generic (
  seedType: natural
);
port (
  clk: in std_logic;
  seeds_din: in t_seedsTB;
  seeds_track: in t_parameterTrackTB;
  seeds_dout: out t_parameterStubsU( 0 to tbMaxNumSeedingLayer - 1 )
);
end component;

signal projections_din: t_parameterStubsTB( 0 to tbMaxNumProjectionLayers - 1 ) := ( others => nulll );
signal projections_track: t_parameterTrackTB := nulll;
signal projections_dout: t_parameterStubsU( 0 to tbMaxNumProjectionLayers - 1 ) := ( others => nulll );
component unify_projections
generic (
  seedType: natural
);
port (
  clk: in std_logic;
  projections_din: in t_parameterStubsTB( 0 to tbMaxNumProjectionLayers - 1 );
  projections_track: in t_parameterTrackTB;
  projections_dout: out t_parameterStubsU( 0 to tbMaxNumProjectionLayers - 1 )
);
end component;

signal valid_din: std_logic := '0';
signal valid_meta: t_metaTB := nulll;
signal valid_track: t_parameterTrackU := nulll;
signal valid_stubs: t_parameterStubsU( 0 to tbNumLayers - 1 ) := ( others => nulll );
signal valid_dout: t_trackU := nulll;
component unify_valid
port (
  clk: in std_logic;
  valid_din: in std_logic;
  valid_meta: in t_metaTB;
  valid_track: in t_parameterTrackU;
  valid_stubs: in t_parameterStubsU( 0 to tbNumLayers - 1 );
  valid_dout: out t_trackU
);
end component;

begin

meta_din <= unify_din.meta;

track_din <= unify_din.track;

seeds_din <= unify_din.seeds;
seeds_track <= unify_din.track;

projections_din <= unify_din.stubs;
projections_track <= unify_din.track;

valid_din <= track_valid;
valid_meta <= meta_dout;
valid_track <= track_dout;
valid_stubs <= seeds_dout & projections_dout;

unify_dout <= valid_dout;

cMeta: unify_meta port map ( clk, meta_din, meta_dout );

cTrack: unify_track port map ( clk, track_din, track_valid, track_dout );

cSeed: unify_seeds Generic map ( seedType ) port map ( clk, seeds_din, seeds_track, seeds_dout );

cProjections: unify_projections generic map ( seedType ) port map ( clk, projections_din, projections_track, projections_dout );

cValid: unify_valid port map ( clk, valid_din, valid_meta, valid_track, valid_stubs, valid_dout );

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.tm_data_types.all;

entity unify_meta is
port (
  clk: in std_logic;
  meta_din: in t_metaTB;
  meta_dout: out t_metaTB
);
end;

architecture rtl of unify_meta is

-- step 1

signal din: t_metaTB := nulll;

-- step 2

signal dout: t_metaTB := nulll;

begin

-- step 2

meta_dout <= dout;

process ( clk ) is
begin
if rising_edge( clk ) then

  -- step 1

  din <= meta_din;

  -- step 2

  dout <= din;

end if;
end process;

end;

library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.tm_data_types.all;
use work.tm_data_formats.all;

entity unify_track is
port (
  clk: in std_logic;
  track_din: in t_parameterTrackTB;
  track_valid: out std_logic;
  track_dout: out t_parameterTrackU
);
end;

architecture rtl of unify_track is

-- step 1

signal dinInv2R: std_logic_vector( widthTBinv2R - 1 downto 0 ) := ( others => '0' );
signal dinCot: std_logic_vector( widthTBcot - 1 downto 0 ) := ( others => '0' );
signal phi0: std_logic_vector( widthTBphi0 - 1 downto 0 ) := ( others => '0' );
signal dspUphiT: t_dspUphiT := ( others => ( others => '0' ) );
signal dspUzT: t_dspUzT := ( others => ( others => '0' ) );

-- step 2

signal doutInv2R: std_logic_vector( widthTBinv2R - 1 downto 0 ) := ( others => '0' );
signal doutCot: std_logic_vector( widthTBcot - 1 downto 0 ) := ( others => '0' );

begin

-- step 1

phi0 <= resize( track_din.phi0 - stdu( 2 ** tbPowPhi0Shift, widthTBphi0 ), widthTBphi0 );

-- step 2

track_valid <= '0' when overflowed( dspUphiT.P( r_overUphiT ) ) or overflowed( dspUzT.P( r_overUzT ) ) else '1';
track_dout <= ( doutInv2R, dspUphiT.P( r_UphiT ), doutCot, dspUzT.P( r_UzT ) );

process ( clk ) is
begin
if rising_edge( clk ) then

  -- step 1

  dinInv2R <= not track_din.inv2R;
  dinCot <= track_din.cot;
  dspUphiT.A <= ( not track_din.inv2R ) & '1';
  dspUphiT.B <= stds( chosenRofPhi / baseUr, widthUr ) & '1';
  dspUphiT.C <= phi0 & "10" & ( baseShiftTBphi0 - baseShiftUinv2R - 1 downto 0 => '0' );
  dspUzT.A <= track_din.cot & '1';
  dspUzT.B <= stds( chosenRofZ / baseUr, widthUr ) & '1';
  dspUzT.C <= track_din.z0 & "10" & ( -baseShiftUcot - 1 downto 0 => '0' );

  -- step 2

  doutInv2R <= dinInv2R;
  doutCot <= dinCot;
  dspUphiT.P <= dspUphiT.A * dspUphiT.B + dspUphiT.C;
  dspUzT.P <= dspUzT.A * dspUzT.B + dspUzT.C;

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.hybrid_data_formats.all;
use work.tm_data_types.all;

entity unify_seeds is
generic (
  seedType: natural
);
port (
  clk: in std_logic;
  seeds_din: in t_seedsTB;
  seeds_track: in t_parameterTrackTB;
  seeds_dout: out t_parameterStubsU( 0 to tbMaxNumSeedingLayer - 1 )
);
end;

architecture rtl of unify_seeds is

component unify_barrel_seed
generic (
  index: natural
);
port (
  clk: in std_logic;
  seed_din: in std_logic_vector( widthTBstubId - 1 downto 0 );
  seed_track: in t_parameterTrackTB;
  seed_dout: out t_parameterStubU
);
end component;

component unify_disk_seed
generic (
  index: natural
);
port (
  clk: in std_logic;
  seed_din: in std_logic_vector( widthTBstubId - 1 downto 0 );
  seed_track: in t_parameterTrackTB;
  seed_dout: out t_parameterStubU
);
end component;

begin

g: for k in 0 to tbMaxNumSeedingLayer - 1 generate

constant layer: natural := seedTypesSeedLayers( seedType )( k );
signal seed_din: std_logic_vector( widthTBstubId - 1 downto 0 ) := ( others => '0' );
signal seed_track: t_parameterTrackTB := nulll;
signal seed_dout: t_parameterStubU := nulll;

begin

seed_din <= seeds_din( k );
seed_track <= seeds_track;
seeds_dout( k ) <= seed_dout;

gBarrel: if layer < 7 generate

constant index: natural := layer - 1;

begin

c: unify_barrel_seed generic map ( index ) port map ( clk, seed_din, seed_track, seed_dout );

end generate;

gDisk: if layer > 6 generate

constant index: natural := layer - 11;

begin

c: unify_disk_seed generic map ( index ) port map ( clk, seed_din, seed_track, seed_dout );

end generate;

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.tm_data_types.all;
use work.tm_data_formats.all;

entity unify_barrel_seed is
generic (
  index: natural
);
port (
  clk: in std_logic;
  seed_din: in std_logic_vector( widthTBstubId - 1 downto 0 );
  seed_track: in t_parameterTrackTB;
  seed_dout: out t_parameterStubU
);
end;

architecture rtl of unify_barrel_seed is

-- step 1

signal dinStubId: std_logic_vector( widthStubId - 1 downto 0 ) := ( others => '0' );
signal dsp: t_dspSB := ( others => ( others => '0' ) );

-- step 2

signal doutStubId: std_logic_vector( widthStubId - 1 downto 0 ) := ( others => '0' );

begin

-- step 2

seed_dout.stubId <= doutStubId;
seed_dout.pst <= '1' when index < tbNumBarrelLayersPS and uint( abs( dsp.p( r_SBz ) ) ) < digi( tbTiltedLayerLimitsZ( index ), baseUz ) else '0';
seed_dout.r <= stds( digi( tbBarrelLayersRadii( index ) - chosenRofPhi, baseUr ), widthUr ) when index > 0 or uint( abs( dsp.p( r_SBz ) ) ) < digi( halfLengthBarrel, baseUz ) else stds( digi( radiusInner - chosenRofPhi, baseUr ), widthUr );
seed_dout.phi <= ( others => '0' );
seed_dout.z <= ( others => '0' );

process( clk ) is
begin
if rising_edge( clk ) then

  -- step 1

  dinStubId <= seed_din;
  dsp.a <= seed_track.cot & '1';
  dsp.b <= '0' & stdu( digi( tbBarrelLayersRadii( index ), baseUr ), widthUr ) & '1';
  dsp.c <= seed_track.z0 & "10" & ( -baseShiftUcot - 1 downto 0 => '0' );

  -- step 2

  doutStubId <= dinStubId;
  dsp.p <= dsp.a * dsp.b + dsp.c;

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.tm_data_types.all;
use work.tm_data_formats.all;

entity unify_disk_seed is
generic (
  index: natural
);
port (
  clk: in std_logic;
  seed_din: in std_logic_vector( widthTBstubId - 1 downto 0 );
  seed_track: in t_parameterTrackTB;
  seed_dout: out t_parameterStubU
);
end;

architecture rtl of unify_disk_seed is

-- step 1

signal dinStubId: std_logic_vector( widthStubId - 1 downto 0 ) := ( others => '0' );
signal cot: std_logic_vector( widthUcot - unusedMSBScot - 1 - 1 downto 0 ) := ( others => '0' );
signal dsp: t_dspSeed := ( others => ( others => '0' ) );
signal ram: t_lutSeed := init_lutSeed;
signal disk: std_logic_vector( widthUzT - 1 downto 0 ) := stds( digi( tbDiskZs( index ), baseUzT ), widthUzT );

-- step 2

signal doutStubId: std_logic_vector( widthStubId - 1 downto 0 ) := ( others => '0' );

begin

-- step 1

cot <= abs( resize( seed_track.cot, widthUcot - unusedMSBScot ) );

-- step 2

seed_dout <= ( '1', doutStubId, dsp.p( r_Sr ), ( others => '0' ), ( others => '0' ) );

process( clk ) is
begin
if rising_edge( clk ) then

  -- step 1

  dinStubId <= seed_din;
  dsp.a <= disk & '1';
  dsp.b <= '0' & ram( uint( cot( r_Scot ) ) ) & '1';
  dsp.c <= stds( chosenRofPhi / baseUr, widthUr ) & "10" & ( baseShiftUr - baseShiftUz - baseShiftSinvCot - 1 downto 0 => '0' );
  dsp.d <= seed_track.z0 & '1';
  if seed_track.cot( widthTBcot - 1 ) = '1' then
    dsp.d <= ( not seed_track.z0 ) & '1';
  end if;

  -- step 2

  doutStubId <= dinStubId;
  dsp.p <= ( dsp.a - dsp.d ) * dsp.b - dsp.c;

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.tm_data_types.all;

entity unify_projections is
generic (
  seedType: natural
);
port (
  clk: in std_logic;
  projections_din: in t_parameterStubsTB( 0 to tbMaxNumProjectionLayers - 1 );
  projections_track: in t_parameterTrackTB;
  projections_dout: out t_parameterStubsU( 0 to tbMaxNumProjectionLayers - 1 )
);
end;

architecture rtl of unify_projections is

signal dout: t_parameterStubsU( 0 to tbMaxNumProjectionLayers - 1 ) := ( others => nulll );

component unify_barrel_projection
generic (
  index: natural
);
port (
  clk: in std_logic;
  projection_din: in t_parameterStubTB;
  projection_track: in t_parameterTrackTB;
  projection_dout: out t_parameterStubU
);
end component;

component unify_disk_projection
generic (
  index: natural
);
port (
  clk: in std_logic;
  projection_din: in t_parameterStubTB;
  projection_track: in t_parameterTrackTB;
  projection_dout: out t_parameterStubU
);
end component;

begin

projections_dout <= dout;

g: for k in 0 to tbNumsProjectionLayers( seedType ) - 1 generate

constant layer: natural := seedTypesProjectionLayers( seedType )( k );
function init_index return natural is begin if layer > 6 then return layer - 11; end if; return layer - 1; end function;
constant index: natural := init_index;
signal projection_din: t_parameterStubTB := nulll;
signal projection_track: t_parameterTrackTB := nulll;
signal projection_dout: t_parameterStubU := nulll;

begin

projection_din <= projections_din( k );
projection_track <= projections_track;
dout( k ) <= projection_dout;

gBarrel: if layer < 7 generate
c: unify_barrel_projection generic map ( index ) port map ( clk, projection_din, projection_track, projection_dout );
end generate;

gDisk: if layer > 6 generate
c: unify_disk_projection generic map ( index ) port map ( clk, projection_din, projection_track, projection_dout );
end generate;

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.tm_data_types.all;
use work.tm_data_formats.all;

entity unify_barrel_projection is
generic (
  index: natural
);
port (
  clk: in std_logic;
  projection_din: in t_parameterStubTB;
  projection_track: in t_parameterTrackTB;
  projection_dout: out t_parameterStubU
);
end;

architecture rtl of unify_barrel_projection is

function init_limit return std_logic_vector is
  variable res: std_logic_vector( widthUz - 1 downto 0 ) := ( others => '0' );
begin
  if index < tbNumBarrelLayersPS then
    res := stdu( digi( tbTiltedLayerLimitsZ( index ), baseUz ), widthUz );
  end if;
  return res;
end function;
constant limit: std_logic_vector( widthUz - 1 downto 0 ) := init_limit;

function f_prep( std: std_logic_vector; width, shift: natural ) return std_logic_vector is
  variable res: std_logic_vector( width + shift - 1 downto 0 );
begin
  case shift is
    when 0 => res := std( width - 1 downto 0 );
    when 1 => res := std( width - 1 downto 0 ) & '1';
    when others => res := std( width - 1 downto 0 ) & '1' & ( shift - 2 downto 0 => '0' );
  end case;
  return res;
end function;

function conv( s: t_parameterStubTB ) return t_parameterStubU is
  variable res: t_parameterStubU := nulll;
begin
  res.stubId := s.stubId;
  case index is
    when 0 to tbNumBarrelLayersPS - 1 =>
      res.r := resize( ( f_prep( s.r, widthsTBr( 0 ), baseShiftsTBr( 0 ) ) ) + stds( ( tbBarrelLayersRadii( index ) - chosenRofPhi ) / baseUr, widthUr ), widthUr );
      res.phi := resize( f_prep( s.phi, widthsTBphi( 0 ), baseShiftsTBphi( 0 ) ), widthUphi );
      res.z := resize( f_prep( s.z, widthsTBz( 0 ), baseShiftsTBz( 0 ) ), widthUz );
    when others =>
      res.r := resize( ( f_prep( s.r, widthsTBr( 1 ), baseShiftsTBr( 1 ) ) ) + stds( ( tbBarrelLayersRadii( index ) - chosenRofPhi ) / baseUr, widthUr ), widthUr );
      res.phi := resize( f_prep( s.phi, widthsTBphi( 1 ), baseShiftsTBphi( 1 ) ), widthUphi );
      res.z := resize( f_prep( s.z, widthsTBz( 1 ), baseShiftsTBz( 1 ) ), widthUz );
  end case;
  return res;
end function;

-- step 1

signal din, stub: t_parameterStubU := nulll;
signal z0dz: std_logic_vector( max( widthUz, widthTBz0 ) + 1 - 1 downto 0 ) := ( others => '0' );
signal dsp: t_dspPB := ( others => ( others => '0' ) );

-- step 2

signal dout: t_parameterStubU := nulll;

begin

-- step 1

stub <= conv( projection_din );
z0dz <= ( projection_track.z0 + stub.z ) + 1;

-- step 3

projection_dout.pst <= '1' when index < tbNumBarrelLayersPS and uint( abs( dsp.p( r_PBz ) ) ) < uint( limit ) else '0';
projection_dout.stubId <= dout.stubId;
projection_dout.r <= dout.r;
projection_dout.phi <= dout.phi;
projection_dout.z <= dout.z;

process ( clk ) is
begin
if rising_edge( clk ) then

  -- step 1

  din <= conv( projection_din );
  dsp.a <= stub.r & '1';
  dsp.b <= projection_track.cot & '1';
  dsp.c <= z0dz & "00" & ( -baseShiftTBCot - 1 downto 0 => '0' );
  dsp.d <= '0' & stdu( chosenRofPhi / baseUr, widthUr ) & '1';

  -- step 2

  dout <= din;
  dsp.p <= ( dsp.a + dsp.d ) * dsp.b + dsp.c;

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.tm_data_types.all;
use work.tm_data_formats.all;

entity unify_disk_projection is
generic (
  index: natural
);
port (
  clk: in std_logic;
  projection_din: in t_parameterStubTB;
  projection_track: in t_parameterTrackTB;
  projection_dout: out t_parameterStubU
);
end;

architecture rtl of unify_disk_projection is

function f_prep( std: std_logic_vector; width, shift: natural ) return std_logic_vector is
  variable res: std_logic_vector( width + shift - 1 downto 0 );
begin
  case shift is
    when 0 => res := std( width - 1 downto 0 );
    when 1 => res := std( width - 1 downto 0 ) & '1';
    when others => res := std( width - 1 downto 0 ) & '1' & ( shift - 2 downto 0 => '0' );
  end case;
  return res;
end function;

type t_ringRadii is array( natural range <> ) of std_logic_vector( widthUr - 1 downto 0 );
function init_ringRadii return t_ringRadii is
  constant rs: reals( 0 to tbNumEndcap2SRings - 1 ) := tbEndcap2SRingRaddi( index );
  variable res: t_ringRadii( rs'range );
begin
  for k in res'range loop
    res( k ) := stds( digi( rs( k ) - chosenRofPhi, baseUr ), widthUr );
  end loop;
  return res;
end function;
constant ringRaddi: t_ringRadii( 0 to tbNumEndcap2SRings - 1 ) := init_ringRadii;

function conv( msb: std_logic; s: t_parameterStubTB ) return t_parameterStubU is
  variable res: t_parameterStubU := nulll;
begin
  res.stubId := s.stubId;
  case uint( s.r( widthUr - 1 downto widthUr - widthTBstubDiksType ) ) is
    when 0 =>
      res.r := ringRaddi( uint( s.r( widthsTBr( 3 ) - 1 downto 0 ) ) );
      res.phi := resize( f_prep( s.phi, widthsTBphi( 3 ), baseShiftsTBphi( 3 ) ), widthUphi );
      res.z := resize( f_prep( s.z, widthsTBz( 3 ), baseShiftsTBz( 3 ) ) + stds( tbDiskZs( index ), baseUz, widthUz ), widthUz );
      if msb= '1' then
        res.z := resize( f_prep( s.z, widthsTBz( 3 ), baseShiftsTBz( 3 ) ) - stds( tbDiskZs( index ), baseUz, widthUz ), widthUz );
      end if;
    when others =>
      res.pst := '1';
      res.r := resize( ( '0' & f_prep( s.r, widthsTBr( 2 ), baseShiftsTBr( 2 ) ) ) - stds( chosenRofPhi, baseUr, widthUr ), widthUr );
      res.phi := resize( f_prep( s.phi, widthsTBphi( 2 ), baseShiftsTBphi( 2 ) ), widthUphi );
      res.z := resize( f_prep( s.z, widthsTBz( 2 ), baseShiftsTBz( 2 ) ) + stds( tbDiskZs( index ), baseUz, widthUz ), widthUz );
      if msb= '1' then
        res.z := resize( f_prep( s.z, widthsTBz( 2 ), baseShiftsTBz( 2 ) ) - stds( tbDiskZs( index ), baseUz, widthUz ), widthUz );
      end if;
      res.pst := '1';
  end case;
  return res;
end function;

-- step 1

signal din: t_parameterStubU := nulll;
signal dspUz: t_dspUz := ( others => ( others => '0' ) );

-- step 1

signal dout: t_parameterStubU := nulll; 

begin

-- step 2

projection_dout <= ( dout.pst, dout.stubId, dout.r, dout.phi, dspUz.p( r_Uz ) );

process ( clk ) is
begin
if rising_edge( clk ) then

  -- step 1

  din <= conv( projection_track.cot( projection_track.cot'high ), projection_din );
  dspUz.a <= not projection_track.cot & '1';
  dspUz.b <= projection_din.z & '1';

  -- step 2

  dout <= din;
  dspUz.p <= dspUz.a * dspUz.b;

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.tm_data_types.all;

entity unify_valid is
port (
  clk: in std_logic;
  valid_din: in std_logic;
  valid_meta: in t_metaTB;
  valid_track: in t_parameterTrackU;
  valid_stubs: in t_parameterStubsU( 0 to tbNumLayers - 1 );
  valid_dout: out t_trackU
);
end;

architecture rtl of unify_valid is

--   step 3

signal dout: t_trackU := nulll;

begin

-- step 3

valid_dout <= dout;

process ( clk ) is
begin
if rising_edge( clk ) then

  -- step 3

  dout <= ( valid_meta, valid_track, valid_stubs );

  if valid_din = '0' then
    dout.meta.valid <= '0';
    dout.meta.hits <= ( others => '0' );
  end if;

  if valid_din = '0' or valid_meta.valid = '0' then
    dout.track <= nulll;
  end if;

  for k in 0 to tbNumLayers - 1 loop
    if valid_din = '0' or valid_meta.valid = '0' or valid_meta.hits( k ) = '0' then
      dout.stubs( k ) <= nulll;
    end if;
  end loop;

end if;
end process;

end;
