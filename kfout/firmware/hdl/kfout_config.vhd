LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE ieee.math_real.ALL;
USE IEEE.FIXED_PKG.ALL;

LIBRARY work;
USE work.emp_data_types.ALL;
USE work.emp_device_decl.ALL;
USE work.kfout_data_formats.ALL;


use work.hybrid_tools.all;
USE work.hybrid_config.ALL;
USE work.hybrid_data_types.ALL;
USE work.hybrid_data_formats.ALL;

PACKAGE kfout_config IS

-- OVERALL CONFIG

CONSTANT numOutLinks : NATURAL :=  2;

TYPE VECTOR_ARRAY   IS ARRAY ( NATURAL RANGE <> ) OF STD_LOGIC_VECTOR( 63 DOWNTO 0);
-- rtl_synthesis off
--TYPE INTEGER_VECTOR IS ARRAY ( NATURAL RANGE <> )  OF INTEGER;
-- rtl_synthesis on

-- TRACK TRANSFORM SPECIFIC CONFIG

CONSTANT zscaleLatency   : NATURAL := 5;
CONSTANT phiscaleLatency : NATURAL := 5;
CONSTANT chiLatency      : NATURAL := 8;
CONSTANT MVALatency      : NATURAL := 15;

CONSTANT zTfactor   : REAL := 0.00999469;
CONSTANT CotFactor  : REAL := 0.000244141;
CONSTANT InvRFactor : REAL := 5.20424e-07	;
CONSTANT PhiTFactor : REAL := 0.000340885;

CONSTANT z0Factor      : INTEGER := 16;
CONSTANT modChosenRofZ : REAL := (chosenRofZ * (CotFactor/zTfactor)) * REAL(2**z0Factor); 

CONSTANT phi0Factor         : INTEGER := 16;
CONSTANT modChosenRofPhi    : REAL    := (chosenRofPhi * (InvRFactor / PhiTFactor )) * REAL( 2**phi0Factor );
CONSTANT BaseSector         : REAL    :=  0.1745;
CONSTANT IntBaseSector      : REAL    := BaseSector / PhiTFactor;
CONSTANT UnsignedBaseSector : UNSIGNED( widthKFphiT - 1 DOWNTO 0 ) := TO_UNSIGNED(INTEGER(IntBaseSector),widthKFPhiT);

--TYPE weight_array IS ARRAY ( NATURAL RANGE <> ) OF INTEGER;
TYPE weight_array IS ARRAY ( NATURAL RANGE <> ) OF SIGNED( 0 TO widthDSPportA - 1);
TYPE chi_array IS ARRAY( NATURAL RANGE <> ) OF SIGNED( widthDSPportC - 1 DOWNTO 0 ) ;
TYPE MVA_array is ARRAY ( NATURAL RANGE <> ) OF SIGNED(9 DOWNTO 0);

CONSTANT numdPhiBins : NATURAL := 2**9;
CONSTANT numdZBins : NATURAL := 2**10;
CONSTANT basedZ : REAL := 0.0399788;
CONSTANT basedPhi : REAL := 4.26106e-05;

--CONSTANT floatMVABins : REALS( 0 TO ( 2**widthTQMVA )) := ( 0.0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.750, 0.875, 1.0 );
CONSTANT floatMVABins : REALS( 0 TO ( 2**widthTQMVA )) := ( -15.0, -1.945910149, -1.098612289, -0.5108256238, 0.0, 0.5108256238, 1.098612289, 1.945910149, 15.0 );

--- LINK OUTPUT formatting specific constants

CONSTANT PacketBufferLength : INTEGER := 107;  --Depth of buffer for output packets

TYPE PacketArray IS ARRAY( INTEGER RANGE <> ) of STD_LOGIC_VECTOR( widthpartialTTTrack*2  - 1 DOWNTO 0 );

TYPE cot_array IS ARRAY( NATURAL RANGE <> ) OF SIGNED( widthKFcot - 1 DOWNTO 0 ) ;

FUNCTION TO_STD_LOGIC( arg  : BOOLEAN )   RETURN STD_ULOGIC;
FUNCTION TO_BOOLEAN( arg    : STD_LOGIC ) RETURN BOOLEAN;

