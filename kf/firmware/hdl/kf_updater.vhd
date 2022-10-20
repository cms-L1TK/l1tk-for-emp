library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.hybrid_data_formats.all;
use work.kf_data_formats.all;
use work.kf_data_types.all;


entity kf_updater is
generic (
  index: natural := 0
);
port (
  clk: in std_logic;
  updater_din: in t_state;
  updater_dout: out t_state
);
end;


architecture rtl of kf_updater is


attribute ram_style: string;
attribute use_dsp: string;

constant widthShift0: natural := width( widthR00 ) + 1;
constant widthShift1: natural := width( widthR11 ) + 1;

type t_shift0 is array ( natural range <> ) of std_logic_vector( widthShift0 - 1 downto 0 );
type t_shift1 is array ( natural range <> ) of std_logic_vector( widthShift1 - 1 downto 0 );

-- step 1
signal din: t_state := nulll;
signal state: t_states( 16 downto 1 + 1 ) := ( others => nulll );
signal dspS00: t_S00 := ( others => ( others => '0' ) );
signal dspS01: t_S01 := ( others => ( others => '0' ) );
signal dspS12: t_S12 := ( others => ( others => '0' ) );
signal dspS13: t_S13 := ( others => ( others => '0' ) );
signal ramv0: t_ramv0 := init_ramv0;
signal ramv1: t_ramv1 := init_ramv1;
signal optionalv0: std_logic_vector( widthv0 - 1 downto 0 ) := ( others => '0' );
signal optionalv1: std_logic_vector( widthv1 - 1 downto 0 ) := ( others => '0' );
attribute ram_style of ramv0, ramv1: signal is "block";

-- step 2
signal dspR00: t_R00 := ( others => ( others => '0' ) );
signal dspR11: t_R11 := ( others => ( others => '0' ) );
signal sumr0C: t_r0C := ( others => ( others => '0' ) );
signal sumr1C: t_r1C := ( others => ( others => '0' ) );
signal r0C: std_logic_vector( widthr0C - 1 - 1 downto 0 ) := ( others => '0' );
signal r1C: std_logic_vector( widthr1C - 1 - 1 downto 0 ) := ( others => '0' );
signal dspr0: t_r0 := ( others => ( others => '0' ) );
signal dspr1: t_r1 := ( others => ( others => '0' ) );
signal v0: std_logic_vector( widthv0 - 1 downto 0 ) := ( others => '0' );
signal v1: std_logic_vector( widthv1 - 1 downto 0 ) := ( others => '0' );

-- step 3
signal S00: std_logic_vector( widthS00 - 1 downto 0 ) := ( others => '0' );
signal S01: std_logic_vector( widthS01 - 1 downto 0 ) := ( others => '0' );
signal S12: std_logic_vector( widthS12 - 1 downto 0 ) := ( others => '0' );
signal S13: std_logic_vector( widthS13 - 1 downto 0 ) := ( others => '0' );
signal srS00: t_S00s( 13 downto 3 + 1 ) := ( others => ( others => '0' ) );
signal srS01: t_S01s( 13 downto 3 + 1 ) := ( others => ( others => '0' ) );
signal srS12: t_S12s( 13 downto 3 + 1 ) := ( others => ( others => '0' ) );
signal srS13: t_S13s( 13 downto 3 + 1 ) := ( others => ( others => '0' ) );
signal sumR00C: t_R00C := ( others => ( others => '0' ) );
signal sumR11C: t_R11C := ( others => ( others => '0' ) );
signal R00C: std_logic_vector( widthR00C - 1 - 1 downto 0 ) := ( others => '0' );
signal R11C: std_logic_vector( widthR11C - 1 - 1 downto 0 ) := ( others => '0' );

-- step 5
signal R00: std_logic_vector( widthR00 - 1 downto 0 ) := ( others => '0' );
signal R11: std_logic_vector( widthR11 - 1 downto 0 ) := ( others => '0' );
signal srR00: std_logic_vector( widthR00 - 1 downto 0 ) := ( others => '0' );
signal srR11: std_logic_vector( widthR11 - 1 downto 0 ) := ( others => '0' );
signal shift0: std_logic_vector( widthShift0 - 1 downto 0 ) := ( others => '0' );
signal shift1: std_logic_vector( widthShift1 - 1 downto 0 ) := ( others => '0' );
signal r0: std_logic_vector( widthr0 - 1 downto 0 ) := ( others => '0' );
signal r1: std_logic_vector( widthr1 - 1 downto 0 ) := ( others => '0' );
signal srr0: t_r0s( 13 downto 5 + 1 ) := ( others => ( others => '0' ) );
signal srr1: t_r1s( 13 downto 5 + 1 ) := ( others => ( others => '0' ) );

