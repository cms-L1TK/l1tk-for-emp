library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.hybrid_data_formats.all;
use work.kfin_data_formats.all;


package kfin_data_types is


type t_ctrl is
record
  reset: std_logic;
  valid: std_logic;
end record;
type t_ctrls is array ( natural range <> ) of t_ctrl;

type t_stubU is
record
  reset: std_logic;
  valid: std_logic;
  pst  : std_logic;
  r    : std_logic_vector( widthUr   - 1 downto 0 );
  phi  : std_logic_vector( widthUphi - 1 downto 0 );
  z    : std_logic_vector( widthUz   - 1 downto 0 );
end record;
type t_stubsU is array ( natural range <> ) of t_stubU;
function nulll return t_stubU;

type t_trackU is
record
  reset: std_logic;
  valid: std_logic;
  inv2R: std_logic_vector( widthUinv2R - 1 downto 0 );
  phiT : std_logic_vector( widthUphiT  - 1 downto 0 );
  cot  : std_logic_vector( widthUcot   - 1 downto 0 );
  zT   : std_logic_vector( widthUzT    - 1 downto 0 );
end record;
type t_tracksU is array ( natural range <> ) of t_trackU;
function nulll return t_trackU;

type t_channelU is
record
  track: t_trackU;
  stubs: t_stubsU( maxNumLayers - 1 downto 0 );
end record;
type t_channelsU is array ( natural range <> ) of t_channelU;
function nulll return t_channelU;

type t_stubH is
record
  reset: std_logic;
  valid: std_logic;
  pst  : std_logic;
  r    : std_logic_vector( widthHr   - 1 downto 0 );
  phi  : std_logic_vector( widthHphi - 1 downto 0 );
  z    : std_logic_vector( widthHz   - 1 downto 0 );
end record;
type t_stubsH is array ( natural range <> ) of t_stubH;
function nulll return t_stubH;

type t_trackH is
record
  reset: std_logic;
  valid: std_logic;
  inv2R: std_logic_vector( widthHinv2R - 1 downto 0 );
  phiT : std_logic_vector( widthHphiT  - 1 downto 0 );
  cot  : std_logic_vector( widthHcot   - 1 downto 0 );
  zT   : std_logic_vector( widthHzT    - 1 downto 0 );
end record;
type t_tracksH is array ( natural range <> ) of t_trackH;
function nulll return t_trackH;

type t_channelH is
record
  track: t_trackH;
  stubs: t_stubsH( maxNumLayers - 1 downto 0 );
end record;
type t_channelsH is array ( natural range <> ) of t_channelH;
function nulll return t_channelH;

type t_stubS is
record
  reset: std_logic;
  valid: std_logic;
  pst  : std_logic;
  r    : std_logic_vector( widthSr   - 1 downto 0 );
  phi  : std_logic_vector( widthSphi - 1 downto 0 );
  z    : std_logic_vector( widthSz   - 1 downto 0 );
end record;
type t_stubsS is array ( natural range <> ) of t_stubS;
function nulll return t_stubS;

type t_trackS is
record
  reset    : std_logic;
  valid    : std_logic;
  sectorPhi: std_logic_vector( widthSsectorPhi - 1 downto 0 );
  sectorEta: std_logic_vector( widthSsectorEta - 1 downto 0 );
  inv2R    : std_logic_vector( widthSinv2R     - 1 downto 0 );
  phiT     : std_logic_vector( widthSphiT      - 1 downto 0 );
  cot      : std_logic_vector( widthScot       - 1 downto 0 );
  zT       : std_logic_vector( widthSzT        - 1 downto 0 );
end record;
type t_tracksS is array ( natural range <> ) of t_trackS;
function nulll return t_trackS;

type t_channelS is
record
  track: t_trackS;
  stubs: t_stubsS( maxNumLayers - 1 downto 0 );
end record;
type t_channeslS is array ( natural range <> ) of t_channelS;
function nulll return t_channelS;

