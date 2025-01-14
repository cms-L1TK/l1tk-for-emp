library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.hybrid_data_formats.all;
use work.kf_data_formats.all;
use work.kf_data_types.all;


package kf_update_pkg is


constant limitX0: integer := digi( 1.5 * baseTMinv2R / 2.0, baseX0 );
constant limitX1: integer := digi( 1.5 * baseTMphiT  / 2.0, baseX1 );
constant limitX2: integer := digi( 1.5 * baseTMcot   / 2.0, baseX2 );
constant limitX3: integer := digi( 1.5 * baseTMzT    / 2.0, baseX3 );

type t_ramv0 is array ( 0 to 2 ** bram18WidthAddr - 1 ) of std_logic_vector( widthv0 - 1 downto 0 );
type t_ramv1 is array ( 0 to 2 ** bram18WidthAddr - 1 ) of std_logic_vector( widthv1 - 1 downto 0 );
function init_ramv0 return t_ramv0;
function init_ramv1 return t_ramv1;

constant shiftDspS00 : integer := baseShiftH00 + baseShiftC00;
constant widthDspS00A: natural := 1 + widthC00 + 1;
constant widthDspS00B: natural :=     widthH00 + 1;
constant widthDspS00C: natural :=     widthC01 + 2 + baseShiftC01 - shiftDspS00;
constant widthDspS00P: natural := max( widthDspS00A + widthDspS00B, widthDspS00C ) + 1;
type t_dspS00 is
record
  A: std_logic_vector( widthDspS00A - 1 downto 0 ); -- C00
  B: std_logic_vector( widthDspS00B - 1 downto 0 ); -- H00
  C: std_logic_vector( widthDspS00C - 1 downto 0 ); -- C01
  P: std_logic_vector( widthDspS00P - 1 downto 0 ); -- H00 * C00 + C01
end record;
subtype r_S00 is natural range widthS00 + baseShiftS00 - shiftDspS00 + 2 - 1 downto baseShiftS00 - shiftDspS00 + 2;

constant shiftDspS01 : integer := baseShiftH00 + baseShiftC01;
constant widthDspS01A: natural :=     widthC01 + 1;
constant widthDspS01B: natural :=     widthH00 + 1;
constant widthDspS01C: natural := 1 + widthC11 + 2 + baseShiftC11 - shiftDspS01;
constant widthDspS01P: natural := max( widthDspS01A + widthDspS01B, widthDspS01C ) + 1;
type t_dspS01 is
record
  A: std_logic_vector( widthDspS01A - 1 downto 0 ); -- C01
  B: std_logic_vector( widthDspS01B - 1 downto 0 ); -- H00
  C: std_logic_vector( widthDspS01C - 1 downto 0 ); -- C11
  P: std_logic_vector( widthDspS01P - 1 downto 0 ); -- H00 * C01 + C11
end record;
subtype r_S01 is natural range widthS01 + baseShiftS01 - shiftDspS01 + 2 - 1 downto baseShiftS01 - shiftDspS01 + 2;

constant shiftDspS12 : integer := baseShiftH12 + baseShiftC22;
constant widthDspS12A: natural := 1 + widthC22 + 1;
constant widthDspS12B: natural :=     widthH12 + 1;
constant widthDspS12C: natural :=     widthC23 + 2 + baseShiftC23 - shiftDspS12;
constant widthDspS12P: natural := max( widthDspS12A + widthDspS12B, widthDspS12C ) + 1;
type t_dspS12 is
record
  A: std_logic_vector( widthDspS12A - 1 downto 0 ); -- C22
  B: std_logic_vector( widthDspS12B - 1 downto 0 ); -- H12
  C: std_logic_vector( widthDspS12C - 1 downto 0 ); -- C23
  P: std_logic_vector( widthDspS12P - 1 downto 0 ); -- H12 * C22 + C23
end record;
subtype r_S12 is natural range widthS12 + baseShiftS12 - shiftDspS12 + 2 - 1 downto baseShiftS12 - shiftDspS12 + 2;

constant shiftDspS13 : integer := baseShiftH12 + baseShiftC23;
constant widthDspS13A: natural :=     widthC23 + 1;
constant widthDspS13B: natural :=     widthH12 + 1;
constant widthDspS13C: natural := 1 + widthC33 + 2 + baseShiftC33 - shiftDspS13;
constant widthDspS13P: natural := max( widthDspS13A + widthDspS13B, widthDspS13C ) + 1;
type t_dspS13 is
record
  A: std_logic_vector( widthDspS13A - 1 downto 0 ); -- C23
  B: std_logic_vector( widthDspS13B - 1 downto 0 ); -- H12
  C: std_logic_vector( widthDspS13C - 1 downto 0 ); -- C33
  P: std_logic_vector( widthDspS13P - 1 downto 0 ); -- H00 * C23 + C33
