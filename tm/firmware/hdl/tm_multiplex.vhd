library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;

entity tm_multiplex is
port (
  clk: in std_logic;
  multiplex_din: in t_channelsTM( tbNumSeedTypes - 1 downto 0 );
  multiplex_dout: out t_channelTM
);
end;

architecture rtl of tm_multiplex is

signal mutex: std_logic_vector( tbNumSeedTypes downto 0 ) := ( others => '0' );
signal channels: t_channelsTM( tbNumSeedTypes downto 0 ) := ( others => nulll );
component tm_multiplex_node
port (
  clk: in std_logic;
  node_din: in t_channelTM;
  node_rin: in t_channelTM;
  node_min: in std_logic;
  node_mout: out std_logic;
  node_rout: out t_channelTM
);
end component;

begin

multiplex_dout <= channels( tbNumSeedTypes );

g: for k in 0 to tbNumSeedTypes - 1 generate

signal node_din: t_channelTM := nulll;
signal node_rin: t_channelTM := nulll;
signal node_min: std_logic := '0';
signal node_mout: std_logic := '0';
signal node_rout: t_channelTM := nulll;

begin

node_din <= multiplex_din( k );
node_rin <= channels( k );
node_min <= mutex( k );
mutex( k + 1 ) <= node_mout;
channels( k + 1 ) <= node_rout;

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
  node_din: in t_channelTM;
  node_rin: in t_channelTM;
  node_min: in std_logic;
  node_mout: out std_logic;
  node_rout: out t_channelTM
);
end;

architecture rtl of tm_multiplex_node is

constant widthStub: natural := 1 + widthTMstubId + widthTMr + widthTMphi + widthTMz + widthTMdPhi + widthTMdZ;
constant widthRam: natural := widthTMinv2R + widthTMphiT + widthTMzT + numLayers * widthStub;
constant widthAddr: natural := widthFrames;
type t_ram is array ( 0 to 2 ** widthAddr - 1 ) of std_logic_vector( widthRam - 1 downto 0 );
function conv( channel: t_channelTM ) return std_logic_vector is
  variable std: std_logic_vector( widthRam - 1 downto 0 ) := ( others => '0' );
begin
  std( widthRam - 1 downto numLayers * widthStub ) := channel.track.inv2R & channel.track.phiT & channel.track.zT;
  for k in 0 to numLayers - 1 loop
    std( ( k + 1 ) * widthStub - 1 downto k * widthStub ) := channel.stubs( k ).valid & channel.stubs( k ).stubId & channel.stubs( k ).r & channel.stubs( k ).phi & channel.stubs( k ).z & channel.stubs( k ).dPhi & channel.stubs( k ).dZ;
  end loop;  
  return std;
end function;
function conv( std: std_logic_vector ) return t_channelTM is
  variable chan: t_channelTM := nulll;
  variable stub: std_logic_vector( widthStub - 1 downto 0 ) := ( others => '0' );
begin
  chan.track.inv2R := std( widthTMinv2R + widthTMphiT + widthTMzT + numLayers * widthStub - 1 downto widthTMphiT + widthTMzT + numLayers * widthStub );
  chan.track.phiT  := std(                widthTMphiT + widthTMzT + numLayers * widthStub - 1 downto               widthTMzT + numLayers * widthStub );
  chan.track.zT    := std(                              widthTMzT + numLayers * widthStub - 1 downto                           numLayers * widthStub );
  for k in 0 to numLayers - 1 loop
    stub := std( ( k + 1 ) * widthStub - 1 downto k * widthStub );
    chan.stubs( k ).valid  := stub( 1 + widthTMstubId + widthTMr + widthTMphi + widthTMz + widthTMdPhi + widthTMdZ - 1 );
    chan.stubs( k ).stubId := stub(     widthTMstubId + widthTMr + widthTMphi + widthTMz + widthTMdPhi + widthTMdZ - 1 downto widthTMr + widthTMphi + widthTMz + widthTMdPhi + widthTMdZ );
    chan.stubs( k ).r      := stub(                     widthTMr + widthTMphi + widthTMz + widthTMdPhi + widthTMdZ - 1 downto            widthTMphi + widthTMz + widthTMdPhi + widthTMdZ );
    chan.stubs( k ).phi    := stub(                                widthTMphi + widthTMz + widthTMdPhi + widthTMdZ - 1 downto                         widthTMz + widthTMdPhi + widthTMdZ );
    chan.stubs( k ).z      := stub(                                             widthTMz + widthTMdPhi + widthTMdZ - 1 downto                                    widthTMdPhi + widthTMdZ );
    chan.stubs( k ).dPhi   := stub(                                                        widthTMdPhi + widthTMdZ - 1 downto                                                  widthTMdZ );
    chan.stubs( k ).dZ     := stub(                                                                      widthTMdZ - 1 downto                                                          0 );
  end loop;
  return chan;
end function;

-- step 1

signal reset: std_logic := '0';
signal waddr: std_logic_vector( widthAddr - 1 downto 0 ) := ( others => '0' );
signal ram: t_ram := ( others => ( others => '0' ) );

-- step 2

signal mout: std_logic := '0';
signal optional: t_channelTM := nulll;
signal raddr: std_logic_vector( widthAddr - 1 downto 0 ) := ( others => '0' );

-- step 3

signal mux: t_channelTM := nulll;

-- step 4

signal rout: t_channelTM := nulll;

begin

-- step 2

node_mout <= mout;

-- step 3
node_rout <= rout;

process( clk ) is
begin
if rising_edge( clk ) then

  -- step 1

  reset <= node_din.track.reset;
  ram( uint( waddr ) ) <= conv( node_din );
  if node_din.track.valid = '1' then
    waddr <= waddr + 1;
  end if;

  if node_din.track.reset = '1' then
    waddr <= ( others => '0' );
  end if;

  -- step 2

  mout <= node_min;
  optional <= conv( ram( uint( raddr ) ) );
  if node_min = '0' and waddr /= raddr then
    mout <= '1';
    optional.track.valid <= '1';
    raddr <= raddr + 1;
  end if;

  if reset = '1' then
    mout <= '0';
    optional.track.reset <= '1';
  end if;
  if node_din.track.reset = '1' then
    raddr <= ( others => '0' );
  end if;

  -- step 3

  mux <= optional;

  -- step 4

  rout <= node_rin;
  if mux.track.valid = '1' then
    rout <= mux;
  end if;
  if mux.track.reset = '1' then
    rout.track.reset <= '1';
    for k in optional.stubs'range loop
      rout.stubs( k ).reset <= '1';
    end loop;
  end if;

end if;
end process;

end;