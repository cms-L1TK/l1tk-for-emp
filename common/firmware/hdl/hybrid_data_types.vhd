library ieee;
use ieee.std_logic_1164.all;

use work.hybrid_config.all;
use work.hybrid_data_formats.all;
use work.emp_data_types.all;


package hybrid_data_types is


function nulll return lword;
type t_packet is
record
  valid: std_logic;
  start_of_orbit: std_logic;
end record;
function nulll return t_packet;
type t_packets is array ( natural range <> ) of t_packet;

type t_reset is
record
  reset: std_logic;
  start: std_logic;
  bx   : std_logic_vector( widthIRBX - 1 downto 0 );
end record;
function nulll return t_reset;
type t_resets is array ( natural range <> ) of t_reset;

type t_stubDTCPS is
record
  reset: std_logic;
  valid: std_logic;
  r    : std_logic_vector( widthsIRr   ( 0 ) - 1 downto 0 );
  z    : std_logic_vector( widthsIRz   ( 0 ) - 1 downto 0 );
  phi  : std_logic_vector( widthsIRphi ( 0 ) - 1 downto 0 );
  bend : std_logic_vector( widthsIRbend( 0 ) - 1 downto 0 );
  layer: std_logic_vector( widthIRlayer      - 1 downto 0 );
end record;
function nulll return t_stubDTCPS;
type t_stubsDTCPS is array ( natural range <> ) of t_stubDTCPS;

type t_stubDTC2S is
record
  reset: std_logic;
  valid: std_logic;
  r    : std_logic_vector( widthsIRr   ( 1 ) - 1 downto 0 );
  z    : std_logic_vector( widthsIRz   ( 1 ) - 1 downto 0 );
  phi  : std_logic_vector( widthsIRphi ( 1 ) - 1 downto 0 );
  bend : std_logic_vector( widthsIRbend( 1 ) - 1 downto 0 );
  layer: std_logic_vector( widthIRlayer      - 1 downto 0 );
end record;
function nulll return t_stubDTC2S;
type t_stubsDTC2S is array ( natural range <> ) of t_stubDTC2S;

type t_stubsDTC is
record
  ps: t_stubsDTCPS( irNumTypedStubs( 0 ) - 1 downto 0 );
  ss: t_stubsDTC2S( irNumTypedStubs( 1 ) - 1 downto 0 );
end record;
function nulll return t_stubsDTC;

type t_metaTB is
record
  reset: std_logic;
  valid: std_logic;
  hits : std_logic_vector( 0 to tbNumLayers - 1 );
end record;
type t_metasTB is array ( natural range <> ) of t_metaTB;
function nulll return t_metaTB;

type t_seedsTB is array ( 0 to tbMaxNumSeedingLayer - 1 ) of std_logic_vector( widthTBstubId - 1 downto 0 );
function nulll return t_seedsTB;

type t_parameterStubTB is
record
  stubId: std_logic_vector( widthTBstubId  - 1 downto 0 );
  r     : std_logic_vector( widthTBr       - 1 downto 0 );
  phi   : std_logic_vector( widthTBphi     - 1 downto 0 );
  z     : std_logic_vector( widthTBz       - 1 downto 0 );
end record;
type t_parameterStubsTB is array ( natural range <> ) of t_parameterStubTB;
function nulll return t_parameterStubTB;

type t_parameterTrackTB is
record
  seedType: std_logic_vector( widthTBseedType - 1 downto 0 );
  inv2R   : std_logic_vector( widthTBinv2R    - 1 downto 0 );
  phi0    : std_logic_vector( widthTBphi0     - 1 downto 0 );
  z0      : std_logic_vector( widthTBz0       - 1 downto 0 );
  cot     : std_logic_vector( widthTBcot      - 1 downto 0 );
end record;
type t_parameterTracksTB is array ( natural range <> ) of t_parameterTrackTB;
function nulll return t_parameterTrackTB;

type t_trackTB is
record
  meta : t_metaTB;
  track: t_parameterTrackTB;
  seeds: t_seedsTB;
  stubs: t_parameterStubsTB( 0 to tbMaxNumProjectionLayers - 1 );
end record;
type t_tracksTB is array ( natural range <> ) of t_trackTB;
function nulll return t_trackTB;

type t_metaTM is
record
  reset: std_logic;
  valid: std_logic;
  hits : std_logic_vector( 0 to tmNumLayers - 1 );
end record;
type t_metasTM is array ( natural range <> ) of t_metaTM;
function nulll return t_metaTM;

type t_parameterStubTM is
record
  pst   : std_logic;
  stubId: std_logic_vector( widthTMstubId - 1 downto 0 );
  r     : std_logic_vector( widthTMr      - 1 downto 0 );
  phi   : std_logic_vector( widthTMphi    - 1 downto 0 );
  z     : std_logic_vector( widthTMz      - 1 downto 0 );
end record;
type t_parameterStubsTM is array ( natural range <> ) of t_parameterStubTM;
function nulll return t_parameterStubTM;

type t_parameterTrackTM is
record
  inv2R: std_logic_vector( widthTMinv2R - 1 downto 0 );
  phiT : std_logic_vector( widthTMphiT  - 1 downto 0 );
  zT   : std_logic_vector( widthTMzT    - 1 downto 0 );
end record;
type t_parameterTracksTM is array ( natural range <> ) of t_parameterTrackTM;
function nulll return t_parameterTrackTM;

type t_trackTM is
record
  meta : t_metaTM;
  track: t_parameterTrackTM;
  stubs: t_parameterStubsTM( 0 to tmNumLayers - 1 );
