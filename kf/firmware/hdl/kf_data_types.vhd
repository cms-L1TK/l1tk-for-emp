library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.tfp_config.all;
use work.tfp_tools.all;
use work.tfp_data_types.all;
use work.tfp_data_formats.all;
use work.kf_data_formats.all;


package kf_data_types is

type t_state is
record
    reset: std_logic;
    valid: std_logic;
    skip : std_logic;
    track: std_logic_vector( widthTrack - 1 downto 0 );
    lmap : std_logic_vector( widthLMap  - 1 downto 0 );
    layer: std_logic_vector( widthLayer - 1 downto 0 );
    stub : std_logic_vector( widthStubs - 1 downto 0 );
    maybe: std_logic_vector( widthMaybe - 1 downto 0 );
    hitsT: std_logic_vector( widthHitsT - 1 downto 0 );
    hits : std_logic_vector( widthHits  - 1 downto 0 );
    x0   : std_logic_vector( widthx0    - 1 downto 0 );
    x1   : std_logic_vector( widthx1    - 1 downto 0 );
    x2   : std_logic_vector( widthx2    - 1 downto 0 );
    x3   : std_logic_vector( widthx3    - 1 downto 0 );
    H00  : std_logic_vector( widthH00   - 1 downto 0 );
    m0   : std_logic_vector( widthm0    - 1 downto 0 );
    m1   : std_logic_vector( widthm1    - 1 downto 0 );
    d0   : std_logic_vector( widthd0    - 1 downto 0 );
    d1   : std_logic_vector( widthd1    - 1 downto 0 );
    C00  : std_logic_vector( widthC00   - 1 downto 0 );
    C01  : std_logic_vector( widthC01   - 1 downto 0 );
    C11  : std_logic_vector( widthC11   - 1 downto 0 );
    C22  : std_logic_vector( widthC22   - 1 downto 0 );
    C23  : std_logic_vector( widthC23   - 1 downto 0 );
    C33  : std_logic_vector( widthC33   - 1 downto 0 );
end record;
type t_states is array ( natural range <> ) of t_state;
function nulll return t_state;

type t_stateProto is
record
    reset: std_logic;
    valid: std_logic;
    skip : std_logic;
    track: std_logic_vector( widthTrack - 1 downto 0 );
    lmap : std_logic_vector( widthLMap  - 1 downto 0 );
    maybe: std_logic_vector( widthMaybe - 1 downto 0 );
    hitsT: std_logic_vector( widthHitsT - 1 downto 0 );
end record;
type t_statesProto is array ( natural range <> ) of t_stateProto;
function nulll return t_stateProto;
function conv( p: t_stateProto ) return t_state;

type t_stubProto is
record
    reset: std_logic;
    valid: std_logic;
    track: std_logic_vector( widthTrack  - 1 downto 0 );
    r    : std_logic_vector( widthSFr    - 1 downto 0 );
    phi  : std_logic_vector( widthSFphi  - 1 downto 0 );
    z    : std_logic_vector( widthSFz    - 1 downto 0 );
    dPhi : std_logic_vector( widthSFdPhi - 1 downto 0 );
    dZ   : std_logic_vector( widthSFdZ   - 1 downto 0 );
end record;
type t_stubsProto is array ( natural range <> ) of t_stubProto;
function nulll return t_stubProto;

type t_channelProto is
record
    state: t_stateProto;
    stubs: t_stubsProto( numLayers - 1 downto 0 );
end record;
function nulll return t_channelProto;

type t_channelProtoSF is
record
    track: t_trackSF;
    stubs: t_stubsProto( numLayers - 1 downto 0 );
end record;
function nulll return t_channelProtoSF;

type t_stateFit is
record
    reset: std_logic;
    valid: std_logic;
    track: std_logic_vector( widthTrack - 1 downto 0 );
    maybe: std_logic_vector( widthMaybe - 1 downto 0 );
    hits : std_logic_vector( widthHits  - 1 downto 0 );
    lmap : std_logic_vector( widthLMap  - 1 downto 0 );
    x0   : std_logic_vector( widthx0    - 1 downto 0 );
    x1   : std_logic_vector( widthx1    - 1 downto 0 );
    x2   : std_logic_vector( widthx2    - 1 downto 0 );
    x3   : std_logic_vector( widthx3    - 1 downto 0 );
end record;
type t_statesFit is array ( natural range <> ) of t_stateFit;
function nulll return t_stateFit;
function f_conv( s: t_state ) return t_stateFit;

type t_stateResidual is
record
    reset: std_logic;
    valid: std_logic;
    track: std_logic_vector( widthTrack - 1 downto 0 );
    maybe: std_logic_vector( widthMaybe - 1 downto 0 );
    x0   : std_logic_vector( widthx0    - 1 downto 0 );
    x1   : std_logic_vector( widthx1    - 1 downto 0 );
    x2   : std_logic_vector( widthx2    - 1 downto 0 );
    x3   : std_logic_vector( widthx3    - 1 downto 0 );
end record;
type t_statesResidual is array ( natural range <> ) of t_stateResidual;
function nulll return t_stateResidual;
function f_conv( s: t_stateFit ) return t_stateResidual;

type t_channelFit is
record
    state: t_stateFit;
    stubs: t_stubsProto( numLayers - 1 downto 0 );
end record;
function nulll return t_channelFit;

type t_channelResidual is
record
    state: t_stateResidual;
    stubs: t_stubsKF( numLayers - 1 downto 0 );
