library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.hybrid_data_formats.all;
use work.tracklet_config.all;
use work.tracklet_data_types.all;
use work.tracklet_config_memory.all;


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
signal writes: t_writes( numOutputs - 1 downto 0 ) := ( others => nulll );

signal counter: std_logic_vector( widthNent - 1 downto 0 ) := ( others => '0' );

begin

din <= vmr_din( offsetIn + numInputs - 1 downto offsetIn );
vmr_rout( offsetIn + numInputs - 1 downto offsetIn ) <= rout;

start <= vmr_din( offsetIn ).start;

process ( clk ) is
begin
if rising_edge( clk ) then

  reset <= vmr_din( offsetIn ).reset;
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
c: entity work.VMRouterTop_L1PHID port map ( clk, reset, start, done, open, open, bx, open, open,
  rout( 0 ).addr( config_memories_in( 0 ).widthAddr - 1 downto 0 ), rout( 0 ).valid, din( 0 ).data( config_memories_in( 0 ).RAM_WIDTH - 1 downto 0 ),
  rout( 1 ).addr( config_memories_in( 1 ).widthAddr - 1 downto 0 ), rout( 1 ).valid, din( 1 ).data( config_memories_in( 1 ).RAM_WIDTH - 1 downto 0 ),
  rout( 2 ).addr( config_memories_in( 2 ).widthAddr - 1 downto 0 ), rout( 2 ).valid, din( 2 ).data( config_memories_in( 2 ).RAM_WIDTH - 1 downto 0 ),
  din( 0 ).nents( 0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 1 ).nents( 0 )( config_memories_in( 1 ).widthNent - 1 downto 0 ), din( 1 ).nents( 1 )( config_memories_in( 1 ).widthNent - 1 downto 0 ),
  din( 2 ).nents( 0 )( config_memories_in( 2 ).widthNent - 1 downto 0 ), din( 2 ).nents( 1 )( config_memories_in( 2 ).widthNent - 1 downto 0 ),
  writes( 0 ).addr( config_memories_out( 0 ).widthAddr - 1 downto 0 ), open, writes( 0 ).valid, writes( 0 ).data( config_memories_out( 0 ).RAM_WIDTH - 1 downto 0 ),
  writes( 1 ).addr( config_memories_out( 1 ).widthAddr - 1 downto 0 ), open, writes( 1 ).valid, writes( 1 ).data( config_memories_out( 1 ).RAM_WIDTH - 1 downto 0 ),
  writes( 2 ).addr( config_memories_out( 2 ).widthAddr - 1 downto 0 ), open, writes( 2 ).valid, writes( 2 ).data( config_memories_out( 2 ).RAM_WIDTH - 1 downto 0 ),
  open, open, open, open,
  open, open, open, open,
  writes( 3 ).addr( config_memories_out( 3 ).widthAddr - 1 downto 0 ), open, writes( 3 ).valid, writes( 3 ).data( config_memories_out( 3 ).RAM_WIDTH - 1 downto 0 ),
  writes( 4 ).addr( config_memories_out( 4 ).widthAddr - 1 downto 0 ), open, writes( 4 ).valid, writes( 4 ).data( config_memories_out( 4 ).RAM_WIDTH - 1 downto 0 ),
  writes( 5 ).addr( config_memories_out( 5 ).widthAddr - 1 downto 0 ), open, writes( 5 ).valid, writes( 5 ).data( config_memories_out( 5 ).RAM_WIDTH - 1 downto 0 ),
  writes( 6 ).addr( config_memories_out( 6 ).widthAddr - 1 downto 0 ), open, writes( 6 ).valid, writes( 6 ).data( config_memories_out( 6 ).RAM_WIDTH - 1 downto 0 ),
  writes( 7 ).addr( config_memories_out( 7 ).widthAddr - 1 downto 0 ), open, writes( 7 ).valid, writes( 7 ).data( config_memories_out( 7 ).RAM_WIDTH - 1 downto 0 ),
  writes( 8 ).addr( config_memories_out( 8 ).widthAddr - 1 downto 0 ), open, writes( 8 ).valid, writes( 8 ).data( config_memories_out( 8 ).RAM_WIDTH - 1 downto 0 ),
  writes( 9 ).addr( config_memories_out( 9 ).widthAddr - 1 downto 0 ), open, writes( 9 ).valid, writes( 9 ).data( config_memories_out( 9 ).RAM_WIDTH - 1 downto 0 ),
  open, open, open, open,
  open, open, open, open,
  open, open, open, open,
  open, open, open, open,
  open, open, open, open );
