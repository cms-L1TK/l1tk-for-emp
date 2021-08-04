LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_MISC.ALL;
USE IEEE.NUMERIC_STD.ALL;

library work;
use work.kfout_data_formats.all;
use work.kfout_config.all;

use work.hybrid_data_types.all;
use work.hybrid_data_formats.all;

ENTITY ScaleZT IS
GENERIC(
  zdelay : NATURAL
);
PORT(  
  clk : IN  STD_LOGIC;
  zT  : IN  SIGNED( widthKFzT -1  DOWNTO 0 );
  cot : IN  SIGNED( widthKFcot -1 DOWNTO 0 );
  z0  : OUT SIGNED( widthZ0 -1    DOWNTO 0 ) := ( OTHERS => '0' )
);
END ScaleZT;

ARCHITECTURE RTL OF ScaleZT IS

    TYPE z0vector IS ARRAY( NATURAL RANGE <> ) OF SIGNED( widthZ0 - 1 DOWNTO 0 );
    SIGNAL z0signal : SIGNED( widthz0 -1 DOWNTO 0 ) :=  ( OTHERS => '0' );
    SIGNAL z0array  : z0vector( 0 TO zdelay - 1 )   :=  ( OTHERS => ( OTHERS => '0' ) );

    SIGNAl A : SIGNED( widthKFcot - 1 DOWNTO 0 )                   := ( OTHERS => '0' );
    SIGNAl B : SIGNED( widthKFZT  - 1 DOWNTO 0 )                   := ( OTHERS => '0' );
    SIGNAl C : SIGNED( widthKFcot + DSP27precision - 1 DOWNTO 0 )  := ( OTHERS => '0' );
    SIGNAl D : SIGNED( widthKFZT  - 1 DOWNTO 0 )                   := ( OTHERS => '0' );

    BEGIN
      PROCESS( clk )
      BEGIN
        IF RISING_EDGE(clk) THEN
        -- Clk 1 ------------------------
          A <= cot;
          B <= zT;
        -- Clk 2 -----------------------
          C <= A * TO_SIGNED( INTEGER( modChosenRofZ ), DSP27precision ); 
          D <= B;
        -- Clk 3 -----------------------
        z0signal <= RESIZE( D - ( RESIZE( C / ( 2**z0Factor ), widthKFZT ) ),widthz0 );
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

    SIGNAl A : SIGNED( widthKFphiT  - 1 DOWNTO 0 )                  := ( OTHERS => '0' );
    SIGNAL B : SIGNED( widthKFInv2R - 1 DOWNTO 0 )                  := ( OTHERS => '0' );
    SIGNAL C : SIGNED( widthKFphiT  - 1 DOWNTO 0 )                  := ( OTHERS => '0' );
    SIGNAL D : SIGNED( widthKFInv2R + DSP27precision - 1 DOWNTO 0 ) := ( OTHERS => '0' );
    SIGNAL E : SIGNED( widthKFphiT  - 1 DOWNTO 0 )                  := ( OTHERS => '0' );
    SIGNAL BaseSectorCorr : SIGNED( widthKFphiT - 1 DOWNTO 0 )      := ( OTHERS => '0' );

    SIGNAL phi0signal : SIGNED( widthphi0 - 1 DOWNTO 0 ) := ( OTHERS => '0' );

    TYPE phivector IS ARRAY( NATURAL range <> ) OF SIGNED(widthphi0 -1 DOWNTO 0 );
    SIGNAL phi0array  : phivector( 0 TO phidelay - 1)     := ( OTHERS => ( OTHERS => '0' ) ); 

    BEGIN
      PROCESS( clk )
        BEGIN
        IF RISING_EDGE(clk) THEN
-- Clk 1 ------------------------------------------------------
          IF (phiSector = '0') THEN
            BaseSectorCorr <= RESIZE( -SIGNED( UnsignedBaseSector ), widthKFphiT );
          ELSE
            BaseSectorCorr <= RESIZE(  SIGNED( UnsignedBaseSector ), widthKFphiT );
          END IF;
          A <= PhiT;
          B <= inv2R/2;
-- Clk 2 ------------------------------------------------------
          C <= A;
          D <= B * TO_SIGNED( INTEGER( modChosenRofPhi ), DSP27precision ); 
          E <= BaseSectorCorr;
