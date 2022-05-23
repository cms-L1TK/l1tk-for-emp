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

-- -------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

USE WORK.DataType.ALL;
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
ENTITY DataRam IS
  GENERIC(
    Count : NATURAL := 512;
    Style : STRING  := "block"
  );
  PORT(
    clk         : IN STD_LOGIC; -- The algorithm clock
    DataIn      : IN tData                         := cNull;
    WriteAddr   : IN NATURAL RANGE 0 TO( Count-1 ) := 0;
    WriteEnable : IN BOOLEAN                       := FALSE;
    ReadAddr    : IN NATURAL RANGE 0 TO( Count-1 ) := 0;
    DataOut     : OUT tData                        := cNull
  );
END DataRam;
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
ARCHITECTURE rtl OF DataRam IS
    TYPE mem_extendable IS ARRAY( 0 TO( Count-1 ) ) OF STD_LOGIC_VECTOR( ( tData'Size - 1 ) DOWNTO 0 );
    SIGNAL RAM                 : mem_extendable := ( OTHERS => ( OTHERS => '0' ) );
    ATTRIBUTE ram_style        : STRING;
    ATTRIBUTE ram_style OF RAM : SIGNAL IS Style;
BEGIN

  PROCESS( clk )
  BEGIN
    IF RISING_EDGE( clk ) THEN

      IF WriteEnable THEN
        RAM( WriteAddr ) <= ToStdLogicVector( DataIn );
      END IF;

      DataOut <= ToDataType( RAM( ReadAddr ) );

    END IF;
  END PROCESS;

END ARCHITECTURE rtl;
