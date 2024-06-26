library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;

entity tm_transform is
port (
  clk: in std_logic;
  transform_din: in t_channelsTB( tbNumSeedTypes - 1 downto 0 );
  transform_dout: out t_channelsTM( tbNumSeedTypes - 1 downto 0 )
);
end;

architecture rtl of tm_transform is

component tm_transform_node
generic (
  index: natural
);
port (
  clk: in std_logic;
  node_din: in t_channelTB;
  node_dout: out t_channelTM
);
end component;

begin

g: for k in 0 to tbNumSeedTypes - 1 generate

signal node_din: t_channelTB := nulll;
signal node_dout: t_channelTM := nulll;

begin

node_din <= transform_din( k );
transform_dout( k ) <= node_dout;

c: tm_transform_node generic map ( k ) port map ( clk, node_din, node_dout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.hybrid_data_formats.all;
use work.tm_data_types.all;

entity tm_transform_node is
generic (
  index: natural
);
port (
  clk: in std_logic;
  node_din: in t_channelTB;
  node_dout: out t_channelTM
);
end;

architecture rtl of tm_transform_node is

signal unify_din: t_channelTB := nulll;
signal unify_dout: t_channelU := nulll;
component tm_unify
generic (
  seedType: natural
);
port (
  clk: in std_logic;
  unify_din: in t_channelTB;
  unify_dout: out t_channelU
);
end component;

signal high_din: t_channelU := nulll;
signal high_dout: t_channelH := nulll;
component tm_high
port (
  clk: in std_logic;
  high_din: in t_channelU;
  high_dout: out t_channelH
);
end component;

signal low_din: t_channelH := nulll;
signal low_dout: t_channelL := nulll;
component tm_low
port (
  clk: in std_logic;
  low_din: in t_channelH;
  low_dout: out t_channelL
);
end component;

signal router_din: t_channelL := nulll;
signal router_dout: t_channelR := nulll;
component tm_router
generic (
  seedType: natural
);
port (
  clk: in std_logic;
  router_din: in t_channelL;
  router_dout: out t_channelR
);
end component;

signal format_din: t_channelR := nulll;
signal format_dout: t_channelTM := nulll;
component tm_format
port (
  clk: in std_logic;
  format_din: in t_channelR;
  format_dout: out t_channelTM
);
end component;

begin

unify_din <= node_din;

high_din <= unify_dout;

low_din <= high_dout;

router_din <= low_dout;

format_din <= router_dout;

node_dout <= format_dout;

cUnify: tm_unify generic map ( index ) port map ( clk, unify_din, unify_dout );

cHigh: tm_high port map ( clk, high_din, high_dout );

cLow: tm_low port map ( clk, low_din, low_dout );

cRouter: tm_router generic map ( index ) port map ( clk, router_din, router_dout );

cFormat: tm_format port map ( clk, format_din, format_dout );

end; 
