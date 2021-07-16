library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.kf_data_types.all;


entity kf_node is
port (
  clk: in std_logic; 
  node_din: in t_channelZHT;
  node_dout: out t_channelKF
);
end;


architecture rtl of kf_node is


signal in_din: t_channelZHT := nulll;
signal in_dout: t_channelProto := nulll;
component kf_format_in
port (
  clk: in std_logic;
  in_din: in t_channelZHT;
  in_dout: out t_channelProto
);
end component;

signal delay_track: t_trackZHT := nulll;
signal delay_channel: t_channelProto := nulll;
signal delay_fit: t_channelProto := nulll;
signal delay_residual: t_stubsProto( numLayers - 1 downto 0 ) := ( others => nulll );
signal delay_format: t_trackZHT := nulll;
component kf_delay
port (
  clk: in std_logic;
  delay_track: in t_trackZHT;
  delay_channel: in t_channelProto;
  delay_fit: out t_channelProto;
  delay_residual: out t_stubsProto( numLayers - 1 downto 0 );
  delay_format: out t_trackZHT
);
end component;

signal fit_din: t_channelProto := nulll;
signal fit_dout: t_stateFit := nulll;
component kf_fit
port (
  clk: in std_logic;
  fit_din: in t_channelProto;
  fit_dout: out t_stateFit
);
end component;

signal residual_din: t_channelFit := nulll;
signal residual_dout: t_channelResidual := nulll;
component kf_residual
port (
  clk: in std_logic;
  residual_din: in t_channelFit;
  residual_dout: out t_channelResidual
);
end component;

signal accumulator_din: t_channelResidual := nulll;
signal accumulator_dout: t_channelResidual := nulll;
component kf_accumulator
port (
  clk: in std_logic;
  accumulator_din: in t_channelResidual;
  accumulator_dout: out t_channelResidual
);
end component;

signal out_track: t_trackZHT := nulll;
signal out_channel: t_channelResidual := nulll;
signal out_dout: t_channelKF := nulll;
component kf_format_out
port (
  clk: in std_logic;
  out_track: in t_trackZHT;
  out_channel: in t_channelResidual;
  out_dout: out t_channelKF
);
end component;


begin

in_din <= node_din;

delay_track <= node_din.track;
delay_channel <= in_dout;

fit_din <= delay_fit;

residual_din <= ( fit_dout, delay_residual );

accumulator_din <= residual_dout;

out_track <= delay_format;
out_channel <= accumulator_dout;

node_dout <= out_dout;

fin: kf_format_in port map ( clk, in_din, in_dout );

delay: kf_delay port map ( clk, delay_track, delay_channel, delay_fit, delay_residual, delay_format );

fit: kf_fit port map ( clk, fit_din, fit_dout );

residual: kf_residual port map ( clk, residual_din, residual_dout );

accumulator: kf_accumulator port map ( clk, accumulator_din, accumulator_dout );

fout: kf_format_out port map ( clk, out_track, out_channel, out_dout );


end;