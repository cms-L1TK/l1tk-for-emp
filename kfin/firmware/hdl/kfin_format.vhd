library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.kfin_data_types.all;

entity kfin_format is
port (
  clk: in std_logic;
  format_din: in t_channelR;
  format_dout: out t_channelZHT
);
end;

architecture rtl of kfin_format is

signal track_din: t_channelR := nulll;
signal track_dout: t_trackZHT := nulll;
component format_track
port (
  clk: in std_logic;
  track_din: in t_channelR;
  track_dout: out t_trackZHT
);
end component;

signal stub_track: t_trackR := nulll;
component format_stub
port (
  clk: in std_logic;
  stub_track: in t_trackR;
  stub_din: in t_stubR;
  stub_dout: out t_stubZHT
);
end component;

begin

track_din <= format_din;
format_dout.track <= track_dout;

stub_track <= format_din.track;

c: format_track port map ( clk, track_din, track_dout );

g: for k in 0 to numLayers - 1 generate

signal stub_din: t_stubR := nulll;
signal stub_dout: t_stubZHT := nulll;

begin

stub_din <= format_din.stubs( k );
format_dout.stubs( k ) <= stub_dout;

c: format_stub port map ( clk, stub_track, stub_din, stub_dout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_data_types.all;
use work.kfin_data_types.all;

entity format_track is
port (
  clk: in std_logic;
  track_din: in t_channelR;
  track_dout: out t_trackZHT
);
end;

architecture rtl of format_track is

function conv( c: t_channelR ) return t_trackZHT is
  variable t: t_trackR := c.track;
  variable res: t_trackZHT := ( t.reset, t.valid, ( others => '0' ), t.sector, t.phiT, t.inv2R, t.zT, t.cot );
begin
  for k in c.stubs'range loop
    res.maybe( k ) := c.stubs( k ).maybe;
  end loop;
  return res;
end function;

-- step 1

signal din: t_trackZHT := nulll;
signal sr: t_tracksZHT( 8 downto 2 ) := ( others => nulll );

-- step 8

signal dout: t_trackZHT := nulll;

begin

-- step 1
din <= conv( track_din );

-- step 8
track_dout <= dout;

process ( clk ) is
begin
if rising_edge( clk ) then

  -- step 1

  sr <= sr( sr'high - 1 downto sr'low ) & din;

  -- step 8

  dout <= sr( 8 );

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
use work.kfin_data_types.all;
use work.kfin_data_formats.all;

entity format_stub is
port (
  clk: in std_logic;
  stub_track: in t_trackR;
  stub_din: in t_stubR;
  stub_dout: out t_stubZHT
);
end;

architecture rtl of format_stub is

attribute ram_style: string;
type t_word0 is
record
  reset : std_logic;
  valid : std_logic;
  barrel: std_logic;
  ps    : std_logic;
  tilt  : std_logic;
  inv2R : std_logic_vector( widthZHTinv2R - 1 downto 0 );
  r     : std_logic_vector( widthZHTr     - 1 downto 0 );
  phi   : std_logic_vector( widthZHTphi   - 1 downto 0 );
  z     : std_logic_vector( widthZHTz     - 1 downto 0 );
end record;
type t_sr0 is array ( natural range <> ) of t_word0;
function nulll return t_word0 is begin return ( '0', '0', '0', '0', '0', others => ( others => '0' ) ); end function;
type t_word1 is
record
  reset: std_logic;
  valid: std_logic;
  r    : std_logic_vector( widthZHTr   - 1 downto 0 );
  phi  : std_logic_vector( widthZHTphi - 1 downto 0 );
  z    : std_logic_vector( widthZHTz   - 1 downto 0 );
  dz   : std_logic_vector( widthZHTdz  - 1 downto 0 );
end record;
type t_sr1 is array ( natural range <> ) of t_word1;
function nulll return t_word1 is begin return ( '0', '0', others => ( others => '0' ) ); end function;

-- step 1

signal w0: t_word0 := nulll;
signal sr0: t_sr0( 6 downto 2 ) := ( others => nulll );
signal dspDz: t_dspFdz := ( others => ( others => '0' ) );
signal indexInvR: std_logic_vector( widthAddrBRAM18 - 1 downto 0 ) := ( others => '0' );
signal ramInvR: t_ramFinvR := init_ramFinvR;
signal optionalInvR: std_logic_vector( widthDSPbu - 1 downto 0 ) := ( others => '0' );
signal cotSector: std_logic_vector( widthHcot - 1 downto 0 ) := ( others => '0' );
signal cotTrack: std_logic_vector( widthLcot - 1 downto 0 ) := ( others => '0' );
signal sectorCots: t_sectorCots := work.kfin_data_types.sectorCots;
attribute ram_style of sectorCots: signal is "register";

-- step 2

signal invR: std_logic_vector( widthDSPbu - 1 downto 0 ) := ( others => '0' );
signal cot: std_logic_vector( widthHcot + 2 - 1 downto 0 ) := ( others => '0' );

-- step 3

signal dspCot: t_dspFcot := ( others => ( others => '0' ) );

-- step 4

signal dspDphi: t_dspFdPhi := ( others => ( others => '0' ) );
signal pitchOverR: std_logic_vector( widthPitchOverR - 1 downto 0 ) := ( others => '0' );
signal indexLength: std_logic_vector( widthAddrBRAM18 - 1 downto 0 ) := ( others => '0' );
signal indexPitchOverR: std_logic_vector( widthAddrBRAM18 - 1 downto 0 ) := ( others => '0' );
signal lengths: std_logic_vector( widthLengthZ + widthLengthR - 1 downto 0 ) := ( others => '0' );
signal ramLengths: t_ramLengths := ramLengths;
signal ramPitchOverRs: t_ramPitchOverRs := ramPitchOverRs;
attribute ram_style of ramLengths, ramPitchOverRs, ramInvR: signal is "block";

-- step 5

signal lengthZ: std_logic_vector( widthLengthZ - 1 downto 0 ) := ( others => '0' );
signal lengthR: std_logic_vector( widthLengthR - 1 downto 0 ) := ( others => '0' );
signal w1: t_word1 := nulll;
signal sr1: t_sr1( 8 downto 7 ) := ( others => nulll );

-- step 7

signal dout: t_stubZHT := nulll;

begin

--step 1
w0 <= ( stub_din.reset, stub_din.valid, stub_din.barrel, stub_din.ps, stub_din.tilt, stub_track.inv2R, stub_din.r, stub_din.phi, stub_din.z );
indexInvR <= stub_din.r( r_FinvRr );

-- step 5
indexLength <= sr0( 5 ).barrel & sr0( 5 ).ps & sr0( 5 ).tilt & abs( dspCot.p( r_Fcot ) );
indexPitchOverR <= sr0( 5 ).ps & sr0( 5 ).r( r_Fr );

-- step 6
lengthZ <= lengths( widthLengthZ + widthLengthR - 1 downto widthLengthR );
lengthR <= lengths(                widthLengthR - 1 downto            0 );
w1 <= ( sr0( 6 ).reset, sr0( 6 ).valid, sr0( 6 ).r, sr0( 6 ).phi, sr0( 6 ).z, lengthZ );

----step 8
stub_dout <= dout;

process ( clk ) is
begin
if rising_edge( clk ) then

  -- step 1

  sr0 <= sr0( sr0'high - 1 downto sr0'low ) & w0;
  dspDz.a <= stub_track.cot & '1';
  dspDz.b <= stds( chosenRofZ / baseLr, widthLr ) & '1';
  dspDz.c <= ( ( stub_track.zT & '1' & ( baseShiftFz - 1 downto 0 => '0' ) ) + ( stub_din.z & '1' ) ) & ( baseShiftFcot downto 0 => '0' );
  optionalInvR <= ramInvR( uint( indexInvR ) );
  cotSector <= sectorCots( uint( stub_track.sector( widthLSectorEta - 1 downto 0 ) ) );
  cotTrack <= stub_track.cot;

  -- step 2

  dspDz.p <= dspDz.c - dspDz.a * dspDz.b;
  invR <= optionalInvR;
  cot <= ( cotSector & '1' ) + ( cotTrack & '1' & ( baseShiftLcot - 1 downto 0 => '0' ) );

  -- step 3

  dspCot.a <= dspDz.p( r_FdZ ) & '1';
  dspCot.b <= '0' & invR & '1';
  dspCot.c <= cot & ( baseShiftFinvR downto 0 => '0' );

  -- step 4

  dspCot.p <= dspCot.a * dspCot.b + dspCot.c;

  -- step 5

  lengths <= ramLengths( uint( indexLength ) );
  pitchOverR <= ramPitchOverRs( uint( indexPitchOverR ) );
  dspDphi.b0 <= '0' & abs( sr0( 5 ).inv2R ) & '1';

  -- step 6

  sr1 <= sr1( sr1'high - 1 downto sr1'low ) & w1;
  dspdPhi.b1 <= dspdPhi.b0;
  dspdPhi.a <= '0' & lengthR & '1';
  dspdPhi.d <= stds( scattering / baseZHTr, widthLengthR ) & '1';
  dspdPhi.c <= '0' & pitchOverR & "10";

  -- step 7

  dspdPhi.p <= ( dspdPhi.a + dspdPhi.d ) * dspdPhi.b1 + dspdPhi.c;

  -- step 8

  dout <= nulll;
  if sr1( 8 ).reset = '1' then
    dout.reset <= '1';
  elsif  sr1( 8 ).valid = '1' then
    dout.valid <= '1';
    dout.r <= sr1( 8 ).r;
    dout.phi <= sr1( 8 ).phi;
    dout.z <= sr1( 8 ).z;
    dout.dPhi <= incr( dspdPhi.p( r_FdPhi ) );
    dout.dz <= sr1( 8 ).dZ;
  end if;

end if;
end process;

end;