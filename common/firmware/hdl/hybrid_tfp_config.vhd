library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

use work.emp_device_decl.all;
use work.emp_data_types.all;

use work.tfp_tools.all;


package tfp_config is

constant freqLHC           : real :=  40.0;                                -- LHC Frequency in MHz
constant freqTFP           : real := 360.0;                                -- TFP Frequency in MHz, has to be integer multiple of FreqLHC
constant magneticField     : real :=   3.81120228767395;                   -- b field in Tesla
constant speedOfLight      : real :=   2.99792458;                         -- speedOfLight in 1e8 m/s
constant trackerInnerRadius: real :=  21.8;                                -- smallest radius
constant trackerOuterRadius: real := 112.7;                                -- biggest radius
constant trackerHalfLength : real := 270.0;                                -- biggest |z|
constant invPtToDphi       : real := magneticField * speedOfLight / 2.0E3; -- translates qOverPt [in GeV] into -1/2R [in 1/cm]

constant tmp           : natural := 18;                                 -- time multiplexed period in number of BX
constant numFramesInfra: natural :=  6;                                 -- number of clock ticks emp infrastructure can't use for data transmission per TMP
constant numFrames     : natural := tmp * integer( freqTFP / freqLHC ); -- number of clk ticks per TMP
constant widthFrames   : natural := width( numFrames );                 -- number of bits used to represent frame number within one TMP

constant chosenRofPhi: real := 55.0;           -- offest radius used for phi sector definitionmaxRtimesMoverBend21.
constant chosenRofZ  : real := 50.0;           -- offest radius used for eta sector definition
constant minPt       : real :=  1.34;          -- minimum pt of tracks considered as reconstructable
constant beamWindowZ : real := 15.0;           -- halve lumi region in z
constant maxEta      : real :=  2.5;           -- maximum |eta| of tracks considered as reconstructable
constant maxCot      : real := sinh( maxEta ); -- maximum |cot(theta)| of tracks considered as reconstructable 

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
constant widthDTCr       : natural := 12;                            -- number of bits used to represent r w.r.t. chosenRofPhi
constant widthDTCphi     : natural := 15;                            -- number of bits used to represent phi w.r.t. phi sector center
constant widthDTCz       : natural := 14;                            -- number of bits used to represent gloabl z

-- TFP

constant widthTFPinv2R: natural := 15; -- number of bits used to represent 1/2R
constant widthTFPphi0 : natural := 12; -- number of bits used to represent phi0 w.r.t. region center
constant widthTFPcot  : natural := 16; -- number of bits used to represent cot(Theta)
constant widthTFPz0   : natural := 12; -- number of bits used to represent z0

-- GP

constant numSectorsPhi: natural :=   2;   -- number of phi sectors within a region
constant numSectorsEta: natural :=  16;   -- number of eta sectors within a region
constant gpWidthAddr  : natural :=   6;   -- fifo depth in stub router firmware
constant rangeGPz     : real    := 160.0; -- range of stub z residual w.r.t. sector center which needs to be covered
constant numSectors   : natural := numSectorsPhi * numSectorsEta; --total numbers of sectors within a region
constant etaBoundaries: reals( 0 to numSectorsEta ) := ( -2.50, -2.08, -1.68, -1.26, -0.90, -0.62, -0.41, -0.20, 0.0, 0.20, 0.41, 0.62, 0.90, 1.26, 1.68, 2.08, 2.50 ); -- eta boundaries defining eta sectors

constant numNodesGP: natural := numDTCsPerTFP; -- number of GP inputs

-- HT

constant numBinsHTinv2R: natural := 16; -- number of bins in pt in track finding
constant numBinsHTphiT : natural := 32; -- number of bins in phiT in track finding
constant minHTlayers   : natural :=  5; -- number of layers a candidate needs stubs in to be found
constant widthHTAddr   : natural :=  5; -- memory address depth used inside HT cells

constant numNodesHT: natural := numBinsHTinv2R; -- number of HT inputs

-- MHT

constant numBinsMHTinv2R: natural := 2; -- number of finer qOverPt bins inside HT bin
constant numBinsMHTphiT : natural := 2; -- number of finer phiT bins inside HT bin
constant numDLB         : natural := 2; -- number of dynamic load balancing steps
constant numDLBNodes    : natural := 8; -- number of units per dynamic load balancing step
constant numDLBChannel  : natural := 2; -- number of inputs per dynamic load balancing unit
constant minMHTlayers   : natural := 5; -- required number of stub layers to form a candidate

constant numNodesMHT: natural := numNodesHT; -- number of MHT inputs

-- SF

constant maxTracks       : natural := 16; -- max number of output tracks per node
constant numStubsPerLayer: natural := 4; -- cut on number of stub per layer
constant numBinsSFcot    : natural := 32; -- number of bins in cot in track finding
constant numBinsSFzT     : natural := 32; -- number of bins in zT in track finding

function init_rangeSFzT return real;
constant rangeSFzT: real; -- range of variable zT

constant numNodesSF: natural := numNodesMHT; -- number of SF inputs

-- KF

constant rangeFactor: real := 2.0; -- search window of each track parameter in initial uncertainties

constant maxStubs: natural := 4; -- maximum number of  layers added to a track

constant numNodesKF: natural := 2; -- number of KF inputs

-- DR

constant numNodesDR: natural := 2; -- number of DR inputs

-- TFP

constant linksInput: naturals( 0 to numDTCsPerTFP - 1 ) := ( 8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55 ); -- used input links
function linkMappingIn( l: ldata ) return ldata;

constant linksOutput: naturals( 0 to numNodesDR - 1 ) := ( 0,1 ); -- used output links
function linkMappingOut( l: ldata ) return ldata;
function linkMappingOut( l: std_logic_vector ) return std_logic_vector;

end;


package body tfp_config is

function init_rangeSFzT return real is
    variable res: real := -1.0;
begin
    for k in 0 to numSectorsEta - 1 loop
        res := max( res, sinh( etaBoundaries( k + 1 ) ) - sinh( etaBoundaries( k ) ) );
    end loop;
    res := res * chosenRofZ;
    return res;
end function;
constant rangeSFzT: real := init_rangeSFzT;

function linkMappingIn( l: ldata ) return ldata is
    variable m: ldata( numDTCsPerTFP - 1 downto 0 );
begin
    for k in m'range loop
        m( k ) := l( linksInput( k ) );
    end loop;
    return m;
end function;


function linkMappingOut( l: ldata ) return ldata is
    variable m:ldata( 4 * N_REGION - 1 downto 0 ) := ( others => ( ( others => '0' ), '0', '0', '1' ) );
begin
    for k in l'range loop
        m( linksOutput( k ) ) := l( k );
    end loop;
    return m;
end function;

function linkMappingOut( l: std_logic_vector ) return std_logic_vector is
    variable m:std_logic_vector( 4 * N_REGION - 1 downto 0 ) := ( others => '0' );
begin
    for k in l'range loop
        m( linksOutput( k ) ) := l( k );
    end loop;
    return m;
end function;

end;
