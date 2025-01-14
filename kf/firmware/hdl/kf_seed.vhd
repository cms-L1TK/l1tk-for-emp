library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.hybrid_tools.all;
use work.hybrid_data_formats.all;
use work.hybrid_data_types.all;
use work.kf_data_formats.all;
use work.kf_data_types.all;

entity kf_seed is
port (
  clk: in std_logic;
  seed_din: in t_metaTHH;
  seed_fin: in t_found;
  seed_fout: out t_found;
  seed_dout: out t_seed
);
end;

architecture rtl of kf_seed is

signal seeds: t_seeds( 0 to kfMaxSeedLayer ) := ( others => nulll );
signal founds: t_founds( 0 to kfMaxSeedLayer ) := ( others => nulll );
component kf_seed_layer
generic (
  index: natural
);
port (
  clk: in std_logic;
  layer_din: in t_seed;
  layer_fin: in t_found;
  layer_fout: out t_found;
  layer_dout: out t_seed
);
end component;

begin

seeds( 0 ).meta <= seed_din;
founds( 0 ) <= seed_fin;
seed_fout <= founds( kfMaxSeedLayer );
seed_dout <= seeds( kfMaxSeedLayer );

g: for k in 0 to kfMaxSeedLayer - 1 generate

signal layer_din: t_seed := nulll;
signal layer_fin: t_found := nulll;
signal layer_fout: t_found := nulll;
signal layer_dout: t_seed := nulll;

begin

layer_din <= seeds( k );
layer_fin <= founds( k );
founds( k + 1 ) <= layer_fout;
seeds( k + 1 ) <= layer_dout;

c: kf_seed_layer generic map ( k ) port map ( clk, layer_din, layer_fin, layer_fout, layer_dout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.kf_data_types.all;

entity kf_seed_layer is
generic (
  index: natural
);
port (
  clk: in std_logic;
  layer_din: in t_seed;
  layer_fin: in t_found;
  layer_fout: out t_found;
  layer_dout: out t_seed
);
end;

architecture rtl of kf_seed_layer is

signal delay_din: t_found := nulll;
signal delay_stub: t_stub := nulll;
signal delay_dout: t_found := nulll;
component kf_seed_delay
generic (
  index: natural
);
port (
  clk: in std_logic;
  delay_din: in t_found;
  delay_stub: out t_stub;
  delay_dout: out t_found
);
end component;

signal associator_din: t_seed := nulll;
signal associator_stub: t_stub := nulll;
signal associator_dout: t_seed := nulll;
component kf_seed_associator
generic (
  index: natural
);
port (
  clk: in std_logic;
  associator_din: in t_seed;
  associator_stub: in t_stub;
  associator_dout: out t_seed
);
end component;

begin

associator_din <= layer_din;
associator_stub <= delay_stub;

delay_din <= layer_fin;

layer_dout <= associator_dout;
layer_fout <= delay_dout;

cDelay: kf_seed_delay generic map ( index ) port map ( clk, delay_din, delay_stub, delay_dout ); 

cAssoc: kf_seed_associator generic map ( index ) port map ( clk, associator_din, associator_stub, associator_dout );

end;