library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.hybrid_data_formats.all;
use work.kf_data_formats.all;
use work.kf_data_types.all;


package kf_state_pkg is


constant widthDH    : natural := bram18WidthAddr;
constant widthInvDH : natural := dspWidthBu;
constant widthInvDH2: natural := dspWidthBu;

constant rangeDH    : real := radiusOuter - radiusInner;
constant rangeInvDH : real := 1.0 / kfMinSeedDeltaR;
constant rangeInvDH2: real := rangeInvDH * rangeInvDH;

constant baseDiffDH    : integer := ilog2( rangeDH / baseH00 ) - widthDH;
constant baseDiffInvdH : integer := ilog2( rangeInvdH  / 2.0 ** widthInvdH  * baseTMr );
constant baseDiffInvdH2: integer := ilog2( rangeInvdH2 / 2.0 ** widthInvdH2 * baseTMr * baseTMr );

constant baseDH    : real := 2.0 ** baseDiffDH     * baseTMr;
constant baseInvDH : real := 2.0 ** baseDiffInvdH  / baseTMr;
constant baseInvDH2: real := 2.0 ** baseDiffInvdH2 / baseTMr / baseTMr;

type t_invDHs is array ( 0 to 2 ** widthDH - 1 ) of std_logic_vector( widthInvDH - 1 downto 0 );
function init_invDHs return t_invDHs;
type t_invDH2s is array ( 0 to 2 ** widthDH - 1 ) of std_logic_vector( widthInvDH2 - 1 downto 0 );
function init_invDH2s return t_invDH2s;

type t_v0s is array ( 0 to 2 ** widthD0 - 1 ) of std_logic_vector( widthV0 - 1 downto 0 );
function init_v0s return t_v0s;
type t_v1s is array ( 0 to 2 ** widthD1 - 1 ) of std_logic_vector( widthV1 - 1 downto 0 );
function init_v1s return t_v1s;

constant widthH0H0: natural := widthH00 + widthH00;
constant widthDSPH02A: natural := widthH00 + 1;
constant widthDSPH02B: natural := widthH00 + 1;
constant widthDSPH02P: natural := widthDSPH02A + widthDSPH02B;
type t_dspH02 is
record
  A: std_logic_vector( widthDSPH02A - 1 downto 0 ); -- H00
  B: std_logic_vector( widthDSPH02B - 1 downto 0 ); -- H00
  P: std_logic_vector( widthDSPH02P - 1 downto 0 ); -- H00 * H00
end record;
subtype r_H02 is natural range widthH0H0 + 2 - 1 downto 2;

constant widthH1H1: natural := widthH12 + widthH12;
constant widthDSPH12A: natural := widthH12 + 1;
constant widthDSPH12B: natural := widthH12 + 1;
constant widthDSPH12P: natural := widthDSPH12A + widthDSPH12B;
type t_dspH12 is
record
  A: std_logic_vector( widthDSPH12A - 1 downto 0 ); -- H11
  B: std_logic_vector( widthDSPH12B - 1 downto 0 ); -- H11
  P: std_logic_vector( widthDSPH12P - 1 downto 0 ); -- H11 * H11
end record;
subtype r_H12 is natural range widthH1H1 + 2 - 1 downto 2;

constant widthHm0: natural := widthH00 + widthm0;
constant widthDSPHm0A: natural := widthH00 + 1;
constant widthDSPHm0B: natural := widthm0 + 1;
constant widthDSPHm0P: natural := widthDSPHm0A + widthDSPHm0B;
type t_dspHm0 is
record
  A0: std_logic_vector( widthDSPHm0A - 1 downto 0 ); -- H00
  A : std_logic_vector( widthDSPHm0A - 1 downto 0 ); -- H00
  B0: std_logic_vector( widthDSPHm0B - 1 downto 0 ); -- m0
  B : std_logic_vector( widthDSPHm0B - 1 downto 0 ); -- m0
  P : std_logic_vector( widthDSPHm0P - 1 downto 0 ); -- m0 * H00