end record;
function nulll return t_channelResidual;

function numSkippedLayer( hitPattern:std_logic_vector ) return std_logic_vector;

type t_lmap is array ( 0 to numLayers - 1 ) of std_logic_vector( widthStubs - 1 downto 0 );
function conv( s: std_logic_vector ) return t_lmap;
function conv( l: t_lmap ) return std_logic_vector;

type t_ramv0 is array ( 0 to 2 ** widthAddrBRAM18 - 1 ) of std_logic_vector( widthDSPbu - 1 downto 0 );
type t_ramv1 is array ( 0 to 2 ** widthAddrBRAM18 - 1 ) of std_logic_vector( widthDSPbu - 1 downto 0 );
function init_ramv0 return t_ramv0;
function init_ramv1 return t_ramv1;

constant dH: std_logic_vector( widthH00 - 1 downto 0 ) := stds( integer( floor( ( chosenRofPhi - chosenRofZ ) / baseH00 ) ), widthH00 );

constant widthS00P: natural := max( widthH00 + 1 + widthC00 + 2, widthC01 + 1 + baseShiftC01 - ( baseShiftH00 + baseShiftC00 ) + 1 ) + 1;
type t_S00 is
record
    A: std_logic_vector( widthH00 + 1 - 1 downto 0 );
    B: std_logic_vector( widthC00 + 2 - 1 downto 0 );
    C: std_logic_vector( widthC01 + 1 + baseShiftC01 - ( baseShiftH00 + baseShiftC00 ) + 1 - 1 downto 0 );
    P: std_logic_vector( widthS00P - 1 downto 0 );
end record;
subtype r_S00 is natural range widthS00 + baseShiftS00 - ( baseShiftH00 + baseShiftC00 ) + 2 - 1 downto baseShiftS00 - ( baseShiftH00 + baseShiftC00 ) + 2;

constant widthS01P: natural := max( widthH00 + 1 + widthC01 + 1, widthC11 + 2 + baseShiftC11 - ( baseShiftH00 + baseShiftC01 ) + 1 ) + 1;
type t_S01 is
record
    A: std_logic_vector( widthH00 + 1 - 1 downto 0 );
    B: std_logic_vector( widthC01 + 1 - 1 downto 0 );
    C: std_logic_vector( widthC11 + 2 + baseShiftC11 - ( baseShiftH00 + baseShiftC01 ) + 1 - 1 downto 0 );
    P: std_logic_vector( widthS01P - 1 downto 0 );
end record;
subtype r_S01 is natural range widthS01 + baseShiftS01 - ( baseShiftH00 + baseShiftC01 ) + 2 - 1 downto baseShiftS01 - ( baseShiftH00 + baseShiftC01 ) + 2;

constant widthS12P: natural := max( widthH00 + 2 + widthC22 + 2, widthC23 + 1 + baseShiftC23 - ( baseShiftH12 + baseShiftC22 ) + 1 ) + 1;
type t_S12 is
record
    A: std_logic_vector( widthH00 + 1 - 1 downto 0 );
    D: std_logic_vector( widthH00 + 1 - 1 downto 0 );
    B: std_logic_vector( widthC22 + 2 - 1 downto 0 );
    C: std_logic_vector( widthC23 + 1 + baseShiftC23 - ( baseShiftH12 + baseShiftC22 ) + 1 - 1 downto 0 );
    P: std_logic_vector( widthS12P - 1 downto 0 );
end record;
subtype r_S12 is natural range widthS12 + baseShiftS12 - ( baseShiftH12 + baseShiftC22 ) + 2 - 1 downto baseShiftS12 - ( baseShiftH12 + baseShiftC22 ) + 2;

constant widthS13P: natural := max( widthH00 + 2 + widthC23 + 1, widthC33 + 2 + baseShiftC33 - ( baseShiftH12 + baseShiftC23 ) + 1 ) + 1;
type t_S13 is
record
    A: std_logic_vector( widthH00 + 1 - 1 downto 0 );
    D: std_logic_vector( widthH00 + 1 - 1 downto 0 );
    B: std_logic_vector( widthC23 + 1 - 1 downto 0 );
    C: std_logic_vector( widthC33 + 2 + baseShiftC33 - ( baseShiftH12 + baseShiftC23 ) + 1 - 1 downto 0 );
    P: std_logic_vector( widthS13P - 1 downto 0 );
end record;
subtype r_S13 is natural range widthS13 + baseShiftS13 - ( baseShiftH12 + baseShiftC23 ) + 2 - 1 downto baseShiftS13 - ( baseShiftH12 + baseShiftC23 ) + 2;

type t_S00s is array ( natural range <> ) of std_logic_vector( widthS00 - 1 downto 0 );
type t_S01s is array ( natural range <> ) of std_logic_vector( widthS01 - 1 downto 0 );
type t_S12s is array ( natural range <> ) of std_logic_vector( widthS12 - 1 downto 0 );
type t_S13s is array ( natural range <> ) of std_logic_vector( widthS13 - 1 downto 0 );

constant widthR00C: natural := max( widthS01 + 1, widthv0 + 2 + baseShiftv0 - baseShiftS01 ) + 1;
type t_R00C is
record
    S01: std_logic_vector( widthS01 + 1 - 1 downto 0 );
    v0 : std_logic_vector( widthv0 + 2 + baseShiftv0 - baseShiftS01 - 1 downto 0 );
    sum: std_logic_vector( widthR00C - 1 downto 0 );
