library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use work.hybrid_tools.all;
use work.hybrid_data_formats.all;
use work.kf_data_formats.all;
use work.kf_data_types.all;
use work.kf_state_pkg.all;


entity kf_state is
generic (
  index: natural := 0
);
port (
  clk: in std_logic;
  state_din: in t_seed;
  state_dout: out t_state
);
end;


architecture rtl of kf_state is


signal dspH1m0A: std_logic_vector( widthDspHm0A - 1 downto 0 ) := ( others => '0' );
signal dspH1m0B: std_logic_vector( widthDspHm0B - 1 downto 0 ) := ( others => '0' );
signal dspH1m0P: std_logic_vector( widthDspHm0P - 1 downto 0 ) := ( others => '0' );
signal dspH0m1A: std_logic_vector( widthDspHm0A - 1 downto 0 ) := ( others => '0' );
signal dspH0m1B: std_logic_vector( widthDspHm0B - 1 downto 0 ) := ( others => '0' );
signal dspH0m1P: std_logic_vector( widthDspHm0P - 1 downto 0 ) := ( others => '0' );
component c_dspHm0
port (
  clk: in std_logic;
  A: in std_logic_vector( widthDspHm0A - 1 downto 0 );
  B: in std_logic_vector( widthDspHm0B - 1 downto 0 );
  P: out std_logic_vector( widthDspHm0P - 1 downto 0 )
);
end component;

signal dspH3m2A: std_logic_vector( widthDspHm1A - 1 downto 0 ) := ( others => '0' );
signal dspH3m2B: std_logic_vector( widthDspHm1B - 1 downto 0 ) := ( others => '0' );
signal dspH3m2P: std_logic_vector( widthDspHm1P - 1 downto 0 ) := ( others => '0' );
signal dspH2m3A: std_logic_vector( widthDspHm1A - 1 downto 0 ) := ( others => '0' );
signal dspH2m3B: std_logic_vector( widthDspHm1B - 1 downto 0 ) := ( others => '0' );
signal dspH2m3P: std_logic_vector( widthDspHm1P - 1 downto 0 ) := ( others => '0' );
component c_dspHm1
port (
  clk: in std_logic;
  A: in std_logic_vector( widthDspHm1A - 1 downto 0 );
  B: in std_logic_vector( widthDspHm1B - 1 downto 0 );
  P: out std_logic_vector( widthDspHm1P - 1 downto 0 )
);
end component;

signal dspH02A: std_logic_vector( widthDspH02A - 1 downto 0 ) := ( others => '0' );
signal dspH02B: std_logic_vector( widthDspH02B - 1 downto 0 ) := ( others => '0' );
signal dspH02P: std_logic_vector( widthDspH02P - 1 downto 0 ) := ( others => '0' );
signal dspH12A: std_logic_vector( widthDspH02A - 1 downto 0 ) := ( others => '0' );
signal dspH12B: std_logic_vector( widthDspH02B - 1 downto 0 ) := ( others => '0' );
signal dspH12P: std_logic_vector( widthDspH02P - 1 downto 0 ) := ( others => '0' );
component c_dspH02
port (
  clk: in std_logic;
  A: in std_logic_vector( widthDspH02A - 1 downto 0 );
  B: in std_logic_vector( widthDspH02B - 1 downto 0 );
  P: out std_logic_vector( widthDspH02P - 1 downto 0 )
);
end component;

signal dspH22A: std_logic_vector( widthDspH12A - 1 downto 0 ) := ( others => '0' );
signal dspH22B: std_logic_vector( widthDspH12B - 1 downto 0 ) := ( others => '0' );
signal dspH22P: std_logic_vector( widthDspH12P - 1 downto 0 ) := ( others => '0' );
signal dspH32A: std_logic_vector( widthDspH12A - 1 downto 0 ) := ( others => '0' );
signal dspH32B: std_logic_vector( widthDspH12B - 1 downto 0 ) := ( others => '0' );
signal dspH32P: std_logic_vector( widthDspH12P - 1 downto 0 ) := ( others => '0' );
component c_dspH12
port (
  clk: in std_logic;
  A: in std_logic_vector( widthDspH12A - 1 downto 0 );
  B: in std_logic_vector( widthDspH12B - 1 downto 0 );
  P: out std_logic_vector( widthDspH12P - 1 downto 0 )
);
end component;

signal dspH1v0A: std_logic_vector( widthDspHv0A - 1 downto 0 ) := ( others => '0' );
signal dspH1v0B: std_logic_vector( widthDspHv0B - 1 downto 0 ) := ( others => '0' );
signal dspH1v0P: std_logic_vector( widthDspHv0P - 1 downto 0 ) := ( others => '0' );
signal dspH0v1A: std_logic_vector( widthDspHv0A - 1 downto 0 ) := ( others => '0' );
signal dspH0v1B: std_logic_vector( widthDspHv0B - 1 downto 0 ) := ( others => '0' );
signal dspH0v1P: std_logic_vector( widthDspHv0P - 1 downto 0 ) := ( others => '0' );
component c_dspHv0
port (
  clk: in std_logic;
  A: in std_logic_vector( widthDspHv0A - 1 downto 0 );
  B: in std_logic_vector( widthDspHv0B - 1 downto 0 );
  P: out std_logic_vector( widthDspHv0P - 1 downto 0 )
);
end component;