end generate;
g1: if k = 1 generate
c: entity work.VMRouterTop_L2PHIB port map ( clk, reset, start, done, open, open, bx, open, open,
  rout( 0 ).addr( config_memories_in( 0 ).widthAddr - 1 downto 0 ), rout( 0 ).valid, din( 0 ).data( config_memories_in( 0 ).RAM_WIDTH - 1 downto 0 ),
  rout( 1 ).addr( config_memories_in( 1 ).widthAddr - 1 downto 0 ), rout( 1 ).valid, din( 1 ).data( config_memories_in( 1 ).RAM_WIDTH - 1 downto 0 ),
  din( 0 ).nents( 0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 1 ).nents( 0 )( config_memories_in( 1 ).widthNent - 1 downto 0 ), din( 1 ).nents( 1 )( config_memories_in( 1 ).widthNent - 1 downto 0 ),
  writes( 0 ).addr( config_memories_out( 0 ).widthAddr - 1 downto 0 ), open, writes( 0 ).valid, writes( 0 ).data( config_memories_out( 0 ).RAM_WIDTH - 1 downto 0 ),
  writes( 1 ).addr( config_memories_out( 1 ).widthAddr - 1 downto 0 ), open, writes( 1 ).valid, writes( 1 ).data( config_memories_out( 1 ).RAM_WIDTH - 1 downto 0 ),
  open, open, open, open,
  open, open, open, open,
  writes( 2 ).addr( config_memories_out( 2 ).widthAddr - 1 downto 0 ), open, writes( 2 ).valid, writes( 2 ).data( config_memories_out( 2 ).RAM_WIDTH - 1 downto 0 ),
  writes( 3 ).addr( config_memories_out( 3 ).widthAddr - 1 downto 0 ), open, writes( 3 ).valid, writes( 3 ).data( config_memories_out( 3 ).RAM_WIDTH - 1 downto 0 ),
  open, open, open, open,
  writes( 4 ).addr( config_memories_out( 4 ).widthAddr - 1 downto 0 ), open, writes( 4 ).valid, writes( 4 ).data( config_memories_out( 4 ).RAM_WIDTH - 1 downto 0 ),
  writes( 5 ).addr( config_memories_out( 5 ).widthAddr - 1 downto 0 ), open, writes( 5 ).valid, writes( 5 ).data( config_memories_out( 5 ).RAM_WIDTH - 1 downto 0 ),
  writes( 6 ).addr( config_memories_out( 6 ).widthAddr - 1 downto 0 ), open, writes( 6 ).valid, writes( 6 ).data( config_memories_out( 6 ).RAM_WIDTH - 1 downto 0 ),
  writes( 7 ).addr( config_memories_out( 7 ).widthAddr - 1 downto 0 ), open, writes( 7 ).valid, writes( 7 ).data( config_memories_out( 7 ).RAM_WIDTH - 1 downto 0 ),
  writes( 8 ).addr( config_memories_out( 8 ).widthAddr - 1 downto 0 ), open, writes( 8 ).valid, writes( 8 ).data( config_memories_out( 8 ).RAM_WIDTH - 1 downto 0 ),
  writes( 9 ).addr( config_memories_out( 9 ).widthAddr - 1 downto 0 ), open, writes( 9 ).valid, writes( 9 ).data( config_memories_out( 9 ).RAM_WIDTH - 1 downto 0 ),
  open, open, open, open,
  open, open, open, open,
  open, open, open, open,
  open, open, open, open,
  open, open, open, open,
  open, open, open, open,
  open, open, open, open,
  open, open, open, open,
  open, open, open, open,
  open, open, open, open,
  open, open, open, open,
  open, open, open, open );