type t_stubL is
record
  reset: std_logic;
  valid: std_logic;
  pst  : std_logic;
  r    : std_logic_vector( widthLr   - 1 downto 0 );
  phi  : std_logic_vector( widthLphi - 1 downto 0 );
  z    : std_logic_vector( widthLz   - 1 downto 0 );
end record;
type t_stubsL is array ( natural range <> ) of t_stubL;
function nulll return t_stubL;

type t_trackL is
record
  reset    : std_logic;
  valid    : std_logic;
  sectorPhi: std_logic_vector( widthLsectorPhi - 1 downto 0 );
  sectorEta: std_logic_vector( widthLsectorEta - 1 downto 0 );
  inv2R    : std_logic_vector( widthLinv2R     - 1 downto 0 );
  phiT     : std_logic_vector( widthLphiT      - 1 downto 0 );
  cot      : std_logic_vector( widthLcot       - 1 downto 0 );
  zT       : std_logic_vector( widthLzT        - 1 downto 0 );
end record;
type t_tracksL is array ( natural range <> ) of t_trackL;
function nulll return t_trackL;

type t_channelL is
record
  track: t_trackL;
  stubs: t_stubsL( maxNumLayers - 1 downto 0 );
end record;
type t_channelsL is array ( natural range <> ) of t_channelL;
function nulll return t_channelL;

type t_trackR is
record
  reset : std_logic;
  valid : std_logic;
  sector: std_logic_vector( widthRsector - 1 downto 0 );
  inv2R : std_logic_vector( widthRinv2R  - 1 downto 0 );
  phiT  : std_logic_vector( widthRphiT   - 1 downto 0 );
  cot   : std_logic_vector( widthRcot    - 1 downto 0 );
  zT    : std_logic_vector( widthRzT     - 1 downto 0 );
end record;
type t_tracksR is array ( natural range <> ) of t_trackR;
function nulll return t_trackR;

type t_stubR is
record
  reset : std_logic;
  valid : std_logic;
  maybe : std_logic;
  barrel: std_logic;
  ps    : std_logic;
  tilt  : std_logic;
  layer : std_logic_vector( widthRlayer - 1 downto 0 );
  r     : std_logic_vector( widthRr     - 1 downto 0 );
  phi   : std_logic_vector( widthRphi   - 1 downto 0 );
  z     : std_logic_vector( widthRz     - 1 downto 0 );
end record;
type t_stubsR is array ( natural range <> ) of t_stubR;
function nulll return t_stubR;

type t_channelRL is
record
  track: t_trackR;
  stubs: t_stubsR( maxNumLayers - 1 downto 0 );
end record;
function nulll return t_channelRL;

type t_channelR is
record
  track: t_trackR;
  stubs: t_stubsR( numLayers - 1 downto 0 );
end record;
function nulll return t_channelR;

type t_lutSeed is array ( 0 to 2 ** widthAddrBRAM18 - 1 ) of std_logic_vector( widthDSPbu - 1 downto 0 );
function init_lutSeed return t_lutSeed;
subtype r_Scot is natural range widthTBcot - unusedMSBScot - 1 - 1 downto baseShiftScot;

constant widthDspSa: natural := widthTBz0 + 1;
constant widthDspSb: natural := 1 + widthDSPbu + 1;
constant widthDspSc: natural := widthuR + 2 + baseShiftUr - baseShiftUz - baseShiftSinvCot;
constant widthDspSd: natural := widthUzT + 1;
constant widthDspSp: natural := max( max( widthDspSa, widthDspSd ) + 1 + widthDspSb, widthDspSc ) + 1;
type t_dspSeed is
record
  A: std_logic_vector( widthDspSa - 1 downto 0 );
  B: std_logic_vector( widthDspSb - 1 downto 0 );
  C: std_logic_vector( widthDspSc - 1 downto 0 );
  D: std_logic_vector( widthDspSd - 1 downto 0 );
  P: std_logic_vector( widthDspSp - 1 downto 0 );
