library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.tm_data_types.all;

entity tm_format is
port (
  clk: in std_logic;
  format_din: in t_channelR;
  format_dout: out t_channelTM
);
end;

architecture rtl of tm_format is

signal track_din: t_channelR := nulll;
signal track_dout: t_trackTM := nulll;
component format_track
port (
  clk: in std_logic;
  track_din: in t_channelR;
  track_dout: out t_trackTM
);
end component;

signal stub_track: t_trackR := nulll;
component format_stub
port (
  clk: in std_logic;
  stub_track: in t_trackR;
  stub_din: in t_stubR;
  stub_dout: out t_stubTM
);
end component;

begin

track_din <= format_din;
format_dout.track <= track_dout;

stub_track <= format_din.track;

c: format_track port map ( clk, track_din, track_dout );

g: for k in 0 to numLayers - 1 generate

signal stub_din: t_stubR := nulll;
signal stub_dout: t_stubTM := nulll;

begin

stub_din <= format_din.stubs( k );
format_dout.stubs( k ) <= stub_dout;

c: format_stub port map ( clk, stub_track, stub_din, stub_dout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_data_types.all;
use work.tm_data_types.all;

entity format_track is
port (
  clk: in std_logic;
  track_din: in t_channelR;
  track_dout: out t_trackTM
);
end;

architecture rtl of format_track is

function conv( c: t_channelR ) return t_trackTM is begin return ( c.track.reset, c.track.valid, c.track.inv2R, c.track.phiT, c.track.zT ); end function;

-- step 1

signal din: t_trackTM := nulll;
signal sr: t_tracksTM( 4 downto 2 ) := ( others => nulll );

-- step 4

signal dout: t_trackTM := nulll;

begin

-- step 1
din <= conv( track_din );

-- step 4
track_dout <= dout;

process ( clk ) is
begin
if rising_edge( clk ) then

  -- step 1

  sr <= sr( sr'high - 1 downto sr'low ) & din;

  -- step 4

  dout <= sr( 4 );

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
use work.tm_data_types.all;
use work.tm_data_formats.all;

entity format_stub is
port (
  clk: in std_logic;
  stub_track: in t_trackR;
  stub_din: in t_stubR;
  stub_dout: out t_stubTM
);
end;

architecture rtl of format_stub is

signal ramLengths: t_ramLengths := ramLengths;
signal ramPitchOverRs: t_ramPitchOverRs := ramPitchOverRs;
attribute ram_style: string;
type t_stub is
record
  reset : std_logic;
  valid : std_logic;
  stubId: std_logic_vector( widthStubId - 1 downto 0 );
  r     : std_logic_vector( widthTMr    - 1 downto 0 );
  phi   : std_logic_vector( widthTMphi  - 1 downto 0 );
  z     : std_logic_vector( widthTMz    - 1 downto 0 );
end record;
function nulll return t_stub is begin return ( '0', '0', others => ( others => '0' ) ); end function;
type t_stubs is array ( natural range <> ) of t_stub;
type t_srz is array ( natural range <> ) of std_logic_vector( widthTMdZ - 1 downto 0 );

-- step 1

signal stub: t_stub := nulll;
signal sr: t_stubs( 4 downto 1 + 1 ) := ( others => nulll );
signal dspDphi: t_dspFdPhi := ( others => ( others => '0' ) );
signal indexLength: std_logic_vector( widthAddrLengths - 1 downto 0 ) := ( others => '0' );
signal indexPitchOverR: std_logic_vector( widthAddrBRAM18 - 1 downto 0 ) := ( others => '0' );
signal pitchOverR: std_logic_vector( widthPitchOverR - 1 downto 0 ) := ( others => '0' );
signal lengths: std_logic_vector( widthLengthZ + widthLengthR - 1 downto 0 ) := ( others => '0' );

-- step 2

signal lengthZ: std_logic_vector( widthLengthZ - 1 downto 0 ) := ( others => '0' );
signal lengthR: std_logic_vector( widthLengthR - 1 downto 0 ) := ( others => '0' );
signal srz: t_srz( 4 downto 2 + 1 ) := ( others => ( others => '0' ) );

-- step 4

signal dout: t_stubTM := nulll;

begin

-- step 1
stub <= ( stub_din.reset, stub_din.valid, stub_din.stubId, stub_din.r, stub_din.phi, stub_din.z );
indexLength <= stub_din.barrel & stub_din.ps & stub_din.tilt & abs( stub_track.zT );
indexPitchOverR <= stub_din.ps & stub_din.r( widthLr - 1 downto widthLr - widthFr );

-- step 2
lengthZ <= lengths( widthLengthZ + widthLengthR - 1 downto widthLengthR );
lengthR <= lengths(                widthLengthR - 1 downto            0 );

----step 4
stub_dout <= dout;

process ( clk ) is
begin
if rising_edge( clk ) then

  -- step 1

  sr <= sr( sr'high - 1 downto sr'low ) & stub;
  lengths <= ramLengths( uint( indexLength ) );
  pitchOverR <= ramPitchOverRs( uint( indexPitchOverR ) );
  dspDphi.b0 <= '0' & abs( stub_track.inv2R ) & '1';

  -- step 2

  srz <= srz( srz'high - 1 downto srz'low ) & lengthZ;
  dspdPhi.b1 <= dspdPhi.b0;
  dspdPhi.a <= '0' & lengthR & '1';
  dspdPhi.d <= stds( digi( scattering, baseR ), widthLengthR ) & '1';
  dspdPhi.c <= '0' & pitchOverR & "10";

  -- step 3

  dspdPhi.p <= ( dspdPhi.a + dspdPhi.d ) * dspdPhi.b1 + dspdPhi.c;

  -- step 4

  dout <= nulll;
  dout.reset <= sr( 4 ).reset;
  if sr( 4 ).valid = '1' then
    dout.valid <= '1';
    dout.stubId <= sr( 4 ).stubId;
    dout.r <= sr( 4 ).r;
    dout.phi <= sr( 4 ).phi;
    dout.z <= sr( 4 ).z;
    dout.dPhi <= dspdPhi.p( r_FdPhi ) + 1;
    dout.dz <= srz( 4 );
  end if;

end if;
end process;

end;