-- step 6
signal srShift0: t_shift0( 12 downto 6 + 1 ) := ( others =>  ( others => '0' ) );
signal srShift1: t_shift1( 12 downto 6 + 1 ) := ( others =>  ( others => '0' ) );
signal R00Shifted: std_logic_vector( widthR00 + 1 - 1 downto 0 ) := ( others => '0' );
signal R11Shifted: std_logic_vector( widthR11 + 1 - 1 downto 0 ) := ( others => '0' );
signal R00Rough: std_logic_vector( widthR00Rough - 1 downto 0 ) := ( others => '0' );
signal R11Rough: std_logic_vector( widthR11Rough - 1 downto 0 ) := ( others => '0' );

-- step 7
signal invR00Approx: std_logic_vector( widthInvR00Approx - 1 downto 0 ) := ( others => '0' );
signal invR11Approx: std_logic_vector( widthInvR11Approx - 1 downto 0 ) := ( others => '0' );
signal ramInvR00: t_ramInvR00 := init_ramInvR00;
signal ramInvR11: t_ramInvR11 := init_ramInvR11;
signal dspInvR00Cor: t_invR00Cor := ( others => ( others => '0' ) );
signal dspInvR11Cor: t_invR11Cor := ( others => ( others => '0' ) );
attribute ram_style of ramInvR00, ramInvR11: signal is "block";

-- step 9
signal dspInvR00: t_invR00 := ( others => ( others => '0' ) );
signal dspInvR11: t_invR11 := ( others => ( others => '0' ) );

-- step 10
signal invR00Cor: std_logic_vector( widthInvR00Cor - 1 downto 0 ) := ( others => '0' );
signal invR11Cor: std_logic_vector( widthInvR11Cor - 1 downto 0 ) := ( others => '0' );

-- step 11
signal dspK00: t_K00 := ( others => ( others => '0' ) );
signal dspK10: t_k10 := ( others => ( others => '0' ) );
signal dspK21: t_K21 := ( others => ( others => '0' ) );
signal dspK31: t_K31 := ( others => ( others => '0' ) );

-- step 12
signal dspInvR00P: std_logic_vector( widthInvR00P - 3 - 1 downto 0 ) := ( others => '0' );
signal dspInvR11P: std_logic_vector( widthInvR11P - 3 - 1 downto 0 ) := ( others => '0' );
signal invR00Shifted: std_logic_vector( widthInvR00P - 1 + 2 ** widthShift0 - 1 - 1 downto 0 ) := ( others => '0' );
signal invR11Shifted: std_logic_vector( widthInvR11P - 1 + 2 ** widthShift1 - 1 - 1 downto 0 ) := ( others => '0' );
signal invR00: std_logic_vector( widthInvR00 - 1 downto 0 ) := ( others => '0' );
signal invR11: std_logic_vector( widthInvR11 - 1 downto 0 ) := ( others => '0' );

-- step 13
signal dspx0: t_x0 := ( others => ( others => '0' ) );
signal dspx1: t_x1 := ( others => ( others => '0' ) );
signal dspx2: t_x2 := ( others => ( others => '0' ) );
signal dspx3: t_x3 := ( others => ( others => '0' ) );
signal dspC00: t_C00 := ( others => ( others => '0' ) );
signal dspC01: t_C01 := ( others => ( others => '0' ) );
signal dspC11: t_C11 := ( others => ( others => '0' ) );
signal dspC22: t_C22 := ( others => ( others => '0' ) );
signal dspC23: t_C23 := ( others => ( others => '0' ) );
signal dspC33: t_C33 := ( others => ( others => '0' ) );

-- step 14
signal K00: std_logic_vector( widthK00 - 1 downto 0 ) := ( others => '0' );
signal K10: std_logic_vector( widthK10 - 1 downto 0 ) := ( others => '0' );
signal K21: std_logic_vector( widthK21 - 1 downto 0 ) := ( others => '0' );
signal K31: std_logic_vector( widthK31 - 1 downto 0 ) := ( others => '0' );

