library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use work.hybrid_tools.all;


package hybrid_config is


constant freqLHC         : real :=  40.0;                                -- LHC Frequency in MHz
constant freqTFP         : real := 360.0;                                -- TFP Frequency in MHz, has to be integer multiple of FreqLHC
constant freqTFPlow      : real := 240.0;                                -- TFP Frequency in MHz, has to be integer multiple of FreqLHC
constant magneticField   : real :=   3.81120228767395;                   -- b field in Tesla
constant speedOfLight    : real :=   2.99792458;                         -- speedOfLight in 1e8 m/s
constant radiusInner     : real :=  21.8;                                -- smallest radius
constant radiusOuter     : real := 112.7;                                -- biggest radius
constant radiusPS        : real :=  60.0;                                -- transition radius from PS tp 2S modules
constant halfLength      : real := 270.0;                                -- biggest |z|
constant halfLengthBarrel: real := 120.0;                                -- half lengt of outer tracker barrel
constant pitchRow2S      : real :=   0.009;                              -- strip pitch of outer tracker sensors in cm
constant pitchRowPS      : real :=   0.01;                               -- pixel pitch of outer tracker sensors in cm
constant pitchCol2S      : real :=   5.025;                              -- strip length of outer tracker sensors in cm
constant pitchColPS      : real :=   0.1467;                             -- pixel length of outer tracker sensors in cm
constant lengthTilt      : real :=   0.12;                               -- In tilted barrel, constant assumed stub radial uncertainty * sqrt(12) in cm
constant scattering      : real :=   0.131283;                           -- additional radial uncertainty in cm used to calculate stub phi residual uncertainty to take multiple scattering into account
constant approxSlope     : real :=   0.884;                              -- In tilted barrel, grad*|z|/r + int approximates |cosTilt| + |sinTilt * cotTheta|
constant approxIntercept : real :=   0.507;                              -- In tilted barrel, grad*|z|/r + int approximates |cosTilt| + |sinTilt * cotTheta|
constant invPtToDphi     : real := magneticField * speedOfLight / 2.0E3; -- translates qOverPt [in GeV] into -1/2R [in 1/cm]

constant tmp           : natural := 18;                                    -- time multiplexed period in number of BX
constant numFramesInfra: natural :=  6;                                    -- number of clock ticks emp infrastructure can't use for data transmission per TMP
constant numFrames     : natural := tmp * integer( freqTFP / freqLHC );    -- number of clk ticks per TMP
constant widthFrames   : natural := width( numFrames );                    -- number of bits used to represent frame number within one TMP
constant numFramesLow  : natural := tmp * integer( freqTFPlow / freqLHC ); -- number of clk ticks per TMP
constant widthFramesLow: natural := width( numFramesLow );                 -- number of bits used to represent frame number within one TMP

constant chosenRofPhi: real := 55.0;           -- offest radius used for phi sector definitionmaxRtimesMoverBend21.
constant chosenRofZ  : real := 57.76;          -- offest radius used for eta sector definition
constant minPt       : real :=  2.0;           -- minimum pt of tracks in GeV considered as reconstructable
constant minPtCand   : real :=  1.34;          -- minimum pt of tracks in GeV delivered by TrackBuilder
constant beamWindowZ : real := 15.0;           -- halve lumi region in z
constant maxEta      : real :=  2.5;           -- maximum |eta| of tracks considered as reconstructable
constant maxCot      : real := sinh( maxEta ) + beamWindowZ / chosenRofZ; -- maximum |cot(theta)| of tracks considered as reconstructable 
constant maxRphi     : real := max( radiusOuter - chosenRofPhi, chosenRofPhi - radiusInner );
constant maxRz       : real := max( radiusOuter - chosenRofZ,   chosenRofZ   - radiusInner );

constant dspWidthPortA  : natural := 27; -- native DSP port A size of used FPGA 
constant dspWidthPortB  : natural := 18; -- native DSP port B size of used FPGA
constant dspWidthPortC  : natural := 48; -- native DSP port C size of used FPGA
constant bram36WidthAddr: natural :=  9; -- smallest address width of an BRAM36 configured as broadest simple dual port memory
constant bram18WidthAddr: natural := 10; -- smallest address width of an BRAM18 configured as broadest simple dual port memory
constant dramWidthAddr  : natural :=  6; -- 

