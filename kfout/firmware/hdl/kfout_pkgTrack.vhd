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

-- .library Track
-- .include ReuseableElements/PkgUtilities.vhd

-- -------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE STD.TEXTIO.ALL;

library work;
use work.hybrid_config.all;
use work.hybrid_data_formats.all;

use work.kfout_data_formats.all;
use work.kfout_config.all;
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
PACKAGE DataType IS
-- -------------------------------------------------------------------------

--  Track Word 
  TYPE tData IS RECORD

  TrackValid : STD_LOGIC;
  extraMVA   : UNSIGNED( widthExtraMVA   - 1 downto 0 );
  TQMVA      : UNSIGNED( widthTQMVA      - 1 downto 0 );
  HitPattern : UNSIGNED( widthHitPattern - 1 downto 0 );
  BendChi2   : UNSIGNED( widthBendChi2   - 1 downto 0 );
  Chi2RPhi   : UNSIGNED( widthChi2RPhi   - 1 downto 0 );
  Chi2RZ     : UNSIGNED( widthChi2RZ     - 1 downto 0 );
  D0         :   SIGNED( widthD0         - 1 downto 0 );
  Z0         :   SIGNED( widthZ0         - 1 downto 0 );
  TanL       :   SIGNED( widthTanL       - 1 downto 0 );
  Phi0       :   SIGNED( widthPhi0       - 1 downto 0 );
  InvR       :   SIGNED( widthInvR       - 1 downto 0 );

  -- Utility field, used for the key in the distribution server 
  SortKey    : INTEGER RANGE 0 TO (numLinksTFP - 1);

  Reset      : STD_LOGIC;
  DataValid  : BOOLEAN;
  FrameValid : BOOLEAN;

END RECORD;

ATTRIBUTE SIZE : NATURAL;
ATTRIBUTE SIZE of tData : TYPE IS widthTTTrack + 3;

-- -------------------------------------------------------------------------       

-- A record to encode the bit location of each field of the tData record
-- when packaged into a std_logic_vector
  TYPE tFieldLocations IS RECORD
    extraMVAl   : INTEGER;
    extraMVAh   : INTEGER;
    TQMVAl      : INTEGER;
    TQMVAh      : INTEGER;
    HitPatternl : INTEGER;
    HitPatternh : INTEGER;
    BendChi2l   : INTEGER;
    BendChi2h   : INTEGER;
    D0l         : INTEGER;
    D0h         : INTEGER;
    
    Chi2RZl     : INTEGER;
    Chi2RZh     : INTEGER;
    Z0l         : INTEGER;
    Z0h         : INTEGER;
    TanLl       : INTEGER;
    TanLh       : INTEGER;
    
    Chi2RPhil   : INTEGER;
    Chi2RPhih   : INTEGER;
    Phi0l       : INTEGER;
    Phi0h       : INTEGER;
    InvRl       : INTEGER;
    InvRh       : INTEGER;
    
    TrackValidi : INTEGER;