signal dspH3v2A: std_logic_vector( widthDspHv1A - 1 downto 0 ) := ( others => '0' );
signal dspH3v2B: std_logic_vector( widthDspHv1B - 1 downto 0 ) := ( others => '0' );
signal dspH3v2P: std_logic_vector( widthDspHv1P - 1 downto 0 ) := ( others => '0' );
signal dspH2v3A: std_logic_vector( widthDspHv1A - 1 downto 0 ) := ( others => '0' );
signal dspH2v3B: std_logic_vector( widthDspHv1B - 1 downto 0 ) := ( others => '0' );
signal dspH2v3P: std_logic_vector( widthDspHv1P - 1 downto 0 ) := ( others => '0' );
component c_dspHv1
port (
  clk: in std_logic;
  A: in std_logic_vector( widthDspHv1A - 1 downto 0 );
  B: in std_logic_vector( widthDspHv1B - 1 downto 0 );
  P: out std_logic_vector( widthDspHv1P - 1 downto 0 )
);
end component;

signal dspH12v0A: std_logic_vector( widthDspH2v0A - 1 downto 0 ) := ( others => '0' );
signal dspH12v0B: std_logic_vector( widthDspH2v0B - 1 downto 0 ) := ( others => '0' );
signal dspH12v0P: std_logic_vector( widthDspH2v0P - 1 downto 0 ) := ( others => '0' );
signal dspH02v1A: std_logic_vector( widthDspH2v0A - 1 downto 0 ) := ( others => '0' );
signal dspH02v1B: std_logic_vector( widthDspH2v0B - 1 downto 0 ) := ( others => '0' );
signal dspH02v1P: std_logic_vector( widthDspH2v0P - 1 downto 0 ) := ( others => '0' );
component c_dspH2v0
port (
  clk: in std_logic;
  A: in std_logic_vector( widthDspH2v0A - 1 downto 0 );
  B: in std_logic_vector( widthDspH2v0B - 1 downto 0 );
  P: out std_logic_vector( widthDspH2v0P - 1 downto 0 )
);
end component;

signal dspH32v2A: std_logic_vector( widthDspH2v1A - 1 downto 0 ) := ( others => '0' );
signal dspH32v2B: std_logic_vector( widthDspH2v1B - 1 downto 0 ) := ( others => '0' );
signal dspH32v2P: std_logic_vector( widthDspH2v1P - 1 downto 0 ) := ( others => '0' );
signal dspH22v3A: std_logic_vector( widthDspH2v1A - 1 downto 0 ) := ( others => '0' );
signal dspH22v3B: std_logic_vector( widthDspH2v1B - 1 downto 0 ) := ( others => '0' );
signal dspH22v3P: std_logic_vector( widthDspH2v1P - 1 downto 0 ) := ( others => '0' );
component c_dspH2v1
port (
  clk: in std_logic;
  A: in std_logic_vector( widthDspH2v1A - 1 downto 0 );
  B: in std_logic_vector( widthDspH2v1B - 1 downto 0 );
  P: out std_logic_vector( widthDspH2v1P - 1 downto 0 )
);
end component;

signal dspX0A: std_logic_vector( widthDspX0A - 1 downto 0 ) := ( others => '0' );
signal dspX0B: std_logic_vector( widthDspX0B - 1 downto 0 ) := ( others => '0' );
signal dspX0D: std_logic_vector( widthDspX0D - 1 downto 0 ) := ( others => '0' );
signal dspX0P: std_logic_vector( widthDspX0P - 1 downto 0 ) := ( others => '0' );
component c_dspX0
port (
  clk: in std_logic;
  A: in std_logic_vector( widthDspX0A - 1 downto 0 );
  B: in std_logic_vector( widthDspX0B - 1 downto 0 );
  D: in std_logic_vector( widthDspX0D - 1 downto 0 );
  P: out std_logic_vector( widthDspX0P - 1 downto 0 )
);
end component;

signal dspX1A: std_logic_vector( widthDspX1A - 1 downto 0 ) := ( others => '0' );
signal dspX1B: std_logic_vector( widthDspX1B - 1 downto 0 ) := ( others => '0' );
signal dspX1D: std_logic_vector( widthDspX1D - 1 downto 0 ) := ( others => '0' );
signal dspX1P: std_logic_vector( widthDspX1P - 1 downto 0 ) := ( others => '0' );
component c_dspX1
port (
  clk: in std_logic;
  A: in std_logic_vector( widthDspX1A - 1 downto 0 );
  B: in std_logic_vector( widthDspX1B - 1 downto 0 );
  D: in std_logic_vector( widthDspX1D - 1 downto 0 );
  P: out std_logic_vector( widthDspX1P - 1 downto 0 )
);
end component;

signal dspX2A: std_logic_vector( widthDspX2A - 1 downto 0 ) := ( others => '0' );
signal dspX2B: std_logic_vector( widthDspX2B - 1 downto 0 ) := ( others => '0' );
signal dspX2D: std_logic_vector( widthDspX2D - 1 downto 0 ) := ( others => '0' );
signal dspX2P: std_logic_vector( widthDspX2P - 1 downto 0 ) := ( others => '0' );
component c_dspX2
port (
  clk: in std_logic;
  A: in std_logic_vector( widthDspX2A - 1 downto 0 );
  B: in std_logic_vector( widthDspX2B - 1 downto 0 );
  D: in std_logic_vector( widthDspX2D - 1 downto 0 );
  P: out std_logic_vector( widthDspX2P - 1 downto 0 )
);
end component;