end record;
subtype r_S13 is natural range widthS13 + baseShiftS13 - shiftDspS13 + 2 - 1 downto baseShiftS13 - shiftDspS13 + 2;

type t_S00s is array ( natural range <> ) of std_logic_vector( widthS00 - 1 downto 0 );
type t_S01s is array ( natural range <> ) of std_logic_vector( widthS01 - 1 downto 0 );
type t_S12s is array ( natural range <> ) of std_logic_vector( widthS12 - 1 downto 0 );
type t_S13s is array ( natural range <> ) of std_logic_vector( widthS13 - 1 downto 0 );

constant widthSumR00A: natural :=     widthS01 + 1;
constant widthSumR00B: natural := 1 + widthv0  + 1;
constant widthSumR00C: natural := max( widthSumR00A, widthSumR00B ) + 1;
type t_sumR00 is
record
  A: std_logic_vector( widthSumR00A - 1 downto 0 ); -- S01
  B: std_logic_vector( widthSumR00B - 1 downto 0 ); -- v0
  C: std_logic_vector( widthSumR00C - 1 downto 0 ); -- S01 + v0
end record;
subtype r_R00C is natural range widthSumR00C - 1 downto 1;

constant shiftDspR00 : integer := baseShiftH00 + baseShiftS00;
constant widthDspR00A: natural := widthS00 + 1;
constant widthDspR00B: natural := widthH00 + 1;
constant widthDspR00C: natural := widthSumR00C + 1 + baseShiftS01 - shiftDspR00;
constant widthDspR00P: natural := max( widthDspR00A + widthDspR00B, widthDspR00C ) + 1;
type t_dspR00 is
record
  A : std_logic_vector( widthDspR00A - 1 downto 0 ); -- S00
  B0: std_logic_vector( widthDspR00B - 1 downto 0 ); -- H00
  B : std_logic_vector( widthDspR00B - 1 downto 0 ); -- H00
  C : std_logic_vector( widthDspR00C - 1 downto 0 ); -- S01 + v0
  P : std_logic_vector( widthDspR00P - 1 downto 0 ); -- H00 * S00 + S01 + v0
end record;
subtype r_R00 is natural range widthR00 + baseShiftR00 - shiftDspR00 + 2 - 1 downto baseShiftR00 - shiftDspR00 + 2;

constant widthSumR11A: natural :=     widthS13 + 1;
constant widthSumR11B: natural := 1 + widthv1  + 1;
constant widthSumR11C: natural := max( widthSumR11A, widthSumR11B ) + 1;
type t_sumR11 is
record
  A: std_logic_vector( widthSumR11A - 1 downto 0 ); -- S13
  B: std_logic_vector( widthSumR11B - 1 downto 0 ); -- v1
  C: std_logic_vector( widthSumR11C - 1 downto 0 ); -- S13 + v1
end record;
subtype r_R11C is natural range widthSumR11C - 1 downto 1;

constant shiftDspR11  : integer := baseShiftH12 + baseShiftS12;
constant widthDspR11A : natural := widthS12 + 1;
constant widthDspR11B : natural := widthH12 + 1;
constant widthDspR11C : natural := widthSumR11C + 1 + baseShiftS13 - shiftDspR11;
constant widthDspR11P : natural := max( widthDspR11A + widthDspR11B, widthDspR11C ) + 1;
type t_dspR11 is
record
  A : std_logic_vector( widthDspR11A - 1 downto 0 ); -- S12
  B0: std_logic_vector( widthDspR11B - 1 downto 0 ); -- H12
  B : std_logic_vector( widthDspR11B - 1 downto 0 ); -- H12
  C : std_logic_vector( widthDspR11C - 1 downto 0 ); -- S13 + v1
  P : std_logic_vector( widthDspR11P - 1 downto 0 ); -- H12 * S12 + S13 + v1
end record;
subtype r_R11 is natural range widthR11 + baseShiftR11 - shiftDspR11 + 2 - 1 downto baseShiftR11 - shiftDspR11 + 2;

constant widthShift0: natural := width( widthR00 ) + 1;
constant widthShift1: natural := width( widthR11 ) + 1;
type t_shift0 is array ( natural range <> ) of std_logic_vector( widthShift0 - 1 downto 0 );
type t_shift1 is array ( natural range <> ) of std_logic_vector( widthShift1 - 1 downto 0 );

