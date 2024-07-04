library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use work.hybrid_config.all;
use work.hybrid_tools.all;


package hybrid_data_formats is


-- DTC

constant widthDTCr    : natural := dtcWidthR;
constant widthDTCphi  : natural := dtcWidthPhi;
constant widthDTCz    : natural := dtcWidthZ;
constant widthDTClayer: natural := dtcWidthLayer;

constant widthDTCphiT : natural := width( numOverlap     );
constant widthDTCzT   : natural := width( gpNumBinsZT    );
constant widthDTCinv2R: natural := width( htNumBinsInv2R );

constant rangeDTCinv2R: real := 2.0 * invPtToDphi / minPt;
constant rangeDTCphiT : real := 2.0 * MATH_PI / real( numRegions );
constant rangeDTCcot  : real := 2.0 * maxCot;
constant rangeDTCzT   : real := 2.0 * sinh( maxEta ) * chosenRofZ;
constant rangeDTCr    : real := 2.0 * maxRphi;
constant rangeDTCphi  : real := rangeDTCphiT + maxRPhi * rangeDTCinv2R;
constant rangeDTCz    : real := 2.0 * halfLength;

constant baseInv2R: real := rangeDTCinv2R / real( htNumBinsInv2R );
constant basePhiT : real := rangeDTCphiT  / real( htNumBinsPhiT  ) / real( gpNumBinsPhiT );
constant baseZT   : real := rangeDTCzT    / real( gpNumBinsZT    );
constant baseCot  : real := ( baseZT + 2.0 * beamWindowZ ) / chosenRofZ;

constant baseShiftDTCr  : integer := ilog2( rangeDTCr   / basePhiT * baseInv2R ) - widthDTCr;
constant baseShiftDTCphi: integer := ilog2( rangeDTCphi / basePhiT             ) - widthDTCphi;
constant baseShiftDTCz  : integer := ilog2( rangeDTCz   / baseZT               ) - widthDTCz;

constant baseR  : real := basePhiT / baseInv2R * 2.0 ** baseShiftDTCr;
constant basePhi: real := basePhiT             * 2.0 ** baseShiftDTCphi;
constant baseZ  : real := baseZT               * 2.0 ** baseShiftDTCz;

constant posDTCbarrel: natural := widthDTClayer - 1;
constant posDTCpsTilt: natural := widthDTClayer - 2;

constant widthLayer: natural := width( numLayers );
constant widthZT   : natural := width( gpNumBinsZT );

-- TFP

constant widthTFPinv2R: natural := tfpWidthInv2R;
constant widthTFPphi0 : natural := tfpWidthPhi0;
constant widthTFPcot  : natural := tfpWidthCot;
constant widthTFPz0   : natural := tfpWidthZ0;

constant rangeTFPinv2R: real := rangeDTCinv2R + 2.0 * baseInv2R;
constant rangeTFPphi0 : real := rangeDTCphiT + maxRPhi * rangeTFPinv2R;
constant rangeTFPcot  : real := rangeDTCcot;
constant rangeTFPz0   : real := 2.0 * beamWindowZ;

constant baseShiftTFPinv2R: integer := ilog2( rangeTFPinv2R / baseInv2R                     ) - widthTFPinv2R;
constant baseShiftTFPphi0 : integer := ilog2( rangeTFPphi0  / basePhiT                      ) - widthTFPphi0;
constant baseShiftTFPcot  : integer := ilog2( rangeTFPcot   / baseZT * basePhiT / baseInv2R ) - widthTFPcot;
constant baseShiftTFPz0   : integer := ilog2( rangeTFPz0    / baseZT                        ) - widthTFPz0;

constant baseTFPinv2R: real := baseInv2R                     * 2.0 ** baseShiftTFPinv2R;
constant baseTFPphi0 : real := basePhiT                      * 2.0 ** baseShiftTFPphi0;
constant baseTFPcot  : real := baseZT / basePhiT * baseInv2R * 2.0 ** baseShiftTFPcot;
constant baseTFPz0   : real := baseZT                        * 2.0 ** baseShiftTFPz0;

-- IR

constant widthIRBX: natural := 3;

