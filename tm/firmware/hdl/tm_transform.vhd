library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.hybrid_data_formats.all;
use work.tm_data_types.all;

entity tm_transform is
generic (
  index: natural
);
port (
  clk: in std_logic;
  transform_din: in t_trackTB;
  transform_dout: out t_trackTM
);
end;

architecture rtl of tm_transform is

signal unify_din: t_trackTB := nulll;
signal unify_dout: t_trackU := nulll;
component tm_unify
generic (
  seedType: natural
);
port (
  clk: in std_logic;
  unify_din: in t_trackTB;
  unify_dout: out t_trackU
);
end component;

signal high_din: t_trackU := nulll;
signal high_dout: t_trackH := nulll;
component tm_high
port (
  clk: in std_logic;
  high_din: in t_trackU;
  high_dout: out t_trackH
);
end component;

signal low_din: t_trackH := nulll;
signal low_dout: t_trackL := nulll;
component tm_low
port (
  clk: in std_logic;
  low_din: in t_trackH;
  low_dout: out t_trackL
);
end component;

signal router_din: t_trackL := nulll;
signal router_dout: t_trackTM := nulll;
component tm_router
generic (
  seedType: natural
);
port (
  clk: in std_logic;
  router_din: in t_trackL;
  router_dout: out t_trackTM
);
end component;

begin

unify_din <= transform_din;

high_din <= unify_dout;

low_din <= high_dout;

router_din <= low_dout;

transform_dout <= router_dout;

cUnify: tm_unify generic map ( index ) port map ( clk, unify_din, unify_dout );

cHigh: tm_high port map ( clk, high_din, high_dout );

cLow: tm_low port map ( clk, low_din, low_dout );

cRouter: tm_router generic map ( index ) port map ( clk, router_din, router_dout );

end; 
