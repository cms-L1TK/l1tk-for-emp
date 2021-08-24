 
library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

use work.tfp_tools.all;
use work.tfp_config.all;


package tfp_data_formats is

-- DTC

constant widthDTCr  : natural := widthDTCr;
constant widthDTCphi: natural := widthDTCphi;
constant widthDTCz  : natural := widthDTCz;

constant widthDTCphis : natural := numOverlap;
constant widthDTCeta  : natural := width( numSectorsEta  );
constant widthDTClayer: natural := width( numLayers      );
constant widthDTCinv2R: natural := width( numBinsHTinv2R );

constant maxRphi: real := max( trackerOuterRadius - chosenRofPhi, chosenRofPhi - trackerInnerRadius );
constant maxRz  : real := max( trackerOuterRadius - chosenRofZ,   chosenRofZ   - trackerInnerRadius );

constant rangeDTCinv2R: real := 2.0 * invPtToDphi / minPt;
constant rangeDTCphiT : real := 2.0 * MATH_PI / real( numRegions ) / real( numSectorsPhi );
constant rangeDTCr    : real := 2.0 * maxRphi;
constant rangeDTCphi  : real := real( numSectorsPhi ) * rangeDTCphiT + rangeDTCr * rangeDTCinv2R / 2.0;
constant rangeDTCz    : real := 2.0 * trackerHalfLength;

constant baseDTCinv2R: real := rangeDTCinv2R / real( numBinsHTinv2R );
constant baseDTCphiT : real := rangeDTCphiT  / real( numBinsHTphiT  );

constant baseShiftDTCr  : integer := width( rangeDTCr   / baseDTCphiT * baseDTCinv2R ) - widthDTCr;
constant baseShiftDTCphi: integer := width( rangeDTCphi / baseDTCphiT                ) - widthDTCphi;
constant baseShiftDTCz  : integer := width( rangeDTCz   / baseDTCphiT * baseDTCinv2R ) - widthDTCz;

constant baseDTCr  : real := baseDTCphiT / baseDTCinv2R * 2.0 ** baseShiftDTCr;
constant baseDTCphi: real := baseDTCphiT                * 2.0 ** baseShiftDTCphi;
constant baseDTCz  : real := baseDTCphiT / baseDTCinv2R * 2.0 ** baseShiftDTCz;

-- TFP

constant widthTFPinv2R: natural := widthTFPinv2R;
constant widthTFPphi0 : natural := widthTFPphi0;
constant widthTFPcot  : natural := widthTFPcot;
constant widthTFPz0   : natural := widthTFPz0;

constant rangeTFPinv2R: real := rangeDTCinv2R;
constant rangeTFPphi0 : real := rangeDTCphi;
constant rangeTFPcot  : real := 2.0 * sinh( maxEta );
constant rangeTFPz0   : real := 2.0 * beamWindowZ;

constant baseShiftTFPpt  : integer := width( rangeTFPinv2R / baseDTCinv2R ) - widthTFPinv2R;
constant baseShiftTFPphi0: integer := width( rangeTFPphi0  / baseDTCphi   ) - widthTFPphi0;
constant baseShiftTFPcot : integer := width( rangeTFPcot   / 1.0          ) - widthTFPcot;
constant baseShiftTFPz0  : integer := width( rangeTFPz0    / baseDTCz     ) - widthTFPz0;

constant baseTFPinv2R: real := baseDTCinv2R * 2.0 ** baseShiftTFPpt;
constant baseTFPphi0 : real := baseDTCphi   * 2.0 ** baseShiftTFPphi0;
constant baseTFPcot  : real := 1.0          * 2.0 ** baseShiftTFPcot;
constant baseTFPz0   : real := baseDTCz     * 2.0 ** baseShiftTFPz0;

-- GP

constant rangeGPr    : real := rangeDTCr;
constant rangeGPphi  : real := rangeDTCphi / real( numSectorsPhi );
constant rangeGPz    : real := rangeGPz;
constant rangeGPinv2R: real := rangeDTCinv2R;

constant baseGPr    : real := baseDTCr;
constant baseGPphi  : real := baseDTCphi;
constant baseGPz    : real := baseDTCz;
constant baseGPinv2R: real := baseDTCinv2R;

constant widthGPlayer: natural := widthDTClayer;
constant widthGPr    : natural := widthDTCr;
constant widthGPphi  : natural := width( rangeGPphi / baseGPphi );
constant widthGPz    : natural := width( rangeGPz   / baseGPz   );
constant widthGPinv2R: natural := widthDTCinv2R;

-- HT

constant rangeHTphiT: real := rangeDTCphiT;
constant rangeHTr   : real := rangeGPr;
constant rangeHTphi : real := 2.0 * baseDTCphiT;
constant rangeHTz   : real := rangeGPz;

constant baseHTphiT: real := baseDTCphiT;
constant baseHTr   : real := baseGPr;
constant baseHTphi : real := baseGPphi;
constant baseHTz   : real := baseGPz;

constant widthHTsector: natural := width( numSectors    );
constant widthHTphiT  : natural := width( numBinsHTphiT );
constant widthHTlayer : natural := widthGPlayer;
constant widthHTr     : natural := widthGPr;
constant widthHTphi   : natural := width( rangeHTphi / baseHTphi );
constant widthHTz     : natural := widthGPz;

-- MHT

