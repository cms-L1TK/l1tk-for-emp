library ieee;
use ieee.std_logic_1164.all;
use work.tracklet_config.all;
use work.tracklet_data_types.all;

entity tracklet_ME is
port (
  clk: in std_logic;
  me_din: in t_datas( numInputsME  - 1 downto 0 );
  me_rin: in t_reads( numOutputsME  - 1 downto 0 );
  me_rout: out t_reads( numInputsME  - 1 downto 0 );
  me_dout: out t_datas( numOutputsME  - 1 downto 0 )
);
end;

architecture rtl of tracklet_ME is

signal process_din: t_datas( numInputsME  - 1 downto 0 ) := ( others => nulll );
signal process_rout: t_reads( numInputsME  - 1 downto 0 ) := ( others => nulll );
signal process_dout: t_writes( numOutputsME  - 1 downto 0 ) := ( others => nulll );
component ME_process
port (
  clk: in std_logic;
  process_din: in t_datas( numInputsME  - 1 downto 0 );
  process_rout: out t_reads( numInputsME  - 1 downto 0 );
  process_dout: out t_writes( numOutputsME  - 1 downto 0 )
);
end component;

signal memories_din: t_writes( numOutputsME  - 1 downto 0 ) := ( others => nulll );
signal memories_rin: t_reads( numOutputsME  - 1 downto 0 ) := ( others => nulll );
signal memories_dout: t_datas( numOutputsME  - 1 downto 0 ) := ( others => nulll );
component ME_memories
port (
  clk: in std_logic;
  memories_din: in t_writes( numOutputsME  - 1 downto 0 );
  memories_rin: in t_reads( numOutputsME  - 1 downto 0 );
  memories_dout: out t_datas( numOutputsME  - 1 downto 0 )
);
end component;

begin

process_din <= me_din;
memories_din <= process_dout;
memories_rin <= me_rin;

me_rout <= process_rout;
me_dout <= memories_dout;

cP: ME_process port map ( clk, process_din, process_rout, process_dout );

CM: ME_memories port map ( clk, memories_din, memories_rin, memories_dout );

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.tracklet_config.all;
use work.tracklet_config_memory.all;
use work.tracklet_data_types.all;

entity ME_process is
port (
  clk: in std_logic;
  process_din: in t_datas( numInputsME  - 1 downto 0 );
  process_rout: out t_reads( numInputsME  - 1 downto 0 );
  process_dout: out t_writes( numOutputsME  - 1 downto 0 )
);
end;

architecture rtl of ME_process is

begin

g: for k in 0 to numME - 1 generate

constant offsetIn: natural := sum( 0 & numNodeInputsME, 0, k );
constant offsetOut: natural := sum( 0 & numNodeOutputsME, 0, k );
constant numInputs: natural := numNodeInputsME( k );
constant numOutputs: natural := numNodeOutputsME( k );
constant config_memories_out: t_config_memories( 0 to numOutputs - 1 ) := config_memories_out( sumMemOutPR + offsetOut to sumMemOutPR + offsetOut + numOutputs - 1 );
constant config_memories_in: t_config_memories( 0 to numInputs - 1 ) := config_memories_in( sumMemInPR + offsetIn to sumMemInPR + offsetIn + numInputs - 1 );

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

start <= process_din( offsetIn + 1 ).start;
bxIn <= process_din( offsetIn + 1 ).bx;

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