FUNCTION scale_v0bins( real_bins : REALS) RETURN weight_array;
FUNCTION scale_v1bins( real_bins : REALS) RETURN weight_array;
FUNCTION init_cotBins                                                           RETURN INTEGER_VECTOR;
FUNCTION scale_chi2rphibins( real_bins : REALS )  RETURN chi_array;
FUNCTION scale_chi2rzbins( real_bins : REALS )  RETURN chi_array;
FUNCTION init_MVAbins return MVA_array;


END kfout_config;

PACKAGE BODY kfout_config IS

  FUNCTION TO_BOOLEAN( arg : STD_LOGIC ) RETURN BOOLEAN IS
  BEGIN
    RETURN( arg = '1' );
  END FUNCTION TO_BOOLEAN;
  -- -------------------------------------------------------------------------       

  -- -------------------------------------------------------------------------       
  FUNCTION TO_STD_LOGIC( arg : BOOLEAN ) RETURN STD_ULOGIC IS
  BEGIN
    IF arg THEN
        RETURN( '1' );
    ELSE
        RETURN( '0' );
    END IF;
  END FUNCTION TO_STD_LOGIC;
  -- -------------------------------------------------------------------------       

  FUNCTION init_MVAbins return mva_array is
    VARIABLE res: mva_array( floatMVABins'LENGTH - 1 DOWNTO 0 ) := ( OTHERS => ( OTHERS=>'0' ) ) ;
  BEGIN
    FOR k IN 0 TO floatMVABins'LENGTH - 1 LOOP
        res( k ) := TO_SIGNED( INTEGER(floatMVABins( k )*32.0), 10);
    END LOOP;
    RETURN res;
  END FUNCTION;

  FUNCTION scale_v0bins( real_bins : REALS ) RETURN weight_array IS
  VARIABLE res: weight_array ( real_bins'LENGTH - 1 DOWNTO 0 ) := ( OTHERS =>  (OTHERS=>'0') );
  VARIABLE A,B,C : REAL;
  BEGIN
    FOR k IN 0 TO real_bins'LENGTH - 1 LOOP
        A := real_bins(k) / 8.0;
        res( k ) := TO_SIGNED(INTEGER(A),widthDSPportA);
    END LOOP;
    RETURN res;
  END FUNCTION;


  FUNCTION scale_v1bins( real_bins : REALS ) RETURN weight_array IS
  VARIABLE res: weight_array ( real_bins'LENGTH - 1 DOWNTO 0 ) := ( OTHERS =>  (OTHERS=>'0')   );
  VARIABLE A,B,C : REAL;
  BEGIN
    FOR k IN 0 TO real_bins'LENGTH - 1 LOOP
        A := real_bins(k) * REAL(2**18);
        res( k ) := TO_SIGNED(INTEGER(A),widthDSPportA);
    END LOOP;
    RETURN res;
  END FUNCTION;

  FUNCTION scale_chi2rphibins( real_bins : REALS ) RETURN chi_array IS
  VARIABLE res: chi_array ( real_bins'LENGTH - 1 DOWNTO 0 ) := ( OTHERS =>  (OTHERS=>'0')   );
  VARIABLE A : SFIXED(36 DOWNTO -12);
  BEGIN
    FOR k IN 0 TO real_bins'LENGTH - 1 LOOP
        A := TO_SFIXED(real_bins(k),36,-12);
        res( k ) := TO_SIGNED(A,widthDSPportC);
    END LOOP;
    RETURN res;
  END FUNCTION;

   FUNCTION scale_chi2rzbins( real_bins : REALS ) RETURN chi_array IS
  VARIABLE res: chi_array ( real_bins'LENGTH - 1 DOWNTO 0 ) := ( OTHERS =>  (OTHERS=>'0')   );
  VARIABLE A : SFIXED(36 DOWNTO -12);
  BEGIN
    FOR k IN 0 TO real_bins'LENGTH - 1 LOOP
        A := TO_SFIXED(real_bins(k),36,-12);
        res( k ) := TO_SIGNED(A,widthDSPportC);
    END LOOP;
    RETURN res;
  END FUNCTION;

  FUNCTION init_cotBins RETURN INTEGER_VECTOR IS
    VARIABLE res : INTEGER_VECTOR( 0 TO numSectorsEta - 1 ) := ( OTHERS => 0 ) ;
  BEGIN
    FOR k IN 0 TO numSectorsEta - 1 LOOP
        res( k ) := INTEGER( ( sinh( etaBoundaries( k + 1 )) + sinh( etaBoundaries( k ))) * ( 0.5 / CotFactor ));
    END LOOP;
    RETURN res;
  END FUNCTION;


END kfout_config;