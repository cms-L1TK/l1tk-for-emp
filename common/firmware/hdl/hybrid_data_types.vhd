library ieee;
use ieee.std_logic_1164.all;

use work.hybrid_config.all;
use work.hybrid_data_formats.all;
use work.emp_data_types.all;


package hybrid_data_types is


type t_reset is
record
  reset: std_logic;
  start: std_logic;
end record;
function nulll return t_reset;
type t_resets is array ( natural range <> ) of t_reset;

type t_stubDTCPS is
record
  reset: std_logic;
  valid: std_logic;
  r    : std_logic_vector( widthPSr     - 1 downto 0 );
  z    : std_logic_vector( widthPSz     - 1 downto 0 );
  phi  : std_logic_vector( widthPSphi   - 1 downto 0 );
  bend : std_logic_vector( widthPSbend  - 1 downto 0 );
  layer: std_logic_vector( widthPSlayer - 1 downto 0 );
  bx   : std_logic_vector( widthPSbx    - 1 downto 0 );
end record;
function nulll return t_stubDTCPS;
type t_stubsDTCPS is array ( natural range <> ) of t_stubDTCPS;

type t_stubDTC2S is
record
  reset: std_logic;
  valid: std_logic;
  r    : std_logic_vector( width2Sr     - 1 downto 0 );
  z    : std_logic_vector( width2Sz     - 1 downto 0 );
  phi  : std_logic_vector( width2Sphi   - 1 downto 0 );
  bend : std_logic_vector( width2Sbend  - 1 downto 0 );
  layer: std_logic_vector( width2Slayer - 1 downto 0 );
  bx   : std_logic_vector( width2Sbx    - 1 downto 0 );
end record;
function nulll return t_stubDTC2S;
type t_stubsDTC2S is array ( natural range <> ) of t_stubDTC2S;

type t_stubsDTC is
record
  ps: t_stubsDTCPS( numDTCPS - 1 downto 0 );
  ss: t_stubsDTC2S( numDTC2S - 1 downto 0 );
end record;
function nulll return t_stubsDTC;

type t_trackTracklet is
record
  valid   : std_logic;
  seedType: std_logic_vector( widthTrackletSeedType - 1 downto 0 );
  inv2R   : std_logic_vector( widthTrackletInv2R    - 1 downto 0 );
  phi0    : std_logic_vector( widthTrackletPhi0     - 1 downto 0 );
  z0      : std_logic_vector( widthTrackletZ0       - 1 downto 0 );
  cot     : std_logic_vector( widthTrackletCot      - 1 downto 0 );
end record;
function nulll return t_trackTracklet;

type t_stubTracklet is
record
  valid  : std_logic;
  trackId: std_logic_vector( widthTrackletTrackId - 1 downto 0 );
  stubId : std_logic_vector( widthTrackletStubId  - 1 downto 0 );
  r      : std_logic_vector( widthTrackletR       - 1 downto 0 );
  phi    : std_logic_vector( widthTrackletPhi     - 1 downto 0 );
  z      : std_logic_vector( widthTrackletZ       - 1 downto 0 );
end record;
type t_stubsTracklet is array ( natural range <> ) of t_stubTracklet;
function nulll return t_stubTracklet;

type t_candTracklet is
record
  track: t_trackTracklet;
  stubs: t_stubsTracklet( numStubsTracklet - 1 downto 0 );
end record;
function nulll return t_candTracklet;

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


function nulll return t_reset is begin return ( others => '0' ); end function;
function nulll return t_stubDTCPS is begin return ( '0', '0', others => ( others => '0' ) ); end function;
function nulll return t_stubDTC2S is begin return ( '0', '0', others => ( others => '0' ) ); end function;
function nulll return t_stubsDTC is begin return ( ( others => nulll ), ( others => nulll ) ); end function;
function nulll return t_trackTracklet is begin return ( '0', others => ( others => '0' ) ); end function;
function nulll return t_stubTracklet is begin return ( '0', others => ( others => '0' ) ); end function;
function nulll return t_candTracklet is begin return ( nulll, ( others => nulll ) ); end function;
function nulll return t_stubKF is begin return ( '0', '0', others => ( others => '0' ) ); end function;
function nulll return t_trackKF is begin return ( '0', '0', '0', others => ( others => '0' ) ); end function;
function nulll return t_channelKF is begin return ( nulll, ( others => nulll ) ); end function;


end;
