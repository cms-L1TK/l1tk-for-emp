library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use work.hybrid_config.all;
use work.hybrid_tools.all;


package hybrid_data_formats is


-- DTC

constant widthDTCr  : natural := 12;
constant widthDTCphi: natural := 15;
constant widthDTCz  : natural := 14;

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

constant widthTFPinv2R: natural := 15; -- number of bits used to represent 1/2R
constant widthTFPphi0 : natural := 12; -- number of bits used to represent phi0 w.r.t. region center
constant widthTFPcot  : natural := 16; -- number of bits used to represent cot(Theta)
constant widthTFPz0   : natural := 12; -- number of bits used to represent z0

constant rangeTFPinv2R: real := rangeDTCinv2R;
constant rangeTFPphi0 : real := rangeDTCphi;
constant rangeTFPcot  : real := 2.0 * maxCot;
constant rangeTFPz0   : real := 2.0 * beamWindowZ;

constant baseShiftTFPpt  : integer := width( rangeTFPinv2R / baseDTCinv2R ) - widthTFPinv2R;
constant baseShiftTFPphi0: integer := width( rangeTFPphi0  / baseDTCphi   ) - widthTFPphi0;
constant baseShiftTFPcot : integer := width( rangeTFPcot   / 1.0          ) - widthTFPcot;
constant baseShiftTFPz0  : integer := width( rangeTFPz0    / baseDTCz     ) - widthTFPz0;

constant baseTFPinv2R: real := baseDTCinv2R * 2.0 ** baseShiftTFPpt;
constant baseTFPphi0 : real := baseDTCphi   * 2.0 ** baseShiftTFPphi0;
constant baseTFPcot  : real := 1.0          * 2.0 ** baseShiftTFPcot;
constant baseTFPz0   : real := baseDTCz     * 2.0 ** baseShiftTFPz0;

-- DR

constant widthDRsector: natural := width( numSectors );
constant widthDRphiT  : natural := width( numBinsHTphiT  * numBinsMHTphiT  );
constant widthDRinv2R : natural := width( numBinsHTinv2R );
constant widthDRzT    : natural := width( numBinsZHTZT  ** numStagesZHT    );
constant widthDRcot   : natural := width( numBinsZHTCot ** numStagesZHT    );
constant widthDRr     : natural := widthDTCr;
constant widthDRchi2  : natural := 64; -- TODO: choose the width
constant widthDRConsistentStubs : natural := 4; -- Tracks can have 8 stubs, i.e. at least 4 bits

constant rangeDRinv2R: real := rangeDTCinv2R;
constant rangeDRphiT : real := rangeDTCphiT;
constant rangeDRzT   : real := rangeZHTzT;
constant rangeDRcot  : real := ( rangeZHTzT + rangeTFPz0 ) / chosenRofZ;

constant baseDRinv2R: real := baseDTCinv2R;
constant baseDRphiT : real := baseDTCphiT;

constant baseShiftDRcot: integer := width( rangeDRcot / 1.0      ) - widthDRcot;
constant baseShiftDRzT : integer := width( rangeDRzT  / baseDTCz ) - widthDRzT;

constant baseDRcot: real := 1.0      * 2.0 ** baseShiftDRcot;
constant baseDRzT : real := baseDTCz * 2.0 ** baseShiftDRzT;
constant baseDRzT_new : real := 2.0 * sinh(maxEta) * chosenRofPhi / 32.0; -- gpNumBinsZT = 32 in emulation

constant rangeDRr   : real := rangeDTCr;
constant rangeDRphi : real := baseDRphiT + baseDRinv2R * maxRphi;
constant rangeDRz   : real := baseDRzT_new + (baseDRzT_new + rangeTFPz0 ) / chosenRofZ * maxRz;
constant rangeDRdPhi: real := maxdPhi;
constant rangeDRdZ  : real := maxdZ;

constant baseDRr   : real := baseDTCr;
constant baseDRphi : real := baseDTCphi;
constant baseDRz   : real := baseDTCz;
constant baseDRdPhi: real := baseDTCphi;
constant baseDRdZ  : real := baseDTCz;

constant widthDRphi   : natural := width( rangeDRphi  / baseDRphi  ); -- phi residual
constant widthDRz     : natural := width( rangeDRz    / baseDRz    ); -- z residual
constant widthDRdPhi  : natural := width( rangeDRdPhi / baseDRdPhi );
constant widthDRdZ    : natural := width( rangeDRdZ   / baseDRdZ   );
constant widthDRinvdZ : natural := widthDRdZ * 2;

constant widthDRStubId : natural := 10; -- or 7?
constant widthDRLayerId: natural := 4;