-- -----------------------------------------
   
  END RECORD;

  --CONSTANT bitloc                      : tFieldLocations := ( 0  , 14 ,   --InvR
  --                                                            15 , 26 ,   --Phi
  --                                                            27 , 42 ,   --Tanl
  --                                                            43 , 54 ,   --Z0
  --                                                            55 , 57 ,   --MVAQ
  --                                                            58 , 63 ,   --MVAres
  --                                                            0  , 12 ,   --D0
  --                                                            13 , 16 ,   --Chirphi
  --                                                            17 , 20 ,   --Chirz
  --                                                            21 , 23 ,   --BendChi
  --                                                            24 , 30 ,   --HitPattern
  --                                                            31          --TrackValid
  --                                                            );

  CONSTANT bitloc                      : tFieldLocations := (                     0  ,                                                           widthExtraMVA - 1 ,   --extra_MVA
                                                                       widthExtraMVA ,                                              widthTQMVA + widthExtraMVA - 1 ,   --TQ_MVA
                                                          widthTQMVA + widthExtraMVA ,                           widthHitPattern +  widthTQMVA + widthExtraMVA - 1 ,   --HitPattern
                                       widthHitPattern +  widthTQMVA + widthExtraMVA ,           widthBendChi2 + widthHitPattern +  widthTQMVA + widthExtraMVA - 1 ,   --BendChi2
                       widthBendChi2 + widthHitPattern +  widthTQMVA + widthExtraMVA , widthD0 + widthBendChi2 + widthHitPattern +  widthTQMVA + widthExtraMVA - 1 ,   --D0
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------
                                                                 widthpartialTTTrack ,                       widthChi2RZ -1 + widthpartialTTTrack , --Chi2RZ
                                                   widthChi2RZ + widthpartialTTTrack ,             widthZ0 + widthChi2RZ -1 + widthpartialTTTrack , --Z0
                                         widthZ0 + widthChi2RZ + widthpartialTTTrack , widthTanL + widthZ0 + widthChi2RZ -1 + widthpartialTTTrack , --TanL
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------
                                                               widthpartialTTTrack*2 ,                         widthChi2RPhi -1 + 2*widthpartialTTTrack ,   --Chi2RPhi
                                               widthChi2RPhi + 2*widthpartialTTTrack ,             widthPhi0 + widthChi2RPhi -1 + 2*widthpartialTTTrack ,   --Phi0
                                   widthPhi0 + widthChi2RPhi + 2*widthpartialTTTrack , widthInvR + widthPhi0 + widthChi2RPhi -1 + 2*widthpartialTTTrack ,   --InvR
                       widthInvR + widthPhi0 + widthChi2RPhi + 2*widthpartialTTTrack    --valid
);
  -- split across 2 different links!
  CONSTANT cNull                       : tData           := (  '0'  ,  -- Valid
                                                              ( OTHERS => '0' ) ,  --ExtraMVA
                                                              ( OTHERS => '0' ) ,  --TQMVA
                                                              ( OTHERS => '0' ) ,  --HitPattern
                                                              ( OTHERS => '0' ) ,  --BendChi2
                                                              ( OTHERS => '0' ) ,  --D0

                                                              ( OTHERS => '0' ) ,  --Chi2RZ
                                                              ( OTHERS => '0' ) ,  --Z0
                                                              ( OTHERS => '0' ) ,  --TanL

                                                              ( OTHERS => '0' ) ,  --Chi2rphi
                                                              ( OTHERS => '0' ) ,  --Phi
                                                              ( OTHERS => '0' ) ,  --InvR

                                                              0,                  --SortKey
                                                              '0',                --Reset
                                                              false ,             --DataValid
                                                              false               --FrameValid
                                                               );  
  FUNCTION ToStdLogicVector( aData     : tData ) RETURN STD_LOGIC_VECTOR;
  FUNCTION ToDataType( aStdLogicVector : STD_LOGIC_VECTOR ) RETURN tData;
-- -------------------------------------------------------------------------       

