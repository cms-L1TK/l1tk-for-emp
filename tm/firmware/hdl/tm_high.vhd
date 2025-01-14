library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.tm_data_types.all;

entity tm_high is
port (
  clk: in std_logic;
  high_din: in t_trackU;
  high_dout: out t_trackH
);
end;

architecture rtl of tm_high is

signal meta_din: t_metaTB := nulll;
signal meta_dout: t_metaTB := nulll;
component high_meta
port (
  clk: in std_logic;
  meta_din: in t_metaTB;
  meta_dout: out t_metaTB
);
end component;

signal track_din: t_parameterTrackU := nulll;
signal track_dout: t_parameterTrackH := nulll;
component high_track
port (
  clk: in std_logic;
  track_din: in t_parameterTrackU;
  track_dout: out t_parameterTrackH
);
end component;

signal stubs_din: t_parameterStubsU( 0 to tbNumLayers - 1 ) := ( others => nulll );
signal stubs_dout: t_parameterStubsH( 0 to tbNumLayers - 1 ) := ( others => nulll );
component high_stubs
port (
  clk: in std_logic;
  stubs_din: in t_parameterStubsU( 0 to tbNumLayers - 1);
  stubs_dout: out t_parameterStubsH( 0 to tbNumLayers - 1 )
);
end component;

signal valid_meta: t_metaTB := nulll;
signal valid_track: t_parameterTrackH := nulll;
signal valid_stubs: t_parameterStubsH( 0 to tbNumLayers - 1 ) := ( others => nulll );
signal valid_dout: t_trackH := nulll;
component high_valid
port (
  clk: in std_logic;
  valid_meta: in t_metaTB;
  valid_track: in t_parameterTrackH;
  valid_stubs: in t_parameterStubsH( 0 to tbNumLayers - 1 );
  valid_dout: out t_trackH
);
end component;

begin

meta_din <= high_din.meta;
track_din <= high_din.track;
stubs_din <= high_din.stubs;

valid_meta <= meta_dout;
valid_track <= track_dout;
valid_stubs <= stubs_dout;

high_dout <= valid_dout;

cMeta: high_meta port map ( clk, meta_din, meta_dout );

cTrack: high_track port map ( clk, track_din, track_dout );

cStubs: high_stubs port map ( clk, stubs_din, stubs_dout );

cValid: high_valid port map ( clk, valid_meta, valid_track, valid_stubs, valid_dout );

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.tm_data_types.all;

entity high_stubs is
port (
  clk: in std_logic;
  stubs_din: in t_parameterStubsU( 0 to tbNumLayers - 1);
  stubs_dout: out t_parameterStubsH( 0 to tbNumLayers - 1 )
);
end;

architecture rtl of high_stubs is

component high_stub
port (
  clk: in std_logic;
  stub_din: in t_parameterStubU;
  stub_dout: out t_parameterStubH
);
end component;

begin

g: for k in 0 to tbNumLayers - 1 generate

signal stub_din: t_parameterStubU := nulll;
signal stub_dout: t_parameterStubH := nulll;

begin

stub_din <= stubs_din( k );
stubs_dout( k ) <= stub_dout;

