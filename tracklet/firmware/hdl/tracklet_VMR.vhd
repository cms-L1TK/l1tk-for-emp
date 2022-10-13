library ieee;
use ieee.std_logic_1164.all;
use work.tracklet_config.all;
use work.tracklet_data_types.all;

entity tracklet_VMR is
port (
  clk: in std_logic;
  vmr_din: in t_datas( numInputsVMR  - 1 downto 0 );
  vmr_rin: in t_reads( numOutputsVMR  - 1 downto 0 );
  vmr_rout: out t_reads( numInputsVMR  - 1 downto 0 );
  vmr_dout: out t_datas( numOutputsVMR  - 1 downto 0 )
);
end;

architecture rtl of tracklet_VMR is

signal process_din: t_datas( numInputsVMR  - 1 downto 0 ) := ( others => nulll );
signal process_rout: t_reads( numInputsVMR  - 1 downto 0 ) := ( others => nulll );
signal process_dout: t_writes( numOutputsVMR  - 1 downto 0 ) := ( others => nulll );
component VMR_process
port (
  clk: in std_logic;
  process_din: in t_datas( numInputsVMR  - 1 downto 0 );
  process_rout: out t_reads( numInputsVMR  - 1 downto 0 );
  process_dout: out t_writes( numOutputsVMR  - 1 downto 0 )
);
end component;

signal memories_din: t_writes( numOutputsVMR  - 1 downto 0 ) := ( others => nulll );
signal memories_rin: t_reads( numOutputsVMR  - 1 downto 0 ) := ( others => nulll );
signal memories_dout: t_datas( numOutputsVMR  - 1 downto 0 ) := ( others => nulll );
component VMR_memories
port (
  clk: in std_logic;
  memories_din: in t_writes( numOutputsVMR  - 1 downto 0 );
  memories_rin: in t_reads( numOutputsVMR  - 1 downto 0 );
  memories_dout: out t_datas( numOutputsVMR  - 1 downto 0 )
);
end component;

begin

process_din <= vmr_din;
memories_din <= process_dout;
memories_rin <= vmr_rin;

vmr_rout <= process_rout;
vmr_dout <= memories_dout;

cP: VMR_process port map ( clk, process_din, process_rout, process_dout );

cM: VMR_memories port map( clk, memories_din, memories_rin, memories_dout );

end;


library xil_defaultlib;
library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.tracklet_config.all;
use work.tracklet_data_types.all;
use work.tracklet_config_memory.all;

entity VMR_process is
port (
  clk: in std_logic;
  process_din: in t_datas( numInputsVMR  - 1 downto 0 );
  process_rout: out t_reads( numInputsVMR  - 1 downto 0 );
  process_dout: out t_writes( numOutputsVMR  - 1 downto 0 )
);
end;

architecture rtl of VMR_process is

begin


g: for k in 0 to numVMR - 1 generate