end record;
subtype r_Sr is natural range widthUr + baseShiftUr - baseShiftUz - baseShiftSinvCot + 2 - 1 downto baseShiftUr - baseShiftUz - baseShiftSinvCot + 2;

constant widthDspUphiTa: natural := widthTBinv2R + 1;
constant widthDspUphiTb: natural := widthUr + 1;
constant widthDspUphiTc: natural := widthTBphi0 + 2 + baseShiftTBphi0 - baseShiftTBinv2R;
constant widthDspUphiTp: natural := max( widthDspUphiTa + widthDspUphiTb, widthDspUphiTc ) + 1;
type t_dspUphiT is
record
  A: std_logic_vector( widthDspUphiTa - 1 downto 0 );
  B: std_logic_vector( widthDspUphiTb - 1 downto 0 );
  C: std_logic_vector( widthDspUphiTc - 1 downto 0 );
  P: std_logic_vector( widthDspUphiTp - 1 downto 0 );
end record;
subtype r_UphiT is natural range widthUphiT + 2 - baseShiftTBinv2R + baseShiftTBphi0 - 1 downto 2 - baseShiftTBinv2R + baseShiftTBphi0;
subtype r_overUphiT is natural range widthDspUphiTp - 1 downto widthUphiT + 2 - baseShiftTBinv2R + baseShiftTBphi0 - 1;

constant widthDspUzTa: natural := widthTBcot + 1;
constant widthDspUzTb: natural := widthUr + 1;
constant widthDspUzTc: natural := widthTBz0 + 2 - baseShiftTBcot;
constant widthDspUzTp: natural := max( widthDspUzTa + widthDspUzTb, widthDspUzTc ) + 1;
type t_dspUzT is
record
  A: std_logic_vector( widthDspUzTa - 1 downto 0 );
  B: std_logic_vector( widthDspUzTb - 1 downto 0 );
  C: std_logic_vector( widthDspUzTc - 1 downto 0 );
  P: std_logic_vector( widthDspUzTp - 1 downto 0 );
end record;
subtype r_UzT is natural range widthUzT + 2 - baseShiftTBcot + baseShiftTBz0 - 1 downto 2 - baseShiftTBcot + baseShiftTBz0;
subtype r_overUzT is natural range widthDspUzTp - 1 downto widthUzT + 2 - baseShiftTBcot + baseShiftTBz0 - 1;

constant widthDspSBa: natural := widthTBcot + 1;
constant widthDspSBb: natural := 1 + widthUr + 1;
constant widthDspSBc: natural := widthTBz0 + 2 - baseShiftTBcot;
constant widthDspSBp: natural := max( widthDspSBa + widthDspSBb, widthDspSBc ) + 1;
type t_dspSB is
record
  A: std_logic_vector( widthDspSBa - 1 downto 0 );
  B: std_logic_vector( widthDspSBb - 1 downto 0 );
  C: std_logic_vector( widthDspSBc - 1 downto 0 );
  P: std_logic_vector( widthDspSBp - 1 downto 0 );
end record;
subtype r_SBz is natural range widthDspSBp - 1 downto 2 - baseShiftTBcot;
constant widthSBz: natural := widthDspSBp - ( 2 - baseShiftTBcot );

constant widthDspPBa: natural := widthUr + 1;
constant widthDspPBb: natural := widthTBcot + 1;
constant widthDspPBc: natural := max( widthTBz0, widthUz ) + 1 + 2 - baseShiftTBcot;
constant widthDspPBd: natural := 1 + widthUr + 1;
constant widthDspPBp: natural := max( max( widthDspPBa, widthDspPBd ) + 1 + widthDspSBb, widthDspSBc ) + 1 + 1;
type t_dspPB is
record
  A: std_logic_vector( widthDspPBa - 1 downto 0 );
  B: std_logic_vector( widthDspPBb - 1 downto 0 );
  C: std_logic_vector( widthDspPBc - 1 downto 0 );
  D: std_logic_vector( widthDspPBd - 1 downto 0 );
  P: std_logic_vector( widthDspPBp - 1 downto 0 );
