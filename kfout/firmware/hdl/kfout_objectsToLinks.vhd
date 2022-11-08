LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY work;
USE work.kfout_data_formats.all;
USE work.kfout_config.all;

---------------------------------------------------------------------
ENTITY PacketRam IS
  GENERIC(
    Count : NATURAL := 128;
    Style : STRING  := "block"
  );
  PORT(
    clk          : IN STD_LOGIC; -- The algorithm clock
    reset        : IN STD_LOGIC;
    Packet1      : IN STD_LOGIC_VECTOR( widthpartialTTTrack*2  - 1 DOWNTO 0 )  := (OTHERS=> '0');
    Packet2      : IN STD_LOGIC_VECTOR( widthpartialTTTrack*2  - 1 DOWNTO 0 )  := (OTHERS=> '0');
    Packet3      : IN STD_LOGIC_VECTOR( widthpartialTTTrack*2  - 1 DOWNTO 0 )  := (OTHERS=> '0');
    WriteAddr    : IN NATURAL RANGE 0 TO( Count -1 )                            := 0;
    ReadAddr     : IN NATURAL RANGE 0 TO( Count -1 )                            := 0;
    PacketOut    : OUT STD_LOGIC_VECTOR( widthpartialTTTrack*2  - 1 DOWNTO 0 ) := (OTHERS=> '0')
  );
END PacketRam;
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
ARCHITECTURE rtl OF PacketRam IS
    TYPE mem_extendable IS ARRAY( 0 TO( Count-1 ) ) OF STD_LOGIC_VECTOR( ( widthpartialTTTrack*2 - 1 ) DOWNTO 0 );
    SIGNAL RAM                 : mem_extendable := ( OTHERS => ( OTHERS => '0' ) );
    ATTRIBUTE ram_style        : STRING;
    ATTRIBUTE ram_style OF RAM : SIGNAL IS Style;
BEGIN

  PROCESS( clk )
    VARIABLE positive_read_addr : INTEGER := 0;
  BEGIN
    
    IF RISING_EDGE( clk ) THEN
        RAM( (WriteAddr) MOD count  ) <= Packet1;
        RAM( (WriteAddr + 1 ) MOD count ) <= Packet2;
        RAM( (WriteAddr + 2 ) MOD count ) <= Packet3;

        IF ReadAddr < 1 THEN
          positive_read_addr := 0;
        ELSE
          positive_read_addr := ReadAddr MOD count;
        END IF;

        PacketOut <= RAM ( positive_read_addr );  --Put packet on output link
        
        IF reset = '1' THEN
          RAM <= ( OTHERS => ( OTHERS => '0' ) );
        END IF;

    END IF;
  END PROCESS;

END ARCHITECTURE rtl;


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_MISC.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY work;
use work.hybrid_data_types.all;
USE work.kfout_data_formats.ALL;
USE work.kfout_config.ALL;
USE work.DataType.ALL;
USE work.ArrayTypes.ALL;

ENTITY kfout_outObjectsToPackets IS
PORT(
  clk          : IN STD_LOGIC; -- The algorithm clock
  reset        : IN STD_LOGIC;
  SortedTracks : IN VECTOR;
  PacketData   : OUT t_frames
);
END kfout_outObjectsToPackets;

-- -------------------------------------------------------------------------
-- -------------------------------------------------------------------------
ARCHITECTURE rtl OF kfout_outObjectsToPackets IS

  TYPE PacketArray IS ARRAY( INTEGER RANGE <> ) of STD_LOGIC_VECTOR( widthpartialTTTrack*2  - 1 DOWNTO 0 );
  TYPE TrackArray IS ARRAY( INTEGER RANGE <> )  of STD_LOGIC_VECTOR( widthTTTrack - 1           DOWNTO 0 );

BEGIN
  g1 : FOR i IN 0 TO numOutLinks-1 GENERATE
    SIGNAL frame_signal : STD_LOGIC := '0';
    SIGNAL RAMreset     : STD_LOGIC := '0';

    SIGNAL Packets : PacketArray( 2 DOWNTO 0 ) := ( OTHERS => ( OTHERS => '0' ));  -- 3 packets for every 2 tracks
    SIGNAL Tracks  : TrackArray(  1 DOWNTO 0 ) := ( OTHERS => ( OTHERS => '0' ));  -- 2 tracks for every 3 packets

    SIGNAL packet_counter : INTEGER := 0;  -- Count packets created
    SIGNAL out_counter    : INTEGER := 0;  -- Count packets out

    SIGNAL OutBuffer   : STD_LOGIC_VECTOR( widthpartialTTTrack*2  - 1 DOWNTO 0 );


  BEGIN

    DataRamInstance : ENTITY work.PacketRam
    GENERIC MAP ( Count => PacketBufferLength+2)
    PORT MAP(
      clk         => clk ,
      reset       => RAMreset,
      WriteAddr   => packet_counter ,
      Packet1     => Packets( 0 ),
      Packet2     => Packets( 1 ),
      Packet3     => Packets( 2 ),
      ReadAddr    => Out_counter ,
      PacketOut   => OutBuffer
    );

    PROCESS( clk )
      VARIABLE odd_even       : INTEGER := 0;  --Put tracks onto packet structure every two clocks

    BEGIN
      IF RISING_EDGE( clk ) THEN
          
          Tracks ( 0 ) <=  ToStdLogicVector( SortedTracks( i ) )( widthTTTrack - 1 DOWNTO 0);
          Tracks ( 1 ) <=  Tracks ( 0 );

          odd_even := odd_even + 1;

          IF odd_even = 2 THEN
            Packets ( 2 )                                                          <= Tracks ( 0 )( widthpartialTTTrack*2  - 1 DOWNTO 0  );                     -- First 64 bits of track 1
            Packets ( 1 )( widthpartialTTTrack    - 1 DOWNTO 0 )                   <= Tracks ( 0 )( widthTTTrack - 1           DOWNTO widthpartialTTTrack*2 );  -- Last 32 bits of track 1
            Packets ( 1 )( widthpartialTTTrack*2  - 1 DOWNTO widthpartialTTTrack ) <= Tracks ( 1 )( widthpartialTTTrack - 1    DOWNTO 0  );                     -- First 32 bits of track 2
            Packets ( 0 )                                                          <= Tracks ( 1 )( widthTTTrack - 1           DOWNTO widthpartialTTTrack );    -- Last 64 bits of track 2
            odd_even := 0;

            packet_counter <= (packet_counter + 3) MOD (PacketBufferLength+1);

          END IF;

          RAMreset <= reset;

          IF reset = '1' THEN
            packet_counter <= 0;
            out_counter <= 0;
            odd_even := 0;
            PacketData( i ) <= (OTHERS => '0');
          ELSE
            Out_counter <= out_counter + 1;
            PacketData( i )  <= OutBuffer;
          END IF;

        END IF;
    END PROCESS;

  END GENERATE;

END RTL;
