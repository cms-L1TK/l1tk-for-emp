-- #########################################################################
-- #########################################################################
-- ###                                                                   ###
-- ###   Use of this code, whether in its current form or modified,      ###
-- ###   implies that you consent to the terms and conditions, namely:   ###
-- ###    - You acknowledge my contribution                              ###
-- ###    - This copyright notification remains intact                   ###
-- ###                                                                   ###
-- ###   Many thanks,                                                    ###
-- ###     Dr. Andrew W. Rose, Imperial College London, 2018             ###
-- ###                                                                   ###
-- #########################################################################
-- #########################################################################

-- .include ReuseableElements/PkgUtilities.vhd
-- .include ReuseableElements/DataRam.vhd in .

-- -------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_MISC.ALL;
USE IEEE.NUMERIC_STD.ALL;

USE work.kfout_config.ALL;

USE work.DataType.ALL;
USE work.ArrayTypes.ALL;
-- -------------------------------------------------------------------------


-- -------------------------------------------------------------------------
ENTITY kfout_distributionServer IS
  GENERIC(
    Interleaving  : INTEGER := 4
  );
  PORT(
    clk     : IN STD_LOGIC := '0'; -- The algorithm clock
    DataIn  : IN Vector;
    DataOut : OUT Vector
  );
END kfout_distributionServer;
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
ARCHITECTURE rtl OF kfout_distributionServer IS

  SIGNAL Input          : Vector( 0 TO DataIn'LENGTH-1 )                          := NullVector( DataIn'LENGTH );
  SIGNAL Output         : Vector( 0 TO DataOut'LENGTH-1 )                         := NullVector( DataOut'LENGTH );

  SIGNAL RamCells       : Vector( 0 TO DataIn'LENGTH-1 )                          := NullVector( DataIn'Length );
  SIGNAL RamCellPipe    : VectorPipe( 0 TO Interleaving )( 0 TO DataIn'Length-1 ) := NullVectorPipe( Interleaving+1 , DataIn'Length );

