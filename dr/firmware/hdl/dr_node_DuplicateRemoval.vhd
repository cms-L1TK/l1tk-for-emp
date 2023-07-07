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

signal ap_rst: std_logic := '0';
signal ap_start: std_logic := '0';
signal ap_done: std_logic := '0';
signal ap_idle: std_logic := '0';
signal ap_ready: std_logic := '0';
signal trackIn: std_logic_vector( 377 downto 0 ) := ( others => '0' );
signal trackOut: std_logic_vector( 328 downto 0 ) := ( others => '0' );
component DuplicateRemovalTop
port (
  ap_clk: in std_logic;
  ap_rst: in std_logic;
  ap_start: in std_logic;
  ap_done: out std_logic;
  ap_idle: out std_logic;
  ap_ready: out std_logic;
  trackIn: in std_logic_vector( 377 downto 0 );
  trackOut: out std_logic_vector( 328 downto 0 )
);
end component;

constant widthTrack: natural := 1 + 1 + widthDRsector + widthDRinv2R + widthDRphiT + widthDRzT + widthDRcot;
constant widthStubIn: natural := 1 + widthDRstubId + 1 + widthDRlayerId + widthDRr + widthDRphi + widthDRz;
constant widthStubOut: natural := 1 + 1 + widthDRlayerId + widthDRr + widthDRphi + widthDRz;

function conv( t: t_trackDRin ) return std_logic_vector is
  variable s: std_logic_vector( widthTrack + numLayers * widthStubIn - 1 downto 0 );
  variable r: std_logic_vector( s'range );
begin
  s( s'high downto numLayers * widthStubIn ) := t.reset & t.valid & t.sector & t.inv2R & t.phiT & t.zT & t.cot;
  for k in 0 to numLayers - 1 loop
    s( ( k + 1 ) * widthStubIn - 1 downto k * widthStubIn ) := t.stubs( k ).valid & t.stubs( k ).stubId & t.stubs( k ).tilt & t.stubs( k ).layerId & t.stubs( k ).r & t.stubs( k ).phi & t.stubs( k ).z;
  end loop;
  for k in s'range loop
    r( k ) := s( s'high - k );
  end loop;
  return r;
end function;

function conv( r: std_logic_vector ) return t_trackDR is
  variable t: t_trackDR;
  variable s: std_logic_vector( r'range ) := r;
begin
  for k in r'range loop
    s( k ) := r( r'high - k );
  end loop;
  t.reset  := s( 1 + widthDRsector + widthDRinv2R + widthDRphiT + widthDRzT + widthDRcot + numLayers * widthStubOut );
  t.valid  := s(     widthDRsector + widthDRinv2R + widthDRphiT + widthDRzT + widthDRcot + numLayers * widthStubOut );
  t.sector := s(     widthDRsector + widthDRinv2R + widthDRphiT + widthDRzT + widthDRcot + numLayers * widthStubOut - 1 downto widthDRinv2R + widthDRphiT + widthDRzT + widthDRcot + numLayers * widthStubOut );
  t.inv2R  := s(                     widthDRinv2R + widthDRphiT + widthDRzT + widthDRcot + numLayers * widthStubOut - 1 downto                widthDRphiT + widthDRzT + widthDRcot + numLayers * widthStubOut );
  t.phiT   := s(                                    widthDRphiT + widthDRzT + widthDRcot + numLayers * widthStubOut - 1 downto                              widthDRzT + widthDRcot + numLayers * widthStubOut );
  t.zT     := s(                                                  widthDRzT + widthDRcot + numLayers * widthStubOut - 1 downto                                          widthDRcot + numLayers * widthStubOut );
  t.cot    := s(                                                              widthDRcot + numLayers * widthStubOut - 1 downto                                                       numLayers * widthStubOut );
  for k in 0 to numLayers - 1 loop
    t.stubs( numLayers - 1 - k ).valid   := s( 1 + widthDRlayerId + widthDRr + widthDRphi + widthDRz + ( numLayers - k - 1 ) * widthStubOut );
    t.stubs( numLayers - 1 - k ).tilt    := s(     widthDRlayerId + widthDRr + widthDRphi + widthDRz + ( numLayers - k - 1 ) * widthStubOut );
    t.stubs( numLayers - 1 - k ).layerId := s(     widthDRlayerId + widthDRr + widthDRphi + widthDRz + ( numLayers - k - 1 ) * widthStubOut - 1 downto widthDRr + widthDRphi + widthDRz + ( numLayers - k - 1 ) * widthStubOut );
    t.stubs( numLayers - 1 - k ).r       := s(                      widthDRr + widthDRphi + widthDRz + ( numLayers - k - 1 ) * widthStubOut - 1 downto            widthDRphi + widthDRz + ( numLayers - k - 1 ) * widthStubOut );
    t.stubs( numLayers - 1 - k ).phi     := s(                                 widthDRphi + widthDRz + ( numLayers - k - 1 ) * widthStubOut - 1 downto                         widthDRz + ( numLayers - k - 1 ) * widthStubOut );
    t.stubs( numLayers - 1 - k ).z       := s(                                              widthDRz + ( numLayers - k - 1 ) * widthStubOut - 1 downto                                    ( numLayers - k - 1 ) * widthStubOut );
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
    ap_rst <= '1';
  end if;
  if din.reset = '1' then
    ap_start <= '1';
    ap_rst <= '0';
  end if;

  -- input regsiters
  trackIn <= conv( din );

  -- output registers
  dout <= conv( trackOut );

end if;
end process;

c: DuplicateRemovalTop port map (
  ap_clk => clk,
  ap_rst => ap_rst,
  ap_start => ap_start,
  ap_done => ap_done,
  ap_idle => ap_idle,
  ap_ready => ap_ready,
  trackIn => trackIn,
  trackOut => trackOut
);

end;
