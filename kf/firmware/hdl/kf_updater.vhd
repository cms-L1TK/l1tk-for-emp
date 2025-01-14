library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.hybrid_data_formats.all;
use work.kf_data_formats.all;
use work.kf_data_types.all;
use work.kf_update_pkg.all;


entity kf_updater is
generic (
  index: natural := 0
);
port (
  clk: in std_logic;
  updater_din: in t_update;
  updater_dout: out t_state
);
end;


architecture rtl of kf_updater is


attribute ram_style: string;
attribute use_dsp: string;

-- step 1
signal m0: std_logic_vector( widthm0 - 1 downto 0 ) := ( others => '0' );
signal m1: std_logic_vector( widthm1 - 1 downto 0 ) := ( others => '0' );
signal H00: std_logic_vector( widthH00 - 1 downto 0 ) := ( others => '0' );
signal H12, H12lut: std_logic_vector( widthH12 - 1 downto 0 ) := ( others => '0' );
signal state: t_states( 16 downto 1 + 1 ) := ( others => nulll );
signal dspS00: t_dspS00 := ( others => ( others => '0' ) );
signal dspS01: t_dspS01 := ( others => ( others => '0' ) );
signal dspS12: t_dspS12 := ( others => ( others => '0' ) );
signal dspS13: t_dspS13 := ( others => ( others => '0' ) );
signal ramv0: t_ramv0 := init_ramv0;
signal ramv1: t_ramv1 := init_ramv1;
signal optionalv0: std_logic_vector( widthv0 - 1 downto 0 ) := ( others => '0' );
signal optionalv1: std_logic_vector( widthv1 - 1 downto 0 ) := ( others => '0' );
attribute ram_style of ramv0, ramv1: signal is "block";

-- step 2
signal dspR00: t_dspR00 := ( others => ( others => '0' ) );
signal dspR11: t_dspR11 := ( others => ( others => '0' ) );
signal sumr0: t_sumR0 := ( others => ( others => '0' ) );
signal sumr1: t_sumR1 := ( others => ( others => '0' ) );
signal r0C: std_logic_vector( widthSumR0C - 1 - 1 downto 0 ) := ( others => '0' );
signal r1C: std_logic_vector( widthSumR1C - 1 - 1 downto 0 ) := ( others => '0' );
signal dspr0: t_dspR0 := ( others => ( others => '0' ) );
signal dspr1: t_dspR1 := ( others => ( others => '0' ) );
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
signal sumR00: t_sumR00 := ( others => ( others => '0' ) );
signal sumR11: t_sumR11 := ( others => ( others => '0' ) );
signal R00C: std_logic_vector( widthSumR00C - 1 - 1 downto 0 ) := ( others => '0' );
signal R11C: std_logic_vector( widthSumR11C - 1 - 1 downto 0 ) := ( others => '0' );

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
signal srShift0: t_shift0( 11 downto 5 + 1 ) := ( others => ( others => '0' ) );
signal srShift1: t_shift1( 11 downto 5 + 1 ) := ( others => ( others => '0' ) );

-- step 6
signal R00Shifted: std_logic_vector( widthR00 + 1 - 1 downto 0 ) := ( others => '0' );
signal R11Shifted: std_logic_vector( widthR11 + 1 - 1 downto 0 ) := ( others => '0' );
signal R00Rough: std_logic_vector( widthR00Rough - 1 downto 0 ) := ( others => '0' );
signal R11Rough: std_logic_vector( widthR11Rough - 1 downto 0 ) := ( others => '0' );
signal invR00ApproxReg: std_logic_vector( widthInvR00Approx - 1 downto 0 ) := ( others => '0' );
signal invR11ApproxReg: std_logic_vector( widthInvR11Approx - 1 downto 0 ) := ( others => '0' );