constant dspWidthA : natural := dspWidthPortA - 1; -- usbale width of DSP port A using biased signed integer
constant dspWidthB : natural := dspWidthPortB - 1; -- usbale width of DSP port B using biased signed integer
constant dspWidthC : natural := dspWidthPortC - 1; -- usbale width of DSP port C using biased signed integer
constant dspWidthAu: natural := dspWidthA - 1;     -- usbale width of DSP port A using biased unsigned integer
constant dspWidthBu: natural := dspWidthB - 1;     -- usbale width of DSP port B using biased unsigned integer
constant dspWidthCu: natural := dspWidthC - 1;     -- usbale width of DSP port C using biased unsigned integer

-- DTC

constant numRegions      : natural :=  9;                            -- nononants or octants or etc
constant numOverlap      : natural :=  2;                            -- number of nononans a reconstructable track may cross
constant numDTCsPerRegion: natural := 24;                            -- max number of DTC per Nonant
constant numLayers       : natural :=  8;                            -- number of detector layers a reconstructable particle may cross
constant numDTCsPerTFP   : natural := numOverlap * numDTCsPerRegion; -- max number of DTC per Nonant

constant dtcWidthR       : natural := 12;                            -- number of bits used to represent r w.r.t. chosenRofPhi
constant dtcWidthPhi     : natural := 15;                            -- number of bits used to represent phi w.r.t. phi sector center
constant dtcWidthZ       : natural := 14;                            -- number of bits used to represent gloabl z

-- TFP

constant tfpNumLinks: natural := 2;

constant tfpWidthInv2R: natural := 15; -- number of bits used to represent 1/2R
constant tfpWidthPhi0 : natural := 12; -- number of bits used to represent phi0 w.r.t. region center
constant tfpWidthCot  : natural := 16; -- number of bits used to represent cot(Theta)
constant tfpWidthZ0   : natural := 12; -- number of bits used to represent z0

constant tfpRangeInv2R: real := 1.0 * 0.006;
constant tfpRangePhi0 : real := 2.0 * 0.7853981696;
constant tfpRangeCot  : real := 2.0 * 8.0;
constant tfpRangeZ0   : real := 2.0 * 20.46912512;

-- IR

type t_stubTypes is ( LayerPS, Layer2S, DiskPS, Disk2S );
constant irNumStubTypes: natural := t_stubTypes'pos( t_stubTypes'high ) + 1;

constant irNumTypedStubs: naturals( 0 to irNumStubTypes - 1 ) := ( 
  t_stubTypes'pos( LayerPS ) => 8,
  t_stubTypes'pos( Layer2S ) => 7,
  t_stubTypes'pos( DiskPS  ) => 0,
  t_stubTypes'pos( Disk2S  ) => 0
);
constant irNumQuads: natural := natural( ceil( real( sum( irNumTypedStubs ) ) / 4.0 ) );

constant widthIRBX: natural := 3;
constant widthsIRr    : naturals( 0 to irNumStubTypes - 1 ) := (  7,  7, 12,  7 );
constant widthsIRz    : naturals( 0 to irNumStubTypes - 1 ) := ( 12,  8,  7,  7 );
constant widthsIRphi  : naturals( 0 to irNumStubTypes - 1 ) := ( 14, 17, 14, 14 );
constant widthsIRalpha: naturals( 0 to irNumStubTypes - 1 ) := (  0,  0,  0,  4 );
constant widthsIRbend : naturals( 0 to irNumStubTypes - 1 ) := (  3,  4,  3,  4 );
constant widthIRlayer: natural:= 2;

-- GP

constant gpNumBinsPhiT: natural :=  2;   -- number of phi sectors within a region
constant gpNumBinsZT  : natural := 32;   -- number of eta sectors within a region

-- HT

constant htNumBinsInv2R: natural := 16; -- number of bins in pt in track finding
constant htNumBinsPhiT : natural := 32; -- number of bins in phiT in track finding

-- TB

constant tbLatency: natural := 22; -- in 360 MHz clock ticks
constant tbMaxDiskR   : real := 120.0; --cm
constant tbLengthZ    : real := 120.0; --cm
constant tbInnerRadius: real :=  19.6; --cm

constant tbPowPhi0Shift: natural := 15;

