LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_MISC.ALL;
USE IEEE.NUMERIC_STD.ALL;

library work;
use work.kfout_data_formats.all;
use work.kfout_config.all;

use work.hybrid_data_types.all;
use work.hybrid_data_formats.all;
use work.hybrid_config.all;

ENTITY ScaleZT IS
GENERIC(
  zdelay : NATURAL
);
PORT(  
  clk : IN  STD_LOGIC;
  zT  : IN  SIGNED( widthKFZT -1  DOWNTO 0 );
  cot : IN  SIGNED( widthKFcot -1 DOWNTO 0 );
  z0  : OUT SIGNED( widthZ0 -1    DOWNTO 0 ) := ( OTHERS => '0' )
);
END ScaleZT;

ARCHITECTURE RTL OF ScaleZT IS

    TYPE z0vector IS ARRAY( NATURAL RANGE <> ) OF SIGNED( widthZ0 - 1 DOWNTO 0 );
    SIGNAL z0signal :  SIGNED( widthZ0 - 1 DOWNTO 0 ) :=  ( OTHERS => '0' );
    SIGNAL z0array  : z0vector( 0 TO zdelay - 1 )   :=  ( OTHERS => ( OTHERS => '0' ) );

    SIGNAl A : SIGNED( widthDSPportB - 1 DOWNTO 0 )  := ( OTHERS => '0' );
    SIGNAl B : SIGNED( widthDSPportB - 1 DOWNTO 0 )  := ( OTHERS => '0' );
    SIGNAl C : SIGNED( widthDSPportC - 1 DOWNTO 0 )  := ( OTHERS => '0' );
    SIGNAl D : SIGNED( widthDSPportC - 1 DOWNTO 0 )  := ( OTHERS => '0' );

    BEGIN
      PROCESS( clk )
      BEGIN
        IF RISING_EDGE(clk) THEN
        -- Clk 1 ------------------------
          A <= RESIZE((2*cot)+1, widthDSPportB);
          B <= RESIZE((2*zT)+1, widthDSPportB);
        -- Clk 2 -----------------------
          C <= RESIZE(A * TO_SIGNED( INTEGER( modChosenRofZ ), widthDSPportA ), widthDSPportC); 
          D <= RESIZE(B * TO_SIGNED( 2**z0Factor, widthDSPportA ), widthDSPportC);
        -- Clk 3 -----------------------
        z0signal <= RESIZE(shift_right((D - C)/2,z0Factor),widthZ0);
        -- Delay Signal
        z0array  <= z0signal & z0array( 0 TO zdelay - 2 );
        z0       <= z0array( zdelay - 1 );
        END IF;
      END PROCESS;
END RTL;

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_MISC.ALL;
USE IEEE.NUMERIC_STD.ALL;


library work;
use work.kfout_data_formats.all;
use work.kfout_config.all;

use work.hybrid_data_types.all;
use work.hybrid_data_formats.all;
use work.hybrid_config.all;


ENTITY ScalePhi IS
GENERIC(
  phidelay : NATURAL 
);
PORT(  
  clk       : IN  STD_LOGIC;
  phiT      : IN  SIGNED( widthKFPhiT - 1  DOWNTO 0);
  inv2R     : IN  SIGNED( widthKFInv2R - 1 DOWNTO 0);
  phiSector : IN  STD_LOGIC;
  phi0      : OUT SIGNED( widthPhi0 - 1    DOWNTO 0) := ( OTHERS => '0' )
);
END ScalePhi;