constant lsbS00Shifted: natural := baseShiftS00Shifted - baseShiftS00;
constant lsbS01Shifted: natural := baseShiftS01Shifted - baseShiftS01;
constant lsbS12Shifted: natural := baseShiftS12Shifted - baseShiftS12;
constant lsbS13Shifted: natural := baseShiftS13Shifted - baseShiftS13;

constant widthInvR00Cor2: natural := widthInvR00Approx + widthR00 + 1 + 2;
constant invR00Cor2: std_logic_vector( widthInvR00Cor2 - 1 downto 0 ) := stdu( 2.0, baseInvR00Approx * baseR00 / 4.0, widthInvR00Cor2 );

constant shiftDspInvR00Cor : integer := baseShiftInvR00Approx + baseShiftR00;
constant widthDspInvR00CorA: natural := 1 + widthR00          + 1;
constant widthDspInvR00CorB: natural := 1 + widthInvR00Approx + 1;
constant widthDspInvR00CorC: natural := 1 + widthInvR00Cor2   + 0;
constant widthDspInvR00CorP: natural := max( widthDspInvR00CorA + widthDspInvR00CorB, widthDspInvR00CorC ) + 1;
type t_dspInvR00Cor is
record
  A0: std_logic_vector( widthDspInvR00CorA - 1 downto 0 ); -- R00
  A : std_logic_vector( widthDspInvR00CorA - 1 downto 0 ); -- R00
  B : std_logic_vector( widthDspInvR00CorB - 1 downto 0 ); -- invR00Approx
  C : std_logic_vector( widthDspInvR00CorC - 1 downto 0 ); -- invR00Cor2
  P : std_logic_vector( widthDspInvR00CorP - 1 downto 0 ); -- invR00Approx * R00 + invR00Cor2
end record;
subtype r_invR00Cor is natural range widthInvR00Cor + baseShiftInvR00Cor - shiftDspInvR00Cor + 2 - 1 downto baseShiftInvR00Cor - shiftDspInvR00Cor + 2;

constant widthInvR11Cor2: natural := widthInvR11Approx + widthR11 + 1 + 2;
constant invR11Cor2: std_logic_vector( widthInvR00Cor2 - 1 downto 0 ) := stdu( 2.0, baseInvR11Approx * baseR11 / 4.0, widthInvR11Cor2 );

constant shiftDspInvR11Cor : integer := baseShiftInvR11Approx + baseShiftR11;
constant widthDspInvR11CorA: natural := 1 + widthR11          + 1;
constant widthDspInvR11CorB: natural := 1 + widthInvR11Approx + 1;
constant widthDspInvR11CorC: natural := 1 + widthInvR11Cor2   + 0;
constant widthDspInvR11CorP: natural := max( widthDspInvR00CorA + widthDspInvR00CorB, widthDspInvR00CorC ) + 1;
type t_dspInvR11Cor is
record
  A0: std_logic_vector( widthDspInvR11CorA - 1 downto 0 ); -- R11
  A : std_logic_vector( widthDspInvR11CorA - 1 downto 0 ); -- R11
  B : std_logic_vector( widthDspInvR11CorB - 1 downto 0 ); -- invR11Approx
  C : std_logic_vector( widthDspInvR11CorC - 1 downto 0 ); -- invR11Cor2
  P : std_logic_vector( widthDspInvR11CorP - 1 downto 0 ); -- invR11Approx * R11 + invR11Cor2
end record;
subtype r_invR11Cor is natural range widthInvR00Cor + baseShiftInvR11Cor - shiftDspInvR11Cor + 2 - 1 downto baseShiftInvR11Cor - shiftDspInvR11Cor + 2;

constant shiftDspInvR00 : integer := baseShiftInvR00Approx + baseShiftInvR00Cor;
constant widthDspInvR00A: natural := 1 + widthInvR00Cor    + 1;
constant widthDspInvR00B: natural := 1 + widthInvR00Approx + 1;
constant widthDspInvR00P: natural := widthDspInvR00A + widthDspInvR00B;
type t_dspInvR00 is
record
  A : std_logic_vector( widthDspInvR00A - 1 downto 0 ); -- invR00Cor
  B0: std_logic_vector( widthDspInvR00B - 1 downto 0 ); -- invR00Approx
  B : std_logic_vector( widthDspInvR00B - 1 downto 0 ); -- invR00Approx
  P : std_logic_vector( widthDspInvR00P - 1 downto 0 ); -- invR00Approx * widthInvR00Cor
end record;
subtype r_invR00 is natural range widthInvR00 + baseShiftInvR00 - shiftDspInvR00 + 2 - 1 downto baseShiftInvR00 - shiftDspInvR00 + 2;

