library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.kf_data_types.all;

entity kf_top is
port (
  clk: in std_logic;
  kf_din: in t_trackDR;
  kf_dout: out t_trackKF
);
end;

architecture rtl of kf_top is


signal format_din: t_trackDR := nulll;
signal format_found: t_found := nulll;
signal format_dout: t_metaTHH := nulll;
component kf_format
port (
  clk: in std_logic;
  format_din: in t_trackDR;
  format_found: out t_found;
  format_dout: out t_metaTHH
);
end component;

signal seed_din: t_metaTHH := nulll;
signal seed_fin: t_found := nulll;
signal seed_fout: t_found := nulll;
signal seed_dout: t_seed := nulll;
component kf_seed
port (
  clk: in std_logic;
  seed_din: in t_metaTHH;
  seed_fin: in t_found;
  seed_fout: out t_found;
  seed_dout: out t_seed
);
end component;

signal state_din: t_seed := nulll;
signal state_dout: t_state := nulll;
component kf_state
port (
  clk: in std_logic;
  state_din: in t_seed;
  state_dout: out t_state
);
end component;

signal fit_din: t_state := nulll;
signal fit_fin: t_found := nulll;
signal fit_fout: t_found := nulll;
signal fit_dout: t_final := nulll;
component kf_fit
port (
  clk: in std_logic;
  fit_din: in t_state;
  fit_fin: in t_found;
  fit_fout: out t_found;
  fit_dout: out t_final
);
end component;

signal residual_din: t_final := nulll;
signal residual_found: t_found := nulll;
signal residual_dout: t_fitted := nulll;
component kf_residual
port (
  clk: in std_logic;
  residual_din: in t_final;
  residual_found: in t_found;
  residual_dout: out t_fitted
);
end component;

signal accumulator_din: t_fitted := nulll;
signal accumulator_dout: t_trackKF := nulll;
component kf_accumulator
port (
  clk: in std_logic;
  accumulator_din: in t_fitted;
  accumulator_dout: out t_trackKF
);
end component;


begin

format_din <= kf_din;

seed_din <= format_dout;
seed_fin <= format_found;

state_din <= seed_dout;

fit_din <= state_dout;
fit_fin <= seed_fout;

residual_din <= fit_dout;
residual_found <= fit_fout;

accumulator_din <= residual_dout;

kf_dout <= accumulator_dout;

format: kf_format port map ( clk, format_din, format_found, format_dout );

seed: kf_seed port map ( clk, seed_din, seed_fin, seed_fout, seed_dout );

state: kf_state port map ( clk, state_din, state_dout );

fit: kf_fit port map ( clk, fit_din, fit_fin, fit_fout, fit_dout );

residual: kf_residual port map ( clk, residual_din, residual_found, residual_dout );

accumulator: kf_accumulator port map ( clk, accumulator_din, accumulator_dout );

end;