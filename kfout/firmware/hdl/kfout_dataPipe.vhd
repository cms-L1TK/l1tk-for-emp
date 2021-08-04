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

USE work.ArrayTypes.ALL;
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
ENTITY DataPipe IS
  PORT(
    clk      : IN STD_LOGIC := '0'; -- The algorithm clock
    DataIn   : IN Vector;
    DataPipe : OUT VectorPipe
  );
END DataPipe;
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
ARCHITECTURE rtl OF DataPipe IS
    SIGNAL DataPipeInternal : VectorPipe( DataPipe'RANGE )( DataIn'RANGE ) := NullVectorPipe( DataPipe'LENGTH , DataIn'LENGTH );
BEGIN

  DataPipeInternal( 0 ) <= DataIn; -- since the data is clocked out , no need to clock it in as well...

  gDataPipe : FOR i IN 1 TO DataPipe'HIGH GENERATE
    DataPipeInternal( i ) <= DataPipeInternal( i-1 ) WHEN RISING_EDGE( clk );
  END GENERATE gDataPipe;

  DataPipe <= DataPipeInternal;

END ARCHITECTURE rtl;