end generate;
g2: if k = 2 generate
c: entity work.VMRouterTop_L3PHIB port map ( clk, reset, start, done, open, open, bx, open, open,
  rout( 0 ).addr( config_memories_in( 0 ).widthAddr - 1 downto 0 ), rout( 0 ).valid, din( 0 ).data( config_memories_in( 0 ).RAM_WIDTH - 1 downto 0 ),
  rout( 1 ).addr( config_memories_in( 1 ).widthAddr - 1 downto 0 ), rout( 1 ).valid, din( 1 ).data( config_memories_in( 1 ).RAM_WIDTH - 1 downto 0 ),
  rout( 2 ).addr( config_memories_in( 2 ).widthAddr - 1 downto 0 ), rout( 2 ).valid, din( 2 ).data( config_memories_in( 2 ).RAM_WIDTH - 1 downto 0 ),
  rout( 3 ).addr( config_memories_in( 3 ).widthAddr - 1 downto 0 ), rout( 3 ).valid, din( 3 ).data( config_memories_in( 3 ).RAM_WIDTH - 1 downto 0 ),
  din( 0 ).nents( 0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 1 ).nents( 0 )( config_memories_in( 1 ).widthNent - 1 downto 0 ), din( 1 ).nents( 1 )( config_memories_in( 1 ).widthNent - 1 downto 0 ),
  din( 2 ).nents( 0 )( config_memories_in( 2 ).widthNent - 1 downto 0 ), din( 2 ).nents( 1 )( config_memories_in( 2 ).widthNent - 1 downto 0 ),
  din( 3 ).nents( 0 )( config_memories_in( 3 ).widthNent - 1 downto 0 ), din( 3 ).nents( 1 )( config_memories_in( 3 ).widthNent - 1 downto 0 ),
  writes( 0 ).addr( config_memories_out( 0 ).widthAddr - 1 downto 0 ), open, writes( 0 ).valid, writes( 0 ).data( config_memories_out( 0 ).RAM_WIDTH - 1 downto 0 ),
  writes( 1 ).addr( config_memories_out( 1 ).widthAddr - 1 downto 0 ), open, writes( 1 ).valid, writes( 1 ).data( config_memories_out( 1 ).RAM_WIDTH - 1 downto 0 ),
  writes( 2 ).addr( config_memories_out( 2 ).widthAddr - 1 downto 0 ), open, writes( 2 ).valid, writes( 2 ).data( config_memories_out( 2 ).RAM_WIDTH - 1 downto 0 ),
  writes( 3 ).addr( config_memories_out( 3 ).widthAddr - 1 downto 0 ), open, writes( 3 ).valid, writes( 3 ).data( config_memories_out( 3 ).RAM_WIDTH - 1 downto 0 ),
  writes( 4 ).addr( config_memories_out( 4 ).widthAddr - 1 downto 0 ), open, writes( 4 ).valid, writes( 4 ).data( config_memories_out( 4 ).RAM_WIDTH - 1 downto 0 ),
  writes( 5 ).addr( config_memories_out( 5 ).widthAddr - 1 downto 0 ), open, writes( 5 ).valid, writes( 5 ).data( config_memories_out( 5 ).RAM_WIDTH - 1 downto 0 ),
  writes( 6 ).addr( config_memories_out( 6 ).widthAddr - 1 downto 0 ), open, writes( 6 ).valid, writes( 6 ).data( config_memories_out( 6 ).RAM_WIDTH - 1 downto 0 ),
  writes( 7 ).addr( config_memories_out( 7 ).widthAddr - 1 downto 0 ), open, writes( 7 ).valid, writes( 7 ).data( config_memories_out( 7 ).RAM_WIDTH - 1 downto 0 ),
  writes( 8 ).addr( config_memories_out( 8 ).widthAddr - 1 downto 0 ), open, writes( 8 ).valid, writes( 8 ).data( config_memories_out( 8 ).RAM_WIDTH - 1 downto 0 ) );
end generate;
g3: if k = 3 generate
c: entity work.VMRouterTop_L4PHIB port map ( clk, reset, start, done, open, open, bx, open, open,
  rout( 0 ).addr( config_memories_in( 0 ).widthAddr - 1 downto 0 ), rout( 0 ).valid, din( 0 ).data( config_memories_in( 0 ).RAM_WIDTH - 1 downto 0 ),
  rout( 1 ).addr( config_memories_in( 1 ).widthAddr - 1 downto 0 ), rout( 1 ).valid, din( 1 ).data( config_memories_in( 1 ).RAM_WIDTH - 1 downto 0 ),
  din( 0 ).nents( 0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 1 ).nents( 0 )( config_memories_in( 1 ).widthNent - 1 downto 0 ), din( 1 ).nents( 1 )( config_memories_in( 1 ).widthNent - 1 downto 0 ),
  writes( 0 ).addr( config_memories_out( 0 ).widthAddr - 1 downto 0 ), open, writes( 0 ).valid, writes( 0 ).data( config_memories_out( 0 ).RAM_WIDTH - 1 downto 0 ),
  writes( 1 ).addr( config_memories_out( 1 ).widthAddr - 1 downto 0 ), open, writes( 1 ).valid, writes( 1 ).data( config_memories_out( 1 ).RAM_WIDTH - 1 downto 0 ),
  writes( 2 ).addr( config_memories_out( 2 ).widthAddr - 1 downto 0 ), open, writes( 2 ).valid, writes( 2 ).data( config_memories_out( 2 ).RAM_WIDTH - 1 downto 0 ),
  writes( 3 ).addr( config_memories_out( 3 ).widthAddr - 1 downto 0 ), open, writes( 3 ).valid, writes( 3 ).data( config_memories_out( 3 ).RAM_WIDTH - 1 downto 0 ),
  writes( 4 ).addr( config_memories_out( 4 ).widthAddr - 1 downto 0 ), open, writes( 4 ).valid, writes( 4 ).data( config_memories_out( 4 ).RAM_WIDTH - 1 downto 0 ),
  writes( 5 ).addr( config_memories_out( 5 ).widthAddr - 1 downto 0 ), open, writes( 5 ).valid, writes( 5 ).data( config_memories_out( 5 ).RAM_WIDTH - 1 downto 0 ),
  writes( 6 ).addr( config_memories_out( 6 ).widthAddr - 1 downto 0 ), open, writes( 6 ).valid, writes( 6 ).data( config_memories_out( 6 ).RAM_WIDTH - 1 downto 0 ),
  writes( 7 ).addr( config_memories_out( 7 ).widthAddr - 1 downto 0 ), open, writes( 7 ).valid, writes( 7 ).data( config_memories_out( 7 ).RAM_WIDTH - 1 downto 0 ),
  writes( 8 ).addr( config_memories_out( 8 ).widthAddr - 1 downto 0 ), open, writes( 8 ).valid, writes( 8 ).data( config_memories_out( 8 ).RAM_WIDTH - 1 downto 0 ) );