end record;
type t_tracksTM is array ( natural range <> ) of t_trackTM;
function nulll return t_trackTM;

constant numLinksTrack: natural := 1 + numLayers;
type t_metaDR is
record
  reset: std_logic;
  valid: std_logic;
  hits : std_logic_vector( 0 to numLayers - 1 );
end record;
function nulll return t_metaDR;

type t_parameterStubDR is
record
  r    : std_logic_vector( widthDRr    - 1 downto 0 );
  phi  : std_logic_vector( widthDRphi  - 1 downto 0 );
  z    : std_logic_vector( widthDRz    - 1 downto 0 );
  dPhi : std_logic_vector( widthDRdPhi - 1 downto 0 );
  dZ   : std_logic_vector( widthDRdZ   - 1 downto 0 );
end record;
type t_parameterStubsDR is array ( natural range <> ) of t_parameterStubDR;
function nulll return t_parameterStubDR;

type t_parameterTrackDR is
record
  inv2R: std_logic_vector( widthDRinv2R - 1 downto 0 );
  phiT : std_logic_vector( widthDRphiT  - 1 downto 0 );
  zT   : std_logic_vector( widthDRzT    - 1 downto 0 );
end record;
type t_parameterTracksDR is array ( natural range <> ) of t_parameterTrackDR;
function nulll return t_parameterTrackDR;
function conv( tm: t_parameterTrackTM ) return t_parameterTrackDR;

type t_trackDR is
record
  meta : t_metaDR;
  track: t_parameterTrackDR;
  stubs: t_parameterStubsDR( 0 to numLayers - 1 );
end record;
type t_tracksDR is array ( natural range <> ) of t_trackDR;
function nulll return t_trackDR;

type t_parameterStubKF is
record
  r    : std_logic_vector( widthKFr    - 1 downto 0 );
  phi  : std_logic_vector( widthKFphi  - 1 downto 0 );
  z    : std_logic_vector( widthKFz    - 1 downto 0 );
  dPhi : std_logic_vector( widthKFdPhi - 1 downto 0 );
  dZ   : std_logic_vector( widthKFdZ   - 1 downto 0 );
end record;
type t_parameterStubsKF is array ( natural range <> ) of t_parameterStubKF;
function nulll return t_parameterStubKF;

type t_parameterTrackKF is
record
  inv2R: std_logic_vector( widthKFinv2R - 1 downto 0 );
  phiT : std_logic_vector( widthKFphiT  - 1 downto 0 );
  cot  : std_logic_vector( widthKFcot   - 1 downto 0 );
  zT   : std_logic_vector( widthKFzT    - 1 downto 0 );
end record;
type t_parameterTracksKF is array ( natural range <> ) of t_parameterTrackKF;
function nulll return t_parameterTrackKF;

type t_trackKF is
record
  meta : t_metaDR;
  track: t_parameterTrackKF;
  stubs: t_parameterStubsKF( 0 to numLayers - 1 );
end record;
type t_tracksKF is array ( natural range <> ) of t_trackKF;
function nulll return t_trackKF;

subtype t_frame is std_logic_vector( LWORD_WIDTH - 1 downto 0 );
type t_frames is array ( natural range <> ) of t_frame;


end;


package body hybrid_data_types is


function nulll return lword              is begin return ( ( others => '0' ), '0', '0', '0', '1', '0' ); end function;
function nulll return t_packet           is begin return ( '0', '0' );                                   end function;
function nulll return t_reset            is begin return ( '0', '0', others => ( others => '0' ) );      end function;
function nulll return t_stubDTCPS        is begin return ( '0', '0', others => ( others => '0' ) );      end function;
function nulll return t_stubDTC2S        is begin return ( '0', '0', others => ( others => '0' ) );      end function;
function nulll return t_stubsDTC         is begin return ( ( others => nulll ), ( others => nulll ) );   end function;
function nulll return t_metaTB           is begin return ( '0', '0', ( others => '0' ) );                end function;
function nulll return t_seedsTB          is begin return ( others => ( others => '0' ) );                end function;
function nulll return t_parameterStubTB  is begin return ( others => ( others => '0' ) );                end function;
function nulll return t_parameterTrackTB is begin return ( others => ( others => '0' ) );                end function;
function nulll return t_trackTB          is begin return ( nulll, nulll, nulll, ( others => nulll ) );   end function;
function nulll return t_metaTM           is begin return ( '0', '0', ( others => '0' ) );                end function;
function nulll return t_parameterStubTM  is begin return ( '0', others => ( others => '0' ) );           end function;
function nulll return t_parameterTrackTM is begin return ( others => ( others => '0' ) );                end function;
function nulll return t_trackTM          is begin return ( nulll, nulll, ( others => nulll ) );          end function;
function nulll return t_metaDR           is begin return ( '0', '0', ( others => '0' ) );                end function;
function nulll return t_parameterStubDR  is begin return ( others => ( others => '0' ) );                end function;
function nulll return t_parameterTrackDR is begin return ( others => ( others => '0' ) );                end function;
function nulll return t_trackDR          is begin return ( nulll, nulll, ( others => nulll ) );          end function;
function nulll return t_parameterStubKF  is begin return ( others => ( others => '0' ) );                end function;
function nulll return t_parameterTrackKF is begin return ( others => ( others => '0' ) );                end function;
function nulll return t_trackKF          is begin return ( nulll, nulll, ( others => nulll ) );          end function;

function conv( tm: t_parameterTrackTM ) return t_parameterTrackDR is begin return ( tm.inv2R, tm.phiT, tm.zT ); end function;


end;
