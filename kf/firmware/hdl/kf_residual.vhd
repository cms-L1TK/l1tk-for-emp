library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.kf_data_types.all;

entity kf_residual is
port (
  clk: in std_logic;
  residual_din: in t_final;
  residual_found: in t_found;
  residual_dout: out t_fitted
);
end;

architecture rtl of kf_residual is

signal delay_din: t_found := nulll;
signal delay_dout: t_found := nulll;
component kf_residual_delay
port (
  clk: in std_logic;
  delay_din: in t_found;
  delay_dout: out t_found
);
end component;

signal lut_din: t_final := nulll;
signal lut_found: t_found := nulll;
signal lut_track: t_parameterTrackDR := nulll;
signal lut_stubs: t_parameterStubs( 0 to numLayers - 1 ) := ( others => nulll );
signal lut_dout: t_final := nulll;
component kf_residual_lut
port (
  clk: in std_logic;
  lut_din: in t_final;
  lut_found: in t_found;
  lut_track: out t_parameterTrackDR;
  lut_stubs: out t_parameterStubs( 0 to numLayers - 1 );
  lut_dout: out t_final
);
end component;

signal track_din: t_final := nulll;
signal track_found: t_parameterTrackDR := nulll;
signal track_dout: t_track := nulll;
component kf_residual_track
port (
  clk: in std_logic;
  track_din: in t_final;
  track_found: in t_parameterTrackDR;
  track_dout: out t_track
);
end component;

signal stubs_din: t_final := nulll;
signal stubs_found: t_parameterStubs( 0 to numLayers - 1 ) := ( others => nulll );
signal stubs_hits: std_logic_vector( 0 to numLayers - 1 ) := ( others => '0' );
signal stubs_dout: t_parameterStubs( 0 to numLayers - 1 ) := ( others => nulll );
component kf_residual_stubs
port (
  clk: in std_logic;
  stubs_din: in t_final;
  stubs_found: in t_parameterStubs( 0 to numLayers - 1 );
  stubs_hits: out std_logic_vector( 0 to numLayers - 1 );
  stubs_dout: out t_parameterStubs( 0 to numLayers - 1 )
);
end component;

begin

delay_din <= residual_found;

lut_din <= residual_din;
lut_found <= delay_dout;

track_din <= lut_dout;
track_found <= lut_track;

stubs_din <= lut_dout;
stubs_found <= lut_stubs;

residual_dout <= ( ( track_dout.meta.reset, track_dout.meta.valid, track_dout.meta.track, stubs_hits ), track_dout.track, stubs_dout );

cDelay: kf_residual_delay port map ( clk, delay_din, delay_dout );

cLut: kf_residual_lut port map ( clk, lut_din, lut_found, lut_track, lut_stubs, lut_dout );

cTrack: kf_residual_track port map ( clk, track_din, track_found, track_dout );

cStubs: kf_residual_stubs port map ( clk, stubs_din, stubs_found, stubs_hits, stubs_dout );

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.hybrid_data_formats.all;
use work.kf_data_formats.all;
use work.kf_data_types.all;

entity kf_residual_delay is
port (
  clk: in std_logic;
  delay_din: in t_found;
  delay_dout: out t_found
);
end;

architecture rtl of kf_residual_delay is

constant latency: integer := 141;
attribute ram_style: string;
constant widthAddr: natural := ilog2( latency );
constant widthRam: natural := 1 + 1 + widthTrack + widthHits + widthDRinv2R + widthDRphiT + widthDRzT + numLayers * widthParameterStub;
type t_ram is array ( 0 to 2 ** widthAddr - 1 ) of std_logic_vector( widthRam - 1 downto 0 );
function conv( f: t_found ) return std_logic_vector is
  variable std: std_logic_vector( widthRam - 1 downto 0 ) := ( others => '0' );
begin
  std( 1 + 1 + widthTrack + widthHits + widthDRinv2R + widthDRphiT + widthDRzT + numLayers * widthParameterStub - 1 downto numLayers * widthParameterStub ) := f.meta.reset & f.meta.valid & f.meta.track & f.meta.hits & f.track.inv2R & f.track.phiT & f.track.zT;
  for k in f.stubs'range loop
    std( widthH00 + widthm0 + widthm1 + widthd0 + widthd1 + k * widthParameterStub - 1 downto k * widthParameterStub ) := f.stubs( k ).H00 & f.stubs( k ).m0 & f.stubs( k ).m1 & f.stubs( k ).d0 & f.stubs( k ).d1;
  end loop;
  return std;