constant widthsIRr    : naturals( 0 to irNumStubTypes - 1 ) := (  7,  7, 12,  7 );
constant widthsIRz    : naturals( 0 to irNumStubTypes - 1 ) := ( 12,  8,  7,  7 );
constant widthsIRphi  : naturals( 0 to irNumStubTypes - 1 ) := ( 14, 17, 14, 14 );
constant widthsIRalpha: naturals( 0 to irNumStubTypes - 1 ) := (  0,  0,  0,  4 );
constant widthsIRbend : naturals( 0 to irNumStubTypes - 1 ) := (  3,  4,  3,  4 );

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
constant widthsTBr  : naturals( 0 to irNumStubTypes - 1 ) := (  7,  7, 12, 12 );
constant widthsTBphi: naturals( 0 to irNumStubTypes - 1 ) := ( 12, 12, 12, 12 );
constant widthsTBz  : naturals( 0 to irNumStubTypes - 1 ) := (  9,  9,  7,  7 );
constant widthTBstubType: natural := width( irNumStubTypes );
constant widthTBstubDiksType: natural := widthsIRr( 3 ) - widthTB2Sr;
subtype r_stubDiskType is natural range widthTBstubDiksType + widthTB2Sr + widthsTBphi( 3 ) + widthsTBz( 3 ) - 1 downto widthTB2Sr + widthsTBphi( 3 ) + widthsTBz( 3 ); 

constant baseShiftsTBr  : naturals( 0 to irNumStubTypes - 1 ) := ( 1, 1, 0, 0 );
constant baseShiftsTBphi: naturals( 0 to irNumStubTypes - 1 ) := ( 0, 0, 3, 3 );
constant baseShiftsTBz  : naturals( 0 to irNumStubTypes - 1 ) := ( 0, 4, 0, 0 );

constant widthTBtrackId: natural :=  7;
constant widthTBstubId : natural := 10;
constant widthTBr      : natural := max( widthsTBr   );
constant widthTBphi    : natural := max( widthsTBphi );
constant widthTBz      : natural := max( widthsTBz   );

-- TM

constant rangeTMphi : real := basePhiT + maxRPhi * baseInv2R;
constant rangeTMz   : real := baseZT + maxRZ * baseCot;

constant widthTMr    : natural := widthDTCr;
constant widthTMphi  : natural := width( rangeTMphi / basePhi );
constant widthTMz    : natural := width( rangeTMz   / baseZ   );
constant widthTMphiT : natural := width( htNumBinsPhiT * gpNumBinsPhiT );
constant widthTMzT   : natural := width( gpNumBinsZT    );

constant rangeTMinv2R: real := 2.0 * invPtToDphi / minPtcand;
constant widthTMinv2R: natural := width( rangeTMinv2R / baseInv2R );

constant rangeTMdPhi: real := pitchRowPS / radiusInner + ( pitchCol2S + scattering ) * rangeTMinv2R / 2.0 + basePhi;
constant rangeTMdZ  : real := pitchCol2S * sinh( maxEta ) + baseZ;

constant widthTMdPhi : natural := width( rangeTMdPhi / basePhi );
constant widthTMdZ   : natural := width( rangeTMdZ   / baseZ   );

constant widthTMstubId: natural := widthTBstubId;

-- DR

constant widthDRStubId : natural := 10;
constant widthDRLayerId: natural := 4;

constant widthDRr    : natural := widthTMr;
constant widthDRdPhi : natural := widthTMdPhi;
constant widthDRdZ   : natural := widthTMdZ;
constant widthDRphi  : natural := widthTMphi;
constant widthDRz    : natural := widthTMz;
constant widthDRinv2R: natural := widthTMinv2R;
constant widthDRphiT : natural := widthTMphiT;
constant widthDRzT   : natural := widthTMzT;

-- KF

constant widthKFdPhi : natural := widthTMdPhi;
constant widthKFdZ   : natural := widthTMdZ;
constant widthKFr    : natural := widthTMr;
constant widthKFz    : natural := widthTMz;
constant widthKFmatch: natural := kfWidthMatch;

constant baseKFinv2R: real := baseTFPinv2R * 2.0 ** kfBaseShift;
constant baseKFphiT : real := baseTFPphi0  * 2.0 ** kfBaseShift;
constant baseKFcot  : real := baseTFPcot   * 2.0 ** kfBaseShift;
constant baseKFzT   : real := baseTFPz0    * 2.0 ** kfBaseShift;

constant widthKFinv2R: natural := width( rangeTFPinv2R / baseKFinv2R );
constant widthKFphiT : natural := width( rangeDTCphiT  / baseKFphiT  );
constant widthKFcot  : natural := width( baseCot       / baseKFcot   );
constant widthKFzT   : natural := width( rangeDTCzT    / baseKFzT    );

constant rangeKFphi: real := rangeTMphi * kfRangeFactor;

constant widthKFphi: natural := width( rangeKFphi  / basePhi );


end;
