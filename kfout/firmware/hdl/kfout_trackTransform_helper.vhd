LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE ieee.math_real.ALL;

LIBRARY work;
USE work.hybrid_config.ALL;
USE work.hybrid_data_types.ALL;
USE work.hybrid_data_formats.ALL;
USE work.kfout_config.ALL;
USE work.kfout_data_formats.ALL;

PACKAGE tracktransform_helper IS
  FUNCTION HitPattern ( stubs : t_stubsKF )               RETURN STD_LOGIC_VECTOR;
  FUNCTION Chi2Packer (chi2 : SIGNED; bins : chi_array) RETURN UNSIGNED;

  CONSTANT Chi2RPhiBins: chi_array := init_chi2RPhiBins;
  CONSTANT Chi2RZBins:   chi_array := init_chi2RZBins;
  CONSTANT CotBins :     INTEGER_VECTOR := init_cotBins;

  CONSTANT v0Bins : weight_array := init_weightbins( basedPhi, numdPhiBins, chiPhiRescale );
  CONSTANT v1Bins : weight_array := init_weightbins( basedZ, numdZBins,chiZRescale**(-1)   );

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

 
END tracktransform_helper;