end record;
subtype r_R00C is natural range widthR00C - 1 downto 1;

constant widthR00P: natural := max( widthH00 + 1 + widthS00 + 1, widthR00C + baseShiftS01 - ( baseShiftH00 + baseShiftS00 ) + 1 ) + 1;
type t_R00 is
record
    A0: std_logic_vector( widthH00 + 1 - 1 downto 0 );
    A1: std_logic_vector( widthH00 + 1 - 1 downto 0 );
    B : std_logic_vector( widthS00 + 1 - 1 downto 0 );
    C : std_logic_vector( widthR00C + baseShiftS01 - ( baseShiftH00 + baseShiftS00 ) + 1 - 1 downto 0 );
    P : std_logic_vector( widthR00P - 1 downto 0 );
end record;
subtype r_R00 is natural range widthR00 + baseShiftR00 - ( baseShiftH00 + baseShiftS00 ) + 2 - 1 downto baseShiftR00 - ( baseShiftH00 + baseShiftS00 ) + 2;

constant widthR11C: natural := max( widthS13 + 1, widthv1 + 2 + baseShiftv1 - baseShiftS13 ) + 1;
type t_R11C is
record
    S13: std_logic_vector( widthS13 + 1 - 1 downto 0 );
    v1 : std_logic_vector( widthv1 + 2 + baseShiftv1 - baseShiftS13 - 1 downto 0 );
    sum: std_logic_vector( widthR11C - 1 downto 0 );
end record;
subtype r_R11C is natural range widthR11C - 1 downto 1;

constant widthR11P: natural := max( widthH00 + 2 + widthS12 + 1, widthR11C + baseShiftS13 - ( baseShiftH12 + baseShiftS12 ) + 1 ) + 1;
type t_R11 is
record
    A : std_logic_vector( widthH00 + 1 - 1 downto 0 );
    D : std_logic_vector( widthH00 + 1 - 1 downto 0 );
    AD: std_logic_vector( widthH00 + 2 - 1 downto 0 );
    B : std_logic_vector( widthS12 + 1 - 1 downto 0 );
    C : std_logic_vector( widthR11C + baseShiftS13 - ( baseShiftH12 + baseShiftS12 ) + 1 - 1 downto 0 );
    P : std_logic_vector( widthR11P - 1 downto 0 );
end record;
subtype r_R11 is natural range widthR11 + baseShiftR11 - ( baseShiftH12 + baseShiftS12 ) + 2 - 1 downto baseShiftR11 - ( baseShiftH12 + baseShiftS12 ) + 2;

type t_R00s is array ( natural range <> ) of std_logic_vector( widthR00 - 1 downto 0 );
type t_R11s is array ( natural range <> ) of std_logic_vector( widthR11 - 1 downto 0 );

function f_dynamicShift( s: std_logic_vector ) return std_logic_vector;

type t_ramInvR00 is array ( 0 to 2 ** widthR00Rough - 1 ) of std_logic_vector( widthInvR00Approx - 1 downto 0 );
type t_ramInvR11 is array ( 0 to 2 ** widthR11Rough - 1 ) of std_logic_vector( widthInvR11Approx - 1 downto 0 );
function init_ramInvR00 return t_ramInvR00;
function init_ramInvR11 return t_ramInvR11;

constant widthInvR00Cor2: natural := widthInvR00Approx + widthR00Rough + 1;
constant invR00Cor2: std_logic_vector( widthInvR00Cor2 - 1 downto 0 ) := stdu( int( 2.0, baseInvR00Approx * baseR00Rough ), widthInvR00Cor2 );

constant widthInvR00CorP: natural := max( widthInvR00Approx + 2 + widthR00Rough + 2, widthInvR00Cor2 + 3 ) + 1;
type t_invR00Cor is
record
    A : std_logic_vector( widthInvR00Approx + 2 - 1 downto 0 );
    B0: std_logic_vector( widthR00Rough + 2 - 1 downto 0 );
    B1: std_logic_vector( widthR00Rough + 2 - 1 downto 0 );
    C : std_logic_vector( widthInvR00Cor2 + 3 - 1 downto 0 );
    P : std_logic_vector( widthInvR00CorP - 1 downto 0 );
end record;
subtype r_invR00Cor is natural range widthInvR00Cor + baseShiftInvR00Cor - ( baseShiftInvR00Approx + baseShiftR00Rough ) + 2 - 1 downto baseShiftInvR00Cor - ( baseShiftInvR00Approx + baseShiftR00Rough ) + 2;

constant widthInvR11Cor2: natural := widthInvR11Approx + widthR11Rough + 1;
constant invR11Cor2: std_logic_vector( widthInvR00Cor2 - 1 downto 0 ) := stdu( int( 2.0, baseInvR11Approx * baseR11Rough ), widthInvR11Cor2 );

constant widthInvR11CorP: natural := max( widthInvR11Approx + 2 + widthR11Rough + 2, widthInvR11Cor2 + 3 ) + 1;
type t_invR11Cor is
record
    A : std_logic_vector( widthInvR11Approx + 2 - 1 downto 0 );
    B0: std_logic_vector( widthR11Rough + 2 - 1 downto 0 );
    B1: std_logic_vector( widthR11Rough + 2 - 1 downto 0 );
    C : std_logic_vector( widthInvR11Cor2 + 3 - 1 downto 0 );
    P : std_logic_vector( widthInvR11CorP - 1 downto 0 );