end record;
subtype r_Hm0 is natural range widthHm0 + 2 - 1 downto 2;

constant widthHm1: natural := widthH12 + widthm1;
constant widthDSPHm1A: natural := widthH12 + 1;
constant widthDSPHm1B: natural := widthm1 + 1;
constant widthDSPHm1P: natural := widthDSPHm1A + widthDSPHm1B;
type t_dspHm1 is
record
  A0: std_logic_vector( widthDSPHm1A - 1 downto 0 ); -- H11
  A : std_logic_vector( widthDSPHm1A - 1 downto 0 ); -- H11
  B0: std_logic_vector( widthDSPHm1B - 1 downto 0 ); -- m1
  B : std_logic_vector( widthDSPHm1B - 1 downto 0 ); -- m1
  P : std_logic_vector( widthDSPHm1P - 1 downto 0 ); -- m1 * H11
end record;
subtype r_Hm1 is natural range widthHm1 + 2 - 1 downto 2;

constant widthDSPHv0A: natural := 1 + widthv0 + 1;
constant widthDSPHv0B: natural := widthH00 + 1;
constant widthDSPHv0P: natural := widthDSPHv0A + widthDSPHv0B;
constant widthHv0: natural := dspWidthA;
constant baseDiffHv0: integer := -1 + widthDSPHv0P - 2 - widthHv0;
type t_dspHv0 is
record
  A : std_logic_vector( widthDSPHv0A - 1 downto 0 ); -- v0
  B0: std_logic_vector( widthDSPHv0B - 1 downto 0 ); -- H00
  B : std_logic_vector( widthDSPHv0B - 1 downto 0 ); -- H00
  P : std_logic_vector( widthDSPHv0P - 1 downto 0 ); -- v0 * H00
end record;
subtype r_Hv0 is natural range widthHv0 + baseDiffHv0 + 2 - 1 downto baseDiffHv0 + 2;

constant widthDSPHv1A: natural := 1 + widthv1 + 1;
constant widthDSPHv1B: natural := widthH12 + 1;
constant widthDSPHv1P: natural := widthDSPHv1A + widthDSPHv1B;
constant widthHv1: natural := dspWidthA;
constant baseDiffHv1: integer := -1 + widthDSPHv1P - 2 - widthHv1;
type t_dspHv1 is
record
  A : std_logic_vector( widthDSPHv1A - 1 downto 0 ); -- v1
  B0: std_logic_vector( widthDSPHv1B - 1 downto 0 ); -- H11
  B : std_logic_vector( widthDSPHv1B - 1 downto 0 ); -- H11
  P : std_logic_vector( widthDSPHv1P - 1 downto 0 ); -- v1 * H11
end record;
subtype r_Hv1 is natural range widthHv1 + baseDiffHv1 + 2 - 1 downto baseDiffHv1 + 2;

constant widthDSPH2v0A: natural := 1 + widthH00 + widthH00 + 1;
constant widthDSPH2v0B: natural := 1 + widthv0 + 1;
constant widthDSPH2v0P: natural := widthDSPH2v0A + widthDSPH2v0B;
constant widthH2v0: natural := dspWidthAu;
constant baseDiffH2v0: integer := -2 + widthDSPH2v0P - 2 - widthH2v0;
type t_dspH2v0 is
record
  A : std_logic_vector( widthDSPH2v0A - 1 downto 0 ); -- H00 * H00
  B0: std_logic_vector( widthDSPH2v0B - 1 downto 0 ); -- v0
  B : std_logic_vector( widthDSPH2v0B - 1 downto 0 ); -- v0
  P : std_logic_vector( widthDSPH2v0P - 1 downto 0 ); -- v0 * H00 * H00
end record;
subtype r_H2v0 is natural range widthH2v0 + baseDiffH2v0 + 2 - 1 downto baseDiffH2v0 + 2;

