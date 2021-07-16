library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.hybrid_data_formats.all;
use work.kfin_config.all;
use work.kfin_data_types.all;

entity kfin_unify is
generic (
  seedType: natural
);
port (
  clk: in std_logic;
  unify_din: in t_channelTB;
  unify_dout: out t_channelU
);
end;

architecture rtl of kfin_unify is

constant numProjectionLayers: natural := numsProjectionLayers( seedType );
signal stubs: t_stubsU( maxNumLayers - 1 downto 0 ) := ( others => nulll );

signal track_din: t_trackTB := nulll;
signal track_dout: t_trackU := nulll;
component unify_track
port (
  clk: in std_logic;
  track_din: in t_trackTB;
  track_dout: out t_trackU
);
end component;

signal seeds_din: t_trackTB := nulll;
signal seeds_dout: t_stubsU( maxNumSeedingLayer - 1 downto 0 ) := ( others => nulll );
component unify_seeds
generic (
  seedType: natural
);
port (
  clk: in std_logic;
  seeds_din: in t_trackTB;
  seeds_dout: out t_stubsU( maxNumSeedingLayer - 1 downto 0 )
);
end component;

signal projections_din: t_channelTB := nulll;
signal projections_dout: t_stubsU( maxNumProjectionLayers - 1 downto 0 ) := ( others => nulll );
component unify_projections
generic (
  seedType: natural
);
port (
  clk: in std_logic;
  projections_din: in t_channelTB;
  projections_dout: out t_stubsU( maxNumProjectionLayers - 1 downto 0 )
);
end component;

begin

track_din <= unify_din.track;
seeds_din <= unify_din.track;
projections_din <= unify_din;

stubs( maxNumSeedingLayer + numProjectionLayers - 1 downto 0 ) <= seeds_dout & projections_dout( numProjectionLayers - 1 downto 0 );

unify_dout <= ( track_dout, stubs );

cTrack: unify_track port map ( clk, track_din, track_dout );

cSeed: unify_seeds Generic map ( seedType ) port map ( clk, seeds_din, seeds_dout );

cProjections: unify_projections generic map ( seedType ) port map ( clk, projections_din, projections_dout );

end;


library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.hybrid_data_formats.all;
use work.kfin_data_types.all;
use work.kfin_data_formats.all;

entity unify_track is
port (
  clk: in std_logic;
  track_din: in t_trackTB;
  track_dout: out t_trackU
);
end;

architecture rtl of unify_track is

type t_word is
record
  reset: std_logic;
  valid: std_logic;
  inv2R: std_logic_vector( widthTBinv2R - 1 downto 0 );
  cot: std_logic_vector( widthTBcot - 1 downto 0 );
end record;
type t_sr is array ( natural range <> ) of t_word;
function nulll return t_word is begin return ( '0', '0', others => ( others => '0' ) ); end function;

-- step 1
signal valid: std_logic := '0';
signal phi0: std_logic_vector( widthTBphi0 - 1 downto 0 ) := ( others => '0' );
signal dspUphiT: t_dspUphiT := ( others => ( others => '0' ) );
signal dspUzT: t_dspUzT := ( others => ( others => '0' ) );
signal sr: t_sr( 3 downto 2 ) := ( others => nulll );
signal t: t_word := nulll;

-- step 3
signal validOver, validRange: std_logic := '0';
signal w: t_word := nulll;
signal dout: t_trackU := nulll;

begin

-- step 1
valid <= track_din.valid when uint( abs( track_din.z0 ) ) < int( beamWindowZ, baseUzT ) else '0';
phi0 <= resize( track_din.phi0 - stdu( 2 ** powPhi0Shift, widthTBphi0 ), widthTBphi0 );
t <= ( track_din.reset, valid, not track_din.inv2R, track_din.cot );
-- step 3
validOver <= '0' when overflowed( dspUphiT.P( r_overUphiT ) ) or overflowed( dspUzT.P( r_overUzT ) ) else '1';
validRange <= '1' when uint( abs( dspUphiT.P( r_UphiT ) ) ) < int( maxUphiT, baseUphiT )
                  and  uint( abs( dspUzT.P  ( r_UzT   ) ) ) < int( maxUzT,   baseUzT   ) else '0';
w <= sr( 3 );
track_dout <= dout;

