library ieee;
use ieee.std_logic_1164.all;


package hybrid_config is


constant numDTCPS: natural := 9;
constant numDTC2S: natural := 8;

constant numStubsTracklet: natural := 4;
constant numLinksTracklet: natural := 1 + numStubsTracklet;

constant outputOffset: natural := 26 * 4;


end;