end function;
function conv( std: std_logic_vector ) return t_found is
  variable f: t_found := nulll;
begin
  f.meta.reset   := std( 1 + 1 + widthTrack + widthHits + widthDRinv2R + widthDRphiT + widthDRzT + numLayers * widthParameterStub - 1 );
  f.meta.valid   := std(     1 + widthTrack + widthHits + widthDRinv2R + widthDRphiT + widthDRzT + numLayers * widthParameterStub - 1 );
  f.meta.track   := std(         widthTrack + widthHits + widthDRinv2R + widthDRphiT + widthDRzT + numLayers * widthParameterStub - 1 downto widthHits + widthDRinv2R + widthDRphiT + widthDRzT + numLayers * widthParameterStub );
  f.meta.hits    := std(                      widthHits + widthDRinv2R + widthDRphiT + widthDRzT + numLayers * widthParameterStub - 1 downto             widthDRinv2R + widthDRphiT + widthDRzT + numLayers * widthParameterStub );
  f.track.inv2R := std(                                  widthDRinv2R + widthDRphiT + widthDRzT + numLayers * widthParameterStub - 1 downto                            widthDRphiT + widthDRzT + numLayers * widthParameterStub );
  f.track.phiT  := std(                                                 widthDRphiT + widthDRzT + numLayers * widthParameterStub - 1 downto                                          widthDRzT + numLayers * widthParameterStub );
  f.track.zT    := std(                                                               widthDRzT + numLayers * widthParameterStub - 1 downto                                                      numLayers * widthParameterStub );
  for k in f.stubs'range loop
    f.stubs( k ).H00 := std( widthH00 + widthm0 + widthm1 + widthd0 + widthd1 + k * widthParameterStub - 1 downto widthm0 + widthm1 + widthd0 + widthd1 + k * widthParameterStub );
    f.stubs( k ).m0  := std(            widthm0 + widthm1 + widthd0 + widthd1 + k * widthParameterStub - 1 downto           widthm1 + widthd0 + widthd1 + k * widthParameterStub );
    f.stubs( k ).m1  := std(                      widthm1 + widthd0 + widthd1 + k * widthParameterStub - 1 downto                     widthd0 + widthd1 + k * widthParameterStub );
    f.stubs( k ).d0  := std(                                widthd0 + widthd1 + k * widthParameterStub - 1 downto                               widthd1 + k * widthParameterStub );
    f.stubs( k ).d1  := std(                                          widthd1 + k * widthParameterStub - 1 downto                                         k * widthParameterStub );
  end loop;
  return f;
end function;

-- step 1

signal ram: t_ram := ( others => ( others => '0' ) );
signal waddr, raddr: std_logic_vector( widthAddr - 1 downto 0 ) := ( others => '0' );
signal optional: t_found := nulll;
attribute ram_style of ram: signal is "block";

-- step 2

signal dout: t_found := nulll;

begin

-- step 1
waddr <= raddr + latency;

-- track_dout 2
delay_dout <= dout;

process( clk ) is
begin
if rising_edge( clk ) then

  -- step 1;

  dout <= delay_din;
  ram( uint( waddr ) ) <= conv( delay_din );
  optional <= conv( ram( uint( raddr ) ) );
  raddr <= raddr + 1;

  -- step 2

  dout <= optional;

end if;
end process;
end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.hybrid_data_formats.all;
use work.hybrid_data_types.all;
use work.kf_data_formats.all;
use work.kf_data_types.all;

entity kf_residual_lut is
port (
  clk: in std_logic;
  lut_din: in t_final;
  lut_found: in t_found;
  lut_track: out t_parameterTrackDR;
  lut_stubs: out t_parameterStubs( 0 to numLayers - 1 );
  lut_dout: out t_final
);
end;

architecture rtl of kf_residual_lut is

