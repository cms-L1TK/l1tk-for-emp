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
  start: std_logic;
  last: std_logic;
end record;
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
  ps: t_stubsDTCPS( numTypedStubs( 0 ) - 1 downto 0 );
  ss: t_stubsDTC2S( numTypedStubs( 1 ) - 1 downto 0 );
end record;
function nulll return t_stubsDTC;

type t_trackTB is
record
  reset   : std_logic;
  valid   : std_logic;
  seedType: std_logic_vector( widthTBseedType - 1 downto 0 );
  inv2R   : std_logic_vector( widthTBinv2R    - 1 downto 0 );
  phi0    : std_logic_vector( widthTBphi0     - 1 downto 0 );
  z0      : std_logic_vector( widthTBz0       - 1 downto 0 );
  cot     : std_logic_vector( widthTBcot      - 1 downto 0 );
end record;
function nulll return t_trackTB;

type t_stubTB is
record
  reset  : std_logic;
  valid  : std_logic;
  trackId: std_logic_vector( widthTBtrackId - 1 downto 0 );
  stubId : std_logic_vector( widthTBstubId  - 1 downto 0 );
  r      : std_logic_vector( widthTBr       - 1 downto 0 );
  phi    : std_logic_vector( widthTBphi     - 1 downto 0 );
  z      : std_logic_vector( widthTBz       - 1 downto 0 );
end record;
type t_stubsTB is array ( natural range <> ) of t_stubTB;
function nulll return t_stubTB;

type t_channelTB is
record
  track: t_trackTB;
  stubs: t_stubsTB( maxNumProjectionLayers - 1 downto 0 );
end record;
type t_channlesTB is array ( natural range <> ) of t_channelTB;
function nulll return t_channelTB;

type t_stubZHT is
record
    reset : std_logic;
    valid : std_logic;
    r     : std_logic_vector( widthZHTr    - 1 downto 0 );
    phi   : std_logic_vector( widthZHTphi  - 1 downto 0 );
    z     : std_logic_vector( widthZHTz    - 1 downto 0 );
    dPhi  : std_logic_vector( widthZHTdPhi - 1 downto 0 );
    dZ    : std_logic_vector( widthZHTdZ   - 1 downto 0 );
end record;
type t_stubsZHT is array ( natural range <> ) of t_stubZHT;
function nulll return t_stubZHT;

type t_trackZHT is
record
    reset : std_logic;
    valid : std_logic;
    maybe : std_logic_vector( widthZHTmaybe  - 1 downto 0 );
    sector: std_logic_vector( widthZHTsector - 1 downto 0 );
    phiT  : std_logic_vector( widthZHTphiT   - 1 downto 0 );
    inv2R : std_logic_vector( widthZHTinv2R  - 1 downto 0 );
    zT    : std_logic_vector( widthZHTzT     - 1 downto 0 );
    cot   : std_logic_vector( widthZHTcot    - 1 downto 0 );
end record;
type t_tracksZHT is array ( natural range <> ) of t_trackZHT;
function nulll return t_trackZHT;

type t_channelZHT is
record
    track: t_trackZHT;
    stubs: t_stubsZHT( numLayers - 1 downto 0 );
end record;
type t_channelsZHT is array ( natural range <> ) of t_channelZHT;
function nulll return t_channelZHT;

type t_stubKF is
record
    reset: std_logic;
    valid: std_logic;
    r    : std_logic_vector( widthKFr    - 1 downto 0 );
    phi  : std_logic_vector( widthKFphi  - 1 downto 0 );
    z    : std_logic_vector( widthKFz    - 1 downto 0 );
    dPhi : std_logic_vector( widthKFdPhi - 1 downto 0 );
    dZ   : std_logic_vector( widthKFdZ   - 1 downto 0 );
end record;
type t_stubsKF is array ( natural range <> ) of t_stubKF;
function nulll return t_stubKF;

type t_trackKF is
record
    reset : std_logic;
    valid : std_logic;
    match : std_logic;
    sector: std_logic_vector( widthKFsector - 1 downto 0 );
    phiT  : std_logic_vector( widthKFphiT   - 1 downto 0 );
    inv2R : std_logic_vector( widthKFinv2R  - 1 downto 0 );
    cot   : std_logic_vector( widthKFcot    - 1 downto 0 );
    zT    : std_logic_vector( widthKFzT     - 1 downto 0 );
end record;
type t_tracksKF is array ( natural range <> ) of t_trackKF;
function nulll return t_trackKF;

type t_channelKF is
record
    track: t_trackKF;
    stubs: t_stubsKF(numLayers - 1 downto 0);
end record;
type t_channelsKF is array ( natural range <> ) of t_channelKF;
function nulll return t_channelKF;

subtype t_frame is std_logic_vector( LWORD_WIDTH - 1 downto 0 );
type t_frames is array ( natural range <> ) of t_frame;


end;


package body hybrid_data_types is


function nulll return lword is begin return ( ( others => '0' ), '0', '0', '0', '1', '0' ); end function;
function nulll return t_reset is begin return ( '0', '0', others => ( others => '0' ) ); end function;
function nulll return t_stubDTCPS is begin return ( '0', '0', others => ( others => '0' ) ); end function;
function nulll return t_stubDTC2S is begin return ( '0', '0', others => ( others => '0' ) ); end function;
function nulll return t_stubsDTC is begin return ( ( others => nulll ), ( others => nulll ) ); end function;
function nulll return t_trackTB is begin return ( '0', '0', others => ( others => '0' ) ); end function;
function nulll return t_stubTB is begin return ( '0', '0', others => ( others => '0' ) ); end function;
function nulll return t_channelTB is begin return ( nulll, ( others => nulll ) ); end function;
function nulll return t_stubZHT is begin return ( '0', '0', others => ( others => '0' ) ); end function;
function nulll return t_trackZHT is begin return ( '0', '0', others => ( others => '0' ) ); end function;
function nulll return t_channelZHT is begin return ( nulll, ( others => nulll ) ); end function;
function nulll return t_stubKF is begin return ( '0', '0', others => ( others => '0' ) ); end function;
function nulll return t_trackKF is begin return ( '0', '0', '0', others => ( others => '0' ) ); end function;
function nulll return t_channelKF is begin return ( nulll, ( others => nulll ) ); end function;


end;
