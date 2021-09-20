library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use work.hybrid_tools.all;


package hybrid_config is


constant numDTCPS: natural := 9;
constant numDTC2S: natural := 8;
constant numQuads: natural := natural( ceil( real( numDTCPS + numDTC2S ) / 4.0 ) );

constant numStubsTracklet: natural := 4;
constant numLinksTracklet: natural := 1 + numStubsTracklet;
constant numLinksTFP: natural := 2;

constant numLayers: natural := 7;

constant numNodesKF: natural := 1;


constant chosenRofPhi: real := 55.0;           -- offest radius used for phi sector definitionmaxRtimesMoverBend21.
constant chosenRofZ  : real := 50.0;           -- offest radius used for eta sector definition
constant numSectorsEta: natural :=  16;   -- number of eta sectors within a region
constant etaBoundaries: reals( 0 to numSectorsEta ) := ( -2.50, -2.08, -1.68, -1.26, -0.90, -0.62, -0.41, -0.20, 0.0, 0.20, 0.41, 0.62, 0.90, 1.26, 1.68, 2.08, 2.50 ); -- eta boundaries defining eta sectors


constant freqLHC    : real    :=  40.0;                                 -- LHC Frequency in MHz
constant freqHyrbid : real    := 240.0;                                 -- TFP Frequency in MHz, has to be integer multiple of FreqLHC
constant tmp        : natural :=  18;                                   -- time multiplexed period in number of BX

constant widthBX: natural := 3;


end;