ARCHITECTURE RTL of ScalePhi IS

    SIGNAl A : SIGNED( widthDSPportB  - 1 DOWNTO 0 )                  := ( OTHERS => '0' );
    SIGNAL B : SIGNED( widthDSPportB  - 1 DOWNTO 0 )                  := ( OTHERS => '0' );
    SIGNAL C : SIGNED( widthDSPportC  - 1 DOWNTO 0 )             := ( OTHERS => '0' );
    SIGNAL D : SIGNED( widthDSPportC  - 1 DOWNTO 0 )              := ( OTHERS => '0' );
    SIGNAL E : SIGNED( widthDSPportC  - 1 DOWNTO 0 )             := ( OTHERS => '0' );
    SIGNAL BaseSectorCorr : SIGNED( widthDSPportB - 1 DOWNTO 0 )      := ( OTHERS => '0' );

    SIGNAL phi0signal : SIGNED( widthphi0 - 1 DOWNTO 0 ) := ( OTHERS => '0' );

    TYPE phivector IS ARRAY( NATURAL range <> ) OF SIGNED( widthphi0 - 1 DOWNTO 0 );
    SIGNAL phi0array  : phivector( 0 TO phidelay - 1)     := ( OTHERS => ( OTHERS => '0' ) ); 

    BEGIN
      PROCESS( clk )
        BEGIN
        IF RISING_EDGE(clk) THEN
-- Clk 1 ------------------------------------------------------
          IF (phiSector = '0') THEN
            BaseSectorCorr <= RESIZE( -SIGNED( UnsignedBaseSector ), widthDSPportB );
          ELSE
            BaseSectorCorr <= RESIZE(  SIGNED( UnsignedBaseSector ), widthDSPportB );
          END IF;
          A <= RESIZE((2*PhiT)+1, widthDSPportB);
          B <= RESIZE(inv2R+1, widthDSPportB);
-- Clk 2 ------------------------------------------------------
          C <= RESIZE(A * TO_SIGNED( 2**phi0Factor, widthDSPportA ), widthDSPportC);
          D <= RESIZE(B * TO_SIGNED( INTEGER( modChosenRofPhi ), widthDSPportA ), widthDSPportC); 
          E <= RESIZE(BaseSectorCorr * TO_SIGNED( 2**phi0Factor, widthDSPportA ), widthDSPportC);
-- Clk 3 ------------------------------------------------------
          phi0signal <= RESIZE( SHIFT_RIGHT(( C  - D )/2 - 2*E  ,phi0Factor), widthphi0 );
-- Delay Signal
          phi0array <= phi0signal & phi0array( 0 TO phidelay - 2 );
          phi0      <= phi0array( phidelay - 1);
        END IF;
      END PROCESS;
END RTL;

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_MISC.ALL;
USE IEEE.NUMERIC_STD.ALL;

use work.kfout_data_formats.all;
use work.kfout_config.all;

use work.tracktransform_helper.all;

use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.hybrid_data_formats.all;


ENTITY CalculateChi IS
PORT(  
  clk      : IN STD_LOGIC;
  reset    : IN STD_LOGIC;
  stubs    : IN t_stubsKF;
  Chi2Rphi : OUT UNSIGNED( widthChi2RPhi - 1 DOWNTO 0 ) := ( OTHERS => '0' );
  Chi2RZ   : OUT UNSIGNED( widthChi2RZ   - 1 DOWNTO 0 ) := ( OTHERS => '0' )
);
END CalculateChi;

