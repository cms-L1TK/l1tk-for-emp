library ieee;
use ieee.std_logic_1164.all;
use work.tracklet_config.all;
use work.tracklet_data_types.all;

entity tracklet_IR is
port (
  clk: in std_logic;
  ir_din: in t_datas( numInputsIR  - 1 downto 0 );
  ir_rin: in t_reads( numOutputsIR  - 1 downto 0 );
  ir_rout: out t_reads( numInputsIR  - 1 downto 0 );
  ir_dout: out t_datas( numOutputsIR  - 1 downto 0 )
);
end;

architecture rtl of tracklet_IR is

signal process_din: t_datas( numInputsIR  - 1 downto 0 ) := ( others => nulll );
signal process_rout: t_reads( numInputsIR  - 1 downto 0 ) := ( others => nulll );
signal process_dout: t_writes( numOutputsIR  - 1 downto 0 ) := ( others => nulll );
component IR_process
port (
  clk: in std_logic;
  process_din: in t_datas( numInputsIR  - 1 downto 0 );
  process_rout: out t_reads( numInputsIR  - 1 downto 0 );
  process_dout: out t_writes( numOutputsIR  - 1 downto 0 )
);
end component;

signal memories_din: t_writes( numOutputsIR  - 1 downto 0 ) := ( others => nulll );
signal memories_rin: t_reads( numOutputsIR  - 1 downto 0 ) := ( others => nulll );
signal memories_dout: t_datas( numOutputsIR  - 1 downto 0 ) := ( others => nulll );
component IR_memories
port (
  clk: in std_logic;
  memories_din: in t_writes( numOutputsIR  - 1 downto 0 );
  memories_rin: in t_reads( numOutputsIR  - 1 downto 0 );
  memories_dout: out t_datas( numOutputsIR  - 1 downto 0 )
);
end component;

begin

process_din <= ir_din;
ir_rout <= process_rout;

memories_din <= process_dout;
memories_rin <= ir_rin;
ir_dout <= memories_dout;

cP: IR_process port map ( clk, process_din, process_rout, process_dout );

cM: IR_memories port map ( clk, memories_din, memories_rin, memories_dout );

end;


library xil_defaultlib;
library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.tracklet_config.all;
use work.tracklet_data_types.all;
use work.tracklet_config_memory.all;

entity IR_process is
port (
  clk: in std_logic;
  process_din: in t_datas( numInputsIR  - 1 downto 0 );
  process_rout: out t_reads( numInputsIR  - 1 downto 0 );
  process_dout: out t_writes( numOutputsIR  - 1 downto 0 )
);
end;

architecture rtl of IR_process is

signal notEmpty: std_logic := '1';

begin

process_rout <= ( others => nulll );

g: for k in 0 to numIR - 1 generate

constant offsetOut: natural := sum( 0 & numNodeOutputsIR, 0, k );
constant numOutputs: natural := numNodeOutputsIR( k );
constant config_memories: t_config_memories( 0 to numOutputs - 1 ) := config_memories_out( offsetOut to offsetOut + numOutputs - 1 );
constant link: std_logic_vector ( widthLink - 1 downto 0 ) := links( k );
constant phiBin: std_logic_vector ( widthPhiBin - 1 downto 0 ) := phiBins( k );

signal reset, start, done, enable: std_logic := '0';
signal counter: std_logic_vector( widthNent - 1 downto 0 ) := ( others => '0' );
signal bxIn, bxOut: std_logic_vector ( widthBX - 1 downto 0 ) := ( others => '0' );
signal data: std_logic_vector( r_dataDTC ) := ( others => '0' );
signal writes: t_writes( numOutputs - 1 downto 0 ) := ( others => nulll );

begin

process_dout( offsetOut + numOutputs - 1 downto offsetOut ) <= writes;

start <= process_din( k ).start;
bxIn <= process_din( k ).bx;
data  <= process_din( k ).data( r_dataDTC );

process ( clk ) is
begin
if rising_edge( clk ) then

  reset <= process_din( k ).reset;
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

gOut: for l in 0 to numOutputs - 1 generate
writes( l ).reset <= reset;
writes( l ).start <= done or enable;
writes( l ).bx <= bxOut;
end generate;