end record;
subtype r_invR11Cor is natural range widthInvR00Cor + baseShiftInvR11Cor - ( baseShiftInvR11Approx + baseShiftR11Rough ) + 2 - 1 downto baseShiftInvR11Cor - ( baseShiftInvR11Approx + baseShiftR11Rough ) + 2;

constant widthInvR00P: natural := widthInvR00Approx + 2 + widthInvR00Cor + 2;
type t_invR00 is
record
    A0: std_logic_vector( widthInvR00Approx + 2 - 1 downto 0 );
    A1: std_logic_vector( widthInvR00Approx + 2 - 1 downto 0 );
    B : std_logic_vector( widthInvR00Cor + 2 - 1 downto 0 );
    P : std_logic_vector( widthInvR00P - 1 downto 0 );
end record;
subtype r_invR00 is natural range widthInvR00 + baseShiftInvR00 - ( baseShiftInvR00Approx + baseShiftInvR00Cor ) + 1 - 1 downto baseShiftInvR00 - ( baseShiftInvR00Approx + baseShiftInvR00Cor ) + 1;

constant widthInvR11P: natural := widthInvR11Approx + 2 + widthInvR11Cor + 2;
type t_invR11 is
record
    A0: std_logic_vector( widthInvR11Approx + 2 - 1 downto 0 );
    A1: std_logic_vector( widthInvR11Approx + 2 - 1 downto 0 );
    B : std_logic_vector( widthInvR11Cor + 2 - 1 downto 0 );
    P : std_logic_vector( widthInvR11P - 1 downto 0 );
end record;
subtype r_invR11 is natural range widthInvR11 + baseShiftInvR11 - ( baseShiftInvR11Approx + baseShiftInvR11Cor ) + 1 - 1 downto baseShiftInvR11 - ( baseShiftInvR11Approx + baseShiftInvR11Cor ) + 1;

type t_K00 is
record
    A : std_logic_vector( widthInvR00 + 2 - 1 downto 0 );
    B0: std_logic_vector( widthS00 + 1 - 1 downto 0 );
    B1: std_logic_vector( widthS00 + 1 - 1 downto 0 );
    P : std_logic_vector( widthInvR00 + 2 + widthS00 + 1 - 1 downto 0 );
end record;
subtype r_K00 is natural range widthK00 + baseShiftK00 - ( baseShiftS00 + baseShiftInvR00 ) + 2 - 1 downto baseShiftK00 - ( baseShiftS00 + baseShiftInvR00 ) + 2;

type t_K10 is
record
    A : std_logic_vector( widthInvR00 + 2 - 1 downto 0 );
    B0: std_logic_vector( widthS01 + 1 - 1 downto 0 );
    B1: std_logic_vector( widthS01 + 1 - 1 downto 0 );
    P : std_logic_vector( widthInvR00 + 2 + widthS01 + 1 - 1 downto 0 );
end record;
subtype r_K10 is natural range widthK10 + baseShiftK10 - ( baseShiftS01 + baseShiftInvR00 ) + 2 - 1 downto baseShiftK10 - ( baseShiftS01 + baseShiftInvR00 ) + 2;

type t_K21 is
record
    A : std_logic_vector( widthInvR11 + 2 - 1 downto 0 );
    B0: std_logic_vector( widthS12 + 1 - 1 downto 0 );
    B1: std_logic_vector( widthS12 + 1 - 1 downto 0 );
    P : std_logic_vector( widthinvR11 + 2 + widthS12 + 1 - 1 downto 0 );
end record;
subtype r_K21 is natural range widthK21 + baseShiftK21 - ( baseShiftS12 + baseShiftInvR11 ) + 2 - 1 downto baseShiftK21 - ( baseShiftS12 + baseShiftInvR11 ) + 2;

type t_K31 is
record
    A : std_logic_vector( widthInvR11 + 2 - 1 downto 0 );
    B0: std_logic_vector( widthS13 + 1 - 1 downto 0 );
    B1: std_logic_vector( widthS13 + 1 - 1 downto 0 );
    P : std_logic_vector( widthInvR11 + 2 + widthS13 + 1 - 1 downto 0 );
end record;
subtype r_K31 is natural range widthK31 + baseShiftK31 - ( baseShiftS13 + baseShiftInvR11 ) + 2 - 1 downto baseShiftK31 - ( baseShiftS13 + baseShiftInvR11 ) + 2;

constant widthx0P: natural := max( widthK00 + 1 + widthr0 + 1, widthx0 + 1 + baseShiftx0 - ( baseShiftK00 + baseShiftr0 ) + 1 ) + 1;
type t_x0 is
record
    A : std_logic_vector( widthK00 + 1 - 1 downto 0 );
    B0: std_logic_vector( widthr0 + 1 - 1 downto 0 );
    B1: std_logic_vector( widthr0 + 1 - 1 downto 0 );
    C : std_logic_vector( widthx0 + 1 + baseShiftx0 - ( baseShiftK00 + baseShiftr0 ) + 1 - 1 downto 0 );
    P : std_logic_vector( widthx0P - 1 downto 0 );
end record;
subtype r_x0 is natural range widthx0 + baseShiftx0 - ( baseShiftK00 + baseShiftr0 ) + 2 - 1 downto baseShiftx0 - ( baseShiftK00 + baseShiftr0 ) + 2;