-- --------  
  SUBTYPE tAddress        IS INTEGER RANGE 0 TO 511;
  TYPE tAddressArray      IS ARRAY( 0 TO DataIn'LENGTH-1 ) OF tAddress;
  TYPE tAddressPipe       IS ARRAY( INTEGER RANGE <> ) OF tAddressArray;

  SUBTYPE tAddressDelta   IS INTEGER RANGE -512 TO 511;
  TYPE tAddressDeltaArray IS ARRAY( 0 TO DataIn'LENGTH-1 ) OF tAddressDelta;

  FUNCTION InitializeAddressPipe( LENGTH : INTEGER ) RETURN tAddressPipe IS
    VARIABLE lret                        : tAddressPipe( 0 TO LENGTH-1 ) := ( OTHERS => ( OTHERS => 0 ) );
  BEGIN
    FOR i IN 0 TO LENGTH-1 LOOP
      lret( i ) := ( OTHERS => ( ( LENGTH-1 ) - i ) );
    END LOOP;
    RETURN lret;
  END FUNCTION InitializeAddressPipe;
-- --------   

  SIGNAL Delta        : tAddressDeltaArray                  := ( OTHERS => 0 );
  SIGNAL WriteAddr    : tAddressArray                       := ( OTHERS => 0 );
  SIGNAL ReadAddrPipe : tAddressPipe( 0 TO interleaving-1 ) := InitializeAddressPipe( interleaving );

  TYPE tCellMap IS ARRAY( Input'RANGE ) OF STD_LOGIC_VECTOR( Output'RANGE );
  SIGNAL CellMap , CellMap2 : tCellMap := ( OTHERS => ( OTHERS => '0' ) );

-- Store the frame-valid signals for convenience
  SIGNAL FrameValidPipe     : STD_LOGIC_VECTOR( 0 TO Interleaving + 3 ) := ( OTHERS => '0' );

  PROCEDURE CellMapProc(signal Delta       : in tAddressDeltaArray;
                        signal RamCellPipe : in VectorPipe;
                        signal CellMap     : out tCellMap) IS
  BEGIN
    CellMap <= ( OTHERS => ( OTHERS => '0' ) );
-- Map the data-valid flags into an array         
    FOR ram IN Input'RANGE LOOP
      IF( Delta( ram ) < 0 ) THEN
-- IF RamCellPipe( 0 )( ram ) .DataValid THEN
        CellMap( ram )( RamCellPipe( 0 )( ram ) .SortKey ) <= '1';
-- END IF;
      END IF;
    END LOOP;
  END PROCEDURE;

  PROCEDURE CellMap2Proc(signal CM  : in tCellMap;
                         signal CM2 : out tCellMap) IS
    BEGIN
    CM2 <= ( OTHERS => ( OTHERS => '0' ) );
-- Remove the duplicates
    FOR sector IN Output'RANGE LOOP
      FOR ram IN Input'RANGE LOOP
        IF CM( ram )( sector ) = '1' THEN
          CM2( ram )( sector ) <= '1';
          EXIT; -- quits inner loop
        END IF;
      END LOOP;
    END LOOP;
  END PROCEDURE;

  PROCEDURE DeltaProc(signal ReadAddrPipe : in tAddressPipe;
                      signal WriteAddr    : in tAddressArray;
                      signal Delta        : out tAddressDeltaArray) IS
  BEGIN
-- Calculate the distance between the read and write pointers (previously done in "RAM" module)      
-- NEW: keep the delta working when either pointer wraps around
-- NOTE: this method means that delta > 255 is not allowed, and incorrect behavior will occur
-- TODO: add a flag monitoring the delta validity?
      FOR ram IN Input'RANGE LOOP
        IF ReadAddrPipe( 0 )( ram ) < WriteAddr( ram ) THEN -- if r < w
          IF ABS( ReadAddrPipe( 0 )( ram ) - WriteAddr( ram ) ) < ABS( ReadAddrPipe( 0 )( ram ) - WriteAddr( ram ) + 512 ) THEN -- if abs(r - w) < abs(r - w + 512)
            Delta( ram ) <= ReadAddrPipe( 0 )( ram ) - WriteAddr( ram );
          ELSE
            Delta( ram ) <= ReadAddrPipe( 0 )( ram ) - WriteAddr( ram ) + 512;
          END IF;
        ELSE -- else (r >= w)
          IF ABS( ReadAddrPipe( 0 )( ram ) - WriteAddr( ram ) ) < ABS( ReadAddrPipe( 0 )( ram ) - WriteAddr( ram ) - 512 ) THEN
            Delta( ram ) <= ReadAddrPipe( 0 )( ram ) - WriteAddr( ram );
          ELSE
            Delta( ram ) <= ReadAddrPipe( 0 )( ram ) - WriteAddr( ram ) - 512;
          END IF;
        END IF;
      END LOOP;
  END PROCEDURE;

  PROCEDURE OutputProc(signal RamCellPipe    : in VectorPipe;
                       signal CellMap2       : in tCellMap;
                       signal FrameValidPipe : in std_logic_vector;
                       signal ReadAddrPipe   : inout tAddressPipe;
                       signal Output         : out Vector) IS
  BEGIN
-- Select the relevant Cell and increment the addresses as necessary     
    Output <= NullVector(Output'LENGTH);
    ReadAddrPipe( 0 ) <= ReadAddrPipe( Interleaving - 1 ); --                                         Read address retains its previous value...
    FOR sector IN Output'RANGE LOOP --                                                                .
      FOR ram IN Input'RANGE LOOP --                                                                  .
        IF CellMap2( ram )( sector ) = '1' THEN --                                                    .
          Output( sector )            <= RamCellPipe( Interleaving-2 )( ram ); --                                   .
          Output( sector ) .DataValid <= TRUE; --                                                      .
          ReadAddrPipe( 0 )( ram )    <= ( ReadAddrPipe( Interleaving - 1 )( ram ) + Interleaving ) MOD 512; -- ... unless we are reading here!
          EXIT; -- Quits inner loop , should be inferred from above , but just in case
        END IF;
      END LOOP;
    END LOOP;
-- The rest of the addresses just get shifted up one place...
    ReadAddrPipe( 1 TO( Interleaving - 1 ) ) <= ReadAddrPipe( 0 TO( Interleaving - 2 ) );

    FOR sector IN Output'RANGE LOOP --                                                                .
--Output( sector ) .FrameValid <= to_boolean( FrameValidPipe( Interleaving ) );
      Output( sector ) .FrameValid <= to_boolean( FrameValidPipe( 0 ) );
    END LOOP;
  END PROCEDURE;

BEGIN

  ASSERT (Interleaving <= 4 and Interleaving >= 2) REPORT "Only Interleaving of 2, 3 or 4 are supported" SEVERITY FAILURE;
-- -------------------------------------------------------------------------
-- Not as pointless as it looks, input copy is a slice whereas local copy is indexed from 0
  Input <= DataIn;
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
-- RAM for storing incoming trigger cells
-- -------------------------------------------------------------------------
  RAMgen            : FOR i IN Input'RANGE GENERATE
    DataRamInstance : ENTITY work.DataRam
    PORT MAP(
      clk         => clk ,
      WriteAddr   => WriteAddr( i ) ,
      DataIn      => Input( i ) ,
      WriteEnable => Input( i ) .DataValid ,
      ReadAddr    => ReadAddrPipe( 0 )( i ) ,
      DataOut     => RamCells( i )
    );
  END GENERATE RAMgen;
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
  PROCESS( clk )
  BEGIN
    IF( RISING_EDGE( clk ) ) THEN

-- Store the frame-valid flags for convenience
      FrameValidPipe( 0 )                     <= to_std_logic( Input( 0 ) .FrameValid );
      FrameValidPipe( 1 TO Interleaving + 3 ) <= FrameValidPipe( 0 TO Interleaving + 2 );


-- Increment the write pointer if we do write
      FOR ram IN Input'RANGE LOOP
        IF( Input( ram ) .DataValid ) THEN
          WriteAddr( ram ) <= ( WriteAddr( ram ) + 1 ) MOD 512;
        END IF;
      END LOOP;
    END IF;
  END PROCESS;

  CellMaps:
  IF Interleaving = 4 GENERATE
    PROCESS(CLK)
    BEGIN
      IF RISING_EDGE(CLK) THEN
        CellMapProc(Delta, RamCellPipe, CellMap);
        CellMap2Proc(CellMap, CellMap2);
        DeltaProc(ReadAddrPipe, WriteAddr, Delta);
        OutputProc(RamCellPipe, CellMap2, FrameValidPipe, ReadAddrPipe, Output);
      END IF;
    END PROCESS;
  ELSIF Interleaving = 3 GENERATE
    PROCESS(CLK)
    BEGIN
      IF RISING_EDGE(CLK) THEN
        CellMapProc(Delta, RamCellPipe, CellMap);
        DeltaProc(ReadAddrPipe, WriteAddr, Delta);
        OutputProc(RamCellPipe, CellMap2, FrameValidPipe, ReadAddrPipe, Output);
      END IF;
    END PROCESS;
    CellMap2Proc(CellMap, CellMap2);
  ELSIF Interleaving = 2 GENERATE
    PROCESS(CLK)
    BEGIN
        IF RISING_EDGE(CLK) THEN
          DeltaProc(ReadAddrPipe, WriteAddr, Delta);
          OutputProc(RamCellPipe, CellMap2, FrameValidPipe, ReadAddrPipe, Output);
        END IF;
    END PROCESS;
    CellMapProc(Delta, RamCellPipe, CellMap);
    CellMap2Proc(CellMap, CellMap2);
  END GENERATE;
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
  DataPipeInstance : ENTITY work.DataPipe
  PORT MAP( clk , RamCells , RamCellPipe );
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
-- Not as pointless as it looks, output copy is a slice whereas local copy is indexed from 0
  DataOut <= Output;
-- -------------------------------------------------------------------------

END rtl;
