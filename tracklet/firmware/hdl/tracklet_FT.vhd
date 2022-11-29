library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.hybrid_data_formats.all;
use work.tracklet_config.all;
use work.tracklet_config_memory.all;
use work.tracklet_data_types.all;


entity tracklet_FT is
port (
  clk: in std_logic;
  ft_din: in t_datas( numInputsFT  - 1 downto 0 );
  ft_rin: in t_reads( numOutputsFT  - 1 downto 0 );
  ft_rout: out t_reads( numInputsFT  - 1 downto 0 );
  ft_dout: out t_datas( numOutputsFT  - 1 downto 0 )
);
end;


architecture rtl of tracklet_FT is


signal notFull: std_logic := '1';


begin


g: for k in 0 to numFT - 1 generate

constant offsetIn: natural := sum( 0 & numNodeInputsFT, 0, k );
constant offsetOut: natural := sum( 0 & numNodeOutputsFT, 0, k );
constant numInputs: natural := numNodeInputsFT( k );
constant numOutputs: natural := numNodeOutputsFT( k );
constant config_memories: t_config_memories( 0 to numInputs - 1 ) := config_memories_in( sumMemInMC + offsetIn to sumMemInMC + offsetIn + numInputs - 1 );

signal din: t_datas( numInputs  - 1 downto 0 ) := ( others => nulll );
signal rout: t_reads( numInputs  - 1 downto 0 ) := ( others => nulll );
signal dout: t_datas( numOutputs  - 1 downto 0 ) := ( others => nulll );

signal start, reset: std_logic := '0';
signal bx: std_logic_vector ( widthBX - 1 downto 0 ) := ( others => '0' );

begin

din <= ft_din( offsetIn + numInputs - 1 downto offsetIn );
ft_rout( offsetIn + numInputs - 1 downto offsetIn ) <= rout;
ft_dout( offsetOut + numOutputs - 1 downto offsetOut ) <= dout;

start <= ft_din( offsetIn + 1 ).start;
bx <= ft_din( offsetIn + 1 ).bx;

process( clk ) is
begin
if rising_edge( clk ) then

  dout( 0 ).start <= reset;

end if;
end process;

L1L2: entity work.FT_L1L2 port map (
  ap_clk => clk,
  ap_rst => '0',
  ap_start => start,
  bx_V => bx,
  ap_done => open,
  ap_idle => open,
  ap_ready => open,
  bx_o_V => open,
  bx_o_V_ap_vld => reset,
  trackWord_V_full_n => notFull,
  barrelStubWords_0_V_full_n => notFull,
  barrelStubWords_1_V_full_n => notFull,
  barrelStubWords_2_V_full_n => notFull,
  barrelStubWords_3_V_full_n => notFull,
  trackWord_V_write => dout( 0 ).valid,
  barrelStubWords_0_V_write => dout( 1 ).valid,
  barrelStubWords_1_V_write => dout( 2 ).valid,
  barrelStubWords_2_V_write => dout( 3 ).valid,
  barrelStubWords_3_V_write => dout( 4 ).valid,
  trackWord_V_din => dout( 0 ).data( r_trackWord ),
  barrelStubWords_0_V_din => dout( 1 ).data( r_stubWord ),
  barrelStubWords_1_V_din => dout( 2 ).data( r_stubWord ),
  barrelStubWords_2_V_din => dout( 3 ).data( r_stubWord ),
  barrelStubWords_3_V_din => dout( 4 ).data( r_stubWord ),
  trackletParameters_0_dataarray_data_V_ce0 => rout( 0 ).valid,
  barrelFullMatches_0_dataarray_data_V_ce0 => rout( 1 ).valid,
  barrelFullMatches_1_dataarray_data_V_ce0 => rout( 2 ).valid,
  barrelFullMatches_2_dataarray_data_V_ce0 => rout( 3 ).valid,
  barrelFullMatches_3_dataarray_data_V_ce0 => rout( 4 ).valid,
  trackletParameters_0_dataarray_data_V_address0 => rout( 0 ).addr( config_memories( 0 ).widthAddr - 1 downto 0 ),
  barrelFullMatches_0_dataarray_data_V_address0 => rout( 1 ).addr( config_memories( 1 ).widthAddr - 1 downto 0 ),
  barrelFullMatches_1_dataarray_data_V_address0 => rout( 2 ).addr( config_memories( 2 ).widthAddr - 1 downto 0 ),
  barrelFullMatches_2_dataarray_data_V_address0 => rout( 3 ).addr( config_memories( 3 ).widthAddr - 1 downto 0 ),
  barrelFullMatches_3_dataarray_data_V_address0 => rout( 4 ).addr( config_memories( 4 ).widthAddr - 1 downto 0 ),
  trackletParameters_0_dataarray_data_V_q0 => din( 0 ).data( config_memories( 0 ).widthData - 1 downto 0 ),
  barrelFullMatches_0_dataarray_data_V_q0 => din( 1 ).data( config_memories( 1 ).widthData - 1 downto 0 ),
  barrelFullMatches_1_dataarray_data_V_q0 => din( 2 ).data( config_memories( 2 ).widthData - 1 downto 0 ),
  barrelFullMatches_2_dataarray_data_V_q0 => din( 3 ).data( config_memories( 3 ).widthData - 1 downto 0 ),
  barrelFullMatches_3_dataarray_data_V_q0 => din( 4 ).data( config_memories( 4 ).widthData - 1 downto 0 ),
  barrelFullMatches_0_nentries_0_V => din( 1 ).nents( 0 )( config_memories( 1 ).widthNent - 1 downto 0 ),
  barrelFullMatches_0_nentries_1_V => din( 1 ).nents( 1 )( config_memories( 1 ).widthNent - 1 downto 0 ),
  barrelFullMatches_1_nentries_0_V => din( 2 ).nents( 0 )( config_memories( 2 ).widthNent - 1 downto 0 ),
  barrelFullMatches_1_nentries_1_V => din( 2 ).nents( 1 )( config_memories( 2 ).widthNent - 1 downto 0 ),
  barrelFullMatches_2_nentries_0_V => din( 3 ).nents( 0 )( config_memories( 3 ).widthNent - 1 downto 0 ),
  barrelFullMatches_2_nentries_1_V => din( 3 ).nents( 1 )( config_memories( 3 ).widthNent - 1 downto 0 ),
  barrelFullMatches_3_nentries_0_V => din( 4 ).nents( 0 )( config_memories( 4 ).widthNent - 1 downto 0 ),
  barrelFullMatches_3_nentries_1_V => din( 4 ).nents( 1 )( config_memories( 4 ).widthNent - 1 downto 0 )
);

gIn: for l in 0 to numInputs - 1 generate
rout( l ).start <= start;
end generate;

end generate;


end;