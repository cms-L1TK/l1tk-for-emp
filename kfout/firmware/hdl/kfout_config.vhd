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

CONSTANT DSP27precision      : NATURAL := 27; -- precision of DSP48e2 (18 x 27 bit multiplier)
CONSTANT DSP18precision      : NATURAL := 18; -- precision of DSP48e2 (18 x 27 bit multiplier)
CONSTANT DSP45Totalprecision : NATURAL := DSP27precision + DSP18precision;

TYPE VECTOR_ARRAY   IS ARRAY ( NATURAL RANGE <> ) OF STD_LOGIC_VECTOR( 63 DOWNTO 0);
-- rtl_synthesis off
TYPE INTEGER_VECTOR IS ARRAY ( NATURAL RANGE <> )  OF INTEGER;
-- rtl_synthesis on

-- TRACK TRANSFORM SPECIFIC CONFIG

CONSTANT zscaleLatency   : NATURAL := 5;
CONSTANT phiscaleLatency : NATURAL := 5;
CONSTANT chiLatency      : NATURAL := 7;

CONSTANT WeightWidth : NATURAL := 16;

CONSTANT zTfactor   : REAL := 0.00999469;
CONSTANT CotFactor  : REAL := 0.000244141;
CONSTANT InvRFactor : REAL := 5.20424e-07	;
CONSTANT PhiTFactor : REAL := 0.000340885;

CONSTANT z0Factor      : INTEGER := 22;
CONSTANT modChosenRofZ : REAL := (chosenRofZ * (CotFactor/zTfactor)) * REAL(2**z0Factor); 

CONSTANT phi0Factor         : INTEGER := 22;
CONSTANT modChosenRofPhi    : REAL    := (chosenRofPhi * (InvRFactor / PhiTFactor )) * REAL( 2**phi0Factor );
CONSTANT BaseSector         : REAL    :=  0.1745;
CONSTANT IntBaseSector      : REAL    := BaseSector / PhiTFactor;
CONSTANT UnsignedBaseSector : UNSIGNED( widthKFphiT - 1 DOWNTO 0 ) := TO_UNSIGNED(INTEGER(IntBaseSector),widthKFPhiT);

CONSTANT nParPhi : NATURAL := 2;
CONSTANT nParZ   : NATURAL := 2;
CONSTANT nPar    : NATURAL := nParPhi + nParZ;
CONSTANT dofPhi  : NATURAL := numLayers - nParPhi;
CONSTANT dofZ    : NATURAL := numLayers - nParZ;

TYPE weight_array IS ARRAY ( NATURAL RANGE <> ) OF UNSIGNED( WeightWidth - 1 DOWNTO 0);

CONSTANT numdPhiBins : NATURAL := 13;
TYPE dphi_array IS ARRAY( numdPhiBins - 1 DOWNTO 0 ) OF UNSIGNED( widthKFdphi - 1 DOWNTO 0 ) ;
CONSTANT INTdPhiBins : reals( 0 TO numdPhiBins )     := ( 0.0,10.0,35.0,70.0,100.0,130.0,165.0,200.0,225.0,260.0,300.0,330.0,360.0,512.0 );
CONSTANT INTv0Bins   : reals( 0 TO numdPhiBins - 1 ) := ( 32716.0, 7139.0, 209.0, 82.0, 43.0, 26.0, 18.0, 13.0, 9.0, 7.0, 6.0, 5.0, 4.0  );

CONSTANT numdZBins : NATURAL := 14;
TYPE dz_array IS ARRAY( numdZBins - 1 DOWNTO 0 ) OF UNSIGNED( widthKFdz - 1 DOWNTO 0 ) ;
CONSTANT INTdZBins : REALS( 0 TO numdZBins )     := ( 0.0,100.0,150.0,233.0,266.0,300.0,333.0,366.0,400.0,433.0,466.0,500.0,533.0,566.0,1024.0 );
CONSTANT INTv1Bins : REALS( 0 TO numdZBins - 1 ) := ( 63607.0, 486.0, 155.0, 121.0, 97.0, 77.0, 63.0, 52.0, 44.0, 39.0, 33.0, 29.0, 26.0, 0.0  );