signal dspX3A: std_logic_vector( widthDspX3A - 1 downto 0 ) := ( others => '0' );
signal dspX3B: std_logic_vector( widthDspX3B - 1 downto 0 ) := ( others => '0' );
signal dspX3D: std_logic_vector( widthDspX3D - 1 downto 0 ) := ( others => '0' );
signal dspX3P: std_logic_vector( widthDspX3P - 1 downto 0 ) := ( others => '0' );
component c_dspX3
port (
  clk: in std_logic;
  A: in std_logic_vector( widthDspX3A - 1 downto 0 );
  B: in std_logic_vector( widthDspX3B - 1 downto 0 );
  D: in std_logic_vector( widthDspX3D - 1 downto 0 );
  P: out std_logic_vector( widthDspX3P - 1 downto 0 )
);
end component;

signal dspC00A: std_logic_vector( widthDspC00A - 1 downto 0 ) := ( others => '0' );
signal dspC00B: std_logic_vector( widthDspC00B - 1 downto 0 ) := ( others => '0' );
signal dspC00D: std_logic_vector( widthDspC00D - 1 downto 0 ) := ( others => '0' );
signal dspC00P: std_logic_vector( widthDspC00P - 1 downto 0 ) := ( others => '0' );
component c_dspC00
port (
  clk: in std_logic;
  A: in std_logic_vector( widthDspC00A - 1 downto 0 );
  B: in std_logic_vector( widthDspC00B - 1 downto 0 );
  D: in std_logic_vector( widthDspC00D - 1 downto 0 );
  P: out std_logic_vector( widthDspC00P - 1 downto 0 )
);
end component;

signal dspC01A: std_logic_vector( widthDspC01A - 1 downto 0 ) := ( others => '0' );
signal dspC01B: std_logic_vector( widthDspC01B - 1 downto 0 ) := ( others => '0' );
signal dspC01D: std_logic_vector( widthDspC01D - 1 downto 0 ) := ( others => '0' );
signal dspC01P: std_logic_vector( widthDspC01P - 1 downto 0 ) := ( others => '0' );
component c_dspC01
port (
  clk: in std_logic;
  A: in std_logic_vector( widthDspC01A - 1 downto 0 );
  B: in std_logic_vector( widthDspC01B - 1 downto 0 );
  D: in std_logic_vector( widthDspC01D - 1 downto 0 );
  P: out std_logic_vector( widthDspC01P - 1 downto 0 )
);
end component;

signal dspC11A: std_logic_vector( widthDspC11A - 1 downto 0 ) := ( others => '0' );
signal dspC11B: std_logic_vector( widthDspC11B - 1 downto 0 ) := ( others => '0' );
signal dspC11D: std_logic_vector( widthDspC11D - 1 downto 0 ) := ( others => '0' );
signal dspC11P: std_logic_vector( widthDspC11P - 1 downto 0 ) := ( others => '0' );
component c_dspC11
port (
  clk: in std_logic;
  A: in std_logic_vector( widthDspC11A - 1 downto 0 );
  B: in std_logic_vector( widthDspC11B - 1 downto 0 );
  D: in std_logic_vector( widthDspC11D - 1 downto 0 );
  P: out std_logic_vector( widthDspC11P - 1 downto 0 )
);
end component;

signal dspC22A: std_logic_vector( widthDspC22A - 1 downto 0 ) := ( others => '0' );
signal dspC22B: std_logic_vector( widthDspC22B - 1 downto 0 ) := ( others => '0' );
signal dspC22D: std_logic_vector( widthDspC22D - 1 downto 0 ) := ( others => '0' );
signal dspC22P: std_logic_vector( widthDspC22P - 1 downto 0 ) := ( others => '0' );
component c_dspC22
port (
  clk: in std_logic;
  A: in std_logic_vector( widthDspC22A - 1 downto 0 );
  B: in std_logic_vector( widthDspC22B - 1 downto 0 );
  D: in std_logic_vector( widthDspC22D - 1 downto 0 );
  P: out std_logic_vector( widthDspC22P - 1 downto 0 )
);
end component;

signal dspC23A: std_logic_vector( widthDspC23A - 1 downto 0 ) := ( others => '0' );
signal dspC23B: std_logic_vector( widthDspC23B - 1 downto 0 ) := ( others => '0' );
signal dspC23D: std_logic_vector( widthDspC23D - 1 downto 0 ) := ( others => '0' );
signal dspC23P: std_logic_vector( widthDspC23P - 1 downto 0 ) := ( others => '0' );
component c_dspC23
port (
  clk: in std_logic;
  A: in std_logic_vector( widthDspC23A - 1 downto 0 );
  B: in std_logic_vector( widthDspC23B - 1 downto 0 );
  D: in std_logic_vector( widthDspC23D - 1 downto 0 );
  P: out std_logic_vector( widthDspC23P - 1 downto 0 )
);
end component;

signal dspC33A: std_logic_vector( widthDspC33A - 1 downto 0 ) := ( others => '0' );
signal dspC33B: std_logic_vector( widthDspC33B - 1 downto 0 ) := ( others => '0' );
signal dspC33D: std_logic_vector( widthDspC33D - 1 downto 0 ) := ( others => '0' );
signal dspC33P: std_logic_vector( widthDspC33P - 1 downto 0 ) := ( others => '0' );
component c_dspC33
port (
  clk: in std_logic;
  A: in std_logic_vector( widthDspC33A - 1 downto 0 );
  B: in std_logic_vector( widthDspC33B - 1 downto 0 );
  D: in std_logic_vector( widthDspC33D - 1 downto 0 );
  P: out std_logic_vector( widthDspC33P - 1 downto 0 )
);
end component;

-- step 1

