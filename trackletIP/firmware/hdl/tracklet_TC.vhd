library ieee, xil_defaultlib;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.hybrid_data_formats.all;
use work.tracklet_config.all;
use work.tracklet_config_memory.all;
use work.tracklet_data_types.all;


entity tracklet_TC is
port (
  clk: in std_logic;
  tc_din: in t_datas( numInputsTC  - 1 downto 0 );
  tc_rin: in t_reads( numOutputsTC  - 1 downto 0 );
  tc_rout: out t_reads( numInputsTC  - 1 downto 0 );
  tc_dout: out t_datas( numOutputsTC  - 1 downto 0 )
);
end;



architecture rtl of tracklet_TC is


component tracklet_memory is
generic (
  index: natural
);
port (
  clk: in std_logic;
  memory_din: in t_write;
  memory_read: in t_read;
  memory_dout: out t_data
);
end component;


begin


g: for k in 0 to numTC - 1 generate

constant offsetIn: natural := sum( 0 & numNodeInputsTC, 0, k );
constant offsetOut: natural := sum( 0 & numNodeOutputsTC, 0, k );
constant numInputs: natural := numNodeInputsTC( k );
constant numOutputs: natural := numNodeOutputsTC( k );
constant config_memories_out: t_config_memories( 0 to numOutputs - 1 ) := config_memories_out( sumMemOutTE + offsetOut to sumMemOutTE + offsetOut + numOutputs - 1 );
constant config_memories_in: t_config_memories( 0 to numInputs - 1 ) := config_memories_in( sumMemInTe + offsetIn to sumMemInTe + offsetIn + numInputs - 1 );

signal din: t_datas( numInputs  - 1 downto 0 ) := ( others => nulll );
signal rout: t_reads( numInputs  - 1 downto 0 ) := ( others => nulll );

signal reset, start, done, enable: std_logic := '0';
signal bxIn, bxOut: std_logic_vector ( widthBX - 1 downto 0 ) := ( others => '0' );
signal writes: t_writes( numOutputs - 1 downto 0 ) := ( others => nulll );

signal counter: std_logic_vector( widthNent - 1 downto 0 ) := ( others => '0' );

begin

din <= tc_din( offsetIn + numInputs - 1 downto offsetIn );
tc_rout( offsetIn + numInputs - 1 downto offsetIn ) <= rout;

start <= tc_din( offsetIn + 2 ).start;
bxIn <= tc_din( offsetIn + 2 ).bx;

process ( clk ) is
begin
if rising_edge( clk ) then

  reset <= tc_din( offsetIn + 2 ).reset;
  counter <= incr( counter );
  if enable = '1' and uint( counter ) = numFrames - 1 then
    enable <= '0';
  end if;
  if done = '1' then
    enable <= '1';
    counter <= ( others => '0' );
  end if;
  if reset = '1' then
    enable <= '0';
  end if;

end if;
end process;