CONSTANT FloatChi2RPhiBins : REALS( 0 TO ( 2**widthChi2RPhi )) := ( 0.0, 0.25, 0.5, 1.0, 2.0, 3.0, 5.0, 7.0, 10.0, 20.0, 40.0, 100.0, 200.0, 500.0, 1000.0, 3000.0,6000.0 );
CONSTANT FloatChi2RZBins   : REALS( 0 TO ( 2**widthChi2RZ   )) := ( 0.0, 0.25, 0.5, 1.0, 2.0, 3.0, 5.0, 7.0, 10.0, 20.0, 40.0, 100.0, 200.0, 500.0, 1000.0, 3000.0,6000.0 );
CONSTANT FloatBendChi2Bins : REALS( 0 TO ( 2**widthBendChi2 )) := ( 0.0, 0.5, 1.25, 2.0, 3.0, 5.0, 10.0, 50.0, 5000.0 );
TYPE chi_array IS ARRAY( NATURAL RANGE <> ) OF UNSIGNED( DSP45Totalprecision - 1 DOWNTO 0 ) ;

CONSTANT Chi2RPhiConv : INTEGER := 525;
CONSTANT Chi2RZConv   : INTEGER := 626;
CONSTANT BendChi2Conv : INTEGER := 10;

CONSTANT ChiRescale   : INTEGER := 1024;

--- LINK OUTPUT formatting specific constants

CONSTANT frame_delay        : INTEGER := 13; --Constant latency of all algorithm steps
CONSTANT null_packets       : INTEGER := 6;  --Number of null packets to send between events
CONSTANT PacketBufferLength : INTEGER := 20;  --Depth of buffer for output packets

TYPE PacketArray IS ARRAY( INTEGER RANGE <> ) of STD_LOGIC_VECTOR( widthpartialTTTrack*2  - 1 DOWNTO 0 );

TYPE cot_array IS ARRAY( NATURAL RANGE <> ) OF SIGNED( widthKFcot - 1 DOWNTO 0 ) ;

FUNCTION TO_STD_LOGIC( arg  : BOOLEAN )   RETURN STD_ULOGIC;
FUNCTION TO_BOOLEAN( arg    : STD_LOGIC ) RETURN BOOLEAN;

FUNCTION init_chi2Bins(   bins : REALS; conversion : INTEGER; nbins : NATURAL ) RETURN chi_array;
FUNCTION init_dzbins(     bins : REALS )                                        RETURN dz_array;
FUNCTION init_dphibins(   bins : REALS )                                        RETURN dphi_array;
FUNCTION init_weightbins( bins : REALS; numBins : NATURAL )                     RETURN weight_array;
FUNCTION init_cotBins                                                           RETURN cot_array;



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

  FUNCTION init_chi2Bins( bins : reals; conversion : INTEGER; nbins : NATURAL ) return chi_array is
    VARIABLE res: chi_array( nbins DOWNTO 0 ) := ( OTHERS => ( OTHERS=>'0' ) ) ;
  BEGIN
    FOR k IN 0 TO bins'LENGTH - 1 LOOP
        res( k ) := TO_UNSIGNED( INTEGER( bins( k )*REAL( conversion ) ), DSP45Totalprecision );
    END LOOP;
    RETURN res;
  END FUNCTION;

  FUNCTION init_dzbins( bins : REALS ) RETURN dz_array IS
    VARIABLE res: dz_array;
  BEGIN
    FOR k IN 0 TO bins'LENGTH - 2 LOOP
        res( k ) := TO_UNSIGNED(INTEGER(bins( k )),widthKFdz);
    END LOOP;
    RETURN res;
  END FUNCTION;

  FUNCTION init_dphibins( bins : REALS ) RETURN dphi_array IS
    VARIABLE res: dphi_array ;
  BEGIN
    FOR k IN 0 TO bins'LENGTH - 2 LOOP
        res( k ) := TO_UNSIGNED(INTEGER(bins( k )),widthKFdphi);
    END LOOP;
    RETURN res;
  END FUNCTION;

  FUNCTION init_weightbins( bins : REALS ; numBins : NATURAL ) RETURN weight_array IS
    VARIABLE res: weight_array ( numBins - 1 DOWNTO 0 ) := ( OTHERS => ( OTHERS => '0' ) ) ;
  BEGIN
    FOR k IN 0 TO bins'LENGTH - 1 LOOP
        res( k ) := TO_UNSIGNED( INTEGER( bins( k ) ), WeightWidth );
    END LOOP;
    RETURN res;
  END FUNCTION;

  FUNCTION init_cotBins RETURN cot_array IS
    VARIABLE res : cot_array( 0 TO numSectorsEta ) := ( OTHERS => ( OTHERS=>'0' ) ) ;
  BEGIN
    FOR k IN 0 TO numSectorsEta - 1 LOOP
        res( k ) := TO_SIGNED( INTEGER( ( sinh( etaBoundaries( k + 1 )) + sinh( etaBoundaries( k ))) * ( 0.5 / CotFactor )), widthKFcot );
    END LOOP;
    RETURN res;
  END FUNCTION;


END kfout_config;