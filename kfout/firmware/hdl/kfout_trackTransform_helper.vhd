LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE ieee.math_real.ALL;
USE IEEE.FIXED_PKG.ALL;

LIBRARY work;
USE work.hybrid_config.ALL;
USE work.hybrid_data_types.ALL;
USE work.hybrid_data_formats.ALL;
USE work.kfout_config.ALL;
USE work.kfout_data_formats.ALL;
USE work.kfout_luts.ALL;

PACKAGE tracktransform_helper IS
  FUNCTION HitPattern ( stubs : t_stubsKF )               RETURN STD_LOGIC_VECTOR;
  FUNCTION Chi2Packer (chi2 : SIGNED; bins : chi_array) RETURN UNSIGNED;
  FUNCTION MVAPacker (MVA : SIGNED; bins : MVA_array) RETURN UNSIGNED;

  FUNCTION Nstub ( hitmask : STD_LOGIC_VECTOR ) RETURN INTEGER;
  FUNCTION Ninterior ( hitmask : STD_LOGIC_VECTOR ) RETURN INTEGER;

  CONSTANT Chi2RPhiBins: chi_array := scale_chi2rphibins(rescaledChi2RphiBins);
  CONSTANT Chi2RZBins:   chi_array := scale_chi2rzbins(rescaledChi2RZBins);

  CONSTANT MVABins : mva_array := init_MVAbins;
  CONSTANT CotBins : INTEGER_VECTOR := init_cotBins;

  CONSTANT v0Bins : weight_array := scale_v0bins( FloatV0Bins );
  CONSTANT v1Bins : weight_array := scale_v1bins( FloatV1Bins );

END tracktransform_helper;

PACKAGE BODY tracktransform_helper IS

  FUNCTION HitPattern ( stubs : t_stubsKF ) RETURN STD_LOGIC_VECTOR IS  
  VARIABLE hits : STD_LOGIC_VECTOR( numLayers - 1 DOWNTO 0 ) := ( OTHERS => '0' );
  BEGIN
    FOR i IN 0 TO numLayers-1 LOOP
      IF TO_BOOLEAN(stubs( i ).valid ) THEN hits( i ) := '1';
      ELSE hits( i ) := '0';
      END IF;
    END LOOP;
  RETURN hits; 
  END FUNCTION HitPattern;

  FUNCTION Chi2Packer ( chi2 : SIGNED; bins : chi_array ) RETURN UNSIGNED IS
  VARIABLE chi : UNSIGNED( widthChi2RPhi - 1 DOWNTO 0 ) := ( OTHERS => '0' );
  BEGIN
  FOR i in 0 TO bins'LENGTH - 2 LOOP
    IF ( chi2 > bins( i ) ) AND ( chi2 <= bins( i + 1) ) THEN
      chi := TO_UNSIGNED( (i), widthChi2RPhi ); 
      EXIT;
    END IF;
  END LOOP;
  RETURN chi;
  END FUNCTION Chi2Packer;

  FUNCTION MVAPacker ( MVA : SIGNED; bins : MVA_array ) RETURN UNSIGNED IS
  VARIABLE mva_out : UNSIGNED( widthTQMVA - 1 DOWNTO 0 ) := ( OTHERS => '0' );
  BEGIN
  FOR i in 0 TO bins'LENGTH - 2 LOOP
    IF ( MVA > bins( i )) AND ( MVA <= bins( i + 1)) THEN
      mva_out := TO_UNSIGNED( (i), widthTQMVA ); 
      EXIT;
    END IF;
  END LOOP;
  RETURN mva_out;
  END FUNCTION MVAPacker;

  FUNCTION Nstub ( hitmask : STD_LOGIC_VECTOR ) RETURN INTEGER IS  --Function to calculate N stub from hitmask and return if > 3
  VARIABLE temp_count : NATURAL := 0;
  BEGIN
    FOR i IN hitmask'RANGE LOOP
      IF hitmask( i ) = '1' THEN temp_count := temp_count + 1;
      END IF;
    END LOOP;
  RETURN temp_count; 
  END FUNCTION Nstub;

  FUNCTION Ninterior ( hitmask : STD_LOGIC_VECTOR ) RETURN INTEGER IS  --Function to calculate N stub from hitmask and return if > 3
  VARIABLE temp_count : INTEGER := 0;
  BEGIN
    IF hitmask( 0 ) = '1' THEN
      FOR i IN 1 TO 5 LOOP
        IF hitmask( i ) = '0' THEN temp_count := temp_count + 1;
      END IF;
      END LOOP;


    ELSIF hitmask( 0 ) = '0' AND hitmask( 1 ) = '1'  THEN
      FOR i IN 2 TO 5 LOOP
        IF hitmask( i ) = '0' THEN temp_count := temp_count + 1;
      END IF;
      END LOOP;

    END IF;
  RETURN temp_count; 
  END FUNCTION Ninterior;

END tracktransform_helper;