end record;
subtype r_PBz is natural range widthDspPBp - 1 downto 2 - baseShiftTBcot;
constant widthPBz: natural := widthDspPBp - ( 2 - baseShiftTBcot );

constant widthDspUza: natural := widthTBcot + 1;
constant widthDspUzb: natural := widthTBz + 1;
constant widthDspUzp: natural := widthDspUza + widthDspUzb;
type t_dspUz is
record
  A: std_logic_vector( widthDspUza - 1 downto 0 );
  B: std_logic_vector( widthDspUzb - 1 downto 0 );
  P: std_logic_vector( widthDspUzP - 1 downto 0 );
end record;
subtype r_Uz is natural range widthUz + 2 - baseShiftTBcot - 1 - 1 downto 2 - baseShiftTBcot - 1;

constant widthDspHinv2Ra: natural := widthUinv2R + 1;
constant widthDspHinv2Rb: natural := widthDSPportB;
constant widthDspHinv2Rp: natural := widthDspHinv2Ra + widthDspHinv2Rb;
type t_dspHinv2R is
record
  A: std_logic_vector( widthDspHinv2Ra - 1 downto 0 );
  B: std_logic_vector( widthDspHinv2Rb - 1 downto 0 );
  P: std_logic_vector( widthDspHinv2Rp - 1 downto 0 );
end record;
subtype r_Hinv2R is natural range widthDspHinv2Rp - 1 - 1 downto baseShiftTransformHinv2R + 2;

constant widthDspHphiTa: natural := widthUphiT + 1;
constant widthDspHphiTb: natural := widthDSPportB;
constant widthDspHphiTp: natural := widthDspHphiTa + widthDspHphiTb;
type t_dspHphiT is
record
  A: std_logic_vector( widthDspHphiTa - 1 downto 0 );
  B: std_logic_vector( widthDspHphiTb - 1 downto 0 );
  P: std_logic_vector( widthDspHphiTp - 1 downto 0 );
end record;
subtype r_HphiT is natural range widthDspHphiTp - 1 - 1 downto baseShiftTransformHphiT + 2;

constant widthDspHcota: natural := widthUcot + 1;
constant widthDspHcotb: natural := widthDSPportB;
constant widthDspHcotp: natural := widthDspHcota + widthDspHcotb;
type t_dspHcot is
record
  A: std_logic_vector( widthDspHcota - 1 downto 0 );
  B: std_logic_vector( widthDspHcotb - 1 downto 0 );
  P: std_logic_vector( widthDspHcotp - 1 downto 0 );
end record;
subtype r_Hcot is natural range widthDspHcotp - 1 - 1 downto baseShiftTransformHcot + 2;

constant widthDspHzTa: natural := widthUzT + 1;
constant widthDspHzTb: natural := widthDSPportB;
constant widthDspHzTp: natural := widthDspHzTa + widthDspHzTb;
type t_dspHzT is
record
  A: std_logic_vector( widthDspHzTa - 1 downto 0 );
  B: std_logic_vector( widthDspHzTb - 1 downto 0 );
  P: std_logic_vector( widthDspHzTp - 1 downto 0 );
end record;
subtype r_HzT is natural range widthDspHzTp - 1 - 1 downto baseShiftTransformHzT + 2;

constant widthDspHra: natural := widthUr + 1;
constant widthDspHrb: natural := widthDSPportB;
constant widthDspHrp: natural := widthDspHra + widthDspHrb;
type t_dspHr is
record
  A: std_logic_vector( widthDspHra - 1 downto 0 );
  B: std_logic_vector( widthDspHrb - 1 downto 0 );
  P: std_logic_vector( widthDspHrp - 1 downto 0 );
