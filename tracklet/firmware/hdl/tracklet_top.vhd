library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.tracklet_config.all;
use work.tracklet_data_types.all;


entity tracklet_top is
port (
  clk: in std_logic;
  tracklet_din: in t_stubsDTC;
  tracklet_dout: out t_channlesTB( numSeedTypes - 1 downto 0 )
);
end;


architecture rtl of tracklet_top is


signal in_din: t_stubsDTC := nulll;
signal in_dout: t_datas( numInputsIR  - 1 downto 0 ) := ( others => nulll );
component tracklet_format_in
port (
  clk: in std_logic;
  in_din: in t_stubsDTC;
  in_dout: out t_datas( numInputsIR  - 1 downto 0 )
);
end component;

signal ir_din: t_datas( numInputsIR  - 1 downto 0 ) := ( others => nulll );
signal ir_rin: t_reads( numOutputsIR  - 1 downto 0 ) := ( others => nulll );
signal ir_rout: t_reads( numInputsIR  - 1 downto 0 ) := ( others => nulll );
signal ir_dout: t_datas( numOutputsIR  - 1 downto 0 ) := ( others => nulll );
component tracklet_IR
port (
  clk: in std_logic;
  ir_din: in t_datas( numInputsIR  - 1 downto 0 );
  ir_rin: in t_reads( numOutputsIR  - 1 downto 0 );
  ir_rout: out t_reads( numInputsIR  - 1 downto 0 );
  ir_dout: out t_datas( numOutputsIR  - 1 downto 0 )
);
end component;

signal vmr_din: t_datas( numInputsVMR  - 1 downto 0 ) := ( others => nulll );
signal vmr_rin: t_reads( numOutputsVMR  - 1 downto 0 ) := ( others => nulll );
signal vmr_rout: t_reads( numInputsVMR  - 1 downto 0 ) := ( others => nulll );
signal vmr_dout: t_datas( numOutputsVMR  - 1 downto 0 ) := ( others => nulll );
component tracklet_VMR
port (
  clk: in std_logic;
  vmr_din: in t_datas( numInputsVMR  - 1 downto 0 );
  vmr_rin: in t_reads( numOutputsVMR  - 1 downto 0 );
  vmr_rout: out t_reads( numInputsVMR  - 1 downto 0 );
  vmr_dout: out t_datas( numOutputsVMR  - 1 downto 0 )
);
end component;

signal te_din: t_datas( numInputsTE  - 1 downto 0 ) := ( others => nulll );
signal te_rin: t_reads( numOutputsTE  - 1 downto 0 ) := ( others => nulll );
signal te_rout: t_reads( numInputsTE  - 1 downto 0 ) := ( others => nulll );
signal te_dout: t_datas( numOutputsTE  - 1 downto 0 ) := ( others => nulll );
component tracklet_TE
port (
  clk: in std_logic;
  te_din: in t_datas( numInputsTE - 1 downto 0 );
  te_rin: in t_reads( numOutputsTE - 1 downto 0 );
  te_rout: out t_reads( numInputsTE - 1 downto 0 );
  te_dout: out t_datas( numOutputsTE - 1 downto 0 )
);
end component;

signal tc_din: t_datas( numInputsTC  - 1 downto 0 ) := ( others => nulll );
signal tc_rin: t_reads( numOutputsTC  - 1 downto 0 ) := ( others => nulll );
signal tc_rout: t_reads( numInputsTC  - 1 downto 0 ) := ( others => nulll );
signal tc_dout: t_datas( numOutputsTC  - 1 downto 0 ) := ( others => nulll );
component tracklet_TC
port (
  clk: in std_logic;
  tc_din: in t_datas( numInputsTC - 1 downto 0 );
  tc_rin: in t_reads( numOutputsTC - 1 downto 0 );
  tc_rout: out t_reads( numInputsTC - 1 downto 0 );
  tc_dout: out t_datas( numOutputsTC - 1 downto 0 )
);
end component;

signal pr_din: t_datas( numInputsPR  - 1 downto 0 ) := ( others => nulll );
signal pr_rin: t_reads( numOutputsPR  - 1 downto 0 ) := ( others => nulll );
signal pr_rout: t_reads( numInputsPR  - 1 downto 0 ) := ( others => nulll );
signal pr_dout: t_datas( numOutputsPR  - 1 downto 0 ) := ( others => nulll );
component tracklet_PR
port (
  clk: in std_logic;
  pr_din: in t_datas( numInputsPR - 1 downto 0 );
  pr_rin: in t_reads( numOutputsPR - 1 downto 0 );
  pr_rout: out t_reads( numInputsPR - 1 downto 0 );
  pr_dout: out t_datas( numOutputsPR - 1 downto 0 )
);
end component;

signal me_din: t_datas( numInputsME  - 1 downto 0 ) := ( others => nulll );
signal me_rin: t_reads( numOutputsME  - 1 downto 0 ) := ( others => nulll );
signal me_rout: t_reads( numInputsME  - 1 downto 0 ) := ( others => nulll );
signal me_dout: t_datas( numOutputsME  - 1 downto 0 ) := ( others => nulll );
component tracklet_ME
port (
  clk: in std_logic;
  me_din: in t_datas( numInputsME - 1 downto 0 );
  me_rin: in t_reads( numOutputsME - 1 downto 0 );
  me_rout: out t_reads( numInputsME - 1 downto 0 );
  me_dout: out t_datas( numOutputsME - 1 downto 0 )
);
end component;