constant widthx1P: natural := max( widthK10 + 1 + widthr0 + 1, widthx1 + 1 + baseShiftx1 - ( baseShiftK10 + baseShiftr0 ) + 1 ) + 1;
type t_x1 is
record
    A : std_logic_vector( widthK10 + 1 - 1 downto 0 );
    B0: std_logic_vector( widthr0 + 1 - 1 downto 0 );
    B1: std_logic_vector( widthr0 + 1 - 1 downto 0 );
    C : std_logic_vector( widthx1 + 1 + baseShiftx1 - ( baseShiftK10 + baseShiftr0 ) + 1 - 1 downto 0 );
    P : std_logic_vector( widthx1P - 1 downto 0 );
end record;
subtype r_x1 is natural range widthx1 + baseShiftx1 - ( baseShiftK10 + baseShiftr0 ) + 2 - 1 downto baseShiftx1 - ( baseShiftK10 + baseShiftr0 ) + 2;

constant widthx2P: natural := max( widthK21 + 1 + widthr1 + 1, widthx2 + 1 + baseShiftx2 - ( baseShiftK21 + baseShiftr1 ) + 1 ) + 1;
type t_x2 is
record
    A : std_logic_vector( widthK21 + 1 - 1 downto 0 );
    B0: std_logic_vector( widthr1 + 1 - 1 downto 0 );
    B1: std_logic_vector( widthr1 + 1 - 1 downto 0 );
    C : std_logic_vector( widthx2 + 1 + baseShiftx2 - ( baseShiftK21 + baseShiftr1 ) + 1 - 1 downto 0 );
    P : std_logic_vector( widthx2P - 1 downto 0 );
end record;
subtype r_x2 is natural range widthx2 + baseShiftx2 - ( baseShiftK21 + baseShiftr1 ) + 2 - 1 downto baseShiftx2 - ( baseShiftK21 + baseShiftr1 ) + 2;

constant widthx3P: natural := max( widthK31 + 1 + widthr1 + 1, widthx3 + 1 + baseShiftx3 - ( baseShiftK31 + baseShiftr1 ) + 1 ) + 1;
type t_x3 is
record
    A : std_logic_vector( widthK31 + 1 - 1 downto 0 );
    B0: std_logic_vector( widthr1 + 1 - 1 downto 0 );
    B1: std_logic_vector( widthr1 + 1 - 1 downto 0 );
    C : std_logic_vector( widthx3 + 1 + baseShiftx3 - ( baseShiftK31 + baseShiftr1 ) + 1 - 1 downto 0 );
    P : std_logic_vector( widthx3P - 1 downto 0 );
end record;
subtype r_x3 is natural range widthx3 + baseShiftx3 - ( baseShiftK31 + baseShiftr1 ) + 2 - 1 downto baseShiftx3- ( baseShiftK31 + baseShiftr1 ) + 2;

constant widthC00P: natural := max( widthK00 + 1 + widthS00 + 1, widthC00 + 1 + baseShiftC00 - ( baseShiftK00 + baseShiftS00 ) + 1 ) + 1;
type t_C00 is
record
    A : std_logic_vector( widthK00 + 1 - 1 downto 0 );
    B0: std_logic_vector( widthS00 + 1 - 1 downto 0 );
    B1: std_logic_vector( widthS00 + 1 - 1 downto 0 );
    C : std_logic_vector( widthC00 + 1 + baseShiftC00 - ( baseShiftK00 + baseShiftS00 ) + 1 - 1 downto 0 );
    P : std_logic_vector( widthC00P - 1 downto 0 );
end record;
subtype r_C00 is natural range widthC00 + baseShiftC00 - ( baseShiftK00 + baseShiftS00 ) + 2 - 1 downto baseShiftC00 - ( baseShiftK00 + baseShiftS00 ) + 2;

constant widthC01P: natural := max( widthK00 + 1 + widthS01 + 1, widthC01 + 1 + baseShiftC01 - ( baseShiftK00 + baseShiftS01 ) + 1 ) + 1;
type t_C01 is
record
    A : std_logic_vector( widthK00 + 1 - 1 downto 0 );
    B0: std_logic_vector( widthS01 + 1 - 1 downto 0 );
    B1: std_logic_vector( widthS01 + 1 - 1 downto 0 );
    C : std_logic_vector( widthC01 + 1 + baseShiftC01 - ( baseShiftK00 + baseShiftS01 ) + 1 - 1 downto 0 );
    P : std_logic_vector( widthC01P - 1 downto 0 );
end record;
subtype r_C01 is natural range widthC01 + baseShiftC01 - ( baseShiftK00 + baseShiftS01 ) + 2 - 1 downto baseShiftC01 - ( baseShiftK00 + baseShiftS01 ) + 2;

constant widthC11P: natural := max( widthK10 + 1 + widthS01 + 1, widthC11 + 1 + baseShiftC11 - ( baseShiftK10 + baseShiftS01 ) + 1 ) + 1;
type t_C11 is
record
    A : std_logic_vector( widthK10 + 1 - 1 downto 0 );
    B0: std_logic_vector( widthS01 + 1 - 1 downto 0 );
    B1: std_logic_vector( widthS01 + 1 - 1 downto 0 );
    C : std_logic_vector( widthC11 + 1 + baseShiftC11 - ( baseShiftK10 + baseShiftS01 ) + 1 - 1 downto 0 );
    P : std_logic_vector( widthC11P - 1 downto 0 );