end record;
subtype r_Hr is natural range widthDspHrp - 1 - 1 downto baseShiftTransformHr + 2;

constant widthDspHphia: natural := widthUphi + 1;
constant widthDspHphib: natural := widthDSPportB;
constant widthDspHphip: natural := widthDspHphia + widthDspHphib;
type t_dspHphi is
record
  A: std_logic_vector( widthDspHphia - 1 downto 0 );
  B: std_logic_vector( widthDspHphib - 1 downto 0 );
  P: std_logic_vector( widthDspHphip - 1 downto 0 );
end record;
subtype r_Hphi is natural range widthDspHphip - 1 - 1 downto baseShiftTransformHphi + 2;

constant widthDspHza: natural := widthUz + 1;
constant widthDspHzb: natural := widthDSPportB;
constant widthDspHzp: natural := widthDspHza + widthDspHzb;
type t_dspHz is
record
  A: std_logic_vector( widthDspHza - 1 downto 0 );
  B: std_logic_vector( widthDspHzb - 1 downto 0 );
  P: std_logic_vector( widthDspHzp - 1 downto 0 );
end record;
subtype r_Hz is natural range widthDspHzp - 1 - 1 downto baseShiftTransformHz + 2;

subtype r_overLinv2R is natural range widthSinv2R - 1 downto widthZHTinv2R - baseShiftHinv2R - 1;
subtype r_overLphiT  is natural range widthSphiT  - 1 downto widthZHTphiT  - baseShiftHphiT  - 1;
subtype r_overLcot   is natural range widthScot   - 1 downto widthZHTcot   - baseShiftHcot   - 1;
subtype r_overLzT    is natural range widthSzT    - 1 downto widthZHTzT    - baseShiftHzT    - 1;
subtype r_overLr     is natural range widthSr     - 1 downto widthZHTr     - baseShiftHr     - 1;

subtype r_Linv2R is natural range widthZHTinv2R - baseShiftHinv2R - 1 downto -baseShiftHinv2R;
subtype r_LphiT  is natural range widthZHTphiT  - baseShiftHphiT  - 1 downto -baseShiftHphiT;
subtype r_Lcot   is natural range widthZHTcot   - baseShiftHcot   - 1 downto -baseShiftHcot;
subtype r_LzT    is natural range widthZHTzT    - baseShiftHzT    - 1 downto -baseShiftHzT;
subtype r_Lr     is natural range widthZHTr     - baseShiftHr     - 1 downto -baseShiftHr;

constant baseShiftLphiT: integer := baseShiftTBinv2R - baseShiftTBphi0;
constant baseShiftLdphi: integer := baseShiftHinv2R;
constant widthDspLphia: natural := max( widthLinv2R - baseShiftHinv2R, widthSinv2R ) + 1 + 1;
constant widthDspLphib: natural := widthHr + 1;
constant widthDspLphic: natural := max( widthLphiT - baseShiftHphiT, widthSphiT ) + 1 + 2 - baseShiftLphiT;
constant widthDspLphip: natural := max( widthDspLphia + widthDspLphib, widthDspLphic ) + 1;
type t_dspLphi is
record
  A: std_logic_vector( widthDspLphia - 1 downto 0 );
  B: std_logic_vector( widthDspLphib - 1 downto 0 );
  C: std_logic_vector( widthDspLphic - 1 downto 0 );
  P: std_logic_vector( widthDspLphip - 1 downto 0 );
end record;
subtype r_overLphi is natural range widthDspLphip - 1 downto widthLphi - baseShiftLphiT + 1 - 1;
subtype r_Lphi is natural range widthLphi - baseShiftHphi + 1 - 1 downto -baseShiftHphi + 1;
subtype r_Ldphi is natural range widthDspLphip - 1 downto -baseShiftLdphi + 2;
constant widthLdphi: natural := max( widthDspLphip + baseShiftLdphi - 1, widthSphi ) + 1 - 2;

