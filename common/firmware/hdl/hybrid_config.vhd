library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use work.hybrid_tools.all;


package hybrid_config is


constant freqLHC            : real :=  40.0;                                -- LHC Frequency in MHz
constant freqTFP            : real := 240.0;                                -- TFP Frequency in MHz, has to be integer multiple of FreqLHC
constant magneticField      : real :=   3.81120228767395;                   -- b field in Tesla
constant speedOfLight       : real :=   2.99792458;                         -- speedOfLight in 1e8 m/s
constant trackerInnerRadius : real :=  21.8;                                -- smallest radius
constant trackerOuterRadius : real := 112.7;                                -- biggest radius
constant trackerHalfLength  : real := 270.0;                                -- biggest |z|
constant invPtToDphi        : real := magneticField * speedOfLight / 2.0E3; -- translates qOverPt [in GeV] into -1/2R [in 1/cm]
constant pitchPS            : real :=   0.01;                               -- pixel pitch of outer tracker sensors in cm
constant pitch2S            : real :=   0.009;                              -- strip pitch of outer tracker sensors in cm
constant lengthPS           : real :=   0.1467;                             -- pixel length of outer tracker sensors in cm
constant length2S           : real :=   5.025;                              -- strip length of outer tracker sensors in cm 
constant tiltApproxSlope    : real :=   0.884;                              -- In tilted barrel, grad*|z|/r + int approximates |cosTilt| + |sinTilt * cotTheta|
constant tiltApproxIntercept: real :=   0.507;                              -- In tilted barrel, grad*|z|/r + int approximates |cosTilt| + |sinTilt * cotTheta|
constant tiltUncertaintyR   : real :=   0.12;                               -- In tilted barrel, constant assumed stub radial uncertainty * sqrt(12) in cm
constant scattering         : real :=   0.131283;                           -- additional radial uncertainty in cm used to calculate stub phi residual uncertainty to take multiple scattering into account

constant tmp           : natural := 18;                                 -- time multiplexed period in number of BX
constant numFramesInfra: natural :=  6;                                 -- number of clock ticks emp infrastructure can't use for data transmission per TMP
constant numFrames     : natural := tmp * integer( freqTFP / freqLHC ); -- number of clk ticks per TMP
constant widthFrames   : natural := width( numFrames );                 -- number of bits used to represent frame number within one TMP

constant chosenRofPhi: real := 55.0;           -- offest radius used for phi sector definitionmaxRtimesMoverBend21.
constant chosenRofZ  : real := 50.0;           -- offest radius used for eta sector definition
constant minPt       : real :=  1.34;          -- minimum pt of tracks considered as reconstructable
constant beamWindowZ : real := 15.0;           -- halve lumi region in z
constant maxEta      : real :=  2.5;           -- maximum |eta| of tracks considered as reconstructable
constant maxCot      : real := sinh( maxEta ) + beamWindowZ / chosenRofZ; -- maximum |cot(theta)| of tracks considered as reconstructable 

constant mindPhi: real :=  0.0001; -- minimum representable stub phi uncertainty
constant maxdPhi: real :=  0.02;   -- maximum representable stub phi uncertainty
constant mindZ  : real :=  0.1;    -- minimum representable stub z uncertainty
constant maxdZ  : real := 30.0;    -- maximum representable stub z uncertainty

constant widthDSPportA  : natural := 27; -- native DSP port A size of used FPGA 
constant widthDSPportB  : natural := 18; -- native DSP port B size of used FPGA
constant widthDSPportC  : natural := 48; -- native DSP port C size of used FPGA
constant widthAddrBRAM36: natural :=  9; -- smallest address width of an BRAM36 configured as broadest simple dual port memory
constant widthAddrBRAM18: natural := 10; -- smallest address width of an BRAM18 configured as broadest simple dual port memory

constant widthDSPa : natural := widthDSPportA - 1; -- usbale width of DSP port A using biased signed integer
constant widthDSPb : natural := widthDSPportB - 1; -- usbale width of DSP port B using biased signed integer
constant widthDSPc : natural := widthDSPportC - 1; -- usbale width of DSP port C using biased signed integer
constant widthDSPau: natural := widthDSPa - 1;     -- usbale width of DSP port A using biased unsigned integer
constant widthDSPbu: natural := widthDSPb - 1;     -- usbale width of DSP port B using biased unsigned integer
constant widthDSPcu: natural := widthDSPc - 1;     -- usbale width of DSP port C using biased unsigned integer

-- DTC

constant numRegions      : natural :=  9;                            -- nononants or octants or etc
constant numOverlap      : natural :=  2;                            -- number of nononans a reconstructable track may cross
constant numDTCsPerRegion: natural := 24;                            -- max number of DTC per Nonant
constant numLayers       : natural :=  7;                            -- number of detector layers a reconstructable particle may cross
constant numDTCsPerTFP   : natural := numOverlap * numDTCsPerRegion; -- max number of DTC per Nonant

-- GP