signal din: t_seed := nulll;
signal metaSR: t_metaTHHs( 7 downto 1 + 1 ) := ( others => nulll );
signal diffH: std_logic_vector( widthH00 + 2 - 1 downto 0 ) := ( others => '0' );
signal dH: std_logic_vector( widthDH - 1 downto 0 ) := ( others => '0' );
signal invDHs: t_invDHs := init_invDHs;
signal invDH2s: t_invDH2s := init_invDH2s;
signal optionalInvDH: std_logic_vector( widthInvDH - 1 downto 0 ) := ( others => '0' );
signal optionalInvDH2: std_logic_vector( widthInvDH2 - 1 downto 0 ) := ( others => '0' );
signal v0s: t_v0s := init_v0s;
signal v1s: t_v1s := init_v1s;
signal v00, v01: std_logic_vector( widthV0 - 1 downto 0 ) := ( others => '0' );
signal v10, v11: std_logic_vector( widthV1 - 1 downto 0 ) := ( others => '0' );
signal m00, m10, m0: std_logic_vector( widthm0 - 1 downto 0 ) := ( others => '0' );
signal m01, m11, m1: std_logic_vector( widthm1 - 1 downto 0 ) := ( others => '0' );
signal H0, H1: std_logic_vector( widthH00 - 1 downto 0 ) := ( others => '0' );
signal H2, H3: std_logic_vector( widthH12 - 1 downto 0 ) := ( others => '0' );

-- step 2

signal invDH: std_logic_vector( widthInvDH - 1 downto 0 ) := ( others => '0' );
signal invDH2: std_logic_vector( widthInvDH2 - 1 downto 0 ) := ( others => '0' );

-- step 3

signal invDH2SR: std_logic_vector( widthInvDH2 - 1 downto 0 ) := ( others => '0' );
signal H12, H02: std_logic_vector( widthH0H0 - 1 downto 0 ) := ( others => '0' );
signal H32, H22: std_logic_vector( widthH1H1 - 1 downto 0 ) := ( others => '0' );

-- step 4

signal H1m0, H0m1: std_logic_vector( widthHm0 - 1 downto 0 ) := ( others => '0' );
signal H3m2, H2m3: std_logic_vector( widthHm1 - 1 downto 0 ) := ( others => '0' );
signal H1v0, H0v1: std_logic_vector( widthHv0 - 1 downto 0 ) := ( others => '0' );
signal H3v2, H2v3: std_logic_vector( widthHv1 - 1 downto 0 ) := ( others => '0' );

-- step 5

signal H12v0, H02v1: std_logic_vector( widthH2v0 - 1 downto 0 ) := ( others => '0' );
signal H32v2, H22v3: std_logic_vector( widthH2v1 - 1 downto 0 ) := ( others => '0' );

-- step 6

signal x0: std_logic_vector( widthX0 - 1 downto 0 ) := ( others => '0' );
signal x1: std_logic_vector( widthX1 - 1 downto 0 ) := ( others => '0' );
signal x2: std_logic_vector( widthX2 - 1 downto 0 ) := ( others => '0' );
signal x3: std_logic_vector( widthX3 - 1 downto 0 ) := ( others => '0' );
signal C00: std_logic_vector( widthC00 - 1 downto 0 ) := ( others => '0' );
signal C01: std_logic_vector( widthC01 - 1 downto 0 ) := ( others => '0' );
signal C11: std_logic_vector( widthC11 - 1 downto 0 ) := ( others => '0' );
signal C22: std_logic_vector( widthC22 - 1 downto 0 ) := ( others => '0' );
signal C23: std_logic_vector( widthC23 - 1 downto 0 ) := ( others => '0' );
signal C33: std_logic_vector( widthC33 - 1 downto 0 ) := ( others => '0' );

-- step 7

signal dout: t_state := nulll;


begin