constant baseShiftLzT: integer := baseShiftTBcot - baseShiftTBz0;
constant baseShiftLdz: integer := baseShiftHcot - 4;
constant widthDspLza: natural := widthHr + 1;
constant widthDspLzb: natural := max( widthLcot - baseShiftHcot, widthScot ) + 1 + 1;
constant widthDspLzc: natural := max( widthLzT - baseShiftHzT, widthSzT ) + 1 + 2 - baseShiftLzT;
constant widthDspLzd: natural := widthHr + 1;
constant widthDspLzp: natural := max( widthDspLza + widthDspLzb + 1, widthDspLzc ) + 1;
type t_dspLz is
record
  A: std_logic_vector( widthDspLza - 1 downto 0 );
  B: std_logic_vector( widthDspLzb - 1 downto 0 );
  C: std_logic_vector( widthDspLzc - 1 downto 0 );
  D: std_logic_vector( widthDspLzd - 1 downto 0 );
  P: std_logic_vector( widthDspLzp - 1 downto 0 );
end record;
subtype r_overLz is natural range widthDspLzp - 1 downto widthLz - baseShiftLzT + 1 - 1;
subtype r_Lz is natural range widthLz - baseShiftHz + 1 - 1 downto -baseShiftHz + 1;
subtype r_Ldz is natural range widthDspLzp - 1 downto -baseShiftLdz + 2;
constant widthLdz: natural := max( widthDspLzp + baseShiftLdz - 1, widthSz ) + 1 - 2;

constant widthDspFdza: natural := widthLcot + 1;
constant widthDspFdzb: natural := widthLr + 1;
constant widthDspFdzc: natural := max( widthLzT  + 1 + baseShiftFz, widthLz + 1 ) + 1 + 1 + baseShiftFcot;
constant widthDspFdzp: natural := max( widthDspFdza + widthDspFdzb, widthDspFdzc ) + 1;
type t_dspFdZ is
record
  A: std_logic_vector( widthDspFdZa - 1 downto 0 );
  B: std_logic_vector( widthDspFdZb - 1 downto 0 );
  C: std_logic_vector( widthDspFdZc - 1 downto 0 );
  P: std_logic_vector( widthDspFdZp - 1 downto 0 );
end record;
subtype r_FdZ is natural range widthDspFdzp - 1 downto 2;

type t_ramFinvR is array ( 0 to 2 ** widthAddrBRAM18 - 1 ) of std_logic_vector( widthDspbu - 1 downto 0 );
function init_ramFinvR return t_ramFinvR;
subtype r_FinvRr is natural range widthLr - 1 downto unusedLSBFinvRr;

constant widthDspFcota: natural := widthDspFdzp - 2 + 1;
constant widthDspFcotb: natural := 1 + widthDspbu + 1;
constant widthDspFcotc: natural := max( widthHcot  + 2, widthLcot + 1 + baseShiftLcot ) + 1 + baseShiftFinvR;
constant widthDspFcotp: natural := max( widthDspFcota + widthDspFcotb, widthDspFcotc ) + 1;
type t_dspFcot is
record
  A: std_logic_vector( widthDspFcota - 1 downto 0 );
  B: std_logic_vector( widthDspFcotb - 1 downto 0 );
  C: std_logic_vector( widthDspFcotc - 1 downto 0 );
  P: std_logic_vector( widthDspFcotp - 1 downto 0 );
end record;
subtype r_Fcot is natural range 1 + usedMSBFcot + 2 + baseShiftFinvR + baseShiftLcot - baseShiftFlutCot - 1 downto 2 + baseShiftFinvR + baseShiftLcot - baseShiftFlutCot;

