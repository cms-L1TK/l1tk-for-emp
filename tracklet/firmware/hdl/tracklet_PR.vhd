library ieee;
use ieee.std_logic_1164.all;
use work.tracklet_config.all;
use work.tracklet_data_types.all;

entity tracklet_PR is
port (
  clk: in std_logic;
  pr_din: in t_datas( numInputsPR  - 1 downto 0 );
  pr_rin: in t_reads( numOutputsPR  - 1 downto 0 );
  pr_rout: out t_reads( numInputsPR  - 1 downto 0 );
  pr_dout: out t_datas( numOutputsPR  - 1 downto 0 )
);
end;

architecture rtl of tracklet_PR is

signal process_din: t_datas( numInputsPR  - 1 downto 0 ) := ( others => nulll );
signal process_rout: t_reads( numInputsPR  - 1 downto 0 ) := ( others => nulll );
signal process_dout: t_writes( numOutputsPR  - 1 downto 0 ) := ( others => nulll );
component PR_process
port (
  clk: in std_logic;
  process_din: in t_datas( numInputsPR  - 1 downto 0 );
  process_rout: out t_reads( numInputsPR  - 1 downto 0 );
  process_dout: out t_writes( numOutputsPR  - 1 downto 0 )
);
end component;

signal memories_din: t_writes( numOutputsPR  - 1 downto 0 ) := ( others => nulll );
signal memories_rin: t_reads( numOutputsPR  - 1 downto 0 ) := ( others => nulll );
signal memories_dout: t_datas( numOutputsPR  - 1 downto 0 ) := ( others => nulll );
component PR_memories
port (
  clk: in std_logic;
  memories_din: in t_writes( numOutputsPR  - 1 downto 0 );
  memories_rin: in t_reads( numOutputsPR  - 1 downto 0 );
  memories_dout: out t_datas( numOutputsPR  - 1 downto 0 )
);
end component;

begin

process_din <= pr_din;
memories_din <= process_dout;
memories_rin <= pr_rin;

pr_rout <= process_rout;
pr_dout <= memories_dout;

cP: PR_process port map ( clk, process_din, process_rout, process_dout );

cM: PR_memories port map ( clk, memories_din, memories_rin, memories_dout );

end;


library xil_defaultlib;
library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.tracklet_config.all;
use work.tracklet_config_memory.all;
use work.tracklet_data_types.all;

entity PR_process is
port (
  clk: in std_logic;
  process_din: in t_datas( numInputsPR  - 1 downto 0 );
  process_rout: out t_reads( numInputsPR  - 1 downto 0 );
  process_dout: out t_writes( numOutputsPR  - 1 downto 0 )
);
end;

architecture rtl of PR_process is

begin

g: for k in 0 to numPR - 1 generate

constant offsetIn: natural := sum( 0 & numNodeInputsPR, 0, k );
constant offsetOut: natural := sum( 0 & numNodeOutputsPR, 0, k );
constant numInputs: natural := numNodeInputsPR( k );
constant numOutputs: natural := numNodeOutputsPR( k );
constant config_memories_out: t_config_memories( 0 to numOutputs - 1 ) := config_memories_out( sumMemOutTC + offsetOut to sumMemOutTC + offsetOut + numOutputs - 1 );
constant config_memories_in: t_config_memories( 0 to numInputs - 1 ) := config_memories_in( sumMemInTC + offsetIn to sumMemInTC + offsetIn + numInputs - 1 );

signal din: t_datas( numInputs  - 1 downto 0 ) := ( others => nulll );
signal rout: t_reads( numInputs  - 1 downto 0 ) := ( others => nulll );

signal reset, start, done, enable: std_logic := '0';
signal counter: std_logic_vector( widthNent - 1 downto 0 ) := ( others => '0' );
signal bxIn, bxOut: std_logic_vector ( widthBX - 1 downto 0 ) := ( others => '0' );
signal writes: t_writes( numOutputs - 1 downto 0 ) := ( others => nulll );

begin

din <= process_din( offsetIn + numInputs - 1 downto offsetIn );
process_rout( offsetIn + numInputs - 1 downto offsetIn ) <= rout;
process_dout( offsetOut + numOutputs - 1 downto offsetOut ) <= writes;

