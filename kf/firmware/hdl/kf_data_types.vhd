library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use work.hybrid_config.all;
use work.hybrid_tools.all;
use work.hybrid_data_types.all;
use work.hybrid_data_formats.all;
use work.kf_data_formats.all;


package kf_data_types is


constant widthParameterStub: natural := widthH00 + widthm0 + widthm1 + widthd0 + widthd1;
type t_parameterStub is
record
  H00: std_logic_vector( widthH00 - 1 downto 0 );
  m0 : std_logic_vector( widthm0  - 1 downto 0 );
  m1 : std_logic_vector( widthm1  - 1 downto 0 );
  d0 : std_logic_vector( widthd0  - 1 downto 0 );
  d1 : std_logic_vector( widthd1  - 1 downto 0 );
end record;
type t_parameterStubs is array ( natural range <> ) of t_parameterStub;
function nulll return t_parameterStub;

type t_metaT is
record
  reset: std_logic;
  valid: std_logic;
  track: std_logic_vector( widthTrack - 1 downto 0 );
end record;
type t_metaTs is array ( natural range <> ) of t_metaT;
function nulll return t_metaT;

type t_metaTH is
record
  reset: std_logic;
  valid: std_logic;
  track: std_logic_vector( widthTrack - 1 downto 0 );
  hits : std_logic_vector( 0 to widthHits - 1 );
end record;
type t_metaTHs is array ( natural range <> ) of t_metaTH;
function nulll return t_metaTH;

type t_metaTHH is
record
  reset: std_logic;
  valid: std_logic;
  track: std_logic_vector( widthTrack - 1 downto 0 );
  hitsT: std_logic_vector( 0 to widthHits - 1 );
  hitsS: std_logic_vector( 0 to widthHits - 1 );
end record;
type t_metaTHHs is array ( natural range <> ) of t_metaTHH;
function nulll return t_metaTHH;

type t_found is
record
  meta  : t_metaTH;
  track: t_parameterTrackDR;
  stubs: t_parameterStubs( 0 to numLayers - 1 );
end record;
type t_founds is array ( natural range <> ) of t_found;
function nulll return t_found;

type t_stub is
record
  meta  : t_metaT;
  param: t_parameterStub;
end record;
type t_stubs is array ( natural range <> ) of t_stub;
function nulll return t_stub;

type t_seed is
record
  meta  : t_metaTHH;
  stubs: t_parameterStubs( 0 to kfNumSeedLayer - 1 );
end record;
type t_seeds is array ( natural range <> ) of t_seed;
function nulll return t_seed;

type t_parameterTrack is
record
  x0: std_logic_vector( widthx0 - 1 downto 0 );
  x1: std_logic_vector( widthx1 - 1 downto 0 );
  x2: std_logic_vector( widthx2 - 1 downto 0 );
  x3: std_logic_vector( widthx3 - 1 downto 0 );
end record;
type t_parameterTracks is array ( natural range <> ) of t_parameterTrack;
function nulll return t_parameterTrack;

type t_uncertaintyTrack is
record
  C00: std_logic_vector( widthC00 - 1 downto 0 );
  C01: std_logic_vector( widthC01 - 1 downto 0 );
  C11: std_logic_vector( widthC11 - 1 downto 0 );
  C22: std_logic_vector( widthC22 - 1 downto 0 );
  C23: std_logic_vector( widthC23 - 1 downto 0 );
  C33: std_logic_vector( widthC33 - 1 downto 0 );
end record;
type t_uncertaintyTracks is array ( natural range <> ) of t_uncertaintyTrack;
function nulll return t_uncertaintyTrack;

type t_state is
record
  meta  : t_metaTHH;
  track: t_parameterTrack;
  cov  : t_uncertaintyTrack;
end record;
type t_states is array ( natural range <> ) of t_state;
function nulll return t_state;

type t_update is
record
  meta  : t_metaTHH;
  stub : t_parameterStub;
  track: t_parameterTrack;
  cov  : t_uncertaintyTrack;
end record;
type t_updates is array ( natural range <> ) of t_update;
function nulll return t_update;

type t_final is
record
  meta  : t_metaTH;
  track: t_parameterTrack;
end record;
type t_finals is array ( natural range <> ) of t_final;
function nulll return t_final;

type t_parameterTrackKF is
record
  inv2R: std_logic_vector( widthKFinv2R - 1 downto 0 );
  phiT : std_logic_vector( widthKFphiT  - 1 downto 0 );
  cot  : std_logic_vector( widthKFcot   - 1 downto 0 );
  zT   : std_logic_vector( widthKFzT    - 1 downto 0 );
end record;
type t_parameterTracksKF is array ( natural range <> ) of t_parameterTrackKF;
function nulll return t_parameterTrackKF;

type t_track is
record
  meta  : t_metaTH;
  track: t_parameterTrackKF;
end record;
type t_tracks is array ( natural range <> ) of t_track;
function nulll return t_track;

type t_fitted is
record
  meta  : t_metaTH;
  track: t_parameterTrackKF;
  stubs: t_parameterStubs( 0 to numLayers - 1 );
end record;
function nulll return t_fitted;


end;



package body kf_data_types is


function nulll return t_parameterStub    is begin return ( others => ( others => '0' ) );           end function;
function nulll return t_metaT             is begin return ( '0', '0', ( others => '0' ) );           end function;
function nulll return t_metaTH            is begin return ( '0', '0', others => ( others => '0' ) ); end function;
function nulll return t_metaTHH           is begin return ( '0', '0', others => ( others => '0' ) ); end function;
function nulll return t_found            is begin return ( nulll, nulll, ( others => nulll ) );     end function;
function nulll return t_stub             is begin return ( nulll, nulll );                          end function;
function nulll return t_seed             is begin return ( nulll, ( others => nulll ) );            end function;
function nulll return t_parameterTrack   is begin return ( others => ( others => '0' ) );           end function;
function nulll return t_uncertaintyTrack is begin return ( others => ( others => '0' ) );           end function;
function nulll return t_state            is begin return ( nulll, nulll, nulll );                   end function;
function nulll return t_update           is begin return ( nulll, nulll, nulll, nulll );            end function;
function nulll return t_final            is begin return ( nulll, nulll );                          end function;
function nulll return t_parameterTrackKF is begin return ( others => ( others => '0' ) );           end function;
function nulll return t_track            is begin return ( nulll, nulll );                          end function;
function nulll return t_fitted           is begin return ( nulll, nulll, ( others => nulll ) );     end function;


end;