constant tbNumBarrelLayers: natural := 6;
constant tbBarrelLayersRadii: reals( 0 to tbNumBarrelLayers - 1 ) := (  24.9316,  37.1777,  52.2656,  68.7598,  86.0156, 108.3105 ); -- mean radius of outer tracker barrel layer
constant tbNumEndcapDisks: natural := 5;
constant tbDiskZs: reals( 0 to tbNumEndcapDisks - 1 ) := ( 131.1914, 154.9805, 185.3320, 221.6016, 265.0195 ); -- mean z of outer tracker endcap disks
constant tbNumEndcap2SRings: natural := 10;
type t_diskRingsRadii is array ( 0 to tbNumEndcapDisks - 1 ) of reals ( 0 to tbNumEndcap2SRings - 1 );
constant tbEndcap2SRingRaddi: t_diskRingsRadii := (                                                                 -- center radius of outer tracker endcap 2S diks strips
  ( 66.4391, 71.4391, 76.2750, 81.2750, 82.9550, 87.9550, 93.8150, 98.8150, 99.8160, 104.8160 ), -- disk 1
  ( 66.4391, 71.4391, 76.2750, 81.2750, 82.9550, 87.9550, 93.8150, 98.8150, 99.8160, 104.8160 ), -- disk 2
  ( 63.9903, 68.9903, 74.2750, 79.2750, 81.9562, 86.9562, 92.4920, 97.4920, 99.8160, 104.8160 ), -- disk 3
  ( 63.9903, 68.9903, 74.2750, 79.2750, 81.9562, 86.9562, 92.4920, 97.4920, 99.8160, 104.8160 ), -- disk 4
  ( 63.9903, 68.9903, 74.2750, 79.2750, 81.9562, 86.9562, 92.4920, 97.4920, 99.8160, 104.8160 )  -- disk 5
);

constant tbPSDiskLimitR: reals( 0 to tbNumEndcapDisks - 1 ) := ( 0 to 1 => 66.4, others => 64.55 );
constant tbNumBarrelLayersPS: natural := 3;
constant tbTiltedLayerLimitsZ: reals( 0 to tbNumBarrelLayersPS - 1 ) := ( 15.5, 24.9, 34.3 ); -- barrel layer limit z value in cm to partition into tilted and untilted region

type t_seedTypes is ( L1L2, L2L3, L3L4, L5L6, D1D2, D3D4, L1D1, L2D1 ); -- seed types used in tracklet algorithm (position gives int value)
constant tbNumSeedTypes: natural := t_seedTypes'pos( t_seedTypes'high ) + 1;
constant tbMaxNumSeedingLayer: natural := 2;                               --
type t_seedingLayers is array ( natural range <> ) of naturals( 0 to tbMaxNumSeedingLayer - 1 ); 
constant seedTypesSeedLayers: t_seedingLayers( 0 to tbNumSeedTypes - 1 ) := (                    -- seeding layers of seed types using default layer id [barrel: 1-6, discs: 11-15]
  t_seedTypes'pos( L1L2 ) => (  1,  2 ),
  t_seedTypes'pos( L2L3 ) => (  2,  3 ),
  t_seedTypes'pos( L3L4 ) => (  3,  4 ),
  t_seedTypes'pos( L5L6 ) => (  5,  6 ),
  t_seedTypes'pos( D1D2 ) => ( 11, 12 ),
  t_seedTypes'pos( D3D4 ) => ( 13, 14 ),
  t_seedTypes'pos( L1D1 ) => (  1, 11 ),
  t_seedTypes'pos( L2D1 ) => (  2, 11 )
);
constant tbMaxNumProjectionLayers: natural := 8; -- max number layers a sedd type may project to
type t_projectionLayers is array ( natural range <> ) of naturals( 0 to tbMaxNumProjectionLayers - 1 );
constant seedTypesProjectionLayers: t_projectionLayers( 0 to tbNumSeedTypes - 1 ) := (           -- layers a seed types can project to using default layer id [barrel: 1-6, discs: 11-15]
  t_seedTypes'pos( L1L2 ) => (  3,  4,  5,  6, 11, 12, 13, 14, others => 0 ),
  t_seedTypes'pos( L2L3 ) => (  1,  4,  5,  6, 11, 12, 13, 14, others => 0 ),
  t_seedTypes'pos( L3L4 ) => (  1,  2,  5,  6, 11, 12,         others => 0 ),
  t_seedTypes'pos( L5L6 ) => (  1,  2,  3,  4,                 others => 0 ),
  t_seedTypes'pos( D1D2 ) => (  1,  2, 13, 14, 15,             others => 0 ),
  t_seedTypes'pos( D3D4 ) => (  1, 11, 12, 15,                 others => 0 ),
  t_seedTypes'pos( L1D1 ) => ( 12, 13, 14, 15,                 others => 0 ),
  t_seedTypes'pos( L2D1 ) => (  1, 12, 13, 14,                 others => 0 )
);
constant tbNumLayers: natural := tbMaxNumSeedingLayer + tbMaxNumProjectionLayers;
function init_numsProjectionLayers return naturals;
constant tbNumsProjectionLayers: naturals( 0 to tbNumSeedTypes - 1 );
function init_limitsChannelTB return naturals;
constant tbLimitsChannel: naturals( 0 to tbNumSeedTypes );