END DataType;
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
PACKAGE BODY DataType IS

  FUNCTION ToStdLogicVector( aData : tData ) RETURN STD_LOGIC_VECTOR IS
    VARIABLE lRet                  : STD_LOGIC_VECTOR( widthTTTrack + 2 DOWNTO 0 ) := ( OTHERS => '0' );
  BEGIN 
    lRet( bitloc.extraMVAh   DOWNTO bitloc.extraMVAl   )  := STD_LOGIC_VECTOR( aData.extraMVA   );
    lRet( bitloc.TQMVAh      DOWNTO bitloc.TQMVAl      )  := STD_LOGIC_VECTOR( aData.TQMVA      );
    lRet( bitloc.Hitpatternh DOWNTO bitloc.Hitpatternl )  := STD_LOGIC_VECTOR( aData.Hitpattern );
    lRet( bitloc.BendChi2h   DOWNTO bitloc.BendChi2l   )  := STD_LOGIC_VECTOR( aData.BendChi2   );
    lRet( bitloc.D0h         DOWNTO bitloc.D0l         )  := STD_LOGIC_VECTOR( aData.D0         );

    lRet( bitloc.Chi2rzh     DOWNTO bitloc.Chi2rzl     )  := STD_LOGIC_VECTOR( aData.Chi2rz     );
    lRet( bitloc.Z0h         DOWNTO bitloc.Z0l         )  := STD_LOGIC_VECTOR( aData.Z0         );
    lRet( bitloc.TanLh       DOWNTO bitloc.TanLl       )  := STD_LOGIC_VECTOR( aData.TanL       );

    lRet( bitloc.Chi2rphih   DOWNTO bitloc.Chi2rphil   )  := STD_LOGIC_VECTOR( aData.Chi2rphi   );
    lRet( bitloc.Phi0h       DOWNTO bitloc.Phi0l       )  := STD_LOGIC_VECTOR( aData.Phi0       );
    lRet( bitloc.InvRh       DOWNTO bitloc.InvRl       )  := STD_LOGIC_VECTOR( aData.InvR       );
    lRet( bitloc.TrackValidi  )                           := aData.TrackValid ;

    lRet( bitloc.TrackValidi + 1 )                               := to_std_logic( aData.DataValid );
    lRet( bitloc.TrackValidi + 2 )                               := aData.Reset ;
    lRet( bitloc.TrackValidi + 3 DOWNTO bitloc.TrackValidi + 3 ) := STD_LOGIC_VECTOR( TO_UNSIGNED( aData.SortKey , 1 ) );


   

    RETURN lRet;
  END FUNCTION;

  FUNCTION ToDataType( aStdLogicVector : STD_LOGIC_VECTOR ) RETURN tData IS
    VARIABLE lRet                      : tData := cNull;
  BEGIN      
    lRet.extraMVA   := UNSIGNED ( aStdLogicVector( bitloc.extraMVAh   DOWNTO bitloc.extraMVAl   ) );        
    lRet.TQMVA      := UNSIGNED ( aStdLogicVector( bitloc.TQMVAh      DOWNTO bitloc.TQMVAl  ) );        
    lRet.Hitpattern := UNSIGNED ( aStdLogicVector( bitloc.Hitpatternh DOWNTO bitloc.Hitpatternl ) );        
    lRet.BendChi2   := UNSIGNED ( aStdLogicVector( bitloc.BendChi2h   DOWNTO bitloc.BendChi2l   ) );  
    lRet.D0         :=   SIGNED ( aStdLogicVector( bitloc.D0h         DOWNTO bitloc.D0l         ) );      

    lRet.Chi2rz     := UNSIGNED ( aStdLogicVector( bitloc.Chi2rzh     DOWNTO bitloc.Chi2rzl     ) );      
    lRet.Z0         :=   SIGNED ( aStdLogicVector( bitloc.Z0h         DOWNTO bitloc.Z0l         ) );
    lRet.TanL       :=   SIGNED ( aStdLogicVector( bitloc.TanLh       DOWNTO bitloc.TanLl       ) );      

    lRet.Chi2rphi   := UNSIGNED ( aStdLogicVector( bitloc.Chi2rphih   DOWNTO bitloc.Chi2rphil   ) );        
    lRet.Phi0       :=   SIGNED ( aStdLogicVector( bitloc.Phi0h       DOWNTO bitloc.Phi0l      ) ); 
    lRet.InvR       :=   SIGNED ( aStdLogicVector( bitloc.InvRh       DOWNTO bitloc.InvRl       ) );  
    lRet.TrackValid := aStdLogicVector( bitloc.TrackValidi  ) ; 

    lRet.DataValid  := to_boolean( aStdLogicVector( bitloc.TrackValidi + 1 ) );
    lRet.Reset      := ( aStdLogicVector( bitloc.TrackValidi + 2 ) );
    lRet.SortKey    := TO_INTEGER( UNSIGNED( aStdLogicVector( bitloc.TrackValidi + 3 DOWNTO bitloc.TrackValidi + 3 ) ) );
    
    RETURN lRet;
  END FUNCTION;

END DataType;