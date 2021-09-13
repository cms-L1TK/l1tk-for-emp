library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.hybrid_data_formats.all;
use work.tracklet_config.all;
use work.tracklet_config_memory.all;
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

signal bx: std_logic_vector ( widthBX - 1 downto 0 ) := ( others => '0' );


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
signal writes: t_writes( numOutputs - 1 downto 0 ) := ( others => nulll );

signal counter: std_logic_vector( widthNent - 1 downto 0 ) := ( others => '0' );

begin

din <= pr_din( offsetIn + numInputs - 1 downto offsetIn );
pr_rout( offsetIn + numInputs - 1 downto offsetIn ) <= rout;

start <= pr_din( offsetIn ).start;

process ( clk ) is
begin
if rising_edge( clk ) then

  reset <= pr_din( offsetIn ).reset;
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

g0: if k = 0 generate
c: entity work.ProjectionRouterTop_L3PHIB port map ( clk, reset, start, done, open, open, bx,
  rout( 0 ).addr( config_memories_in( 0 ).widthAddr - 1 downto 0 ), rout( 0 ).valid, din( 0 ).data( config_memories_in( 0 ).RAM_WIDTH - 1 downto 0 ),
  din( 0 ).nents( 0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  open, open,
  writes( 8 ).addr( config_memories_out( 8 ).widthAddr - 1 downto 0 ), open, writes( 8 ).valid, writes( 8 ).data( config_memories_out( 8 ).RAM_WIDTH - 1 downto 0 ),
  writes( 0 ).addr( config_memories_out( 0 ).widthAddr - 1 downto 0 ), open, writes( 0 ).valid, writes( 0 ).data( config_memories_out( 0 ).RAM_WIDTH - 1 downto 0 ),
  writes( 1 ).addr( config_memories_out( 1 ).widthAddr - 1 downto 0 ), open, writes( 1 ).valid, writes( 1 ).data( config_memories_out( 1 ).RAM_WIDTH - 1 downto 0 ),
  writes( 2 ).addr( config_memories_out( 2 ).widthAddr - 1 downto 0 ), open, writes( 2 ).valid, writes( 2 ).data( config_memories_out( 2 ).RAM_WIDTH - 1 downto 0 ),
  writes( 3 ).addr( config_memories_out( 3 ).widthAddr - 1 downto 0 ), open, writes( 3 ).valid, writes( 3 ).data( config_memories_out( 3 ).RAM_WIDTH - 1 downto 0 ),
  writes( 4 ).addr( config_memories_out( 4 ).widthAddr - 1 downto 0 ), open, writes( 4 ).valid, writes( 4 ).data( config_memories_out( 4 ).RAM_WIDTH - 1 downto 0 ),
  writes( 5 ).addr( config_memories_out( 5 ).widthAddr - 1 downto 0 ), open, writes( 5 ).valid, writes( 5 ).data( config_memories_out( 5 ).RAM_WIDTH - 1 downto 0 ),
  writes( 6 ).addr( config_memories_out( 6 ).widthAddr - 1 downto 0 ), open, writes( 6 ).valid, writes( 6 ).data( config_memories_out( 6 ).RAM_WIDTH - 1 downto 0 ),
  writes( 7 ).addr( config_memories_out( 7 ).widthAddr - 1 downto 0 ), open, writes( 7 ).valid, writes( 7 ).data( config_memories_out( 7 ).RAM_WIDTH - 1 downto 0 ) );
end generate;
g1: if k = 1 generate
c: entity work.ProjectionRouterTop_L4PHIB port map ( clk, reset, start, done, open, open, bx,
  rout( 0 ).addr( config_memories_in( 0 ).widthAddr - 1 downto 0 ), rout( 0 ).valid, din( 0 ).data( config_memories_in( 0 ).RAM_WIDTH - 1 downto 0 ),
  din( 0 ).nents( 0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  open, open,
  writes( 8 ).addr( config_memories_out( 8 ).widthAddr - 1 downto 0 ), open, writes( 8 ).valid, writes( 8 ).data( config_memories_out( 8 ).RAM_WIDTH - 1 downto 0 ),
  writes( 0 ).addr( config_memories_out( 0 ).widthAddr - 1 downto 0 ), open, writes( 0 ).valid, writes( 0 ).data( config_memories_out( 0 ).RAM_WIDTH - 1 downto 0 ),
  writes( 1 ).addr( config_memories_out( 1 ).widthAddr - 1 downto 0 ), open, writes( 1 ).valid, writes( 1 ).data( config_memories_out( 1 ).RAM_WIDTH - 1 downto 0 ),
  writes( 2 ).addr( config_memories_out( 2 ).widthAddr - 1 downto 0 ), open, writes( 2 ).valid, writes( 2 ).data( config_memories_out( 2 ).RAM_WIDTH - 1 downto 0 ),
  writes( 3 ).addr( config_memories_out( 3 ).widthAddr - 1 downto 0 ), open, writes( 3 ).valid, writes( 3 ).data( config_memories_out( 3 ).RAM_WIDTH - 1 downto 0 ),
  writes( 4 ).addr( config_memories_out( 4 ).widthAddr - 1 downto 0 ), open, writes( 4 ).valid, writes( 4 ).data( config_memories_out( 4 ).RAM_WIDTH - 1 downto 0 ),
  writes( 5 ).addr( config_memories_out( 5 ).widthAddr - 1 downto 0 ), open, writes( 5 ).valid, writes( 5 ).data( config_memories_out( 5 ).RAM_WIDTH - 1 downto 0 ),
  writes( 6 ).addr( config_memories_out( 6 ).widthAddr - 1 downto 0 ), open, writes( 6 ).valid, writes( 6 ).data( config_memories_out( 6 ).RAM_WIDTH - 1 downto 0 ),
  writes( 7 ).addr( config_memories_out( 7 ).widthAddr - 1 downto 0 ), open, writes( 7 ).valid, writes( 7 ).data( config_memories_out( 7 ).RAM_WIDTH - 1 downto 0 ) );
end generate;
g2: if k = 2 generate
c: entity work.ProjectionRouterTop_L5PHIB port map ( clk, reset, start, done, open, open, bx,
  rout( 0 ).addr( config_memories_in( 0 ).widthAddr - 1 downto 0 ), rout( 0 ).valid, din( 0 ).data( config_memories_in( 0 ).RAM_WIDTH - 1 downto 0 ),
  din( 0 ).nents( 0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  open, open,
  writes( 8 ).addr( config_memories_out( 8 ).widthAddr - 1 downto 0 ), open, writes( 8 ).valid, writes( 8 ).data( config_memories_out( 8 ).RAM_WIDTH - 1 downto 0 ),
  writes( 0 ).addr( config_memories_out( 0 ).widthAddr - 1 downto 0 ), open, writes( 0 ).valid, writes( 0 ).data( config_memories_out( 0 ).RAM_WIDTH - 1 downto 0 ),
  writes( 1 ).addr( config_memories_out( 1 ).widthAddr - 1 downto 0 ), open, writes( 1 ).valid, writes( 1 ).data( config_memories_out( 1 ).RAM_WIDTH - 1 downto 0 ),
  writes( 2 ).addr( config_memories_out( 2 ).widthAddr - 1 downto 0 ), open, writes( 2 ).valid, writes( 2 ).data( config_memories_out( 2 ).RAM_WIDTH - 1 downto 0 ),
  writes( 3 ).addr( config_memories_out( 3 ).widthAddr - 1 downto 0 ), open, writes( 3 ).valid, writes( 3 ).data( config_memories_out( 3 ).RAM_WIDTH - 1 downto 0 ),
  writes( 4 ).addr( config_memories_out( 4 ).widthAddr - 1 downto 0 ), open, writes( 4 ).valid, writes( 4 ).data( config_memories_out( 4 ).RAM_WIDTH - 1 downto 0 ),
  writes( 5 ).addr( config_memories_out( 5 ).widthAddr - 1 downto 0 ), open, writes( 5 ).valid, writes( 5 ).data( config_memories_out( 5 ).RAM_WIDTH - 1 downto 0 ),
  writes( 6 ).addr( config_memories_out( 6 ).widthAddr - 1 downto 0 ), open, writes( 6 ).valid, writes( 6 ).data( config_memories_out( 6 ).RAM_WIDTH - 1 downto 0 ),
  writes( 7 ).addr( config_memories_out( 7 ).widthAddr - 1 downto 0 ), open, writes( 7 ).valid, writes( 7 ).data( config_memories_out( 7 ).RAM_WIDTH - 1 downto 0 ) );
end generate;
g3: if k = 3 generate
c: entity work.ProjectionRouterTop_L6PHIB port map ( clk, reset, start, done, open, open, bx,
  rout( 0 ).addr( config_memories_in( 0 ).widthAddr - 1 downto 0 ), rout( 0 ).valid, din( 0 ).data( config_memories_in( 0 ).RAM_WIDTH - 1 downto 0 ),
  din( 0 ).nents( 0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  open, open,
  writes( 8 ).addr( config_memories_out( 8 ).widthAddr - 1 downto 0 ), open, writes( 8 ).valid, writes( 8 ).data( config_memories_out( 8 ).RAM_WIDTH - 1 downto 0 ),
  writes( 0 ).addr( config_memories_out( 0 ).widthAddr - 1 downto 0 ), open, writes( 0 ).valid, writes( 0 ).data( config_memories_out( 0 ).RAM_WIDTH - 1 downto 0 ),
  writes( 1 ).addr( config_memories_out( 1 ).widthAddr - 1 downto 0 ), open, writes( 1 ).valid, writes( 1 ).data( config_memories_out( 1 ).RAM_WIDTH - 1 downto 0 ),
  writes( 2 ).addr( config_memories_out( 2 ).widthAddr - 1 downto 0 ), open, writes( 2 ).valid, writes( 2 ).data( config_memories_out( 2 ).RAM_WIDTH - 1 downto 0 ),
  writes( 3 ).addr( config_memories_out( 3 ).widthAddr - 1 downto 0 ), open, writes( 3 ).valid, writes( 3 ).data( config_memories_out( 3 ).RAM_WIDTH - 1 downto 0 ),
  writes( 4 ).addr( config_memories_out( 4 ).widthAddr - 1 downto 0 ), open, writes( 4 ).valid, writes( 4 ).data( config_memories_out( 4 ).RAM_WIDTH - 1 downto 0 ),
  writes( 5 ).addr( config_memories_out( 5 ).widthAddr - 1 downto 0 ), open, writes( 5 ).valid, writes( 5 ).data( config_memories_out( 5 ).RAM_WIDTH - 1 downto 0 ),
  writes( 6 ).addr( config_memories_out( 6 ).widthAddr - 1 downto 0 ), open, writes( 6 ).valid, writes( 6 ).data( config_memories_out( 6 ).RAM_WIDTH - 1 downto 0 ),
  writes( 7 ).addr( config_memories_out( 7 ).widthAddr - 1 downto 0 ), open, writes( 7 ).valid, writes( 7 ).data( config_memories_out( 7 ).RAM_WIDTH - 1 downto 0 ) );
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

memory_din <= writes( l );

memory_read <= pr_rin( offsetOut + l );

pr_dout( offsetOut + l ) <= memory_dout;

c: tracklet_memory generic map ( sumMemOutTC + offsetOut + l ) port map ( clk, memory_din, memory_read, memory_dout );

end generate;

end generate;


end;