constant widthDSPH2v1A: natural := 1 + widthH12 + widthH12 + 1;
constant widthDSPH2v1B: natural := 1 + widthv1 + 1;
constant widthDSPH2v1P: natural := widthDSPH2v1A + widthDSPH2v1B;
constant widthH2v1: natural := dspWidthAu;
constant baseDiffH2v1: integer := -2 + widthDSPH2v1P - 2 - widthH2v1;
type t_dspH2v1 is
record
  A : std_logic_vector( widthDSPH2v1A - 1 downto 0 ); -- H11 * H11
  B0: std_logic_vector( widthDSPH2v1B - 1 downto 0 ); -- v1
  B : std_logic_vector( widthDSPH2v1B - 1 downto 0 ); -- v1
  P : std_logic_vector( widthDSPH2v1P - 1 downto 0 ); -- v1 * H11 * H11
end record;
subtype r_H2v1 is natural range widthH2v1 + baseDiffH2v1 + 2 - 1 downto baseDiffH2v1 + 2;

constant baseDiffDspX0: integer := ilog2( baseX0 / ( baseM0 * baseInvDH ) );
constant widthDSPx0A: natural := widthm0 + 1;
constant widthDSPx0B: natural := 1 + widthInvDH + 1;
constant widthDSPx0D: natural := widthm0 + 1;
constant widthDSPx0AD: natural := max( widthDSPx0A, widthDSPx0D ) + 1;
constant widthDSPx0M: natural := widthDSPx0AD + widthDSPx0B;
constant widthDSPx0P: natural := widthDSPx0M;
type t_dspX0 is
record
  A0: std_logic_vector( widthDSPx0A  - 1 downto 0 ); -- m0
  A : std_logic_vector( widthDSPx0A  - 1 downto 0 ); -- m0
  B : std_logic_vector( widthDSPx0B  - 1 downto 0 ); -- invDH
  D : std_logic_vector( widthDSPx0D  - 1 downto 0 ); -- m0
  AD: std_logic_vector( widthDSPx0AD - 1 downto 0 ); -- Dm0
  M : std_logic_vector( widthDSPx0M  - 1 downto 0 ); -- Dm0 / DH
  P : std_logic_vector( widthDSPx0P  - 1 downto 0 ); -- Dm0 / DH
end record;
subtype r_x0 is natural range widthX0 + baseDiffDspX0 + 2 - 1 downto baseDiffDspX0 + 2;
subtype o_x0 is natural range widthDSPx0P - 1 downto widthX0 + baseDiffDspX0 + 2 - 1;

constant baseDiffDspX2: integer := ilog2( baseX2 / ( basem1 * baseInvDH ) );
constant widthDSPx2A: natural := widthm1 + 1;
constant widthDSPx2B: natural := 1 + widthInvDH + 1;
constant widthDSPx2D: natural := widthm1 + 1;
constant widthDSPx2AD: natural := max( widthDSPx2A, widthDSPx2D ) + 1;
constant widthDSPx2M: natural := widthDSPx2AD + widthDSPx2B;
constant widthDSPx2P: natural := widthDSPx2M;
type t_dspX2 is
record
  A0: std_logic_vector( widthDSPx2A  - 1 downto 0 ); -- m1
  A : std_logic_vector( widthDSPx2A  - 1 downto 0 ); -- m1
  B : std_logic_vector( widthDSPx2B  - 1 downto 0 ); -- invDH
  D : std_logic_vector( widthDSPx2D  - 1 downto 0 ); -- m1
  AD: std_logic_vector( widthDSPx2AD - 1 downto 0 ); -- Dm1
  M : std_logic_vector( widthDSPx2M  - 1 downto 0 ); -- Dm1 / DH
  P : std_logic_vector( widthDSPx2P  - 1 downto 0 ); -- Dm1 / DH
end record;
subtype r_x2 is natural range widthX2 + baseDiffDspX2 + 2 - 1 downto baseDiffDspX2 + 2;
subtype o_x2 is natural range widthDSPx2P - 1 downto widthX2 + baseDiffDspX2 + 2 - 1;