constant numSectorsPhi: natural :=   2;   -- number of phi sectors within a region
constant numSectorsEta: natural :=  16;   -- number of eta sectors within a region
constant rangeGPz     : real    := 160.0; -- range of stub z residual w.r.t. sector center which needs to be covered
constant numSectors   : natural := numSectorsPhi * numSectorsEta; --total numbers of sectors within a region
constant etaBoundaries: reals( 0 to numSectorsEta ) := ( -2.50, -2.23, -1.88, -1.36, -0.90, -0.62, -0.41, -0.20, 0.0, 0.20, 0.41, 0.62, 0.90, 1.36, 1.88, 2.23, 2.50 ); -- eta boundaries defining eta sectors

-- HT

constant numBinsHTinv2R: natural := 16; -- number of bins in pt in track finding
constant numBinsHTphiT : natural := 32; -- number of bins in phiT in track finding

-- MHT

constant numBinsMHTinv2R: natural := 2; -- number of finer qOverPt bins inside HT bin
constant numBinsMHTphiT : natural := 2; -- number of finer phiT bins inside HT bin

-- ZHT

constant numBinsZHTZT    : natural := 2;
constant numBinsZHTCot   : natural := 2;
constant numStagesZHT    : natural := 5;
constant numStubsPerLayer: natural := 4;  -- cut on number of stub per layer

function init_rangeZHTzT return real;
constant rangeZHTzT: real; -- range of variable zT

function init_sectorCots return reals;
constant sectorCots: reals( numSectorsEta - 1 downto 0 );

-- PP

type t_stubTypes is ( LayerPS, Layer2S, DiskPS, Disk2S );
constant numStubTypes: natural := t_stubTypes'pos( t_stubTypes'high ) + 1;

constant numTypedStubs: naturals( 0 to numStubTypes - 1 ) := ( 
  t_stubTypes'pos( LayerPS ) => 8,
  t_stubTypes'pos( Layer2S ) => 7,
  t_stubTypes'pos( DiskPS  ) => 0,
  t_stubTypes'pos( Disk2S  ) => 0
);
constant numPPquads: natural := natural( ceil( real( sum( numTypedStubs ) ) / 4.0 ) );

-- TB

constant minTBPt : real := 2.0;   -- GeV
constant maxDiskR: real := 120.0; --cm
constant lengthZ : real := 120.0; --cm
constant trackerInnerRadiusTB: real := 19.6; --cm

constant powPhi0Shift: natural := 15;

constant numBarrelLayers: natural := 6;
constant barrelLayersRadii: reals( 0 to numBarrelLayers - 1 ) := (  24.9316,  37.1777,  52.2656,  68.7598,  86.0156, 108.3105 ); -- mean radius of outer tracker barrel layer
constant numEndcapDisks: natural := 5;
constant diskZs: reals( 0 to numEndcapDisks - 1 ) := ( 131.1914, 154.9805, 185.3320, 221.6016, 265.0195 ); -- mean z of outer tracker endcap disks
constant numEndcap2SRings: natural := 10;
type t_diskRingsRadii is array ( 0 to max( numBarrelLayers, numEndcapDisks ) - 1 ) of reals ( 0 to numEndcap2SRings - 1 );
constant endcap2SRingRaddi: t_diskRingsRadii := (                                                                 -- center radius of outer tracker endcap 2S diks strips
  ( 66.4391, 71.4391, 76.2750, 81.2750, 82.9550, 87.9550, 93.8150, 98.8150, 99.8160, 104.8160 ), -- disk 1
  ( 66.4391, 71.4391, 76.2750, 81.2750, 82.9550, 87.9550, 93.8150, 98.8150, 99.8160, 104.8160 ), -- disk 2
  ( 63.9903, 68.9903, 74.2750, 79.2750, 81.9562, 86.9562, 92.4920, 97.4920, 99.8160, 104.8160 ), -- disk 3
  ( 63.9903, 68.9903, 74.2750, 79.2750, 81.9562, 86.9562, 92.4920, 97.4920, 99.8160, 104.8160 ), -- disk 4
  ( 63.9903, 68.9903, 74.2750, 79.2750, 81.9562, 86.9562, 92.4920, 97.4920, 99.8160, 104.8160 ), -- disk 5
  others => ( others => 0.0 )
);

constant psDiskLimitR: reals( 0 to numEndcapDisks - 1 ) := ( 0 to 1 => 66.4, others => 64.55 );
constant numBarrelLayersPS: natural := 3;
constant tiltedLayerLimitsZ: reals( 0 to numBarrelLayersPS - 1 ) := ( 15.5, 24.9, 34.3 ); -- barrel layer limit z value in cm to partition into tilted and untilted region