constant shiftDspInvR11 : integer := baseShiftInvR11Approx + baseShiftInvR11Cor;
constant widthDspInvR11A: natural := 1 + widthInvR11Cor    + 1;
constant widthDspInvR11B: natural := 1 + widthInvR11Approx + 1;
constant widthDspInvR11P: natural := widthDspInvR11A + widthDspInvR11B;
type t_dspInvR11 is
record
  A : std_logic_vector( widthDspInvR11A - 1 downto 0 ); -- invR11Cor
  B0: std_logic_vector( widthDspInvR11B - 1 downto 0 ); -- invR11Approx
  B : std_logic_vector( widthDspInvR11B - 1 downto 0 ); -- invR11Approx
  P : std_logic_vector( widthDspInvR11P - 1 downto 0 ); -- invR11Approx * widthInvR11Cor
end record;
subtype r_invR11 is natural range widthInvR11 + baseShiftInvR11 - shiftDspInvR11 + 2 - 1 downto baseShiftInvR11 - shiftDspInvR11 + 2;

constant shiftDspK00 : integer := baseShiftS00Shifted + baseShiftInvR00;
constant widthDspK00A: natural :=     widthS00Shifted    + 1;
constant widthDspK00B: natural := 1 + widthInvR00        + 1;
constant widthDspK00P: natural := widthDspK00A + widthDspK00B;
type t_dspK00 is
record
  A0: std_logic_vector( widthDspK00A - 1 downto 0 ); -- S00Shifted
  A : std_logic_vector( widthDspK00A - 1 downto 0 ); -- S00Shifted
  B : std_logic_vector( widthDspK00B - 1 downto 0 ); -- InvR00
  P : std_logic_vector( widthDspK00P - 1 downto 0 ); -- InvR00 * S00Shifted
end record;
subtype r_K00 is natural range widthK00 + baseShiftK00 - shiftDspK00 + 2 - 1 downto baseShiftK00 - shiftDspK00 + 2;

constant shiftDspK10 : integer := baseShiftS01Shifted + baseShiftInvR00;
constant widthDspK10A: natural :=     widthS01Shifted + 1;
constant widthDspK10B: natural := 1 + widthInvR00     + 1;
constant widthDspK10P: natural := widthDspK10A + widthDspK10B;
type t_dspK10 is
record
  A0: std_logic_vector( widthDspK10A - 1 downto 0 ); -- S01Shifted
  A : std_logic_vector( widthDspK10A - 1 downto 0 ); -- S01Shifted
  B : std_logic_vector( widthDspK10B - 1 downto 0 ); -- InvR00
  P : std_logic_vector( widthDspK10P - 1 downto 0 ); -- InvR00 * S01Shifted
end record;
subtype r_K10 is natural range widthK10 + baseShiftK10 - shiftDspK10 + 2 - 1 downto baseShiftK10 - shiftDspK10 + 2;

constant shiftDspK21 : integer := baseShiftS12Shifted + baseShiftInvR11;
constant widthDspK21A: natural :=     widthS12Shifted + 1;
constant widthDspK21B: natural := 1 + widthInvR11     + 1;
constant widthDspK21P: natural := widthDspK10A + widthDspK10B;
type t_dspK21 is
record
  A0: std_logic_vector( widthDspK21A - 1 downto 0 ); -- S12Shifted
  A : std_logic_vector( widthDspK21A - 1 downto 0 ); -- S12Shifted
  B : std_logic_vector( widthDspK21B - 1 downto 0 ); -- InvR11
  P : std_logic_vector( widthDspK21P - 1 downto 0 ); -- InvR11 * S12Shifted
end record;
subtype r_K21 is natural range widthK21 + baseShiftK21 - shiftDspK21 + 2 - 1 downto baseShiftK21 - shiftDspK21 + 2;

constant shiftDspK31 : integer := baseShiftS13Shifted + baseShiftInvR11;
constant widthDspK31A: natural :=     widthS13Shifted + 1;
constant widthDspK31B: natural := 1 + widthInvR11     + 1;
constant widthDspK31P: natural := widthDspK10A + widthDspK10B;
type t_dspK31 is
record
  A0: std_logic_vector( widthDspK31A - 1 downto 0 ); -- S13Shifted
  A : std_logic_vector( widthDspK31A - 1 downto 0 ); -- S13Shifted
  B : std_logic_vector( widthDspK31B - 1 downto 0 ); -- InvR11
  P : std_logic_vector( widthDspK31P - 1 downto 0 ); -- InvR11 * S13Shifted
