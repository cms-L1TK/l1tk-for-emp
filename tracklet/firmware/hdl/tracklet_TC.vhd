library ieee;
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
signal counter: std_logic_vector( widthNent - 1 downto 0 ) := ( others => '0' );
signal bxIn, bxOut: std_logic_vector ( widthBX - 1 downto 0 ) := ( others => '0' );
signal writes: t_writes( numOutputs - 1 downto 0 ) := ( others => nulll );

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

c: entity work.TrackletCalculator_L1L2F port map ( clk, reset, start, done, open, open, bxIn,
  rout(  0 ).addr( config_memories_in(  0 ).widthAddr - 1 downto 0 ), rout(  0 ).valid, din(  0 ).data( config_memories_in(  0 ).RAM_WIDTH - 1 downto 0 ),
  rout(  1 ).addr( config_memories_in(  1 ).widthAddr - 1 downto 0 ), rout(  1 ).valid, din(  1 ).data( config_memories_in(  1 ).RAM_WIDTH - 1 downto 0 ),
  rout(  2 ).addr( config_memories_in(  2 ).widthAddr - 1 downto 0 ), rout(  2 ).valid, din(  2 ).data( config_memories_in(  2 ).RAM_WIDTH - 1 downto 0 ),
  rout(  3 ).addr( config_memories_in(  3 ).widthAddr - 1 downto 0 ), rout(  3 ).valid, din(  3 ).data( config_memories_in(  3 ).RAM_WIDTH - 1 downto 0 ),
  rout(  4 ).addr( config_memories_in(  4 ).widthAddr - 1 downto 0 ), rout(  4 ).valid, din(  4 ).data( config_memories_in(  4 ).RAM_WIDTH - 1 downto 0 ),
  rout(  5 ).addr( config_memories_in(  5 ).widthAddr - 1 downto 0 ), rout(  5 ).valid, din(  5 ).data( config_memories_in(  5 ).RAM_WIDTH - 1 downto 0 ),
  rout(  6 ).addr( config_memories_in(  6 ).widthAddr - 1 downto 0 ), rout(  6 ).valid, din(  6 ).data( config_memories_in(  6 ).RAM_WIDTH - 1 downto 0 ),
  rout(  7 ).addr( config_memories_in(  7 ).widthAddr - 1 downto 0 ), rout(  7 ).valid, din(  7 ).data( config_memories_in(  7 ).RAM_WIDTH - 1 downto 0 ),
  rout(  8 ).addr( config_memories_in(  8 ).widthAddr - 1 downto 0 ), rout(  8 ).valid, din(  8 ).data( config_memories_in(  8 ).RAM_WIDTH - 1 downto 0 ),
  rout(  9 ).addr( config_memories_in(  9 ).widthAddr - 1 downto 0 ), rout(  9 ).valid, din(  9 ).data( config_memories_in(  9 ).RAM_WIDTH - 1 downto 0 ),
  rout( 10 ).addr( config_memories_in( 10 ).widthAddr - 1 downto 0 ), rout( 10 ).valid, din( 10 ).data( config_memories_in( 10 ).RAM_WIDTH - 1 downto 0 ),
  din(  2 ).nents( 0 )( config_memories_in(  2 ).widthNent - 1 downto 0 ), din(  2 ).nents( 1 )( config_memories_in(  2 ).widthNent - 1 downto 0 ),
  din(  3 ).nents( 0 )( config_memories_in(  3 ).widthNent - 1 downto 0 ), din(  3 ).nents( 1 )( config_memories_in(  3 ).widthNent - 1 downto 0 ),
  din(  4 ).nents( 0 )( config_memories_in(  4 ).widthNent - 1 downto 0 ), din(  4 ).nents( 1 )( config_memories_in(  4 ).widthNent - 1 downto 0 ),
  din(  5 ).nents( 0 )( config_memories_in(  5 ).widthNent - 1 downto 0 ), din(  5 ).nents( 1 )( config_memories_in(  5 ).widthNent - 1 downto 0 ),
  din(  6 ).nents( 0 )( config_memories_in(  6 ).widthNent - 1 downto 0 ), din(  6 ).nents( 1 )( config_memories_in(  6 ).widthNent - 1 downto 0 ),
  din(  7 ).nents( 0 )( config_memories_in(  7 ).widthNent - 1 downto 0 ), din(  7 ).nents( 1 )( config_memories_in(  7 ).widthNent - 1 downto 0 ),
  din(  8 ).nents( 0 )( config_memories_in(  8 ).widthNent - 1 downto 0 ), din(  8 ).nents( 1 )( config_memories_in(  8 ).widthNent - 1 downto 0 ),
  din(  9 ).nents( 0 )( config_memories_in(  9 ).widthNent - 1 downto 0 ), din(  9 ).nents( 1 )( config_memories_in(  9 ).widthNent - 1 downto 0 ),
  din( 10 ).nents( 0 )( config_memories_in( 10 ).widthNent - 1 downto 0 ), din( 10 ).nents( 1 )( config_memories_in( 10 ).widthNent - 1 downto 0 ),
  bxOut, open,
  writes( 4 ).addr( config_memories_out( 4 ).widthAddr - 1 downto 0 ), open, writes( 4 ).valid, writes( 4 ).data( config_memories_out( 4 ).RAM_WIDTH - 1 downto 0 ),
  writes( 0 ).addr( config_memories_out( 0 ).widthAddr - 1 downto 0 ), open, writes( 0 ).valid, writes( 0 ).data( config_memories_out( 0 ).RAM_WIDTH - 1 downto 0 ),
  writes( 1 ).addr( config_memories_out( 1 ).widthAddr - 1 downto 0 ), open, writes( 1 ).valid, writes( 1 ).data( config_memories_out( 1 ).RAM_WIDTH - 1 downto 0 ),
  writes( 2 ).addr( config_memories_out( 2 ).widthAddr - 1 downto 0 ), open, writes( 2 ).valid, writes( 2 ).data( config_memories_out( 2 ).RAM_WIDTH - 1 downto 0 ),
  writes( 3 ).addr( config_memories_out( 3 ).widthAddr - 1 downto 0 ), open, writes( 3 ).valid, writes( 3 ).data( config_memories_out( 3 ).RAM_WIDTH - 1 downto 0 )
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
writes( l ).start <= done or enable;
writes( l ).bx <= bxOut;

memory_din <= writes( l );

memory_read <= tc_rin( offsetOut + l );

tc_dout( offsetOut + l ) <= memory_dout;

c: tracklet_memory generic map ( sumMemOutTE + offsetOut + l ) port map ( clk, memory_din, memory_read, memory_dout );

end generate;

end generate;


end;