end record;
subtype r_C11 is natural range widthC11 + baseShiftC11 - ( baseShiftK10 + baseShiftS01 ) + 2 - 1 downto baseShiftC11 - ( baseShiftK10 + baseShiftS01 ) + 2;

constant widthC22P: natural := max( widthK21 + 1 + widthS12 + 1, widthC22 + 1 + baseShiftC22 - ( baseShiftK21 + baseShiftS12 ) + 1 ) + 1;
type t_C22 is
record
    A : std_logic_vector( widthK21 + 1 - 1 downto 0 );
    B0: std_logic_vector( widthS12 + 1 - 1 downto 0 );
    B1: std_logic_vector( widthS12 + 1 - 1 downto 0 );
    C : std_logic_vector( widthC22 + 1 + baseShiftC22 - ( baseShiftK21 + baseShiftS12 ) + 1 - 1 downto 0 );
    P : std_logic_vector( widthC22P - 1 downto 0 );
end record;
subtype r_C22 is natural range widthC22 + baseShiftC22 - ( baseShiftK21 + baseShiftS12 ) + 2 - 1 downto baseShiftC22 - ( baseShiftK21 + baseShiftS12 ) + 2;

constant widthC23P: natural := max( widthK21 + 1 + widthS13 + 1, widthC23 + 1 + baseShiftC23 - ( baseShiftK21 + baseShiftS13 ) + 1 ) + 1;
type t_C23 is
record
    A : std_logic_vector( widthK21 + 1 - 1 downto 0 );
    B0: std_logic_vector( widthS13 + 1 - 1 downto 0 );
    B1: std_logic_vector( widthS13 + 1 - 1 downto 0 );
    C : std_logic_vector( widthC23 + 1 + baseShiftC23 - ( baseShiftK21 + baseShiftS13 ) + 1 - 1 downto 0 );
    P : std_logic_vector( widthC23P - 1 downto 0 );
end record;
subtype r_C23 is natural range widthC23 + baseShiftC23 - ( baseShiftK21 + baseShiftS13 ) + 2 - 1 downto baseShiftC23 - ( baseShiftK21 + baseShiftS13 ) + 2;

constant widthC33P: natural := max( widthK31 + 1 + widthS13 + 1, widthC33 + 1 + baseShiftC33 - ( baseShiftK31 + baseShiftS13 ) + 1 ) + 1;
type t_C33 is
record
    A : std_logic_vector( widthK31 + 1 - 1 downto 0 );
    B0: std_logic_vector( widthS13 + 1 - 1 downto 0 );
    B1: std_logic_vector( widthS13 + 1 - 1 downto 0 );
    C : std_logic_vector( widthC33 + 1 + baseShiftC33 - ( baseShiftK31 + baseShiftS13 ) + 1 - 1 downto 0 );
    P : std_logic_vector( widthC33P - 1 downto 0 );
end record;
subtype r_C33 is natural range widthC33 + baseShiftC33 - ( baseShiftK31 + baseShiftS13 ) + 2 - 1 downto baseShiftC33 - ( baseShiftK31 + baseShiftS13 ) + 2;

constant widthr0C: natural := max( widthm0 + baseShiftm0 - baseShiftx1 + 1, widthx1 + 1 ) + 1;
type t_r0C is
record
    m0 : std_logic_vector( widthm0 + baseShiftm0 - baseShiftx1 + 1 - 1 downto 0 );
    x1 : std_logic_vector( widthx1 + 1 - 1 downto 0 );
    sum: std_logic_vector( widthr0C - 1 downto 0 );
end record;
subtype r_r0C is natural range widthr0C - 1 downto 1;

constant widthr0P: natural := max( widthH00 + 1 + widthx0 + 1, widthr0C + baseShiftx1 - ( baseShiftx0 + baseShiftH00 ) + 1 ) + 1;
type t_r0 is
record
    A0: std_logic_vector( widthH00 + 1 - 1 downto 0 );
    A1: std_logic_vector( widthH00 + 1 - 1 downto 0 );
    B0: std_logic_vector( widthX0 + 1 - 1 downto 0 );
    B1: std_logic_vector( widthX0 + 1 - 1 downto 0 );
    C : std_logic_vector( widthr0C + baseShiftx1 - ( baseShiftx0 + baseShiftH00 ) + 1 - 1 downto 0 );
    P : std_logic_vector( widthr0P - 1 downto 0 );
end record;
subtype r_r0 is natural range widthr0 + baseShiftr0 - ( baseShiftx0 + baseShiftH00 ) + 2 - 1 downto baseShiftr0 - ( baseShiftx0 + baseShiftH00 ) + 2;
subtype r_phi is natural range widthKFphi + baseShiftm0 - ( baseShiftx0 + baseShiftH00 ) + 2 - 1 downto baseShiftm0 - ( baseShiftx0 + baseShiftH00 ) + 2;

constant widthr1C: natural := max( widthm1 + baseShiftm1 - baseShiftx3 + 1, widthx3 + 1 ) + 1;
type t_r1C is
record
    m1 : std_logic_vector( widthm1 + baseShiftm1 - baseShiftx3 + 1 - 1 downto 0 );
    x3 : std_logic_vector( widthx3 + 1 - 1 downto 0 );
    sum: std_logic_vector( widthr1C - 1 downto 0 );
end record;
subtype r_r1C is natural range widthr1C - 1 downto 1;