process ( clk ) is
begin
if rising_edge( clk ) then

  -- step 1

  dspUphiT.A <= ( not track_din.inv2R ) & '1';
  dspUphiT.B <= stds( chosenRofPhi / baseUr, widthUr ) & '1';
  dspUphiT.C <= phi0 & "10" & ( baseShiftTBphi0 - baseShiftUinv2R - 1 downto 0 => '0' );
  dspUzT.A <= track_din.cot & '1';
  dspUzT.B <= stds( chosenRofZ / baseUr, widthUr ) & '1';
  dspUzT.C <= track_din.z0 & "10" & ( -baseShiftUcot - 1 downto 0 => '0' );
  sr <= sr( sr'high - 1 downto sr'low ) & t;

  -- step 2

  dspUphiT.P <= dspUphiT.A * dspUphiT.B + dspUphiT.C;
  dspUzT.P <= dspUzT.A * dspUzT.B + dspUzT.C;

  -- step 3

  dout <= nulll;
  if w.reset = '1' then
    dout.reset <= '1';
  elsif w.valid = '1' and validOver = '1' and validRange = '1' then
    dout .valid <= '1';
    dout.inv2R <= w.inv2R;
    dout.phiT <= dspUphiT.P( r_UphiT );
    dout.cot <= w.cot;
    dout.zT <= dspUzT.P( r_UzT );
  end if;

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.hybrid_data_formats.all;
use work.kfin_data_types.all;

entity unify_seeds is
generic (
  seedType: natural
);
port (
  clk: in std_logic;
  seeds_din: in t_trackTB;
  seeds_dout: out t_stubsU( maxNumSeedingLayer - 1 downto 0 )
);
end;

architecture rtl of unify_seeds is

component unify_barrel_seed
generic (
  index: natural
);
port (
  clk: in std_logic;
  seed_din: in t_trackTB;
  seed_dout: out t_stubU
);
end component;

component unify_disk_seed
generic (
  index: natural
);
port (
  clk: in std_logic;
  seed_din: in t_trackTB;
  seed_dout: out t_stubU
);
end component;

begin

g: for k in 0 to maxNumSeedingLayer - 1 generate

constant layer: natural := seedTypesSeedLayers( seedType )( k );
function init_index return natural is begin if layer > 6 then return layer - 11; end if; return layer - 1; end function;
constant index: natural := init_index;
signal seed_din: t_trackTB := nulll;
signal seed_dout: t_stubU := nulll;

begin

seed_din <= seeds_din;
seeds_dout( k ) <= seed_dout;

gBarrel: if layer < 7 generate

c: unify_barrel_seed generic map ( index ) port map ( clk, seed_din, seed_dout );

end generate;

gDisk: if layer > 6 generate

c: unify_disk_seed generic map ( index ) port map ( clk, seed_din, seed_dout );

end generate;

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.hybrid_data_formats.all;
use work.kfin_data_types.all;
use work.kfin_data_formats.all;

entity unify_barrel_seed is
generic (
  index: natural
);
port (
  clk: in std_logic;
  seed_din: in t_trackTB;
  seed_dout: out t_stubU
);
end;

architecture rtl of unify_barrel_seed is

-- step 1
signal din: t_ctrl := ( others => '0' );
signal sr: t_ctrls( 3 downto 2 ) := ( others => ( others => '0' ) );
signal dsp: t_dspSB := ( others => ( others => '0' ) );

-- step 3
function init_limit return std_logic_vector is
  variable res: std_logic_vector( widthUz - 1 downto 0 ) := ( others => '0' );
begin
  if index < numBarrelLayersPS then
    res := stdu( int( tiltedLayerLimitsZ( index ), baseUz ), widthUz );
  end if;
  return res;
end function;
constant limit: std_logic_vector( widthUz - 1 downto 0 ) := init_limit;
signal z: std_logic_vector( widthSBz - 1 - 1 downto 0 ) := ( others => '0' );
signal dout: t_stubU := nulll;

begin

-- step 1
din <= ( seed_din.reset, seed_din.valid );

-- step 3
z <= abs( dsp.p( r_SBz ) );
seed_dout <= dout;

process( clk ) is
begin
if rising_edge( clk ) then

  -- step 1

  sr <= sr( sr'high - 1 downto sr'low) & din;
  dsp.a <= seed_din.cot & '1';
  dsp.b <= '0' & stdu( barrelLayersRadii( index ) / baseUr, widthUr ) & '1';
  dsp.c <= seed_din.z0 & "10" & ( -baseShiftUcot - 1 downto 0 => '0' );

  -- step 2

  dsp.p <= dsp.a * dsp.b + dsp.c;

  -- step 3

  dout <= nulll;
  if sr( 3 ).reset = '1' then
    dout.reset <= '1';
  elsif sr( 3 ).valid = '1' then
    dout.valid <= '1';
    dout.r <= stds( ( barrelLayersRadii( index ) - chosenRofPhi ) / baseUr, widthUr );
    if index < numBarrelLayersPS and unsigned( z ) < unsigned( limit ) then
     dout.pst <= '1';
    end if;
  end if;

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.hybrid_data_formats.all;
use work.kfin_data_types.all;
use work.kfin_data_formats.all;