end record;
subtype r_K31 is natural range widthK31 + baseShiftK31 - shiftDspK31 + 2 - 1 downto baseShiftK31 - shiftDspK31 + 2;

constant shiftDspX0 : integer := baseShiftK00 + baseShiftr0;
constant widthDspX0A: natural := widthr0 + 1;
constant widthDspX0B: natural := widthK00 + 1;
constant widthDspX0C: natural := widthx0 + 2 + baseShiftx0 - shiftDspX0;
constant widthDspX0P: natural := max( widthDspX0A + widthDspX0B, widthDspX0C ) + 1;
type t_dspX0 is
record
  A0: std_logic_vector( widthDspX0A - 1 downto 0 ); -- r0
  A : std_logic_vector( widthDspX0A - 1 downto 0 ); -- r0
  B : std_logic_vector( widthDspX0B - 1 downto 0 ); -- K00
  C : std_logic_vector( widthDspX0C - 1 downto 0 ); -- x0
  P : std_logic_vector( widthDspX0P - 1 downto 0 ); -- x0 + r0 * K00
end record;
subtype r_x0 is natural range widthx0 + baseShiftx0 - shiftDspX0 + 2 - 1 downto baseShiftx0 - shiftDspX0 + 2;
subtype r_x0over is natural range widthDspX0P - 1 downto r_x0'high;

constant shiftDspX1 : integer := baseShiftK10 + baseShiftr0;
constant widthDspX1A: natural := widthr0 + 1;
constant widthDspX1B: natural := widthK10 + 1;
constant widthDspX1C: natural := widthx1 + 2 + baseShiftx1 - shiftDspX1;
constant widthDspX1P: natural := max( widthDspX1A + widthDspX1B, widthDspX1C ) + 1;
type t_dspX1 is
record
  A0: std_logic_vector( widthDspX1A - 1 downto 0 ); -- r0
  A : std_logic_vector( widthDspX1A - 1 downto 0 ); -- r0
  B : std_logic_vector( widthDspX1B - 1 downto 0 ); -- K10
  C : std_logic_vector( widthDspX1C - 1 downto 0 ); -- x1
  P : std_logic_vector( widthDspX1P - 1 downto 0 ); -- x1 + r0 * K10
end record;
subtype r_x1 is natural range widthx1 + baseShiftx1 - shiftDspX1 + 2 - 1 downto baseShiftx1 - shiftDspX1 + 2;
subtype r_x1over is natural range widthDspX1P - 1 downto r_x1'high;

constant shiftDspX2 : integer := baseShiftK21 + baseShiftr1;
constant widthDspX2A: natural := widthr1 + 1;
constant widthDspX2B: natural := widthK21 + 1;
constant widthDspX2C: natural := widthx2 + 2 + baseShiftx2 - shiftDspX2;
constant widthDspX2P: natural := max( widthDspX2A + widthDspX2B, widthDspX2C ) + 1;
type t_dspX2 is
record
  A0: std_logic_vector( widthDspX2A - 1 downto 0 ); -- r1
  A : std_logic_vector( widthDspX2A - 1 downto 0 ); -- r1
  B : std_logic_vector( widthDspX2B - 1 downto 0 ); -- K21
  C : std_logic_vector( widthDspX2C - 1 downto 0 ); -- x2
  P : std_logic_vector( widthDspX2P - 1 downto 0 ); -- x2 + r1 * K21
end record;
subtype r_x2 is natural range widthx2 + baseShiftx2 - shiftDspX2 + 2 - 1 downto baseShiftx2 - shiftDspX2 + 2;
subtype r_x2over is natural range widthDspX2P - 1 downto r_x2'high;

constant shiftDspX3 : integer := baseShiftK31 + baseShiftr1;
constant widthDspX3A: natural := widthr1 + 1;
constant widthDspX3B: natural := widthK31 + 1;
constant widthDspX3C: natural := widthx3 + 2 + baseShiftx3 - shiftDspX3;
constant widthDspX3P: natural := max( widthDspX3A + widthDspX3B, widthDspX3C ) + 1;
type t_dspX3 is
record
  A0: std_logic_vector( widthDspX3A - 1 downto 0 ); -- r1
  A : std_logic_vector( widthDspX3A - 1 downto 0 ); -- r1
  B : std_logic_vector( widthDspX3B - 1 downto 0 ); -- K31
  C : std_logic_vector( widthDspX3C - 1 downto 0 ); -- x3
  P : std_logic_vector( widthDspX3P - 1 downto 0 ); -- x3 + r1 * K31
