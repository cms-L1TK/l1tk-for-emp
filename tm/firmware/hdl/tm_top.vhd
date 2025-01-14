library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;

entity tm_top is
port (
  clk240: in std_logic;
  clk360: in std_logic;
  tm_packet: in t_packets( 0 to tbNumSeedTypes - 1 );
  tm_din: in t_tracksTB( 0 to tbNumSeedTypes - 1 );
  tm_dout: out t_trackTM
);
end;

architecture rtl of tm_top is

signal process_din: t_tracksTB( 0 to tbNumSeedTypes - 1 ) := ( others => nulll );
signal process_packet: t_packets( 0 to tbNumSeedTypes - 1 ) := ( others => nulll );
signal process_dout: t_tracksTM( 0 to tbNumSeedTypes - 1 ) := ( others => nulll );
component tm_process
port (
  clk240: in std_logic;
  clk360: in std_logic;
  process_din: in t_tracksTB( 0 to tbNumSeedTypes - 1 );
  process_packet: in t_packets( 0 to tbNumSeedTypes - 1 );
  process_dout: out t_tracksTM( 0 to tbNumSeedTypes - 1 )
);
end component;

signal multiplex_din: t_tracksTM( 0 to tbNumSeedTypes - 1 ) := ( others => nulll );
signal multiplex_dout: t_trackTM := nulll;
component tm_multiplex
port (
  clk: in std_logic;
  multiplex_din: in t_tracksTM( 0 to tbNumSeedTypes - 1 );
  multiplex_dout: out t_trackTM
);
end component;

begin

process_din <= tm_din;
process_packet <= tm_packet;

multiplex_din <= process_dout;

tm_dout <= multiplex_dout;

cP: tm_process port map ( clk240, clk360, process_din, process_packet, process_dout );

cM: tm_multiplex port map ( clk360, multiplex_din, multiplex_dout );

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;

entity tm_process is
port (
  clk240: in std_logic;
  clk360: in std_logic;
  process_din: in t_tracksTB( 0 to tbNumSeedTypes - 1 );
  process_packet: in t_packets( 0 to tbNumSeedTypes - 1 );
  process_dout: out t_tracksTM( 0 to tbNumSeedTypes - 1 )
);
end;

architecture rtl of tm_process is

component tm_node
generic (
  index: natural
);
port (
  clk240: in std_logic;
  clk360: in std_logic;
  node_din: in t_trackTB;
  node_packet: in t_packet;
  node_dout: out t_trackTM
);
end component;

begin

g: for k in 0 to tbNumSeedTypes - 1 generate

signal node_din: t_trackTB := nulll;
signal node_packet: t_packet := nulll;
signal node_dout: t_trackTM := nulll;

begin

node_din <= process_din( k );
node_packet <= process_packet( k );

process_dout( k ) <= node_dout;

c: tm_node generic map ( k ) port map ( clk240, clk360, node_din, node_packet, node_dout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;

entity tm_node is
generic (
  index: natural
);
port (
  clk240: in std_logic;
  clk360: in std_logic;
  node_din: in t_trackTB;
  node_packet: in t_packet;
  node_dout: out t_trackTM
);
end;

architecture rtl of tm_node is

signal transform_din: t_trackTB := nulll;
signal transform_dout: t_trackTM := nulll;
component tm_transform
generic (
  index: natural
);
port (
  clk: in std_logic;
  transform_din: in t_trackTB;
  transform_dout: out t_trackTM
);
end component;

signal cdc_din: t_trackTM := nulll;
signal cdc_packet: t_packet := nulll;
signal cdc_dout: t_trackTM := nulll;
component tm_cdc
port (
  clk240: in std_logic;
  clk360: in std_logic;
  cdc_din: in t_trackTM;
  cdc_packet: in t_packet;
  cdc_dout: out t_trackTM
);
end component;

signal desync_din: t_trackTM := nulll;
signal desync_dout: t_trackTM := nulll;
component tm_desync
generic (
  index: natural
);
port (
  clk: in std_logic;
  desync_din: in t_trackTM;
  desync_dout: out t_trackTM
);
end component;

begin

transform_din <= node_din;

cdc_din <= transform_dout;
cdc_packet <= node_packet;

desync_din <= cdc_dout;

node_dout <= desync_dout;

cT: tm_transform generic map ( index ) port map ( clk240, transform_din, transform_dout );

cC: tm_cdc port map ( clk240, clk360, cdc_din, cdc_packet, cdc_dout );

cD: tm_desync generic map ( index ) port map ( clk360, desync_din, desync_dout );

end;
