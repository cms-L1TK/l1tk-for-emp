library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.hybrid_data_formats.all;
use work.hybrid_data_types.all;

entity dr_node is
port (
  clk: in std_logic;
  node_din: in t_trackDRin;
  node_dout: out t_trackDR
);
end;

architecture rtl of dr_node is

signal din: t_trackDRin := nulll;
signal dout: t_trackDR := nulll;

signal ap_clk: std_logic := '0';
signal ap_rst: std_logic := '0';
signal ap_start: std_logic := '0';
signal ap_done: std_logic := '0';
signal ap_idle: std_logic := '0';
signal ap_ready: std_logic := '0';
signal din_dout, dinReg: std_logic_vector( 372 downto 0 ) := ( others => '0' );
signal din_empty_n: std_logic := '0';
signal din_read: std_logic := '0';
signal dout_din: std_logic_vector( 323 downto 0 ) := ( others => '0' );
signal dout_full_n: std_logic := '0';
signal dout_write: std_logic := '0';
component TrackMerger
port (
  ap_clk: in std_logic;
  ap_rst: in std_logic;
  ap_start: in std_logic;
  ap_done: out std_logic;
  ap_idle: out std_logic;
  ap_ready: out std_logic;
  din_V_dout: in std_logic_vector( 372 downto 0 );
  din_V_empty_n: in std_logic;
  din_V_read: out std_logic;
  dout_V_din: out std_logic_vector( 323 downto 0 );
  dout_V_full_n: in std_logic;
  dout_V_write: out std_logic
);
end component;

constant widthTrack: natural := 1 + 1 + widthDRinv2R + widthDRphiT + widthDRzT + widthDRcot;
constant widthStubIn: natural := 1 + widthDRstubId + 1 + widthDRlayerId + widthDRr + widthDRphi + widthDRz;
constant widthStubOut: natural := 1 + 1 + widthDRlayerId + widthDRr + widthDRphi + widthDRz;

function conv( t: t_trackDRin ) return std_logic_vector is
  variable s: std_logic_vector( widthTrack + numLayers * widthStubIn - 1 downto 0 );
begin
  s( s'high downto numLayers * widthStubIn ) := t.valid & t.reset & t.inv2R & t.phiT & t.zT & t.cot;
  for k in 0 to numLayers - 1 loop
    s( ( k + 1 ) * widthStubIn - 1 downto k * widthStubIn ) := t.stubs( k ).valid & t.stubs( k ).tilt & t.stubs( k ).layerId & t.stubs( k ).r & t.stubs( k ).phi & t.stubs( k ).z & t.stubs( k ).stubId;
  end loop;
  return s;
end function;

function conv( s: std_logic_vector ) return t_trackDR is
  variable t: t_trackDR;
begin
  t.valid := s( 1 + widthDRinv2R + widthDRphiT + widthDRzT + widthDRcot + numLayers * widthStubOut );
  t.reset := s(     widthDRinv2R + widthDRphiT + widthDRzT + widthDRcot + numLayers * widthStubOut );
  t.inv2R := s(     widthDRinv2R + widthDRphiT + widthDRzT + widthDRcot + numLayers * widthStubOut - 1 downto widthDRphiT + widthDRzT + widthDRcot + numLayers * widthStubOut );
  t.phiT  := s(                    widthDRphiT + widthDRzT + widthDRcot + numLayers * widthStubOut - 1 downto               widthDRzT + widthDRcot + numLayers * widthStubOut );
  t.zT    := s(                                  widthDRzT + widthDRcot + numLayers * widthStubOut - 1 downto                           widthDRcot + numLayers * widthStubOut );
  t.cot   := s(                                              widthDRcot + numLayers * widthStubOut - 1 downto                                        numLayers * widthStubOut );
  for k in 0 to numLayers - 1 loop
    t.stubs( k ).valid   := s( 1 + widthDRlayerId + widthDRr + widthDRphi + widthDRz + ( numLayers - k - 1 ) * widthStubOut );
    t.stubs( k ).tilt    := s(     widthDRlayerId + widthDRr + widthDRphi + widthDRz + ( numLayers - k - 1 ) * widthStubOut );
    t.stubs( k ).layerId := s(     widthDRlayerId + widthDRr + widthDRphi + widthDRz + ( numLayers - k - 1 ) * widthStubOut - 1 downto widthDRr + widthDRphi + widthDRz + ( numLayers - k - 1 ) * widthStubOut );
    t.stubs( k ).r       := s(                      widthDRr + widthDRphi + widthDRz + ( numLayers - k - 1 ) * widthStubOut - 1 downto            widthDRphi + widthDRz + ( numLayers - k - 1 ) * widthStubOut );
    t.stubs( k ).phi     := s(                                 widthDRphi + widthDRz + ( numLayers - k - 1 ) * widthStubOut - 1 downto                         widthDRz + ( numLayers - k - 1 ) * widthStubOut );
    t.stubs( k ).z       := s(                                              widthDRz + ( numLayers - k - 1 ) * widthStubOut - 1 downto                                    ( numLayers - k - 1 ) * widthStubOut );
  end loop;
  return t;
end function;

begin

din <= node_din;
node_dout <= dout;

process ( clk ) is
begin
if rising_edge( clk ) then

  -- hls control logic
  if ap_start = '0' then
    --ap_rst <= '1';
  end if;
  if din.reset = '1' then
    ap_start <= '1';
    --ap_rst <= '0';
  end if;

  -- input regsiters
  dinReg <= conv( din );
  din_dout <= dinReg;

  -- output registers
  dout <= conv( dout_din );

end if;
end process;

ap_clk <= clk;
din_empty_n <= '1';
dout_full_n <= '1';

c: TrackMerger port map (
  ap_clk => ap_clk,
  ap_rst => ap_rst,
  ap_start => ap_start,
  ap_done => ap_done,
  ap_idle => ap_idle,
  ap_ready => ap_ready,
  din_V_dout => din_dout,
  din_V_empty_n => din_empty_n,
  din_V_read => din_read,
  dout_V_din => dout_din,
  dout_V_full_n => dout_full_n,
  dout_V_write => dout_write
);

end;