end record;
subtype r_x3 is natural range widthx3 + baseShiftx3 - shiftDspX3 + 2 - 1 downto baseShiftx3 - shiftDspX3 + 2;
subtype r_x3over is natural range widthDspX3P - 1 downto r_x3'high;

constant shiftDspC00 : integer := baseShiftK00 + baseShiftS00;
constant widthDspC00A: natural :=     widthS00 + 1;
constant widthDspC00B: natural :=     widthK00 + 1;
constant widthDspC00C: natural := 1 + widthC00 + 2 + baseShiftC00 - shiftDspC00;
constant widthDspC00P: natural := max( widthDspC00A + widthDspC00B, widthDspC00C ) + 1;
type t_dspC00 is
record
  A0: std_logic_vector( widthDspC00A - 1 downto 0 ); -- S00
  A : std_logic_vector( widthDspC00A - 1 downto 0 ); -- S00
  B : std_logic_vector( widthDspC00B - 1 downto 0 ); -- K00
  C : std_logic_vector( widthDspC00C - 1 downto 0 ); -- C00
  P : std_logic_vector( widthDspC00P - 1 downto 0 ); -- C00 - S00 * K00
end record;
subtype r_C00 is natural range widthC00 + baseShiftC00 - shiftDspC00 + 2 - 1 downto baseShiftC00 - shiftDspC00 + 2;

constant shiftDspC01 : integer := baseShiftK00 + baseShiftS01;
constant widthDspC01A: natural := widthS01 + 1;
constant widthDspC01B: natural := widthK00 + 1;
constant widthDspC01C: natural := widthC01 + 2 + baseShiftC01 - shiftDspC01;
constant widthDspC01P: natural := max( widthDspC01A + widthDspC01B, widthDspC01C ) + 1;
type t_dspC01 is
record
  A0: std_logic_vector( widthDspC01A - 1 downto 0 ); -- S01
  A : std_logic_vector( widthDspC01A - 1 downto 0 ); -- S01
  B : std_logic_vector( widthDspC01B - 1 downto 0 ); -- K00
  C : std_logic_vector( widthDspC01C - 1 downto 0 ); -- C01
  P : std_logic_vector( widthDspC01P - 1 downto 0 ); -- C01 - S01 * K00
end record;
subtype r_C01 is natural range widthC01 + baseShiftC01 - shiftDspC01 + 2 - 1 downto baseShiftC01 - shiftDspC01 + 2;

constant shiftDspC11 : integer := baseShiftK10 + baseShiftS01;
constant widthDspC11A: natural :=     widthS01 + 1;
constant widthDspC11B: natural :=     widthK10 + 1;
constant widthDspC11C: natural := 1 + widthC11 + 2 + baseShiftC11 - shiftDspC11;
constant widthDspC11P: natural := max( widthDspC11A + widthDspC11B, widthDspC11C ) + 1;
type t_dspC11 is
record
  A : std_logic_vector( widthDspC11A - 1 downto 0 ); -- S01
  A0: std_logic_vector( widthDspC11A - 1 downto 0 ); -- S01
  B : std_logic_vector( widthDspC11B - 1 downto 0 ); -- K10
  C : std_logic_vector( widthDspC11C - 1 downto 0 ); -- C11
  P : std_logic_vector( widthDspC11P - 1 downto 0 ); -- C11 - S01 * K10
end record;
subtype r_C11 is natural range widthC11 + baseShiftC11 - shiftDspC11 + 2 - 1 downto baseShiftC11 - shiftDspC11 + 2;

constant shiftDspC22 : integer := baseShiftK21 + baseShiftS12;
constant widthDspC22A: natural :=     widthS12 + 1;
constant widthDspC22B: natural :=     widthK21 + 1;
constant widthDspC22C: natural := 1 + widthC22 + 2 + baseShiftC22 - shiftDspC22;
constant widthDspC22P: natural := max( widthDspC22A + widthDspC22B, widthDspC22C ) + 1;
type t_dspC22 is
record
  A0: std_logic_vector( widthDspC22A - 1 downto 0 ); -- S12
  A : std_logic_vector( widthDspC22A - 1 downto 0 ); -- S12
  B : std_logic_vector( widthDspC22B - 1 downto 0 ); -- K21
  C : std_logic_vector( widthDspC22C - 1 downto 0 ); -- C22
  P : std_logic_vector( widthDspC22P - 1 downto 0 ); -- C22 - S12 * K21
end record;
subtype r_C22 is natural range widthC22 + baseShiftC22 - shiftDspC22 + 2 - 1 downto baseShiftC22 - shiftDspC22 + 2;

