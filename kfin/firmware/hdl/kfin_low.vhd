library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.kfin_data_types.all;

entity kfin_low is
port (
  clk: in std_logic;
  low_din: in t_channelS;
  low_dout: out t_channelL
);
end;

architecture rtl of kfin_low is

signal track_din: t_trackS := nulll;
signal track_dout: t_trackL := nulll;
component low_track
port (
  clk: in std_logic;
  track_din: in t_trackS;
  track_dout: out t_trackL
);
end component;

signal stubs_din: t_channelS := nulll;
signal stubs_dout: t_stubsL( maxNumLayers - 1 downto 0 ) := ( others => nulll );
component low_stubs
port (
  clk: in std_logic;
  stubs_din: in t_channelS;
  stubs_dout: out t_stubsL( maxNumLayers - 1 downto 0 )
);
end component;

begin

track_din <= low_din.track;
stubs_din <= low_din;

low_dout <= ( track_dout, stubs_dout );

cTrack: low_track port map ( clk, track_din, track_dout );

cStubs: low_stubs port map ( clk, stubs_din, stubs_dout );

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.kfin_data_types.all;

entity low_track is
port (
  clk: in std_logic;
  track_din: in t_trackS;
  track_dout: out t_trackL
);
end;

architecture rtl of low_track is

-- step 1

signal din: t_trackS := nulll;

-- step 2

signal d: t_trackL := nulll;
signal vin2R, vphiT, vcot, vzT: std_logic := '0';

-- step 3

signal dout: t_trackL := nulll;

begin

-- step 2
track_dout <= dout;

process ( clk ) is
begin
if rising_edge( clk ) then

  -- step 1

  din <= track_din;

  -- step 2

  d.reset <= din.reset;
  d.valid <= din.valid;
  d.sectorPhi <= din.sectorPhi;
  d.sectorEta <= din.sectorEta;
  d.inv2R <= din.inv2R( r_Linv2R );
  d.phiT <= din.phiT( r_LphiT );
  d.cot <= din.cot( r_Lcot );
  d.zT <= din.zT( r_LzT );
  vin2R <= '0';
  vphiT <= '0';
  vcot <= '0';
  vzT <= '0';
  if not overflowed( din.inv2R( r_overLinv2R ) ) then vin2R <= '1'; end if;
  if not overflowed( din.phiT( r_overLphiT ) ) then vphiT <= '1'; end if;
  if not overflowed( din.cot( r_overLcot ) ) then vcot <= '1'; end if;
  if not overflowed( din.zT( r_overLzT ) ) then vzT <= '1'; end if;

  -- step 3

  dout <= nulll;
  if d.reset = '1' then
    dout.reset <= '1';
  elsif d.valid = '1' and vin2R = '1' and vphiT = '1' and vcot ='1' and  vzT = '1' then
    dout.valid <= '1';
    dout.sectorPhi <= d.sectorPhi;
    dout.sectorEta <= d.sectorEta;
    dout.inv2R <= d.inv2R;
    dout.phiT <= d.phiT;
    dout.cot <= d.cot;
    dout.zT <= d.zT;
  end if;

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.kfin_data_types.all;

entity low_stubs is
port (
  clk: in std_logic;
  stubs_din: in t_channelS;
  stubs_dout: out t_stubsL( maxNumLayers - 1 downto 0 )
);
end;

architecture rtl of low_stubs is

signal stub_track: t_trackS := nulll;
component low_stub
port (
  clk: in std_logic;
  stub_track: in t_trackS;
  stub_din: in t_stubS;
  stub_dout: out t_stubL
);
end component;

begin

stub_track <= stubs_din.track;

g: for k in 0 to maxNumLayers - 1 generate

signal stub_din: t_stubS := nulll;
signal stub_dout: t_stubL := nulll;

begin

stub_din <= stubs_din.stubs( k );
stubs_dout( k ) <= stub_dout;

