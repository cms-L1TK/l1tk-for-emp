library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.hybrid_data_formats.all;
use work.tracklet_config.all;
use work.tracklet_data_types.all;
use work.tracklet_config_memory.all;
use work.tracklet_components.all;


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

signal notEmpty: std_logic := '1';


begin


ir_rout <= ( others => nulll );

g: for k in 0 to numIR - 1 generate

constant offsetOut: natural := sum( 0 & numNodeOutputsIR, 0, k );
constant numOutputs: natural := numNodeOutputsIR( k );
constant config_memories: t_config_memories( 0 to numOutputs - 1 ) := config_memories_out( offsetOut to offsetOut + numOutputs - 1 );
constant link: std_logic_vector ( widthLink - 1 downto 0 ) := links( k );
constant phiBin: std_logic_vector ( widthPhiBin - 1 downto 0 ) := phiBins( k );

signal reset, start, done, enable: std_logic := '0';
signal bxIn, bxOut: std_logic_vector ( widthBX - 1 downto 0 ) := ( others => '0' );
signal data: std_logic_vector( r_dataDTC ) := ( others => '0' );
signal writes: t_writes( numOutputs - 1 downto 0 ) := ( others => nulll );

signal counter: std_logic_vector( widthNent - 1 downto 0 ) := ( others => '0' );

begin

start <= ir_din( k ).start;
bxIn <= ir_din( k ).bx;
data  <= ir_din( k ).data( r_dataDTC );

process ( clk ) is
begin
if rising_edge( clk ) then

  reset <= ir_din( k ).reset;
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

g0: if k = 0 generate
c: IR_PS10G_1_A port map ( clk, reset, start, done, open, open, data, notEmpty, open,
  bxIn, link, phiBin, bxOut, open, writes( 0 ).addr( config_memories( 0 ).widthAddr - 1 downto 0 ),
  open, writes( 0 ).valid, writes( 0 ).data( config_memories( 0 ).RAM_WIDTH - 1 downto 0 ) );
end generate;

g1: if k = 1 generate
c: IR_PS10G_2_A port map ( clk, reset, start, done, open, open, data, notEmpty, open,
  bxIn, link, phiBin, bxOut, open, writes( 0 ).addr( config_memories( 0 ).widthAddr - 1 downto 0 ),
  open, writes( 0 ).valid, writes( 0 ).data( config_memories( 0 ).RAM_WIDTH - 1 downto 0 ) );
end generate;

g2: if k = 2 generate
c: IR_PS10G_2_B port map ( clk, reset, start, done, open, open, data, notEmpty, open,
  bxIn, link, phiBin, bxOut, open, writes( 0 ).addr( config_memories( 0 ).widthAddr - 1 downto 0 ),
  open, writes( 0 ).valid, writes( 0 ).data( config_memories( 0 ).RAM_WIDTH - 1 downto 0 ) );
end generate;

g3: if k = 3 generate
c: IR_PS10G_3_A port map ( clk, reset, start, done, open, open, data, notEmpty, open,
  bxIn, link, phiBin, bxOut, open, writes( 0 ).addr( config_memories( 0 ).widthAddr - 1 downto 0 ),
  open, writes( 0 ).valid, writes( 0 ).data( config_memories( 0 ).RAM_WIDTH - 1 downto 0 ) );
end generate;

g4: if k = 4 generate
c: IR_PS10G_3_B port map ( clk, reset, start, done, open, open, data, notEmpty, open,
  bxIn, link, phiBin, bxOut, open, writes( 0 ).addr( config_memories( 0 ).widthAddr - 1 downto 0 ),
  open, writes( 0 ).valid, writes( 0 ).data( config_memories( 0 ).RAM_WIDTH - 1 downto 0 ) );
end generate;

g5: if k = 5 generate
c: IR_PS_1_A port map ( clk, reset, start, done, open, open, data, notEmpty, open,
  bxIn, link, phiBin, bxOut, open, writes( 0 ).addr( config_memories( 0 ).widthAddr - 1 downto 0 ),
  open, writes( 0 ).valid, writes( 0 ).data( config_memories( 0 ).RAM_WIDTH - 1 downto 0 ) );
end generate;

g6: if k = 6 generate
c: IR_PS_1_B port map ( clk, reset, start, done, open, open, data, notEmpty, open,
  bxIn, link, phiBin, bxOut, open, writes( 0 ).addr( config_memories( 0 ).widthAddr - 1 downto 0 ),
  open, writes( 0 ).valid, writes( 0 ).data( config_memories( 0 ).RAM_WIDTH - 1 downto 0 ) );
end generate;