constant baseDiffDspX1: integer := ilog2( baseX1 / ( baseH00 * baseM0 * baseInvDH ) );
constant widthDSPx1A: natural := widthH00 + widthm0 + 1;
constant widthDSPx1B: natural := 1 + widthInvDH + 1;
constant widthDSPx1D: natural := widthH00 + widthm0 + 1;
constant widthDSPx1M: natural := max( widthDSPx1A, widthDSPx1D ) + 1 + widthDSPx1B;
constant widthDSPx1P: natural := widthDSPx1M;
type t_dspX1 is
record
  A : std_logic_vector( widthDSPx1A - 1 downto 0 ); -- m0 * H00
  B0: std_logic_vector( widthDSPx1B - 1 downto 0 ); -- invDH
  B : std_logic_vector( widthDSPx1B - 1 downto 0 ); -- invDH
  D : std_logic_vector( widthDSPx1D - 1 downto 0 ); -- m0 * H00
  M : std_logic_vector( widthDSPx1M - 1 downto 0 ); -- DmH0 / DH
  P : std_logic_vector( widthDSPx1P - 1 downto 0 ); -- DmH0 / DH
end record;
subtype r_x1 is natural range widthX1 + baseDiffDspX1 + 2 - 1 downto baseDiffDspX1 + 2;
subtype o_x1 is natural range widthDSPx1P - 1 downto widthX1 + baseDiffDspX1 + 2 - 1;

constant baseDiffDspX3: integer := ilog2( basex3 / ( baseH12 * basem1 * baseInvDH ) );
constant widthDSPx3A: natural := widthH12 + widthm1 + 1;
constant widthDSPx3B: natural := 1 + widthInvDH + 1;
constant widthDSPx3D: natural := widthH12 + widthm1 + 1;
constant widthDSPx3M: natural := max( widthDSPx3A, widthDSPx3D ) + 1 + widthDSPx3B;
constant widthDSPx3P: natural := widthDSPx3M;
type t_dspX3 is
record
  A : std_logic_vector( widthDSPx3A - 1 downto 0 ); -- m1 * H11
  B0: std_logic_vector( widthDSPx3B - 1 downto 0 ); -- invDH
  B : std_logic_vector( widthDSPx3B - 1 downto 0 ); -- invDH
  D : std_logic_vector( widthDSPx3D - 1 downto 0 ); -- m1 * H11
  M : std_logic_vector( widthDSPx3M - 1 downto 0 ); -- DmH1 / DH
  P : std_logic_vector( widthDSPx3P - 1 downto 0 ); -- DmH1 / DH
end record;
subtype r_x3 is natural range widthX3 + baseDiffDspX3 + 2 - 1 downto baseDiffDspX3 + 2;
subtype o_x3 is natural range widthDSPx3P - 1 downto widthX3 + baseDiffDspX3 + 2 - 1;

constant baseDiffDspC00: integer := ilog2( baseC00 / ( basev0 * baseInvDH2 ) );
constant widthDSPC00A: natural := 1 + widthV0 + 1;
constant widthDSPC00B: natural := 1 + widthInvDH2 + 1;
constant widthDSPC00D: natural := 1 + widthV0 + 1;
constant widthDSPC00AD: natural := max( widthDSPC00A, widthDSPC00D ) + 1;
constant widthDSPC00M: natural := widthDSPC00AD + widthDSPC00B;
constant widthDSPC00P: natural := widthDSPC00M;
type t_dspC00 is
record
  A : std_logic_vector( widthDSPC00A  - 1 downto 0 ); -- v0
  B : std_logic_vector( widthDSPC00B  - 1 downto 0 ); -- invDH2
  D : std_logic_vector( widthDSPC00D  - 1 downto 0 ); -- v0
  AD: std_logic_vector( widthDSPC00AD - 1 downto 0 ); -- Sv0
  M : std_logic_vector( widthDSPC00M  - 1 downto 0 ); -- Sv0 / H2
  P : std_logic_vector( widthDSPC00P  - 1 downto 0 ); -- Sv0 / H2
end record;
subtype r_C00 is natural range widthC00 + baseDiffDspC00 + 2 - 1 downto baseDiffDspC00 + 2;