start <= process_din( offsetIn ).start;
bxIn <= process_din( offsetIn ).bx;

process ( clk ) is
begin
if rising_edge( clk ) then

  reset <= process_din( offsetIn ).reset;
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

gIn: for l in 0 to numInputs - 1 generate
rout( l ).start <= start;
end generate;

gOut: for l in 0 to numOutputs - 1 generate
writes( l ).reset <= reset;
writes( l ).start <= done or enable;
writes( l ).bx <= bxOut;
end generate;

g0: if k = 0 generate
L3PHIB: entity xil_defaultlib.PR_L3PHIB port map (
  ap_clk => clk,
  ap_rst => reset,
  ap_start => start,
  ap_done => done,
  bx_V => bxIn,
  bx_o_V => bxOut,
  ap_idle => open,
  ap_ready => open,
  bx_o_V_ap_vld => open,
  projin_0_dataarray_data_V_ce0 => rout( 0 ).valid,
  projin_0_dataarray_data_V_address0 => rout( 0 ).addr( config_memories_in( 0 ).widthAddr - 1 downto 0 ),
  projin_0_dataarray_data_V_q0 => din( 0 ).data( config_memories_in( 0 ).widthData - 1 downto 0 ),
  projin_0_nentries_0_V => din( 0 ).nents( 0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  projin_0_nentries_1_V => din( 0 ).nents( 1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  allprojout_dataarray_data_V_ce0 => open,
  vmprojout_0_dataarray_data_V_ce0 => open,
  vmprojout_1_dataarray_data_V_ce0 => open,
  vmprojout_2_dataarray_data_V_ce0 => open,
  vmprojout_3_dataarray_data_V_ce0 => open,
  vmprojout_4_dataarray_data_V_ce0 => open,
  vmprojout_5_dataarray_data_V_ce0 => open,
  vmprojout_6_dataarray_data_V_ce0 => open,
  vmprojout_7_dataarray_data_V_ce0 => open,
  allprojout_dataarray_data_V_we0 => writes( 8 ).valid,
  vmprojout_0_dataarray_data_V_we0 => writes( 0 ).valid,
  vmprojout_1_dataarray_data_V_we0 => writes( 1 ).valid,
  vmprojout_2_dataarray_data_V_we0 => writes( 2 ).valid,
  vmprojout_3_dataarray_data_V_we0 => writes( 3 ).valid,
  vmprojout_4_dataarray_data_V_we0 => writes( 4 ).valid,
  vmprojout_5_dataarray_data_V_we0 => writes( 5 ).valid,
  vmprojout_6_dataarray_data_V_we0 => writes( 6 ).valid,
  vmprojout_7_dataarray_data_V_we0 => writes( 7 ).valid,
  allprojout_dataarray_data_V_address0 => writes( 8 ).addr( config_memories_out( 8 ).widthAddr - 1 downto 0 ),
  vmprojout_0_dataarray_data_V_address0 => writes( 0 ).addr( config_memories_out( 0 ).widthAddr - 1 downto 0 ),
  vmprojout_1_dataarray_data_V_address0 => writes( 1 ).addr( config_memories_out( 1 ).widthAddr - 1 downto 0 ),
  vmprojout_2_dataarray_data_V_address0 => writes( 2 ).addr( config_memories_out( 2 ).widthAddr - 1 downto 0 ),
  vmprojout_3_dataarray_data_V_address0 => writes( 3 ).addr( config_memories_out( 3 ).widthAddr - 1 downto 0 ),
  vmprojout_4_dataarray_data_V_address0 => writes( 4 ).addr( config_memories_out( 4 ).widthAddr - 1 downto 0 ),
  vmprojout_5_dataarray_data_V_address0 => writes( 5 ).addr( config_memories_out( 5 ).widthAddr - 1 downto 0 ),
  vmprojout_6_dataarray_data_V_address0 => writes( 6 ).addr( config_memories_out( 6 ).widthAddr - 1 downto 0 ),
  vmprojout_7_dataarray_data_V_address0 => writes( 7 ).addr( config_memories_out( 7 ).widthAddr - 1 downto 0 ),
  allprojout_dataarray_data_V_d0 => writes( 8 ).data( config_memories_out( 8 ).widthData - 1 downto 0 ),
  vmprojout_0_dataarray_data_V_d0 => writes( 0 ).data( config_memories_out( 0 ).widthData - 1 downto 0 ),
  vmprojout_1_dataarray_data_V_d0 => writes( 1 ).data( config_memories_out( 1 ).widthData - 1 downto 0 ),
  vmprojout_2_dataarray_data_V_d0 => writes( 2 ).data( config_memories_out( 2 ).widthData - 1 downto 0 ),
  vmprojout_3_dataarray_data_V_d0 => writes( 3 ).data( config_memories_out( 3 ).widthData - 1 downto 0 ),
  vmprojout_4_dataarray_data_V_d0 => writes( 4 ).data( config_memories_out( 4 ).widthData - 1 downto 0 ),
  vmprojout_5_dataarray_data_V_d0 => writes( 5 ).data( config_memories_out( 5 ).widthData - 1 downto 0 ),
  vmprojout_6_dataarray_data_V_d0 => writes( 6 ).data( config_memories_out( 6 ).widthData - 1 downto 0 ),
  vmprojout_7_dataarray_data_V_d0 => writes( 7 ).data( config_memories_out( 7 ).widthData - 1 downto 0 )
);
end generate;
g1: if k = 1 generate
L4PHIB: entity xil_defaultlib.PR_L4PHIB port map (
  ap_clk => clk,
  ap_rst => reset,
  ap_start => start,
  ap_done => done,
  bx_V => bxIn,
  bx_o_V => bxOut,
  ap_idle => open,
  ap_ready => open,
  bx_o_V_ap_vld => open,
  projin_0_dataarray_data_V_ce0 => rout( 0 ).valid,
  projin_0_dataarray_data_V_address0 => rout( 0 ).addr( config_memories_in( 0 ).widthAddr - 1 downto 0 ),
  projin_0_dataarray_data_V_q0 => din( 0 ).data( config_memories_in( 0 ).widthData - 1 downto 0 ),
  projin_0_nentries_0_V => din( 0 ).nents( 0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  projin_0_nentries_1_V => din( 0 ).nents( 1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  allprojout_dataarray_data_V_ce0 => open,
  vmprojout_0_dataarray_data_V_ce0 => open,
  vmprojout_1_dataarray_data_V_ce0 => open,
  vmprojout_2_dataarray_data_V_ce0 => open,
  vmprojout_3_dataarray_data_V_ce0 => open,
  vmprojout_4_dataarray_data_V_ce0 => open,
  vmprojout_5_dataarray_data_V_ce0 => open,
  vmprojout_6_dataarray_data_V_ce0 => open,
  vmprojout_7_dataarray_data_V_ce0 => open,
  allprojout_dataarray_data_V_we0 => writes( 8 ).valid,
  vmprojout_0_dataarray_data_V_we0 => writes( 0 ).valid,
  vmprojout_1_dataarray_data_V_we0 => writes( 1 ).valid,
  vmprojout_2_dataarray_data_V_we0 => writes( 2 ).valid,
  vmprojout_3_dataarray_data_V_we0 => writes( 3 ).valid,
  vmprojout_4_dataarray_data_V_we0 => writes( 4 ).valid,
  vmprojout_5_dataarray_data_V_we0 => writes( 5 ).valid,
  vmprojout_6_dataarray_data_V_we0 => writes( 6 ).valid,
  vmprojout_7_dataarray_data_V_we0 => writes( 7 ).valid,
  allprojout_dataarray_data_V_address0 => writes( 8 ).addr( config_memories_out( 8 ).widthAddr - 1 downto 0 ),
  vmprojout_0_dataarray_data_V_address0 => writes( 0 ).addr( config_memories_out( 0 ).widthAddr - 1 downto 0 ),
  vmprojout_1_dataarray_data_V_address0 => writes( 1 ).addr( config_memories_out( 1 ).widthAddr - 1 downto 0 ),
  vmprojout_2_dataarray_data_V_address0 => writes( 2 ).addr( config_memories_out( 2 ).widthAddr - 1 downto 0 ),
  vmprojout_3_dataarray_data_V_address0 => writes( 3 ).addr( config_memories_out( 3 ).widthAddr - 1 downto 0 ),
  vmprojout_4_dataarray_data_V_address0 => writes( 4 ).addr( config_memories_out( 4 ).widthAddr - 1 downto 0 ),
  vmprojout_5_dataarray_data_V_address0 => writes( 5 ).addr( config_memories_out( 5 ).widthAddr - 1 downto 0 ),
  vmprojout_6_dataarray_data_V_address0 => writes( 6 ).addr( config_memories_out( 6 ).widthAddr - 1 downto 0 ),
  vmprojout_7_dataarray_data_V_address0 => writes( 7 ).addr( config_memories_out( 7 ).widthAddr - 1 downto 0 ),
  allprojout_dataarray_data_V_d0 => writes( 8 ).data( config_memories_out( 8 ).widthData - 1 downto 0 ),
  vmprojout_0_dataarray_data_V_d0 => writes( 0 ).data( config_memories_out( 0 ).widthData - 1 downto 0 ),
  vmprojout_1_dataarray_data_V_d0 => writes( 1 ).data( config_memories_out( 1 ).widthData - 1 downto 0 ),
  vmprojout_2_dataarray_data_V_d0 => writes( 2 ).data( config_memories_out( 2 ).widthData - 1 downto 0 ),
  vmprojout_3_dataarray_data_V_d0 => writes( 3 ).data( config_memories_out( 3 ).widthData - 1 downto 0 ),
  vmprojout_4_dataarray_data_V_d0 => writes( 4 ).data( config_memories_out( 4 ).widthData - 1 downto 0 ),
  vmprojout_5_dataarray_data_V_d0 => writes( 5 ).data( config_memories_out( 5 ).widthData - 1 downto 0 ),
  vmprojout_6_dataarray_data_V_d0 => writes( 6 ).data( config_memories_out( 6 ).widthData - 1 downto 0 ),
  vmprojout_7_dataarray_data_V_d0 => writes( 7 ).data( config_memories_out( 7 ).widthData - 1 downto 0 )
);
end generate;
g2: if k = 2 generate
L5PHIB: entity xil_defaultlib.PR_L5PHIB port map (
  ap_clk => clk,
  ap_rst => reset,
  ap_start => start,
  ap_done => done,
  bx_V => bxIn,
  bx_o_V => bxOut,
  ap_idle => open,
  ap_ready => open,
  bx_o_V_ap_vld => open,
  projin_0_dataarray_data_V_ce0 => rout( 0 ).valid,
  projin_0_dataarray_data_V_address0 => rout( 0 ).addr( config_memories_in( 0 ).widthAddr - 1 downto 0 ),
  projin_0_dataarray_data_V_q0 => din( 0 ).data( config_memories_in( 0 ).widthData - 1 downto 0 ),
  projin_0_nentries_0_V => din( 0 ).nents( 0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  projin_0_nentries_1_V => din( 0 ).nents( 1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  allprojout_dataarray_data_V_ce0 => open,
  vmprojout_0_dataarray_data_V_ce0 => open,
  vmprojout_1_dataarray_data_V_ce0 => open,
  vmprojout_2_dataarray_data_V_ce0 => open,
  vmprojout_3_dataarray_data_V_ce0 => open,
  vmprojout_4_dataarray_data_V_ce0 => open,
  vmprojout_5_dataarray_data_V_ce0 => open,
  vmprojout_6_dataarray_data_V_ce0 => open,
  vmprojout_7_dataarray_data_V_ce0 => open,
  allprojout_dataarray_data_V_we0 => writes( 8 ).valid,
  vmprojout_0_dataarray_data_V_we0 => writes( 0 ).valid,
  vmprojout_1_dataarray_data_V_we0 => writes( 1 ).valid,
  vmprojout_2_dataarray_data_V_we0 => writes( 2 ).valid,
  vmprojout_3_dataarray_data_V_we0 => writes( 3 ).valid,
  vmprojout_4_dataarray_data_V_we0 => writes( 4 ).valid,
  vmprojout_5_dataarray_data_V_we0 => writes( 5 ).valid,
  vmprojout_6_dataarray_data_V_we0 => writes( 6 ).valid,
  vmprojout_7_dataarray_data_V_we0 => writes( 7 ).valid,
  allprojout_dataarray_data_V_address0 => writes( 8 ).addr( config_memories_out( 8 ).widthAddr - 1 downto 0 ),
  vmprojout_0_dataarray_data_V_address0 => writes( 0 ).addr( config_memories_out( 0 ).widthAddr - 1 downto 0 ),
  vmprojout_1_dataarray_data_V_address0 => writes( 1 ).addr( config_memories_out( 1 ).widthAddr - 1 downto 0 ),
  vmprojout_2_dataarray_data_V_address0 => writes( 2 ).addr( config_memories_out( 2 ).widthAddr - 1 downto 0 ),
  vmprojout_3_dataarray_data_V_address0 => writes( 3 ).addr( config_memories_out( 3 ).widthAddr - 1 downto 0 ),
  vmprojout_4_dataarray_data_V_address0 => writes( 4 ).addr( config_memories_out( 4 ).widthAddr - 1 downto 0 ),
  vmprojout_5_dataarray_data_V_address0 => writes( 5 ).addr( config_memories_out( 5 ).widthAddr - 1 downto 0 ),
  vmprojout_6_dataarray_data_V_address0 => writes( 6 ).addr( config_memories_out( 6 ).widthAddr - 1 downto 0 ),
  vmprojout_7_dataarray_data_V_address0 => writes( 7 ).addr( config_memories_out( 7 ).widthAddr - 1 downto 0 ),
  allprojout_dataarray_data_V_d0 => writes( 8 ).data( config_memories_out( 8 ).widthData - 1 downto 0 ),
  vmprojout_0_dataarray_data_V_d0 => writes( 0 ).data( config_memories_out( 0 ).widthData - 1 downto 0 ),
  vmprojout_1_dataarray_data_V_d0 => writes( 1 ).data( config_memories_out( 1 ).widthData - 1 downto 0 ),
  vmprojout_2_dataarray_data_V_d0 => writes( 2 ).data( config_memories_out( 2 ).widthData - 1 downto 0 ),
  vmprojout_3_dataarray_data_V_d0 => writes( 3 ).data( config_memories_out( 3 ).widthData - 1 downto 0 ),
  vmprojout_4_dataarray_data_V_d0 => writes( 4 ).data( config_memories_out( 4 ).widthData - 1 downto 0 ),
  vmprojout_5_dataarray_data_V_d0 => writes( 5 ).data( config_memories_out( 5 ).widthData - 1 downto 0 ),
  vmprojout_6_dataarray_data_V_d0 => writes( 6 ).data( config_memories_out( 6 ).widthData - 1 downto 0 ),
  vmprojout_7_dataarray_data_V_d0 => writes( 7 ).data( config_memories_out( 7 ).widthData - 1 downto 0 )
);
end generate;
g3: if k = 3 generate
L6PHIB: entity xil_defaultlib.PR_L6PHIB port map (
  ap_clk => clk,
  ap_rst => reset,
  ap_start => start,
  ap_done => done,
  bx_V => bxIn,
  bx_o_V => bxOut,
  ap_idle => open,
  ap_ready => open,
  bx_o_V_ap_vld => open,
  projin_0_dataarray_data_V_ce0 => rout( 0 ).valid,
  projin_0_dataarray_data_V_address0 => rout( 0 ).addr( config_memories_in( 0 ).widthAddr - 1 downto 0 ),
  projin_0_dataarray_data_V_q0 => din( 0 ).data( config_memories_in( 0 ).widthData - 1 downto 0 ),
  projin_0_nentries_0_V => din( 0 ).nents( 0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  projin_0_nentries_1_V => din( 0 ).nents( 1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  allprojout_dataarray_data_V_ce0 => open,
  vmprojout_0_dataarray_data_V_ce0 => open,
  vmprojout_1_dataarray_data_V_ce0 => open,
  vmprojout_2_dataarray_data_V_ce0 => open,
  vmprojout_3_dataarray_data_V_ce0 => open,
  vmprojout_4_dataarray_data_V_ce0 => open,
  vmprojout_5_dataarray_data_V_ce0 => open,
  vmprojout_6_dataarray_data_V_ce0 => open,
  vmprojout_7_dataarray_data_V_ce0 => open,
  allprojout_dataarray_data_V_we0 => writes( 8 ).valid,
  vmprojout_0_dataarray_data_V_we0 => writes( 0 ).valid,
  vmprojout_1_dataarray_data_V_we0 => writes( 1 ).valid,
  vmprojout_2_dataarray_data_V_we0 => writes( 2 ).valid,
  vmprojout_3_dataarray_data_V_we0 => writes( 3 ).valid,
  vmprojout_4_dataarray_data_V_we0 => writes( 4 ).valid,
  vmprojout_5_dataarray_data_V_we0 => writes( 5 ).valid,
  vmprojout_6_dataarray_data_V_we0 => writes( 6 ).valid,
  vmprojout_7_dataarray_data_V_we0 => writes( 7 ).valid,
  allprojout_dataarray_data_V_address0 => writes( 8 ).addr( config_memories_out( 8 ).widthAddr - 1 downto 0 ),
  vmprojout_0_dataarray_data_V_address0 => writes( 0 ).addr( config_memories_out( 0 ).widthAddr - 1 downto 0 ),
  vmprojout_1_dataarray_data_V_address0 => writes( 1 ).addr( config_memories_out( 1 ).widthAddr - 1 downto 0 ),
  vmprojout_2_dataarray_data_V_address0 => writes( 2 ).addr( config_memories_out( 2 ).widthAddr - 1 downto 0 ),
  vmprojout_3_dataarray_data_V_address0 => writes( 3 ).addr( config_memories_out( 3 ).widthAddr - 1 downto 0 ),
  vmprojout_4_dataarray_data_V_address0 => writes( 4 ).addr( config_memories_out( 4 ).widthAddr - 1 downto 0 ),
  vmprojout_5_dataarray_data_V_address0 => writes( 5 ).addr( config_memories_out( 5 ).widthAddr - 1 downto 0 ),
  vmprojout_6_dataarray_data_V_address0 => writes( 6 ).addr( config_memories_out( 6 ).widthAddr - 1 downto 0 ),
  vmprojout_7_dataarray_data_V_address0 => writes( 7 ).addr( config_memories_out( 7 ).widthAddr - 1 downto 0 ),
  allprojout_dataarray_data_V_d0 => writes( 8 ).data( config_memories_out( 8 ).widthData - 1 downto 0 ),
  vmprojout_0_dataarray_data_V_d0 => writes( 0 ).data( config_memories_out( 0 ).widthData - 1 downto 0 ),
  vmprojout_1_dataarray_data_V_d0 => writes( 1 ).data( config_memories_out( 1 ).widthData - 1 downto 0 ),
  vmprojout_2_dataarray_data_V_d0 => writes( 2 ).data( config_memories_out( 2 ).widthData - 1 downto 0 ),
  vmprojout_3_dataarray_data_V_d0 => writes( 3 ).data( config_memories_out( 3 ).widthData - 1 downto 0 ),
  vmprojout_4_dataarray_data_V_d0 => writes( 4 ).data( config_memories_out( 4 ).widthData - 1 downto 0 ),
  vmprojout_5_dataarray_data_V_d0 => writes( 5 ).data( config_memories_out( 5 ).widthData - 1 downto 0 ),
  vmprojout_6_dataarray_data_V_d0 => writes( 6 ).data( config_memories_out( 6 ).widthData - 1 downto 0 ),
  vmprojout_7_dataarray_data_V_d0 => writes( 7 ).data( config_memories_out( 7 ).widthData - 1 downto 0 )
);
end generate;

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.tracklet_config.all;
use work.tracklet_data_types.all;

entity PR_memories is
port (
  clk: in std_logic;
  memories_din: in t_writes( numOutputsPR  - 1 downto 0 );
  memories_rin: in t_reads( numOutputsPR  - 1 downto 0 );
  memories_dout: out t_datas( numOutputsPR  - 1 downto 0 )
);
end;

architecture rtl of PR_memories is

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


g: for k in 0 to numOutputsPR - 1 generate

signal memory_din: t_write := nulll;
signal memory_read: t_read := nulll;
signal memory_dout: t_data := nulll;

begin

memory_din <= memories_din( k );
memory_read <= memories_rin( k );
memories_dout( k ) <= memory_dout;

c: tracklet_memory generic map ( sumMemOutTC + k ) port map ( clk, memory_din, memory_read, memory_dout );

end generate;

end;