-- step 15
signal x0: std_logic_vector( widthx0 - 1 downto 0 ) := ( others => '0' );
signal x1: std_logic_vector( widthx1 - 1 downto 0 ) := ( others => '0' );
signal x2: std_logic_vector( widthx2 - 1 downto 0 ) := ( others => '0' );
signal x3: std_logic_vector( widthx3 - 1 downto 0 ) := ( others => '0' );
signal C00: std_logic_vector( widthC00 - 1 downto 0 ) := ( others => '0' );
signal C01: std_logic_vector( widthC01 - 1 downto 0 ) := ( others => '0' );
signal C11: std_logic_vector( widthC11 - 1 downto 0 ) := ( others => '0' );
signal C22: std_logic_vector( widthC22 - 1 downto 0 ) := ( others => '0' );
signal C23: std_logic_vector( widthC23 - 1 downto 0 ) := ( others => '0' );
signal C33: std_logic_vector( widthC33 - 1 downto 0 ) := ( others => '0' );
signal dout: t_state := nulll;


begin


-- step 1
din <= updater_din;

-- step 2
sumr0C.m0 <= state( 2 ).m0 & '1' & ( baseShiftm0 - baseShiftx1 - 1 downto 0 => '0' );
sumr0C.x1 <= state( 2 ).x1 & '1';
sumr0C.sum <= sumr0C.m0 - sumr0C.x1;
sumr1C.m1 <= state( 2 ).m1 & '1'& ( baseShiftm1 - baseShiftx3 - 1 downto 0 => '0' );
sumr1C.x3 <= state( 2 ).x3 & '1';
sumr1C.sum <= sumr1C.m1 - sumr1C.x3;

-- step 3
S00 <= dspS00.P( r_S00 );
S01 <= dspS01.P( r_S01 );
S12 <= dspS12.P( r_S12 );
S13 <= dspS13.P( r_S13 );
sumR00C.S01 <= S01 & '1';
sumR00C.v0 <= '0' & v0 & '1' & ( baseShiftv0 - baseShiftS01 - 1 downto 0 => '0' );
sumR00C.sum <= sumR00C.S01 + sumR00C.v0;
sumR11C.S13 <= S13 & '1';
sumR11C.v1 <= '0' & v1 & '1' & ( baseShiftv1 - baseShiftS13 - 1 downto 0 => '0' );
sumR11C.sum <= sumR11C.S13 + sumR11C.v1;
R00C <= sumR00C.sum( r_R00C );
R11C <= sumR11C.sum( r_R11C );

-- step 5
R00 <= dspR00.P( r_R00 );
R11 <= dspR11.P( r_R11 );
r0 <= dspr0.P( r_r0 );
r1 <= dspr1.P( r_r1 );

-- step 6
R00Shifted <= usl( srR00 & '1', uint( shift0 ) );
R11Shifted <= usl( srR11 & '1', uint( shift1 ) );

-- step 10
invR00Cor <= dspInvR00Cor.P( r_invR00Cor );
invR11Cor <= dspInvR11Cor.P( r_invR11Cor );

---- step 12
dspInvR00P <= dspInvR00.P( widthInvR00P - 1 - 1 downto 2 );
dspInvR11P <= dspInvR11.P( widthInvR11P - 1 - 1 downto 2 );
invR00Shifted <= usl( ( 2 ** widthShift0 - 1 downto 0 => '0' ) & dspInvR00P & '1', uint( srShift0( 12 ) ) );
invR11Shifted <= usl( ( 2 ** widthShift0 - 1 downto 0 => '0' ) & dspInvR11P & '1', uint( srShift1( 12 ) ) );
invR00 <= invR00Shifted( r_invR00 );
invR11 <= invR11Shifted( r_invR11 );

-- step 14
K00 <= dspK00.P( r_K00 );
K10 <= dspK10.P( r_K10 );
K21 <= dspK21.P( r_K21 );
K31 <= dspK31.P( r_K31 );

-- step 15
C00 <= dspC00.P( r_C00 );
C01 <= dspC01.P( r_C01 );
C11 <= dspC11.P( r_C11 );
C22 <= dspC22.P( r_C22 );
C23 <= dspC23.P( r_C23 );
C33 <= dspC33.P( r_C33 );
x0 <= dspx0.P( r_x0 );
x1 <= dspx1.P( r_x1 );
x2 <= dspx2.P( r_x2 );
x3 <= dspx3.P( r_x3 );

--step 16s
updater_dout <= dout;


