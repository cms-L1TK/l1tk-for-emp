library ieee;
use ieee.std_logic_1164.all;
use work.emp_data_types.all;
use work.emp_device_decl.all;
use work.hybrid_data_types.all;

entity cdc_top is
port (
  clk360: in std_logic;
  clk240: in std_logic;
  cdc_din: in ldata( 4 * N_REGION - 1 downto 0 );
  cdc_dout: out ldata( 4 * N_REGION - 1 downto 0 )
);
end;

architecture rtl of cdc_top is

signal dout: ldata( 4 * N_REGION - 1 downto 0 ) := ( others => nulll );
component cdc_node
port (
  clk360: in std_logic;
  clk240: in std_logic;
  node_din: in lword;
  node_dout: out lword
);
end component;

begin

cdc_dout <= dout;

g: for k in 0 to 0 generate

signal node_din: lword := nulll;
signal node_dout: lword := nulll;

begin

node_din <= cdc_din( k );
dout( k ) <= node_dout;

c: cdc_node port map ( clk360, clk240, node_din, node_dout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.emp_data_types.all;
use work.hybrid_data_types.all;
use work.cdc_pkg.all;

entity cdc_node is
port (
  clk360: in std_logic;
  clk240: in std_logic;
  node_din: in lword;
  node_dout: out lword
);
end;

architecture rtl of cdc_node is

function conv( l: lword ) return t_packet is begin return ( l.valid, l.start_of_orbit ); end function;

signal fts_din: lword := nulll;
signal fts_dout: t_data := nulll;
component cdc_fts
port (
  clk360: in std_logic;
  clk240: in std_logic;
  fts_din: in lword;
  fts_dout: out t_data
);
end component;

signal stf_packet: t_packet := ( others => '0' );
signal stf_din: t_data := nulll;
signal stf_dout: lword := nulll;
component cdc_stf
port (
  clk360: in std_logic;
  clk240: in std_logic;
  stf_packet: in t_packet;
  stf_din: in t_data;
  stf_dout: out lword
);
end component;

begin

fts_din <= node_din;

stf_packet <= conv( node_din );
stf_din <= fts_dout;

node_dout <= stf_dout;

fts: cdc_fts port map ( clk360, clk240, fts_din, fts_dout );

stf: cdc_stf port map ( clk360, clk240, stf_packet, stf_din, stf_dout );

end;
