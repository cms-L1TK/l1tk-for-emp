library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.hybrid_tools.all;
use work.hybrid_data_types.all;
use work.kf_data_formats.all;
use work.kf_data_types.all;

entity kf_fit is
port (
  clk: in std_logic;
  fit_din: in t_state;
  fit_fin: in t_found;
  fit_fout: out t_found;
  fit_dout: out t_final
);
end;

architecture rtl of kf_fit is

constant low: natural := kfNumSeedLayer;
constant high: natural := numLayers - 1;

signal founds: t_founds( low to high + 1 ) := ( others => nulll );
signal states: t_states( low to high + 1 ) := ( others => nulll );
component kf_fit_layer
generic (
  index: natural
);
port (
  clk: in std_logic;
  layer_din: in t_state;
  layer_fin: in t_found;
  layer_fout: out t_found;
  layer_dout: out t_state
);
end component;

begin

states( low ) <= fit_din;
founds( low ) <= fit_fin;

fit_fout <= founds( high + 1 );
fit_dout.meta.reset <= states( high + 1 ).meta.reset;
fit_dout.meta.valid <= states( high + 1 ).meta.valid;
fit_dout.meta.track <= states( high + 1 ).meta.track;
fit_dout.meta.hits  <= states( high + 1 ).meta.hitsS; 
fit_dout.track <= states( high + 1 ).track;

g: for k in low to high generate

signal layer_din: t_state := nulll;
signal layer_fin: t_found := nulll;
signal layer_fout: t_found := nulll;
signal layer_dout: t_state := nulll;

begin

layer_din <= states( k );
layer_fin <= founds( k );
founds( k + 1 ) <= layer_fout;
states( k + 1 ) <= layer_dout;

c: kf_fit_layer generic map ( k ) port map ( clk, layer_din, layer_fin, layer_fout, layer_dout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.kf_data_types.all;

entity kf_fit_layer is
generic (
  index: natural
);
port (
  clk: in std_logic;
  layer_din: in t_state;
  layer_fin: in t_found;
  layer_fout: out t_found;
  layer_dout: out t_state
);
end;

architecture rtl of kf_fit_layer is

signal delay_din: t_found := nulll;
signal delay_stub: t_stub := nulll;
signal delay_dout: t_found := nulll;
component kf_delay
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

signal associator_state: t_state := nulll;
signal associator_stub: t_stub := nulll;
signal associator_dout: t_update := nulll;
component kf_associator
generic (
  index: natural
);
port (
  clk: in std_logic;
  associator_state: in t_state;
  associator_stub: in t_stub;
  associator_dout: out t_update
);
end component;

signal updater_din: t_update := nulll;
signal updater_dout: t_state := nulll;
component kf_updater
generic (
  index: natural
);
port (
  clk: in std_logic;
  updater_din: in t_update;
  updater_dout: out t_state
);
end component;

begin

delay_din <= layer_fin;

associator_state <= layer_din;
associator_stub <= delay_stub;

updater_din <= associator_dout;

layer_dout <= updater_dout;
layer_fout <= delay_dout;

delay: kf_delay generic map ( index ) port map ( clk, delay_din, delay_stub, delay_dout );

associator: kf_associator generic map ( index ) port map ( clk, associator_state, associator_stub, associator_dout );

updater: kf_updater generic map ( index ) port map ( clk, updater_din, updater_dout );

end;