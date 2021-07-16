library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.hybrid_tools.all;
use work.hybrid_data_types.all;
use work.kf_data_types.all;

entity kf_fit is
port (
  clk: in std_logic;
  fit_din: in t_channelProto;
  fit_dout: out t_stateFit
);
end;

architecture rtl of kf_fit is

signal states: t_states( 0 to numLayers ) := ( others => nulll );
component kf_fit_layer
generic (
  index: natural
);
port (
  clk: in std_logic;
  layer_state: in t_state;
  layer_stub: in t_stubProto;
  layer_dout: out t_state
);
end component;

begin

states( 0 ) <= conv( fit_din.state );

fit_dout <= f_conv( states( numLayers ) );

g: for k in 0 to numLayers - 1 generate

signal layer_state: t_state := nulll;
signal layer_stub: t_stubProto := nulll;
signal layer_dout: t_state := nulll;

begin

layer_state <= states( k );
layer_stub <= fit_din.stubs( k );
states( k + 1 ) <= layer_dout;

c: kf_fit_layer generic map ( k ) port map ( clk, layer_state, layer_stub, layer_dout );

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
  layer_state: in t_state;
  layer_stub: in t_stubProto;
  layer_dout: out t_state
);
end;

architecture rtl of kf_fit_layer is

signal associator_state: t_state := nulll;
signal associator_stub: t_stubProto := nulll;
signal associator_dout: t_state := nulll;
component kf_associator
generic (
  index: natural
);
port (
  clk: in std_logic;
  associator_state: in t_state;
  associator_stub: in t_stubProto;
  associator_dout: out t_state
);
end component;

signal updater_din: t_state := nulll;
signal updater_dout: t_state := nulll;
component kf_updater
generic (
  index: natural
);
port (
  clk: in std_logic;
  updater_din: in t_state;
  updater_dout: out t_state
);
end component;

begin

associator_state <= layer_state;
associator_stub <= layer_stub;

updater_din <= associator_dout;
layer_dout <= updater_dout;

associator: kf_associator generic map ( index ) port map ( clk, associator_state, associator_stub, associator_dout );

updater: kf_updater generic map ( index ) port map ( clk, updater_din, updater_dout );

end;