constant widthr1P: natural := max( widthH00 + 2 + widthx2 + 1, widthr1C + baseShiftx3 - ( baseShiftx2 + baseShiftH12 ) + 1 ) + 1;
type t_r1 is
record
    A : std_logic_vector( widthH00 + 1 - 1 downto 0 );
    D : std_logic_vector( widthH00 + 1 - 1 downto 0 );
    AD: std_logic_vector( widthH00 + 2 - 1 downto 0 );
    B0: std_logic_vector( widthx2 + 1 - 1 downto 0 );
    B1: std_logic_vector( widthx2 + 1 - 1 downto 0 );
    C : std_logic_vector( widthr1C + baseShiftx3 - ( baseShiftx2 + baseShiftH12 ) + 1 - 1 downto 0 );
    P : std_logic_vector( widthr1P - 1 downto 0 );
end record;
subtype r_r1 is natural range widthr1 + baseShiftr1 - ( baseShiftx2 + baseShiftH12 ) + 2 - 1 downto baseShiftr1 - ( baseShiftx2 + baseShiftH12 ) + 2;
subtype r_z is natural range widthKFz + baseShiftm1 - ( baseShiftx2 + baseShiftH12 ) + 2 - 1 downto baseShiftm1 - ( baseShiftx2 + baseShiftH12 ) + 2;

type t_r0s is array ( natural range <> ) of std_logic_vector( widthr0 - 1 downto 0 );
type t_r1s is array ( natural range <> ) of std_logic_vector( widthr1 - 1 downto 0 );

constant baseShift0: integer := integer( round( log2( baseSFinv2R / baseKFinv2R ) ) );
constant baseShift1: integer := integer( round( log2( baseSFphiT  / baseKFphiT  ) ) );
constant baseShift2: integer := integer( round( log2( baseSFcot   / baseKFcot   ) ) );
constant baseShift3: integer := integer( round( log2( baseSFzT    / baseKFzT    ) ) );

--constant widthValidx0: natural := widthx0 + baseShiftx0 - baseShift0;
--constant widthValidx1: natural := widthx1 + baseShiftx1 - baseShift1;
--constant widthValidx2: natural := widthx2 + baseShiftx2 - baseShift2;
--constant widthValidx3: natural := widthx3 + baseShiftx3 - baseShift3;
--subtype r_validx0 is natural range widthx0 - 1 downto widthx0 - widthValidx0;
--subtype r_validx1 is natural range widthx1 - 1 downto widthx1 - widthValidx1;
--subtype r_validx2 is natural range widthx2 - 1 downto widthx2 - widthValidx2;
--subtype r_validx3 is natural range widthx3 - 1 downto widthx3 - widthValidx3;

type t_inv2R is
record
    match: std_logic;
    over : std_logic_vector( widthx0 - ( baseShift0 - baseShiftx0 ) + 1 - 1 downto 0 );
    x    : std_logic_vector( widthKFinv2R - baseShiftx0 - 1 downto 0 );
    dx   : std_logic_vector( widthKFinv2R - baseShiftx0 - 1 downto 0 );
    sum  : std_logic_vector( widthKFinv2R - baseShiftx0 + 1 - 1 downto 0 );
end record;
subtype r_inv2R is natural range widthKFinv2R - baseShiftx0 - 1 downto -baseShiftx0;

type t_phiT is
record
    match: std_logic;
    over : std_logic_vector( widthx1 - ( baseShift1 - baseShiftx1 ) + 1 - 1 downto 0 );
    x    : std_logic_vector( widthKFphiT - baseShiftx1 - 1 downto 0 );
    dx   : std_logic_vector( widthKFphiT - baseShiftx1 - 1 downto 0 );
    sum  : std_logic_vector( widthKFphiT - baseShiftx1 + 1 - 1 downto 0 );
end record;
subtype r_phiT is natural range widthKFphiT - baseShiftx1 - 1 downto -baseShiftx1;

type t_cot is
record
    x    : std_logic_vector( widthKFcot - baseShiftx2 - 1 downto 0 );
    dx   : std_logic_vector( widthKFcot - baseShiftx2 - 1 downto 0 );
    sum  : std_logic_vector( widthKFcot - baseShiftx2 + 1 - 1 downto 0 );
end record;
subtype r_cot is natural range widthKFcot - baseShiftx2 - 1 downto -baseShiftx2;

type t_zT is
record
    x    : std_logic_vector( widthKFzT - baseShiftx3 - 1 downto 0 );
    dx   : std_logic_vector( widthKFzT - baseShiftx3 - 1 downto 0 );
    sum  : std_logic_vector( widthKFzT - baseShiftx3 + 1 - 1 downto 0 );
end record;
subtype r_zT is natural range widthKFzT - baseShiftx3 - 1 downto -baseShiftx3;

function nulll return t_inv2R;
function nulll return t_phiT;
function nulll return t_cot;
function nulll return t_zT;

type t_srr is array   ( natural range <> ) of std_logic_vector( widthKFr   - 1 downto 0 );
type t_srphi is array ( natural range <> ) of std_logic_vector( widthKFphi - 1 downto 0 );
type t_srz is array   ( natural range <> ) of std_logic_vector( widthKFz   - 1 downto 0 );

end;


package body kf_data_types is