end generate;
g4: if k = 4 generate
c: entity work.VMRouterTop_L5PHIB port map ( clk, reset, start, done, open, open, bx, open, open,
  rout( 0 ).addr( config_memories_in( 0 ).widthAddr - 1 downto 0 ), rout( 0 ).valid, din( 0 ).data( config_memories_in( 0 ).RAM_WIDTH - 1 downto 0 ),
  rout( 1 ).addr( config_memories_in( 1 ).widthAddr - 1 downto 0 ), rout( 1 ).valid, din( 1 ).data( config_memories_in( 1 ).RAM_WIDTH - 1 downto 0 ),
  rout( 2 ).addr( config_memories_in( 2 ).widthAddr - 1 downto 0 ), rout( 2 ).valid, din( 2 ).data( config_memories_in( 2 ).RAM_WIDTH - 1 downto 0 ),
  din( 0 ).nents( 0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 1 ).nents( 0 )( config_memories_in( 1 ).widthNent - 1 downto 0 ), din( 1 ).nents( 1 )( config_memories_in( 1 ).widthNent - 1 downto 0 ),
  din( 2 ).nents( 0 )( config_memories_in( 2 ).widthNent - 1 downto 0 ), din( 2 ).nents( 1 )( config_memories_in( 2 ).widthNent - 1 downto 0 ),
  writes( 0 ).addr( config_memories_out( 0 ).widthAddr - 1 downto 0 ), open, writes( 0 ).valid, writes( 0 ).data( config_memories_out( 0 ).RAM_WIDTH - 1 downto 0 ),
  writes( 1 ).addr( config_memories_out( 1 ).widthAddr - 1 downto 0 ), open, writes( 1 ).valid, writes( 1 ).data( config_memories_out( 1 ).RAM_WIDTH - 1 downto 0 ),
  writes( 2 ).addr( config_memories_out( 2 ).widthAddr - 1 downto 0 ), open, writes( 2 ).valid, writes( 2 ).data( config_memories_out( 2 ).RAM_WIDTH - 1 downto 0 ),
  writes( 3 ).addr( config_memories_out( 3 ).widthAddr - 1 downto 0 ), open, writes( 3 ).valid, writes( 3 ).data( config_memories_out( 3 ).RAM_WIDTH - 1 downto 0 ),
  writes( 4 ).addr( config_memories_out( 4 ).widthAddr - 1 downto 0 ), open, writes( 4 ).valid, writes( 4 ).data( config_memories_out( 4 ).RAM_WIDTH - 1 downto 0 ),
  writes( 5 ).addr( config_memories_out( 5 ).widthAddr - 1 downto 0 ), open, writes( 5 ).valid, writes( 5 ).data( config_memories_out( 5 ).RAM_WIDTH - 1 downto 0 ),
  writes( 6 ).addr( config_memories_out( 6 ).widthAddr - 1 downto 0 ), open, writes( 6 ).valid, writes( 6 ).data( config_memories_out( 6 ).RAM_WIDTH - 1 downto 0 ),
  writes( 7 ).addr( config_memories_out( 7 ).widthAddr - 1 downto 0 ), open, writes( 7 ).valid, writes( 7 ).data( config_memories_out( 7 ).RAM_WIDTH - 1 downto 0 ),
  writes( 8 ).addr( config_memories_out( 8 ).widthAddr - 1 downto 0 ), open, writes( 8 ).valid, writes( 8 ).data( config_memories_out( 8 ).RAM_WIDTH - 1 downto 0 ) );