constant shiftDspC23 : integer := baseShiftK21 + baseShiftS13;
constant widthDspC23A: natural := widthS13 + 1;
constant widthDspC23B: natural := widthK21 + 1;
constant widthDspC23C: natural := widthC23 + 2 + baseShiftC23 - shiftDspC23;
constant widthDspC23P: natural := max( widthDspC23A + widthDspC23B, widthDspC23C ) + 1;
type t_dspC23 is
record
  A0: std_logic_vector( widthDspC23A - 1 downto 0 ); -- S13
  A : std_logic_vector( widthDspC23A - 1 downto 0 ); -- S13
  B : std_logic_vector( widthDspC23B - 1 downto 0 ); -- K21
  C : std_logic_vector( widthDspC23C - 1 downto 0 ); -- C23
  P : std_logic_vector( widthDspC23P - 1 downto 0 ); -- C23 - S13 * K21
end record;
subtype r_C23 is natural range widthC23 + baseShiftC23 - shiftDspC23 + 2 - 1 downto baseShiftC23 - shiftDspC23 + 2;

constant shiftDspC33 : integer := baseShiftK31 + baseShiftS13;
constant widthDspC33A: natural :=     widthS13 + 1;
constant widthDspC33B: natural :=     widthK31 + 1;
constant widthDspC33C: natural := 1 + widthC33 + 2 + baseShiftC33 - shiftDspC33;
constant widthDspC33P: natural := max( widthDspC33A + widthDspC33B, widthDspC33C ) + 1;
type t_dspC33 is
record
  A0: std_logic_vector( widthDspC33A - 1 downto 0 ); -- S13
  A : std_logic_vector( widthDspC33A - 1 downto 0 ); -- S13
  B : std_logic_vector( widthDspC33B - 1 downto 0 ); -- K31
  C : std_logic_vector( widthDspC33C - 1 downto 0 ); -- C33
  P : std_logic_vector( widthDspC33P - 1 downto 0 ); -- C33 - S13 * K31
end record;
subtype r_C33 is natural range widthC33 + baseShiftC33 - shiftDspC33 + 2 - 1 downto baseShiftC33 - shiftDspC33 + 2;

type t_R00s is array ( natural range <> ) of std_logic_vector( widthR00 - 1 downto 0 );
type t_R11s is array ( natural range <> ) of std_logic_vector( widthR11 - 1 downto 0 );

function f_dynamicShift( s: std_logic_vector ) return std_logic_vector;

type t_ramInvR00 is array ( 0 to 2 ** widthR00Rough - 1 ) of std_logic_vector( widthInvR00Approx - 1 downto 0 );
type t_ramInvR11 is array ( 0 to 2 ** widthR11Rough - 1 ) of std_logic_vector( widthInvR11Approx - 1 downto 0 );
function init_ramInvR00 return t_ramInvR00;
function init_ramInvR11 return t_ramInvR11;

constant widthSumR0A: natural :=  widthM0 + baseShiftM0 - baseShiftX1 + 1;
constant widthSumR0B: natural :=  widthX1 + 1;
constant widthSumR0C: natural :=  max( widthSumR0A, widthSumR0B ) + 1;
type t_sumR0 is
record
  A: std_logic_vector( widthSumR0A - 1 downto 0 ); -- m0
  B: std_logic_vector( widthSumR0B - 1 downto 0 ); -- x1
  C: std_logic_vector( widthSumR0C - 1 downto 0 ); -- m0 - x1
end record;
subtype r_r0C is natural range widthSumR0C - 1 downto 1;

constant shiftDspR0 : integer := baseShiftX0 + baseShiftH00;
constant widthDspR0A: natural := widthH00 + 1;
constant widthDspR0B: natural := widthX0 + 1;
constant widthDspR0C: natural := widthSumR0C + 1 + baseShiftX1 - shiftDspR0;
constant widthDspR0P: natural := max( widthDspR0A + widthDspR0B, widthDspR0C ) + 1;
type t_dspR0 is
record
  A0: std_logic_vector( widthDspR0A - 1 downto 0 ); -- H00
  A : std_logic_vector( widthDspR0A - 1 downto 0 ); -- H00
  B0: std_logic_vector( widthDspR0B - 1 downto 0 ); -- x0
  B : std_logic_vector( widthDspR0B - 1 downto 0 ); -- x0
  C : std_logic_vector( widthDspR0C - 1 downto 0 ); -- m0 - x1
  P : std_logic_vector( widthDspR0P - 1 downto 0 ); -- m0 - x1 - x0 * H00
end record;
subtype r_r0 is natural range widthR0 + baseShiftR0 - shiftDspR0 + 2 - 1 downto baseShiftR0 - shiftDspR0 + 2;

