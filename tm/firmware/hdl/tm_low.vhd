library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.tm_data_types.all;

entity tm_low is
port (
  clk: in std_logic;
  low_din: in t_trackH;
  low_dout: out t_trackL
);
end;

architecture rtl of tm_low is

signal meta_din: t_metaTB := nulll;
signal meta_dout: t_metaTB := nulll;
component low_meta
port (
  clk: in std_logic;
  meta_din: in t_metaTB;
  meta_dout: out t_metaTB
);
end component;

signal track_din: t_parameterTrackH := nulll;
signal track_valid: std_logic := '0';
signal track_dout: t_parameterTrackTM := nulll;
component low_track
port (
  clk: in std_logic;
  track_din: in t_parameterTrackH;
  track_valid: out std_logic;
  track_dout: out t_parameterTrackTM
);
end component;

signal stubs_din: t_parameterStubsH( 0 to tbNumLayers - 1 ) := ( others => nulll );
signal stubs_track: t_parameterTrackH := nulll;
signal stubs_hits: std_logic_vector( 0 to tbNumLayers - 1 ) := ( others => '0' );
signal stubs_dout: t_parameterStubsTM( 0 to tbNumLayers - 1 ) := ( others => nulll );
component low_stubs
port (
  clk: in std_logic;
  stubs_din: in t_parameterStubsH( 0 to tbNumLayers - 1 );
  stubs_track: in t_parameterTrackH;
  stubs_hits: out std_logic_vector( 0 to tbNumLayers - 1 );
  stubs_dout: out t_parameterStubsTM( 0 to tbNumLayers - 1 )
);
end component;

signal valid_din: std_logic := '0';
signal valid_hits: std_logic_vector( 0 to tbNumLayers - 1 ) := ( others => '0' );
signal valid_meta: t_metaTB := nulll;
signal valid_track: t_parameterTrackTM := nulll;
signal valid_stubs: t_parameterStubsTM( 0 to tbNumLayers - 1 ) := ( others => nulll );
signal valid_dout: t_trackL := nulll;
component low_valid
port (
  clk: in std_logic;
  valid_din: in std_logic;
  valid_hits: in std_logic_vector( 0 to tbNumLayers - 1 );
  valid_meta: in t_metaTB;
  valid_track: in t_parameterTrackTM;
  valid_stubs: in t_parameterStubsTM( 0 to tbNumLayers - 1 );
  valid_dout: out t_trackL
);
end component;

begin

meta_din <= low_din.meta;
track_din <= low_din.track;
stubs_din <= low_din.stubs;
stubs_track <= low_din.track;

valid_din <= track_valid;
valid_hits <= stubs_hits;
valid_meta <= meta_dout;
valid_track <= track_dout;
valid_stubs <= stubs_dout;

low_dout <= valid_dout;

cMeta: low_meta port map ( clk, meta_din, meta_dout );

cTrack: low_track port map ( clk, track_din, track_valid, track_dout );

cStubs: low_stubs port map ( clk, stubs_din, stubs_track, stubs_hits, stubs_dout );

cValid: low_valid port map ( clk, valid_din, valid_hits, valid_meta, valid_track, valid_stubs, valid_dout );

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.hybrid_data_types.all;
use work.tm_data_types.all;

entity low_track is
port (
  clk: in std_logic;
  track_din: in t_parameterTrackH;
  track_valid: out std_logic;
  track_dout: out t_parameterTrackTM
);
end;

architecture rtl of low_track is

-- step 1

signal inv2R, phiT, zT: std_logic := '0';
signal din: t_parameterTrackTM := nulll;

-- step 2

signal valid: std_logic := '0';
signal dout: t_parameterTrackTM := nulll;

begin

-- step 2

track_valid <= valid;
track_dout <= dout;

process ( clk ) is
begin
if rising_edge( clk ) then

  -- step 1

  din.inv2R <= track_din.inv2R( r_Linv2R );
  din.phiT <= track_din.phiT( r_LphiT );
  din.zT <= track_din.zT( r_LzT );
  inv2R <= '0';
  if not overflowed( track_din.inv2R( r_overLinv2R ) ) then
    inv2R <= '1';
  end if;
  phiT <= '0';
  if not overflowed( track_din.phiT( r_overLphiT ) ) then
    phiT <= '1';
  end if;
  zT <= '0';
  if not overflowed( track_din.zT( r_overLzT ) ) then
    zT <= '1';
  end if;

  -- step 2

  valid <= '0';
  dout <= din;
  if inv2R = '1' and phiT = '1' and zT = '1' then
    valid <= '1';
  end if;

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.tm_data_types.all;

entity low_stubs is
port (
  clk: in std_logic;
  stubs_din: in t_parameterStubsH( 0 to tbNumLayers - 1 );
  stubs_track: in t_parameterTrackH;
  stubs_hits: out std_logic_vector( 0 to tbNumLayers - 1 );
  stubs_dout: out t_parameterStubsTM( 0 to tbNumLayers - 1 )
);
end;

architecture rtl of low_stubs is

component low_stub
port (
  clk: in std_logic;
  stub_din: in t_parameterStubH;
  stub_track: in t_parameterTrackH;
  stub_valid: out std_logic;
  stub_dout: out t_parameterStubTM
);
end component;

begin

g: for k in 0 to tbNumLayers - 1 generate

