library ieee;
use ieee.std_logic_1164.all;

use work.hybrid_config.all;
use work.hybrid_data_formats.all;


package hybrid_data_types is


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
  seedType: std_logic_vector( widthSeedType - 1 downto 0 );
  inv2R   : std_logic_vector( widthInv2R    - 1 downto 0 );
  phi0    : std_logic_vector( widthPhi0     - 1 downto 0 );
  z0      : std_logic_vector( widthZ0       - 1 downto 0 );
  cot     : std_logic_vector( widthCot      - 1 downto 0 );
end record;
function nulll return t_trackTracklet;

type t_stubTracklet is
record
  valid  : std_logic;
  trackId: std_logic_vector( widthTrackId - 1 downto 0 );
  stubId : std_logic_vector( widthStubId  - 1 downto 0 );
  r      : std_logic_vector( widthR       - 1 downto 0 );
  phi    : std_logic_vector( widthPhi     - 1 downto 0 );
  z      : std_logic_vector( widthZ       - 1 downto 0 );
end record;
type t_stubsTracklet is array ( natural range <> ) of t_stubTracklet;
function nulll return t_stubTracklet;

type t_candTracklet is
record
  track: t_trackTracklet;
  stubs: t_stubsTracklet( numStubsTracklet - 1 downto 0 );
end record;
function nulll return t_candTracklet;


end;


package body hybrid_data_types is


function nulll return t_stubDTCPS is begin return ( '0', '0', others => ( others => '0' ) ); end function;
function nulll return t_stubDTC2S is begin return ( '0', '0', others => ( others => '0' ) ); end function;
function nulll return t_stubsDTC is begin return ( ( others => nulll ), ( others => nulll ) ); end function;
function nulll return t_trackTracklet is begin return ( '0', others => ( others => '0' ) ); end function;
function nulll return t_stubTracklet is begin return ( '0', others => ( others => '0' ) ); end function;
function nulll return t_candTracklet is begin return ( nulll, ( others => nulll ) ); end function;


end;