dspH1m0A  <=       H1       & '1';
dspH1m0B  <=       m00      & '1';
dspH0m1A  <=       H0       & '1';
dspH0m1B  <=       m10      & '1';
dspH3m2A  <=       H3       & '1';
dspH3m2B  <=       m01      & '1';
dspH2m3A  <=       H2       & '1';
dspH2m3B  <=       m11      & '1';
dspH1v0A  <= '0' & v00      & '1';
dspH1v0B  <=       H1       & '1';
dspH0v1A  <= '0' & v01      & '1';
dspH0v1B  <=       H0       & '1';
dspH3v2A  <= '0' & v10      & '1';
dspH3v2B  <=       H3       & '1';
dspH2v3A  <= '0' & v11      & '1';
dspH2v3B  <=       H2       & '1';
dspH02A   <=       H0       & '1';
dspH02B   <=       H0       & '1';
dspH12A   <=       H1       & '1';
dspH12B   <=       H1       & '1';
dspH22A   <=       H2       & '1';
dspH22B   <=       H2       & '1';
dspH32A   <=       H3       & '1';
dspH32B   <=       H3       & '1';
dspH12v0A <= '0' & H12      & '1';
dspH12v0B <= '0' & v00      & '1';
dspH02v1A <= '0' & H02      & '1';
dspH02v1B <= '0' & v01      & '1';
dspH32v2A <= '0' & H32      & '1';
dspH32v2B <= '0' & v10      & '1';
dspH22v3A <= '0' & H22      & '1';
dspH22v3B <= '0' & v11      & '1';
dspX0A    <=       m10      & '1';
dspX0B    <= '0' & invDH    & '1';
dspX0D    <=       m0       & '1';
dspX2A    <=       m11      & '1';
dspX2B    <= '0' & invDH    & '1';
dspX2D    <=       m1       & '1';
dspX1A    <=       H1m0     & '1';
dspX1B    <= '0' & invDH    & '1';
dspX1D    <=       H0m1     & '1';
dspX3A    <=       H3m2     & '1';
dspX3B    <= '0' & invDH    & '1';
dspX3D    <=       H2m3     & '1';
dspC00A   <= '0' & v00      & '1';
dspC00B   <= '0' & invDH2   & '1';
dspC00D   <= '0' & v01      & '1';
dspC22A   <= '0' & v10      & '1';
dspC22B   <= '0' & invDH2   & '1';
dspC22D   <= '0' & v11      & '1';
dspC01A   <=       H1v0     & '1';
dspC01B   <= '0' & invDH2   & '1';
dspC01D   <=       H0v1     & '1';
dspC23A   <=       H3v2     & '1';
dspC23B   <= '0' & invDH2   & '1';
dspC23D   <=       H2v3     & '1';
dspC11A   <= '0' & H12v0    & '1';
dspC11B   <= '0' & invDH2SR & '1';
dspC11D   <= '0' & H02v1    & '1';
dspC33A   <= '0' & H32v2    & '1';
dspC33B   <= '0' & invDH2SR & '1';
dspC33D   <= '0' & H22v3    & '1';
dspH1m0:  c_dspHm0  port map ( clk, dspH1m0A,  dspH1m0B,           dspH1m0P  );
dspH0m1:  c_dspHm0  port map ( clk, dspH0m1A,  dspH0m1B,           dspH0m1P  );
dspH3m2:  c_dspHm1  port map ( clk, dspH3m2A,  dspH3m2B,           dspH3m2P  );
dspH2m3:  c_dspHm1  port map ( clk, dspH2m3A,  dspH2m3B,           dspH2m3P  );
dspH1v0:  c_dspHv0  port map ( clk, dspH1v0A,  dspH1v0B,           dspH1v0P  );
dspH0v1:  c_dspHv0  port map ( clk, dspH0v1A,  dspH0v1B,           dspH0v1P  );
dspH3v2:  c_dspHv1  port map ( clk, dspH3v2A,  dspH3v2B,           dspH3v2P  );
dspH2v3:  c_dspHv1  port map ( clk, dspH2v3A,  dspH2v3B,           dspH2v3P  );
dspH02:   c_dspH02  port map ( clk, dspH02A,   dspH02B,            dspH02P   );
dspH12:   c_dspH02  port map ( clk, dspH12A,   dspH12B,            dspH12P   );
dspH22:   c_dspH12  port map ( clk, dspH22A,   dspH22B,            dspH22P   );
dspH32:   c_dspH12  port map ( clk, dspH32A,   dspH32B,            dspH32P   );
dspH12v0: c_dspH2v0 port map ( clk, dspH12v0A, dspH12v0B,          dspH12v0P );
dspH02v1: c_dspH2v0 port map ( clk, dspH02v1A, dspH02v1B,          dspH02v1P );
dspH32v2: c_dspH2v1 port map ( clk, dspH32v2A, dspH32v2B,          dspH32v2P );
dspH22v3: c_dspH2v1 port map ( clk, dspH22v3A, dspH22v3B,          dspH22v3P );
dspX0:    c_dspX0   port map ( clk, dspX0A,    dspX0B,    dspX0D,  dspX0P    );
dspX2:    c_dspX2   port map ( clk, dspX2A,    dspX2B,    dspX2D,  dspX2P    );
dspX1:    c_dspX1   port map ( clk, dspX1A,    dspX1B,    dspX1D,  dspX1P    );
dspX3:    c_dspX3   port map ( clk, dspX3A,    dspX3B,    dspX3D,  dspX3P    );
dspC00:   c_dspC00  port map ( clk, dspC00A,   dspC00B,   dspC00D, dspC00P   );
dspC22:   c_dspC22  port map ( clk, dspC22A,   dspC22B,   dspC22D, dspC22P   );
dspC01:   c_dspC01  port map ( clk, dspC01A,   dspC01B,   dspC01D, dspC01P   );
dspC23:   c_dspC23  port map ( clk, dspC23A,   dspC23B,   dspC23D, dspC23P   );
dspC11:   c_dspC11  port map ( clk, dspC11A,   dspC11B,   dspC11D, dspC11P   );
dspC33:   c_dspC33  port map ( clk, dspC33A,   dspC33B,   dspC33D, dspC33P   );

-- step 1
din <= state_din;
diffH <= ( H1 & '1' ) - ( H0 & '1' );
dH <= diffH( widthDH + baseDiffDH + 1 - 1 downto baseDiffDH + 1 );
H1 <= din.stubs( 1 ).H00;
H0 <= din.stubs( 0 ).H00;
H3 <= f_H12( din.stubs( 1 ).H00 );
H2 <= f_H12( din.stubs( 0 ).H00 );
m00 <= din.stubs( 0 ).m0;
m01 <= din.stubs( 0 ).m1;
m10 <= din.stubs( 1 ).m0;
m11 <= din.stubs( 1 ).m1;

-- step 3
H12 <= dspH12P( r_H02 );
H02 <= dspH02P( r_H02 );
H32 <= dspH32P( r_H12 );
H22 <= dspH22P( r_H12 );

-- step 4
H1m0 <= dspH1m0P( r_Hm0 );
H0m1 <= dspH0m1P( r_Hm0 );
H3m2 <= dspH3m2P( r_Hm1 );
H2m3 <= dspH2m3P( r_Hm1 );
H1v0 <= dspH1v0P( r_Hv0 );
H0v1 <= dspH0v1P( r_Hv0 );
H3v2 <= dspH3v2P( r_Hv1 );
H2v3 <= dspH2v3P( r_Hv1 );

