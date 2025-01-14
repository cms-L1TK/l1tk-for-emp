library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.hybrid_data_formats.all;


package kf_data_formats is


constant widthTrack: natural := dramWidthAddr;
constant widthHits : natural := numLayers;

constant widthH00: natural := width( 2.0 * maxRPhi / baseTMr );
constant widthH12: natural := width( 2.0 * maxRz   / baseTMr );
constant widthm0 : natural := widthDRphi;
constant widthm1 : natural := widthDRz;
constant widthd0 : natural := widthDRdPhi;
constant widthd1 : natural := widthDRdZ;

constant baseH00: real := baseTMr;
constant baseH12: real := baseTMr;
constant basem0 : real := baseTMphi;
constant basem1 : real := baseTMz;
constant based0 : real := baseTMphi;
constant based1 : real := baseTMz;

constant baseShift0: integer := ilog2( baseTMinv2R / baseKFinv2R );
constant baseShift1: integer := ilog2( baseTMphiT  / baseKFphiT  );
constant baseShift2: integer := ilog2( baseTMcot   / baseKFcot   );
constant baseShift3: integer := ilog2( baseTMzT    / baseKFzT    );

constant widthx0          : natural := dspWidthB;
constant widthx1          : natural := dspWidthB;
constant widthx2          : natural := dspWidthB;
constant widthx3          : natural := dspWidthB;
constant widthr0          : natural := dspWidthB;
constant widthr1          : natural := dspWidthB;
constant widthr02         : natural := dspWidthBu;
constant widthr12         : natural := dspWidthBu;
constant widthS00         : natural := dspWidthA;
constant widthS01         : natural := dspWidthA;
constant widthS12         : natural := dspWidthA;
constant widthS13         : natural := dspWidthA;
constant widthS00Shifted  : natural := dspWidthA;
constant widthS01Shifted  : natural := dspWidthA;
constant widthS12Shifted  : natural := dspWidthA;
constant widthS13Shifted  : natural := dspWidthA;
constant widthK00         : natural := dspWidthB;
constant widthK10         : natural := dspWidthB;
constant widthK21         : natural := dspWidthB;
constant widthK31         : natural := dspWidthB;
constant widthR00         : natural := 20;
constant widthR11         : natural := 20;
constant widthR00Rough    : natural := bram18WidthAddr;
constant widthR11Rough    : natural := bram18WidthAddr;
constant widthInvR00Approx: natural := dspWidthBu;
constant widthInvR11Approx: natural := dspWidthBu;
constant widthInvR00Cor   : natural := dspWidthAu;
constant widthInvR11Cor   : natural := dspWidthAu;
constant widthInvR00      : natural := dspWidthBu;
constant widthInvR11      : natural := dspWidthBu;
constant widthC00         : natural := 20;
constant widthC01         : natural := 20;
constant widthC11         : natural := 20;
constant widthC22         : natural := 20;
constant widthC23         : natural := 20;
constant widthC33         : natural := 20;

constant baseShiftx0          : integer :=  -2;
constant baseShiftx1          : integer :=  -8;
constant baseShiftx2          : integer :=  -1;
constant baseShiftx3          : integer :=  -1;

constant baseShiftr0          : integer :=  -9;
constant baseShiftr1          : integer :=   0;

constant baseShiftS00         : integer :=  -4;
constant baseShiftS01         : integer := -12;
constant baseShiftS12         : integer :=   0;
constant baseShiftS13         : integer :=  -1;

constant baseShiftR00         : integer :=  -5;
constant baseShiftR11         : integer :=   6;

constant baseShiftInvR00Approx: integer := -30;
constant baseShiftInvR11Approx: integer := -41;
constant baseShiftInvR00Cor   : integer := -24;
constant baseShiftInvR11Cor   : integer := -24;
constant baseShiftInvR00      : integer := -30;
constant baseShiftInvR11      : integer := -41;

constant baseShiftS00Shifted  : integer :=  -1;
constant baseShiftS01Shifted  : integer :=  -7;
constant baseShiftS12Shifted  : integer :=   4;
constant baseShiftS13Shifted  : integer :=   4;

constant baseShiftK00         : integer :=  -7;
constant baseShiftK10         : integer := -13;
constant baseShiftK21         : integer := -13;
constant baseShiftK31         : integer := -13;

constant baseShiftC00         : integer :=   6;
constant baseShiftC01         : integer :=   1;
constant baseShiftC11         : integer :=  -6;
constant baseShiftC22         : integer :=   5;
constant baseShiftC23         : integer :=   6;
constant baseShiftC33         : integer :=   5;