g0: if k = 0 generate
PS10G_1_A: entity xil_defaultlib.IR_PS10G_1_A port map (
  ap_clk => clk,
  ap_rst => reset,
  ap_start => start,
  ap_done => done,
  bx_V => bxIn,
  hLinkWord_V => link,
  hPhBnWord_V => phiBin,
  bx_o_V => bxOut,
  ap_idle => open,
  ap_ready => open,
  bx_o_V_ap_vld => open,
  hInputStubs_V_read => open,
  hInputStubs_V_empty_n => notEmpty,
  hInputStubs_V_dout => data,
  hOutputStubs_0_dataarray_data_V_ce0 => open,
  hOutputStubs_0_dataarray_data_V_we0 => writes( 0 ).valid,
  hOutputStubs_0_dataarray_data_V_address0 => writes( 0 ).addr( config_memories( 0 ).widthAddr - 1 downto 0 ),
  hOutputStubs_0_dataarray_data_V_d0 => writes( 0 ).data( config_memories( 0 ).widthData - 1 downto 0 )
);
end generate;

g1: if k = 1 generate
PS10G_2_A: entity xil_defaultlib.IR_PS10G_2_A port map (
  ap_clk => clk,
  ap_rst => reset,
  ap_start => start,
  ap_done => done,
  bx_V => bxIn,
  hLinkWord_V => link,
  hPhBnWord_V => phiBin,
  bx_o_V => bxOut,
  ap_idle => open,
  ap_ready => open,
  bx_o_V_ap_vld => open,
  hInputStubs_V_read => open,
  hInputStubs_V_empty_n => notEmpty,
  hInputStubs_V_dout => data,
  hOutputStubs_0_dataarray_data_V_ce0 => open,
  hOutputStubs_0_dataarray_data_V_we0 => writes( 0 ).valid,
  hOutputStubs_0_dataarray_data_V_address0 => writes( 0 ).addr( config_memories( 0 ).widthAddr - 1 downto 0 ),
  hOutputStubs_0_dataarray_data_V_d0 => writes( 0 ).data( config_memories( 0 ).widthData - 1 downto 0 )
);
end generate;

g2: if k = 2 generate
PS10G_2_B: entity xil_defaultlib.IR_PS10G_2_B port map (
  ap_clk => clk,
  ap_rst => reset,
  ap_start => start,
  ap_done => done,
  bx_V => bxIn,
  hLinkWord_V => link,
  hPhBnWord_V => phiBin,
  bx_o_V => bxOut,
  ap_idle => open,
  ap_ready => open,
  bx_o_V_ap_vld => open,
  hInputStubs_V_read => open,
  hInputStubs_V_empty_n => notEmpty,
  hInputStubs_V_dout => data,
  hOutputStubs_0_dataarray_data_V_ce0 => open,
  hOutputStubs_0_dataarray_data_V_we0 => writes( 0 ).valid,
  hOutputStubs_0_dataarray_data_V_address0 => writes( 0 ).addr( config_memories( 0 ).widthAddr - 1 downto 0 ),
  hOutputStubs_0_dataarray_data_V_d0 => writes( 0 ).data( config_memories( 0 ).widthData - 1 downto 0 )
);
end generate;

g3: if k = 3 generate
PS10G_3_A: entity xil_defaultlib.IR_PS10G_3_A port map (
  ap_clk => clk,
  ap_rst => reset,
  ap_start => start,
  ap_done => done,
  bx_V => bxIn,
  hLinkWord_V => link,
  hPhBnWord_V => phiBin,
  bx_o_V => bxOut,
  ap_idle => open,
  ap_ready => open,
  bx_o_V_ap_vld => open,
  hInputStubs_V_read => open,
  hInputStubs_V_empty_n => notEmpty,
  hInputStubs_V_dout => data,
  hOutputStubs_0_dataarray_data_V_ce0 => open,
  hOutputStubs_0_dataarray_data_V_we0 => writes( 0 ).valid,
  hOutputStubs_0_dataarray_data_V_address0 => writes( 0 ).addr( config_memories( 0 ).widthAddr - 1 downto 0 ),
  hOutputStubs_0_dataarray_data_V_d0 => writes( 0 ).data( config_memories( 0 ).widthData - 1 downto 0 )
);
end generate;