-- step 5
H12v0 <= dspH12v0P( r_H2v0 );
H02v1 <= dspH02v1P( r_H2v0 );
H32v2 <= dspH32v2P( r_H2v1 );
H22v3 <= dspH22v3P( r_H2v1 );

-- step 6
x1 <= dspX1P( r_x1 );
x3 <= dspX3P( r_x3 );
C11 <= dspC11P( r_C11 );
C33 <= dspC33P( r_C33 );

-- step 7
state_dout <= dout;


process( clk ) is
begin
if rising_edge( clk ) then

  -- shift registers

  metaSR <= metaSR( metaSR'high - 1 downto metaSR'low ) & nulll;

  -- step 1

  metaSR( metaSR'low ) <= din.meta;
  optionalInvDH <= invDHs( uint( dH ) );
  optionalInvDH2 <= invDH2s( uint( dH ) );
  v00 <= v0s( uint( din.stubs( 0 ).d0 ) );
  v01 <= v0s( uint( din.stubs( 1 ).d0 ) );
  v10 <= v1s( uint( din.stubs( 0 ).d1 ) );
  v11 <= v1s( uint( din.stubs( 1 ).d1 ) );
  m0 <= m00;
  m1 <= m01;

  -- step 2

  invDH <= optionalInvDH;
  invDH2 <= optionalInvDH2;

  -- step 3

  invDH2SR <= invDH2;

  -- step 4

  -- step 5

  -- step 6

  X0 <= dspX0P( r_x0 );
  X2 <= dspX2P( r_x2 );
  C00 <= dspC00P( r_C00 );
  C01 <= dspC01P( r_C01 );
  C22 <= dspC22P( r_C22 );
  C23 <= dspC23P( r_C23 );

  -- step 7

  dout.meta <= metaSR( 7 );
  dout.track.x0 <= x0;
  dout.track.x1 <= x1;
  dout.track.x2 <= x2;
  dout.track.x3 <= x3;
  dout.cov.C00 <= C00;
  dout.cov.C01 <= not C01;
  dout.cov.C22 <= C22;
  dout.cov.C11 <= C11;
  dout.cov.C23 <= not C23;
  dout.cov.C33 <= C33;

  if metaSR( 7 ).valid = '0' then
    dout.track <= nulll;
    dout.cov <= nulll;
  end if;

end if;
end process;


end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.kf_state_pkg.all;

entity c_dspHm0 is
port (
  clk: in std_logic;
  A: in std_logic_vector( widthDspHm0A - 1 downto 0 );
  B: in std_logic_vector( widthDspHm0B - 1 downto 0 );
  P: out std_logic_vector( widthDspHm0P - 1 downto 0 )
);
end;

architecture rtl of c_dspHm0 is

signal dsp: t_dspHm0 := ( others => ( others => '0' ) );

begin

P <= dsp.P;

process( clk ) is
begin
if rising_edge( clk ) then

  dsp.A0 <= A;
  dsp.B0 <= B;

  dsp.A <= dsp.A0;
  dsp.B <= dsp.B0;

  dsp.P <= dsp.A * dsp.B;

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.kf_state_pkg.all;

entity c_dspHm1 is
port (
  clk: in std_logic;
  A: in std_logic_vector( widthDspHm1A - 1 downto 0 );
  B: in std_logic_vector( widthDspHm1B - 1 downto 0 );
  P: out std_logic_vector( widthDspHm1P - 1 downto 0 )
);
end;

architecture rtl of c_dspHm1 is

signal dsp: t_dspHm1 := ( others => ( others => '0' ) );

begin

P <= dsp.P;

process( clk ) is
begin
if rising_edge( clk ) then

  dsp.A0 <= A;
  dsp.B0 <= B;

  dsp.A <= dsp.A0;
  dsp.B <= dsp.B0;

  dsp.P <= dsp.A * dsp.B;

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.kf_state_pkg.all;

entity c_dspH02 is
port (
  clk: in std_logic;
  A: in std_logic_vector( widthDspH02A - 1 downto 0 );
  B: in std_logic_vector( widthDspH02B - 1 downto 0 );
  P: out std_logic_vector( widthDspH02P - 1 downto 0 )
);
end;

architecture rtl of c_dspH02 is

signal dsp: t_dspH02 := ( others => ( others => '0' ) );

begin

P <= dsp.P;

process( clk ) is
begin
if rising_edge( clk ) then

  dsp.A <= A;
  dsp.B <= B;

  dsp.P <= dsp.A * dsp.B;

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.kf_state_pkg.all;

entity c_dspH12 is
port (
  clk: in std_logic;
  A: in std_logic_vector( widthDspH12A - 1 downto 0 );
  B: in std_logic_vector( widthDspH12B - 1 downto 0 );
  P: out std_logic_vector( widthDspH12P - 1 downto 0 )
);
end;

architecture rtl of c_dspH12 is

signal dsp: t_dspH12 := ( others => ( others => '0' ) );

begin

P <= dsp.P;

process( clk ) is
begin
if rising_edge( clk ) then

  dsp.A <= A;
  dsp.B <= B;

  dsp.P <= dsp.A * dsp.B;

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.kf_state_pkg.all;

entity c_dspHv0 is
port (
  clk: in std_logic;
  A: in std_logic_vector( widthDspHv0A - 1 downto 0 );
  B: in std_logic_vector( widthDspHv0B - 1 downto 0 );
  P: out std_logic_vector( widthDspHv0P - 1 downto 0 )
);
end;

architecture rtl of c_dspHv0 is

signal dsp: t_dspHv0 := ( others => ( others => '0' ) );

begin

P <= dsp.P;

process( clk ) is
begin
if rising_edge( clk ) then

  dsp.B0 <= B;

  dsp.A <= A;
  dsp.B <= dsp.B0;

  dsp.P <= dsp.A * dsp.B;

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.kf_state_pkg.all;

entity c_dspHv1 is
port (
  clk: in std_logic;
  A: in std_logic_vector( widthDspHv1A - 1 downto 0 );
  B: in std_logic_vector( widthDspHv1B - 1 downto 0 );
  P: out std_logic_vector( widthDspHv1P - 1 downto 0 )
);
end;

architecture rtl of c_dspHv1 is

signal dsp: t_dspHv1 := ( others => ( others => '0' ) );

begin

P <= dsp.P;

process( clk ) is
begin
if rising_edge( clk ) then

  dsp.B0 <= B;

  dsp.A <= A;
  dsp.B <= dsp.B0;

  dsp.P <= dsp.A * dsp.B;

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.kf_state_pkg.all;

entity c_dspH2v0 is
port (
  clk: in std_logic;
  A: in std_logic_vector( widthDspH2v0A - 1 downto 0 );
  B: in std_logic_vector( widthDspH2v0B - 1 downto 0 );
  P: out std_logic_vector( widthDspH2v0P - 1 downto 0 )
);
end;

architecture rtl of c_dspH2v0 is

signal dsp: t_dspH2v0 := ( others => ( others => '0' ) );

begin

P <= dsp.P;

process( clk ) is
begin
if rising_edge( clk ) then

  dsp.B0 <= B;

  dsp.A <= A;
  dsp.B <= dsp.B0;

  dsp.P <= dsp.A * dsp.B;

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.kf_state_pkg.all;

entity c_dspH2v1 is
port (
  clk: in std_logic;
  A: in std_logic_vector( widthDspH2v1A - 1 downto 0 );
  B: in std_logic_vector( widthDspH2v1B - 1 downto 0 );
  P: out std_logic_vector( widthDspH2v1P - 1 downto 0 )
);
end;

architecture rtl of c_dspH2v1 is

signal dsp: t_dspH2v1 := ( others => ( others => '0' ) );

begin

P <= dsp.P;

process( clk ) is
begin
if rising_edge( clk ) then

  dsp.B0 <= B;

  dsp.A <= A;
  dsp.B <= dsp.B0;

  dsp.P <= dsp.A * dsp.B;

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.kf_state_pkg.all;

entity c_dspx0 is
port (
  clk: in std_logic;
  A: in std_logic_vector( widthDspX0A - 1 downto 0 );
  B: in std_logic_vector( widthDspX0B - 1 downto 0 );
  D: in std_logic_vector( widthDspX0D - 1 downto 0 );
  P: out std_logic_vector( widthDspX0P - 1 downto 0 )
);
end;

architecture rtl of c_dspx0 is

signal dsp: t_dspX0 := ( others => ( others => '0' ) );

begin

P <= dsp.P;

process( clk ) is
begin
if rising_edge( clk ) then

  dsp.A0 <= A;

  dsp.A <= dsp.A0;
  dsp.D <= D;

  dsp.B <= B;
  dsp.AD <= dsp.A - dsp.D;

  dsp.M <= dsp.AD * dsp.B;

  dsp.P <= dsp.M;

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.kf_state_pkg.all;

entity c_dspx2 is
port (
  clk: in std_logic;
  A: in std_logic_vector( widthDspX2A - 1 downto 0 );
  B: in std_logic_vector( widthDspX2B - 1 downto 0 );
  D: in std_logic_vector( widthDspX2D - 1 downto 0 );
  P: out std_logic_vector( widthDspX2P - 1 downto 0 )
);
end;

architecture rtl of c_dspx2 is

signal dsp: t_dspX2 := ( others => ( others => '0' ) );

begin

P <= dsp.P;

process( clk ) is
begin
if rising_edge( clk ) then

  dsp.A0 <= A;

  dsp.A <= dsp.A0;
  dsp.D <= D;

  dsp.B <= B;
  dsp.AD <= dsp.A - dsp.D;

  dsp.M <= dsp.AD * dsp.B;

  dsp.P <= dsp.M;

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.kf_state_pkg.all;

entity c_dspx1 is
port (
  clk: in std_logic;
  A: in std_logic_vector( widthDspX1A - 1 downto 0 );
  B: in std_logic_vector( widthDspX1B - 1 downto 0 );
  D: in std_logic_vector( widthDspX1D - 1 downto 0 );
  P: out std_logic_vector( widthDspX1P - 1 downto 0 )
);
end;

architecture rtl of c_dspx1 is

signal dsp: t_dspX1 := ( others => ( others => '0' ) );

begin

P <= dsp.P;

process( clk ) is
begin
if rising_edge( clk ) then

  dsp.B0 <= B;

  dsp.A <= A;
  dsp.B <= dsp.B0;
  dsp.D <= D;

  dsp.M <= ( dsp.A - dsp.D ) * dsp.B;

  dsp.P <= dsp.M;

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.kf_state_pkg.all;

entity c_dspx3 is
port (
  clk: in std_logic;
  A: in std_logic_vector( widthDspX3A - 1 downto 0 );
  B: in std_logic_vector( widthDspX3B - 1 downto 0 );
  D: in std_logic_vector( widthDspX3D - 1 downto 0 );
  P: out std_logic_vector( widthDspX3P - 1 downto 0 )
);
end;

architecture rtl of c_dspx3 is

signal dsp: t_dspX3 := ( others => ( others => '0' ) );

begin

P <= dsp.P;

process( clk ) is
begin
if rising_edge( clk ) then

  dsp.B0 <= B;

  dsp.A <= A;
  dsp.B <= dsp.B0;
  dsp.D <= D;

  dsp.M <= ( dsp.A - dsp.D ) * dsp.B;

  dsp.P <= dsp.M;

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.kf_state_pkg.all;

entity c_dspC00 is
port (
  clk: in std_logic;
  A: in std_logic_vector( widthDspC00A - 1 downto 0 );
  B: in std_logic_vector( widthDspC00B - 1 downto 0 );
  D: in std_logic_vector( widthDspC00D - 1 downto 0 );
  P: out std_logic_vector( widthDspC00P - 1 downto 0 )
);
end;

architecture rtl of c_dspC00 is

signal dsp: t_dspC00 := ( others => ( others => '0' ) );

begin

P <= dsp.P;

process( clk ) is
begin
if rising_edge( clk ) then

  dsp.A <= A;
  dsp.D <= D;

  dsp.B <= B;
  dsp.AD <= dsp.A + dsp.D;

  dsp.M <= dsp.AD * dsp.B;

  dsp.P <= dsp.M;

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.kf_state_pkg.all;

entity c_dspC22 is
port (
  clk: in std_logic;
  A: in std_logic_vector( widthDspC22A - 1 downto 0 );
  B: in std_logic_vector( widthDspC22B - 1 downto 0 );
  D: in std_logic_vector( widthDspC22D - 1 downto 0 );
  P: out std_logic_vector( widthDspC22P - 1 downto 0 )
);
end;

architecture rtl of c_dspC22 is

signal dsp: t_dspC22 := ( others => ( others => '0' ) );

begin

P <= dsp.P;

process( clk ) is
begin
if rising_edge( clk ) then

  dsp.A <= A;
  dsp.D <= D;

  dsp.B <= B;
  dsp.AD <= dsp.A + dsp.D;

  dsp.M <= dsp.AD * dsp.B;

  dsp.P <= dsp.M;

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.kf_state_pkg.all;

entity c_dspC01 is
port (
  clk: in std_logic;
  A: in std_logic_vector( widthDspC01A - 1 downto 0 );
  B: in std_logic_vector( widthDspC01B - 1 downto 0 );
  D: in std_logic_vector( widthDspC01D - 1 downto 0 );
  P: out std_logic_vector( widthDspC01P - 1 downto 0 )
);
end;

architecture rtl of c_dspC01 is

signal dsp: t_dspC01 := ( others => ( others => '0' ) );

begin

P <= dsp.P;

process( clk ) is
begin
if rising_edge( clk ) then

  dsp.B0 <= B;

  dsp.A <= A;
  dsp.B <= dsp.B0;
  dsp.D <= D;

  dsp.P <= ( dsp.A + dsp.D ) * dsp.B;

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.kf_state_pkg.all;

entity c_dspC23 is
port (
  clk: in std_logic;
  A: in std_logic_vector( widthDspC23A - 1 downto 0 );
  B: in std_logic_vector( widthDspC23B - 1 downto 0 );
  D: in std_logic_vector( widthDspC23D - 1 downto 0 );
  P: out std_logic_vector( widthDspC23P - 1 downto 0 )
);
end;

architecture rtl of c_dspC23 is

signal dsp: t_dspC23 := ( others => ( others => '0' ) );

begin

P <= dsp.P;

process( clk ) is
begin
if rising_edge( clk ) then

  dsp.B0 <= B;

  dsp.A <= A;
  dsp.B <= dsp.B0;
  dsp.D <= D;

  dsp.P <= ( dsp.A + dsp.D ) * dsp.B;

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.kf_state_pkg.all;

entity c_dspC11 is
port (
  clk: in std_logic;
  A: in std_logic_vector( widthDspC11A - 1 downto 0 );
  B: in std_logic_vector( widthDspC11B - 1 downto 0 );
  D: in std_logic_vector( widthDspC11D - 1 downto 0 );
  P: out std_logic_vector( widthDspC11P - 1 downto 0 )
);
end;

architecture rtl of c_dspC11 is

signal dsp: t_dspC11 := ( others => ( others => '0' ) );

begin

P <= dsp.P;

process( clk ) is
begin
if rising_edge( clk ) then

  dsp.B0 <= B;

  dsp.A <= A;
  dsp.B <= dsp.B0;
  dsp.D <= D;

  dsp.P <= ( dsp.A + dsp.D ) * dsp.B;

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.kf_state_pkg.all;

entity c_dspC33 is
port (
  clk: in std_logic;
  A: in std_logic_vector( widthDspC33A - 1 downto 0 );
  B: in std_logic_vector( widthDspC33B - 1 downto 0 );
  D: in std_logic_vector( widthDspC33D - 1 downto 0 );
  P: out std_logic_vector( widthDspC33P - 1 downto 0 )
);
end;

architecture rtl of c_dspC33 is

signal dsp: t_dspC33 := ( others => ( others => '0' ) );

begin

P <= dsp.P;

process( clk ) is
begin
if rising_edge( clk ) then

  dsp.B0 <= B;

  dsp.A <= A;
  dsp.B <= dsp.B0;
  dsp.D <= D;

  dsp.P <= ( dsp.A + dsp.D ) * dsp.B;

end if;
end process;

end;