constant widthSumR1A: natural :=  widthM1 + baseShiftM1 - baseShiftX3 + 1;
constant widthSumR1B: natural :=  widthX3 + 1;
constant widthSumR1C: natural :=  max( widthSumR1A, widthSumR1B ) + 1;
type t_sumR1 is
record
  A: std_logic_vector( widthSumR1A - 1 downto 0 ); -- m1
  B: std_logic_vector( widthSumR1B - 1 downto 0 ); -- x3
  C: std_logic_vector( widthSumR1C - 1 downto 0 ); -- m1 - x3
end record;
subtype r_r1C is natural range widthSumR1C - 1 downto 1;

constant shiftDspR1  : integer := baseShiftX2 + baseShiftH12;
constant widthDspR1A : natural := widthH12 + 1;
constant widthDspR1B : natural := widthX2 + 1;
constant widthDspR1C : natural := widthSumR1C + 1 + baseShiftX3 - shiftDspR1;
constant widthDspR1P : natural := max( widthDspR1A + widthDspR1B, widthDspR1C ) + 1;
type t_dspR1 is
record
  A0: std_logic_vector( widthDspR1A - 1 downto 0 ); -- H12
  A : std_logic_vector( widthDspR1A - 1 downto 0 ); -- H12
  B0: std_logic_vector( widthDspR1B - 1 downto 0 ); -- x2
  B : std_logic_vector( widthDspR1B - 1 downto 0 ); -- x2
  C : std_logic_vector( widthDspR1C - 1 downto 0 ); -- m1 - x3
  P : std_logic_vector( widthDspR1P - 1 downto 0 ); -- m1 - x3 - x2 * H12
end record;
subtype r_r1 is natural range widthr1 + baseShiftR1 - shiftDspR1 + 2 - 1 downto baseShiftR1 - shiftDspR1 + 2;

type t_r0s is array ( natural range <> ) of std_logic_vector( widthr0 - 1 downto 0 );
type t_r1s is array ( natural range <> ) of std_logic_vector( widthr1 - 1 downto 0 );

type t_srR is array   ( natural range <> ) of std_logic_vector( widthTMr   - 1 downto 0 );
type t_srPhi is array ( natural range <> ) of std_logic_vector( widthTMphi - 1 downto 0 );
type t_srZ is array   ( natural range <> ) of std_logic_vector( widthTMz   - 1 downto 0 );


end; 



package body kf_update_pkg is


function init_ramv0 return t_ramv0 is
  variable ram: t_ramv0 := ( others => ( others => '0' ) );
  variable d0, v0: real;
begin 
  for k in ram'range loop
    d0 := 2.0 * ( real( k ) + 0.5 ) * based0;
    v0 := d0 ** 2;
    if v0 / basev0 < 2.0 ** widthv0 then
      ram( k ) := stdu( v0, basev0, widthv0 );
    end if;
  end loop;
  return ram;
end function;

function init_ramv1 return t_ramv1 is
  variable ram: t_ramv1 := ( others => ( others => '0' ) );
  variable d1, v1: real;
begin
  for k in ram'range loop
    d1 := 2.0 * ( real( k ) + 0.5 ) * based1;
    v1 := d1 ** 2;
    if v1 / basev1 < 2.0 ** widthv1 then
        ram( k ) := stdu( v1, basev1, widthv1 );
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
  constant R00RoughOffset: real := baseR00Rough * 2.0 ** widthR00Rough;
begin
  for k in ram'range loop
    R00Rough := ( real( k ) + 0.5 ) * baseR00Rough + R00RoughOffset;
    invR00Approx := 1.0 / R00Rough;
    if invR00Approx / baseInvR00Approx < 2.0 ** widthInvR00Approx then
      ram( k ) := stdu( invR00Approx, baseInvR00Approx, widthInvR00Approx );
    end if;
  end loop;
  return ram;
end function;

function init_ramInvR11 return t_ramInvR11 is
  variable ram: t_ramInvR11 := ( others => ( others => '0' ) );
  variable R11Rough, invR11Approx: real;
  constant R11RoughOffset: real := baseR11Rough * 2.0 ** widthR11Rough;
begin
  for k in ram'range loop
    R11Rough := ( real( k ) + 0.5 ) * baseR11Rough + R11RoughOffset;
    invR11Approx := 1.0 / R11Rough;
    if invR11Approx / baseInvR11Approx < 2.0 ** widthInvR11Approx then
      ram( k ) := stdu( invR11Approx, baseInvR11Approx, widthInvR11Approx );
    end if;
  end loop;
  return ram;
end function;


end;