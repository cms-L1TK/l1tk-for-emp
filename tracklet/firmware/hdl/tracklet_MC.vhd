library ieee;
use ieee.std_logic_1164.all;
use work.tracklet_config.all;
use work.tracklet_data_types.all;

entity tracklet_MC is
port (
  clk: in std_logic;
  mc_din: in t_datas( numInputsMC  - 1 downto 0 );
  mc_rin: in t_reads( numOutputsMC  - 1 downto 0 );
  mc_rout: out t_reads( numInputsMC  - 1 downto 0 );
  mc_dout: out t_datas( numOutputsMC  - 1 downto 0 )
);
end;

architecture rtl of tracklet_MC is

signal process_din: t_datas( numInputsMC  - 1 downto 0 ) := ( others => nulll );
signal process_rout: t_reads( numInputsMC  - 1 downto 0 ) := ( others => nulll );
signal process_dout: t_writes( numOutputsMC  - 1 downto 0 ) := ( others => nulll );
component MC_process
port (
  clk: in std_logic;
  process_din: in t_datas( numInputsMC  - 1 downto 0 );
  process_rout: out t_reads( numInputsMC  - 1 downto 0 );
  process_dout: out t_writes( numOutputsMC  - 1 downto 0 )
);
end component;

signal memories_din: t_writes( numOutputsMC  - 1 downto 0 ) := ( others => nulll );
signal memories_rin: t_reads( numOutputsMC  - 1 downto 0 ) := ( others => nulll );
signal memories_dout: t_datas( numOutputsMC  - 1 downto 0 ) := ( others => nulll );
component MC_memories
port (
  clk: in std_logic;
  memories_din: in t_writes( numOutputsMC  - 1 downto 0 );
  memories_rin: in t_reads( numOutputsMC  - 1 downto 0 );
  memories_dout: out t_datas( numOutputsMC  - 1 downto 0 )
);
end component;

begin

process_din <= mc_din;
memories_din <= process_dout;
memories_rin <= mc_rin;

mc_rout <= process_rout;
mc_dout <= memories_dout;

cP: MC_process port map ( clk, process_din, process_rout, process_dout );

cM: MC_memories port map ( clk, memories_din, memories_rin, memories_dout );

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.tracklet_config.all;
use work.tracklet_config_memory.all;
use work.tracklet_data_types.all;

entity MC_process is
port (
  clk: in std_logic;
  process_din: in t_datas( numInputsMC  - 1 downto 0 );
  process_rout: out t_reads( numInputsMC  - 1 downto 0 );
  process_dout: out t_writes( numOutputsMC  - 1 downto 0 )
);
end;

architecture rtl of MC_process is

begin

g: for k in 0 to numMC - 1 generate