c: entity xil_defaultlib.TC_L1L2F port map (
  ap_clk => clk,
  ap_rst => reset,
  ap_start => start,
  ap_done => done,
  bx_V => bxIn,
  bx_o_V => bxOut,
  innerStubs_0_dataarray_data_V_address0 => rout( 0 ).addr( config_memories_in( 0 ).widthAddr - 1 downto 0 ),
  innerStubs_0_dataarray_data_V_ce0 => rout( 0 ).valid,
  innerStubs_0_dataarray_data_V_q0 => din( 0 ).data( config_memories_in( 0 ).RAM_WIDTH - 1 downto 0 ),
  outerStubs_0_dataarray_data_V_address0 => rout( 1 ).addr( config_memories_in( 1 ).widthAddr - 1 downto 0 ),
  outerStubs_0_dataarray_data_V_ce0 => rout( 1 ).valid,
  outerStubs_0_dataarray_data_V_q0 => din( 1 ).data( config_memories_in( 1 ).RAM_WIDTH - 1 downto 0 ),
  stubPairs_0_dataarray_data_V_address0 => rout( 2 ).addr( config_memories_in( 2 ).widthAddr - 1 downto 0 ),
  stubPairs_0_dataarray_data_V_ce0 => rout( 2 ).valid,
  stubPairs_0_dataarray_data_V_q0 => din( 2 ).data( config_memories_in( 2 ).RAM_WIDTH - 1 downto 0 ),
  stubPairs_1_dataarray_data_V_address0 => rout( 3 ).addr( config_memories_in( 3 ).widthAddr - 1 downto 0 ),
  stubPairs_1_dataarray_data_V_ce0 => rout( 3 ).valid,
  stubPairs_1_dataarray_data_V_q0 => din( 3 ).data( config_memories_in( 3 ).RAM_WIDTH - 1 downto 0 ),
  stubPairs_2_dataarray_data_V_address0 => rout( 4 ).addr( config_memories_in( 4 ).widthAddr - 1 downto 0 ),
  stubPairs_2_dataarray_data_V_ce0 => rout( 4 ).valid,
  stubPairs_2_dataarray_data_V_q0 => din( 4 ).data( config_memories_in( 4 ).RAM_WIDTH - 1 downto 0 ),
  stubPairs_3_dataarray_data_V_address0 => rout( 5 ).addr( config_memories_in( 5 ).widthAddr - 1 downto 0 ),
  stubPairs_3_dataarray_data_V_ce0 => rout( 5 ).valid,
  stubPairs_3_dataarray_data_V_q0 => din( 5 ).data( config_memories_in( 5 ).RAM_WIDTH - 1 downto 0 ),
  stubPairs_4_dataarray_data_V_address0 => rout( 6 ).addr( config_memories_in( 6 ).widthAddr - 1 downto 0 ),
  stubPairs_4_dataarray_data_V_ce0 => rout( 6 ).valid,
  stubPairs_4_dataarray_data_V_q0 => din( 6 ).data( config_memories_in( 6 ).RAM_WIDTH - 1 downto 0 ),
  stubPairs_5_dataarray_data_V_address0 => rout( 7 ).addr( config_memories_in( 7 ).widthAddr - 1 downto 0 ),
  stubPairs_5_dataarray_data_V_ce0 => rout( 7 ).valid,
  stubPairs_5_dataarray_data_V_q0 => din( 7 ).data( config_memories_in( 7 ).RAM_WIDTH - 1 downto 0 ),
  stubPairs_6_dataarray_data_V_address0 => rout( 8 ).addr( config_memories_in( 8 ).widthAddr - 1 downto 0 ),
  stubPairs_6_dataarray_data_V_ce0 => rout( 8 ).valid,
  stubPairs_6_dataarray_data_V_q0 => din( 8 ).data( config_memories_in( 8 ).RAM_WIDTH - 1 downto 0 ),
  stubPairs_7_dataarray_data_V_address0 => rout( 9 ).addr( config_memories_in( 9 ).widthAddr - 1 downto 0 ),
  stubPairs_7_dataarray_data_V_ce0 => rout( 9 ).valid,
  stubPairs_7_dataarray_data_V_q0 => din( 9 ).data( config_memories_in( 9 ).RAM_WIDTH - 1 downto 0 ),
  stubPairs_8_dataarray_data_V_address0 => rout( 10 ).addr( config_memories_in( 10 ).widthAddr - 1 downto 0 ),
  stubPairs_8_dataarray_data_V_ce0 => rout( 10 ).valid,
  stubPairs_8_dataarray_data_V_q0 => din( 10 ).data( config_memories_in( 10 ).RAM_WIDTH - 1 downto 0 ),
  stubPairs_0_nentries_0_V => din( 2 ).nents( 0 )( config_memories_in( 2 ).widthNent - 1 downto 0 ),
  stubPairs_0_nentries_1_V => din( 2 ).nents( 1 )( config_memories_in( 2 ).widthNent - 1 downto 0 ),
  stubPairs_1_nentries_0_V => din( 3 ).nents( 0 )( config_memories_in( 3 ).widthNent - 1 downto 0 ),
  stubPairs_1_nentries_1_V => din( 3 ).nents( 1 )( config_memories_in( 3 ).widthNent - 1 downto 0 ),
  stubPairs_2_nentries_0_V => din( 4 ).nents( 0 )( config_memories_in( 4 ).widthNent - 1 downto 0 ),
  stubPairs_2_nentries_1_V => din( 4 ).nents( 1 )( config_memories_in( 4 ).widthNent - 1 downto 0 ),
  stubPairs_3_nentries_0_V => din( 5 ).nents( 0 )( config_memories_in( 5 ).widthNent - 1 downto 0 ),
  stubPairs_3_nentries_1_V => din( 5 ).nents( 1 )( config_memories_in( 5 ).widthNent - 1 downto 0 ),
  stubPairs_4_nentries_0_V => din( 6 ).nents( 0 )( config_memories_in( 6 ).widthNent - 1 downto 0 ),
  stubPairs_4_nentries_1_V => din( 6 ).nents( 1 )( config_memories_in( 6 ).widthNent - 1 downto 0 ),
  stubPairs_5_nentries_0_V => din( 7 ).nents( 0 )( config_memories_in( 7 ).widthNent - 1 downto 0 ),
  stubPairs_5_nentries_1_V => din( 7 ).nents( 1 )( config_memories_in( 7 ).widthNent - 1 downto 0 ),
  stubPairs_6_nentries_0_V => din( 8 ).nents( 0 )( config_memories_in( 8 ).widthNent - 1 downto 0 ),
  stubPairs_6_nentries_1_V => din( 8 ).nents( 1 )( config_memories_in( 8 ).widthNent - 1 downto 0 ),
  stubPairs_7_nentries_0_V => din( 9 ).nents( 0 )( config_memories_in( 9 ).widthNent - 1 downto 0 ),
  stubPairs_7_nentries_1_V => din( 9 ).nents( 1 )( config_memories_in( 9 ).widthNent - 1 downto 0 ),
  stubPairs_8_nentries_0_V => din( 10 ).nents( 0 )( config_memories_in( 10 ).widthNent - 1 downto 0 ),
  stubPairs_8_nentries_1_V => din( 10 ).nents( 1 )( config_memories_in( 10 ).widthNent - 1 downto 0 ),
  trackletParameters_dataarray_data_V_address0 => writes( 4 ).addr( config_memories_out( 4 ).widthAddr - 1 downto 0 ),
  trackletParameters_dataarray_data_V_we0 => writes( 4 ).valid,
  trackletParameters_dataarray_data_V_d0 => writes( 4 ).data( config_memories_out( 4 ).RAM_WIDTH - 1 downto 0 ),
  projout_barrel_ps_13_dataarray_data_V_address0 => writes( 0 ).addr( config_memories_out( 0 ).widthAddr - 1 downto 0 ),
  projout_barrel_ps_13_dataarray_data_V_we0 => writes( 0 ).valid,
  projout_barrel_ps_13_dataarray_data_V_d0 => writes( 0 ).data( config_memories_out( 0 ).RAM_WIDTH - 1 downto 0 ),
  projout_barrel_2s_1_dataarray_data_V_address0 => writes( 1 ).addr( config_memories_out( 1 ).widthAddr - 1 downto 0 ),
  projout_barrel_2s_1_dataarray_data_V_we0 => writes( 1 ).valid,
  projout_barrel_2s_1_dataarray_data_V_d0 => writes( 1 ).data( config_memories_out( 1 ).RAM_WIDTH - 1 downto 0 ),
  projout_barrel_2s_5_dataarray_data_V_address0 => writes( 2 ).addr( config_memories_out( 2 ).widthAddr - 1 downto 0 ),
  projout_barrel_2s_5_dataarray_data_V_we0 => writes( 2 ).valid,
  projout_barrel_2s_5_dataarray_data_V_d0 => writes( 2 ).data( config_memories_out( 2 ).RAM_WIDTH - 1 downto 0 ),
  projout_barrel_2s_9_dataarray_data_V_address0 => writes( 3 ).addr( config_memories_out( 3 ).widthAddr - 1 downto 0 ),
  projout_barrel_2s_9_dataarray_data_V_we0 => writes( 3 ).valid,
  projout_barrel_2s_9_dataarray_data_V_d0 => writes( 3 ).data( config_memories_out( 3 ).RAM_WIDTH - 1 downto 0 )
);

gIn: for l in 0 to numInputs - 1 generate
rout( l ).start <= start;
end generate;

gOut: for l in 0 to numOutputs - 1 generate

signal memory_din: t_write := nulll;
signal memory_read: t_read := nulll;
signal memory_dout: t_data := nulll;

begin

writes( l ).reset <= reset;
writes( l ).start <= '1' when done = '1' or enable = '1' else '0';
writes( l ).bx <= bxOut;

memory_din <= writes( l );

memory_read <= tc_rin( offsetOut + l );

tc_dout( offsetOut + l ) <= memory_dout;

c: tracklet_memory generic map ( sumMemOutTE + offsetOut + l ) port map ( clk, memory_din, memory_read, memory_dout );

end generate;

end generate;


end;