constant widthDspFdPhia: natural := 1 + widthLengthR + 1;
constant widthDspFdPhib: natural := widthZHTinv2R + 1;
constant widthDspFdPhic: natural := 1 + widthPitchOverR + 2;
constant widthDspFdPhid: natural := widthLengthR + 1;
constant widthDspFdPhip: natural := max( max( widthDspFdPhia, widthDspFdPhid ) + 1 + widthDspFdPhib, widthDspFdPhic ) + 1;
type t_dspFdPhi is
record
  A : std_logic_vector( widthDspFdPhia - 1 downto 0 );
  B0: std_logic_vector( widthDspFdPhib - 1 downto 0 );
  B1: std_logic_vector( widthDspFdPhib - 1 downto 0 );
  C : std_logic_vector( widthDspFdPhic - 1 downto 0 );
  D : std_logic_vector( widthDspFdPhid - 1 downto 0 );
  P : std_logic_vector( widthDspFdPhip - 1 downto 0 );
end record;

subtype r_Fr is natural range widthZHTr - 1 downto unusedLSBFr;
subtype r_FdPhi is natural range widthZHTdPhi + 2 - baseShiftF - 1 downto 2 - baseShiftF;

type t_ramLengths is array ( 0 to 2 ** widthAddrBRAM18 - 1 ) of std_logic_vector( widthLengthZ + widthLengthR - 1 downto 0 );
function init_ramLengths return t_ramLengths;
constant ramLengths: t_ramLengths;

type t_ramPitchOverRs is array ( 0 to 2 ** widthAddrBRAM18 - 1 ) of std_logic_vector( widthPitchOverR - 1 downto 0 ); 
function init_ramPitchOverRs return t_ramPitchOverRs;
constant ramPitchOverRs: t_ramPitchOverRs;

type t_sectorCots is array ( 0 to numSectorsEta - 1 ) of std_logic_vector( widthHcot - 1 downto 0 );
function init_sectorCots return t_sectorCots;
constant sectorCots: t_sectorCots;

end;



package body kfin_data_types is


function nulll return t_stubU is begin return ( '0', '0', '0', others => ( others => '0' ) ); end function;
function nulll return t_stubH is begin return ( '0', '0', '0', others => ( others => '0' ) ); end function;
function nulll return t_stubS is begin return ( '0', '0', '0', others => ( others => '0' ) ); end function;
function nulll return t_stubL is begin return ( '0', '0', '0', others => ( others => '0' ) ); end function;
function nulll return t_stubR is begin return ( '0', '0', '0', '0', '0', '0', others => ( others => '0' ) ); end function;
function nulll return t_trackU is begin return ( '0', '0', others => ( others => '0' ) ); end function;
function nulll return t_trackH is begin return ( '0', '0', others => ( others => '0' ) ); end function;
function nulll return t_trackS is begin return ( '0', '0', others => ( others => '0' ) ); end function;
function nulll return t_trackL is begin return ( '0', '0', others => ( others => '0' ) ); end function;
function nulll return t_trackR is begin return ( '0', '0', others => ( others => '0' ) ); end function;
function nulll return t_channelU is begin return ( nulll, others => ( others => nulll ) ); end function;
function nulll return t_channelH is begin return ( nulll, others => ( others => nulll ) ); end function;
function nulll return t_channelS is begin return ( nulll, others => ( others => nulll ) ); end function;
function nulll return t_channelL is begin return ( nulll, others => ( others => nulll ) ); end function;
function nulll return t_channelR is begin return ( nulll, others => ( others => nulll ) ); end function;
function nulll return t_channelRL is begin return ( nulll, others => ( others => nulll ) ); end function;

function init_lutSeed return t_lutSeed is
  variable lut: t_lutSeed;
  variable cot: real;
begin
  for k in lut'range loop
    cot := ( real( k ) + 0.5 ) * baseScot;
    lut( k ) := stdu( 1.0 / cot / baseSinvCot, widthDSPbu );
  end loop;
  return lut;
end function;