entity unify_disk_seed is
generic (
  index: natural
);
port (
  clk: in std_logic;
  seed_din: in t_trackTB;
  seed_dout: out t_stubU
);
end;

architecture rtl of unify_disk_seed is

attribute ram_style: string;

-- step 1
signal din: t_ctrl := ( others => '0' );
signal sr: t_ctrls( 3 downto 2 ) := ( others => ( others => '0' ) );
signal cot: std_logic_vector( widthUcot - unusedMSBScot - 1 - 1 downto 0 ) := ( others => '0' );
signal invCot: std_logic_vector( widthDSPbu - 1 downto 0 ) := ( others => '0' );
signal dsp: t_dspSeed := ( others => ( others => '0' ) );
signal ram: t_lutSeed := init_lutSeed;
attribute ram_style of ram: signal is "block";

-- step 2
signal reset, valid: std_logic := '0';

-- step 3
signal dout: t_stubU := nulll;

begin

-- step 1
din <= ( seed_din.reset, seed_din.valid );
cot <= abs( resize( seed_din.cot, widthUcot - unusedMSBScot ) );

-- step 2
dsp.b <= '0' & invCot & '1';

-- step 3
seed_dout <= dout;

process( clk ) is
begin
if rising_edge( clk ) then

  -- step 1

  sr <= sr( sr'high - 1 downto sr'low ) & din;
  invCot <= ram( uint( cot( r_Scot ) ) );
  dsp.a <= seed_din.z0 & '1';
  dsp.c <= stds( chosenRofPhi / baseUr, widthUr ) & "10" & ( baseShiftUr - baseShiftUz - baseShiftSinvCot - 1 downto 0 => '0' );
  dsp.d <= stds( diskZs( index ) / baseUzT, widthUzT ) & '1';

  -- step 2

  dsp.p <= ( dsp.a + dsp.d ) * dsp.b - dsp.c;

  -- step 3

  dout <= nulll;
  if sr( 3 ).reset = '1' then
    dout.reset <= '1';
  elsif sr( 3 ).valid = '1' then
    dout.valid <= '1';
    dout.r <= dsp.p( r_Sr );
    --if sint( dsp.p( r_Sr ) ) < int( ( psDiskLimitR( index ) - chosenRofPhi ), baseUr ) then
      dout.pst <= '1';
    --end if;
  end if;

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.hybrid_data_formats.all;
use work.kfin_data_types.all;

entity unify_projections is
generic (
  seedType: natural
);
port (
  clk: in std_logic;
  projections_din: in t_channelTB;
  projections_dout: out t_stubsU( maxNumProjectionLayers - 1 downto 0 )
);
end;

architecture rtl of unify_projections is

signal dout: t_stubsU( maxNumProjectionLayers - 1 downto 0 ) := ( others => nulll );

component unify_barrel_projection
generic (
  index: natural
);
port (
  clk: in std_logic;
  projection_track: in t_trackTB;
  projection_din: in t_stubTB;
  projection_dout: out t_stubU
);
end component;

component unify_disk_projection
generic (
  index: natural
);
port (
  clk: in std_logic;
  projection_track: in t_trackTB;
  projection_din: in t_stubTB;
  projection_dout: out t_stubU
);
end component;

begin

projections_dout <= dout;

g: for k in 0 to numsProjectionLayers( seedType ) - 1 generate

constant layer: natural := seedTypesProjectionLayers( seedType )( k );
function init_index return natural is begin if layer > 6 then return layer - 11; end if; return layer - 1; end function;
constant index: natural := init_index;
signal projection_track: t_trackTB := nulll;
signal projection_din: t_stubTB := nulll;
signal projection_dout: t_stubU := nulll;

begin

projection_track <= projections_din.track;
projection_din <= projections_din.stubs( k );
dout( k ) <= projection_dout;

gBarrel: if layer < 7 generate
c: unify_barrel_projection generic map ( index ) port map ( clk, projection_track, projection_din, projection_dout );
end generate;

