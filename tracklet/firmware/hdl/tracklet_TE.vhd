library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.hybrid_data_formats.all;
use work.tracklet_config.all;
use work.tracklet_config_memory.all;
use work.tracklet_data_types.all;


entity tracklet_TE is
port (
  clk: in std_logic;
  te_din: in t_datas( numInputsTE  - 1 downto 0 );
  te_rin: in t_reads( numOutputsTE  - 1 downto 0 );
  te_rout: out t_reads( numInputsTE  - 1 downto 0 );
  te_dout: out t_datas( numOutputsTE  - 1 downto 0 )
);
end;



architecture rtl of tracklet_TE is


component tracklet_memory
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

constant lut_width: integer := 1;
constant lut_depth: integer := 256;
constant RAM_PERFORMANCE : string := "HIGH_PERFORMANCE";
constant widthAddr: natural := width( lut_depth );
component tf_lut
generic (
  lut_file: string;
  lut_width: integer;
  lut_depth: integer;
  RAM_PERFORMANCE : string
);
port (
  clk: in std_logic;
  ce: in std_logic;
  addr: in std_logic_vector( widthAddr - 1 downto 0 );
  dout: out std_logic_vector( lut_width-1 downto 0 )
);
end component;

signal bx: std_logic_vector ( widthBX - 1 downto 0 ) := ( others => '0' );


begin


g: for k in 0 to numTE - 1 generate

constant offsetIn: natural := sum( 0 & numNodeInputsTE, 0, k );
constant offsetOut: natural := sum( 0 & numNodeOutputsTE, 0, k );
constant numInputs: natural := numNodeInputsTE( k );
constant numOutputs: natural := numNodeOutputsTE( k );
constant config_memories_out: t_config_memories( 0 to numOutputs - 1 ) := config_memories_out( sumMemOutVMR + offsetOut to sumMemOutVMR + offsetOut + numOutputs - 1 );
constant config_memories_in: t_config_memories( 0 to numInputs - 1 ) := config_memories_in( sumMemInVMR + offsetIn to sumMemInVMR + offsetIn + numInputs - 1 );

signal din: t_datas( numInputs  - 1 downto 0 ) := ( others => nulll );
signal rout: t_reads( numInputs  - 1 downto 0 ) := ( others => nulll );

signal lutRead: t_reads( 2 - 1 downto 0 ) := ( others => nulll );
type t_lutDatas is array ( natural range <> ) of std_logic_vector( 1 - 1 downto 0 );
signal lutData: t_lutDatas( 2 - 1 downto 0 ) := ( others => ( others => '0' ) );

signal reset, start, done, enable: std_logic := '0';
signal writes: t_writes( numOutputs - 1 downto 0 ) := ( others => nulll );

signal counter: std_logic_vector( widthNent - 1 downto 0 ) := ( others => '0' );

begin

din <= te_din( offsetIn + numInputs - 1 downto offsetIn );
te_rout( offsetIn + numInputs - 1 downto offsetIn ) <= rout;

start <= te_din( offsetIn ).start;

process ( clk ) is
begin
if rising_edge( clk ) then

  reset <= te_din( offsetIn ).reset;
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

gLUT: for l in 0 to 2 - 1 generate

constant lut_file: string := lut_files( 2 * k + l );

signal ce: std_logic := '0';
signal addr: std_logic_vector( widthAddr - 1 downto 0 ) := ( others => '0' );
signal dout: std_logic_vector( lut_width - 1 downto 0 ) := ( others => '0' );

begin

ce <= lutRead( l ).valid;
addr <= lutRead( l ).addr( addr'range );
lutData( l )( dout'range ) <= dout; 

c: tf_lut generic map ( lut_file, lut_width, lut_depth, RAM_PERFORMANCE ) port map ( clk, ce, addr, dout );

end generate;

c: entity work.TrackletEngineTop port map ( clk, reset, start, done, open, open, bx,
  rout( 0 ).addr( config_memories_in( 0 ).widthAddr - 1 downto 0 ), rout( 0 ).valid, din( 0 ).data( config_memories_in( 0 ).RAM_WIDTH - 1 downto 0 ),
  din( 0 ).nents( 0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ), din( 0 ).nents( 1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  rout( 1 ).addr( config_memories_in( 1 ).widthAddr - 1 downto 0 ), rout( 1 ).valid, din( 1 ).data( config_memories_in( 1 ).RAM_WIDTH - 1 downto 0 ),
  din( 1 ).nents(  0 )( config_memories_in( 1 ).widthNent - 1 downto 0 ), din( 1 ).nents(  1 )( config_memories_in( 1 ).widthNent - 1 downto 0 ),
  din( 1 ).nents(  2 )( config_memories_in( 1 ).widthNent - 1 downto 0 ), din( 1 ).nents(  3 )( config_memories_in( 1 ).widthNent - 1 downto 0 ),
  din( 1 ).nents(  4 )( config_memories_in( 1 ).widthNent - 1 downto 0 ), din( 1 ).nents(  5 )( config_memories_in( 1 ).widthNent - 1 downto 0 ),
  din( 1 ).nents(  6 )( config_memories_in( 1 ).widthNent - 1 downto 0 ), din( 1 ).nents(  7 )( config_memories_in( 1 ).widthNent - 1 downto 0 ),
  din( 1 ).nents(  8 )( config_memories_in( 1 ).widthNent - 1 downto 0 ), din( 1 ).nents(  9 )( config_memories_in( 1 ).widthNent - 1 downto 0 ),
  din( 1 ).nents( 10 )( config_memories_in( 1 ).widthNent - 1 downto 0 ), din( 1 ).nents( 11 )( config_memories_in( 1 ).widthNent - 1 downto 0 ),
  din( 1 ).nents( 12 )( config_memories_in( 1 ).widthNent - 1 downto 0 ), din( 1 ).nents( 13 )( config_memories_in( 1 ).widthNent - 1 downto 0 ),
  din( 1 ).nents( 14 )( config_memories_in( 1 ).widthNent - 1 downto 0 ), din( 1 ).nents( 15 )( config_memories_in( 1 ).widthNent - 1 downto 0 ),
  lutRead( 0 ).addr( 8 - 1 downto 0 ), lutRead( 0 ).valid, lutData( 0 ),
  lutRead( 1 ).addr( 8 - 1 downto 0 ), lutRead( 1 ).valid, lutData( 1 ), open, open,
  writes( 0 ).addr( config_memories_out( 0 ).widthAddr - 1 downto 0 ), open, writes( 0 ).valid, writes( 0 ).data( config_memories_out( 0 ).RAM_WIDTH - 1 downto 0 )
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
writes( l ).start <= '1' when done = '1' or enable = '1' else '0';

memory_din <= writes( l );

memory_read <= te_rin( offsetOut + l );

te_dout( offsetOut + l ) <= memory_dout;

c: tracklet_memory generic map ( sumMemOutVMR + offsetOut + l ) port map ( clk, memory_din, memory_read, memory_dout );

end generate;

end generate;


end;