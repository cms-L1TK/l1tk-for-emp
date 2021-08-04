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


signal TTTracks: Vector(numNodesKF -1 downto 0) := NullVector(  numNodesKF );
signal SortedTracks: Vector(numOutLinks -1 downto 0) := NullVector( numOutLinks );
signal Reset: std_logic := '0';
signal PacketData: PacketArray( 0 TO numOutLinks - 1)  := ( others => ( others => '0' ));
signal PacketValid: std_logic_vector( 0 TO numOutLinks - 1 ) := ( others => '0' );


begin


Reset <= kfout_din( 0 ).track.reset; 
-- ------------------------------------------------------------------------
-- Convert KF tracks and KF stubs to TTTracks
TrackTransformInstance : ENTITY work.kfout_trackTransform
PORT MAP(
  clk          => clk ,
  KFObjectsIn  => kfout_din ,
  TTTracksOut  => TTTracks
  );
-- ------------------------------------------------------------------------
-- Convert Route TTTracks in Eta
RouterInstance : ENTITY work.kfout_distributionServer
  GENERIC MAP( Interleaving => 2)
  PORT MAP(
    clk     => clk ,
    DataIn  => TTTracks,
    DataOut => SortedTracks 
    
  );
----------------------------------------------------------------------
-------------------------------------------------------------------
-- Output 64-bit partial tracks in correct link structure
OutObjectsToPacketsInstance : ENTITY work.kfout_outObjectsToPackets
PORT MAP(
  clk                 => clk ,
  rst                 => Reset,
  SortedTracks        => SortedTracks,
  PacketValid         => PacketValid,
  PacketData          => PacketData
);
-- ------------------------------------------------------------------------

links : FOR i IN 0 TO numOutLinks-1 GENERATE
  signal dout: lword;
  begin
  kfout_dout( i ) <= dout.data;
  PacketsToEMPLinks : ENTITY work.EMPDataOut
  PORT MAP(
    clk                 => clk ,
    PacketValid         => PacketValid( i ),
    PacketData          => PacketData( i ),
    linkOut             => dout
  );
END GENERATE;


-- ------------------------------------------------------------------------
END rtl;