ARCHITECTURE RTL of CalculateChi IS
  TYPE phizarray IS ARRAY(natural RANGE <> ) OF SIGNED( widthDSPportC - 1 DOWNTO 0);
  SIGNAL rphi : phizarray( numLayers -1 DOWNTO 0 )            := ( OTHERS => ( OTHERS => '0' ) );
  SIGNAL rz   : phizarray( numLayers -1 DOWNTO 0 )            := ( OTHERS => ( OTHERS => '0' ) );
  SIGNAL C    : SIGNED ( widthDSPportC - 1 DOWNTO 0 ) := ( OTHERS => '0' ) ;
  SIGNAL D    : SIGNED ( widthDSPportC - 1 DOWNTO 0 ) := ( OTHERS => '0' ) ;

  CONSTANT frame_delay : INTEGER := 3;

    BEGIN
    g1 : FOR i IN 0 TO numLayers - 1 GENERATE
    
      SIGNAL validarray : STD_LOGIC_VECTOR( 0 TO frame_delay - 1)  := ( OTHERS => '0' );  --Delaying frame valid signals 

      SIGNAL phi        :   SIGNED( widthKFphi     - 1 DOWNTO 0 ) := ( OTHERS => '0' );
      SIGNAL z          :   SIGNED( widthKFz       - 1 DOWNTO 0 ) := ( OTHERS => '0' );
      SIGNAL dphi       : UNSIGNED( widthKFdphi    - 1 DOWNTO 0 ) := ( OTHERS => '0' );
      SIGNAL dz         : UNSIGNED( widthKFdz      - 1 DOWNTO 0 ) := ( OTHERS => '0' );

      SIGNAL phisquared :   SIGNED( widthDSPportB - 1 DOWNTO 0 ) := ( OTHERS => '0' );
      SIGNAL zsquared   :   SIGNED( widthDSPportB - 1 DOWNTO 0 ) := ( OTHERS => '0' );

      SIGNAL tempv0 :   SIGNED( widthDSPportA - 1 DOWNTO 0) := ( OTHERS => '0' ); 
      SIGNAL tempv1 :   SIGNED( widthDSPportA - 1 DOWNTO 0) := ( OTHERS => '0' ); 

      SIGNAL temprphi_0 : SIGNED( widthDSPportC - 1 DOWNTO 0 ):= ( OTHERS => '0' );
      SIGNAL temprz_0   : SIGNED( widthDSPportC - 1 DOWNTO 0 ):= ( OTHERS => '0' );
      SIGNAL temprphi_1 : SIGNED( widthDSPportC - 1 DOWNTO 0 ):= ( OTHERS => '0' );
      SIGNAL temprz_1   : SIGNED( widthDSPportC - 1 DOWNTO 0 ):= ( OTHERS => '0' );

      BEGIN
      PROCESS( clk )
        BEGIN
        IF RISING_EDGE(clk) THEN
          -- Clk 1 ----------------------------------------------
          validarray <= ( stubs( i ).valid ) & validarray( 0 TO frame_delay - 2 );
          phi  <=   SIGNED( stubs( i ).phi  );
          dphi <= UNSIGNED( stubs( i ).dPhi );
          z    <=   SIGNED( stubs( i ).z    );
          dz   <= UNSIGNED( stubs( i ).dZ   );
 
          --Clk 2 ----------------------------------------------
          phisquared <= RESIZE( (4*phi*phi + 4*phi + 1) ,widthDSPportB );
          tempv0     <=  v0Bins( TO_INTEGER(dphi ));
          zsquared   <= RESIZE( (4*z*z + 4*z + 1 )  , widthDSPportB );
          tempv1     <=  v1Bins( TO_INTEGER(dz ));

          --Clk 3 ------------------------------------------------
          temprphi_0 <= RESIZE(SHIFT_RIGHT((phisquared  * tempv0),2), widthDSPportC);
          temprz_0   <= RESIZE(SHIFT_RIGHT((zsquared  * tempv1),2), widthDSPportC);

          IF validarray(frame_delay - 1) = '1' THEN
            rphi( i ) <= temprphi_0 ;
            rz( i )   <= temprz_0 ;
          ELSE
            rphi( i ) <= ( OTHERS => '0' );
            rz( i )   <= ( OTHERS => '0' );
          END IF;

        END IF;
      END PROCESS;
    END GENERATE;

    PROCESS( clk )
    VARIABLE tempchi2rphi, tempchi2rz : SIGNED( widthDSPportC - 1 DOWNTO 0 ) := ( OTHERS => '0' );
      BEGIN
      
      IF RISING_EDGE( clk ) THEN
        FOR i IN 0 TO numLayers - 1 LOOP
          tempchi2rphi := tempchi2rphi + rphi( i ) ; 
          tempchi2rz   := tempchi2rz   + rz( i ) ; 
        END LOOP;

        -- Clk 5 ---------------------------------------------------
        C <= tempchi2rphi;
        D <= tempchi2rz; 
        tempchi2rphi := ( OTHERS => '0' );
        tempchi2rz   := ( OTHERS => '0' );
        -- Clk 6 ---------------------------------------------------
        Chi2Rphi <= Chi2Packer( C,Chi2RPhiBins );
        Chi2RZ   <= Chi2Packer( D,Chi2RZBins );
        
        END IF;
      END PROCESS;