gDisk: if layer > 6 generate
c: unify_disk_projection generic map ( index ) port map ( clk, projection_track, projection_din, projection_dout );
end generate;

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.hybrid_data_formats.all;
use work.kfin_config.all;
use work.kfin_data_types.all;
use work.kfin_data_formats.all;

entity unify_barrel_projection is
generic (
  index: natural
);
port (
  clk: in std_logic;
  projection_track: in t_trackTB;
  projection_din: in t_stubTB;
  projection_dout: out t_stubU
);
end;

architecture rtl of unify_barrel_projection is

function f_stubType( s: t_stubTB ) return natural is
  variable stubtype: natural;
begin
  case index is
    when 0 to numBarrelLayersPS - 1 => stubType := 0;
    when others => stubType := 1;
  end case;
  return stubType;
end function;

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

function conv( s: t_stubTB ) return t_stubU is
  variable res: t_stubU := nulll;
  variable stubType: natural := f_stubType( s );
begin
  if s.reset = '1' then
    res.reset := '1';
  elsif s.valid = '1' then
    res.valid := '1';
    case stubType is
      when 0 =>
        res.r := resize( ( f_prep( s.r, widthsTBr( 0 ), baseShiftsTBr( 0 ) ) ) + stds( ( barrelLayersRadii( index ) - chosenRofPhi ) / baseUr, widthUr ), widthUr );
        res.phi := resize( f_prep( s.phi, widthsTBphi( 0 ), baseShiftsTBphi( 0 ) ), widthUphi );
        res.z := resize( f_prep( s.z, widthsTBz( 0 ), baseShiftsTBz( 0 ) ), widthUz );
      when 1 =>
        res.r := resize( ( f_prep( s.r, widthsTBr( 1 ), baseShiftsTBr( 1 ) ) ) + stds( ( barrelLayersRadii( index ) - chosenRofPhi ) / baseUr, widthUr ), widthUr );
        res.phi := resize( f_prep( s.phi, widthsTBphi( 1 ), baseShiftsTBphi( 1 ) ), widthUphi );
        res.z := resize( f_prep( s.z, widthsTBz( 1 ), baseShiftsTBz( 1 ) ), widthUz );
      when others => null;
    end case;
  end if;
  return res;
end function;

-- step 1
signal din: t_stubU := nulll;
signal sr: t_stubsU( 3 downto 2 ) := ( others => nulll );
signal z0dz: std_logic_vector( max( widthUz, widthTBz0 ) + 1 - 1 downto 0 ) := ( others => '0' );
signal dsp: t_dspPB := ( others => ( others => '0' ) );

-- step 3
function init_limit return std_logic_vector is
  variable res: std_logic_vector( widthUz - 1 downto 0 ) := ( others => '0' );
begin
  if index < numBarrelLayersPS then
    res := stdu( int( tiltedLayerLimitsZ( index ), baseUz ), widthUz );
  end if;
  return res;
end function;
constant limit: std_logic_vector( widthUz - 1 downto 0 ) := init_limit;
signal z: std_logic_vector( widthPBz - 1 - 1 downto 0 ) := ( others => '0' );
signal dout: t_stubU := nulll;

begin

-- step 1
din <= conv( projection_din );
z0dz <= incr(projection_track.z0 + din.z);

-- step 3
z <= abs( dsp.p( r_PBz ) );
projection_dout <= dout;

process ( clk ) is
begin
if rising_edge( clk ) then

  -- step 1

  sr <= sr( sr'high - 1 downto sr'low ) & din;
  dsp.a <= din.r & '1';
  dsp.b <= projection_track.cot & '1';
  dsp.c <= z0dz & "00" & ( -baseShiftTBCot - 1 downto 0 => '0' );
  dsp.d <= '0' & stdu( chosenRofPhi / baseUr, widthUr ) & '1';

  -- step 2

  dsp.p <= ( dsp.a + dsp.d ) * dsp.b + dsp.c;

  -- step 3

  dout <= nulll;
  if sr( 3 ).reset = '1' then
    dout. reset <= '1';
  elsif sr( 3 ).valid = '1' then
    dout.valid <= '1';
    dout.r <= sr( 3 ).r;
    dout.phi <= sr( 3 ).phi;
    dout.z <= sr( 3 ).z;
    if index < numBarrelLayersPS and unsigned( z ) < unsigned( limit ) then
      dout.pst <= '1';
    end if; 
  end if;

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.hybrid_data_formats.all;
use work.kfin_config.all;
use work.kfin_data_types.all;
use work.kfin_data_formats.all;

