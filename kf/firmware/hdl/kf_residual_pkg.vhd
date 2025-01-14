library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.hybrid_data_formats.all;
use work.kf_data_formats.all;


package kf_residual_pkg is


type t_inv2R is
record
  x  : std_logic_vector( widthKFinv2R - baseShiftx0 - 1 downto 0 );
  dx : std_logic_vector( widthKFinv2R - baseShiftx0 - 1 downto 0 );
  sum: std_logic_vector( widthKFinv2R - baseShiftx0 + 1 - 1 downto 0 );
end record;
function nulll return t_inv2R;
subtype r_inv2R is natural range widthKFinv2R - baseShiftx0 - 1 downto -baseShiftx0;
subtype r_inv2Rover is natural range widthKFinv2R - baseShiftx0 downto widthKFinv2R - baseShiftx0 - 1;

type t_phiT is
record
  x  : std_logic_vector( widthKFphiT - baseShiftx1 - 1 downto 0 );
  dx : std_logic_vector( widthKFphiT - baseShiftx1 - 1 downto 0 );
  sum: std_logic_vector( widthKFphiT - baseShiftx1 + 1 - 1 downto 0 );
end record;
function nulll return t_phiT;
subtype r_phiT is natural range widthKFphiT - baseShiftx1 - 1 downto -baseShiftx1;
subtype r_phiTover is natural range widthKFphiT - baseShiftx1 downto widthKFphiT - baseShiftx1 - 1 - 1;

type t_cot is
record
  x  : std_logic_vector( widthKFcot - baseShiftx2 - 1 downto 0 );
  dx : std_logic_vector( widthKFcot - baseShiftx2 - 1 downto 0 );
  sum: std_logic_vector( widthKFcot - baseShiftx2 + 1 - 1 downto 0 );
end record;
function nulll return t_cot;
subtype r_cot is natural range widthKFcot - baseShiftx2 - 1 downto -baseShiftx2;
subtype r_cotover is natural range widthKFcot - baseShiftx2 downto widthKFcot - baseShiftx2 - 1;

type t_zT is
record
  x  : std_logic_vector( widthKFzT - baseShiftx3 - 1 downto 0 );
  dx : std_logic_vector( widthKFzT - baseShiftx3 - 1 downto 0 );
  sum: std_logic_vector( widthKFzT - baseShiftx3 + 1 - 1 downto 0 );
end record;
function nulll return t_zT;
subtype r_zT is natural range widthKFzT - baseShiftx3 - 1 downto -baseShiftx3;
subtype r_zTover is natural range widthKFzT - baseShiftx3 downto widthKFzT - baseShiftx3 - 1;

constant shiftDspZ0: integer := baseShiftX2 + baseShiftH12;
constant widthDspZ0A: natural := widthX2 + 1;
constant widthDspZ0B: natural := widthH12 + 1;
constant widthDspZ0C: natural := widthX3 + 2 + baseShiftX3 - shiftDspZ0;
constant widthDspZ0P: natural := max( widthDspZ0A + widthDspZ0B, widthDspZ0C ) + 1;
type t_dspZ0 is
record
  A: std_logic_vector( widthDspZ0A - 1 downto 0 );
  B: std_logic_vector( widthDspZ0B - 1 downto 0 );
  C: std_logic_vector( widthDspZ0C - 1 downto 0 );
  P: std_logic_vector( widthDspZ0P - 1 downto 0 );
end record;
subtype r_z0over is natural range widthDspZ0P - 1 downto 2 - shiftDspZ0;

type t_cots is array ( 0 to 2 ** widthTMzT - 1 ) of std_logic_vector( widthKFcot - 1 downto 0 );
function init_cots return t_cots;
constant c_cots: t_cots;

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
  A: std_logic_vector( widthDspR0A - 1 downto 0 ); -- H00
  B: std_logic_vector( widthDspR0B - 1 downto 0 ); -- x0
  C: std_logic_vector( widthDspR0C - 1 downto 0 ); -- m0 - x1
  P: std_logic_vector( widthDspR0P - 1 downto 0 ); -- m0 - x1 - x0 * H00
end record;
subtype r_phi is natural range widthKFphi + baseShiftM0 - shiftDspR0 + 2 - 1 downto baseShiftM0 - shiftDspR0 + 2;
subtype r_overPhi is natural range widthDspR0P - 1 downto widthKFphi + baseShiftM0 - shiftDspR0 + 2 - 1;
constant widthOverPhi: natural := widthDspR0P - ( widthKFphi + baseShiftM0 - shiftDspR0 + 2 - 1 );

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
  A: std_logic_vector( widthDspR1A - 1 downto 0 ); -- H12
  B: std_logic_vector( widthDspR1B - 1 downto 0 ); -- x2
  C: std_logic_vector( widthDspR1C - 1 downto 0 ); -- m1 - x3
  P: std_logic_vector( widthDspR1P - 1 downto 0 ); -- m1 - x3 - x2 * H12
end record;
subtype r_z is natural range widthTMz + baseShiftM1 - shiftDspR1 + 2 - 1 downto baseShiftM1 - shiftDspR1 + 2;
subtype r_overZ is natural range widthDspR1P - 1 downto widthTMz + baseShiftM1 - shiftDspR1 + 2 - 1;
constant widthOverZ: natural := widthDspR1P - ( widthTMz + baseShiftM1 - shiftDspR1 + 2 - 1 );


end;



package body kf_residual_pkg is


function nulll return t_inv2R is begin return ( others => ( others => '0' ) ); end function;
function nulll return t_phiT  is begin return ( others => ( others => '0' ) ); end function;
function nulll return t_cot   is begin return ( others => ( others => '0' ) ); end function;
function nulll return t_zT    is begin return ( others => ( others => '0' ) ); end function;

function init_cots return t_cots is
  variable cots: t_cots := ( others => ( others => '0' ) );
  variable zT: real;
begin
  for k in cots'range loop
    zT := ( real( sint( stdu( k, widthTMzT ) ) ) + 0.5 ) * baseTMzT;
    cots( k ) := stds( zT / chosenRofZ, baseKFcot, widthKFcot );
  end loop;
  return cots;
end function;
constant c_cots: t_cots := init_cots;


end;