c: high_stub port map ( clk, stub_din, stub_dout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.hybrid_tools.all;
use work.tm_data_types.all;
use work.tm_data_formats.all;

entity high_stub is
port (
  clk: in std_logic;
  stub_din: in t_parameterStubU;
  stub_dout: out t_parameterStubH
);
end;

architecture rtl of high_stub is

-- step 1

signal dinPst: std_logic := '0';
signal dinStubId: std_logic_vector( widthStubId - 1 downto 0 ) := ( others => '0' );
signal dspHr: t_dspHr := ( others => ( others => '0' ) );
signal dspHphi: t_dspHphi := ( others => ( others => '0' ) );
signal dspHz: t_dspHz := ( others => ( others => '0' ) );

-- step 1

signal doutPst: std_logic := '0';
signal doutStubId: std_logic_vector( widthStubId - 1 downto 0 ) := ( others => '0' );

begin

-- step 2

stub_dout <= ( doutPst, doutStubId, dspHr.p( r_Hr ), dspHphi.p( r_Hphi ), dspHz.p( r_Hz ) );

process ( clk ) is
begin
if rising_edge( clk ) then

  -- step 1

  dinPst <= stub_din.pst;
  dinStubId <= stub_din.stubId;
  dspHr.a <= stub_din.r & '1';
  dspHphi.a <= stub_din.phi & '1';
  dspHz.a <= stub_din.z & '1';
  dspHr.b <= '0' & stdu( baseTransformHr * 2.0 ** baseShiftTransformHr, dspWidthBu ) & '1';
  dspHphi.b <= '0' & stdu( baseTransformHphi * 2.0 ** baseShiftTransformHphi, dspWidthBu ) & '1';
  dspHz.b <= '0' & stdu( baseTransformHz * 2.0 ** baseShiftTransformHz, dspWidthBu ) & '1';

  -- step 2

  doutPst <= dinPst;
  doutStubId <= dinStubId;
  dspHr.p <= dspHr.a * dspHr.b;
  dspHphi.p <= dspHphi.a * dspHphi.b;
  dspHz.p <= dspHz.a * dspHz.b;

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.hybrid_tools.all;
use work.tm_data_types.all;
use work.tm_data_formats.all;

entity high_track is
port (
  clk: in std_logic;
  track_din: in t_parameterTrackU;
  track_dout: out t_parameterTrackH
);
end;

architecture rtl of high_track is

-- step 1

signal dspHinv2R: t_dspHinv2R := ( others => ( others => '0' ) );
signal dspHphiT: t_dspHphiT := ( others => ( others => '0' ) );
signal dspHcot: t_dspHcot := ( others => ( others => '0' ) );
signal dspHzT: t_dspHzT := ( others => ( others => '0' ) );

begin

-- step 2

track_dout.inv2R <= dspHinv2R.p( r_Hinv2R );
track_dout.phiT <= dspHphiT.p( r_HphiT );
track_dout.cot <= dspHcot.p( r_Hcot );
track_dout.zT <= dspHzT.p( r_HzT );

process ( clk ) is
begin
if rising_edge( clk ) then

  -- step 1

  dspHinv2R.a <= track_din.inv2R & '1';
  dspHphiT.a <= track_din.phiT & '1';
  dspHcot.a <= track_din.cot & '1';
  dspHzT.a <= track_din.zT & '1';
  dspHinv2R.b <= '0' & stdu( baseTransformHinv2R * 2.0 ** baseShiftTransformHinv2R, dspWidthBu ) & '1';
  dspHphiT.b <= '0' & stdu( baseTransformHphiT * 2.0 ** baseShiftTransformHphiT, dspWidthBu ) & '1';
  dspHcot.b <= '0' & stdu( baseTransformHcot * 2.0 ** baseShiftTransformHcot, dspWidthBu ) & '1';
  dspHzT.b <= '0' & stdu( baseTransformHzT * 2.0 ** baseShiftTransformHzT, dspWidthBu ) & '1';

  -- step 2

  dspHinv2R.p <= dspHinv2R.a * dspHinv2R.b;
  dspHphiT.p <= dspHphiT.a * dspHphiT.b;
  dspHcot.p <= dspHcot.a * dspHcot.b;
  dspHzT.p <= dspHzT.a * dspHzT.b;

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.tm_data_types.all;

entity high_meta is
port (
  clk: in std_logic;
  meta_din: in t_metaTB;
  meta_dout: out t_metaTB
);
end;

architecture rtl of high_meta is

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
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.tm_data_types.all;

entity high_valid is
port (
  clk: in std_logic;
  valid_meta: in t_metaTB;
  valid_track: in t_parameterTrackH;
  valid_stubs: in t_parameterStubsH( 0 to tbNumLayers - 1 );
  valid_dout: out t_trackH
);
end;

architecture rtl of high_valid is

-- step 3

signal dout: t_trackH := nulll;

begin

-- step 3

valid_dout <= dout;

process ( clk ) is
begin
if rising_edge( clk ) then

  -- step 3

  dout <= ( valid_meta, valid_track, valid_stubs );

  if valid_meta.valid = '0' then
    dout.track <= nulll;
    dout.stubs <= ( others => nulll );
  end if;

end if;
end process;

end;