g4: if k = 4 generate
PS10G_3_B: entity xil_defaultlib.IR_PS10G_3_B port map (
  ap_clk => clk,
  ap_rst => reset,
  ap_start => start,
  ap_done => done,
  bx_V => bxIn,
  hLinkWord_V => link,
  hPhBnWord_V => phiBin,
  bx_o_V => bxOut,
  ap_idle => open,
  ap_ready => open,
  bx_o_V_ap_vld => open,
  hInputStubs_V_read => open,
  hInputStubs_V_empty_n => notEmpty,
  hInputStubs_V_dout => data,
  hOutputStubs_0_dataarray_data_V_ce0 => open,
  hOutputStubs_0_dataarray_data_V_we0 => writes( 0 ).valid,
  hOutputStubs_0_dataarray_data_V_address0 => writes( 0 ).addr( config_memories( 0 ).widthAddr - 1 downto 0 ),
  hOutputStubs_0_dataarray_data_V_d0 => writes( 0 ).data( config_memories( 0 ).widthData - 1 downto 0 )
);
end generate;

g5: if k = 5 generate
PS_1_A: entity xil_defaultlib.IR_PS_1_A port map (
  ap_clk => clk,
  ap_rst => reset,
  ap_start => start,
  ap_done => done,
  bx_V => bxIn,
  hLinkWord_V => link,
  hPhBnWord_V => phiBin,
  bx_o_V => bxOut,
  ap_idle => open,
  ap_ready => open,
  bx_o_V_ap_vld => open,
  hInputStubs_V_read => open,
  hInputStubs_V_empty_n => notEmpty,
  hInputStubs_V_dout => data,
  hOutputStubs_0_dataarray_data_V_ce0 => open,
  hOutputStubs_0_dataarray_data_V_we0 => writes( 0 ).valid,
  hOutputStubs_0_dataarray_data_V_address0 => writes( 0 ).addr( config_memories( 0 ).widthAddr - 1 downto 0 ),
  hOutputStubs_0_dataarray_data_V_d0 => writes( 0 ).data( config_memories( 0 ).widthData - 1 downto 0 )
);
end generate;

g6: if k = 6 generate
PS_2_A: entity xil_defaultlib.IR_PS_2_A port map (
  ap_clk => clk,
  ap_rst => reset,
  ap_start => start,
  ap_done => done,
  bx_V => bxIn,
  hLinkWord_V => link,
  hPhBnWord_V => phiBin,
  bx_o_V => bxOut,
  ap_idle => open,
  ap_ready => open,
  bx_o_V_ap_vld => open,
  hInputStubs_V_read => open,
  hInputStubs_V_empty_n => notEmpty,
  hInputStubs_V_dout => data,
  hOutputStubs_0_dataarray_data_V_ce0 => open,
  hOutputStubs_0_dataarray_data_V_we0 => writes( 0 ).valid,
  hOutputStubs_0_dataarray_data_V_address0 => writes( 0 ).addr( config_memories( 0 ).widthAddr - 1 downto 0 ),
  hOutputStubs_0_dataarray_data_V_d0 => writes( 0 ).data( config_memories( 0 ).widthData - 1 downto 0 )
);
end generate;

g7: if k = 7 generate
PS_2_B: entity xil_defaultlib.IR_PS_2_B port map (
  ap_clk => clk,
  ap_rst => reset,
  ap_start => start,
  ap_done => done,
  bx_V => bxIn,
  hLinkWord_V => link,
  hPhBnWord_V => phiBin,
  bx_o_V => bxOut,
  ap_idle => open,
  ap_ready => open,
  bx_o_V_ap_vld => open,
  hInputStubs_V_read => open,
  hInputStubs_V_empty_n => notEmpty,
  hInputStubs_V_dout => data,
  hOutputStubs_0_dataarray_data_V_ce0 => open,
  hOutputStubs_0_dataarray_data_V_we0 => writes( 0 ).valid,
  hOutputStubs_0_dataarray_data_V_address0 => writes( 0 ).addr( config_memories( 0 ).widthAddr - 1 downto 0 ),
  hOutputStubs_0_dataarray_data_V_d0 => writes( 0 ).data( config_memories( 0 ).widthData - 1 downto 0 )
);
end generate;