constant baseDiffDspC22: integer := ilog2( baseC22 / ( basev1 * baseInvDH2 ) );
constant widthDSPC22A: natural := 1 + widthv1 + 1;
constant widthDSPC22B: natural := 1 + widthInvDH2 + 1;
constant widthDSPC22D: natural := 1 + widthv1 + 1;
constant widthDSPC22AD: natural := max( widthDSPC22A, widthDSPC22D ) + 1;
constant widthDSPC22M: natural := widthDSPC22AD + widthDSPC22B;
constant widthDSPC22P: natural := widthDSPC22M;
type t_dspC22 is
record
  A : std_logic_vector( widthDSPC22A  - 1 downto 0 ); -- v1
  B : std_logic_vector( widthDSPC22B  - 1 downto 0 ); -- invDH2
  D : std_logic_vector( widthDSPC22D  - 1 downto 0 ); -- v1
  AD: std_logic_vector( widthDSPC22AD - 1 downto 0 ); -- Sv1
  M : std_logic_vector( widthDSPC22M  - 1 downto 0 ); -- Sv1 / H2
  P : std_logic_vector( widthDSPC22P  - 1 downto 0 ); -- Sv1 / H2
end record;
subtype r_C22 is natural range widthC22 + baseDiffDspC22 + 2 - 1 downto baseDiffDspC22 + 2;

constant baseDiffDspC01: integer := ilog2( baseC01 / ( baseH00 * baseV0 * baseInvDH2 ) ) - baseDiffHv0;
constant widthDSPC01A: natural := widthHv0 + 1;
constant widthDSPC01B: natural := 1 + widthInvDH2 + 1;
constant widthDSPC01D: natural := widthHv0 + 1;
constant widthDSPC01P: natural := max( widthDSPC01A, widthDSPC01D ) + 1 + widthDSPC01B;
type t_dspC01 is
record
  A : std_logic_vector( widthDSPC01A - 1 downto 0 ); -- v0 * H00
  B0: std_logic_vector( widthDSPC01B - 1 downto 0 ); -- invDH2
  B : std_logic_vector( widthDSPC01B - 1 downto 0 ); -- invDH2
  D : std_logic_vector( widthDSPC01D - 1 downto 0 ); -- v0 * H00
  P : std_logic_vector( widthDSPC01P - 1 downto 0 ); -- SvH0 / H2
end record;
subtype r_C01 is natural range widthC01 + baseDiffDspC01 + 2 - 1 downto baseDiffDspC01 + 2;

constant baseDiffDspC23: integer := ilog2( baseC23 / ( baseH12 * basev1 * baseInvDH2 ) ) - baseDiffHv1;
constant widthDSPC23A: natural := widthHv1 + 1;
constant widthDSPC23B: natural := 1 + widthInvDH2 + 1;
constant widthDSPC23D: natural := widthHv1 + 1;
constant widthDSPC23P: natural := max( widthDSPC23A, widthDSPC23D ) + 1 + widthDSPC23B;
type t_dspC23 is
record
  A : std_logic_vector( widthDSPC23A - 1 downto 0 ); -- v1 * H11
  B0: std_logic_vector( widthDSPC23B - 1 downto 0 ); -- invDH2
  B : std_logic_vector( widthDSPC23B - 1 downto 0 ); -- invDH2
  D : std_logic_vector( widthDSPC23D - 1 downto 0 ); -- v1 * H11
  P : std_logic_vector( widthDSPC23P - 1 downto 0 ); -- SvH1 / H2
end record;
subtype r_C23 is natural range widthC23 + baseDiffDspC23 + 2 - 1 downto baseDiffDspC23 + 2;

