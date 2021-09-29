library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.hybrid_data_formats.all;
use work.tracklet_config.all;
use work.tracklet_config_memory.all;
use work.tracklet_data_types.all;
use work.tracklet_components.all;


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


g: for k in 0 to numME - 1 generate

constant offsetIn: natural := sum( 0 & numNodeInputsME, 0, k );
constant offsetOut: natural := sum( 0 & numNodeOutputsME, 0, k );
constant numInputs: natural := numNodeInputsME( k );
constant numOutputs: natural := numNodeOutputsME( k );
constant config_memories_out: t_config_memories( 0 to numOutputs - 1 ) := config_memories_out( sumMemOutPR + offsetOut to sumMemOutPR + offsetOut + numOutputs - 1 );
constant config_memories_in: t_config_memories( 0 to numInputs - 1 ) := config_memories_in( sumMemInPR + offsetIn to sumMemInPR + offsetIn + numInputs - 1 );

signal din: t_datas( numInputs  - 1 downto 0 ) := ( others => nulll );
signal rout: t_reads( numInputs  - 1 downto 0 ) := ( others => nulll );

signal reset, start, done, enable: std_logic := '0';
signal bxIn, bxOut: std_logic_vector ( widthBX - 1 downto 0 ) := ( others => '0' );
signal writes: t_writes( numOutputs - 1 downto 0 ) := ( others => nulll );

signal counter: std_logic_vector( widthNent - 1 downto 0 ) := ( others => '0' );

begin

din <= me_din( offsetIn + numInputs - 1 downto offsetIn );
me_rout( offsetIn + numInputs - 1 downto offsetIn ) <= rout;

start <= me_din( offsetIn + 1 ).start;
bxIn <= me_din( offsetIn + 1 ).bx;

process ( clk ) is
begin
if rising_edge( clk ) then

  reset <= me_din( offsetIn + 1 ).reset;
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