constant rangeMHTinv2R: real := rangeDTCinv2R;
constant rangeMHTphiT : real := rangeHTphiT;
constant rangeMHTr    : real := rangeHTr;
constant rangeMHTphi  : real := rangeHTphi / real( numBinsMHTphiT );
constant rangeMHTz    : real := rangeGPz;

constant baseMHTinv2R: real := baseDTCinv2R / real( numBinsMHTinv2R );
constant baseMHTphiT : real := baseHTphiT   / real( numBinsMHTphiT  );
constant baseMHTr    : real := baseHTr;
constant baseMHTphi  : real := baseHTphi;
constant baseMHTz    : real := baseHTz;

constant widthMHTsector: natural := widthHTsector;
constant widthMHTphiT  : natural := width( numBinsHTphiT  * numBinsMHTphiT  );
constant widthMHTinv2R : natural := width( numBinsHTinv2R * numBinsMHTinv2R );
constant widthMHTlayer : natural := widthHTlayer;
constant widthMHTr     : natural := widthHTr;
constant widthMHTphi   : natural := width( rangeMHTphi / baseMHTphi );
constant widthMHTz     : natural := widthHTz;

-- SF

constant widthSFmaybe : natural := numLayers;
constant widthSFhits  : natural := numLayers;
constant widthSFlmap  : natural := numLayers * width( numStubsPerLayer );
constant widthSFsector: natural := widthMHTsector;
constant widthSFphiT  : natural := widthMHTphiT;
constant widthSFinv2R : natural := widthMHTinv2R;
constant widthSFzT    : natural := width( numBinsSFzT );
constant widthSFcot   : natural := width( numBinsSFcot );
constant widthSFr     : natural := widthMHTr;

constant rangeSFinv2R: real := rangeMHTinv2R;
constant rangeSFphiT : real := rangeMHTphiT;
constant rangeSFcot  : real := ( rangeSFzT + rangeTFPz0 ) / chosenRofZ;
constant rangeSFzT   : real := rangeSFzT;

constant baseSFinv2R: real := baseMHTinv2R;
constant baseSFphiT : real := baseMHTphiT;

constant baseShiftSFcot: integer := width( rangeSFcot / 1.0      ) - widthSFcot;
constant baseShiftSFzT : integer := width( rangeSFzT  / baseMHTz ) - widthSFzT;

constant baseSFcot: real := 1.0      * 2.0 ** baseShiftSFcot;
constant baseSFzT : real := baseMHTz * 2.0 ** baseShiftSFzT;

constant rangeSFr   : real := rangeMHTr;
constant rangeSFphi : real := 4.0 * (baseSFphiT + baseSFinv2R * 2.0 * maxRphi + maxdPhi);
constant rangeSFz   : real := 2.0 * (baseSFzT + baseSFcot * 2.0 * maxRz + maxdZ);
constant rangeSFdPhi: real := maxdPhi;
constant rangeSFdZ  : real := maxdZ;

constant baseSFr   : real := baseMHTr;
constant baseSFphi : real := baseMHTphi;
constant baseSFz   : real := baseMHTz;
constant baseSFdPhi: real := baseMHTphi;
constant baseSFdZ  : real := baseMHTz;

constant widthSFphi : natural := width( rangeSFphi  / baseSFphi  );
constant widthSFz   : natural := width( rangeSFz    / baseSFz    );
constant widthSFdPhi: natural := width( rangeSFdPhi / baseSFdPhi );
constant widthSFdZ  : natural := width( rangeSFdZ   / baseSFdZ   );

-- KF

constant rangeKFinv2R: real := rangeSFinv2R + rangeFactor * baseSFinv2R;
constant rangeKFphiT : real := rangeSFphiT  + rangeFactor * baseSFphiT;
constant rangeKFcot  : real := rangeSFcot   + rangeFactor * baseSFcot;
constant rangeKFzT   : real := rangeSFzT    + rangeFactor * baseSFzT;
constant rangeKFr    : real := rangeSFr;
constant rangeKFphi  : real := rangeFactor * rangeSFphi;
constant rangeKFz    : real := rangeFactor * rangeSFz;

constant baseKFinv2R: real := baseTFPinv2R;
constant baseKFphiT : real := baseTFPphi0;
constant baseKFcot  : real := baseTFPcot;
constant baseKFzT   : real := baseTFPz0;
constant baseKFr    : real := baseSFr;
constant baseKFphi  : real := baseSFphi;
constant baseKFz    : real := baseSFz;
constant baseKFdPhi : real := baseSFdPhi;
constant baseKFdZ   : real := baseSFdZ;

constant widthKFinv2R: natural := width( rangeKFinv2R / baseKFinv2R );
constant widthKFphiT : natural := width( rangeKFphiT  / baseKFphiT  );
constant widthKFzT   : natural := width( rangeKFzT    / baseKFzT    );
constant widthKFcot  : natural := width( rangeKFcot   / baseKFcot   );
constant widthKFphi  : natural := width( rangeKFphi   / baseKFphi   );
constant widthKFz    : natural := width( rangeKFz     / baseKFz     );

constant widthKFhits  : natural := widthSFhits;
constant widthKFsector: natural := widthSFsector;
constant widthKFr     : natural := widthSFr;
constant widthKFdPhi  : natural := widthSFdPhi;
constant widthKFdZ    : natural := widthSFdZ;

end;