gL3: if k < 8 generate
L3: entity work.ME_L3 port map (
  ap_clk => clk,
  ap_rst => '0',
  ap_start => start,
  bx_V => bxIn,
  bx_o_V => bxOut,
  ap_done => done,
  ap_idle => open,
  ap_ready => open,
  bx_o_V_ap_vld => open,
  inputStubData_dataarray_data_V_ce0 => rout( 0 ).valid,
  inputProjectionData_dataarray_data_V_ce0 => rout( 1 ).valid,
  inputStubData_dataarray_data_V_address0 => rout( 0 ).addr( config_memories_in( 0 ).widthAddr - 1 downto 0 ),
  inputProjectionData_dataarray_data_V_address0 => rout( 1 ).addr( config_memories_in( 1 ).widthAddr - 1 downto 0 ),
  inputStubData_dataarray_data_V_q0 => din( 0 ).data( config_memories_in( 0 ).widthData - 1 downto 0 ),
  inputProjectionData_dataarray_data_V_q0 => din( 1 ).data( config_memories_in( 1 ).widthData - 1 downto 0 ),
  inputStubData_nentries_0_V_0 => din( 0 ).nents(  0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_0_V_1 => din( 0 ).nents(  1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_0_V_2 => din( 0 ).nents(  2 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_0_V_3 => din( 0 ).nents(  3 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_0_V_4 => din( 0 ).nents(  4 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_0_V_5 => din( 0 ).nents(  5 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_0_V_6 => din( 0 ).nents(  6 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_0_V_7 => din( 0 ).nents(  7 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_1_V_0 => din( 0 ).nents(  8 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_1_V_1 => din( 0 ).nents(  9 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_1_V_2 => din( 0 ).nents( 10 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_1_V_3 => din( 0 ).nents( 11 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_1_V_4 => din( 0 ).nents( 12 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_1_V_5 => din( 0 ).nents( 13 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_1_V_6 => din( 0 ).nents( 14 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_1_V_7 => din( 0 ).nents( 15 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_2_V_0 => din( 0 ).nents( 16 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_2_V_1 => din( 0 ).nents( 17 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_2_V_2 => din( 0 ).nents( 18 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_2_V_3 => din( 0 ).nents( 19 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_2_V_4 => din( 0 ).nents( 20 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_2_V_5 => din( 0 ).nents( 21 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_2_V_6 => din( 0 ).nents( 22 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_2_V_7 => din( 0 ).nents( 23 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_3_V_0 => din( 0 ).nents( 24 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_3_V_1 => din( 0 ).nents( 25 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_3_V_2 => din( 0 ).nents( 26 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_3_V_3 => din( 0 ).nents( 27 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_3_V_4 => din( 0 ).nents( 28 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_3_V_5 => din( 0 ).nents( 29 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_3_V_6 => din( 0 ).nents( 30 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_3_V_7 => din( 0 ).nents( 31 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_4_V_0 => din( 0 ).nents( 32 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_4_V_1 => din( 0 ).nents( 33 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_4_V_2 => din( 0 ).nents( 34 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_4_V_3 => din( 0 ).nents( 35 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_4_V_4 => din( 0 ).nents( 36 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_4_V_5 => din( 0 ).nents( 37 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_4_V_6 => din( 0 ).nents( 38 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_4_V_7 => din( 0 ).nents( 39 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_5_V_0 => din( 0 ).nents( 40 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_5_V_1 => din( 0 ).nents( 41 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_5_V_2 => din( 0 ).nents( 42 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_5_V_3 => din( 0 ).nents( 43 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_5_V_4 => din( 0 ).nents( 44 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_5_V_5 => din( 0 ).nents( 45 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_5_V_6 => din( 0 ).nents( 46 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_5_V_7 => din( 0 ).nents( 47 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_6_V_0 => din( 0 ).nents( 48 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_6_V_1 => din( 0 ).nents( 49 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_6_V_2 => din( 0 ).nents( 50 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_6_V_3 => din( 0 ).nents( 51 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_6_V_4 => din( 0 ).nents( 52 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_6_V_5 => din( 0 ).nents( 53 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_6_V_6 => din( 0 ).nents( 54 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_6_V_7 => din( 0 ).nents( 55 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_7_V_0 => din( 0 ).nents( 56 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_7_V_1 => din( 0 ).nents( 57 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_7_V_2 => din( 0 ).nents( 58 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_7_V_3 => din( 0 ).nents( 59 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_7_V_4 => din( 0 ).nents( 60 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_7_V_5 => din( 0 ).nents( 61 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_7_V_6 => din( 0 ).nents( 62 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_7_V_7 => din( 0 ).nents( 63 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputProjectionData_nentries_0_V => din( 1 ).nents( 0 )( config_memories_in( 1 ).widthNent - 1 downto 0 ),
  inputProjectionData_nentries_1_V => din( 1 ).nents( 1 )( config_memories_in( 1 ).widthNent - 1 downto 0 ),
  outputCandidateMatch_dataarray_data_V_ce0 => open,
  outputCandidateMatch_dataarray_data_V_we0 => writes( 0 ).valid,
  outputCandidateMatch_dataarray_data_V_address0 => writes( 0 ).addr( config_memories_out( 0 ).widthAddr - 1 downto 0 ),
  outputCandidateMatch_dataarray_data_V_d0 => writes( 0 ).data( config_memories_out( 0 ).widthData - 1 downto 0 )
);
end generate;
gL4: if k >= 8 and k < 16 generate
L4: entity work.ME_L4 port map (
  ap_clk => clk,
  ap_rst => '0',
  ap_start => start,
  bx_V => bxIn,
  bx_o_V => bxOut,
  ap_done => done,
  ap_idle => open,
  ap_ready => open,
  bx_o_V_ap_vld => open,
  inputStubData_dataarray_data_V_ce0 => rout( 0 ).valid,
  inputProjectionData_dataarray_data_V_ce0 => rout( 1 ).valid,
  inputStubData_dataarray_data_V_address0 => rout( 0 ).addr( config_memories_in( 0 ).widthAddr - 1 downto 0 ),
  inputProjectionData_dataarray_data_V_address0 => rout( 1 ).addr( config_memories_in( 1 ).widthAddr - 1 downto 0 ),
  inputStubData_dataarray_data_V_q0 => din( 0 ).data( config_memories_in( 0 ).widthData - 1 downto 0 ),
  inputProjectionData_dataarray_data_V_q0 => din( 1 ).data( config_memories_in( 1 ).widthData - 1 downto 0 ),
  inputStubData_nentries_0_V_0 => din( 0 ).nents(  0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_0_V_1 => din( 0 ).nents(  1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_0_V_2 => din( 0 ).nents(  2 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_0_V_3 => din( 0 ).nents(  3 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_0_V_4 => din( 0 ).nents(  4 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_0_V_5 => din( 0 ).nents(  5 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_0_V_6 => din( 0 ).nents(  6 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_0_V_7 => din( 0 ).nents(  7 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_1_V_0 => din( 0 ).nents(  8 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_1_V_1 => din( 0 ).nents(  9 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_1_V_2 => din( 0 ).nents( 10 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_1_V_3 => din( 0 ).nents( 11 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_1_V_4 => din( 0 ).nents( 12 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_1_V_5 => din( 0 ).nents( 13 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_1_V_6 => din( 0 ).nents( 14 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_1_V_7 => din( 0 ).nents( 15 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_2_V_0 => din( 0 ).nents( 16 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_2_V_1 => din( 0 ).nents( 17 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_2_V_2 => din( 0 ).nents( 18 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_2_V_3 => din( 0 ).nents( 19 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_2_V_4 => din( 0 ).nents( 20 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_2_V_5 => din( 0 ).nents( 21 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_2_V_6 => din( 0 ).nents( 22 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_2_V_7 => din( 0 ).nents( 23 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_3_V_0 => din( 0 ).nents( 24 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_3_V_1 => din( 0 ).nents( 25 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_3_V_2 => din( 0 ).nents( 26 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_3_V_3 => din( 0 ).nents( 27 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_3_V_4 => din( 0 ).nents( 28 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_3_V_5 => din( 0 ).nents( 29 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_3_V_6 => din( 0 ).nents( 30 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_3_V_7 => din( 0 ).nents( 31 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_4_V_0 => din( 0 ).nents( 32 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_4_V_1 => din( 0 ).nents( 33 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_4_V_2 => din( 0 ).nents( 34 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_4_V_3 => din( 0 ).nents( 35 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_4_V_4 => din( 0 ).nents( 36 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_4_V_5 => din( 0 ).nents( 37 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_4_V_6 => din( 0 ).nents( 38 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_4_V_7 => din( 0 ).nents( 39 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_5_V_0 => din( 0 ).nents( 40 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_5_V_1 => din( 0 ).nents( 41 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_5_V_2 => din( 0 ).nents( 42 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_5_V_3 => din( 0 ).nents( 43 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_5_V_4 => din( 0 ).nents( 44 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_5_V_5 => din( 0 ).nents( 45 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_5_V_6 => din( 0 ).nents( 46 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_5_V_7 => din( 0 ).nents( 47 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_6_V_0 => din( 0 ).nents( 48 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_6_V_1 => din( 0 ).nents( 49 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_6_V_2 => din( 0 ).nents( 50 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_6_V_3 => din( 0 ).nents( 51 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_6_V_4 => din( 0 ).nents( 52 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_6_V_5 => din( 0 ).nents( 53 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_6_V_6 => din( 0 ).nents( 54 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_6_V_7 => din( 0 ).nents( 55 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_7_V_0 => din( 0 ).nents( 56 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_7_V_1 => din( 0 ).nents( 57 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_7_V_2 => din( 0 ).nents( 58 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_7_V_3 => din( 0 ).nents( 59 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_7_V_4 => din( 0 ).nents( 60 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_7_V_5 => din( 0 ).nents( 61 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_7_V_6 => din( 0 ).nents( 62 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_7_V_7 => din( 0 ).nents( 63 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputProjectionData_nentries_0_V => din( 1 ).nents( 0 )( config_memories_in( 1 ).widthNent - 1 downto 0 ),
  inputProjectionData_nentries_1_V => din( 1 ).nents( 1 )( config_memories_in( 1 ).widthNent - 1 downto 0 ),
  outputCandidateMatch_dataarray_data_V_ce0 => open,
  outputCandidateMatch_dataarray_data_V_we0 => writes( 0 ).valid,
  outputCandidateMatch_dataarray_data_V_address0 => writes( 0 ).addr( config_memories_out( 0 ).widthAddr - 1 downto 0 ),
  outputCandidateMatch_dataarray_data_V_d0 => writes( 0 ).data( config_memories_out( 0 ).widthData - 1 downto 0 )
);
end generate;
gL5: if k >= 16 and k < 24 generate
L5: entity work.ME_L5 port map (
  ap_clk => clk,
  ap_rst => '0',
  ap_start => start,
  bx_V => bxIn,
  bx_o_V => bxOut,
  ap_done => done,
  ap_idle => open,
  ap_ready => open,
  bx_o_V_ap_vld => open,
  inputStubData_dataarray_data_V_ce0 => rout( 0 ).valid,
  inputProjectionData_dataarray_data_V_ce0 => rout( 1 ).valid,
  inputStubData_dataarray_data_V_address0 => rout( 0 ).addr( config_memories_in( 0 ).widthAddr - 1 downto 0 ),
  inputProjectionData_dataarray_data_V_address0 => rout( 1 ).addr( config_memories_in( 1 ).widthAddr - 1 downto 0 ),
  inputStubData_dataarray_data_V_q0 => din( 0 ).data( config_memories_in( 0 ).widthData - 1 downto 0 ),
  inputProjectionData_dataarray_data_V_q0 => din( 1 ).data( config_memories_in( 1 ).widthData - 1 downto 0 ),
  inputStubData_nentries_0_V_0 => din( 0 ).nents(  0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_0_V_1 => din( 0 ).nents(  1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_0_V_2 => din( 0 ).nents(  2 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_0_V_3 => din( 0 ).nents(  3 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_0_V_4 => din( 0 ).nents(  4 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_0_V_5 => din( 0 ).nents(  5 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_0_V_6 => din( 0 ).nents(  6 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_0_V_7 => din( 0 ).nents(  7 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_1_V_0 => din( 0 ).nents(  8 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_1_V_1 => din( 0 ).nents(  9 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_1_V_2 => din( 0 ).nents( 10 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_1_V_3 => din( 0 ).nents( 11 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_1_V_4 => din( 0 ).nents( 12 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_1_V_5 => din( 0 ).nents( 13 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_1_V_6 => din( 0 ).nents( 14 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_1_V_7 => din( 0 ).nents( 15 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_2_V_0 => din( 0 ).nents( 16 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_2_V_1 => din( 0 ).nents( 17 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_2_V_2 => din( 0 ).nents( 18 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_2_V_3 => din( 0 ).nents( 19 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_2_V_4 => din( 0 ).nents( 20 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_2_V_5 => din( 0 ).nents( 21 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_2_V_6 => din( 0 ).nents( 22 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_2_V_7 => din( 0 ).nents( 23 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_3_V_0 => din( 0 ).nents( 24 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_3_V_1 => din( 0 ).nents( 25 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_3_V_2 => din( 0 ).nents( 26 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_3_V_3 => din( 0 ).nents( 27 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_3_V_4 => din( 0 ).nents( 28 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_3_V_5 => din( 0 ).nents( 29 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_3_V_6 => din( 0 ).nents( 30 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_3_V_7 => din( 0 ).nents( 31 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_4_V_0 => din( 0 ).nents( 32 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_4_V_1 => din( 0 ).nents( 33 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_4_V_2 => din( 0 ).nents( 34 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_4_V_3 => din( 0 ).nents( 35 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_4_V_4 => din( 0 ).nents( 36 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_4_V_5 => din( 0 ).nents( 37 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_4_V_6 => din( 0 ).nents( 38 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_4_V_7 => din( 0 ).nents( 39 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_5_V_0 => din( 0 ).nents( 40 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_5_V_1 => din( 0 ).nents( 41 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_5_V_2 => din( 0 ).nents( 42 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_5_V_3 => din( 0 ).nents( 43 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_5_V_4 => din( 0 ).nents( 44 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_5_V_5 => din( 0 ).nents( 45 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_5_V_6 => din( 0 ).nents( 46 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_5_V_7 => din( 0 ).nents( 47 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_6_V_0 => din( 0 ).nents( 48 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_6_V_1 => din( 0 ).nents( 49 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_6_V_2 => din( 0 ).nents( 50 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_6_V_3 => din( 0 ).nents( 51 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_6_V_4 => din( 0 ).nents( 52 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_6_V_5 => din( 0 ).nents( 53 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_6_V_6 => din( 0 ).nents( 54 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_6_V_7 => din( 0 ).nents( 55 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_7_V_0 => din( 0 ).nents( 56 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_7_V_1 => din( 0 ).nents( 57 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_7_V_2 => din( 0 ).nents( 58 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_7_V_3 => din( 0 ).nents( 59 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_7_V_4 => din( 0 ).nents( 60 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_7_V_5 => din( 0 ).nents( 61 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_7_V_6 => din( 0 ).nents( 62 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_7_V_7 => din( 0 ).nents( 63 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputProjectionData_nentries_0_V => din( 1 ).nents( 0 )( config_memories_in( 1 ).widthNent - 1 downto 0 ),
  inputProjectionData_nentries_1_V => din( 1 ).nents( 1 )( config_memories_in( 1 ).widthNent - 1 downto 0 ),
  outputCandidateMatch_dataarray_data_V_ce0 => open,
  outputCandidateMatch_dataarray_data_V_we0 => writes( 0 ).valid,
  outputCandidateMatch_dataarray_data_V_address0 => writes( 0 ).addr( config_memories_out( 0 ).widthAddr - 1 downto 0 ),
  outputCandidateMatch_dataarray_data_V_d0 => writes( 0 ).data( config_memories_out( 0 ).widthData - 1 downto 0 )
);
end generate;
gL6: if k >= 24 generate
L6: entity work.ME_L6 port map (
  ap_clk => clk,
  ap_rst => '0',
  ap_start => start,
  bx_V => bxIn,
  bx_o_V => bxOut,
  ap_done => done,
  ap_idle => open,
  ap_ready => open,
  bx_o_V_ap_vld => open,
  inputStubData_dataarray_data_V_ce0 => rout( 0 ).valid,
  inputProjectionData_dataarray_data_V_ce0 => rout( 1 ).valid,
  inputStubData_dataarray_data_V_address0 => rout( 0 ).addr( config_memories_in( 0 ).widthAddr - 1 downto 0 ),
  inputProjectionData_dataarray_data_V_address0 => rout( 1 ).addr( config_memories_in( 1 ).widthAddr - 1 downto 0 ),
  inputStubData_dataarray_data_V_q0 => din( 0 ).data( config_memories_in( 0 ).widthData - 1 downto 0 ),
  inputProjectionData_dataarray_data_V_q0 => din( 1 ).data( config_memories_in( 1 ).widthData - 1 downto 0 ),
  inputStubData_nentries_0_V_0 => din( 0 ).nents(  0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_0_V_1 => din( 0 ).nents(  1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_0_V_2 => din( 0 ).nents(  2 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_0_V_3 => din( 0 ).nents(  3 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_0_V_4 => din( 0 ).nents(  4 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_0_V_5 => din( 0 ).nents(  5 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_0_V_6 => din( 0 ).nents(  6 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_0_V_7 => din( 0 ).nents(  7 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_1_V_0 => din( 0 ).nents(  8 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_1_V_1 => din( 0 ).nents(  9 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_1_V_2 => din( 0 ).nents( 10 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_1_V_3 => din( 0 ).nents( 11 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_1_V_4 => din( 0 ).nents( 12 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_1_V_5 => din( 0 ).nents( 13 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_1_V_6 => din( 0 ).nents( 14 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_1_V_7 => din( 0 ).nents( 15 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_2_V_0 => din( 0 ).nents( 16 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_2_V_1 => din( 0 ).nents( 17 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_2_V_2 => din( 0 ).nents( 18 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_2_V_3 => din( 0 ).nents( 19 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_2_V_4 => din( 0 ).nents( 20 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_2_V_5 => din( 0 ).nents( 21 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_2_V_6 => din( 0 ).nents( 22 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_2_V_7 => din( 0 ).nents( 23 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_3_V_0 => din( 0 ).nents( 24 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_3_V_1 => din( 0 ).nents( 25 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_3_V_2 => din( 0 ).nents( 26 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_3_V_3 => din( 0 ).nents( 27 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_3_V_4 => din( 0 ).nents( 28 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_3_V_5 => din( 0 ).nents( 29 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_3_V_6 => din( 0 ).nents( 30 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_3_V_7 => din( 0 ).nents( 31 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_4_V_0 => din( 0 ).nents( 32 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_4_V_1 => din( 0 ).nents( 33 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_4_V_2 => din( 0 ).nents( 34 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_4_V_3 => din( 0 ).nents( 35 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_4_V_4 => din( 0 ).nents( 36 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_4_V_5 => din( 0 ).nents( 37 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_4_V_6 => din( 0 ).nents( 38 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_4_V_7 => din( 0 ).nents( 39 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_5_V_0 => din( 0 ).nents( 40 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_5_V_1 => din( 0 ).nents( 41 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_5_V_2 => din( 0 ).nents( 42 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_5_V_3 => din( 0 ).nents( 43 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_5_V_4 => din( 0 ).nents( 44 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_5_V_5 => din( 0 ).nents( 45 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_5_V_6 => din( 0 ).nents( 46 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_5_V_7 => din( 0 ).nents( 47 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_6_V_0 => din( 0 ).nents( 48 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_6_V_1 => din( 0 ).nents( 49 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_6_V_2 => din( 0 ).nents( 50 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_6_V_3 => din( 0 ).nents( 51 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_6_V_4 => din( 0 ).nents( 52 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_6_V_5 => din( 0 ).nents( 53 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_6_V_6 => din( 0 ).nents( 54 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_6_V_7 => din( 0 ).nents( 55 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_7_V_0 => din( 0 ).nents( 56 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_7_V_1 => din( 0 ).nents( 57 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_7_V_2 => din( 0 ).nents( 58 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_7_V_3 => din( 0 ).nents( 59 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_7_V_4 => din( 0 ).nents( 60 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_7_V_5 => din( 0 ).nents( 61 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_7_V_6 => din( 0 ).nents( 62 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubData_nentries_7_V_7 => din( 0 ).nents( 63 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputProjectionData_nentries_0_V => din( 1 ).nents( 0 )( config_memories_in( 1 ).widthNent - 1 downto 0 ),
  inputProjectionData_nentries_1_V => din( 1 ).nents( 1 )( config_memories_in( 1 ).widthNent - 1 downto 0 ),
  outputCandidateMatch_dataarray_data_V_ce0 => open,
  outputCandidateMatch_dataarray_data_V_we0 => writes( 0 ).valid,
  outputCandidateMatch_dataarray_data_V_address0 => writes( 0 ).addr( config_memories_out( 0 ).widthAddr - 1 downto 0 ),
  outputCandidateMatch_dataarray_data_V_d0 => writes( 0 ).data( config_memories_out( 0 ).widthData - 1 downto 0 )
);
end generate;

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.tracklet_config.all;
use work.tracklet_data_types.all;

entity ME_memories is
port (
  clk: in std_logic;
  memories_din: in t_writes( numOutputsME  - 1 downto 0 );
  memories_rin: in t_reads( numOutputsME  - 1 downto 0 );
  memories_dout: out t_datas( numOutputsME  - 1 downto 0 )
);
end;

architecture rtl of ME_memories is

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

g: for k in 0 to numOutputsME - 1 generate

signal memory_din: t_write := nulll;
signal memory_read: t_read := nulll;
signal memory_dout: t_data := nulll;

begin

memory_din <= memories_din( k );
memory_read <= memories_rin( k );
memories_dout( k ) <= memory_dout;

c: tracklet_memory generic map ( sumMemOutPR + k ) port map ( clk, memory_din, memory_read, memory_dout );

end generate;

end;