-- Clk 3 ------------------------------------------------------
          phi0signal <= RESIZE( ( C - ( RESIZE( D / (2**phi0Factor ), widthKFphiT ) ) + E ), widthphi0 );
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
  TYPE phizarray IS ARRAY(natural RANGE <> ) OF UNSIGNED( DSP45Totalprecision - 1 DOWNTO 0);
  SIGNAL rphi : phizarray( numLayers -1 DOWNTO 0 )            := ( OTHERS => ( OTHERS => '0' ) );
  SIGNAL rz   : phizarray( numLayers -1 DOWNTO 0 )            := ( OTHERS => ( OTHERS => '0' ) );
  SIGNAL C    : UNSIGNED ( DSP45Totalprecision - 1 DOWNTO 0 ) := ( OTHERS => '0' ) ;
  SIGNAL D    : UNSIGNED ( DSP45Totalprecision - 1 DOWNTO 0 ) := ( OTHERS => '0' ) ;

  CONSTANT frame_delay : INTEGER := 2;

    BEGIN
    g1 : FOR i IN 0 TO numLayers - 1 GENERATE
    
      SIGNAL validarray : STD_LOGIC_VECTOR( 0 TO frame_delay - 1)  := ( OTHERS => '0' );  --Delaying frame valid signals 

      SIGNAL phi        :   SIGNED( widthKFphi     - 1 DOWNTO 0 ) := ( OTHERS => '0' );
      SIGNAL z          :   SIGNED( widthKFz       - 1 DOWNTO 0 ) := ( OTHERS => '0' );
      SIGNAL dphi       : UNSIGNED( widthKFdphi    - 1 DOWNTO 0 ) := ( OTHERS => '0' );
      SIGNAL dz         : UNSIGNED( widthKFdz      - 1 DOWNTO 0 ) := ( OTHERS => '0' );
      SIGNAL phisquared :   SIGNED( DSP27precision - 1 DOWNTO 0 ) := ( OTHERS => '0' );
      SIGNAL zsquared   :   SIGNED( DSP27precision - 1 DOWNTO 0 ) := ( OTHERS => '0' );

      SIGNAL tempv0 :   SIGNED( DSP18precision - 1 DOWNTO 0) := ( OTHERS => '0' ); 
      SIGNAL tempv1 :   SIGNED( DSP18precision - 1 DOWNTO 0) := ( OTHERS => '0' ); 

      SIGNAL temprphi : SIGNED( DSP45Totalprecision - 1 DOWNTO 0 ):= ( OTHERS => '0' );
      SIGNAL temprz   : SIGNED( DSP45Totalprecision - 1 DOWNTO 0 ):= ( OTHERS => '0' );

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
          phisquared <= RESIZE( ( phi * phi ),DSP27precision );
          tempv0     <= SIGNED( RESIZE( v0( dphi ), DSP18precision ) );
          zsquared   <= RESIZE( ( z*z ), DSP27precision );
          tempv1     <= SIGNED( RESIZE( v1( dz ), DSP18precision ) );
          --Clk 3 ------------------------------------------------
          temprphi <= phisquared * tempv0;
          temprz   <= zsquared   * tempv1;

          IF validarray(frame_delay - 1) = '1' THEN
            rphi( i ) <= UNSIGNED( temprphi );
            rz( i )   <= UNSIGNED( temprz );
          ELSE
            rphi( i ) <= ( OTHERS => '0' );
            rz( i )   <= ( OTHERS => '0' );
          END IF;

        END IF;
      END PROCESS;
    END GENERATE;

    PROCESS( clk )
    VARIABLE tempchi2rphi, tempchi2rz : UNSIGNED( DSP45Totalprecision - 1 DOWNTO 0 ) := ( OTHERS => '0' );
      BEGIN
      
      IF RISING_EDGE( clk ) THEN
        FOR i IN 0 TO numLayers - 1 LOOP
          tempchi2rphi := tempchi2rphi + rphi( i ) / ChiRescale; 
          tempchi2rz   := tempchi2rz   + rz( i )   / ChiRescale; 
        END LOOP;

        -- Clk 4 ---------------------------------------------------
        C <= tempchi2rphi;
        D <= tempchi2rz; 
        tempchi2rphi := ( OTHERS => '0' );
        tempchi2rz   := ( OTHERS => '0' );
        -- Clk 5 ---------------------------------------------------
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
  TTTracksOut  : OUT VECTOR
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
    SIGNAL sign_array   : STD_LOGIC_VECTOR( 0 TO chiLatency - 1 )  := ( OTHERS => '0' );  --Delaying track num signals

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

    SIGNAL HitPattern_array : hitpatternARRAY( 0 TO chiLatency - 1 ) := ( OTHERS => ( OTHERS =>'0'));
    SIGNAL Tanl_array       : TanlARRAY( 0 TO chiLatency - 1 )       := ( OTHERS => ( OTHERS =>'0'));
    SIGNAL InvR_array       : InvRARRAY( 0 TO chiLatency - 1 )       := ( OTHERS => ( OTHERS =>'0'));

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

    scaleZentity : ScaleZT GENERIC MAP ( zdelay => chiLatency + 2 - zscaleLatency )
                           PORT MAP    ( clk    => clk, 
                                          zT    => zT, 
                                         cot    => cot, 
                                          z0    => z0);
                                       
    scalePhientity : ScalePhi GENERIC MAP ( phidelay  => chiLatency + 2 - phiscaleLatency )
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

      VARIABLE EtaSector : INTEGER RANGE 0 TO 16 := 0 ;
      VARIABLE modCot   : SIGNED( widthTanL -1 DOWNTO 0 ) := ( OTHERS => '0' );

    BEGIN
      IF RISING_EDGE(clk) THEN
        frame_array <= KFObjectsIn( i ).track.valid & frame_array( 0 TO frame_delay - 2 );
        sign_array  <= KFObjectsIn( i ).track.cot( widthKFcot - 1) & sign_array( 0 TO chiLatency - 2 );

        zT  <= SIGNED( KFObjectsIn( i ).track.zT );
        cot <= SIGNED( KFObjectsIn( i ).track.cot );

        phiT      <= SIGNED( KFObjectsIn( i ).track.phiT );
        inv2R     <= SIGNED( KFObjectsIn( i ).track.inv2R );
        phiSector <= KFObjectsIn( i ).track.sector( widthKFsector - 1 );

        stubs     <= KFObjectsIn( i ).stubs;

        EtaSector := TO_INTEGER(UNSIGNED( KFObjectsIn( i ).track.sector( widthKFsector - 2 downto 0 )));

        HitPattern_array <= UNSIGNED(HitPattern(stubs)) & HitPattern_array( 0 TO chiLatency - 2 );
        modCot           := RESIZE(SIGNED(cot) + CotBins(EtaSector),widthTanL);
        Tanl_array       <= modCot & Tanl_array( 0 TO chiLatency - 2 );
        InvR_array       <= RESIZE(inv2R,widthinvr ) & InvR_array( 0 TO chiLatency - 2 );

        Output( i ).TrackValid <=  frame_array( frame_delay- 1 );
        Output( i ).DataValid  <=  TO_BOOLEAN( frame_array( frame_delay- 1 ) );
        Output( i ).extraMVA   <=  TO_UNSIGNED( 0, widthExtraMVA );  --Blank for now
        Output( i ).TQMVA      <=  TO_UNSIGNED( 0, widthTQMVA );     --Blank for now
        Output( i ).HitPattern <=  HitPattern_array(chiLatency - 2 );
        Output( i ).BendChi2   <=  TO_UNSIGNED( 0, widthBendChi2 );  --Blank for now
        Output( i ).Chi2RPhi   <=  Chi2Rphi;
        Output( i ).Chi2RZ     <=  Chi2RZ;   
        Output( i ).D0         <=  TO_SIGNED( 0, widthD0 );          --Blank for now
        Output( i ).Z0         <=  z0;
        Output( i ).TanL       <=  Tanl_array( chiLatency - 1 );
        Output( i ).Phi0       <=  phi0;
        Output( i ).InvR       <=  InvR_array( chiLatency - 2 );
        Output( i ).SortKey    <=  TO_INTEGER( UNSIGNED'('0' & sign_array(chiLatency - 1)));

        reset( i )        <= TO_STD_LOGIC(( frame_array( frame_delay - 1 ) = '0') AND ( frame_array( frame_delay - 2 )  = '1'));
        Output( i ).reset <= TO_STD_LOGIC(( frame_array( frame_delay - 1 ) = '0') AND ( frame_array( frame_delay - 2 )  = '1'));

      END IF;

    END PROCESS;
    
  END GENERATE;

  TTTracksOut <= Output;

END rtl;