g8: if k = 8 generate
SS_1_A: entity xil_defaultlib.IR_2S_1_A port map (
  ap_clk => clk,
  ap_rst => reset,
  ap_start => start,
  ap_done => done,
  bx_V => bxIn,
  hLinkWord_V => link,
  hPhBnWord_V => phiBin,
  bx_o_V => bxOut,
  ap_idle => open,
  ap_ready => open,
  bx_o_V_ap_vld => open,
  hInputStubs_V_read => open,
  hInputStubs_V_empty_n => notEmpty,
  hInputStubs_V_dout => data,
  hOutputStubs_0_dataarray_data_V_ce0 => open,
  hOutputStubs_0_dataarray_data_V_we0 => writes( 0 ).valid,
  hOutputStubs_0_dataarray_data_V_address0 => writes( 0 ).addr( config_memories( 0 ).widthAddr - 1 downto 0 ),
  hOutputStubs_0_dataarray_data_V_d0 => writes( 0 ).data( config_memories( 0 ).widthData - 1 downto 0 )
);
end generate;

g9: if k = 9 generate
SS_1_B: entity xil_defaultlib.IR_2S_1_B port map (
  ap_clk => clk,
  ap_rst => reset,
  ap_start => start,
  ap_done => done,
  bx_V => bxIn,
  hLinkWord_V => link,
  hPhBnWord_V => phiBin,
  bx_o_V => bxOut,
  ap_idle => open,
  ap_ready => open,
  bx_o_V_ap_vld => open,
  hInputStubs_V_read => open,
  hInputStubs_V_empty_n => notEmpty,
  hInputStubs_V_dout => data,
  hOutputStubs_0_dataarray_data_V_ce0 => open,
  hOutputStubs_0_dataarray_data_V_we0 => writes( 0 ).valid,
  hOutputStubs_0_dataarray_data_V_address0 => writes( 0 ).addr( config_memories( 0 ).widthAddr - 1 downto 0 ),
  hOutputStubs_0_dataarray_data_V_d0 => writes( 0 ).data( config_memories( 0 ).widthData - 1 downto 0 )
);
end generate;

g10: if k = 10 generate
SS_2_A: entity xil_defaultlib.IR_2S_2_A port map (
  ap_clk => clk,
  ap_rst => reset,
  ap_start => start,
  ap_done => done,
  bx_V => bxIn,
  hLinkWord_V => link,
  hPhBnWord_V => phiBin,
  bx_o_V => bxOut,
  ap_idle => open,
  ap_ready => open,
  bx_o_V_ap_vld => open,
  hInputStubs_V_read => open,
  hInputStubs_V_empty_n => notEmpty,
  hInputStubs_V_dout => data,
  hOutputStubs_0_dataarray_data_V_ce0 => open,
  hOutputStubs_0_dataarray_data_V_we0 => writes( 0 ).valid,
  hOutputStubs_0_dataarray_data_V_address0 => writes( 0 ).addr( config_memories( 0 ).widthAddr - 1 downto 0 ),
  hOutputStubs_0_dataarray_data_V_d0 => writes( 0 ).data( config_memories( 0 ).widthData - 1 downto 0 )
);
end generate;

g11: if k = 11 generate
SS_2_B: entity xil_defaultlib.IR_2S_2_B port map (
  ap_clk => clk,
  ap_rst => reset,
  ap_start => start,
  ap_done => done,
  bx_V => bxIn,
  hLinkWord_V => link,
  hPhBnWord_V => phiBin,
  bx_o_V => bxOut,
  ap_idle => open,
  ap_ready => open,
  bx_o_V_ap_vld => open,
  hInputStubs_V_read => open,
  hInputStubs_V_empty_n => notEmpty,
  hInputStubs_V_dout => data,
  hOutputStubs_0_dataarray_data_V_ce0 => open,
  hOutputStubs_0_dataarray_data_V_we0 => writes( 0 ).valid,
  hOutputStubs_0_dataarray_data_V_address0 => writes( 0 ).addr( config_memories( 0 ).widthAddr - 1 downto 0 ),
  hOutputStubs_0_dataarray_data_V_d0 => writes( 0 ).data( config_memories( 0 ).widthData - 1 downto 0 )
);
end generate;