constant tbNumLinks: natural := 1 + tbMaxNumProjectionLayers + tbMaxNumSeedingLayer;


constant widthTBTrackId : natural :=  7;
constant widthTBStubId  : natural := 10;
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

constant widthTBr      : natural := max( widthsTBr   );
constant widthTBphi    : natural := max( widthsTBphi );
constant widthTBz      : natural := max( widthsTBz   );

-- TM

constant tmNumLayers: natural := 11;
constant tmNumNodes : natural := 1;
constant tmNumLinks : natural := 1 + tmNumLayers;

-- DR

constant drNumLinks            : natural := 1 + numLayers;
constant drMinSharedStubs      : natural :=  3;
constant drNumComparisonModules: natural := 32;

constant layerIds: naturals( 0 to tmNumLayers - 1 ) := ( 1, 2, 3, 4, 5, 6, 11, 12, 13, 14, 15 );
type t_layerEncodings is array ( 0 to gpNumBinsZT / 2 - 1 ) of naturals( 0 to numLayers - 1 );
constant layerEncodings: t_layerEncodings := (
  ( 1,  2,  3,  4,  5,  6,   0,  0 ), --  0
  ( 1,  2,  3,  4,  5,  6,   0,  0 ), --  1
  ( 1,  2,  3,  4,  5,  6,  11,  0 ), --  2
  ( 1,  2,  3,  4,  5,  6,  11, 12 ), --  3
  ( 1,  2,  3,  4,  11, 12, 13,  0 ), --  4
  ( 1,  2,  3,  11, 12, 13, 14,  0 ), --  5
  ( 1,  2,  3,  11, 12, 13, 14, 15 ), --  6
  ( 1,  2,  11, 12, 13, 14, 15,  0 ), --  7
  ( 1,  2,  11, 12, 13, 14, 15,  0 ), --  8
  ( 1,  2,  11, 12, 13, 14, 15,  0 ), --  9
  ( 1,  11, 12, 13, 14, 15,  0,  0 ), -- 10
  ( 1,  11, 12, 13, 14, 15,  0,  0 ), -- 11
  ( 1,  11, 12, 13, 14, 15,  0,  0 ), -- 12
  ( 1,  11, 12, 13, 14, 15,  0,  0 ), -- 13
  ( 1,  11, 12, 13, 14, 15,  0,  0 ), -- 14
  ( 11, 12, 13, 14, 15,  0,  0,  0 )  -- 15
);

-- KF

constant kfNumNodes     : natural :=  tmNumNodes; -- number of KF inputs
constant kfNumSeedLayer : natural :=  2;          -- number of layer building seed
constant kfMaxSeedLayer : natural :=  4;          -- n first layer to seed in
constant kfMinSeedDeltaR: real    :=  1.6;
constant kfBaseShift    : integer := -1;          -- kf bases are shifted by that power of 2 wrt tfp bases
constant kfMinStubs     : natural :=  4;          -- minimum number of layers added to a track
constant kfMaxStubs     : natural :=  8;          -- maximum number of layers added to a track
constant kfRangeFactor  : real    := 3.0;


end;



package body hybrid_config is




function init_numsProjectionLayers return naturals is
  variable res: naturals( 0 to tbNumSeedTypes - 1 ) := ( others => 0 );
  variable layers: naturals( 0 to tbMaxNumProjectionLayers - 1 );
begin
  for k in seedTypesProjectionLayers'range loop
    layers := seedTypesProjectionLayers( k );
    for l in layers'range loop
      if layers( l ) /= 0 then
        res( k ) := res( k ) + 1;
      end if;
    end loop;
  end loop;
  return res;
end function;
constant tbNumsProjectionLayers: naturals( 0 to tbNumSeedTypes - 1 ) := init_numsProjectionLayers;

function init_limitsChannelTB return naturals is
  variable limits: naturals( 0 to tbNumSeedTypes ) := ( others => 0 );
begin
  for k in 0 to tbNumSeedTypes - 1 loop
    limits( k + 1 ) := limits( k ) + tbNumsProjectionLayers( k ) + tbMaxNumSeedingLayer + 1;
  end loop;
  return limits;
end function;
constant tbLimitsChannel: naturals( 0 to tbNumSeedTypes ) := init_limitsChannelTB;


end;