-- step 7
signal invR00Approx: std_logic_vector( widthInvR00Approx - 1 downto 0 ) := ( others => '0' );
signal invR11Approx: std_logic_vector( widthInvR11Approx - 1 downto 0 ) := ( others => '0' );
signal ramInvR00: t_ramInvR00 := init_ramInvR00;
signal ramInvR11: t_ramInvR11 := init_ramInvR11;
signal dspInvR00Cor: t_dspInvR00Cor := ( others => ( others => '0' ) );
signal dspInvR11Cor: t_dspInvR11Cor := ( others => ( others => '0' ) );
attribute ram_style of ramInvR00, ramInvR11: signal is "block";

-- step 9
signal dspInvR00: t_dspInvR00 := ( others => ( others => '0' ) );
signal dspInvR11: t_dspInvR11 := ( others => ( others => '0' ) );

-- step 10
signal invR00Cor: std_logic_vector( widthInvR00Cor - 1 downto 0 ) := ( others => '0' );
signal invR11Cor: std_logic_vector( widthInvR11Cor - 1 downto 0 ) := ( others => '0' );

-- step 11
signal S00ShiftedTmp: std_logic_vector( lsbS00Shifted + widthS00Shifted + 1 - 1 downto 0 ) := ( others => '0' );
signal S01ShiftedTmp: std_logic_vector( lsbS01Shifted + widthS01Shifted + 1 - 1 downto 0 ) := ( others => '0' );
signal S12ShiftedTmp: std_logic_vector( lsbS12Shifted + widthS12Shifted + 1 - 1 downto 0 ) := ( others => '0' );
signal S13ShiftedTmp: std_logic_vector( lsbS13Shifted + widthS13Shifted + 1 - 1 downto 0 ) := ( others => '0' );
signal S00Shifted: std_logic_vector( widthS00Shifted + 1 - 1 downto 0 ) := ( others => '0' );
signal S01Shifted: std_logic_vector( widthS01Shifted + 1 - 1 downto 0 ) := ( others => '0' );
signal S12Shifted: std_logic_vector( widthS12Shifted + 1 - 1 downto 0 ) := ( others => '0' );
signal S13Shifted: std_logic_vector( widthS13Shifted + 1 - 1 downto 0 ) := ( others => '0' );
signal dspK00: t_dspK00 := ( others => ( others => '0' ) );
signal dspK10: t_dspk10 := ( others => ( others => '0' ) );
signal dspK21: t_dspK21 := ( others => ( others => '0' ) );
signal dspK31: t_dspK31 := ( others => ( others => '0' ) );

-- step 12
signal invR00Shifted: std_logic_vector( widthInvR00 - 1 downto 0 ) := ( others => '0' );
signal invR11Shifted: std_logic_vector( widthInvR11 - 1 downto 0 ) := ( others => '0' );

-- step 13
signal dspx0: t_dspX0 := ( others => ( others => '0' ) );
signal dspx1: t_dspX1 := ( others => ( others => '0' ) );
signal dspx2: t_dspX2 := ( others => ( others => '0' ) );
signal dspx3: t_dspX3 := ( others => ( others => '0' ) );
signal dspC00: t_dspC00 := ( others => ( others => '0' ) );
signal dspC01: t_dspC01 := ( others => ( others => '0' ) );
signal dspC11: t_dspC11 := ( others => ( others => '0' ) );
signal dspC22: t_dspC22 := ( others => ( others => '0' ) );
signal dspC23: t_dspC23 := ( others => ( others => '0' ) );
signal dspC33: t_dspC33 := ( others => ( others => '0' ) );

-- step 14
signal K00: std_logic_vector( widthK00 - 1 downto 0 ) := ( others => '0' );
signal K10: std_logic_vector( widthK10 - 1 downto 0 ) := ( others => '0' );
signal K21: std_logic_vector( widthK21 - 1 downto 0 ) := ( others => '0' );
signal K31: std_logic_vector( widthK31 - 1 downto 0 ) := ( others => '0' );

-- step 15
signal valid: std_logic := '0';
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
signal absX0, absX1, absX2, absX3: integer := 0;
signal invalidX0, invalidX1, invalidX2, invalidX3: boolean := false;

-- step 16
signal dout: t_state := nulll;


begin


-- step 1
H12lut <= f_H12( updater_din.stub.H00 );

