library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.hybrid_data_formats.all;


package kfin_data_formats is


constant baseShiftUphi: integer := -17;
constant baseShiftUr  : integer := -12;
constant baseShiftUz  : integer := -11;

constant rangeUphi: real := 2.0 * MATH_PI / real( numRegions ) + invPtToDphi / minTBPt * 2.0 * maxRphi;
constant rangeUr  : real := maxDiskR;
constant rangeUz  : real := lengthZ;

constant baseUphi: real := rangeUphi * 2.0 ** baseShiftUphi;
constant baseUr  : real := rangeUr   * 2.0 ** baseShiftUr;
constant baseUz  : real := rangeUz   * 2.0 ** baseShiftUz;

constant baseShiftUinv2R: integer := baseShiftTBinv2R;
constant baseShiftUcot  : integer := baseShiftTBcot;
constant baseShiftUphiT : integer := baseShiftTBphi0;
constant baseShiftUzT   : integer := baseShiftTBz0;

constant baseUinv2R: real := baseUphi / baseUr * 2.0 ** baseShiftUinv2R;
constant baseUcot  : real := baseUz   / baseUr * 2.0 ** baseShiftUcot;
constant baseUphiT : real := baseUphi          * 2.0 ** baseShiftUphiT;
constant baseUzT   : real := baseUz            * 2.0 ** baseShiftUzT;

constant maxUphiT: real := MATH_PI / real( numRegions );
constant maxUzT  : real := sinh( maxEta ) * chosenRofZ;

constant widthUinv2R: natural := widthTBinv2R;
constant widthUcot  : natural := widthTBcot;
constant widthUphiT : natural := width( 2.0 * maxUphiT / baseUphiT );
constant widthUzT   : natural := width( 2.0 * maxUzT   / baseUzT   );

constant widthUr  : natural := width( rangeDTCr / baseUr );
constant widthUphi: natural := max( sum( widthsTBphi, baseShiftsTBphi ) );
constant widthUz  : natural := max( sum( widthsTBz,   baseShiftsTBz   ) );

constant unusedMSBScot: natural := integer( floor( log2( baseUcot * 2.0 ** widthUcot / ( 2.0 * maxCot ) ) ) );
constant baseShiftScot: integer := widthUcot - unusedMSBScot - 1 - widthAddrBRAM18;
constant baseScot: real := baseUcot * 2.0 ** baseShiftScot;

constant baseShiftSinvCot: integer := integer( ceil( log2( trackerOuterRadius / lengthZ ) ) ) - widthDSPbu;
constant baseSinvCot: real := 2.0 ** baseShiftSinvCot;

constant baseShiftHinv2R: integer := integer( floor( log2( baseUinv2R / baseZHTinv2R ) ) );
constant baseShiftHphiT : integer := integer( floor( log2( baseUphiT  / baseZHTphiT  ) ) );
constant baseShiftHcot  : integer := integer( floor( log2( baseUcot   / baseZHTcot   ) ) );
constant baseShiftHzT   : integer := integer( floor( log2( baseUzT    / baseZHTzT    ) ) );

constant baseHinv2R: real := baseZHTinv2R * 2.0 ** baseShiftHinv2R;
constant baseHphiT : real := baseZHTphiT  * 2.0 ** baseShiftHphiT;
constant baseHcot  : real := baseZHTcot   * 2.0 ** baseShiftHcot;
constant baseHzT   : real := baseZHTzT    * 2.0 ** baseShiftHzT;

constant baseTransformHinv2R: real := baseUinv2R / baseHinv2R;
constant baseTransformHphiT : real := baseUphiT  / baseHphiT;
constant baseTransformHcot  : real := baseUcot   / baseHcot;
constant baseTransformHzT   : real := baseUzT    / baseHzT;

constant baseShiftTransformHinv2R: integer := widthDSPbu - width( baseTransformHinv2R );
constant baseShiftTransformHphiT : integer := widthDSPbu - width( baseTransformHphiT  );
constant baseShiftTransformHcot  : integer := widthDSPbu - width( baseTransformHcot + 1.0e-9   );
constant baseShiftTransformHzT   : integer := widthDSPbu - width( baseTransformHzT    );

constant baseShiftHr  : integer := integer( floor( log2( baseUr   / baseZHTr   ) ) );
constant baseShiftHphi: integer := integer( floor( log2( baseUphi / baseZHTphi ) ) );
constant baseShiftHz  : integer := integer( floor( log2( baseUz   / baseZHTz   ) ) );

