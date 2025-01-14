library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.hybrid_data_formats.all;
use work.hybrid_data_types.all;


package dr_data_types is


type t_stubCM is
record
  valid : std_logic;
  pst   : std_logic;
  stubId: std_logic_vector( widthTMstubId - 1 downto 0 );
  r     : std_logic_vector( widthDRr      - 1 downto 0 );
  phi   : std_logic_vector( widthDRphi    - 1 downto 0 );
  z     : std_logic_vector( widthDRz      - 1 downto 0 );
end record;
type t_stubsCM is array ( natural range <> ) of t_stubCM;
function nulll return t_stubCM;

type t_trackCM is
record
  reset: std_logic;
  valid: std_logic;
  cm   : std_logic;
  param: t_parameterTrackDR;
  stubs: t_stubsCM( 0 to tmNumLayers - 1 );
end record;
type t_tracksCM is array ( natural range <> ) of t_trackCM;
function nulll return t_trackCM;
function conv( tm: t_trackTM ) return t_trackCM;

type t_id is
record
  valid: std_logic;
  value: std_logic_vector( widthTMstubId - 1 downto 0 );
end record;
type t_ids is array ( natural range <> ) of t_id;
function nulll return t_id;

type t_cm is
record
  valid: std_logic;
  ids  : t_ids( 0 to tmNumLayers - 1 );
end record;
type t_cms is array ( natural range <> ) of t_cm;
function nulll return t_cm;
function conv( t: t_trackCM ) return t_cm;

type t_stubCore is
record
  valid: std_logic;
  pst  : std_logic;
  r    : std_logic_vector( widthDRr   - 1 downto 0 );
  phi  : std_logic_vector( widthDRphi - 1 downto 0 );
  z    : std_logic_vector( widthDRz   - 1 downto 0 );
end record;
type t_stubsCore is array ( natural range <> ) of t_stubCore;
function nulll return t_stubCore;

type t_trackCore is
record
  reset: std_logic;
  valid: std_logic;
  param: t_parameterTrackDR;
  stubs: t_stubsCore( 0 to tmNumLayers - 1 );
end record;
type t_tracksCore is array ( natural range <> ) of t_trackCore;
function nulll return t_trackCore;
function conv( cm: t_trackCM ) return t_trackCore;

type t_stubCalc is
record
  valid: std_logic;
  layer: std_logic_vector( 0 to numLayers - 1 );
  param: t_parameterStubDR;
end record;
type t_stubsCalc is array ( natural range <> ) of t_stubCalc;
function nulll return t_stubCalc;

type t_trackCalc is
record
  reset: std_logic;
  valid: std_logic;
  param: t_parameterTrackDR;
  stubs: t_stubsCalc( 0 to tmNumLayers - 1 );
end record;
type t_tracksCalc is array ( natural range <> ) of t_trackCalc;
function nulll return t_trackCalc;

constant baseShiftR: integer := widthTMr - bram18WidthAddr + 1;
constant baseR     : real    := baseTMr * 2.0 ** baseShiftR;
constant maxDPhi   : real    := baseTMphi * 2.0 ** widthDRdPhi;

constant offsetR: natural := 2 ** ( widthTMinv2R - 1 );
constant offsetPhi: natural := 2 ** ( bram18WidthAddr - 1 );
constant offsetZ: natural := 2 ** ( widthTMzT - 1 );
type t_ramR is array( 0 to 2 ** widthTMinv2R - 1 ) of std_logic_vector( widthDRdPhi - 1 downto 0 );
type t_ramPhi is array( 0 to 2 ** bram18WidthAddr - 1 ) of std_logic_vector( widthDRdPhi - 1 downto 0 );
type t_ramZ is array( 0 to 2 ** widthTMzT - 1 ) of std_logic_vector( widthDRdZ - 1 downto 0 );
type t_rams is
record
  r: t_ramR;
  phi: t_ramPhi;
  z: t_ramZ;
end record;
function init_Barrel return t_rams;
function init_EndCap return t_rams;
constant c_barrel: t_rams;
constant c_endcap: t_rams;


end;



package body dr_data_types is


function nulll return t_id is begin return ( '0', ( others => '0' ) ); end function;
function nulll return t_cm is begin return ( '0', ( others => nulll ) ); end function;
function nulll return t_stubCM is begin return ( '0', '0', others => ( others => '0' ) ); end function;
function nulll return t_trackCM is begin return ( '0', '0', '0', nulll, ( others => nulll ) ); end function;
function nulll return t_stubCore is begin return ( '0', '0', others => ( others => '0' ) ); end function;
function nulll return t_trackCore is begin return ( '0', '0', nulll, ( others => nulll ) ); end function;
function nulll return t_stubCalc is begin return ( '0', ( others => '0' ), nulll ); end function;
function nulll return t_trackCalc is begin return ( '0', '0', nulll, ( others => nulll ) ); end function;