-- step 2
sumR0.A <= m0 & '1' & ( baseShiftM0 - baseShiftX1 - 1 downto 0 => '0' );
sumR0.B <= state( 2 ).track.x1 & '1';
sumR0.C <= sumR0.A - sumR0.B;
sumR1.A <= m1 & '1'& ( baseShiftM1 - baseShiftX3 - 1 downto 0 => '0' );
sumR1.B <= state( 2 ).track.x3 & '1';
sumR1.C <= sumR1.A - sumR1.B;

-- step 3
S00 <= dspS00.P( r_S00 );
S01 <= dspS01.P( r_S01 );
S12 <= dspS12.P( r_S12 );
S13 <= dspS13.P( r_S13 );
sumR00.A <= S01 & '1';
sumR00.B <= '0' & v0 & '1';
sumR00.C <= sumR00.A + sumR00.B;
sumR11.A <= S13 & '1';
sumR11.B <= '0' & v1 & '1';
sumR11.C <= sumR11.A + sumR11.B;
R00C <= sumR00.C( r_R00C );
R11C <= sumR11.C( r_R11C );

-- step 5
shift0 <= f_dynamicShift( R00 );
shift1 <= f_dynamicShift( R11 );
R00 <= dspR00.P( r_R00 );
R11 <= dspR11.P( r_R11 );
r0 <= dspr0.P( r_r0 );
r1 <= dspr1.P( r_r1 );

-- step 6
R00Rough <= R00Shifted( widthR00 - 1 downto widthR00 - widthR00Rough );
R11Rough <= R11Shifted( widthR11 - 1 downto widthR11 - widthR11Rough );

-- step 10
invR00Cor <= dspInvR00Cor.P( r_invR00Cor );
invR11Cor <= dspInvR11Cor.P( r_invR11Cor );

-- step 11
S00ShiftedTmp <= ssl( resize( srS00( 11 ), widthS00 + lsbS00Shifted ) & '1', uint( srShift0( 11 ) ) );
S01ShiftedTmp <= ssl( resize( srS01( 11 ), widthS01 + lsbS01Shifted ) & '1', uint( srShift0( 11 ) ) );
S12ShiftedTmp <= ssl( resize( srS12( 11 ), widthS12 + lsbS12Shifted ) & '1', uint( srShift1( 11 ) ) );
S13ShiftedTmp <= ssl( resize( srS13( 11 ), widthS13 + lsbS13Shifted ) & '1', uint( srShift1( 11 ) ) );
S00Shifted <= S00ShiftedTmp( lsbS00Shifted + widthS00Shifted + 1 - 1 downto lsbS00Shifted );
S01Shifted <= S01ShiftedTmp( lsbS01Shifted + widthS01Shifted + 1 - 1 downto lsbS01Shifted );
S12Shifted <= S12ShiftedTmp( lsbS12Shifted + widthS12Shifted + 1 - 1 downto lsbS12Shifted );
S13Shifted <= S13ShiftedTmp( lsbS13Shifted + widthS13Shifted + 1 - 1 downto lsbS13Shifted );

---- step 12
invR00Shifted <= dspInvR00.P( r_invR00 );
invR11Shifted <= dspInvR11.P( r_invR11 );

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
absX0 <= uint( abs( dspx0.P( r_x0over ) ) );
absX1 <= uint( abs( dspx1.P( r_x1over ) ) );
absX2 <= uint( abs( dspx2.P( r_x2over ) ) );
absX3 <= uint( abs( dspx3.P( r_x3over ) ) );
invalidX0   <= true when absX0 > limitX0 else false;
invalidX1   <= true when absX1 > limitX1 else false;
invalidX2   <= true when absX2 > limitX2 else false;
invalidX3   <= true when absX3 > limitX3 else false;

--step 16
updater_dout <= dout;


