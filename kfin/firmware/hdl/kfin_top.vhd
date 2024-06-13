library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;

entity kfin_top is
port (
  clk: in std_logic;
  kfin_din: in t_channlesTB( numNodesKF - 1 downto 0 );
  kfin_dout: out t_channelsZHT( numNodesKF - 1 downto 0 )
);
end;

architecture rtl of kfin_top is

component kfin_node
generic (
  index: natural
);
port (
  clk: in std_logic;
  node_din: in t_channelTB;
  node_dout: out t_channelZHT
);
end component;

begin

g: for k in 0 to numNodesKF - 1 generate

signal node_din: t_channelTB := nulll;
signal node_dout: t_channelZHT := nulll;

begin

node_din <= kfin_din( k );
kfin_dout( k ) <= node_dout;

c: kfin_node generic map ( k ) port map ( clk, node_din, node_dout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.hybrid_data_formats.all;
use work.kfin_data_types.all;

entity kfin_node is
generic (
  index: natural
);
port (
  clk: in std_logic;
  node_din: in t_channelTB;
  node_dout: out t_channelZHT
);
end;

architecture rtl of kfin_node is

signal unify_din: t_channelTB := nulll;
signal unify_dout: t_channelU := nulll;
component kfin_unify
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
component kfin_high
port (
  clk: in std_logic;
  high_din: in t_channelU;
  high_dout: out t_channelH
);
end component;

signal sector_din: t_channelH := nulll;
signal sector_dout: t_channelS := nulll;
component kfin_sector
port (
  clk: in std_logic;
  sector_din: in t_channelH;
  sector_dout: out t_channelS
);
end component;

signal low_din: t_channelS := nulll;
signal low_dout: t_channelL := nulll;
component kfin_low
port (
  clk: in std_logic;
  low_din: in t_channelS;
  low_dout: out t_channelL
);
end component;

signal router_din: t_channelL := nulll;
signal router_dout: t_channelR := nulll;
component kfin_router
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
signal format_dout: t_channelZHT := nulll;
component kfin_format
port (
  clk: in std_logic;
  format_din: in t_channelR;
  format_dout: out t_channelZHT
);
end component;

begin

unify_din <= node_din;

high_din <= unify_dout;

sector_din <= high_dout;

low_din <= sector_dout;

router_din <= low_dout;

format_din <= router_dout;

node_dout <= format_dout;

cUnify: kfin_unify generic map ( index ) port map ( clk, unify_din, unify_dout );

cHigh: kfin_high port map ( clk, high_din, high_dout );

cSector: kfin_sector port map ( clk, sector_din, sector_dout );

cLow: kfin_low port map ( clk, low_din, low_dout );

cRouter: kfin_router generic map ( index ) port map ( clk, router_din, router_dout );

cFormat: kfin_format port map ( clk, format_din, format_dout );

end;