signal stub_din: t_parameterStubH := nulll;
signal stub_track: t_parameterTrackH := nulll;
signal stub_valid: std_logic := '0';
signal stub_dout: t_parameterStubTM := nulll;

begin

stub_din <= stubs_din( k );
stub_track <= stubs_track;
stubs_hits( k ) <= stub_valid;
stubs_dout( k ) <= stub_dout;

c: low_stub port map ( clk, stub_din, stub_track, stub_valid, stub_dout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.tm_data_types.all;
use work.tm_data_formats.all;

entity low_stub is
port (
  clk: in std_logic;
  stub_din: in t_parameterStubH;
  stub_track: in t_parameterTrackH;
  stub_valid: out std_logic;
  stub_dout: out t_parameterStubTM
);
end;

architecture rtl of low_stub is

constant cots: t_cots := cots;

-- step 1

signal valid: std_logic := '0';
signal din: t_parameterStubH := nulll;
signal inv2R: std_logic_vector( widthLinv2R + 1 + baseShiftHinv2R - 1 downto 0 ) := ( others => '0' );
signal phiT: std_logic_vector( widthLphiT + 1 + baseShiftHphiT - 1 downto 0 ) := ( others => '0' );
signal cot: std_logic_vector( widthHcot + 1 - 1 downto 0 ) := ( others => '0' );
signal index: std_logic_vector( widthLzT - 1 downto 0 ) := ( others => '0' );
signal zT: std_logic_vector( widthLzT + 1 + baseShiftHzT - 1 downto 0 ) := ( others => '0' );
signal dspLphi: t_dspLphi := ( others => ( others => '0' ) );
signal dspLz: t_dspLz := ( others => ( others => '0' ) );

-- step 2

signal dout: t_parameterStubH := nulll;
signal phi: std_logic_vector( widthLdphi + 2 - 1 downto 0 ) := ( others => '0' );
signal z: std_logic_vector( widthLdz + 2 - 1 downto 0 ) := ( others => '0' );

begin

-- step 1

inv2R <= stub_track.inv2R( r_Linv2R ) & '1' & ( baseShiftHinv2R - 1 downto 0 => '0' );
phiT <= stub_track.phiT( r_LphiT ) & '1' & ( baseShiftHphiT - 1 downto 0 => '0' );
zT <= stub_track.zT( r_LzT ) & '1' & ( baseShiftHzT - 1 downto 0 => '0' );
index <= stub_track.zT( r_LzT );
cot <= cots( uint( index ) ) & '1';

-- step 2

phi <= ( dout.phi & '1' ) + ( dspLphi.p( r_Ldphi ) & '1' );
z <= ( dout.z & '1' ) + ( dspLz.p( r_Ldz ) & '1' );
stub_valid <= '1' when valid = '1' and not overflowed( phi( r_overLphi ) ) and not overflowed( z( r_overLz ) ) else '0';
stub_dout <= ( dout.pst, dout.stubId, dout.r( r_Lr ), phi( r_Lphi ), z( r_Lz ) );


process ( clk ) is
begin
if rising_edge( clk ) then

  -- step 1

  valid <= '0';
  if not overflowed( stub_din.r( r_overLr ) ) then
    valid <= '1';
  end if;
  din <= stub_din;
  dspLphi.a <= ( stub_track.inv2R & '1' ) - inv2R;
  dspLphi.b <= stub_din.r & '1';
  dspLphi.c <= ( ( stub_track.phiT & '1' ) - phiT ) & ( baseShiftLphiT + 1 - 1 downto 0 => '0' );
  dspLz.b <= ( stub_track.cot & '1' ) - cot;
  dspLz.a <= stub_din.r & '1';
  dspLz.c <= ( ( stub_track.zT & '1' ) - zT ) & ( baseShiftLzT + 1 - 1 downto 0 => '0' );
  dspLz.d <= stds( ( chosenRofPhi - chosenRofZ ) / baseHr, widthHr ) & '1';

  -- step 2

  dout <= din;
  dspLphi.p <= dspLphi.a * dspLphi.b + dspLphi.c;
  dspLz.p <= dspLz.b * ( dspLz.a + dspLz.d ) + dspLz.c;

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.tm_data_types.all;

entity low_meta is
port (
  clk: in std_logic;
  meta_din: in t_metaTB;
  meta_dout: out t_metaTB
);
end;

architecture rtl of low_meta is

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

  din <= meta_din;

  dout <= din;

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.tm_data_types.all;

entity low_valid is
port (
  clk: in std_logic;
  valid_din: in std_logic;
  valid_hits: in std_logic_vector( 0 to tbNumLayers - 1 );
  valid_meta: in t_metaTB;
  valid_track: in t_parameterTrackTM;
  valid_stubs: in t_parameterStubsTM( 0 to tbNumLayers - 1 );
  valid_dout: out t_trackL
);
end;

architecture rtl of low_valid is

-- step 3

signal dout: t_trackL := nulll;

begin

-- step 3

valid_dout <= dout;

process ( clk ) is
begin
if rising_edge( clk ) then

  dout <= ( valid_meta, valid_track, valid_stubs );

  if valid_meta.valid = '0' then
    dout.track <= nulll;
  end if;

  for k in 0 to tbNumLayers - 1 loop
    if valid_meta.valid = '0' or valid_meta.hits( k ) = '0' or valid_hits( k ) = '0' then
      dout.meta.hits( k ) <= '0';
      dout.stubs( k ) <= nulll;
    end if;
  end loop;

end if;
end process;

end;