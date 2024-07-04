library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.tm_data_types.all;

entity tm_high is
port (
  clk: in std_logic;
  high_din: in t_channelU;
  high_dout: out t_channelH
);
end;

architecture rtl of tm_high is

signal track_din: t_trackU := nulll;
signal track_dout: t_trackH := nulll;
component high_track
port (
  clk: in std_logic;
  track_din: in t_trackU;
  track_dout: out t_trackH
);
end component;

signal stubs_din: t_stubsU( tbNumLayers - 1 downto 0 ) := ( others => nulll );
signal stubs_dout: t_stubsH( tbNumLayers - 1 downto 0 ) := ( others => nulll );
component high_stubs
port (
  clk: in std_logic;
  stubs_din: in t_stubsU( tbNumLayers - 1 downto 0 );
  stubs_dout: out t_stubsH( tbNumLayers - 1 downto 0 )
);
end component;

begin

track_din <= high_din.track;
stubs_din <= high_din.stubs;

high_dout <= ( track_dout, stubs_dout );

cTrack: high_track port map ( clk, track_din, track_dout );

cStubs: high_stubs port map ( clk, stubs_din, stubs_dout );

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.tm_data_types.all;

entity high_stubs is
port (
  clk: in std_logic;
  stubs_din: in t_stubsU( tbNumLayers - 1 downto 0 );
  stubs_dout: out t_stubsH( tbNumLayers - 1 downto 0 )
);
end;

architecture rtl of high_stubs is

component high_stub
port (
  clk: in std_logic;
  stub_din: in t_stubU;
  stub_dout: out t_stubH
);
end component;

begin

g: for k in 0 to tbNumLayers - 1 generate

signal stub_din: t_stubU := nulll;
signal stub_dout: t_stubH := nulll;

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
  stub_din: in t_stubU;
  stub_dout: out t_stubH
);
end;

architecture rtl of high_stub is

type t_word is
record
  reset : std_logic;
  valid : std_logic;
  pst   : std_logic;
  stubId: std_logic_vector( widthStubId - 1 downto 0 );
end record;
function nulll return t_word is begin return ( '0', '0', '0', ( others => '0' ) ); end function;
type t_sr is array ( natural range <> ) of t_word;

-- step 1
signal dspHr: t_dspHr := ( others => ( others => '0' ) );
signal dspHphi: t_dspHphi := ( others => ( others => '0' ) );
signal dspHz: t_dspHz := ( others => ( others => '0' ) );
signal sr: t_sr( 3 downto 2 ) := ( others => nulll );
signal din: t_word := nulll;

-- step 3
signal dout: t_stubH := nulll;

begin

-- step 1
din <= ( stub_din.reset, stub_din.valid, stub_din.pst, stub_din.stubId );

-- step 2
stub_dout <= dout;

process ( clk ) is
begin
if rising_edge( clk ) then

  -- step 1

  dspHr.a <= stub_din.r & '1';
  dspHphi.a <= stub_din.phi & '1';
  dspHz.a <= stub_din.z & '1';
  dspHr.b <= '0' & stdu( baseTransformHr * 2.0 ** baseShiftTransformHr, widthDSPbu ) & '1';
  dspHphi.b <= '0' & stdu( baseTransformHphi * 2.0 ** baseShiftTransformHphi, widthDSPbu ) & '1';
  dspHz.b <= '0' & stdu( baseTransformHz * 2.0 ** baseShiftTransformHz, widthDSPbu ) & '1';
  sr <= sr( sr'high - 1 downto sr'low ) & din;

  -- step 2
  dspHr.p <= dspHr.a * dspHr.b;
  dspHphi.p <= dspHphi.a * dspHphi.b;
  dspHz.p <= dspHz.a * dspHz.b;

  -- step 3

  dout <= nulll;
  if sr( 3 ).reset = '1' then
    dout.reset <= '1';
  elsif sr( 3 ).valid = '1' then
    dout.valid <= '1';
    dout.pst <= sr( 3 ).pst;
    dout.stubId <= sr( 3 ).stubId;
    dout.r <= dspHr.p( r_Hr );
    dout.phi <= dspHphi.p( r_Hphi );
    dout.z <= dspHz.p( r_Hz );
  end if;

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
  track_din: in t_trackU;
  track_dout: out t_trackH
);
end;

architecture rtl of high_track is

-- step 1
signal dspHinv2R: t_dspHinv2R := ( others => ( others => '0' ) );
signal dspHphiT: t_dspHphiT := ( others => ( others => '0' ) );
signal dspHcot: t_dspHcot := ( others => ( others => '0' ) );
signal dspHzT: t_dspHzT := ( others => ( others => '0' ) );
signal sr: t_ctrls( 3 downto 2 ) := ( others => ( others => '0' ) );
signal din: t_ctrl := ( others => '0' );

-- step 3
signal dout: t_trackH := nulll;

begin

-- step 1
din <= ( track_din.reset, track_din.valid );

-- step 3
track_dout <= dout;

process ( clk ) is
begin
if rising_edge( clk ) then

  -- step 1

  dspHinv2R.a <= track_din.inv2R & '1';
  dspHphiT.a <= track_din.phiT & '1';
  dspHcot.a <= track_din.cot & '1';
  dspHzT.a <= track_din.zT & '1';
  dspHinv2R.b <= '0' & stdu( baseTransformHinv2R * 2.0 ** baseShiftTransformHinv2R, widthDSPbu ) & '1';
  dspHphiT.b <= '0' & stdu( baseTransformHphiT * 2.0 ** baseShiftTransformHphiT, widthDSPbu ) & '1';
  dspHcot.b <= '0' & stdu( baseTransformHcot * 2.0 ** baseShiftTransformHcot, widthDSPbu ) & '1';
  dspHzT.b <= '0' & stdu( baseTransformHzT * 2.0 ** baseShiftTransformHzT, widthDSPbu ) & '1';
  sr <= sr( sr'high - 1 downto sr'low ) & din;

  -- step 2

  dspHinv2R.p <= dspHinv2R.a * dspHinv2R.b;
  dspHphiT.p <= dspHphiT.a * dspHphiT.b;
  dspHcot.p <= dspHcot.a * dspHcot.b;
  dspHzT.p <= dspHzT.a * dspHzT.b;

  -- step 3

  dout <= nulll;
  if sr( 3 ).reset = '1' then
    dout.reset <= '1';
  elsif sr( 3 ).valid = '1' then
    dout.valid <= '1';
    dout.inv2R <= dspHinv2R.p( r_Hinv2R );
    dout.phiT <= dspHphiT.p( r_HphiT );
    dout.cot <= dspHcot.p( r_Hcot );
    dout.zT <= dspHzT.p( r_HzT );
  end if;

end if;
end process;

end;