function init_ramLengths return t_ramLengths is
  variable ram: t_ramLengths := ( others => ( others => '0' ) );
  variable index: std_logic_vector( widthAddrBRAM18 - 1 downto 0 );
  variable barrel, ps, tilt: boolean;
  variable cot, length, lengthZ, lengthR: real;
begin
  for k in ram'range loop
    index := stdu( k, widthAddrBRAM18 );
    barrel := bool( index( index'high ) );
    ps := bool( index( index'high - 1 ) );
    tilt := bool( index( index'high - 2 ) );
    cot := ( real( uint( index( index'high - 3 downto 0 ) ) ) + 0.5 ) * baseZHTcot * 2.0 ** (-baseShiftFlutCot);
    length := length2S;
    if ps then
      length := lengthPS;
    end if;
    lengthZ := length;
    lengthR := 0.0;
    if not barrel then
      lengthZ := length * cot;
      lengthR := length;
    elsif tilt then
      lengthZ := lengthZ * abs( tiltApproxSlope * cot + tiltApproxIntercept );
      lengthR := tiltUncertaintyR;
    end if;
    lengthZ := lengthZ + baseZHTz;
    if lengthZ < baseZHTz * 2.0 ** widthLengthZ then
      ram( k )( widthLengthZ + widthLengthR - 1 downto widthLengthR ) := stdu( lengthZ / baseZHTz, widthLengthZ );
    end if;
    if lengthR < baseZHTr * 2.0 ** widthLengthR then
      ram( k )( widthLengthR - 1 downto 0 ) := stdu( lengthR / baseZHTr, widthLengthR );
    end if;
  end loop;
  return ram;
end function;
constant ramLengths: t_ramLengths := init_ramLengths;

function init_ramFinvR return t_ramFinvR is
  variable ram: t_ramFinvR := ( others => ( others => '0' ) );
  variable index: std_logic_vector( widthAddrBRAM18 - 1 downto 0 );
  variable r, invR: real;
begin
  for k in ram'range loop
    index := stdu( k, widthAddrBRAM18 );
    r := ( real( sint( index ) ) + 0.5 ) * baseZHTr * 2.0 ** unusedLSBFinvRr + chosenRofPhi;
    invR := 1.0 / r;
    if r > 0.0 and invR < baseFinvR * 2.0 ** widthDspbu then
      ram( k ) := stdu( invR / baseFinvR, widthDspbu );
    end if;
  end loop;
  return ram;
end function;
 
function init_ramPitchOverRs return t_ramPitchOverRs is
  variable ram: t_ramPitchOverRs := ( others => ( others => '0' ) );
  variable index: std_logic_vector( widthAddrBRAM18 - 1 downto 0 );
  variable ps: boolean;
  variable r: real;
  variable pitch: real;
begin
  for k in ram'range loop
    index := stdu( k, widthAddrBRAM18 );
    ps := bool( index( index'high ) );
    r := ( real( sint( index( index'high - 1 downto 0 ) ) ) + 0.5 ) * baseZHTr * 2.0 ** unusedLSBFr + chosenRofPhi;
    pitch := pitch2S;
    if ps then
      pitch := pitchPS;
    end if;
    if r > 0.0 and pitch / r < baseZHTphi * 2.0 ** ( baseShiftF + widthPitchOverR ) then
      ram( k ) := stdu( pitch / r / baseZHTphi / 2.0 ** baseShiftF, widthPitchOverR );
    end if;
  end loop;
  return ram;
end function;
constant ramPitchOverRs: t_ramPitchOverRs := init_ramPitchOverRs;

function init_sectorCots return t_sectorCots is
  variable res: t_sectorCots;
begin
  for k in res'range loop
    res( k ) := stds( work.hybrid_config.sectorCots( k ) / baseHcot, widthHcot );
  end loop;
  return res;
end function;
constant sectorCots: t_sectorCots := init_sectorCots;


end;