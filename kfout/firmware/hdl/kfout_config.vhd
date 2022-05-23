LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE ieee.math_real.ALL;

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
CONSTANT chiLatency      : NATURAL := 7;

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

TYPE weight_array IS ARRAY ( NATURAL RANGE <> ) OF INTEGER;

CONSTANT WeightBinFraction : INTEGER := 0;   -- Num bits dropped from dPhi and dZ bins
CONSTANT numdPhiBins : NATURAL := 2**(9 - WeightBinFraction);
CONSTANT numdZBins : NATURAL := 2**(10 - WeightBinFraction);
CONSTANT chiZRescale: REAL := 1024.0;
CONSTANT chiPhiRescale: REAL := 1024.0;
CONSTANT basedZ : REAL := 0.0399788;
CONSTANT basedPhi : REAL := 4.26106e-05;


CONSTANT FloatChi2RPhiBins : REALS( 0 TO ( 2**widthChi2RPhi )) := ( 0.0, 0.25, 0.5, 1.0, 2.0, 3.0, 5.0, 7.0, 10.0, 20.0, 40.0, 100.0, 200.0, 500.0, 1000.0, 3000.0,6000.0 );
CONSTANT FloatChi2RZBins   : REALS( 0 TO ( 2**widthChi2RZ   )) := ( 0.0, 0.25, 0.5, 1.0, 2.0, 3.0, 5.0, 7.0, 10.0, 20.0, 40.0, 100.0, 200.0, 500.0, 1000.0, 3000.0,6000.0 );
CONSTANT FloatBendChi2Bins : REALS( 0 TO ( 2**widthBendChi2 )) := ( 0.0, 0.5, 1.25, 2.0, 3.0, 5.0, 10.0, 50.0, 5000.0 );
TYPE chi_array IS ARRAY( NATURAL RANGE <> ) OF SIGNED( widthDSPportC - 1 DOWNTO 0 ) ;

CONSTANT Chi2RPhiConv : REAL := 3.0;
CONSTANT Chi2RZConv   : REAL := 13.0;
CONSTANT BendChi2Conv : REAL := 1.0;

--- LINK OUTPUT formatting specific constants

CONSTANT total_frame_delay  : INTEGER := 15; --Constant latency of all algorithm steps
CONSTANT PacketBufferLength : INTEGER := 104;  --Depth of buffer for output packets

TYPE PacketArray IS ARRAY( INTEGER RANGE <> ) of STD_LOGIC_VECTOR( widthpartialTTTrack*2  - 1 DOWNTO 0 );

TYPE cot_array IS ARRAY( NATURAL RANGE <> ) OF SIGNED( widthKFcot - 1 DOWNTO 0 ) ;

FUNCTION TO_STD_LOGIC( arg  : BOOLEAN )   RETURN STD_ULOGIC;
FUNCTION TO_BOOLEAN( arg    : STD_LOGIC ) RETURN BOOLEAN;

FUNCTION init_weightbins( base : REAL; numBins : NATURAL; scale : REAL )                      RETURN weight_array;
FUNCTION init_cotBins                                                           RETURN INTEGER_VECTOR;
FUNCTION init_chi2RPhiBins                                                      return chi_array;
FUNCTION init_chi2RZBins                                                        return chi_array;



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

  FUNCTION init_chi2RPhiBins return chi_array is
    VARIABLE res: chi_array( FloatChi2RPhiBins'LENGTH - 1 DOWNTO 0 ) := ( OTHERS => ( OTHERS=>'0' ) ) ;
  BEGIN
    FOR k IN 0 TO FloatChi2RPhiBins'LENGTH - 1 LOOP
        res( k ) := TO_SIGNED( INTEGER ((FloatChi2RPhiBins( k ))*REAL(basedPhi**(-2) / (chiPhiRescale*Chi2RPhiConv) )), widthDSPportC);
    END LOOP;
    RETURN res;
  END FUNCTION;

  FUNCTION init_chi2RZBins return chi_array is
    VARIABLE res: chi_array( FloatChi2RZBins'LENGTH - 1 DOWNTO 0 ) := ( OTHERS => ( OTHERS=>'0' ) ) ;
  BEGIN
    FOR k IN 0 TO FloatChi2RZBins'LENGTH - 1 LOOP
        res( k ) := TO_SIGNED( INTEGER ((FloatChi2RZBins( k ))*REAL(basedZ **(-2) * chiZRescale/ Chi2RZConv )), widthDSPportC );
    END LOOP;
    RETURN res;
  END FUNCTION;

  FUNCTION init_weightbins( base : REAL ; numBins : NATURAL; scale : REAL ) RETURN weight_array IS
    VARIABLE res: weight_array ( numBins - 1 DOWNTO 0 ) := ( OTHERS =>  0  );
    VARIABLE A,B,C : REAL;
  BEGIN
    FOR k IN 0 TO numBins - 1 LOOP
        A := base*REAL(k+1);
        B := A * REAL(2**(WeightBinFraction));
        C := B**(-2);
        res( k ) := INTEGER(C / scale);
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