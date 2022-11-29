library ieee;
use ieee.std_logic_1164.all;
use work.tracklet_config.all;
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

signal process_din: t_datas( numInputsTC  - 1 downto 0 ) := ( others => nulll );
signal process_rout: t_reads( numInputsTC  - 1 downto 0 ) := ( others => nulll );
signal process_dout: t_writes( numOutputsTC  - 1 downto 0 ) := ( others => nulll );
component TC_process
port (
  clk: in std_logic;
  process_din: in t_datas( numInputsTC  - 1 downto 0 );
  process_rout: out t_reads( numInputsTC  - 1 downto 0 );
  process_dout: out t_writes( numOutputsTC  - 1 downto 0 )
);
end component;

signal memories_din: t_writes( numOutputsTC  - 1 downto 0 ) := ( others => nulll );
signal memories_rin: t_reads( numOutputsTC  - 1 downto 0 ) := ( others => nulll );
signal memories_dout: t_datas( numOutputsTC  - 1 downto 0 ) := ( others => nulll );
component TC_memories
port (
  clk: in std_logic;
  memories_din: in t_writes( numOutputsTC  - 1 downto 0 );
  memories_rin: in t_reads( numOutputsTC  - 1 downto 0 );
  memories_dout: out t_datas( numOutputsTC  - 1 downto 0 )
);
end component;

begin

process_din <= tc_din;
memories_din <= process_dout;
memories_rin <= tc_rin;

tc_rout <= process_rout;
tc_dout <= memories_dout;

cP: TC_process port map ( clk, process_din, process_rout, process_dout );

cM: TC_memories port map ( clk, memories_din, memories_rin, memories_dout );

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.tracklet_config.all;
use work.tracklet_config_memory.all;
use work.tracklet_data_types.all;

entity TC_process is
port (
  clk: in std_logic;
  process_din: in t_datas( numInputsTC  - 1 downto 0 );
  process_rout: out t_reads( numInputsTC  - 1 downto 0 );
  process_dout: out t_writes( numOutputsTC  - 1 downto 0 )
);
end;

architecture rtl of TC_process is

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

signal start, done, enable: std_logic := '0';
signal counter: std_logic_vector( widthNent - 1 downto 0 ) := ( others => '0' );
signal bxIn, bxOut: std_logic_vector ( widthBX - 1 downto 0 ) := ( others => '0' );
signal writes: t_writes( numOutputs - 1 downto 0 ) := ( others => nulll );

begin

din <= process_din( offsetIn + numInputs - 1 downto offsetIn );
process_rout( offsetIn + numInputs - 1 downto offsetIn ) <= rout;
process_dout( offsetOut + numOutputs - 1 downto offsetOut ) <= writes;

start <= process_din( offsetIn + 2 ).start;
bxIn <= process_din( offsetIn + 2 ).bx;

process ( clk ) is
begin
if rising_edge( clk ) then

  counter <= incr( counter );
  if enable = '1' and uint( counter ) = numFrames - 1 then
    enable <= '0';
  end if;
  if done = '1' then
    enable <= '1';
    counter <= ( others => '0' );
  end if;

end if;
end process;

gIn: for l in 0 to numInputs - 1 generate
rout( l ).start <= start;
end generate;

gOut: for l in 0 to numOutputs - 1 generate
writes( l ).start <= done or enable;
writes( l ).bx <= bxOut;
end generate;