function conv( tm: t_trackTM ) return t_trackCM is
  variable cm: t_trackCM := ( tm.meta.reset, tm.meta.valid, '0', ( tm.track.inv2R, tm.track.phiT, tm.track.zT ), ( others => nulll ) );
begin
  for k in 0 to tmNumlayers - 1 loop
    cm.stubs( k ) := ( tm.meta.hits( k ), tm.stubs( k ).pst, tm.stubs( k ).stubId, tm.stubs( k ).r, tm.stubs( k ).phi, tm.stubs( k ).z );
  end loop;
  return cm;
end function;

function conv( t: t_trackCM ) return t_cm is
  variable cm: t_cm := ( t.valid, ( others => nulll ) );
begin
  for k in 0 to tmNumlayers - 1 loop
    cm.ids( k ) := ( t.stubs( k ).valid, t.stubs( k ).stubId );
  end loop;
  return cm;
end function;

function conv( cm: t_trackCM ) return t_trackCore is
  variable c: t_trackCore := ( cm.reset, cm.valid, cm.param, ( others => nulll ) );
begin
  for k in 0 to tmNumLayers - 1 loop
    c.stubs( k ) := ( cm.stubs( k ).valid, cm.stubs( k ).pst, cm.stubs( k ).r, cm.stubs( k ).phi, cm.stubs( k ).z );
  end loop;
  return c;
end function;

function init_Barrel return t_rams is
  variable rams: t_rams := ( ( others => ( others => '0' ) ), ( others => ( others => '0' ) ), ( others => ( others => '0' ) ) );
  variable val, val0, val1: real;
begin
  for k in 0 to offsetR - 1 loop
    val := ( real( k ) + 0.5 ) * baseTMinv2R;
    val0 := 0.5 * scattering * val;
    val1 := 0.5 * ( scattering + lengthTilt ) * val;
    rams.r( k ) := stdu( val0, baseTMphi, widthDRdPhi );
    rams.r( k + offsetR ) := stdu( val1, baseTMphi, widthDRdPhi );
  end loop;
  for k in 0 to offsetPhi - 1 loop
    val := ( sreal( stdu( k, bram18WidthAddr - 1 ) ) + 0.5 ) * baseR + chosenRofPhi;
    val0 := 0.5 * pitchRow2S / val;
    val1 := 0.5 * pitchRowPS / val;
    if val0 > 0.0 and val0 < maxDPhi then
      rams.phi( k ) := stdu( val0, baseTMphi, widthDRdPhi );
    end if;
    if val1 > 0.0 and val1 < maxDPhi then
      rams.phi( k + offsetPhi ) := stdu( val1, baseTMphi, widthDRdPhi );
    end if;
  end loop;
  for k in 0 to offsetZ - 1 loop
    val := ( real( k ) + 0.5 ) * baseTMzT / chosenRofZ;
    val0 := 0.5 * pitchColPS * ( approxSlope * val + approxIntercept );
    rams.z( k ) := stdu( val0, baseTMz, widthDRdZ );
    rams.z( k + offsetZ ) := stdu( val0, baseTMz, widthDRdZ );
  end loop;
  return rams;
end function;
constant c_barrel: t_rams := init_Barrel;

function init_EndCap return t_rams is
  variable rams: t_rams := ( ( others => ( others => '0' ) ), ( others => ( others => '0' ) ), ( others => ( others => '0' ) ) );
  variable val, val0, val1: real;
begin
  for k in 0 to offsetR - 1 loop
    val := ( real( k ) + 0.5 ) * baseTMinv2R;
    val0 := 0.5 * ( scattering + pitchCol2S ) * val;
    val1 := 0.5 * ( scattering + pitchColPS ) * val;
    rams.r( k ) := stdu( val0, baseTMphi, widthDRdPhi );
    rams.r( k + offsetR ) := stdu( val1, baseTMphi, widthDRdPhi );
  end loop;
  for k in 0 to offsetPhi - 1 loop
    val := ( sreal( stdu( k, bram18WidthAddr - 1 ) ) + 0.5 ) * baseR + chosenRofPhi;
    val0 := 0.5 * pitchRow2S / val;
    val1 := 0.5 * pitchRowPS / val;
    if val0 > 0.0 and val0 < maxDPhi then
      rams.phi( k ) := stdu( val0, baseTMphi, widthDRdPhi );
    end if;
    if val1 > 0.0 and val1 < maxDPhi then
      rams.phi( k + offsetPhi ) := stdu( val1, baseTMphi, widthDRdPhi );
    end if;
  end loop;
  for k in 0 to offsetZ - 1 loop
    val := ( real( k ) + 0.5 ) * baseTMzT / chosenRofZ;
    val0 := 0.5 * pitchCol2S * val;
    val1 := 0.5 * pitchColPS * val;
    rams.z( k ) := stdu( val0, baseTMz, widthDRdZ );
    rams.z( k + offsetZ ) := stdu( val1, baseTMz, widthDRdZ );
  end loop;
  return rams;
end function;
constant c_endcap: t_rams := init_EndCap;

end;