g7: if k = 7 generate
c: IR_PS_2_A port map ( clk, reset, start, done, open, open, data, notEmpty, open,
  bxIn, link, phiBin, bxOut, open, writes( 0 ).addr( config_memories( 0 ).widthAddr - 1 downto 0 ),
  open, writes( 0 ).valid, writes( 0 ).data( config_memories( 0 ).RAM_WIDTH - 1 downto 0 ) );
end generate;

g8: if k = 8 generate
c: IR_PS_2_B port map ( clk, reset, start, done, open, open, data, notEmpty, open,
  bxIn, link, phiBin, bxOut, open, writes( 0 ).addr( config_memories( 0 ).widthAddr - 1 downto 0 ),
  open, writes( 0 ).valid, writes( 0 ).data( config_memories( 0 ).RAM_WIDTH - 1 downto 0 ) );
end generate;

g9: if k = 9 generate
c: IR_2S_1_A port map ( clk, reset, start, done, open, open, data, notEmpty, open,
  bxIn, link, phiBin, bxOut, open, writes( 0 ).addr( config_memories( 0 ).widthAddr - 1 downto 0 ), open,
  writes( 0 ).valid, writes( 0 ).data( config_memories( 0 ).RAM_WIDTH - 1 downto 0 ),
  writes( 1 ).addr( config_memories( 1 ).widthAddr - 1 downto 0 ), open,
  writes( 1 ).valid, writes( 1 ).data( config_memories( 1 ).RAM_WIDTH - 1 downto 0 ) );
end generate;

g10: if k = 10 generate
c: IR_2S_1_B port map ( clk, reset, start, done, open, open, data, notEmpty, open,
  bxIn, link, phiBin, bxOut, open, writes( 0 ).addr( config_memories( 0 ).widthAddr - 1 downto 0 ),
  open, writes( 0 ).valid, writes( 0 ).data( config_memories( 0 ).RAM_WIDTH - 1 downto 0 ) );
end generate;

g11: if k = 11 generate
c: IR_2S_2_A port map ( clk, reset, start, done, open, open, data, notEmpty, open,
  bxIn, link, phiBin, bxOut, open, writes( 0 ).addr( config_memories( 0 ).widthAddr - 1 downto 0 ),
  open, writes( 0 ).valid, writes( 0 ).data( config_memories( 0 ).RAM_WIDTH - 1 downto 0 ) );
end generate;

g12: if k = 12 generate
c: IR_2S_2_B port map ( clk, reset, start, done, open, open, data, notEmpty, open,
  bxIn, link, phiBin, bxOut, open, writes( 0 ).addr( config_memories( 0 ).widthAddr - 1 downto 0 ),
  open, writes( 0 ).valid, writes( 0 ).data( config_memories( 0 ).RAM_WIDTH - 1 downto 0 ) );
end generate;

g13: if k = 13 generate
c: IR_2S_3_A port map ( clk, reset, start, done, open, open, data, notEmpty, open,
  bxIn, link, phiBin, bxOut, open, writes( 0 ).addr( config_memories( 0 ).widthAddr - 1 downto 0 ),
  open, writes( 0 ).valid, writes( 0 ).data( config_memories( 0 ).RAM_WIDTH - 1 downto 0 ) );
end generate;

g14: if k = 14 generate
c: IR_2S_3_B port map ( clk, reset, start, done, open, open, data, notEmpty, open,
  bxIn, link, phiBin, bxOut, open, writes( 0 ).addr( config_memories( 0 ).widthAddr - 1 downto 0 ),
  open, writes( 0 ).valid, writes( 0 ).data( config_memories( 0 ).RAM_WIDTH - 1 downto 0 ) );
end generate;

g15: if k = 15 generate
c: IR_2S_4_A port map ( clk, reset, start, done, open, open, data, notEmpty, open,
  bxIn, link, phiBin, bxOut, open, writes( 0 ).addr( config_memories( 0 ).widthAddr - 1 downto 0 ),
  open, writes( 0 ).valid, writes( 0 ).data( config_memories( 0 ).RAM_WIDTH - 1 downto 0 ) );
end generate;

g16: if k = 16 generate
c: IR_2S_4_B port map ( clk, reset, start, done, open, open, data, notEmpty, open,
  bxIn, link, phiBin, bxOut, open, writes( 0 ).addr( config_memories( 0 ).widthAddr - 1 downto 0 ),
  open, writes( 0 ).valid, writes( 0 ).data( config_memories( 0 ).RAM_WIDTH - 1 downto 0 ) );
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

memory_read <= ir_rin( offsetOut + l );

ir_dout( offsetOut + l ) <= memory_dout;

c: tracklet_memory generic map ( offsetOut + l ) port map ( clk, memory_din, memory_read, memory_dout );

end generate;

end generate;

end;