c: low_stub port map ( clk, stub_track, stub_din, stub_dout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.hybrid_data_formats.all;
use work.kfin_data_types.all;
use work.kfin_data_formats.all;

entity low_stub is
port (
  clk: in std_logic;
  stub_track: in t_trackS;
  stub_din: in t_stubS;
  stub_dout: out t_stubL
);
end;

architecture rtl of low_stub is

-- step 1

signal sr: t_stubsS( 3 downto 2 ) := ( others => nulll );
signal inv2R: std_logic_vector( widthLinv2R - baseShiftHinv2R - 1 downto 0 ) := ( others => '0' );
signal phiT: std_logic_vector( widthLphiT - baseShiftHphiT - 1 downto 0 ) := ( others => '0' );
signal cot: std_logic_vector( widthLcot - baseShiftHcot - 1 downto 0 ) := ( others => '0' );
signal zT: std_logic_vector( widthLzT - baseShiftHzT - 1 downto 0 ) := ( others => '0' );
signal dspLphi: t_dspLphi := ( others => ( others => '0' ) );
signal dspLz: t_dspLz := ( others => ( others => '0' ) );

-- step 2

signal vr: std_logic := '0';

-- step 3

signal phi: std_logic_vector( widthLdphi + 2 - 1 downto 0 ) := ( others => '0' );
signal z: std_logic_vector( widthLdz + 2 - 1 downto 0 ) := ( others => '0' );
signal dout: t_stubL := nulll;

begin

-- step 1
inv2R <= stub_track.inv2R( r_Linv2R ) & '1' & ( -baseShiftHinv2R - 2 downto 0 => '0' );
phiT <= stub_track.phiT( r_LphiT ) & '1' & ( -baseShiftHphiT - 2 downto 0 => '0' );
cot <= stub_track.cot( r_Lcot ) & '1' & ( -baseShiftHcot - 2 downto 0 => '0' );
zT <= stub_track.zT( r_LzT ) & '1' & ( -baseShiftHzT - 2 downto 0 => '0' );

-- step 3
phi <= ( sr( 3 ).phi & '1' ) + ( dspLphi.p( r_Ldphi ) & '1' );
z <= ( sr( 3 ).z & '1' ) + ( dspLz.p( r_Ldz ) & '1' );
stub_dout <= dout;

process ( clk ) is
begin
if rising_edge( clk ) then

  -- step 1

  sr <= sr( sr'high - 1 downto sr'low ) & stub_din;
  dspLphi.a <= ( stub_track.inv2R - inv2R ) & '1';
  dspLphi.b <= stub_din.r & '1';
  dspLphi.c <= ( stub_track.phiT - phiT ) & '1' & ( 1 - baseShiftLphiT - 1 downto 0 => '0' );
  dspLz.b <= ( stub_track.cot - cot ) & '1';
  dspLz.a <= stub_din.r & '1';
  dspLz.c <= ( stub_track.zT - zT ) & '1' & ( 1 - baseShiftLzT - 1 downto 0 => '0' );
  dspLz.d <= stds( ( chosenRofPhi - chosenRofZ ) / baseHr, widthHr ) & '1';

  -- step 2

  dspLphi.p <= dspLphi.a * dspLphi.b + dspLphi.c;
  dspLz.p <= dspLz.b * ( dspLz.a + dspLz.d ) + dspLz.c;
  vr <= '0';
  if not overflowed( sr( 2 ).r( r_overLr ) ) then
    vr <= '1';
  end if;

  -- step 3

  dout <= nulll;
  if sr( 3 ).reset = '1' then
    dout.reset <= '1';
  elsif sr( 3 ).valid = '1' and not overflowed( dspLphi.p( r_overLphi ) ) and not overflowed( dspLz.p( r_overLz ) ) and vr = '1' then
    dout.valid <= '1';
    dout.pst <= sr( 3 ).pst;
    dout.r <= sr( 3 ).r( r_Lr );
    dout.phi <= phi( r_Lphi );
    dout.z <= z( r_Lz );
  end if;

end if;
end process;

end;