function nulll return t_state is begin return ( '0', '0', '0', others => ( others => '0' ) ); end function;
function nulll return t_stateProto is begin return ( '0', '0', '0', others => ( others => '0' ) ); end function;
function nulll return t_stubProto is begin return ( '0', '0', others => ( others => '0' ) ); end function;
function nulll return t_stateFit is begin return ( '0', '0', others => ( others => '0' ) ); end function;
function nulll return t_stateResidual is begin return ( '0', '0', others => ( others => '0' ) ); end function;
function nulll return t_channelProto is begin return ( nulll, ( others => nulll ) ); end function;
function nulll return t_channelProtoSF is begin return ( nulll, ( others => nulll ) ); end function;
function nulll return t_channelFit is begin return ( nulll, ( others => nulll ) ); end function;
function nulll return t_channelResidual is begin return ( nulll, ( others => nulll ) ); end function;

function conv( p: t_stateProto ) return t_state is
    variable s: t_state := nulll;
begin
    s.reset := p.reset;
    s.valid := p.valid;
    s.skip := p.skip;
    s.track := p.track;
    s.lmap := p.lmap;
    s.maybe := p.maybe;
    s.hitsT := p.hitsT;
    s.C00 := cov_00;
    s.C11 := cov_11;
    s.C22 := cov_22;
    s.C33 := cov_33;
    return s;
end function;

function f_conv( s: t_state ) return t_stateFit is
    variable state: t_stateFit := ( s.reset, s.valid, s.track, s.maybe, s.hits, s.lmap, s.x0, s.x1, s.x2, s.x3 );
begin
    return state;
end function;

function f_conv( s: t_stateFit ) return t_stateResidual is
    variable state: t_stateResidual := ( s.reset, s.valid, s.track, s.maybe, s.x0, s.x1, s.x2, s.x3 );
begin
    return state;
end function;

function numSkippedLayer( hitPattern:std_logic_vector ) return std_logic_vector is
    variable n: natural := 0;
    variable res: std_logic_vector( hitPattern'range ) := ( others => '0' );
begin
    for k in hitPattern'low to hitPattern'high loop
        if hitPattern( k ) = '0' then
            n := n + 1;
        else
            res := stdu( n, hitPattern'length );
        end if;
    end loop;
    return res;
end function;

function conv( s: std_logic_vector ) return t_lmap is
    variable m: t_lmap := ( others => ( others => '0' ) );
begin
    for k in 0 to numLayers - 1 loop
        m( k ) := s( ( k + 1 ) * widthStubs - 1 downto k * widthStubs );
    end loop;
    return m;
end function;

function conv( l: t_lmap ) return std_logic_vector is
    variable s: std_logic_vector( widthLMap - 1 downto 0 ) := ( others => '0' );
begin
    for k in l'range loop
        s( ( k + 1 ) * widthStubs - 1 downto k * widthStubs ) := l( k );
    end loop;
    return s;
end function;

function init_ramv0 return t_ramv0 is
  variable ram: t_ramv0 := ( others => ( others => '0' ) );
  variable d0, v0: real;
begin 
  for k in ram'range loop
    d0 := ( real( k ) + 0.5 ) * based0;
    v0 := d0 ** 2;
    if v0 / basev0 < 2.0 ** widthv0 then
        ram( k ) := stdu( v0 / basev0, widthv0 );
    end if;
  end loop;
  return ram;
end function;

function init_ramv1 return t_ramv1 is
  variable ram: t_ramv1 := ( others => ( others => '0' ) );
  variable d1, v1: real;
begin
  for k in ram'range loop
    d1 := ( real( k ) + 0.5 ) * based1;
    v1 := d1 ** 2;
    if v1 / basev1 < 2.0 ** widthv1 then
        ram( k ) := stdu( v1 / basev1, widthv1 );
    end if;
  end loop;
  return ram;
end function;

function f_dynamicShift( s: std_logic_vector ) return std_logic_vector is
    variable len: natural := width( s'length ) + 1;
    variable res: std_logic_vector( len - 1 downto 0 ) := ( others => '0' );
begin
    res( res'high ) := '1';
    for k in s'range loop
        if s( k ) = '1' then
            res := stdu( s'length - k - 1, len );
            exit;
        end if;
    end loop;
    return res;
end function;

function init_ramInvR00 return t_ramInvR00 is
    variable ram: t_ramInvR00 := ( others => ( others => '0' ) );
    variable R00Rough, invR00Approx: real;
begin
    for k in ram'range loop
        R00Rough := ( real( k ) + 0.5 ) * baseR00Rough;
        invR00Approx := 1.0 / R00Rough;
        if invR00Approx / baseInvR00Approx < 2.0 ** widthInvR00Approx then
            ram( k ) := stdu( invR00Approx / baseInvR00Approx, widthInvR00Approx );
        end if;
    end loop;
    return ram;
end function;

function init_ramInvR11 return t_ramInvR11 is
    variable ram: t_ramInvR11 := ( others => ( others => '0' ) );
    variable R11Rough, invR11Approx: real;
begin
    for k in ram'range loop
        R11Rough := ( real( k ) + 0.5 ) * baseR11Rough;
        invR11Approx := 1.0 / R11Rough;
        if invR11Approx / baseInvR11Approx < 2.0 ** widthInvR11Approx then
            ram( k ) := stdu( invR11Approx / baseInvR11Approx, widthInvR11Approx );
        end if;
    end loop;
    return ram;
end function;

function nulll return t_inv2R is begin return ( '0', others => ( others => '0' ) ); end function;
function nulll return t_phiT  is begin return ( '0', others => ( others => '0' ) ); end function;
function nulll return t_cot   is begin return ( others => ( others => '0' ) ); end function;
function nulll return t_zT    is begin return ( others => ( others => '0' ) ); end function;

end;
