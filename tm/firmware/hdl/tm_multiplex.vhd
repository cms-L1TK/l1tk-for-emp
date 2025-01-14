library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;

entity tm_multiplex is
port (
  clk: in std_logic;
  multiplex_din: in t_tracksTM( 0 to tbNumSeedTypes - 1 );
  multiplex_dout: out t_trackTM
);
end;

architecture rtl of tm_multiplex is

signal mutex: std_logic_vector( 0 to tbNumSeedTypes ) := ( others => '0' );
signal tracks: t_tracksTM( 0 to tbNumSeedTypes ) := ( others => nulll );
component tm_multiplex_node
port (
  clk: in std_logic;
  node_din: in t_trackTM;
  node_rin: in t_trackTM;
  node_min: in std_logic;
  node_mout: out std_logic;
  node_rout: out t_trackTM
);
end component;

begin

multiplex_dout <= tracks( tbNumSeedTypes );

g: for k in 0 to tbNumSeedTypes - 1 generate

signal node_din: t_trackTM := nulll;
signal node_rin: t_trackTM := nulll;
signal node_min: std_logic := '0';
signal node_mout: std_logic := '0';
signal node_rout: t_trackTM := nulll;

begin

node_din <= multiplex_din( k );
node_rin <= tracks( k );
node_min <= mutex( k );
mutex( k + 1 ) <= node_mout;
tracks( k + 1 ) <= node_rout;

c: tm_multiplex_node port map ( clk, node_din, node_rin, node_min, node_mout, node_rout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.hybrid_data_formats.all;
use work.hybrid_data_types.all;

entity tm_multiplex_node is
port (
  clk: in std_logic;
  node_din: in t_trackTM;
  node_rin: in t_trackTM;
  node_min: in std_logic;
  node_mout: out std_logic;
  node_rout: out t_trackTM
);
end;

architecture rtl of tm_multiplex_node is

constant widthStub: natural := 1 + widthTMstubId + widthTMr + widthTMphi + widthTMz;
constant widthRam: natural := tmNumLayers + widthTMinv2R + widthTMphiT + widthTMzT + tmNumLayers * widthStub;
constant widthAddr: natural := widthFrames;
type t_ram is array ( 0 to 2 ** widthAddr - 1 ) of std_logic_vector( widthRam - 1 downto 0 );
function conv( t: t_trackTM ) return std_logic_vector is
  variable std: std_logic_vector( widthRam - 1 downto 0 ) := ( others => '0' );
begin
  std( widthRam - 1 downto tmNumLayers * widthStub ) := t.meta.hits & t.track.inv2R & t.track.phiT & t.track.zT;
  for k in 0 to tmNumLayers - 1 loop
    std( ( k + 1 ) * widthStub - 1 downto k * widthStub ) := t.stubs( k ).pst & t.stubs( k ).stubId & t.stubs( k ).r & t.stubs( k ).phi & t.stubs( k ).z;
  end loop;  
  return std;
end function;
function conv( std: std_logic_vector ) return t_trackTM is
  variable chan: t_trackTM := nulll;
  variable stub: std_logic_vector( widthStub - 1 downto 0 ) := ( others => '0' );
begin
  chan.meta.hits   := std( tmNumLayers + widthTMinv2R + widthTMphiT + widthTMzT + tmNumLayers * widthStub - 1 downto widthTMinv2R + widthTMphiT + widthTMzT + tmNumLayers * widthStub );
  chan.track.inv2R := std(               widthTMinv2R + widthTMphiT + widthTMzT + tmNumLayers * widthStub - 1 downto                widthTMphiT + widthTMzT + tmNumLayers * widthStub );
  chan.track.phiT  := std(                              widthTMphiT + widthTMzT + tmNumLayers * widthStub - 1 downto                              widthTMzT + tmNumLayers * widthStub );
  chan.track.zT    := std(                                            widthTMzT + tmNumLayers * widthStub - 1 downto                                          tmNumLayers * widthStub );
  for k in 0 to tmNumLayers - 1 loop
    stub := std( ( k + 1 ) * widthStub - 1 downto k * widthStub );
    chan.stubs( k ).pst    := stub( widthTMstubId + widthTMr + widthTMphi + widthTMz );
    chan.stubs( k ).stubId := stub( widthTMstubId + widthTMr + widthTMphi + widthTMz - 1 downto widthTMr + widthTMphi + widthTMz );
    chan.stubs( k ).r      := stub(                 widthTMr + widthTMphi + widthTMz - 1 downto            widthTMphi + widthTMz );
    chan.stubs( k ).phi    := stub(                            widthTMphi + widthTMz - 1 downto                         widthTMz );
    chan.stubs( k ).z      := stub(                                         widthTMz - 1 downto                                0 );
  end loop;
  return chan;
end function;

-- step 1

signal reset: std_logic := '0';
signal waddr: std_logic_vector( widthAddr - 1 downto 0 ) := ( others => '0' );
signal ram: t_ram := ( others => ( others => '0' ) );

-- step 2

signal mout: std_logic := '0';
signal optional: t_trackTM := nulll;
signal raddr: std_logic_vector( widthAddr - 1 downto 0 ) := ( others => '0' );

-- step 3

signal mux: t_trackTM := nulll;

-- step 4

signal rout: t_trackTM := nulll;

begin

-- step 2

node_mout <= mout;

-- step 3
node_rout <= rout;

process( clk ) is
begin
if rising_edge( clk ) then

  -- step 1

  reset <= node_din.meta.reset;
  ram( uint( waddr ) ) <= conv( node_din );
  if node_din.meta.valid = '1' then
    waddr <= waddr + 1;
  end if;

  if node_din.meta.reset = '1' then
    waddr <= ( others => '0' );
  end if;

  -- step 2

  mout <= node_min;
  optional <= conv( ram( uint( raddr ) ) );
  if node_min = '0' and waddr /= raddr then
    mout <= '1';
    optional.meta.valid <= '1';
    raddr <= raddr + 1;
  end if;

  if reset = '1' then
    mout <= '0';
    optional.meta.reset <= '1';
  end if;
  if node_din.meta.reset = '1' then
    raddr <= ( others => '0' );
  end if;

  -- step 3

  mux <= optional;

  -- step 4

  rout <= node_rin;
  if mux.meta.valid = '1' then
    rout <= mux;
  end if;
  if mux.meta.reset = '1' then
    rout.meta.reset <= '1';
  end if;

end if;
end process;

end;