end generate;
g5: if k = 5 generate
c: entity work.VMRouterTop_L6PHIB port map ( clk, reset, start, done, open, open, bx, open, open,
  rout( 0 ).addr( config_memories_in( 0 ).widthAddr - 1 downto 0 ), rout( 0 ).valid, din( 0 ).data( config_memories_in( 0 ).RAM_WIDTH - 1 downto 0 ),
  rout( 1 ).addr( config_memories_in( 1 ).widthAddr - 1 downto 0 ), rout( 1 ).valid, din( 1 ).data( config_memories_in( 1 ).RAM_WIDTH - 1 downto 0 ),
  rout( 2 ).addr( config_memories_in( 2 ).widthAddr - 1 downto 0 ), rout( 2 ).valid, din( 2 ).data( config_memories_in( 2 ).RAM_WIDTH - 1 downto 0 ),
  rout( 3 ).addr( config_memories_in( 3 ).widthAddr - 1 downto 0 ), rout( 3 ).valid, din( 3 ).data( config_memories_in( 3 ).RAM_WIDTH - 1 downto 0 ),
  din( 0 ).nents( 0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 1 ).nents( 0 )( config_memories_in( 1 ).widthNent - 1 downto 0 ), din( 1 ).nents( 1 )( config_memories_in( 1 ).widthNent - 1 downto 0 ),
  din( 2 ).nents( 0 )( config_memories_in( 2 ).widthNent - 1 downto 0 ), din( 2 ).nents( 1 )( config_memories_in( 2 ).widthNent - 1 downto 0 ),
  din( 3 ).nents( 0 )( config_memories_in( 3 ).widthNent - 1 downto 0 ), din( 3 ).nents( 1 )( config_memories_in( 3 ).widthNent - 1 downto 0 ),
  writes( 0 ).addr( config_memories_out( 0 ).widthAddr - 1 downto 0 ), open, writes( 0 ).valid, writes( 0 ).data( config_memories_out( 0 ).RAM_WIDTH - 1 downto 0 ),
  writes( 1 ).addr( config_memories_out( 1 ).widthAddr - 1 downto 0 ), open, writes( 1 ).valid, writes( 1 ).data( config_memories_out( 1 ).RAM_WIDTH - 1 downto 0 ),
  writes( 2 ).addr( config_memories_out( 2 ).widthAddr - 1 downto 0 ), open, writes( 2 ).valid, writes( 2 ).data( config_memories_out( 2 ).RAM_WIDTH - 1 downto 0 ),
  writes( 3 ).addr( config_memories_out( 3 ).widthAddr - 1 downto 0 ), open, writes( 3 ).valid, writes( 3 ).data( config_memories_out( 3 ).RAM_WIDTH - 1 downto 0 ),
  writes( 4 ).addr( config_memories_out( 4 ).widthAddr - 1 downto 0 ), open, writes( 4 ).valid, writes( 4 ).data( config_memories_out( 4 ).RAM_WIDTH - 1 downto 0 ),
  writes( 5 ).addr( config_memories_out( 5 ).widthAddr - 1 downto 0 ), open, writes( 5 ).valid, writes( 5 ).data( config_memories_out( 5 ).RAM_WIDTH - 1 downto 0 ),
  writes( 6 ).addr( config_memories_out( 6 ).widthAddr - 1 downto 0 ), open, writes( 6 ).valid, writes( 6 ).data( config_memories_out( 6 ).RAM_WIDTH - 1 downto 0 ),
  writes( 7 ).addr( config_memories_out( 7 ).widthAddr - 1 downto 0 ), open, writes( 7 ).valid, writes( 7 ).data( config_memories_out( 7 ).RAM_WIDTH - 1 downto 0 ),
  writes( 8 ).addr( config_memories_out( 8 ).widthAddr - 1 downto 0 ), open, writes( 8 ).valid, writes( 8 ).data( config_memories_out( 8 ).RAM_WIDTH - 1 downto 0 ) );
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

memory_read <= vmr_rin( offsetOut + l );

vmr_dout( offsetOut + l ) <= memory_dout;

c: tracklet_memory generic map ( sumMemOutIR + offsetOut + l ) port map ( clk, memory_din, memory_read, memory_dout );

end generate;

end generate;


end;