constant baseHr  : real := baseZHTr   * 2.0 ** baseShiftHr;
constant baseHphi: real := baseZHTphi * 2.0 ** baseShiftHphi;
constant baseHz  : real := baseZHTz   * 2.0 ** baseShiftHz;

constant baseTransformHr  : real := baseUr   / baseHr;
constant baseTransformHphi: real := baseUphi / baseHphi;
constant baseTransformHz  : real := baseUz   / baseHz;

constant baseShiftTransformHr  : integer := widthDSPbu - width( baseTransformHr   );
constant baseShiftTransformHphi: integer := widthDSPbu - width( baseTransformHphi );
constant baseShiftTransformHz  : integer := widthDSPbu - width( baseTransformHz   );

constant widthHinv2R: natural := widthUinv2R + widthDSPbu - baseShiftTransformHinv2R;
constant widthHcot  : natural := widthUcot   + widthDSPbu - baseShiftTransformHcot;
constant widthHphiT : natural := widthUphiT  + widthDSPbu - baseShiftTransformHphiT;
constant widthHzT   : natural := widthUzT    + widthDSPbu - baseShiftTransformHzT;

constant widthHr  : natural := widthUr   + widthDSPbu - baseShiftTransformHr;
constant widthHphi: natural := widthUphi + widthDSPbu - baseShiftTransformHphi;
constant widthHz  : natural := widthUz   + widthDSPbu - baseShiftTransformHz;

constant widthSinv2R: natural := widthHinv2R;
constant widthScot  : natural := widthHcot  + 1;
constant widthSphiT : natural := widthHphiT - 1;
constant widthSzT   : natural := widthHzT   + 1;

constant widthSsectorPhi: natural := width( numSectorsPhi );
constant widthSsectorEta: natural := width( numSectorsEta );

constant widthSr  : natural := widthHr;
constant widthSphi: natural := widthHphi;
constant widthSz  : natural := widthHz;

constant widthLinv2R: natural := widthZHTinv2R;
constant widthLphiT : natural := widthZHTphiT;
constant widthLcot  : natural := widthZHTcot;
constant widthLzT   : natural := widthZHTzT;

constant widthLsectorPhi: natural := widthSsectorPhi;
constant widthLsectorEta: natural := widthSsectorEta;

constant widthLr  : natural := widthZHTr;
constant widthLphi: natural := widthZHTphi;
constant widthLz  : natural := widthZHTz;

constant baseLinv2R: real := baseZHTinv2R;
constant baseLcot  : real := baseZHTcot;
constant baseLphiT : real := baseZHTphiT;
constant baseLzT   : real := baseZHTzT;
constant baseLr    : real := baseZHTr;
constant baseLphi  : real := baseZHTphi;
constant baseLz    : real := baseZHTz;

constant widtRmaybe  : natural := numLayers;
constant widthRsector: natural := widthLsectorPhi + widthLsectorEta;
constant widthRinv2R : natural := widthLinv2R;
constant widthRphiT  : natural := widthLphiT;
constant widthRcot   : natural := widthLcot;
constant widthRzT    : natural := widthLzT;
constant widthRlayer: natural := widthDTClayer;
constant widthRr    : natural := widthLr;
constant widthRphi  : natural := widthLphi;
constant widthRz    : natural := widthLz;

constant baseFinvR: real := 2.0 ** ( integer( ceil( log2( baseLr / trackerInnerRadiusTB ) ) ) - widthDspbu ) / baseLr;
constant baseShiftFz   : integer := width( baseLzT / baseLz );
constant baseShiftFcot : integer := width( baseLz / baseLR / baseLcot );
constant baseShiftFinvR: integer := width( baseHcot / baseFinvR / baseLcot / baseLr );
constant baseShiftLcot : integer := width( baseLcot / baseHcot );

constant unusedLSBFinvRr: natural := widthZHTr - widthAddrBRAM18;
constant usedMSBFcot: natural := widthAddrBRAM18 - 3;

constant baseShiftFlutCot: integer := usedMSBFcot - width( maxCot / baseLCot );

constant baseF: real := baseZHTinv2R * baseZHTr;
constant baseShiftF: integer := integer( floor( log2( baseF / baseZHTphi ) ) );
constant maxPitchOverR: real := pitchPS / trackerInnerRadiusTB;
constant widthPitchOverR: natural := width( maxPitchOverR / baseF ) + 1;
constant widthLengthZ: natural := width( maxdZ / baseZHTz );
constant widthLengthR: natural := width( length2S / baseZHTr );
constant widthFcot: natural := width( 2.0 * maxCot / baseZHTcot );

constant unusedLSBFr: natural := widthZHTr - ( widthAddrBRAM18 - 1 );


end;