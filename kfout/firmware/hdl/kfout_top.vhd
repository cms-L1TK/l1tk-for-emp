library ieee;
use ieee.std_logic_1164.all;

use work.kfout_data_formats.all;
use work.kfout_config.all;
use work.DataType.all;
use work.ArrayTypes.all;

use work.emp_data_types.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.hybrid_data_formats.all;


entity kfout_top is
port (
  clk: in std_logic;
  kfout_din: in t_channelsKF( numNodesKF - 1 downto 0 );
  kfout_dout: out t_frames( numLinksTFP - 1 downto 0 )
);
end;


architecture rtl of kfout_top IS

CONSTANT reset_delay : INTEGER := 27;
CONSTANT router_reset_delay : INTEGER := 8;

signal TTTracks: Vector(numNodesKF -1 downto 0) := NullVector(  numNodesKF );
signal TTTracksTQ: Vector(numOutLinks -1 downto 0) := NullVector(  numOutLinks );
signal SortedTracks: Vector(numOutLinks -1 downto 0) := NullVector( numOutLinks );
signal Reset: std_logic_vector(0 TO reset_delay - 1) := (OTHERS => '0');
signal PacketData: PacketArray( numOutLinks -1 downto 0)  := ( others => ( others => '0' ));
signal PacketValid: std_logic_vector( numOutLinks -1 downto 0 ) := ( others => '0' );



begin

  process (clk)
    BEGIN
      if RISING_EDGE(clk) THEN
        Reset <= kfout_din( 0 ).track.reset & Reset( 0 TO reset_delay - 2 );
      END if;
  end process;

-- ------------------------------------------------------------------------
-- Convert KF tracks and KF stubs to TTTracks
TrackTransformInstance : ENTITY work.kfout_trackTransform
PORT MAP(
  clk          => clk ,
  KFObjectsIn  => kfout_din ,
  TTTracksOut  => TTTracks
  );
-- ------------------------------------------------------------------------
-- ------------------------------------------------------------------------
-- Convert Route TTTracks in Eta
RouterInstance : ENTITY work.kfout_router
  PORT MAP(
    clk     => clk ,
    reset   => reset( router_reset_delay - 1),
    DataIn  => TTTracks,
    DataOut => SortedTracks 
  );
----------------------------------------------------------------------
-------------------------------------------------------------------
-- ------------------------------------------------------------------------
-- Run Track Quality BDT 
TrackQualityInstance : ENTITY work.kfout_trackQuality
PORT MAP(
  clk          => clk ,
  TTTracksIn   => SortedTracks ,
  TTTracksOut  => TTTracksTQ
  );
-- Output 64-bit partial tracks in correct link structure
OutObjectsToPacketsInstance : ENTITY work.kfout_outObjectsToPackets
PORT MAP(
  clk                 => clk ,
  Reset               => reset( reset_delay - 1 ),
  SortedTracks        => TTTracksTQ,
  PacketData          => kfout_dout
);
-- ------------------------------------------------------------------------
-- ------------------------------------------------------------------------
END rtl;