signal mc_din: t_datas( numInputsMC  - 1 downto 0 ) := ( others => nulll );
signal mc_rin: t_reads( numOutputsMC  - 1 downto 0 ) := ( others => nulll );
signal mc_rout: t_reads( numInputsMC  - 1 downto 0 ) := ( others => nulll );
signal mc_dout: t_datas( numOutputsMC  - 1 downto 0 ) := ( others => nulll );
component tracklet_MC
port (
  clk: in std_logic;
  mc_din: in t_datas( numInputsMC - 1 downto 0 );
  mc_rin: in t_reads( numOutputsMC - 1 downto 0 );
  mc_rout: out t_reads( numInputsMC - 1 downto 0 );
  mc_dout: out t_datas( numOutputsMC - 1 downto 0 )
);
end component;

signal ft_din: t_datas( numInputsFT  - 1 downto 0 ) := ( others => nulll );
signal ft_rin: t_reads( numOutputsFT  - 1 downto 0 ) := ( others => nulll );
signal ft_rout: t_reads( numInputsFT  - 1 downto 0 ) := ( others => nulll );
signal ft_dout: t_datas( numOutputsFT  - 1 downto 0 ) := ( others => nulll );
component tracklet_FT
port (
  clk: in std_logic;
  ft_din: in t_datas( numInputsFT - 1 downto 0 );
  ft_rin: in t_reads( numOutputsFT - 1 downto 0 );
  ft_rout: out t_reads( numInputsFT - 1 downto 0 );
  ft_dout: out t_datas( numOutputsFT - 1 downto 0 )
);
end component;

signal out_din: t_datas( numOutputsFT - 1 downto 0 ) := ( others => nulll );
signal out_dout: t_channlesTB( numSeedTypes - 1 downto 0 ) := ( others => nulll );
component tracklet_format_out
port (
  clk: in std_logic;
  out_din: in t_datas( numOutputsFT - 1 downto 0 );
  out_dout: out t_channlesTB( numSeedTypes - 1 downto 0 )
);
end component;

signal readsOut: t_reads( numMemories - 1 downto 0 ) := ( others => nulll );
signal readsIn: t_reads( numMemories - 1 downto 0 ) := ( others => nulll );
signal datasOut: t_datas( numMemories - 1 downto 0 ) := ( others => nulll );
signal datasIn: t_datas( numMemories - 1 downto 0 ) := ( others => nulll );


begin


datasOut <= MC_dout & ME_dout & PR_dout & TC_dout & TE_dout & VMR_dout & IR_dout;
readsOut <= FT_rout & MC_rout & ME_rout & PR_rout & TC_rout & TE_rout & VMR_rout;

readsIn <= f_map( readsOut );
datasIn <= f_map( datasOut );

in_din   <= tracklet_din;

ir_din  <= in_dout;
ir_rin  <= readsIn(                numOutputsIR  - 1 downto 0            );

vmr_din <= datasIn(                numInputsVMR  - 1 downto 0            );
vmr_rin <= readsIn( sumMemOutIR  + numOutputsVMR - 1 downto sumMemOutIR  );

te_din  <= datasIn( sumMemInVMR  + numInputsTE   - 1 downto sumMemInVMR  );
te_rin  <= readsIn( sumMemOutVMR + numOutputsTE  - 1 downto sumMemOutVMR );

tc_din  <= datasIn( sumMemInTE   + numInputsTC   - 1 downto sumMemInTE   );
tc_rin  <= readsIn( sumMemOutTE  + numOutputsTC  - 1 downto sumMemOutTE  );

pr_din  <= datasIn( sumMemInTC   + numInputsPR   - 1 downto sumMemInTC   );
pr_rin  <= readsIn( sumMemOutTC  + numOutputsPR  - 1 downto sumMemOutTC  );

me_din  <= datasIn( sumMemInPR   + numInputsME   - 1 downto sumMemInPR   );
me_rin  <= readsIn( sumMemOutPR  + numOutputsME  - 1 downto sumMemOutPR  );

mc_din  <= datasIn( sumMemInME   + numInputsMC   - 1 downto sumMemInME   );
mc_rin  <= readsIn( sumMemOutME  + numOutputsMC  - 1 downto sumMemOutME  );

ft_din  <= datasIn( sumMemInMC   + numInputsFT   - 1 downto sumMemInMC   );

out_din <= ft_dout;

tracklet_dout <= out_dout;

Fin: tracklet_format_in port map ( clk, in_din, in_dout );

IR:  tracklet_IR  port map ( clk, ir_din,  ir_rin,  ir_rout,  ir_dout );

VMR: tracklet_VMR port map ( clk, vmr_din, vmr_rin, vmr_rout, vmr_dout );

TE:  tracklet_TE  port map ( clk, te_din,  te_rin,  te_rout,  te_dout );

TC:  tracklet_TC  port map ( clk, tc_din,  tc_rin,  tc_rout,  tc_dout );

PR:  tracklet_PR  port map ( clk, pr_din,  pr_rin,  pr_rout,  pr_dout );

ME:  tracklet_ME  port map ( clk, me_din,  me_rin,  me_rout,  me_dout );

MC:  tracklet_MC  port map ( clk, mc_din,  mc_rin,  mc_rout,  mc_dout );

FT:  tracklet_FT  port map ( clk, ft_din,  ft_rin,  ft_rout,  ft_dout );

Fout: tracklet_format_out port map ( clk, out_din, out_dout );


end;