g12: if k = 12 generate
SS_3_A: entity xil_defaultlib.IR_2S_3_A port map (
  ap_clk => clk,
  ap_rst => reset,
  ap_start => start,
  ap_done => done,
  bx_V => bxIn,
  hLinkWord_V => link,
  hPhBnWord_V => phiBin,
  bx_o_V => bxOut,
  ap_idle => open,
  ap_ready => open,
  bx_o_V_ap_vld => open,
  hInputStubs_V_read => open,
  hInputStubs_V_empty_n => notEmpty,
  hInputStubs_V_dout => data,
  hOutputStubs_0_dataarray_data_V_ce0 => open,
  hOutputStubs_0_dataarray_data_V_we0 => writes( 0 ).valid,
  hOutputStubs_0_dataarray_data_V_address0 => writes( 0 ).addr( config_memories( 0 ).widthAddr - 1 downto 0 ),
  hOutputStubs_0_dataarray_data_V_d0 => writes( 0 ).data( config_memories( 0 ).widthData - 1 downto 0 )
);
end generate;

g13: if k = 13 generate
SS_4_A: entity xil_defaultlib.IR_2S_4_A port map (
  ap_clk => clk,
  ap_rst => reset,
  ap_start => start,
  ap_done => done,
  bx_V => bxIn,
  hLinkWord_V => link,
  hPhBnWord_V => phiBin,
  bx_o_V => bxOut,
  ap_idle => open,
  ap_ready => open,
  bx_o_V_ap_vld => open,
  hInputStubs_V_read => open,
  hInputStubs_V_empty_n => notEmpty,
  hInputStubs_V_dout => data,
  hOutputStubs_0_dataarray_data_V_ce0 => open,
  hOutputStubs_0_dataarray_data_V_we0 => writes( 0 ).valid,
  hOutputStubs_0_dataarray_data_V_address0 => writes( 0 ).addr( config_memories( 0 ).widthAddr - 1 downto 0 ),
  hOutputStubs_0_dataarray_data_V_d0 => writes( 0 ).data( config_memories( 0 ).widthData - 1 downto 0 )
);
end generate;

g14: if k = 14 generate
SS_4_B: entity xil_defaultlib.IR_2S_4_B port map (
  ap_clk => clk,
  ap_rst => reset,
  ap_start => start,
  ap_done => done,
  bx_V => bxIn,
  hLinkWord_V => link,
  hPhBnWord_V => phiBin,
  bx_o_V => bxOut,
  ap_idle => open,
  ap_ready => open,
  bx_o_V_ap_vld => open,
  hInputStubs_V_read => open,
  hInputStubs_V_empty_n => notEmpty,
  hInputStubs_V_dout => data,
  hOutputStubs_0_dataarray_data_V_ce0 => open,
  hOutputStubs_0_dataarray_data_V_we0 => writes( 0 ).valid,
  hOutputStubs_0_dataarray_data_V_address0 => writes( 0 ).addr( config_memories( 0 ).widthAddr - 1 downto 0 ),
  hOutputStubs_0_dataarray_data_V_d0 => writes( 0 ).data( config_memories( 0 ).widthData - 1 downto 0 )
);
end generate;

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.tracklet_config.all;
use work.tracklet_data_types.all;

entity IR_memories is
port (
  clk: in std_logic;
  memories_din: in t_writes( numOutputsIR  - 1 downto 0 );
  memories_rin: in t_reads( numOutputsIR  - 1 downto 0 );
  memories_dout: out t_datas( numOutputsIR  - 1 downto 0 )
);
end;

architecture rtl of IR_memories is

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

g: for k in 0 to numOutputsIR - 1 generate

signal memory_din: t_write := nulll;
signal memory_read: t_read := nulll;
signal memory_dout: t_data := nulll;

begin

memory_din <= memories_din( k );
memory_read <= memories_rin( k );
memories_dout( k ) <= memory_dout;

c: tracklet_memory generic map ( k ) port map ( clk, memory_din, memory_read, memory_dout );

end generate;

end;