process( clk ) is
begin
if rising_edge( clk ) then

  -- shift registesr

  state <= state( state'high - 1 downto state'low ) & nulll;
  srS00 <= srS00( srS00'high - 1 downto srS00'low ) & stdu( 0, widthS00 );
  srS01 <= srS01( srS01'high - 1 downto srS01'low ) & stdu( 0, widthS01 );
  srS12 <= srS12( srS12'high - 1 downto srS12'low ) & stdu( 0, widthS12 );
  srS13 <= srS13( srS13'high - 1 downto srS13'low ) & stdu( 0, widthS13 );
  srr0 <= srr0( srr0'high - 1 downto srr0'low ) & stdu( 0, widthR0 );
  srr1 <= srr1( srr1'high - 1 downto srr1'low ) & stdu( 0, widthR1 );
  srShift0 <= srShift0( srShift0'high - 1 downto srShift0'low ) & stdu( 0, widthShift0 );
  srShift1 <= srShift1( srShift1'high - 1 downto srShift1'low ) & stdu( 0, widthShift1 );


  -- step 1

  H00 <= updater_din.stub.H00;
  H12 <= H12lut;
  m0 <= updater_din.stub.m0;
  m1 <= updater_din.stub.m1;
  state( state'low ) <= ( updater_din.meta, updater_din.track, updater_din.cov );
  dspS00.A <= '0' & updater_din.cov.C00 & '1';
  dspS01.A <=       updater_din.cov.C01 & '1';
  dspS12.A <= '0' & updater_din.cov.C22 & '1';
  dspS13.A <=       updater_din.cov.C23 & '1';
  dspS00.B <= updater_din.stub.H00 & '1';
  dspS01.B <= updater_din.stub.H00 & '1';
  dspS12.B <= H12lut & '1';
  dspS13.B <= H12lut & '1';
  dspS00.C <=       updater_din.cov.C01 & "10" & ( baseShiftC01 - shiftDspS00 - 1 downto 0 => '0' );
  dspS01.C <= '0' & updater_din.cov.C11 & "10" & ( baseShiftC11 - shiftDspS01 - 1 downto 0 => '0' );
  dspS12.C <=       updater_din.cov.C23 & "10" & ( baseShiftC23 - shiftDspS12 - 1 downto 0 => '0' );
  dspS13.C <= '0' & updater_din.cov.C33 & "10" & ( baseShiftC33 - shiftDspS13 - 1 downto 0 => '0' );
  optionalv0 <= ramv0( uint( updater_din.stub.d0 ) );
  optionalv1 <= ramv1( uint( updater_din.stub.d1 ) );

  -- step 2

  dspR00.B0 <= H00 & '1';
  dspR11.B0 <= H12 & '1';
  dspS00.P <= dspS00.A * dspS00.B + dspS00.C;
  dspS01.P <= dspS01.A * dspS01.B + dspS01.C;
  dspS12.P <= dspS12.A * dspS12.B + dspS12.C;
  dspS13.P <= dspS13.A * dspS13.B + dspS13.C;
  dspr0.A0 <= H00 & '1';
  dspr1.A0 <= H12 & '1';
  dspr0.B0 <= state( 2 ).track.x0 & '1';
  dspr1.B0 <= state( 2 ).track.x2 & '1';
  r0C <= sumr0.C( r_r0C );
  r1C <= sumr1.C( r_r1C );
  v0 <= optionalv0;
  v1 <= optionalv1;

  -- step 3

  srS00( srS00'low ) <= S00;
  srS01( srS01'low ) <= S01;
  srS12( srS12'low ) <= S12;
  srS13( srS13'low ) <= S13;
  dspR00.A <= s00 & '1';
  dspR11.A <= S12 & '1';
  dspR00.B <= dspR00.B0;
  dspR11.B <= dspR11.B0;
  dspR00.C <= R00C & "00" & ( baseShiftS01 - shiftDspR00 - 1 downto 0 => '0' );
  dspR11.C <= R11C & "00" & ( baseShiftS13 - shiftDspR11 - 1 downto 0 => '0' );
  dspr0.A <= dspr0.A0;
  dspr1.A <= dspr1.A0;
  dspr0.B <= dspr0.B0;
  dspr1.B <= dspr1.B0;
  dspr0.C <= r0C & "10" & ( baseShiftx1 - shiftDspR0 - 1 downto 0 => '0' );
  dspr1.C <= r1C & "10" & ( baseShiftx3 - shiftDspR1 - 1 downto 0 => '0' );

  -- step 4

  dspR00.P <= dspR00.A * dspR00.B + dspR00.C;
  dspR11.P <= dspR11.A * dspR11.B + dspR11.C;
  dspr0.P <= dspr0.C - dspr0.A * dspr0.B;
  dspr1.P <= dspr1.C - dspr1.A * dspr1.B;

  -- step 5

  srR00 <= R00;
  srR11 <= R11;
  srr0( srr0'low ) <= r0;
  srr1( srr1'low ) <= r1;
  srShift0( srShift0'low ) <= shift0;
  srShift1( srShift1'low ) <= shift1;

  -- step 6

  R00Shifted <= usl( srR00 & '1', uint( srShift0( 6 ) ) );
  R11Shifted <= usl( srR11 & '1', uint( srShift1( 6 ) ) );

  -- step 7

  invR00Approx <= ramInvR00( uint( R00Rough ) );
  invR11Approx <= ramInvR11( uint( R11Rough ) );
  dspInvR00Cor.A0 <= '0' & R00Shifted;
  dspInvR11Cor.A0 <= '0' & R11Shifted;

  -- step 8

  invR00ApproxReg <= invR00Approx;
  invR11ApproxReg <= invR11Approx;
  dspInvR00Cor.A <= dspInvR00Cor.A0;
  dspInvR11Cor.A <= dspInvR11Cor.A0;
  dspInvR00Cor.B <= '0' & invR00Approx & '1';
  dspInvR11Cor.B <= '0' & invR11Approx & '1';
  dspInvR00Cor.C <= '0' & invR00Cor2;
  dspInvR11Cor.C <= '0' & invR11Cor2;

  -- step 9

  dspInvR00Cor.P <= dspInvR00Cor.C - dspInvR00Cor.A * dspInvR00Cor.B;
  dspInvR11Cor.P <= dspInvR11Cor.C - dspInvR11Cor.A * dspInvR11Cor.B;
  dspInvR00.B0 <= '0' & invR00ApproxReg & '1';
  dspInvR11.B0 <= '0' & invR11ApproxReg & '1';

  -- step 10
 
  dspInvR00.A <= '0' & invR00Cor & '1';
  dspInvR11.A <= '0' & invR11Cor & '1';
  dspInvR00.B <= dspInvR00.B0;
  dspInvR11.B <= dspInvR11.B0;

  -- step 11

  dspInvR00.P <= dspInvR00.A * dspInvR00.B;
  dspInvR11.P <= dspInvR11.A * dspInvR11.B;
  dspK00.A0 <= S00Shifted;
  dspK10.A0 <= S01Shifted;
  dspK21.A0 <= S12Shifted;
  dspK31.A0 <= S13Shifted;

  -- step 12

  dspK00.A <= dspK00.A0;
  dspK10.A <= dspK10.A0;
  dspK21.A <= dspK21.A0;
  dspK31.A <= dspK31.A0;
  dspK00.B <= '0' & invR00Shifted & '1';
  dspK10.B <= '0' & invR00Shifted & '1';
  dspK21.B <= '0' & invR11Shifted & '1';
  dspK31.B <= '0' & invR11Shifted & '1';

  -- step 13

  dspK00.P <= dspK00.A * dspK00.B;
  dspK10.P <= dspK10.A * dspK10.B;
  dspK21.P <= dspK21.A * dspK21.B;
  dspK31.P <= dspK31.A * dspK31.B;
  dspx0.A0 <= srr0( 13 ) & '1';
  dspx1.A0 <= srr0( 13 ) & '1';
  dspx2.A0 <= srr1( 13 ) & '1';
  dspx3.A0 <= srr1( 13 ) & '1';
  dspC00.A0 <= srS00( 13 ) & '1';
  dspC01.A0 <= srS01( 13 ) & '1';
  dspC11.A0 <= srS01( 13 ) & '1';
  dspC22.A0 <= srS12( 13 ) & '1';
  dspC23.A0 <= srS13( 13 ) & '1';
  dspC33.A0 <= srS13( 13 ) & '1';

  -- step 14

  dspx0.A <= dspx0.A0;
  dspx1.A <= dspx1.A0;
  dspx2.A <= dspx2.A0;
  dspx3.A <= dspx3.A0;
  dspx0.B <= K00 & '1';
  dspx1.B <= K10 & '1';
  dspx2.B <= K21 & '1';
  dspx3.B <= K31 & '1';
  dspx0.C <= state( 14 ).track.x0 & "10" & ( baseShiftx0 - shiftDspX0 - 1 downto 0 => '0' );
  dspx1.C <= state( 14 ).track.x1 & "10" & ( baseShiftx1 - shiftDspX1 - 1 downto 0 => '0' );
  dspx2.C <= state( 14 ).track.x2 & "10" & ( baseShiftx2 - shiftDspX2 - 1 downto 0 => '0' );
  dspx3.C <= state( 14 ).track.x3 & "10" & ( baseShiftx3 - shiftDspX3 - 1 downto 0 => '0' );
  dspC00.A <= dspC00.A0;
  dspC01.A <= dspC01.A0;
  dspC11.A <= dspC11.A0;
  dspC22.A <= dspC22.A0;
  dspC23.A <= dspC23.A0;
  dspC33.A <= dspC33.A0;
  dspC00.B <= K00 & '1';
  dspC01.B <= K00 & '1';
  dspC11.B <= K10 & '1';
  dspC22.B <= K21 & '1';
  dspC23.B <= K21 & '1';
  dspC33.B <= K31 & '1';
  dspC00.C <= '0' & state( 14 ).cov.C00 & "10" & ( baseShiftC00 - shiftDspC00 - 1 downto 0 => '0' );
  dspC01.C <=       state( 14 ).cov.C01 & "10" & ( baseShiftC01 - shiftDspC01 - 1 downto 0 => '0' );
  dspC11.C <= '0' & state( 14 ).cov.C11 & "10" & ( baseShiftC11 - shiftDspC11 - 1 downto 0 => '0' );
  dspC22.C <= '0' & state( 14 ).cov.C22 & "10" & ( baseShiftC22 - shiftDspC22 - 1 downto 0 => '0' );
  dspC23.C <=       state( 14 ).cov.C23 & "10" & ( baseShiftC23 - shiftDspC23 - 1 downto 0 => '0' );
  dspC33.C <= '0' & state( 14 ).cov.C33 & "10" & ( baseShiftC33 - shiftDspC33 - 1 downto 0 => '0' );

  -- step 15

  valid <= '0';
  if state( 15 ).meta.valid = '1' and state( 15 ).meta.hitsS( index ) = '1' and count( state( 15 ).meta.hitsS, 0, index ) > kfNumSeedLayer then
    valid <= '1';
  end if;
  dspx0.P <= dspx0.C + dspx0.A * dspx0.B;
  dspx1.P <= dspx1.C + dspx1.A * dspx1.B;
  dspx2.P <= dspx2.C + dspx2.A * dspx2.B;
  dspx3.P <= dspx3.C + dspx3.A * dspx3.B;
  dspC00.P <= dspC00.C - dspC00.A * dspC00.B;
  dspC01.P <= dspC01.C - dspC01.A * dspC01.B;
  dspC11.P <= dspC11.C - dspC11.A * dspC11.B;
  dspC22.P <= dspC22.C - dspC22.A * dspC22.B;
  dspC23.P <= dspC23.C - dspC23.A * dspC23.B;
  dspC33.P <= dspC33.C - dspC33.A * dspC33.B;

  -- step 16

  dout <= state( 16 );
  if valid = '1' then
    dout.track.x0 <= x0;
    dout.track.x1 <= x1;
    dout.track.x2 <= x2;
    dout.track.x3 <= x3;
    dout.cov.C00 <= C00;
    dout.cov.C01 <= C01;
    dout.cov.C11 <= C11;
    dout.cov.C22 <= C22;
    dout.cov.C23 <= C23;
    dout.cov.C33 <= C33;
    if invalidX0 or invalidX1 or invalidX2 or invalidX3 then
      dout.meta.valid <= '0';
    end if;
  end if;

end if;
end process;


end;