--type t_seedTypes is ( L1L2, L2L3, L3L4, L5L6, D1D2, D3D4, L1D1, L2D1 ); -- seed types used in tracklet algorithm (position gives int value)
type t_seedTypes is ( L1L2 ); -- seed types used in tracklet algorithm (position gives int value)
constant numSeedTypes: natural := t_seedTypes'pos( t_seedTypes'high ) + 1;
constant maxNumSeedingLayer: natural := 2;                               --
type t_seedingLayers is array ( natural range <> ) of naturals( 0 to maxNumSeedingLayer - 1 ); 
constant seedTypesSeedLayers: t_seedingLayers( 0 to numSeedTypes - 1 ) := (                    -- seeding layers of seed types using default layer id [barrel: 1-6, discs: 11-15]
  t_seedTypes'pos( L1L2 ) => (  1,  2 )
--  t_seedTypes'pos( L1L2 ) => (  1,  2 ),
--  t_seedTypes'pos( L2L3 ) => (  2,  3 ),
--  t_seedTypes'pos( L3L4 ) => (  3,  4 ),
--  t_seedTypes'pos( L5L6 ) => (  5,  6 ),
--  t_seedTypes'pos( D1D2 ) => ( 11, 12 ),
--  t_seedTypes'pos( D3D4 ) => ( 13, 14 ),
--  t_seedTypes'pos( L1D1 ) => (  1, 11 ),
--  t_seedTypes'pos( L2D1 ) => (  2, 11 )
);
--constant maxNumProjectionLayers: natural := 8;                        -- max number layers a sedd type may project to
constant maxNumProjectionLayers: natural := 4;                        -- max number layers a sedd type may project to
type t_projectionLayers is array ( natural range <> ) of naturals( 0 to maxNumProjectionLayers - 1 );
constant seedTypesProjectionLayers: t_projectionLayers( 0 to numSeedTypes - 1 ) := (           -- layers a seed types can project to using default layer id [barrel: 1-6, discs: 11-15]
  t_seedTypes'pos( L1L2 ) => (  3,  4,  5,  6, others => 0 )
--  t_seedTypes'pos( L1L2 ) => (  3,  4,  5,  6, 11, 12, 13, 14, others => 0 ),
--  t_seedTypes'pos( L2L3 ) => (  1,  4,  5,  6, 11, 12, 13, 14, others => 0 ),
--  t_seedTypes'pos( L3L4 ) => (  1,  2,  5,  6, 11, 12,         others => 0 ),
--  t_seedTypes'pos( L5L6 ) => (  1,  2,  3,  4,                 others => 0 ),
--  t_seedTypes'pos( D1D2 ) => (  1,  2, 13, 14, 15,             others => 0 ),
--  t_seedTypes'pos( D3D4 ) => (  1, 11, 12, 15,                 others => 0 ),
--  t_seedTypes'pos( L1D1 ) => ( 12, 13, 14, 15,                 others => 0 ),
--  t_seedTypes'pos( L2D1 ) => (  1, 12, 13, 14,                 others => 0 )
);
constant maxNumLayers: natural := maxNumSeedingLayer + maxNumProjectionLayers;
function init_numsProjectionLayers return naturals;
constant numsProjectionLayers: naturals( 0 to numSeedTypes - 1 );
function init_limitsChannelTB return naturals;
constant limitsChannelTB: naturals( 0 to numSeedTypes );

constant numLinksTB: natural := 1 + maxNumProjectionLayers;

-- KF

constant rangeFactor: real    := 2.0; -- search window of each track parameter in initial uncertainties
constant minLayersKF: natural := 4;   -- required number of stub layers to form a track
constant maxLayersKF: natural := 7;   -- maximum number of  layers added to a track
constant numNodesKF : natural := numSeedTypes;   -- number of KF workes

-- TFP

constant numLinksTFP: natural := 2;


end;



package body hybrid_config is


function init_rangeZHTzT return real is
    variable res: real := -1.0;
begin
    for k in 0 to numSectorsEta - 1 loop
        res := max( res, sinh( etaBoundaries( k + 1 ) ) - sinh( etaBoundaries( k ) ) );
    end loop;
    res := res * chosenRofZ;
    return res;
end function;
constant rangeZHTzT: real := init_rangeZHTzT;

function init_sectorCots return reals is
  variable res: reals( numSectorsEta - 1 downto 0 );
begin
  for k in res'range loop
    res( k ) := ( sinh( etaBoundaries( k + 1 ) ) + sinh( etaBoundaries( k ) ) ) / 2.0;
  end loop;
  return res;
end function;
constant sectorCots: reals( numSectorsEta - 1 downto 0 ) := init_sectorCots;

function init_numsProjectionLayers return naturals is
  variable res: naturals( 0 to numSeedTypes - 1 ) := ( others => 0 );
  variable layers: naturals( 0 to maxNumProjectionLayers - 1 );
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
constant numsProjectionLayers: naturals( 0 to numSeedTypes - 1 ) := init_numsProjectionLayers;

function init_limitsChannelTB return naturals is
  variable limits: naturals( 0 to numSeedTypes ) := ( others => 0 );
begin
  for k in 0 to numSeedTypes - 1 loop
    limits( k + 1 ) := limits( k ) + numsProjectionLayers( k ) + 1;
  end loop;
  return limits;
end function;
constant limitsChannelTB: naturals( 0 to numSeedTypes ) := init_limitsChannelTB;


end;