constant offsetIn: natural := sum( 0 & numNodeInputsVMR, 0, k );
constant offsetOut: natural := sum( 0 & numNodeOutputsVMR, 0, k );
constant numInputs: natural := numNodeInputsVMR( k );
constant numOutputs: natural := numNodeOutputsVMR( k );
constant config_memories_out: t_config_memories( 0 to numOutputs - 1 ) := config_memories_out( sumMemOutIR + offsetOut to sumMemOutIR + offsetOut + numOutputs - 1 );
constant config_memories_in: t_config_memories( 0 to numInputs - 1 ) := config_memories_in( offsetIn to offsetIn + numInputs - 1 );

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
L1PHID: entity xil_defaultlib.VMR_L1PHID port map (
  ap_clk => clk,
  ap_rst => reset,
  ap_start => start,
  ap_done => done,
  bx_V => bxIn,
  bx_o_V => bxOut,
  ap_idle => open,
  ap_ready => open,
  bx_o_V_ap_vld => open,
  inputStubs_0_dataarray_data_V_ce0 => rout( 0 ).valid,
  inputStubs_1_dataarray_data_V_ce0 => rout( 1 ).valid,
  inputStubs_2_dataarray_data_V_ce0 => rout( 2 ).valid,
  inputStubs_0_dataarray_data_V_address0 => rout( 0 ).addr( config_memories_in( 0 ).widthAddr - 1 downto 0 ),
  inputStubs_1_dataarray_data_V_address0 => rout( 1 ).addr( config_memories_in( 1 ).widthAddr - 1 downto 0 ),
  inputStubs_2_dataarray_data_V_address0 => rout( 2 ).addr( config_memories_in( 2 ).widthAddr - 1 downto 0 ),
  inputStubs_0_dataarray_data_V_q0 => din( 0 ).data( config_memories_in( 0 ).widthData - 1 downto 0 ),
  inputStubs_1_dataarray_data_V_q0 => din( 1 ).data( config_memories_in( 1 ).widthData - 1 downto 0 ),
  inputStubs_2_dataarray_data_V_q0 => din( 2 ).data( config_memories_in( 2 ).widthData - 1 downto 0 ),
  inputStubs_0_nentries_0_V => din( 0 ).nents( 0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubs_0_nentries_1_V => din( 0 ).nents( 1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubs_1_nentries_0_V => din( 1 ).nents( 0 )( config_memories_in( 1 ).widthNent - 1 downto 0 ),
  inputStubs_1_nentries_1_V => din( 1 ).nents( 1 )( config_memories_in( 1 ).widthNent - 1 downto 0 ),
  inputStubs_2_nentries_0_V => din( 2 ).nents( 0 )( config_memories_in( 2 ).widthNent - 1 downto 0 ),
  inputStubs_2_nentries_1_V => din( 2 ).nents( 1 )( config_memories_in( 2 ).widthNent - 1 downto 0 ),
  memoriesAS_0_dataarray_data_V_ce0 => open,
  memoriesTEI_0_0_dataarray_data_V_ce0 => open,
  memoriesTEI_0_1_dataarray_data_V_ce0 => open,
  memoriesTEI_0_2_dataarray_data_V_ce0 => open,
  memoriesTEI_0_3_dataarray_data_V_ce0 => open,
  memoriesTEI_1_0_dataarray_data_V_ce0 => open,
  memoriesTEI_1_1_dataarray_data_V_ce0 => open,
  memoriesTEI_1_2_dataarray_data_V_ce0 => open,
  memoriesTEI_1_3_dataarray_data_V_ce0 => open,
  memoriesTEI_2_0_dataarray_data_V_ce0 => open,
  memoriesTEI_2_1_dataarray_data_V_ce0 => open,
  memoriesTEI_2_2_dataarray_data_V_ce0 => open,
  memoriesTEI_2_3_dataarray_data_V_ce0 => open,
  memoriesTEI_3_0_dataarray_data_V_ce0 => open,
  memoriesTEI_3_1_dataarray_data_V_ce0 => open,
  memoriesTEI_3_2_dataarray_data_V_ce0 => open,
  memoriesTEI_3_3_dataarray_data_V_ce0 => open,
  memoriesAS_0_dataarray_data_V_we0 => writes( 0 ).valid,
  memoriesTEI_0_0_dataarray_data_V_we0 => writes( 1 ).valid,
  memoriesTEI_0_1_dataarray_data_V_we0 => writes( 2 ).valid,
  memoriesTEI_0_2_dataarray_data_V_we0 => open,
  memoriesTEI_0_3_dataarray_data_V_we0 => open,
  memoriesTEI_1_0_dataarray_data_V_we0 => writes( 3 ).valid,
  memoriesTEI_1_1_dataarray_data_V_we0 => writes( 4 ).valid,
  memoriesTEI_1_2_dataarray_data_V_we0 => writes( 5 ).valid,
  memoriesTEI_1_3_dataarray_data_V_we0 => writes( 6 ).valid,
  memoriesTEI_2_0_dataarray_data_V_we0 => writes( 7 ).valid,
  memoriesTEI_2_1_dataarray_data_V_we0 => writes( 8 ).valid,
  memoriesTEI_2_2_dataarray_data_V_we0 => writes( 9 ).valid,
  memoriesTEI_2_3_dataarray_data_V_we0 => open,
  memoriesTEI_3_0_dataarray_data_V_we0 => open,
  memoriesTEI_3_1_dataarray_data_V_we0 => open,
  memoriesTEI_3_2_dataarray_data_V_we0 => open,
  memoriesTEI_3_3_dataarray_data_V_we0 => open,
  memoriesAS_0_dataarray_data_V_address0 => writes( 0 ).addr( config_memories_out( 0 ).widthAddr - 1 downto 0 ),
  memoriesTEI_0_0_dataarray_data_V_address0 => writes( 1 ).addr( config_memories_out( 1 ).widthAddr - 1 downto 0 ),
  memoriesTEI_0_1_dataarray_data_V_address0 => writes( 2 ).addr( config_memories_out( 2 ).widthAddr - 1 downto 0 ),
  memoriesTEI_0_2_dataarray_data_V_address0 => open,
  memoriesTEI_0_3_dataarray_data_V_address0 => open,
  memoriesTEI_1_0_dataarray_data_V_address0 => writes( 3 ).addr( config_memories_out( 3 ).widthAddr - 1 downto 0 ),
  memoriesTEI_1_1_dataarray_data_V_address0 => writes( 4 ).addr( config_memories_out( 4 ).widthAddr - 1 downto 0 ),
  memoriesTEI_1_2_dataarray_data_V_address0 => writes( 5 ).addr( config_memories_out( 5 ).widthAddr - 1 downto 0 ),
  memoriesTEI_1_3_dataarray_data_V_address0 => writes( 6 ).addr( config_memories_out( 6 ).widthAddr - 1 downto 0 ),
  memoriesTEI_2_0_dataarray_data_V_address0 => writes( 7 ).addr( config_memories_out( 7 ).widthAddr - 1 downto 0 ),
  memoriesTEI_2_1_dataarray_data_V_address0 => writes( 8 ).addr( config_memories_out( 8 ).widthAddr - 1 downto 0 ),
  memoriesTEI_2_2_dataarray_data_V_address0 => writes( 9 ).addr( config_memories_out( 9 ).widthAddr - 1 downto 0 ),
  memoriesTEI_2_3_dataarray_data_V_address0 => open,
  memoriesTEI_3_0_dataarray_data_V_address0 => open,
  memoriesTEI_3_1_dataarray_data_V_address0 => open,
  memoriesTEI_3_2_dataarray_data_V_address0 => open,
  memoriesTEI_3_3_dataarray_data_V_address0 => open,
  memoriesAS_0_dataarray_data_V_d0 => writes( 0 ).data( config_memories_out( 0 ).widthData - 1 downto 0 ),
  memoriesTEI_0_0_dataarray_data_V_d0 => writes( 1 ).data( config_memories_out( 1 ).widthData - 1 downto 0 ),
  memoriesTEI_0_1_dataarray_data_V_d0 => writes( 2 ).data( config_memories_out( 2 ).widthData - 1 downto 0 ),
  memoriesTEI_0_2_dataarray_data_V_d0 => open,
  memoriesTEI_0_3_dataarray_data_V_d0 => open,
  memoriesTEI_1_0_dataarray_data_V_d0 => writes( 3 ).data( config_memories_out( 3 ).widthData - 1 downto 0 ),
  memoriesTEI_1_1_dataarray_data_V_d0 => writes( 4 ).data( config_memories_out( 4 ).widthData - 1 downto 0 ),
  memoriesTEI_1_2_dataarray_data_V_d0 => writes( 5 ).data( config_memories_out( 5 ).widthData - 1 downto 0 ),
  memoriesTEI_1_3_dataarray_data_V_d0 => writes( 6 ).data( config_memories_out( 6 ).widthData - 1 downto 0 ),
  memoriesTEI_2_0_dataarray_data_V_d0 => writes( 7 ).data( config_memories_out( 7 ).widthData - 1 downto 0 ),
  memoriesTEI_2_1_dataarray_data_V_d0 => writes( 8 ).data( config_memories_out( 8 ).widthData - 1 downto 0 ),
  memoriesTEI_2_2_dataarray_data_V_d0 => writes( 9 ).data( config_memories_out( 9 ).widthData - 1 downto 0 ),
  memoriesTEI_2_3_dataarray_data_V_d0 => open,
  memoriesTEI_3_0_dataarray_data_V_d0 => open,
  memoriesTEI_3_1_dataarray_data_V_d0 => open,
  memoriesTEI_3_2_dataarray_data_V_d0 => open,
  memoriesTEI_3_3_dataarray_data_V_d0 => open
);
end generate;
g1: if k = 1 generate
L2PHIB: entity xil_defaultlib.VMR_L2PHIB port map (
  ap_clk => clk,
  ap_rst => reset,
  ap_start => start,
  ap_done => done,
  bx_V => bxIn,
  bx_o_V => bxOut,
  ap_idle => open,
  ap_ready => open,
  bx_o_V_ap_vld => open,
  inputStubs_0_dataarray_data_V_ce0 => rout( 0 ).valid,
  inputStubs_1_dataarray_data_V_ce0 => rout( 1 ).valid,
  inputStubs_0_dataarray_data_V_address0 => rout( 0 ).addr( config_memories_in( 0 ).widthAddr - 1 downto 0 ),
  inputStubs_1_dataarray_data_V_address0 => rout( 1 ).addr( config_memories_in( 1 ).widthAddr - 1 downto 0 ),
  inputStubs_0_dataarray_data_V_q0 => din( 0 ).data( config_memories_in( 0 ).widthData - 1 downto 0 ),
  inputStubs_1_dataarray_data_V_q0 => din( 1 ).data( config_memories_in( 1 ).widthData - 1 downto 0 ),
  inputStubs_0_nentries_0_V => din( 0 ).nents( 0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubs_0_nentries_1_V => din( 0 ).nents( 1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubs_1_nentries_0_V => din( 1 ).nents( 0 )( config_memories_in( 1 ).widthNent - 1 downto 0 ),
  inputStubs_1_nentries_1_V => din( 1 ).nents( 1 )( config_memories_in( 1 ).widthNent - 1 downto 0 ),
  memoriesAS_0_dataarray_data_V_ce0 => open,
  memoriesTEO_0_0_dataarray_data_V_ce0 => open,
  memoriesTEO_0_1_dataarray_data_V_ce0 => open,
  memoriesTEO_0_2_dataarray_data_V_ce0 => open,
  memoriesTEO_1_0_dataarray_data_V_ce0 => open,
  memoriesTEO_1_1_dataarray_data_V_ce0 => open,
  memoriesTEO_1_2_dataarray_data_V_ce0 => open,
  memoriesTEO_2_0_dataarray_data_V_ce0 => open,
  memoriesTEO_2_1_dataarray_data_V_ce0 => open,
  memoriesTEO_2_2_dataarray_data_V_ce0 => open,
  memoriesTEO_3_0_dataarray_data_V_ce0 => open,
  memoriesTEO_3_1_dataarray_data_V_ce0 => open,
  memoriesTEO_3_2_dataarray_data_V_ce0 => open,
  memoriesTEO_4_0_dataarray_data_V_ce0 => open,
  memoriesTEO_4_1_dataarray_data_V_ce0 => open,
  memoriesTEO_4_2_dataarray_data_V_ce0 => open,
  memoriesTEO_5_0_dataarray_data_V_ce0 => open,
  memoriesTEO_5_1_dataarray_data_V_ce0 => open,
  memoriesTEO_5_2_dataarray_data_V_ce0 => open,
  memoriesTEO_6_0_dataarray_data_V_ce0 => open,
  memoriesTEO_6_1_dataarray_data_V_ce0 => open,
  memoriesTEO_6_2_dataarray_data_V_ce0 => open,
  memoriesTEO_7_0_dataarray_data_V_ce0 => open,
  memoriesTEO_7_1_dataarray_data_V_ce0 => open,
  memoriesTEO_7_2_dataarray_data_V_ce0 => open,
  memoriesAS_0_dataarray_data_V_we0 => writes( 0 ).valid,
  memoriesTEO_0_0_dataarray_data_V_we0 => writes( 1 ).valid,
  memoriesTEO_0_1_dataarray_data_V_we0 => open,
  memoriesTEO_0_2_dataarray_data_V_we0 => open,
  memoriesTEO_1_0_dataarray_data_V_we0 => writes( 2 ).valid,
  memoriesTEO_1_1_dataarray_data_V_we0 => writes( 3 ).valid,
  memoriesTEO_1_2_dataarray_data_V_we0 => open,
  memoriesTEO_2_0_dataarray_data_V_we0 => writes( 4 ).valid,
  memoriesTEO_2_1_dataarray_data_V_we0 => writes( 5 ).valid,
  memoriesTEO_2_2_dataarray_data_V_we0 => writes( 6 ).valid,
  memoriesTEO_3_0_dataarray_data_V_we0 => writes( 7 ).valid,
  memoriesTEO_3_1_dataarray_data_V_we0 => writes( 8 ).valid,
  memoriesTEO_3_2_dataarray_data_V_we0 => writes( 9 ).valid,
  memoriesTEO_4_0_dataarray_data_V_we0 => open,
  memoriesTEO_4_1_dataarray_data_V_we0 => open,
  memoriesTEO_4_2_dataarray_data_V_we0 => open,
  memoriesTEO_5_0_dataarray_data_V_we0 => open,
  memoriesTEO_5_1_dataarray_data_V_we0 => open,
  memoriesTEO_5_2_dataarray_data_V_we0 => open,
  memoriesTEO_6_0_dataarray_data_V_we0 => open,
  memoriesTEO_6_1_dataarray_data_V_we0 => open,
  memoriesTEO_6_2_dataarray_data_V_we0 => open,
  memoriesTEO_7_0_dataarray_data_V_we0 => open,
  memoriesTEO_7_1_dataarray_data_V_we0 => open,
  memoriesTEO_7_2_dataarray_data_V_we0 => open,
  memoriesAS_0_dataarray_data_V_address0 => writes( 0 ).addr( config_memories_out( 0 ).widthAddr - 1 downto 0 ),
  memoriesTEO_0_0_dataarray_data_V_address0 => writes( 1 ).addr( config_memories_out( 1 ).widthAddr - 1 downto 0 ),
  memoriesTEO_0_1_dataarray_data_V_address0 => open,
  memoriesTEO_0_2_dataarray_data_V_address0 => open,
  memoriesTEO_1_0_dataarray_data_V_address0 => writes( 2 ).addr( config_memories_out( 2 ).widthAddr - 1 downto 0 ),
  memoriesTEO_1_1_dataarray_data_V_address0 => writes( 3 ).addr( config_memories_out( 3 ).widthAddr - 1 downto 0 ),
  memoriesTEO_1_2_dataarray_data_V_address0 => open,
  memoriesTEO_2_0_dataarray_data_V_address0 => writes( 4 ).addr( config_memories_out( 4 ).widthAddr - 1 downto 0 ),
  memoriesTEO_2_1_dataarray_data_V_address0 => writes( 5 ).addr( config_memories_out( 5 ).widthAddr - 1 downto 0 ),
  memoriesTEO_2_2_dataarray_data_V_address0 => writes( 6 ).addr( config_memories_out( 6 ).widthAddr - 1 downto 0 ),
  memoriesTEO_3_0_dataarray_data_V_address0 => writes( 7 ).addr( config_memories_out( 7 ).widthAddr - 1 downto 0 ),
  memoriesTEO_3_1_dataarray_data_V_address0 => writes( 8 ).addr( config_memories_out( 8 ).widthAddr - 1 downto 0 ),
  memoriesTEO_3_2_dataarray_data_V_address0 => writes( 9 ).addr( config_memories_out( 9 ).widthAddr - 1 downto 0 ),
  memoriesTEO_4_0_dataarray_data_V_address0 => open,
  memoriesTEO_4_1_dataarray_data_V_address0 => open,
  memoriesTEO_4_2_dataarray_data_V_address0 => open,
  memoriesTEO_5_0_dataarray_data_V_address0 => open,
  memoriesTEO_5_1_dataarray_data_V_address0 => open,
  memoriesTEO_5_2_dataarray_data_V_address0 => open,
  memoriesTEO_6_0_dataarray_data_V_address0 => open,
  memoriesTEO_6_1_dataarray_data_V_address0 => open,
  memoriesTEO_6_2_dataarray_data_V_address0 => open,
  memoriesTEO_7_0_dataarray_data_V_address0 => open,
  memoriesTEO_7_1_dataarray_data_V_address0 => open,
  memoriesTEO_7_2_dataarray_data_V_address0 => open,
  memoriesAS_0_dataarray_data_V_d0 => writes( 0 ).data( config_memories_out( 0 ).widthData - 1 downto 0 ),
  memoriesTEO_0_0_dataarray_data_V_d0 => writes( 1 ).data( config_memories_out( 1 ).widthData - 1 downto 0 ),
  memoriesTEO_0_1_dataarray_data_V_d0 => open,
  memoriesTEO_0_2_dataarray_data_V_d0 => open,
  memoriesTEO_1_0_dataarray_data_V_d0 => writes( 2 ).data( config_memories_out( 2 ).widthData - 1 downto 0 ),
  memoriesTEO_1_1_dataarray_data_V_d0 => writes( 3 ).data( config_memories_out( 3 ).widthData - 1 downto 0 ),
  memoriesTEO_1_2_dataarray_data_V_d0 => open,
  memoriesTEO_2_0_dataarray_data_V_d0 => writes( 4 ).data( config_memories_out( 4 ).widthData - 1 downto 0 ),
  memoriesTEO_2_1_dataarray_data_V_d0 => writes( 5 ).data( config_memories_out( 5 ).widthData - 1 downto 0 ),
  memoriesTEO_2_2_dataarray_data_V_d0 => writes( 6 ).data( config_memories_out( 6 ).widthData - 1 downto 0 ),
  memoriesTEO_3_0_dataarray_data_V_d0 => writes( 7 ).data( config_memories_out( 7 ).widthData - 1 downto 0 ),
  memoriesTEO_3_1_dataarray_data_V_d0 => writes( 8 ).data( config_memories_out( 8 ).widthData - 1 downto 0 ),
  memoriesTEO_3_2_dataarray_data_V_d0 => writes( 9 ).data( config_memories_out( 9 ).widthData - 1 downto 0 ),
  memoriesTEO_4_0_dataarray_data_V_d0 => open,
  memoriesTEO_4_1_dataarray_data_V_d0 => open,
  memoriesTEO_4_2_dataarray_data_V_d0 => open,
  memoriesTEO_5_0_dataarray_data_V_d0 => open,
  memoriesTEO_5_1_dataarray_data_V_d0 => open,
  memoriesTEO_5_2_dataarray_data_V_d0 => open,
  memoriesTEO_6_0_dataarray_data_V_d0 => open,
  memoriesTEO_6_1_dataarray_data_V_d0 => open,
  memoriesTEO_6_2_dataarray_data_V_d0 => open,
  memoriesTEO_7_0_dataarray_data_V_d0 => open,
  memoriesTEO_7_1_dataarray_data_V_d0 => open,
  memoriesTEO_7_2_dataarray_data_V_d0 => open
);
end generate;
g2: if k = 2 generate
L3PHIB: entity xil_defaultlib.VMR_L3PHIB port map (
  ap_clk => clk,
  ap_rst => reset,
  ap_start => start,
  ap_done => done,
  bx_V => bxIn,
  bx_o_V => bxOut,
  ap_idle => open,
  ap_ready => open,
  bx_o_V_ap_vld => open,
  inputStubs_0_dataarray_data_V_ce0 => rout( 0 ).valid,
  inputStubs_1_dataarray_data_V_ce0 => rout( 1 ).valid,
  inputStubs_2_dataarray_data_V_ce0 => rout( 2 ).valid,
  inputStubs_0_dataarray_data_V_address0 => rout( 0 ).addr( config_memories_in( 0 ).widthAddr - 1 downto 0 ),
  inputStubs_1_dataarray_data_V_address0 => rout( 1 ).addr( config_memories_in( 1 ).widthAddr - 1 downto 0 ),
  inputStubs_2_dataarray_data_V_address0 => rout( 2 ).addr( config_memories_in( 2 ).widthAddr - 1 downto 0 ),
  inputStubs_0_dataarray_data_V_q0 => din( 0 ).data( config_memories_in( 0 ).widthData - 1 downto 0 ),
  inputStubs_1_dataarray_data_V_q0 => din( 1 ).data( config_memories_in( 1 ).widthData - 1 downto 0 ),
  inputStubs_2_dataarray_data_V_q0 => din( 2 ).data( config_memories_in( 2 ).widthData - 1 downto 0 ),
  inputStubs_0_nentries_0_V => din( 0 ).nents( 0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubs_0_nentries_1_V => din( 0 ).nents( 1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubs_1_nentries_0_V => din( 1 ).nents( 0 )( config_memories_in( 1 ).widthNent - 1 downto 0 ),
  inputStubs_1_nentries_1_V => din( 1 ).nents( 1 )( config_memories_in( 1 ).widthNent - 1 downto 0 ),
  inputStubs_2_nentries_0_V => din( 2 ).nents( 0 )( config_memories_in( 2 ).widthNent - 1 downto 0 ),
  inputStubs_2_nentries_1_V => din( 2 ).nents( 1 )( config_memories_in( 2 ).widthNent - 1 downto 0 ),
  memoriesAS_0_dataarray_data_V_ce0 => open,
  memoriesME_0_dataarray_data_V_ce0 => open,
  memoriesME_1_dataarray_data_V_ce0 => open,
  memoriesME_2_dataarray_data_V_ce0 => open,
  memoriesME_3_dataarray_data_V_ce0 => open,
  memoriesME_4_dataarray_data_V_ce0 => open,
  memoriesME_5_dataarray_data_V_ce0 => open,
  memoriesME_6_dataarray_data_V_ce0 => open,
  memoriesME_7_dataarray_data_V_ce0 => open,
  memoriesAS_0_dataarray_data_V_we0 => writes( 0 ).valid,
  memoriesME_0_dataarray_data_V_we0 => writes( 1 ).valid,
  memoriesME_1_dataarray_data_V_we0 => writes( 2 ).valid,
  memoriesME_2_dataarray_data_V_we0 => writes( 3 ).valid,
  memoriesME_3_dataarray_data_V_we0 => writes( 4 ).valid,
  memoriesME_4_dataarray_data_V_we0 => writes( 5 ).valid,
  memoriesME_5_dataarray_data_V_we0 => writes( 6 ).valid,
  memoriesME_6_dataarray_data_V_we0 => writes( 7 ).valid,
  memoriesME_7_dataarray_data_V_we0 => writes( 8 ).valid,
  memoriesAS_0_dataarray_data_V_address0 => writes( 0 ).addr( config_memories_out( 0 ).widthAddr - 1 downto 0 ),
  memoriesME_0_dataarray_data_V_address0 => writes( 1 ).addr( config_memories_out( 1 ).widthAddr - 1 downto 0 ),
  memoriesME_1_dataarray_data_V_address0 => writes( 2 ).addr( config_memories_out( 2 ).widthAddr - 1 downto 0 ),
  memoriesME_2_dataarray_data_V_address0 => writes( 3 ).addr( config_memories_out( 3 ).widthAddr - 1 downto 0 ),
  memoriesME_3_dataarray_data_V_address0 => writes( 4 ).addr( config_memories_out( 4 ).widthAddr - 1 downto 0 ),
  memoriesME_4_dataarray_data_V_address0 => writes( 5 ).addr( config_memories_out( 5 ).widthAddr - 1 downto 0 ),
  memoriesME_5_dataarray_data_V_address0 => writes( 6 ).addr( config_memories_out( 6 ).widthAddr - 1 downto 0 ),
  memoriesME_6_dataarray_data_V_address0 => writes( 7 ).addr( config_memories_out( 7 ).widthAddr - 1 downto 0 ),
  memoriesME_7_dataarray_data_V_address0 => writes( 8 ).addr( config_memories_out( 8 ).widthAddr - 1 downto 0 ),
  memoriesAS_0_dataarray_data_V_d0 => writes( 0 ).data( config_memories_out( 0 ).widthData - 1 downto 0 ),
  memoriesME_0_dataarray_data_V_d0 => writes( 1 ).data( config_memories_out( 1 ).widthData - 1 downto 0 ),
  memoriesME_1_dataarray_data_V_d0 => writes( 2 ).data( config_memories_out( 2 ).widthData - 1 downto 0 ),
  memoriesME_2_dataarray_data_V_d0 => writes( 3 ).data( config_memories_out( 3 ).widthData - 1 downto 0 ),
  memoriesME_3_dataarray_data_V_d0 => writes( 4 ).data( config_memories_out( 4 ).widthData - 1 downto 0 ),
  memoriesME_4_dataarray_data_V_d0 => writes( 5 ).data( config_memories_out( 5 ).widthData - 1 downto 0 ),
  memoriesME_5_dataarray_data_V_d0 => writes( 6 ).data( config_memories_out( 6 ).widthData - 1 downto 0 ),
  memoriesME_6_dataarray_data_V_d0 => writes( 7 ).data( config_memories_out( 7 ).widthData - 1 downto 0 ),
  memoriesME_7_dataarray_data_V_d0 => writes( 8 ).data( config_memories_out( 8 ).widthData - 1 downto 0 )
);
end generate;
g3: if k = 3 generate
L4PHIB: entity xil_defaultlib.VMR_L4PHIB port map (
  ap_clk => clk,
  ap_rst => reset,
  ap_start => start,
  ap_done => done,
  bx_V => bxIn,
  bx_o_V => bxOut,
  ap_idle => open,
  ap_ready => open,
  bx_o_V_ap_vld => open,
  inputStubs_0_dataarray_data_V_ce0 => rout( 0 ).valid,
  inputStubs_1_dataarray_data_V_ce0 => rout( 1 ).valid,
  inputStubs_0_dataarray_data_V_address0 => rout( 0 ).addr( config_memories_in( 0 ).widthAddr - 1 downto 0 ),
  inputStubs_1_dataarray_data_V_address0 => rout( 1 ).addr( config_memories_in( 1 ).widthAddr - 1 downto 0 ),
  inputStubs_0_dataarray_data_V_q0 => din( 0 ).data( config_memories_in( 0 ).widthData - 1 downto 0 ),
  inputStubs_1_dataarray_data_V_q0 => din( 1 ).data( config_memories_in( 1 ).widthData - 1 downto 0 ),
  inputStubs_0_nentries_0_V => din( 0 ).nents( 0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubs_0_nentries_1_V => din( 0 ).nents( 1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubs_1_nentries_0_V => din( 1 ).nents( 0 )( config_memories_in( 1 ).widthNent - 1 downto 0 ),
  inputStubs_1_nentries_1_V => din( 1 ).nents( 1 )( config_memories_in( 1 ).widthNent - 1 downto 0 ),
  memoriesAS_0_dataarray_data_V_ce0 => open,
  memoriesME_0_dataarray_data_V_ce0 => open,
  memoriesME_1_dataarray_data_V_ce0 => open,
  memoriesME_2_dataarray_data_V_ce0 => open,
  memoriesME_3_dataarray_data_V_ce0 => open,
  memoriesME_4_dataarray_data_V_ce0 => open,
  memoriesME_5_dataarray_data_V_ce0 => open,
  memoriesME_6_dataarray_data_V_ce0 => open,
  memoriesME_7_dataarray_data_V_ce0 => open,
  memoriesAS_0_dataarray_data_V_we0 => writes( 0 ).valid,
  memoriesME_0_dataarray_data_V_we0 => writes( 1 ).valid,
  memoriesME_1_dataarray_data_V_we0 => writes( 2 ).valid,
  memoriesME_2_dataarray_data_V_we0 => writes( 3 ).valid,
  memoriesME_3_dataarray_data_V_we0 => writes( 4 ).valid,
  memoriesME_4_dataarray_data_V_we0 => writes( 5 ).valid,
  memoriesME_5_dataarray_data_V_we0 => writes( 6 ).valid,
  memoriesME_6_dataarray_data_V_we0 => writes( 7 ).valid,
  memoriesME_7_dataarray_data_V_we0 => writes( 8 ).valid,
  memoriesAS_0_dataarray_data_V_address0 => writes( 0 ).addr( config_memories_out( 0 ).widthAddr - 1 downto 0 ),
  memoriesME_0_dataarray_data_V_address0 => writes( 1 ).addr( config_memories_out( 1 ).widthAddr - 1 downto 0 ),
  memoriesME_1_dataarray_data_V_address0 => writes( 2 ).addr( config_memories_out( 2 ).widthAddr - 1 downto 0 ),
  memoriesME_2_dataarray_data_V_address0 => writes( 3 ).addr( config_memories_out( 3 ).widthAddr - 1 downto 0 ),
  memoriesME_3_dataarray_data_V_address0 => writes( 4 ).addr( config_memories_out( 4 ).widthAddr - 1 downto 0 ),
  memoriesME_4_dataarray_data_V_address0 => writes( 5 ).addr( config_memories_out( 5 ).widthAddr - 1 downto 0 ),
  memoriesME_5_dataarray_data_V_address0 => writes( 6 ).addr( config_memories_out( 6 ).widthAddr - 1 downto 0 ),
  memoriesME_6_dataarray_data_V_address0 => writes( 7 ).addr( config_memories_out( 7 ).widthAddr - 1 downto 0 ),
  memoriesME_7_dataarray_data_V_address0 => writes( 8 ).addr( config_memories_out( 8 ).widthAddr - 1 downto 0 ),
  memoriesAS_0_dataarray_data_V_d0 => writes( 0 ).data( config_memories_out( 0 ).widthData - 1 downto 0 ),
  memoriesME_0_dataarray_data_V_d0 => writes( 1 ).data( config_memories_out( 1 ).widthData - 1 downto 0 ),
  memoriesME_1_dataarray_data_V_d0 => writes( 2 ).data( config_memories_out( 2 ).widthData - 1 downto 0 ),
  memoriesME_2_dataarray_data_V_d0 => writes( 3 ).data( config_memories_out( 3 ).widthData - 1 downto 0 ),
  memoriesME_3_dataarray_data_V_d0 => writes( 4 ).data( config_memories_out( 4 ).widthData - 1 downto 0 ),
  memoriesME_4_dataarray_data_V_d0 => writes( 5 ).data( config_memories_out( 5 ).widthData - 1 downto 0 ),
  memoriesME_5_dataarray_data_V_d0 => writes( 6 ).data( config_memories_out( 6 ).widthData - 1 downto 0 ),
  memoriesME_6_dataarray_data_V_d0 => writes( 7 ).data( config_memories_out( 7 ).widthData - 1 downto 0 ),
  memoriesME_7_dataarray_data_V_d0 => writes( 8 ).data( config_memories_out( 8 ).widthData - 1 downto 0 )
);
end generate;
g4: if k = 4 generate
L5PHIB: entity xil_defaultlib.VMR_L5PHIB port map (
  ap_clk => clk,
  ap_rst => reset,
  ap_start => start,
  ap_done => done,
  bx_V => bxIn,
  bx_o_V => bxOut,
  ap_idle => open,
  ap_ready => open,
  bx_o_V_ap_vld => open,
  inputStubs_0_dataarray_data_V_ce0 => rout( 0 ).valid,
  inputStubs_1_dataarray_data_V_ce0 => rout( 1 ).valid,
  inputStubs_0_dataarray_data_V_address0 => rout( 0 ).addr( config_memories_in( 0 ).widthAddr - 1 downto 0 ),
  inputStubs_1_dataarray_data_V_address0 => rout( 1 ).addr( config_memories_in( 1 ).widthAddr - 1 downto 0 ),
  inputStubs_0_dataarray_data_V_q0 => din( 0 ).data( config_memories_in( 0 ).widthData - 1 downto 0 ),
  inputStubs_1_dataarray_data_V_q0 => din( 1 ).data( config_memories_in( 1 ).widthData - 1 downto 0 ),
  inputStubs_0_nentries_0_V => din( 0 ).nents( 0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubs_0_nentries_1_V => din( 0 ).nents( 1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubs_1_nentries_0_V => din( 1 ).nents( 0 )( config_memories_in( 1 ).widthNent - 1 downto 0 ),
  inputStubs_1_nentries_1_V => din( 1 ).nents( 1 )( config_memories_in( 1 ).widthNent - 1 downto 0 ),
  memoriesAS_0_dataarray_data_V_ce0 => open,
  memoriesME_0_dataarray_data_V_ce0 => open,
  memoriesME_1_dataarray_data_V_ce0 => open,
  memoriesME_2_dataarray_data_V_ce0 => open,
  memoriesME_3_dataarray_data_V_ce0 => open,
  memoriesME_4_dataarray_data_V_ce0 => open,
  memoriesME_5_dataarray_data_V_ce0 => open,
  memoriesME_6_dataarray_data_V_ce0 => open,
  memoriesME_7_dataarray_data_V_ce0 => open,
  memoriesAS_0_dataarray_data_V_we0 => writes( 0 ).valid,
  memoriesME_0_dataarray_data_V_we0 => writes( 1 ).valid,
  memoriesME_1_dataarray_data_V_we0 => writes( 2 ).valid,
  memoriesME_2_dataarray_data_V_we0 => writes( 3 ).valid,
  memoriesME_3_dataarray_data_V_we0 => writes( 4 ).valid,
  memoriesME_4_dataarray_data_V_we0 => writes( 5 ).valid,
  memoriesME_5_dataarray_data_V_we0 => writes( 6 ).valid,
  memoriesME_6_dataarray_data_V_we0 => writes( 7 ).valid,
  memoriesME_7_dataarray_data_V_we0 => writes( 8 ).valid,
  memoriesAS_0_dataarray_data_V_address0 => writes( 0 ).addr( config_memories_out( 0 ).widthAddr - 1 downto 0 ),
  memoriesME_0_dataarray_data_V_address0 => writes( 1 ).addr( config_memories_out( 1 ).widthAddr - 1 downto 0 ),
  memoriesME_1_dataarray_data_V_address0 => writes( 2 ).addr( config_memories_out( 2 ).widthAddr - 1 downto 0 ),
  memoriesME_2_dataarray_data_V_address0 => writes( 3 ).addr( config_memories_out( 3 ).widthAddr - 1 downto 0 ),
  memoriesME_3_dataarray_data_V_address0 => writes( 4 ).addr( config_memories_out( 4 ).widthAddr - 1 downto 0 ),
  memoriesME_4_dataarray_data_V_address0 => writes( 5 ).addr( config_memories_out( 5 ).widthAddr - 1 downto 0 ),
  memoriesME_5_dataarray_data_V_address0 => writes( 6 ).addr( config_memories_out( 6 ).widthAddr - 1 downto 0 ),
  memoriesME_6_dataarray_data_V_address0 => writes( 7 ).addr( config_memories_out( 7 ).widthAddr - 1 downto 0 ),
  memoriesME_7_dataarray_data_V_address0 => writes( 8 ).addr( config_memories_out( 8 ).widthAddr - 1 downto 0 ),
  memoriesAS_0_dataarray_data_V_d0 => writes( 0 ).data( config_memories_out( 0 ).widthData - 1 downto 0 ),
  memoriesME_0_dataarray_data_V_d0 => writes( 1 ).data( config_memories_out( 1 ).widthData - 1 downto 0 ),
  memoriesME_1_dataarray_data_V_d0 => writes( 2 ).data( config_memories_out( 2 ).widthData - 1 downto 0 ),
  memoriesME_2_dataarray_data_V_d0 => writes( 3 ).data( config_memories_out( 3 ).widthData - 1 downto 0 ),
  memoriesME_3_dataarray_data_V_d0 => writes( 4 ).data( config_memories_out( 4 ).widthData - 1 downto 0 ),
  memoriesME_4_dataarray_data_V_d0 => writes( 5 ).data( config_memories_out( 5 ).widthData - 1 downto 0 ),
  memoriesME_5_dataarray_data_V_d0 => writes( 6 ).data( config_memories_out( 6 ).widthData - 1 downto 0 ),
  memoriesME_6_dataarray_data_V_d0 => writes( 7 ).data( config_memories_out( 7 ).widthData - 1 downto 0 ),
  memoriesME_7_dataarray_data_V_d0 => writes( 8 ).data( config_memories_out( 8 ).widthData - 1 downto 0 )
);
end generate;
g5: if k = 5 generate
L6PHIB: entity xil_defaultlib.VMR_L6PHIB port map (
  ap_clk => clk,
  ap_rst => reset,
  ap_start => start,
  ap_done => done,
  bx_V => bxIn,
  bx_o_V => bxOut,
  ap_idle => open,
  ap_ready => open,
  bx_o_V_ap_vld => open,
  inputStubs_0_dataarray_data_V_ce0 => rout( 0 ).valid,
  inputStubs_1_dataarray_data_V_ce0 => rout( 1 ).valid,
  inputStubs_2_dataarray_data_V_ce0 => rout( 2 ).valid,
  inputStubs_0_dataarray_data_V_address0 => rout( 0 ).addr( config_memories_in( 0 ).widthAddr - 1 downto 0 ),
  inputStubs_1_dataarray_data_V_address0 => rout( 1 ).addr( config_memories_in( 1 ).widthAddr - 1 downto 0 ),
  inputStubs_2_dataarray_data_V_address0 => rout( 2 ).addr( config_memories_in( 2 ).widthAddr - 1 downto 0 ),
  inputStubs_0_dataarray_data_V_q0 => din( 0 ).data( config_memories_in( 0 ).widthData - 1 downto 0 ),
  inputStubs_1_dataarray_data_V_q0 => din( 1 ).data( config_memories_in( 1 ).widthData - 1 downto 0 ),
  inputStubs_2_dataarray_data_V_q0 => din( 2 ).data( config_memories_in( 2 ).widthData - 1 downto 0 ),
  inputStubs_0_nentries_0_V => din( 0 ).nents( 0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubs_0_nentries_1_V => din( 0 ).nents( 1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  inputStubs_1_nentries_0_V => din( 1 ).nents( 0 )( config_memories_in( 1 ).widthNent - 1 downto 0 ),
  inputStubs_1_nentries_1_V => din( 1 ).nents( 1 )( config_memories_in( 1 ).widthNent - 1 downto 0 ),
  inputStubs_2_nentries_0_V => din( 2 ).nents( 0 )( config_memories_in( 2 ).widthNent - 1 downto 0 ),
  inputStubs_2_nentries_1_V => din( 2 ).nents( 1 )( config_memories_in( 2 ).widthNent - 1 downto 0 ),
  memoriesAS_0_dataarray_data_V_ce0 => open,
  memoriesME_0_dataarray_data_V_ce0 => open,
  memoriesME_1_dataarray_data_V_ce0 => open,
  memoriesME_2_dataarray_data_V_ce0 => open,
  memoriesME_3_dataarray_data_V_ce0 => open,
  memoriesME_4_dataarray_data_V_ce0 => open,
  memoriesME_5_dataarray_data_V_ce0 => open,
  memoriesME_6_dataarray_data_V_ce0 => open,
  memoriesME_7_dataarray_data_V_ce0 => open,
  memoriesAS_0_dataarray_data_V_we0 => writes( 0 ).valid,
  memoriesME_0_dataarray_data_V_we0 => writes( 1 ).valid,
  memoriesME_1_dataarray_data_V_we0 => writes( 2 ).valid,
  memoriesME_2_dataarray_data_V_we0 => writes( 3 ).valid,
  memoriesME_3_dataarray_data_V_we0 => writes( 4 ).valid,
  memoriesME_4_dataarray_data_V_we0 => writes( 5 ).valid,
  memoriesME_5_dataarray_data_V_we0 => writes( 6 ).valid,
  memoriesME_6_dataarray_data_V_we0 => writes( 7 ).valid,
  memoriesME_7_dataarray_data_V_we0 => writes( 8 ).valid,
  memoriesAS_0_dataarray_data_V_address0 => writes( 0 ).addr( config_memories_out( 0 ).widthAddr - 1 downto 0 ),
  memoriesME_0_dataarray_data_V_address0 => writes( 1 ).addr( config_memories_out( 1 ).widthAddr - 1 downto 0 ),
  memoriesME_1_dataarray_data_V_address0 => writes( 2 ).addr( config_memories_out( 2 ).widthAddr - 1 downto 0 ),
  memoriesME_2_dataarray_data_V_address0 => writes( 3 ).addr( config_memories_out( 3 ).widthAddr - 1 downto 0 ),
  memoriesME_3_dataarray_data_V_address0 => writes( 4 ).addr( config_memories_out( 4 ).widthAddr - 1 downto 0 ),
  memoriesME_4_dataarray_data_V_address0 => writes( 5 ).addr( config_memories_out( 5 ).widthAddr - 1 downto 0 ),
  memoriesME_5_dataarray_data_V_address0 => writes( 6 ).addr( config_memories_out( 6 ).widthAddr - 1 downto 0 ),
  memoriesME_6_dataarray_data_V_address0 => writes( 7 ).addr( config_memories_out( 7 ).widthAddr - 1 downto 0 ),
  memoriesME_7_dataarray_data_V_address0 => writes( 8 ).addr( config_memories_out( 8 ).widthAddr - 1 downto 0 ),
  memoriesAS_0_dataarray_data_V_d0 => writes( 0 ).data( config_memories_out( 0 ).widthData - 1 downto 0 ),
  memoriesME_0_dataarray_data_V_d0 => writes( 1 ).data( config_memories_out( 1 ).widthData - 1 downto 0 ),
  memoriesME_1_dataarray_data_V_d0 => writes( 2 ).data( config_memories_out( 2 ).widthData - 1 downto 0 ),
  memoriesME_2_dataarray_data_V_d0 => writes( 3 ).data( config_memories_out( 3 ).widthData - 1 downto 0 ),
  memoriesME_3_dataarray_data_V_d0 => writes( 4 ).data( config_memories_out( 4 ).widthData - 1 downto 0 ),
  memoriesME_4_dataarray_data_V_d0 => writes( 5 ).data( config_memories_out( 5 ).widthData - 1 downto 0 ),
  memoriesME_5_dataarray_data_V_d0 => writes( 6 ).data( config_memories_out( 6 ).widthData - 1 downto 0 ),
  memoriesME_6_dataarray_data_V_d0 => writes( 7 ).data( config_memories_out( 7 ).widthData - 1 downto 0 ),
  memoriesME_7_dataarray_data_V_d0 => writes( 8 ).data( config_memories_out( 8 ).widthData - 1 downto 0 )
);
end generate;

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.tracklet_config.all;
use work.tracklet_data_types.all;

entity VMR_memories is
port (
  clk: in std_logic;
  memories_din: in t_writes( numOutputsVMR  - 1 downto 0 );
  memories_rin: in t_reads( numOutputsVMR  - 1 downto 0 );
  memories_dout: out t_datas( numOutputsVMR  - 1 downto 0 )
);
end;

architecture rtl of VMR_memories is

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

g: for k in 0 to numOutputsVMR - 1 generate

signal memory_din: t_write := nulll;
signal memory_read: t_read := nulll;
signal memory_dout: t_data := nulll;

begin

memory_din <= memories_din( k );
memory_read <= memories_rin( k );
memories_dout( k ) <= memory_dout;

c: tracklet_memory generic map ( sumMemOutIR + k ) port map ( clk, memory_din, memory_read, memory_dout );

end generate;

end;