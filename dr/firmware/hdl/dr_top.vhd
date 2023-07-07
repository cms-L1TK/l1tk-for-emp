library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.hybrid_data_formats.all;

entity dr_top is
port (
  clk: in std_logic;
  dr_din: in t_tracksDRin( numNodesDR - 1 downto 0 );
  dr_dout: out t_tracksDR( numNodesDR - 1 downto 0 )
);
end;

architecture rtl of dr_top is

component dr_node
port (
  clk: in std_logic;
  node_din: in t_trackDRin;
  node_dout: out t_trackDR
);
end component;

begin

g: for k in 0 to numNodesDR - 1 generate

signal node_din: t_trackDRin := nulll;
signal node_dout: t_trackDR := nulll;

begin

node_din <= dr_din( k );
dr_dout( k ) <= node_dout;

c: dr_node port map ( clk, node_din, node_dout );

end generate;

end;