attribute ram_style: string;
constant widthRam: natural := widthDRinv2R + widthDRphiT + widthDRzT + numLayers * widthParameterStub;
constant widthAddr: natural := widthTrack;
type t_ram is array ( 0 to 2 ** widthAddr - 1 ) of std_logic_vector( widthRam - 1 downto 0 );
function conv( f: t_found ) return std_logic_vector is
  variable std: std_logic_vector( widthRam - 1 downto 0 ) := ( others => '0' );
begin
  std( widthDRinv2R + widthDRphiT + widthDRzT + numLayers * widthParameterStub - 1 downto numLayers * widthParameterStub ) := f.track.inv2R & f.track.phiT & f.track.zT;
  for k in f.stubs'range loop
    std( widthH00 + widthm0 + widthm1 + widthd0 + widthd1 + k * widthParameterStub - 1 downto k * widthParameterStub ) := f.stubs( k ).H00 & f.stubs( k ).m0 & f.stubs( k ).m1 & f.stubs( k ).d0 & f.stubs( k ).d1;
  end loop;
  return std;
end function;
function conv( std: std_logic_vector ) return t_found is
  variable f: t_found := nulll;
begin
  f.track.inv2R := std( widthDRinv2R + widthDRphiT + widthDRzT + numLayers * widthParameterStub - 1 downto widthDRphiT + widthDRzT + numLayers * widthParameterStub );
  f.track.phiT  := std(                widthDRphiT + widthDRzT + numLayers * widthParameterStub - 1 downto               widthDRzT + numLayers * widthParameterStub );
  f.track.zT    := std(                              widthDRzT + numLayers * widthParameterStub - 1 downto                           numLayers * widthParameterStub );
  for k in f.stubs'range loop
    f.stubs( k ).H00 := std( widthH00 + widthm0 + widthm1 + widthd0 + widthd1 + k * widthParameterStub - 1 downto widthm0 + widthm1 + widthd0 + widthd1 + k * widthParameterStub );
    f.stubs( k ).m0  := std(            widthm0 + widthm1 + widthd0 + widthd1 + k * widthParameterStub - 1 downto           widthm1 + widthd0 + widthd1 + k * widthParameterStub );
    f.stubs( k ).m1  := std(                      widthm1 + widthd0 + widthd1 + k * widthParameterStub - 1 downto                     widthd0 + widthd1 + k * widthParameterStub );
    f.stubs( k ).d0  := std(                                widthd0 + widthd1 + k * widthParameterStub - 1 downto                               widthd1 + k * widthParameterStub );
    f.stubs( k ).d1  := std(                                          widthd1 + k * widthParameterStub - 1 downto                                         k * widthParameterStub );
  end loop;
  return f;
end function;

-- step 1
signal dout: t_final := nulll;
signal read: t_found := nulll;
signal ram: t_ram := ( others => ( others => '0' ) );
attribute ram_style of ram: signal is "distributed";

begin

-- step 1
lut_dout <= dout;
lut_track <= read.track;
lut_stubs <= read.stubs;

process( clk ) is
begin
if rising_edge( clk ) then

  -- step 1

  dout <= lut_din;
  read <= conv( ram( uint( lut_din.meta.track ) ) );
  if lut_found.meta.valid = '1' then
    ram( uint( lut_found.meta.track ) ) <= conv( lut_found );
  end if;

  if lut_din.meta.valid = '0' then
    read.track <= nulll;
    read.stubs <= ( others => nulll );
  end if;

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.kf_data_types.all;

entity kf_residual_stubs is
port (
  clk: in std_logic;
  stubs_din: in t_final;
  stubs_found: in t_parameterStubs( 0 to numLayers - 1 );
  stubs_hits: out std_logic_vector( 0 to numLayers - 1 );
  stubs_dout: out t_parameterStubs( 0 to numLayers - 1 )
);
end;

architecture rtl of kf_residual_stubs is

component kf_residual_stub
generic (
  index: natural
);
port (
  clk: in std_logic;
  stub_din: in t_final;
  stub_found: in t_parameterStub;
  stub_valid: out std_logic;
  stub_dout: out t_parameterStub
);
end component;

begin

g: for k in 0 to numLayers - 1 generate