entity unify_disk_projection is
generic (
  index: natural
);
port (
  clk: in std_logic;
  projection_track: in t_trackTB;
  projection_din: in t_stubTB;
  projection_dout: out t_stubU
);
end;

architecture rtl of unify_disk_projection is

type t_word is
record
  reset: std_logic;
  valid: std_logic;
  pst: std_logic;
  r: std_logic_vector( widthUr - 1 downto 0 );
  phi: std_logic_vector( widthUphi - 1 downto 0 );
end record;
type t_sr is array ( natural range <> ) of t_word;
function nulll return t_word is begin return ( '0', '0', '0', others => ( others => '0' ) ); end function;

function f_stubType( s: t_stubTB ) return natural is
  variable stubtype: natural := 2;
begin
  if uint( s.r( widthUr - 1 downto widthUr - widthTBstubDiksType ) ) = 0 then
    stubType := 3;
  end if;
  return stubType;
end function;

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
  constant rs: reals( 0 to numEndcap2SRings - 1 ) := endcap2SRingRaddi( index );
  variable res: t_ringRadii( rs'range );
begin
  for k in res'range loop
    res( k ) := stds( ( rs( k ) - chosenRofPhi ) / baseUr, widthUr );
  end loop;
  return res;
end function;
constant ringRaddi: t_ringRadii( 0 to numEndcap2SRings - 1 ) := init_ringRadii;

function conv( msb: std_logic; s: t_stubTB ) return t_stubU is
  variable res: t_stubU := nulll;
  variable stubType: natural := f_stubType( s );
begin
  res.reset := s.reset;
  res.valid := s.valid;
  case stubType is
    when 2 =>
      res.pst := '1';
      res.r := resize( ( '0' & f_prep( s.r, widthsTBr( 2 ), baseShiftsTBr( 2 ) ) ) - stds( chosenRofPhi / baseUr, widthUr ), widthUr );
      res.phi := resize( f_prep( s.phi, widthsTBphi( 2 ), baseShiftsTBphi( 2 ) ), widthUphi );
      res.z := resize( f_prep( s.z, widthsTBz( 2 ), baseShiftsTBz( 2 ) ) + stds( diskZs( index ) / baseUz, widthUz ), widthUz );
      if msb= '1' then
        res.z := resize( f_prep( s.z, widthsTBz( 2 ), baseShiftsTBz( 2 ) ) - stds( diskZs( index ) / baseUz, widthUz ), widthUz );
      end if;
      res.pst := '1';
    when 3 =>
      res.r := ringRaddi( uint( s.r( widthsTBr( 3 ) - 1 downto 0 ) ) );
      res.phi := resize( f_prep( s.phi, widthsTBphi( 3 ), baseShiftsTBphi( 3 ) ), widthUphi );
      res.z := resize( f_prep( s.z, widthsTBz( 3 ), baseShiftsTBz( 3 ) ) + stds( diskZs( index ) / baseUz, widthUz ), widthUz );
      if msb= '1' then
        res.z := resize( f_prep( s.z, widthsTBz( 3 ), baseShiftsTBz( 3 ) ) - stds( diskZs( index ) / baseUz, widthUz ), widthUz );
      end if;
    when others => null;
  end case;
  return res;
end function;

-- step 1
signal stubU: t_stubU := nulll;
signal d: t_word := nulll;
signal sr: t_sr( 3 downto 2 ) := ( others => nulll );
signal dspUz: t_dspUz := ( others => ( others => '0' ) );
signal cot: std_logic_vector( widthTBcot - 1 downto 0 ) := ( others => '0' ); 

-- step 3
signal dout: t_stubU := nulll;

begin

-- step 1
cot <= projection_track.cot;
stubU <= conv( msb( cot ), projection_din );
d <= ( stubU.reset, stubU.valid, stubU.pst, stubU.r, stubU.phi );
-- step 3
projection_dout <= dout;

process ( clk ) is
begin
if rising_edge( clk ) then

  -- step 1

  dspUz.a <= not cot & '1';
  dspUz.b <= projection_din.z & '1';
  sr <= sr( sr'high - 1 downto sr'low ) & d;

  -- step 2

  dspUz.p <= dspUz.a * dspUz.b;

  -- step 3

  dout <= nulll;
  if sr( 3 ).reset = '1' then
    dout.reset <= '1';
  elsif sr( 3 ).valid = '1' then
    dout.valid <= '1';
    dout.pst <= sr( 3 ).pst;
    dout.r <= sr( 3 ).r;
    dout.phi <= sr( 3 ).phi;
    dout.z <= dspUz.p( r_Uz );
  end if;

end if;
end process;

end;