-- KF

constant rangeKFinv2R: real := rangeDRinv2R + rangeFactor * baseDRinv2R;
constant rangeKFphiT : real := rangeDRphiT  + rangeFactor * baseDRphiT;
constant rangeKFcot  : real := rangeDRcot   + rangeFactor * baseDRcot;
constant rangeKFzT   : real := rangeDRzT    + rangeFactor * baseDRzT;
constant rangeKFr    : real := rangeDRr;
constant rangeKFphi  : real := rangeFactor * rangeDRphi;
constant rangeKFz    : real := rangeFactor * rangeDRz;

constant baseKFinv2R: real := baseTFPinv2R;
constant baseKFphiT : real := baseTFPphi0;
constant baseKFcot  : real := baseTFPcot;
constant baseKFzT   : real := baseTFPz0;
constant baseKFr    : real := baseDRr;
constant baseKFphi  : real := baseDRphi;
constant baseKFz    : real := baseDRz;
constant baseKFdPhi : real := baseDRdPhi;
constant baseKFdZ   : real := baseDRdZ;

constant widthKFinv2R: natural := width( rangeKFinv2R / baseKFinv2R );
constant widthKFphiT : natural := width( rangeKFphiT  / baseKFphiT  );
constant widthKFzT   : natural := width( rangeKFzT    / baseKFzT    );
constant widthKFcot  : natural := width( rangeKFcot   / baseKFcot   );
--constant widthKFphi  : natural := width( rangeKFphi   / baseKFphi   );
--constant widthKFz    : natural := width( rangeKFz     / baseKFz     );
constant widthKFphi  : natural := widthDRphi;
constant widthKFz    : natural := widthDRz;

constant widthKFhits  : natural := numLayers;
constant widthKFsector: natural := widthDRsector;
constant widthKFr     : natural := widthDRr;
constant widthKFdPhi  : natural := widthDRdPhi;
constant widthKFdZ    : natural := widthDRdZ;

-- IR

constant widthIRBX: natural := 3;

constant widthsIRr    : naturals( 0 to numStubTypes - 1 ) := (  7,  7, 12,  7 );
constant widthsIRz    : naturals( 0 to numStubTypes - 1 ) := ( 12,  8,  7,  7 );
constant widthsIRphi  : naturals( 0 to numStubTypes - 1 ) := ( 14, 17, 14, 14 );
constant widthsIRalpha: naturals( 0 to numStubTypes - 1 ) := (  0,  0,  0,  4 );
constant widthsIRbend : naturals( 0 to numStubTypes - 1 ) := (  3,  4,  3,  4 );

constant widthIRlayer: natural:= 2;

-- TB

constant widthTBseedType: natural :=  3;
constant widthTBinv2R   : natural := 14;
constant widthTBphi0    : natural := 18;
constant widthTBz0      : natural := 10;
constant widthTBcot     : natural := 14;

constant baseShiftTBinv2R: integer :=  -9;
constant baseShiftTBphi0 : integer :=   1;
constant baseShiftTBcot  : integer := -10;
constant baseShiftTBz0   : integer :=   0;

constant widthTB2Sr: natural := 4; 
constant widthsTBr  : naturals( 0 to numStubTypes - 1 ) := (  7,  7, 12, 12 );
constant widthsTBphi: naturals( 0 to numStubTypes - 1 ) := ( 12, 12, 12, 12 );
constant widthsTBz  : naturals( 0 to numStubTypes - 1 ) := (  9,  9,  7,  7 );
constant widthTBstubType: natural := width( numStubTypes );
constant widthTBstubDiksType: natural := widthsIRr( 3 ) - widthTB2Sr;
subtype r_stubDiskType is natural range widthTBstubDiksType + widthTB2Sr + widthsTBphi( 3 ) + widthsTBz( 3 ) - 1 downto widthTB2Sr + widthsTBphi( 3 ) + widthsTBz( 3 ); 

constant baseShiftsTBr  : naturals( 0 to numStubTypes - 1 ) := ( 1, 1, 0, 0 );
constant baseShiftsTBphi: naturals( 0 to numStubTypes - 1 ) := ( 0, 0, 3, 3 );
constant baseShiftsTBz  : naturals( 0 to numStubTypes - 1 ) := ( 0, 4, 0, 0 );

constant widthTBtrackId: natural :=  7;
constant widthTBstubId : natural := 10;
constant widthTBr      : natural := max( widthsTBr   );
constant widthTBphi    : natural := max( widthsTBphi );
constant widthTBz      : natural := max( widthsTBz   );


end;