process( clk ) is
begin
if rising_edge( clk ) then

  -- step 1

  state <= state( state'high - 1 downto state'low ) & din;
  dspS00.A <= din.H00 & '1';
  dspS00.B <= '0' & din.C00 & '1';
  dspS00.C <= din.C01 & '1' & ( baseShiftC01 - ( baseShiftH00 + baseShiftC00 ) + 1 - 1 downto 0 => '0' );
  dspS01.A <= din.H00 & '1';
  dspS01.B <= din.C01 & '1';
  dspS01.C <= '0' & din.C11 & '1' & ( baseShiftC11 - ( baseShiftH00 + baseShiftC01 ) + 1 - 1 downto 0 => '0' );
  dspS12.A <= din.H00 & '1';
  dspS12.D <= dH & '0';
  dspS12.B <= '0' & din.C22 & '1';
  dspS12.C <= din.C23 & '1' & ( baseShiftC23 - ( baseShiftH12 + baseShiftC22 ) + 1 - 1 downto 0 => '0' );
  dspS13.A <= din.H00 & '1';
  dspS13.D <= dH & '0';
  dspS13.B <= din.C23 & '1';
  dspS13.C <= '0' & din.C33 & '1' & ( baseShiftC33 - ( baseShiftH12 + baseShiftC23 ) + 1 - 1 downto 0 => '0' );
  optionalv0 <= ramv0( uint( din.d0 ) );
  optionalv1 <= ramv1( uint( din.d1 ) );

  -- step 2

  dspR00.A0 <= state( 2 ).H00 & '1';
  dspS00.P <= dspS00.A * dspS00.B + dspS00.C;
  dspS01.P <= dspS01.A * dspS01.B + dspS01.C;
  dspS12.P <= ( dspS12.A + dspS12.D ) * dspS12.B + dspS12.C;
  dspS13.P <= ( dspS13.A + dspS13.D ) * dspS13.B + dspS13.C;
  dspR11.A <= state( 2 ).H00 & '1';
  dspR11.D <= dH & '0';
  dspr0.A0 <= state( 2 ).H00 & '1';
  dspr0.B0 <= state( 2 ).x0 & '1';
  dspr1.A <= state( 2 ).H00 & '1';
  dspr1.D <= dH & '0';
  dspr1.B0 <= state( 2 ).x2 & '1';
  r0C <= sumr0C.sum( r_r0C );
  r1C <= sumr1C.sum( r_r1C );
  v0 <= optionalv0;
  v1 <= optionalv1;

  -- step 3

  srS00 <= srS00( srS00'high - 1 downto srS00'low ) & S00;
  srS01 <= srS01( srS01'high - 1 downto srS01'low ) & S01;
  srS12 <= srS12( srS12'high - 1 downto srS12'low ) & S12;
  srS13 <= srS13( srS13'high - 1 downto srS13'low ) & S13;
  dspR00.A1 <= dspR00.A0;
  dspR00.B <= s00 & '1';
  dspR00.C <= R00C & '1' & ( baseShiftS01 - ( baseShiftH00 + baseShiftS00 ) + 1 - 1 downto 0 => '0' );
  dspR11.AD <= dspR11.A + dspR11.D;
  dspR11.B <= S12 & '1';
  dspR11.C <= R11C & '1' & ( baseShiftS13 - ( baseShiftH12 + baseShiftS12 ) + 1 - 1 downto 0 => '0' );
  dspr0.A1 <= dspr0.A0;
  dspr0.B1 <= dspr0.B0;
  dspr0.C <= r0C & '1' & ( baseShiftx1 - ( baseShiftx0 + baseShiftH00 ) + 1 - 1 downto 0 => '0' );
  dspr1.AD <= dspr1.A + dspr1.D;
  dspr1.B1 <= dspr1.B0;
  dspr1.C <= r1C & '1' & ( baseShiftx3 - ( baseShiftx2 + baseShiftH12 ) + 1 - 1 downto 0 => '0' );

  -- step 4

  dspR00.P <= dspR00.A1 * dspR00.B + dspR00.C;
  dspR11.P <= dspR11.AD * dspR11.B + dspR11.C;
  dspr0.P <= dspr0.C - dspr0.A1 * dspr0.B1;
  dspr1.P <= dspr1.C - dspr1.AD * dspr1.B1;

  -- step 5

  srR00 <= R00;
  srR11 <= R11;
  shift0 <= f_dynamicShift( R00 );
  shift1 <= f_dynamicShift( R11 );
  srr0 <= srr0( srr0'high - 1 downto srr0'low ) & r0;
  srr1 <= srr1( srr1'high - 1 downto srr1'low ) & r1;

  -- step 6

  R00Rough <= R00Shifted( widthR00 + 1 - 1 downto widthR00 + 1 - widthR00Rough );
  R11Rough <= R11Shifted( widthR11 + 1 - 1 downto widthR11 + 1 - widthR11Rough );
  srShift0 <= srShift0( srShift0'high - 1 downto srShift0'low ) & shift0;
  srShift1 <= srShift1( srShift1'high - 1 downto srShift1'low ) & shift1;

  -- step 7

  invR00Approx <= ramInvR00( uint( R00Rough ) );
  invR11Approx <= ramInvR11( uint( R11Rough ) );
  dspInvR00Cor.B0 <= '0' & R00Rough & '1';
  dspInvR11Cor.B0 <= '0' & R11Rough & '1';

  -- step 8

  dspInvR00Cor.A <= '0' & invR00Approx & '1';
  dspInvR00Cor.B1 <= dspInvR00Cor.B0;
  dspInvR00Cor.C <= '0' & invR00Cor2 & "00";
  dspInvR11Cor.A <= '0' & invR11Approx & '1';
  dspInvR11Cor.B1 <= dspInvR11Cor.B0;
  dspInvR11Cor.C <= '0' & invR11Cor2 & "00";

  -- step 9

  dspInvR00Cor.P <= dspInvR00Cor.C - dspInvR00Cor.A * dspInvR00Cor.B1;
  dspInvR11Cor.P <= dspInvR11Cor.C - dspInvR11Cor.A * dspInvR11Cor.B1;
  dspInvR00.A0 <= dspInvR00Cor.A;
  dspInvR11.A0 <= dspInvR11Cor.A;

  -- step 10

  dspInvR00.A1 <= dspInvR00.A0;
  dspInvR00.B <= '0' & invR00Cor & '1';
  dspInvR11.A1 <= dspInvR11.A0;
  dspInvR11.B <= '0' & invR11Cor & '1';

  -- step 11

  dspInvR00.P <= dspInvR00.A1 * dspInvR00.B;
  dspInvR11.P <= dspInvR11.A1 * dspInvR11.B;
  dspK00.B0 <= srS00( 11 ) & '1';
  dspK10.B0 <= srS01( 11 ) & '1';
  dspK21.B0 <= srS12( 11 ) & '1';
  dspK31.B0 <= srS13( 11 ) & '1';

  -- step 12

  dspK00.A <= '0' & invR00 & '1';
  dspK10.A <= '0' & invR00 & '1';
  dspK21.A <= '0' & invR11 & '1';
  dspK31.A <= '0' & invR11 & '1';
  dspK00.B1 <= dspK00.B0;
  dspK10.B1 <= dspK10.B0;
  dspK21.B1 <= dspK21.B0;
  dspK31.B1 <= dspK31.B0;

  -- step 13

  dspK00.P <= dspK00.A * dspK00.B1;
  dspK10.P <= dspK10.A * dspK10.B1;
  dspK21.P <= dspK21.A * dspK21.B1;
  dspK31.P <= dspK31.A * dspK31.B1;
  dspx0.B0 <= srr0( 13 ) & '1';
  dspx1.B0 <= srr0( 13 ) & '1';
  dspx2.B0 <= srr1( 13 ) & '1';
  dspx3.B0 <= srr1( 13 ) & '1';
  dspC00.B0 <= srS00( 13 ) & '1';
  dspC01.B0 <= srS01( 13 ) & '1';
  dspC11.B0 <= srS01( 13 ) & '1';
  dspC22.B0 <= srS12( 13 ) & '1';
  dspC23.B0 <= srS13( 13 ) & '1';
  dspC33.B0 <= srS13( 13 ) & '1';

  -- step 14

  dspx0.B1 <= dspx0.B0;
  dspx0.A <= K00 & '1';
  dspx0.C <= state( 14 ).x0 & '1' & ( baseShiftx0 - ( baseShiftK00 + baseShiftr0 ) + 1 - 1 downto 0 => '0' );
  dspx1.B1 <= dspx1.B0;
  dspx1.A <= K10 & '1';
  dspx1.C <= state( 14 ).x1 & '1' & ( baseShiftx1 - ( baseShiftK10 + baseShiftr0 ) + 1 - 1 downto 0 => '0' );
  dspx2.B1 <= dspx2.B0;
  dspx2.A <= K21 & '1';
  dspx2.C <= state( 14 ).x2 & '1' & ( baseShiftx2 - ( baseShiftK21 + baseShiftr1 ) + 1 - 1 downto 0 => '0' );
  dspx3.B1 <= dspx3.B0;
  dspx3.A <= K31 & '1';
  dspx3.C <= state( 14 ).x3 & '1' & ( baseShiftx3 - ( baseShiftK31 + baseShiftr1 ) + 1 - 1 downto 0 => '0' );
  dspC00.B1 <= dspC00.B0;
  dspC00.A <= K00 & '1';
  dspC00.C <= state( 14 ).C00 & '1' & ( baseShiftC00 - ( baseShiftK00 + baseShiftS00 ) + 1 - 1 downto 0 => '0' );
  dspC01.B1 <= dspC01.B0;
  dspC01.A <= K00 & '1';
  dspC01.C <= state( 14 ).C01 & '1' & ( baseShiftC01 - ( baseShiftK00 + baseShiftS01 ) + 1 - 1 downto 0 => '0' );
  dspC11.B1 <= dspC11.B0;
  dspC11.A <= K10 & '1';
  dspC11.C <= state( 14 ).C11 & '1' & ( baseShiftC11 - ( baseShiftK10 + baseShiftS01 ) + 1 - 1 downto 0 => '0' );
  dspC22.B1 <= dspC22.B0;
  dspC22.A <= K21 & '1';
  dspC22.C <= state( 14 ).C22 & '1' & ( baseShiftC22 - ( baseShiftK21 + baseShiftS12 ) + 1 - 1 downto 0 => '0' );
  dspC23.B1 <= dspC23.B0;
  dspC23.A <= K21 & '1';
  dspC23.C <= state( 14 ).C23 & '1' & ( baseShiftC23 - ( baseShiftK21 + baseShiftS13 ) + 1 - 1 downto 0 => '0' );
  dspC33.B1 <= dspC33.B0;
  dspC33.A <= K31 & '1';
  dspC33.C <= state( 14 ).C33 & '1' & ( baseShiftC33 - ( baseShiftK31 + baseShiftS13 ) + 1 - 1 downto 0 => '0' );

  -- step 15

  dspx0.P <= dspx0.C + dspx0.A * dspx0.B1;
  dspx1.P <= dspx1.C + dspx1.A * dspx1.B1;
  dspx2.P <= dspx2.C + dspx2.A * dspx2.B1;
  dspx3.P <= dspx3.C + dspx3.A * dspx3.B1;
  dspC00.P <= dspC00.C - dspC00.A * dspC00.B1;
  dspC01.P <= dspC01.C - dspC01.A * dspC01.B1;
  dspC11.P <= dspC11.C - dspC11.A * dspC11.B1;
  dspC22.P <= dspC22.C - dspC22.A * dspC22.B1;
  dspC23.P <= dspC23.C - dspC23.A * dspC23.B1;
  dspC33.P <= dspC33.C - dspC33.A * dspC33.B1;

  -- step 16

  dout <= nulll;
  if state( 16 ).reset = '1' then
    dout.reset <= '1';
  elsif state( 16 ).valid = '1' then
    dout <= state( 16 );
    dout.skip <= '0';
    if ( index < numLayers - 1 and state( 16 ).hitsT( index + 1 ) = '0' ) or count( state( 16 ).hits, '1' ) = maxLayersKF then
      dout.skip <= '1';
    end if;
    if state( 16 ).skip = '0' then
      dout.stub <= ( others => '0' );
      dout.hits( index ) <= '1';
      dout.lmap( ( index + 1 ) * widthStubs - 1 downto index * widthStubs ) <= state( 16 ).stub;
      dout.x0 <= x0;
      dout.x1 <= x1;
      dout.x2 <= x2;
      dout.x3 <= x3;
      dout.C00 <= C00;
      dout.C01 <= C01;
      dout.C11 <= C11;
      dout.C22 <= C22;
      dout.C23 <= C23;
      dout.C33 <= C33;
      if count( state( 16 ).hits, '1' ) = maxLayersKF - 1 then
        dout.skip <= '1';
      end if;
    end if;
  end if;

end if;
end process;


end;