constant baseDiffDspC11: integer := ilog2( baseC11 / ( baseH00 * baseH00 * baseV0 * baseInvDH2 ) ) - baseDiffH2v0;
constant widthDSPC11A: natural := 1 + widthH2v0 + 1;
constant widthDSPC11B: natural := 1 + widthInvDH2 + 1;
constant widthDSPC11D: natural := 1 + widthH2v0 + 1;
constant widthDSPC11P: natural := max( widthDSPC11A, widthDSPC11D ) + 1 + widthDSPC11B;
type t_dspC11 is
record
  A: std_logic_vector( widthDSPC11A - 1 downto 0 ); -- v0 * H00 * H00
  B0: std_logic_vector( widthDSPC11B - 1 downto 0 ); -- invDH2
  B: std_logic_vector( widthDSPC11B - 1 downto 0 ); -- invDH2
  D: std_logic_vector( widthDSPC11D - 1 downto 0 ); -- v0 * H00 * H00
  P: std_logic_vector( widthDSPC11P - 1 downto 0 ); -- SvH20 / H2
end record;
subtype r_C11 is natural range widthC11 + baseDiffDspC11 + 2 - 1 downto baseDiffDspC11 + 2;

constant baseDiffDspC33: integer := ilog2( baseC33 / ( baseH12 * baseH12 * baseV1 * baseInvDH2 ) ) - baseDiffH2v1;
constant widthDSPC33A: natural := 1 + widthH2v1 + 1;
constant widthDSPC33B: natural := 1 + widthInvDH2 + 1;
constant widthDSPC33D: natural := 1 + widthH2v1 + 1;
constant widthDSPC33P: natural := max( widthDSPC33A, widthDSPC33D ) + 1 + widthDSPC33B;
type t_dspC33 is
record
  A: std_logic_vector( widthDSPC33A - 1 downto 0 ); -- v1 * H11 * H11
  B0: std_logic_vector( widthDSPC33B - 1 downto 0 ); -- invDH2
  B: std_logic_vector( widthDSPC33B - 1 downto 0 ); -- invDH2
  D: std_logic_vector( widthDSPC33D - 1 downto 0 ); -- v1 * H11 * H11
  P: std_logic_vector( widthDSPC33P - 1 downto 0 ); -- SvH21 / H2
end record;
subtype r_C33 is natural range widthC33 + baseDiffDspC33 + 2 - 1 downto baseDiffDspC33 + 2;


end; 



package body kf_state_pkg is


function init_invDHs return t_invDHs is
  variable invDHs: t_invDHs := ( others => ( others => '0' ) );
  variable dH: real;
begin
  for k in invDHs'range loop
    dH := ( real( k ) + 0.5 ) * baseDH;
    if dH > kfMinSeedDeltaR then
      invDHs( k ) := stdu( 1.0 / dH, baseInvDH, widthInvDH );
    end if;
  end loop;
  return invDHs;
end function;

function init_invDH2s return t_invDH2s is
  variable invDH2s: t_invDH2s := ( others => ( others => '0' ) );
  variable dH: real;
begin
  for k in invDH2s'range loop
    dH := ( real( k ) + 0.5 ) * baseDH;
    if dH > kfMinSeedDeltaR then
      invDH2s( k ) := stdu( 1.0 / dH / dH, baseInvDH2, widthInvDH2 );
    end if;
  end loop;
  return invDH2s;
end function;

function init_v0s return t_v0s is
  variable v0s: t_v0s := ( others => ( others => '0' ) );
  variable d0, v0: real;
begin 
  for k in v0s'range loop
    d0 := 2.0  * ( real( k ) + 0.5 ) * based0;
    v0 := d0 ** 2;
    if v0 / basev0 < 2.0 ** widthv0 then
        v0s( k ) := stdu( v0, basev0, widthv0 );
    end if;
  end loop;
  return v0s;
end function;

function init_v1s return t_v1s is
  variable v1s: t_v1s := ( others => ( others => '0' ) );
  variable d1, v1: real;
begin 
  for k in v1s'range loop
    d1 := 2.0 * ( real( k ) + 0.5 ) * based1;
    v1 := d1 ** 2;
    if v1 / basev1 < 2.0 ** widthv1 then
        v1s( k ) := stdu( v1, basev1, widthv1 );
    end if;
  end loop;
  return v1s;
end function;


end;