constant baseShiftR00Rough: integer := widthR00 - widthR00Rough + baseShiftR00 - 1;
constant baseShiftR11Rough: integer := widthR11 - widthR11Rough + baseShiftR11 - 1;

constant basex0          : real := 2.0 ** baseShiftx0           * baseKFinv2R;
constant basex1          : real := 2.0 ** baseShiftx1           * baseKFphiT;
constant basex2          : real := 2.0 ** baseShiftx2           * baseKFcot;
constant basex3          : real := 2.0 ** baseShiftx3           * baseKFzT; 
constant baser0          : real := 2.0 ** baseShiftr0           * baseKFphiT;
constant baser1          : real := 2.0 ** baseShiftr1           * baseKFzT;
constant baseS00         : real := 2.0 ** baseShiftS00          * baseKFinv2R * baseKFphiT;
constant baseS01         : real := 2.0 ** baseShiftS01          * baseKFphiT  * baseKFphiT;
constant baseS12         : real := 2.0 ** baseShiftS12          * baseKFcot   * baseKFzT;
constant baseS13         : real := 2.0 ** baseShiftS13          * baseKFzT    * baseKFzT;
constant baseK00         : real := 2.0 ** baseShiftK00          * baseKFinv2R / baseKFphiT;
constant baseK10         : real := 2.0 ** baseShiftK10          * 1.0;
constant baseK21         : real := 2.0 ** baseShiftK21          * baseKFcot   / baseKFzT;
constant baseK31         : real := 2.0 ** baseShiftK31          * 1.0;
constant baseR00         : real := 2.0 ** baseShiftR00          * baseKFphiT  * baseKFphiT;
constant baseR11         : real := 2.0 ** baseShiftR11          * baseKFzT    * baseKFzT;
constant baseInvR00Approx: real := 2.0 ** baseShiftInvR00Approx / baseKFphiT  / baseKFphiT;
constant baseInvR11Approx: real := 2.0 ** baseShiftInvR11Approx / baseKFzT    / baseKFzT;
constant baseR00Rough    : real := 2.0 ** baseShiftR00Rough     * baseKFphiT  * baseKFphiT;
constant baseR11Rough    : real := 2.0 ** baseShiftR11Rough     * baseKFzT    * baseKFzT;
constant baseInvR00Cor   : real := 2.0 ** baseShiftInvR00Cor    * 1.0;
constant baseInvR11Cor   : real := 2.0 ** baseShiftInvR11Cor    * 1.0;
constant baseInvR00      : real := 2.0 ** baseShiftInvR00       / baseKFphiT  / baseKFphiT;
constant baseInvR11      : real := 2.0 ** baseShiftInvR11       / baseKFzT    / baseKFzT;
constant baseC00         : real := 2.0 ** baseShiftC00          * baseKFinv2R * baseKFinv2R;
constant baseC01         : real := 2.0 ** baseShiftC01          * baseKFinv2R * baseKFphiT;
constant baseC11         : real := 2.0 ** baseShiftC11          * baseKFphiT  * baseKFphiT;
constant baseC22         : real := 2.0 ** baseShiftC22          * baseKFcot   * baseKFcot;
constant baseC23         : real := 2.0 ** baseShiftC23          * baseKFcot   * baseKFzT;
constant baseC33         : real := 2.0 ** baseShiftC33          * baseKFzT    * baseKFzT;

constant basev0 : real := baseS01;
constant basev1 : real := baseS13;
constant rangev0: real := 4.0 * rangeTMdPhi * rangeTMdPhi;
constant rangev1: real := 4.0 * rangeTMdZ * rangeTMdZ;
constant widthv0 : natural := width( rangev0 / basev0 );
constant widthv1 : natural := width( rangev1 / basev1 );

constant baseShiftH00: integer := ilog2( baseH00 / baseKFphiT * baseKFinv2R );
constant baseShiftH12: integer := ilog2( baseH12 / baseKFzT   * baseKFcot   );
constant baseShiftm0 : integer := ilog2( basem0  / baseKFphiT               );
constant baseShiftm1 : integer := ilog2( basem1  / baseKFzT                 );

function f_H12( H00: std_logic_vector ) return std_logic_vector;


end;



package body kf_data_formats is


function f_H12( H00: std_logic_vector ) return std_logic_vector is
  variable H12: std_logic_vector( 1 + widthH12 + 1 - 1 downto 0 ) := ( H00 & '1' ) + stds( chosenRofPhi - chosenRofZ, baseTMr / 2.0, widthH00 );
begin
  return H12( widthH12 + 1 - 1 downto 1 );
end function;


end;