END RTL;

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_MISC.ALL;
USE IEEE.NUMERIC_STD.ALL;


library work;
use work.kfout_data_formats.all;
use work.kfout_config.all;
use work.tracktransform_helper.all;

USE work.DataType.all;
USE work.ArrayTypes.all;

use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.hybrid_data_formats.all;

ENTITY kfout_trackTransform IS
PORT(
  clk          : IN STD_LOGIC; -- The algorithm clock
  KFObjectsIn  : IN t_channelsKF;
  TTTracksOut  : OUT Vector
);
END kfout_trackTransform;

ARCHITECTURE RTL OF kfout_trackTransform IS

  type hitpatternARRAY is array ( NATURAL range <>) of UNSIGNED( widthHitPattern - 1 DOWNTO 0 );
  type TanlARRAY is array ( NATURAL range <>) of SIGNED( widthTanL - 1 DOWNTO 0 );
  type InvRARRAY is array ( NATURAL range <>) of SIGNED( widthInvR - 1 DOWNTO 0 );

  SIGNAL Output : VECTOR( 0 TO numNodesKF - 1 ):= NullVector( numNodesKF );
  SIGNAL reset  : STD_LOGIC_VECTOR( 0 TO numNodesKF - 1 ) := ( OTHERS => '0' );

  CONSTANT frame_delay : INTEGER := chiLatency; --Constant latency of algorithm steps

  BEGIN
  g1 : FOR i IN 0 TO numNodesKF-1 GENERATE
    
    SIGNAL frame_signal : STD_LOGIC := '0';
    SIGNAL frame_array  : STD_LOGIC_VECTOR( 0 TO frame_delay - 1 ) := ( OTHERS => '0' );  --Delaying frame valid signals
    SIGNAL sign_array   : INTEGER_VECTOR( 0 TO frame_delay - 1 )  := ( OTHERS => 0 );  --Delaying track num signals

    SIGNAL z0  : SIGNED( widthZ0 - 1 DOWNTO 0 )    := ( OTHERS =>'0' );
    SIGNAL zT  : SIGNED( widthKFZT - 1 DOWNTO 0 )  := ( OTHERS =>'0' );
    SIGNAL cot : SIGNED( widthKFcot - 1 DOWNTO 0 ) := ( OTHERS =>'0' );

    SIGNAL phiT      : SIGNED( widthKFphiT - 1 DOWNTO 0 )  := ( OTHERS =>'0' );
    SIGNAL inv2R     : SIGNED( widthKFinv2r - 1 DOWNTO 0 ) := ( OTHERS =>'0' );
    SIGNAL phiSector : STD_LOGIC                           := '0';
    SIGNAL phi0      : SIGNED( widthPhi0 - 1 DOWNTO 0 )    := ( OTHERS =>'0' );

    SIGNAL Chi2Rphi : UNSIGNED( widthChi2RPhi - 1 DOWNTO 0 ) := ( OTHERS =>'0' );
    SIGNAL Chi2RZ   : UNSIGNED( widthChi2RZ - 1 DOWNTO 0 )   := ( OTHERS =>'0' );
    SIGNAL stubs    : t_stubsKF( numLayers-1 DOWNTO 0 )      := ( OTHERS => nulll);

    SIGNAL HitPattern_array : hitpatternARRAY( 0 TO frame_delay - 1 ) := ( OTHERS => ( OTHERS =>'0'));
    SIGNAL Tanl_array       : TanlARRAY( 0 TO frame_delay - 1 )       := ( OTHERS => ( OTHERS =>'0'));
    SIGNAL InvR_array       : InvRARRAY( 0 TO frame_delay - 1 )       := ( OTHERS => ( OTHERS =>'0'));
    SIGNAL EtaSector : INTEGER RANGE 0 TO 16 := 0 ;

    COMPONENT ScaleZT
      GENERIC ( zdelay : NATURAL );
      PORT (
          clk : IN  STD_LOGIC;
          zT  : IN  SIGNED( widthKFZT - 1 DOWNTO 0 );
          cot : IN  SIGNED( widthKFcot - 1 DOWNTO 0 );
          z0  : OUT SIGNED( widthZ0 - 1 DOWNTO 0 )
      );
      END COMPONENT;

    COMPONENT ScalePhi
      GENERIC ( phidelay : NATURAL );
      PORT (
            clk       : IN STD_LOGIC;
            phiT      : IN SIGNED( widthKFphiT - 1 DOWNTO 0 );
            inv2R     : IN SIGNED( widthKFinv2r - 1 DOWNTO 0 );
            phiSector : IN STD_LOGIC;
            phi0      : OUT SIGNED( widthPhi0 - 1 DOWNTO 0 )
      );
      END COMPONENT;

    COMPONENT CalculateChi
      PORT (  
            clk      : IN STD_LOGIC;
            reset    : IN STD_LOGIC;
            stubs    : IN t_stubsKF;
            Chi2Rphi : OUT UNSIGNED( widthChi2RPhi - 1 DOWNTO 0 );
            Chi2RZ   : OUT UNSIGNED( widthChi2RZ - 1 DOWNTO 0 )
      );
      END COMPONENT;

  BEGIN 

    scaleZentity : ScaleZT GENERIC MAP ( zdelay => frame_delay - 1 - zscaleLatency )
                           PORT MAP    ( clk    => clk, 
                                          zT    => zT, 
                                         cot    => cot, 
                                          z0    => z0);
                                       
    scalePhientity : ScalePhi GENERIC MAP ( phidelay  => frame_delay -1 - phiscaleLatency )
                              PORT MAP    ( clk       => clk, 
                                            phiT      => phiT, 
                                            inv2R     => inv2R, 
                                            phiSector => phiSector, 
                                            phi0      => phi0);
                                         
    calcChientity : CalculateChi PORT MAP ( clk       => clk, 
                                            reset     => reset ( i ),
                                            stubs     => stubs, 
                                            Chi2Rphi  => Chi2Rphi,
                                            Chi2RZ    => Chi2RZ );

    PROCESS (clk)

     
      VARIABLE EtaSign   : INTEGER := 0;
      VARIABLE modCot   : SIGNED( widthTanL -1 DOWNTO 0 ) := ( OTHERS => '0' );
      VARIABLE TrackCounter : INTEGER := 0;

    BEGIN
      IF RISING_EDGE(clk) THEN
        frame_array <= KFObjectsIn( i ).track.valid & frame_array( 0 TO frame_delay - 2 );
        sign_array  <= EtaSign & sign_array( 0 TO frame_delay - 2 );

        zT  <= SIGNED( KFObjectsIn( i ).track.zT );
        cot <= SIGNED( KFObjectsIn( i ).track.cot );

        phiT      <= SIGNED( KFObjectsIn( i ).track.phiT );
        inv2R     <= SIGNED( KFObjectsIn( i ).track.inv2R );
        phiSector <= KFObjectsIn( i ).track.sector( widthKFsector - 1 );

        stubs     <= KFObjectsIn( i ).stubs;

        EtaSector  <= TO_INTEGER(UNSIGNED( KFObjectsIn( i ).track.sector( widthKFsector - 2 downto 0 )));


        EtaSign := 1 WHEN EtaSector < INTEGER(numSectorsEta/2) ELSE 0;

        HitPattern_array <= UNSIGNED(HitPattern(stubs)) & HitPattern_array( 0 TO frame_delay - 2 );
        modCot           := TO_SIGNED((TO_INTEGER(cot) + CotBins(EtaSector)),widthTanL);
        Tanl_array       <= modCot & Tanl_array( 0 TO frame_delay - 2 );
        InvR_array       <= RESIZE(-inv2R - 1,widthinvr ) & InvR_array( 0 TO frame_delay - 2 );

        IF TO_BOOLEAN( frame_array( frame_delay- 2 ) ) THEN 

          Output( i ).TrackValid <=  frame_array( frame_delay- 2 );
          Output( i ).DataValid  <=  TO_BOOLEAN( frame_array( frame_delay- 2 ) );
          Output( i ).extraMVA   <=  TO_UNSIGNED( 0, widthExtraMVA );  --Blank for now
          Output( i ).TQMVA      <=  TO_UNSIGNED( 0, widthTQMVA );     --Blank for now filled by TQ module
          Output( i ).HitPattern <=  HitPattern_array(frame_delay - 3 ); --TO_UNSIGNED( 0, widthHitPattern);--
          Output( i ).BendChi2   <=  TO_UNSIGNED( 0, widthBendChi2 );  --Blank for now
          Output( i ).Chi2RPhi   <=  Chi2Rphi; --TO_UNSIGNED( 0, widthChi2RZ ); --
          Output( i ).Chi2RZ     <=  Chi2RZ; --TO_UNSIGNED( 0, widthChi2RZ );  --
          Output( i ).D0         <=  TO_SIGNED( 0, widthD0 );          --Blank for now
          Output( i ).Z0         <=  z0; --TO_SIGNED( 0, widthZ0 ); --
          Output( i ).TanL       <=  Tanl_array( frame_delay - 3 ); --TO_SIGNED( 0, widthTanL ); --
          Output( i ).Phi0       <=  phi0; --TO_SIGNED( 0, widthphi0 ); --
          Output( i ).InvR       <=  InvR_array( frame_delay - 3 );
          Output( i ).SortKey    <=  sign_array(frame_delay - 4);

          TrackCounter := TrackCounter + 1;

        
        -- ELSIF (frame_array( frame_delay - 2 ) = '0') AND ( frame_array( frame_delay - 1 )  = '1') AND (TrackCounter MOD 2 = 1) THEN -- Pad out final track so distribution server has equal numbers of inputs

        --   Output( i ).TrackValid <=  '0';
        --   Output( i ).DataValid  <=  False;
        --   Output( i ).SortKey    <=  0;
        --   Output( i ).extraMVA   <=  TO_UNSIGNED( 0, widthExtraMVA );
        --   Output( i ).TQMVA      <=  TO_UNSIGNED( 0, widthTQMVA );   
        --   Output( i ).HitPattern <=  TO_UNSIGNED( 0, widthHitPattern);
        --   Output( i ).BendChi2   <=  TO_UNSIGNED( 0, widthBendChi2 );
        --   Output( i ).Chi2RPhi   <=  TO_UNSIGNED( 0, widthChi2RPhi ); 
        --   Output( i ).Chi2RZ     <=  TO_UNSIGNED( 0, widthChi2RZ );   
        --   Output( i ).D0         <=  TO_SIGNED( 0, widthD0 );        
        --   Output( i ).Z0         <=  TO_SIGNED( 0, widthZ0 ); 
        --   Output( i ).TanL       <=  TO_SIGNED( 0, widthTanL ); 
        --   Output( i ).Phi0       <=  TO_SIGNED( 0, widthphi0 ); 
        --   Output( i ).InvR       <=  TO_SIGNED( 0, widthInvR ); 
        --   TrackCounter := 0;

        ELSE

          Output( i ) <= cNull;

        END IF;



        reset( i )        <= TO_STD_LOGIC(( frame_array( frame_delay - 2 ) = '0') AND ( frame_array( frame_delay - 3 )  = '1'));
        Output( i ).reset <= TO_STD_LOGIC(( frame_array( frame_delay - 2 ) = '0') AND ( frame_array( frame_delay - 3 )  = '1'));
      
      END IF;

    END PROCESS;

  END GENERATE;

  TTTracksOut <= Output;

END rtl;