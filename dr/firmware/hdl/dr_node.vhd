library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.dr_data_types.all;

entity dr_node is
port (
  clk: in std_logic;
  node_din: in t_trackDRin;
  node_dout: out t_trackDR
);
end;

architecture rtl of dr_node is

signal tracks: t_tracks( numComparisonModules downto 0 ) := ( others => nulll );
signal tc_dout: t_track; -- remove?

component dr_cm
port (
  clk: in std_logic;
  cm_din: in t_track;
  cm_dout: out t_track
);
end component;

component track_conversion
port (
  clk: in std_logic;
  t_in: in t_trackDRin;
  t_out: out t_track
);
end component;

begin

tc: track_conversion port map ( clk, node_din, tc_dout );
tracks( 0 ) <= tc_dout; -- does this help with timing?! I don't knowwwwwwwwww
node_dout <= conv( tracks( numComparisonModules ) );

g_cm: for k in 0 to numComparisonModules - 1 generate

signal cm_din: t_track := nulll;
signal cm_dout: t_track := nulll;

begin

cm_din <= tracks( k );
tracks( k + 1 ) <= cm_dout;

c: dr_cm port map ( clk, cm_din, cm_dout );

end generate;

end;
