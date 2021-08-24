library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

use work.tfp_tools.all;
use work.tfp_config.all;
use work.tfp_data_formats.all;


package kf_data_formats is


constant widthTrack: natural := widthFrames;
constant widthLMap : natural := widthSFlmap;
constant widthLayer: natural := widthMHTlayer;
constant widthStubs: natural := width( numStubsPerLayer );
constant widthMaybe: natural := numLayers;
constant widthHitsT: natural := numLayers;
constant widthHits : natural := numLayers;

constant widthH00: natural := width( 2.0 * maxRPhi / baseDTCr );
constant widthH12: natural := width( 2.0 * maxRz   / baseDTCr );
constant widthm0 : natural := widthSFphi;
constant widthm1 : natural := widthSFz;
constant widthd0 : natural := widthSFdPhi;
constant widthd1 : natural := widthSFdZ;

constant baseH00: real := baseDTCr;
constant baseH12: real := baseDTCr;
constant basem0 : real := baseSFphi;
constant basem1 : real := baseSFz;
constant based0 : real := baseSFdPhi;
constant based1 : real := baseSFdZ;

constant widthx0          : natural := widthDSPb;
constant widthx1          : natural := widthDSPb;
constant widthx2          : natural := widthDSPb;
constant widthx3          : natural := widthDSPb;
constant widthr0          : natural := widthDSPb;
constant widthr1          : natural := widthDSPb;
constant widthv0          : natural := widthDSPbu;
constant widthv1          : natural := widthDSPbu;
constant widthS00         : natural := widthDSPb;
constant widthS01         : natural := widthDSPb;
constant widthS12         : natural := widthDSPb;
constant widthS13         : natural := widthDSPb;
constant widthK00         : natural := widthDSPa;
constant widthK10         : natural := widthDSPa;
constant widthK21         : natural := widthDSPa;
constant widthK31         : natural := widthDSPa;
constant widthR00         : natural := widthDSPbu;
constant widthR11         : natural := widthDSPbu;
constant widthR00Rough    : natural := widthAddrBRAM18;
constant widthR11Rough    : natural := widthAddrBRAM18;
constant widthInvR00Approx: natural := widthDSPbu;
constant widthInvR11Approx: natural := widthDSPbu;
constant widthInvR00Cor   : natural := widthDSPbu;
constant widthInvR11Cor   : natural := widthDSPbu;
constant widthInvR00      : natural := widthDSPau;
constant widthInvR11      : natural := widthDSPau;
constant widthC00         : natural := widthDSPbu;
constant widthC01         : natural := widthDSPb;
constant widthC11         : natural := widthDSPbu;
constant widthC22         : natural := widthDSPbu;
constant widthC23         : natural := widthDSPb;
constant widthC33         : natural := widthDSPbu;

constant baseShiftx0          : integer :=  -3;
constant baseShiftx1          : integer :=  -8;
constant baseShiftx2          : integer :=  -3;
constant baseShiftx3          : integer :=  -4;
constant baseShiftv0          : integer :=  -4;
constant baseShiftv1          : integer :=   8;
constant baseShiftr0          : integer :=  -8;
constant baseShiftr1          : integer :=  -2;
constant baseShiftS00         : integer :=   0;
constant baseShiftS01         : integer :=  -7;
constant baseShiftS12         : integer :=   3;
constant baseShiftS13         : integer :=   3;
constant baseShiftK00         : integer := -16;
constant baseShiftK10         : integer := -22;
constant baseShiftK21         : integer := -22;
constant baseShiftK31         : integer := -23;
constant baseShiftR00         : integer :=  -4;
constant baseShiftR11         : integer :=   7;
constant baseShiftInvR00Approx: integer := -27;
constant baseShiftInvR11Approx: integer := -38;
constant baseShiftInvR00Cor   : integer := -15;
constant baseShiftInvR11Cor   : integer := -15;
constant baseShiftInvR00      : integer := -23;
constant baseShiftInvR11      : integer := -34;
constant baseShiftC00         : integer :=   5;
constant baseShiftC01         : integer :=  -3;
constant baseShiftC11         : integer :=  -7;
constant baseShiftC22         : integer :=   3;
constant baseShiftC23         : integer :=   1;
constant baseShiftC33         : integer :=   3;

constant baseShiftR00Rough: integer := widthR00 - widthR00Rough + baseShiftR00;
constant baseShiftR11Rough: integer := widthR11 - widthR11Rough + baseShiftR11;

constant basex0          : real := 2.0 ** baseShiftx0           * baseKFinv2R;
constant basex1          : real := 2.0 ** baseShiftx1           * baseKFphiT;
constant basex2          : real := 2.0 ** baseShiftx2           * baseKFcot;
constant basex3          : real := 2.0 ** baseShiftx3           * baseKFzT; 
constant basev0          : real := 2.0 ** baseShiftv0           * baseKFphiT  * baseKFphiT;
constant basev1          : real := 2.0 ** baseShiftv1           * baseKFzT    * baseKFzT;
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


constant baseShiftH00: integer := integer( round( log2( baseH00 / baseKFphiT * baseKFinv2R ) ) );
constant baseShiftH12: integer := integer( round( log2( baseH12 / baseKFzT   * baseKFcot   ) ) );
constant baseShiftm0 : integer := integer( round( log2( basem0  / baseKFphiT               ) ) );
constant baseShiftm1 : integer := integer( round( log2( basem1  / baseKFzT                 ) ) );

constant cov_00: std_logic_vector( widthC00 - 1 downto 0 ) := stdu( integer( floor( baseSFinv2R ** 2 / baseC00 ) ), widthC00 );
constant cov_11: std_logic_vector( widthC11 - 1 downto 0 ) := stdu( integer( floor( baseSFphiT  ** 2 / baseC11 ) ), widthC11 );
constant cov_22: std_logic_vector( widthC22 - 1 downto 0 ) := stdu( integer( floor( baseSFcot   ** 2 / baseC22 ) ), widthC22 );
constant cov_33: std_logic_vector( widthC33 - 1 downto 0 ) := stdu( integer( floor( baseSFzT    ** 2 / baseC33 ) ), widthC33 );


end;
