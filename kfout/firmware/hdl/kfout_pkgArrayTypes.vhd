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

USE work.DataType.ALL;
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
PACKAGE ArrayTypes IS

  TYPE Pipe       IS ARRAY( NATURAL RANGE <> ) OF tData;

  TYPE Vector     IS ARRAY( INTEGER RANGE <> ) OF tData;
  TYPE VectorPipe IS ARRAY( NATURAL RANGE <> ) OF Vector;
  TYPE Matrix     IS ARRAY( INTEGER RANGE <> ) OF Vector;

  FUNCTION NullVector( aSize      : INTEGER ) RETURN Vector;
  FUNCTION NullPipe( aSize        : NATURAL ) RETURN Pipe;
  FUNCTION NullVectorPipe( aSize1 : NATURAL ; aSize2 : INTEGER ) RETURN VectorPipe;
  FUNCTION NullMatrix( aSize1     : INTEGER ; aSize2 : INTEGER ) RETURN Matrix;

END ArrayTypes;
-- -------------------------------------------------------------------------



-- -------------------------------------------------------------------------
PACKAGE BODY ArrayTypes IS

  FUNCTION NullVector( aSize : INTEGER ) RETURN Vector IS
    VARIABLE lRet            : Vector( 0 TO aSize-1 ) := ( OTHERS => cNull );
  BEGIN
    RETURN lRet;
  END NullVector;

  FUNCTION NullPipe( aSize : NATURAL ) RETURN Pipe IS
    VARIABLE lRet          : Pipe( 0 TO aSize-1 ) := ( OTHERS => cNull );
  BEGIN
    RETURN lRet;
  END NullPipe;

  FUNCTION NullVectorPipe( aSize1 : NATURAL ; aSize2 : INTEGER ) RETURN VectorPipe IS
    VARIABLE lRet                 : VectorPipe( 0 TO aSize1-1 )( 0 TO aSize2-1 ) := ( OTHERS => ( OTHERS => cNull ) );
  BEGIN
    RETURN lRet;
  END NullVectorPipe;

  FUNCTION NullMatrix( aSize1 : INTEGER ; aSize2 : INTEGER ) RETURN Matrix IS
    VARIABLE lRet             : Matrix( 0 TO aSize1 - 1 )( 0 TO aSize2 - 1 ) := ( OTHERS => ( OTHERS => cNull ) );
  BEGIN
    RETURN lRet;
  END NullMatrix;

END ArrayTypes;