constant offsetIn: natural := sum( 0 & numNodeInputsMC, 0, k );
constant offsetOut: natural := sum( 0 & numNodeOutputsMC, 0, k );
constant numInputs: natural := numNodeInputsMC( k );
constant numOutputs: natural := numNodeOutputsMC( k );
constant config_memories_out: t_config_memories( 0 to numOutputs - 1 ) := config_memories_out( sumMemOutME + offsetOut to sumMemOutME + offsetOut + numOutputs - 1 );
constant config_memories_in: t_config_memories( 0 to numInputs - 1 ) := config_memories_in( sumMemInME + offsetIn to sumMemInME + offsetIn + numInputs - 1 );

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
c: entity work.MatchCalculator_L3PHIB port map ( clk, reset, start, done, open, open, bxIn,
  rout( 0 ).addr( config_memories_in( 0 ).widthAddr - 1 downto 0 ), rout( 0 ).valid, din( 0 ).data( config_memories_in( 0 ).widthData - 1 downto 0 ),
  rout( 1 ).addr( config_memories_in( 1 ).widthAddr - 1 downto 0 ), rout( 1 ).valid, din( 1 ).data( config_memories_in( 1 ).widthData - 1 downto 0 ),
  rout( 2 ).addr( config_memories_in( 2 ).widthAddr - 1 downto 0 ), rout( 2 ).valid, din( 2 ).data( config_memories_in( 2 ).widthData - 1 downto 0 ),
  rout( 3 ).addr( config_memories_in( 3 ).widthAddr - 1 downto 0 ), rout( 3 ).valid, din( 3 ).data( config_memories_in( 3 ).widthData - 1 downto 0 ),
  rout( 4 ).addr( config_memories_in( 4 ).widthAddr - 1 downto 0 ), rout( 4 ).valid, din( 4 ).data( config_memories_in( 4 ).widthData - 1 downto 0 ),
  rout( 5 ).addr( config_memories_in( 5 ).widthAddr - 1 downto 0 ), rout( 5 ).valid, din( 5 ).data( config_memories_in( 5 ).widthData - 1 downto 0 ),
  rout( 6 ).addr( config_memories_in( 6 ).widthAddr - 1 downto 0 ), rout( 6 ).valid, din( 6 ).data( config_memories_in( 6 ).widthData - 1 downto 0 ),
  rout( 7 ).addr( config_memories_in( 7 ).widthAddr - 1 downto 0 ), rout( 7 ).valid, din( 7 ).data( config_memories_in( 7 ).widthData - 1 downto 0 ),
  din( 0 ).nents( 0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 1 ).nents( 0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 1 ).nents( 1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 2 ).nents( 0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 2 ).nents( 1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 3 ).nents( 0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 3 ).nents( 1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 4 ).nents( 0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 4 ).nents( 1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 5 ).nents( 0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 5 ).nents( 1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 6 ).nents( 0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 6 ).nents( 1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 7 ).nents( 0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 7 ).nents( 1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  rout( 8 ).addr( config_memories_in( 8 ).widthAddr - 1 downto 0 ), rout( 8 ).valid, din( 8 ).data( config_memories_in( 8 ).widthData - 1 downto 0 ),
  rout( 9 ).addr( config_memories_in( 9 ).widthAddr - 1 downto 0 ), rout( 9 ).valid, din( 9 ).data( config_memories_in( 9 ).widthData - 1 downto 0 ),
  bxOut, open,
  writes( 0 ).addr( config_memories_out( 0 ).widthAddr - 1 downto 0 ), open, writes( 0 ).valid, writes( 0 ).data( config_memories_out( 0 ).widthData - 1 downto 0 ) );
end generate;
g1: if k = 1 generate
c: entity work.MatchCalculator_L4PHIB port map ( clk, reset, start, done, open, open, bxIn,
  rout( 0 ).addr( config_memories_in( 0 ).widthAddr - 1 downto 0 ), rout( 0 ).valid, din( 0 ).data( config_memories_in( 0 ).widthData - 1 downto 0 ),
  rout( 1 ).addr( config_memories_in( 1 ).widthAddr - 1 downto 0 ), rout( 1 ).valid, din( 1 ).data( config_memories_in( 1 ).widthData - 1 downto 0 ),
  rout( 2 ).addr( config_memories_in( 2 ).widthAddr - 1 downto 0 ), rout( 2 ).valid, din( 2 ).data( config_memories_in( 2 ).widthData - 1 downto 0 ),
  rout( 3 ).addr( config_memories_in( 3 ).widthAddr - 1 downto 0 ), rout( 3 ).valid, din( 3 ).data( config_memories_in( 3 ).widthData - 1 downto 0 ),
  rout( 4 ).addr( config_memories_in( 4 ).widthAddr - 1 downto 0 ), rout( 4 ).valid, din( 4 ).data( config_memories_in( 4 ).widthData - 1 downto 0 ),
  rout( 5 ).addr( config_memories_in( 5 ).widthAddr - 1 downto 0 ), rout( 5 ).valid, din( 5 ).data( config_memories_in( 5 ).widthData - 1 downto 0 ),
  rout( 6 ).addr( config_memories_in( 6 ).widthAddr - 1 downto 0 ), rout( 6 ).valid, din( 6 ).data( config_memories_in( 6 ).widthData - 1 downto 0 ),
  rout( 7 ).addr( config_memories_in( 7 ).widthAddr - 1 downto 0 ), rout( 7 ).valid, din( 7 ).data( config_memories_in( 7 ).widthData - 1 downto 0 ),
  din( 0 ).nents( 0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 1 ).nents( 0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 1 ).nents( 1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 2 ).nents( 0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 2 ).nents( 1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 3 ).nents( 0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 3 ).nents( 1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 4 ).nents( 0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 4 ).nents( 1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 5 ).nents( 0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 5 ).nents( 1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 6 ).nents( 0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 6 ).nents( 1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 7 ).nents( 0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 7 ).nents( 1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  rout( 8 ).addr( config_memories_in( 8 ).widthAddr - 1 downto 0 ), rout( 8 ).valid, din( 8 ).data( config_memories_in( 8 ).widthData - 1 downto 0 ),
  rout( 9 ).addr( config_memories_in( 9 ).widthAddr - 1 downto 0 ), rout( 9 ).valid, din( 9 ).data( config_memories_in( 9 ).widthData - 1 downto 0 ),
  bxOut, open,
  writes( 0 ).addr( config_memories_out( 0 ).widthAddr - 1 downto 0 ), open, writes( 0 ).valid, writes( 0 ).data( config_memories_out( 0 ).widthData - 1 downto 0 ) );
end generate;
g2: if k = 2 generate
c: entity work.MatchCalculator_L5PHIB port map ( clk, reset, start, done, open, open, bxIn,
  rout( 0 ).addr( config_memories_in( 0 ).widthAddr - 1 downto 0 ), rout( 0 ).valid, din( 0 ).data( config_memories_in( 0 ).widthData - 1 downto 0 ),
  rout( 1 ).addr( config_memories_in( 1 ).widthAddr - 1 downto 0 ), rout( 1 ).valid, din( 1 ).data( config_memories_in( 1 ).widthData - 1 downto 0 ),
  rout( 2 ).addr( config_memories_in( 2 ).widthAddr - 1 downto 0 ), rout( 2 ).valid, din( 2 ).data( config_memories_in( 2 ).widthData - 1 downto 0 ),
  rout( 3 ).addr( config_memories_in( 3 ).widthAddr - 1 downto 0 ), rout( 3 ).valid, din( 3 ).data( config_memories_in( 3 ).widthData - 1 downto 0 ),
  rout( 4 ).addr( config_memories_in( 4 ).widthAddr - 1 downto 0 ), rout( 4 ).valid, din( 4 ).data( config_memories_in( 4 ).widthData - 1 downto 0 ),
  rout( 5 ).addr( config_memories_in( 5 ).widthAddr - 1 downto 0 ), rout( 5 ).valid, din( 5 ).data( config_memories_in( 5 ).widthData - 1 downto 0 ),
  rout( 6 ).addr( config_memories_in( 6 ).widthAddr - 1 downto 0 ), rout( 6 ).valid, din( 6 ).data( config_memories_in( 6 ).widthData - 1 downto 0 ),
  rout( 7 ).addr( config_memories_in( 7 ).widthAddr - 1 downto 0 ), rout( 7 ).valid, din( 7 ).data( config_memories_in( 7 ).widthData - 1 downto 0 ),
  din( 0 ).nents( 0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 1 ).nents( 0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 1 ).nents( 1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 2 ).nents( 0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 2 ).nents( 1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 3 ).nents( 0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 3 ).nents( 1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 4 ).nents( 0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 4 ).nents( 1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 5 ).nents( 0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 5 ).nents( 1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 6 ).nents( 0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 6 ).nents( 1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 7 ).nents( 0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 7 ).nents( 1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  rout( 8 ).addr( config_memories_in( 8 ).widthAddr - 1 downto 0 ), rout( 8 ).valid, din( 8 ).data( config_memories_in( 8 ).widthData - 1 downto 0 ),
  rout( 9 ).addr( config_memories_in( 9 ).widthAddr - 1 downto 0 ), rout( 9 ).valid, din( 9 ).data( config_memories_in( 9 ).widthData - 1 downto 0 ),
  bxOut, open,
  writes( 0 ).addr( config_memories_out( 0 ).widthAddr - 1 downto 0 ), open, writes( 0 ).valid, writes( 0 ).data( config_memories_out( 0 ).widthData - 1 downto 0 ) );
end generate;
g3: if k = 3 generate
c: entity work.MatchCalculator_L6PHIB port map ( clk, reset, start, done, open, open, bxIn,
  rout( 0 ).addr( config_memories_in( 0 ).widthAddr - 1 downto 0 ), rout( 0 ).valid, din( 0 ).data( config_memories_in( 0 ).widthData - 1 downto 0 ),
  rout( 1 ).addr( config_memories_in( 1 ).widthAddr - 1 downto 0 ), rout( 1 ).valid, din( 1 ).data( config_memories_in( 1 ).widthData - 1 downto 0 ),
  rout( 2 ).addr( config_memories_in( 2 ).widthAddr - 1 downto 0 ), rout( 2 ).valid, din( 2 ).data( config_memories_in( 2 ).widthData - 1 downto 0 ),
  rout( 3 ).addr( config_memories_in( 3 ).widthAddr - 1 downto 0 ), rout( 3 ).valid, din( 3 ).data( config_memories_in( 3 ).widthData - 1 downto 0 ),
  rout( 4 ).addr( config_memories_in( 4 ).widthAddr - 1 downto 0 ), rout( 4 ).valid, din( 4 ).data( config_memories_in( 4 ).widthData - 1 downto 0 ),
  rout( 5 ).addr( config_memories_in( 5 ).widthAddr - 1 downto 0 ), rout( 5 ).valid, din( 5 ).data( config_memories_in( 5 ).widthData - 1 downto 0 ),
  rout( 6 ).addr( config_memories_in( 6 ).widthAddr - 1 downto 0 ), rout( 6 ).valid, din( 6 ).data( config_memories_in( 6 ).widthData - 1 downto 0 ),
  rout( 7 ).addr( config_memories_in( 7 ).widthAddr - 1 downto 0 ), rout( 7 ).valid, din( 7 ).data( config_memories_in( 7 ).widthData - 1 downto 0 ),
  din( 0 ).nents( 0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 1 ).nents( 0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 1 ).nents( 1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 2 ).nents( 0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 2 ).nents( 1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 3 ).nents( 0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 3 ).nents( 1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 4 ).nents( 0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 4 ).nents( 1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 5 ).nents( 0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 5 ).nents( 1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 6 ).nents( 0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 6 ).nents( 1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  din( 7 ).nents( 0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 7 ).nents( 1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  rout( 8 ).addr( config_memories_in( 8 ).widthAddr - 1 downto 0 ), rout( 8 ).valid, din( 8 ).data( config_memories_in( 8 ).widthData - 1 downto 0 ),
  rout( 9 ).addr( config_memories_in( 9 ).widthAddr - 1 downto 0 ), rout( 9 ).valid, din( 9 ).data( config_memories_in( 9 ).widthData - 1 downto 0 ),
  bxOut, open,
  writes( 0 ).addr( config_memories_out( 0 ).widthAddr - 1 downto 0 ), open, writes( 0 ).valid, writes( 0 ).data( config_memories_out( 0 ).widthData - 1 downto 0 ) );
end generate;

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.tracklet_config.all;
use work.tracklet_data_types.all;

entity MC_memories is
port (
  clk: in std_logic;
  memories_din: in t_writes( numOutputsMC  - 1 downto 0 );
  memories_rin: in t_reads( numOutputsMC  - 1 downto 0 );
  memories_dout: out t_datas( numOutputsMC  - 1 downto 0 )
);
end;

architecture rtl of MC_memories is

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

g: for k in 0 to numOutputsMC - 1 generate

signal memory_din: t_write := nulll;
signal memory_read: t_read := nulll;
signal memory_dout: t_data := nulll;

begin

memory_din <= memories_din( k );
memory_read <= memories_rin( k );
memories_dout( k ) <= memory_dout;

c: tracklet_memory generic map ( sumMemOutME + k ) port map ( clk, memory_din, memory_read, memory_dout );

end generate;

end;