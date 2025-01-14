library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.dr_data_types.all;


entity dr_top is
port (
  clk: in std_logic;
  dr_din: in t_trackTM;
  dr_dout: out t_trackDR
);
end;


architecture rtl of dr_top is


signal core_din: t_trackTM := nulll;
signal core_dout: t_trackCore := nulll;
component dr_core
port (
  clk: in std_logic;
  core_din: in t_trackTM;
  core_dout: out t_trackCore
);
end component;

signal calc_din: t_trackCore := nulll;
signal calc_dout: t_trackCalc := nulll;
component dr_calc
port (
  clk: in std_logic;
  calc_din: in t_trackCore;
  calc_dout: out t_trackCalc
);
end component;

signal route_din: t_trackCalc := nulll;
signal route_dout: t_trackDR := nulll;
component dr_route
port (
  clk: in std_logic;
  route_din: in t_trackCalc;
  route_dout: out t_trackDR
);
end component;


begin


core_din <= dr_din;

calc_din <= core_dout;

route_din <= calc_dout;

dr_dout <= route_dout;

cCore: dr_core port map ( clk, core_din, core_dout );

cCalc: dr_calc port map ( clk, calc_din, calc_dout );

cRoute: dr_route port map ( clk, route_din, route_dout );


end;