signal stub_din: t_final := nulll;
signal stub_found: t_parameterStub := nulll;
signal stub_valid: std_logic := '0';
signal stub_dout: t_parameterStub := nulll;

begin

stub_din <= stubs_din;
stub_found <= stubs_found( k );
stubs_hits( k ) <= stub_valid;
stubs_dout( k ) <= stub_dout;

c: kf_residual_stub generic map ( k ) port map ( clk, stub_din, stub_found, stub_valid, stub_dout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.hybrid_data_formats.all;
use work.hybrid_data_types.all;
use work.kf_data_formats.all;
use work.kf_data_types.all;
use work.kf_residual_pkg.all;

entity kf_residual_track is
port (
  clk: in std_logic;
  track_din: in t_final;
  track_found: in t_parameterTrackDR;
  track_dout: out t_track
);
end;

architecture rtl of kf_residual_track is

-- step 1
signal validInv2R: std_logic := '0';
signal validPhiT: std_logic := '0';
signal validCot: std_logic := '0';
signal validZT: std_logic := '0';
signal sumInv2R: t_inv2R := nulll;
signal sumPhiT: t_phiT := nulll;
signal sumCot: t_cot := nulll;
signal sumZT: t_zT := nulll;
signal track: t_track := nulll;
signal sr: t_tracks( 3 downto 1 + 1 ) := ( others => nulll );

-- step 3
signal dout: t_track := nulll;

begin

-- step 1
sumInv2R.x <= resize( track_found.inv2R & '1' & ( baseShift0 - baseShiftx0 - 1 - 1 downto 0 => '0' ), widthKFinv2R - baseShiftx0 );
sumInv2R.dx <= resize( track_din.track.x0, widthKFinv2R - baseShiftx0 );
sumInv2R.sum <= sumInv2R.x + sumInv2R.dx;

sumPhiT.x <= resize( track_found.phiT & '1' & ( baseShift1 - baseShiftx1 - 1 - 1 downto 0 => '0' ), widthKFphiT - baseShiftx1 );
sumPhiT.dx <= resize( track_din.track.x1, widthKFphiT - baseShiftx1 );
sumPhiT.sum <= sumPhiT.x + sumPhiT.dx;

sumCot.x <= resize( ( c_cots( uint( track_found.zT ) ) & '1' ), widthKFcot - baseShiftx2 );
sumCot.dx <= resize( track_din.track.x2, widthKFcot - baseShiftx2 );
sumCot.sum <= sumCot.x + sumCot.dx;

sumZT.x <= resize( track_found.zT & '1' & ( baseShift3 - baseShiftx3 - 1 - 1 downto 0 => '0' ), widthKFzT - baseShiftx3 );
sumZT.dx <= resize( track_din.track.x3, widthKFzT - baseShiftx3 );
sumZT.sum <= sumZT.x + sumZT.dx;

track.meta <= track_din.meta;
track.track.inv2R <= sumInv2R.sum( r_inv2R );
track.track.phiT <= sumPhiT.sum( r_phiT );
track.track.cot <= sumCot.sum( r_cot );
track.track.zT <= sumZT.sum( r_zT );

-- step 4
track_dout <= dout;

process( clk ) is
begin
if rising_edge( clk ) then

  -- sr

  sr <= sr( sr'high - 1 downto sr'low ) & nulll;

  -- step 1

  sr( sr'low ) <= track;
  validInv2R <= '0';
  if uint( sumInv2R.sum( r_inv2Rover ) ) = 0 or sint( sumInv2R.sum( r_inv2Rover ) ) = -1 then
    validInv2R <= '1';
  end if;
  validPhiT <= '0';
  if uint( sumPhiT.sum( r_phiTover ) ) = 0 or sint( sumPhiT.sum( r_phiTover ) ) = -1 then
    validPhiT <= '1';
  end if;
  validCot <= '0';
  if uint( sumCot.sum( r_cotover ) ) = 0 or sint( sumCot.sum( r_cotover ) ) = -1 then
    validCot <= '1';
  end if;
  validZT <= '0';
  if uint( sumZT.sum( r_zTover ) ) = 0 or sint( sumZT.sum( r_zTover ) ) = -1 then
    validZT <= '1';
  end if;

  -- step 2

  if ( validInv2R and validPhiT and validCot and validZT ) = '0' or sr( 2 ).meta.valid = '0' then
    sr( 2 + 1 ).meta.valid <= '0';
    sr( 2 + 1 ).meta.hits <= ( others => '0' );
    sr( 2 + 1 ).track <= nulll;
  end if;

  -- step 3

  dout <= sr( 3 );

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.kf_data_formats.all;
use work.kf_data_types.all;
use work.kf_residual_pkg.all;

entity kf_residual_stub is
generic (
  index: natural
);
port (
  clk: in std_logic;
  stub_din: in t_final;
  stub_found: in t_parameterStub;
  stub_valid: out std_logic;
  stub_dout: out t_parameterStub
);
end;

architecture rtl of kf_residual_stub is

type t_stub is
record
  valid: std_logic;
  H00: std_logic_vector( widthH00 - 1 downto 0 );
  d0 : std_logic_vector( widthd0  - 1 downto 0 );
  d1 : std_logic_vector( widthd1  - 1 downto 0 );
end record;
type t_stubs is array ( natural range <> ) of t_stub;
function nulll return t_stub is begin return ( '0', others => ( others => '0' ) ); end function;

-- step 1
signal stubs: t_stubs( 3 downto 1 + 1 ) := ( others => nulll );
signal sumR0: t_sumR0 := ( others => ( others => '0' ) );
signal sumR1: t_sumR1 := ( others => ( others => '0' ) );
signal dspr0: t_dspR0 := ( others => ( others => '0' ) );
signal dspr1: t_dspR1 := ( others => ( others => '0' ) );

-- step 3
signal valid: std_logic := '0';
signal overPhi: std_logic_vector( widthOverPhi - 1 downto 0 ) := ( others => '0' );
signal overZ: std_logic_vector( widthOverZ - 1 downto 0 ) := ( others => '0' );
signal dout: t_parameterStub := nulll;

begin

-- step 1
sumR0.A <= stub_found.m0 & '1' & ( baseShiftm0 - baseShiftx1 - 1 downto 0 => '0' );
sumR0.B <= stub_din.track.x1 & '1';
sumR0.C <= sumR0.A - sumR0.B;
sumR1.A <= stub_found.m1 & '1'& ( baseShiftm1 - baseShiftx3 - 1 downto 0 => '0' );
sumR1.B <= stub_din.track.x3 & '1';
sumR1.C <= sumR1.A - sumR1.B;

-- step 3
stub_valid <= valid;
stub_dout <= dout;
overPhi <= dspr0.P( r_overPhi );
overZ <= dspr1.P( r_overZ );

process( clk ) is
begin
if rising_edge( clk ) then

  -- shift register

  stubs <= stubs( stubs'high - 1 downto stubs'low ) & ( nulll );

  -- step 1

  stubs( stubs'low ) <= ( stub_din.meta.hits( index ), stub_found.H00, stub_found.d0, stub_found.d1 );
  dspr0.A <= stub_found.H00 & '1';
  dspr1.A <= f_H12( stub_found.H00 ) & '1';
  dspr0.B <= stub_din.track.x0 & '1';
  dspr1.B <= stub_din.track.x2 & '1';
  dspr0.C <= sumR0.C( r_r0C ) & "10" & ( baseShiftx1 - shiftDspR0 - 1 downto 0 => '0' );
  dspr1.C <= sumR1.C( r_r1C ) & "10" & ( baseShiftx3 - shiftDspR1 - 1 downto 0 => '0' );

  -- step 2

  dspr0.P <= dspr0.C - dspr0.A * dspr0.B;
  dspr1.P <= dspr1.C - dspr1.A * dspr1.B;

  -- step 3

  valid <= '0';
  if stubs( 3 ).valid = '1' and ( sint( overPhi ) = -1 or uint( overPhi ) = 0 ) and ( sint( overZ ) = -1 or uint( overZ ) = 0 ) then
    valid <= '1';
  end if;
  dout <= ( stubs( 3 ).H00, dspr0.P( r_phi ), dspr1.P( r_z ), stubs( 3 ).d0, stubs( 3 ).d1 );

  if stubs( 3 ).valid = '0' then
    dout <= nulll;
  end if;

end if;
end process;

end;