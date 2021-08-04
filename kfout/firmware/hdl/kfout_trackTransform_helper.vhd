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
  FUNCTION v0 ( dPhi : UNSIGNED)                          RETURN UNSIGNED;
  FUNCTION v1 ( dZ  :  UNSIGNED)                          RETURN UNSIGNED;
  FUNCTION Chi2Packer (chi2 : UNSIGNED; bins : chi_array) RETURN UNSIGNED;

  CONSTANT Chi2RPhiBins: chi_array := init_chi2Bins( FloatChi2RPhiBins, Chi2RPhiConv, 2**widthChi2RPhi );
  CONSTANT Chi2RZBins:   chi_array := init_chi2Bins( FloatChi2RZBins,   Chi2RZConv,   2**widthChi2RZ   );
  CONSTANT BendChi2Bins: chi_array := init_chi2Bins( FloatBendChi2Bins, BendChi2Conv, 2**widthBendChi2 );
  CONSTANT CotBins :     cot_array := init_cotBins;

  CONSTANT dZBins   : dz_array   := init_dzbins(   INTdZBins   );
  CONSTANT dPhiBins : dphi_array := init_dphibins( INTdPhiBins );

  CONSTANT v0Bins : weight_array := init_weightbins( INTv0Bins, numdPhiBins );
  CONSTANT v1Bins : weight_array := init_weightbins( INTv1Bins, numdZBins   );

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

  FUNCTION v0 ( dPhi : UNSIGNED ) RETURN UNSIGNED IS
  VARIABLE v0 : UNSIGNED( WeightWidth - 1 DOWNTO 0 ) := ( OTHERS => '0' );
  BEGIN
  FOR i in 0 TO numdPhiBins-2 LOOP
    IF ( dPhi > dPhiBins( i ) ) AND ( dPhi <= dPhiBins( i + 1 ) ) THEN
      v0 := v0Bins( i );
      EXIT;
    END IF;
  END LOOP;
  RETURN v0;
  END FUNCTION v0;

  FUNCTION v1 ( dZ :  UNSIGNED ) RETURN UNSIGNED IS
  VARIABLE v1 : UNSIGNED( WeightWidth - 1 DOWNTO 0 ) := ( OTHERS => '0' );
  BEGIN
  FOR i in 0 TO numdZBins-2 LOOP
    IF ( dZ > dZBins( i ) ) AND ( dZ <= dZBins( i + 1 ) ) THEN
      v1 := v1Bins( i );
      EXIT;
    END IF;
  END LOOP;
  RETURN v1;
  END FUNCTION v1;

  FUNCTION Chi2Packer ( chi2 : UNSIGNED; bins : chi_array ) RETURN UNSIGNED IS
  VARIABLE chi : UNSIGNED( widthChi2RPhi - 1 DOWNTO 0 ) := ( OTHERS => '0' );
  BEGIN
  FOR i in 0 TO bins'LENGTH - 2 LOOP
    IF ( chi2 > bins( i ) ) AND ( chi2 <= bins( i + 1) ) THEN
      chi := TO_UNSIGNED( i, widthChi2RPhi );
      EXIT;
    END IF;
  END LOOP;
  RETURN chi;
  END FUNCTION Chi2Packer;

 
END tracktransform_helper;