L1L2F: entity work.TC_L1L2F port map (
  ap_clk => clk,
  ap_rst => '0',
  ap_start => start,
  ap_done => done,
  bx_V => bxIn,
  bx_o_V => bxOut,
  ap_idle => open,
  ap_ready => open,
  bx_o_V_ap_vld => open,
  innerStubs_0_dataarray_data_V_ce0 => rout( 0 ).valid,
  outerStubs_0_dataarray_data_V_ce0 => rout( 1 ).valid,
  stubPairs_0_dataarray_data_V_ce0 => rout( 2 ).valid,
  stubPairs_1_dataarray_data_V_ce0 => rout( 3 ).valid,
  stubPairs_2_dataarray_data_V_ce0 => rout( 4 ).valid,
  stubPairs_3_dataarray_data_V_ce0 => rout( 5 ).valid,
  stubPairs_4_dataarray_data_V_ce0 => rout( 6 ).valid,
  stubPairs_5_dataarray_data_V_ce0 => rout( 7 ).valid,
  stubPairs_6_dataarray_data_V_ce0 => rout( 8 ).valid,
  stubPairs_7_dataarray_data_V_ce0 => rout( 9 ).valid,
  stubPairs_8_dataarray_data_V_ce0 => rout( 10 ).valid,
  innerStubs_0_dataarray_data_V_address0 => rout( 0 ).addr( config_memories_in( 0 ).widthAddr - 1 downto 0 ),
  outerStubs_0_dataarray_data_V_address0 => rout( 1 ).addr( config_memories_in( 1 ).widthAddr - 1 downto 0 ),
  stubPairs_0_dataarray_data_V_address0 => rout( 2 ).addr( config_memories_in( 2 ).widthAddr - 1 downto 0 ),
  stubPairs_1_dataarray_data_V_address0 => rout( 3 ).addr( config_memories_in( 3 ).widthAddr - 1 downto 0 ),
  stubPairs_2_dataarray_data_V_address0 => rout( 4 ).addr( config_memories_in( 4 ).widthAddr - 1 downto 0 ),
  stubPairs_3_dataarray_data_V_address0 => rout( 5 ).addr( config_memories_in( 5 ).widthAddr - 1 downto 0 ),
  stubPairs_4_dataarray_data_V_address0 => rout( 6 ).addr( config_memories_in( 6 ).widthAddr - 1 downto 0 ),
  stubPairs_5_dataarray_data_V_address0 => rout( 7 ).addr( config_memories_in( 7 ).widthAddr - 1 downto 0 ),
  stubPairs_6_dataarray_data_V_address0 => rout( 8 ).addr( config_memories_in( 8 ).widthAddr - 1 downto 0 ),
  stubPairs_7_dataarray_data_V_address0 => rout( 9 ).addr( config_memories_in( 9 ).widthAddr - 1 downto 0 ),
  stubPairs_8_dataarray_data_V_address0 => rout( 10 ).addr( config_memories_in( 10 ).widthAddr - 1 downto 0 ),
  innerStubs_0_dataarray_data_V_q0 => din( 0 ).data( config_memories_in( 0 ).widthData - 1 downto 0 ),
  outerStubs_0_dataarray_data_V_q0 => din( 1 ).data( config_memories_in( 1 ).widthData - 1 downto 0 ),
  stubPairs_0_dataarray_data_V_q0 => din( 2 ).data( config_memories_in( 2 ).widthData - 1 downto 0 ),
  stubPairs_1_dataarray_data_V_q0 => din( 3 ).data( config_memories_in( 3 ).widthData - 1 downto 0 ),
  stubPairs_2_dataarray_data_V_q0 => din( 4 ).data( config_memories_in( 4 ).widthData - 1 downto 0 ),
  stubPairs_3_dataarray_data_V_q0 => din( 5 ).data( config_memories_in( 5 ).widthData - 1 downto 0 ),
  stubPairs_4_dataarray_data_V_q0 => din( 6 ).data( config_memories_in( 6 ).widthData - 1 downto 0 ),
  stubPairs_5_dataarray_data_V_q0 => din( 7 ).data( config_memories_in( 7 ).widthData - 1 downto 0 ),
  stubPairs_6_dataarray_data_V_q0 => din( 8 ).data( config_memories_in( 8 ).widthData - 1 downto 0 ),
  stubPairs_7_dataarray_data_V_q0 => din( 9 ).data( config_memories_in( 9 ).widthData - 1 downto 0 ),
  stubPairs_8_dataarray_data_V_q0 => din( 10 ).data( config_memories_in( 10 ).widthData - 1 downto 0 ),
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
  trackletParameters_dataarray_data_V_ce0 => open,
  projout_barrel_ps_13_dataarray_data_V_ce0 => open,
  projout_barrel_2s_1_dataarray_data_V_ce0 => open,
  projout_barrel_2s_5_dataarray_data_V_ce0 => open,
  projout_barrel_2s_9_dataarray_data_V_ce0 => open,
  trackletParameters_dataarray_data_V_we0 => writes( 4 ).valid,
  projout_barrel_ps_13_dataarray_data_V_we0 => writes( 0 ).valid,
  projout_barrel_2s_1_dataarray_data_V_we0 => writes( 1 ).valid,
  projout_barrel_2s_5_dataarray_data_V_we0 => writes( 2 ).valid,
  projout_barrel_2s_9_dataarray_data_V_we0 => writes( 3 ).valid,
  trackletParameters_dataarray_data_V_address0 => writes( 4 ).addr( config_memories_out( 4 ).widthAddr - 1 downto 0 ),
  projout_barrel_ps_13_dataarray_data_V_address0 => writes( 0 ).addr( config_memories_out( 0 ).widthAddr - 1 downto 0 ),
  projout_barrel_2s_1_dataarray_data_V_address0 => writes( 1 ).addr( config_memories_out( 1 ).widthAddr - 1 downto 0 ),
  projout_barrel_2s_5_dataarray_data_V_address0 => writes( 2 ).addr( config_memories_out( 2 ).widthAddr - 1 downto 0 ),
  projout_barrel_2s_9_dataarray_data_V_address0 => writes( 3 ).addr( config_memories_out( 3 ).widthAddr - 1 downto 0 ),
  trackletParameters_dataarray_data_V_d0 => writes( 4 ).data( config_memories_out( 4 ).widthData - 1 downto 0 ),
  projout_barrel_ps_13_dataarray_data_V_d0 => writes( 0 ).data( config_memories_out( 0 ).widthData - 1 downto 0 ),
  projout_barrel_2s_1_dataarray_data_V_d0 => writes( 1 ).data( config_memories_out( 1 ).widthData - 1 downto 0 ),
  projout_barrel_2s_5_dataarray_data_V_d0 => writes( 2 ).data( config_memories_out( 2 ).widthData - 1 downto 0 ),
  projout_barrel_2s_9_dataarray_data_V_d0 =>  writes( 3 ).data( config_memories_out( 3 ).widthData - 1 downto 0 )
);

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.tracklet_config.all;
use work.tracklet_data_types.all;

entity TC_memories is
port (
  clk: in std_logic;
  memories_din: in t_writes( numOutputsTC  - 1 downto 0 );
  memories_rin: in t_reads( numOutputsTC  - 1 downto 0 );
  memories_dout: out t_datas( numOutputsTC  - 1 downto 0 )
);
end;

architecture rtl of TC_memories is

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

g: for k in 0 to numOutputsTC - 1 generate

signal memory_din: t_write := nulll;
signal memory_read: t_read := nulll;
signal memory_dout: t_data := nulll;

begin

memory_din <= memories_din( k );
memory_read <= memories_rin( k );
memories_dout( k ) <= memory_dout;

c: tracklet_memory generic map ( sumMemOutTE + k ) port map ( clk, memory_din, memory_read, memory_dout );

end generate;

end;