gL3: if k < 8 generate
c: ME_L3PHIB port map ( clk, reset, start, done, open, open, bxIn, bxOut, open,
  rout( 0 ).addr( config_memories_in( 0 ).widthAddr - 1 downto 0 ), rout( 0 ).valid, din( 0 ).data( config_memories_in( 0 ).RAM_WIDTH - 1 downto 0 ),
  din( 0 ).nents(  0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents(  1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents(  2 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents(  3 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents(  4 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents(  5 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents(  6 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents(  7 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents(  8 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents(  9 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 10 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 11 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 12 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 13 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 14 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 15 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 16 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 17 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 18 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 19 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 20 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 21 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 22 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 23 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 24 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 25 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 26 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 27 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 28 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 29 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 30 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 31 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 32 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 33 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 34 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 35 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 36 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 37 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 38 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 39 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 40 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 41 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 42 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 43 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 44 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 45 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 46 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 47 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 48 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 49 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 50 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 51 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 52 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 53 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 54 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 55 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 56 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 57 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 58 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 59 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 60 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 61 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 62 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 63 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  rout( 1 ).addr( config_memories_in( 1 ).widthAddr - 1 downto 0 ), rout( 1 ).valid, din( 1 ).data( config_memories_in( 1 ).RAM_WIDTH - 1 downto 0 ),
  din( 1 ).nents( 0 )( config_memories_in( 1 ).widthNent - 1 downto 0 ), din( 1 ).nents( 1 )( config_memories_in( 1 ).widthNent - 1 downto 0 ),
  writes( 0 ).addr( config_memories_out( 0 ).widthAddr - 1 downto 0 ), open, writes( 0 ).valid, writes( 0 ).data( config_memories_out( 0 ).RAM_WIDTH - 1 downto 0 ) );
end generate;
gL4: if k >= 8 and k < 16 generate
c: ME_L4PHIB port map ( clk, reset, start, done, open, open, bxIn, bxOut, open,
  rout( 0 ).addr( config_memories_in( 0 ).widthAddr - 1 downto 0 ), rout( 0 ).valid, din( 0 ).data( config_memories_in( 0 ).RAM_WIDTH - 1 downto 0 ),
  din( 0 ).nents(  0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents(  1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents(  2 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents(  3 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents(  4 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents(  5 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents(  6 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents(  7 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents(  8 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents(  9 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 10 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 11 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 12 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 13 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 14 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 15 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 16 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 17 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 18 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 19 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 20 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 21 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 22 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 23 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 24 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 25 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 26 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 27 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 28 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 29 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 30 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 31 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 32 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 33 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 34 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 35 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 36 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 37 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 38 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 39 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 40 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 41 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 42 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 43 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 44 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 45 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 46 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 47 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 48 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 49 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 50 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 51 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 52 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 53 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 54 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 55 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 56 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 57 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 58 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 59 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 60 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 61 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 62 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 63 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  rout( 1 ).addr( config_memories_in( 1 ).widthAddr - 1 downto 0 ), rout( 1 ).valid, din( 1 ).data( config_memories_in( 1 ).RAM_WIDTH - 1 downto 0 ),
  din( 1 ).nents( 0 )( config_memories_in( 1 ).widthNent - 1 downto 0 ), din( 1 ).nents( 1 )( config_memories_in( 1 ).widthNent - 1 downto 0 ),
  writes( 0 ).addr( config_memories_out( 0 ).widthAddr - 1 downto 0 ), open, writes( 0 ).valid, writes( 0 ).data( config_memories_out( 0 ).RAM_WIDTH - 1 downto 0 ) );
end generate;
gL5: if k >= 16 and k < 24 generate
c: ME_L5PHIB port map ( clk, reset, start, done, open, open, bxIn, bxOut, open,
  rout( 0 ).addr( config_memories_in( 0 ).widthAddr - 1 downto 0 ), rout( 0 ).valid, din( 0 ).data( config_memories_in( 0 ).RAM_WIDTH - 1 downto 0 ),
  din( 0 ).nents(  0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents(  1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents(  2 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents(  3 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents(  4 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents(  5 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents(  6 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents(  7 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents(  8 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents(  9 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 10 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 11 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 12 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 13 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 14 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 15 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 16 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 17 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 18 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 19 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 20 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 21 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 22 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 23 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 24 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 25 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 26 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 27 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 28 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 29 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 30 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 31 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 32 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 33 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 34 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 35 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 36 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 37 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 38 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 39 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 40 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 41 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 42 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 43 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 44 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 45 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 46 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 47 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 48 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 49 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 50 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 51 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 52 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 53 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 54 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 55 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 56 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 57 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 58 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 59 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 60 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 61 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 62 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 63 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  rout( 1 ).addr( config_memories_in( 1 ).widthAddr - 1 downto 0 ), rout( 1 ).valid, din( 1 ).data( config_memories_in( 1 ).RAM_WIDTH - 1 downto 0 ),
  din( 1 ).nents( 0 )( config_memories_in( 1 ).widthNent - 1 downto 0 ), din( 1 ).nents( 1 )( config_memories_in( 1 ).widthNent - 1 downto 0 ),
  writes( 0 ).addr( config_memories_out( 0 ).widthAddr - 1 downto 0 ), open, writes( 0 ).valid, writes( 0 ).data( config_memories_out( 0 ).RAM_WIDTH - 1 downto 0 ) );
end generate;
gL6: if k >= 24 generate
c: ME_L6PHIB port map ( clk, reset, start, done, open, open, bxIn, bxOut, open,
  rout( 0 ).addr( config_memories_in( 0 ).widthAddr - 1 downto 0 ), rout( 0 ).valid, din( 0 ).data( config_memories_in( 0 ).RAM_WIDTH - 1 downto 0 ),
  din( 0 ).nents(  0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents(  1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents(  2 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents(  3 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents(  4 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents(  5 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents(  6 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents(  7 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents(  8 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents(  9 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 10 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 11 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 12 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 13 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 14 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 15 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 16 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 17 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 18 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 19 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 20 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 21 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 22 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 23 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 24 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 25 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 26 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 27 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 28 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 29 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 30 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 31 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 32 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 33 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 34 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 35 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 36 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 37 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 38 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 39 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 40 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 41 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 42 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 43 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 44 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 45 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 46 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 47 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 48 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 49 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 50 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 51 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 52 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 53 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 54 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 55 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 56 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 57 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 58 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 59 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 60 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 61 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 0 ).nents( 62 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 63 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  rout( 1 ).addr( config_memories_in( 1 ).widthAddr - 1 downto 0 ), rout( 1 ).valid, din( 1 ).data( config_memories_in( 1 ).RAM_WIDTH - 1 downto 0 ),
  din( 1 ).nents( 0 )( config_memories_in( 1 ).widthNent - 1 downto 0 ), din( 1 ).nents( 1 )( config_memories_in( 1 ).widthNent - 1 downto 0 ),
  writes( 0 ).addr( config_memories_out( 0 ).widthAddr - 1 downto 0 ), open, writes( 0 ).valid, writes( 0 ).data( config_memories_out( 0 ).RAM_WIDTH - 1 downto 0 ) );
end generate;

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

memory_read <= me_rin( offsetOut + l );

me_dout( offsetOut + l ) <= memory_dout;

c: tracklet_memory generic map ( sumMemOutPR + offsetOut + l ) port map ( clk, memory_din, memory_read, memory_dout );

end generate;

end generate;


end;
