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
ENTITY kfout_router IS
  PORT(
    clk     : IN STD_LOGIC := '0'; -- The algorithm clock
    reset   : IN STD_LOGIC := '0';
    DataIn  : IN Vector;
    DataOut : OUT Vector
  );
END kfout_router;
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
ARCHITECTURE rtl OF kfout_router IS

  SIGNAL Output         : Vector( 0 TO DataOut'LENGTH-1 )                         := NullVector( DataOut'LENGTH );

  SIGNAL reset_array : std_logic_vector(0 TO 5) := (OTHERS=>'0');

  SUBTYPE tAddress        IS INTEGER RANGE 0 TO PacketBufferLength - 1;
  TYPE tAddressArray      IS ARRAY( 0 TO DataIn'LENGTH-1 ) OF tAddress;

BEGIN


  g1 : FOR j IN 0 TO DataOut'LENGTH-1 GENERATE

    SIGNAL RamCells       : Vector( 0 TO DataIn'LENGTH-1 )                          := NullVector( DataIn'Length );

    SIGNAL Input          : Vector( 0 TO DataIn'LENGTH-1 )                          := NullVector( DataIn'LENGTH );

    SIGNAL Addresses_ram : INTEGER_VECTOR( 0 TO 107) := (OTHERS=>0);
    SIGNAL Addresses_ram_idx : INTEGER_VECTOR( 0 TO 107) := (OTHERS=>0);

    SIGNAL WriteAddr    : tAddressArray                       := ( OTHERS => 0 );
    SIGNAL ReadAddr     :tAddressArray := ( OTHERS => 0 );

  BEGIN

-- -------------------------------------------------------------------------
-- RAM for storing incoming trigger cells
-- -------------------------------------------------------------------------
  RAMgen            : FOR i IN Input'RANGE GENERATE
    DataRamInstance : ENTITY work.DataRam
    GENERIC MAP(
        COUNT => PacketBufferLength
    )
    PORT MAP(
      clk         => clk ,
      WriteAddr   => WriteAddr( i ),
      DataIn      => Input( i ) ,
      WriteEnable => Input( i ) .DataValid ,
      ReadAddr    => ReadAddr( i ) ,
      DataOut     => RamCells( i ) 
    );
  END GENERATE RAMgen;
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
  PROCESS( clk )
  VARIABLE buffer_counter : INTEGER := 0;
  BEGIN
    IF( RISING_EDGE( clk ) ) THEN

    reset_array <= reset & reset_array( 0 TO 4);

-- Increment the write pointer if we do write
      FOR ram IN Input'RANGE LOOP
        IF (DataIn( ram ).sortkey  = j) AND ( DataIn( ram ) .DataValid ) THEN
          Input( ram )  <= DataIn( ram );
          WriteAddr( ram ) <= ( WriteAddr( ram ) + 1 ) MOD PacketBufferLength;
          
          Addresses_ram( buffer_counter ) <= ram;
          Addresses_ram_idx( buffer_counter ) <= WriteAddr( ram );
          buffer_counter := buffer_counter + 1;

        END IF;
      END LOOP;

      IF reset = '1' THEN
        buffer_counter := 0;
        Addresses_ram <= (OTHERS=>0);
        Addresses_ram_idx <= (OTHERS=>0);
      END IF;

    END IF;
  END PROCESS;



  PROCESS( clk )

  VARIABLE out_counter : INTEGER := 0;
  
  BEGIN
    IF( RISING_EDGE( clk ) ) THEN

      ReadAddr( Addresses_ram( out_counter + 2 ) ) <=   ReadAddr( Addresses_ram( out_counter + 2 ) ) + 1;   --Addresses_ram_idx( out_counter + 2 );

      DataOut( j ) <= RamCells(Addresses_ram( out_counter));

      out_counter := (out_counter + 1) MOD (PacketBufferLength - 2);

      IF reset_array(2) = '1' THEN
        out_counter := 0;
      END IF;

    END IF;
  END PROCESS;
END GENERATE;
 
END rtl;