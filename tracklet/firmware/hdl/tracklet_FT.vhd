library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.hybrid_data_formats.all;
use work.tracklet_config.all;
use work.tracklet_config_memory.all;
use work.tracklet_data_types.all;


entity tracklet_FT is
port (
  clk: in std_logic;
  ft_din: in t_datas( numInputsFT  - 1 downto 0 );
  ft_rin: in t_reads( numOutputsFT  - 1 downto 0 );
  ft_rout: out t_reads( numInputsFT  - 1 downto 0 );
  ft_dout: out t_datas( numOutputsFT  - 1 downto 0 )
);
end;



architecture rtl of tracklet_FT is


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

signal notFull: std_logic := '1';


begin


g: for k in 0 to numFT - 1 generate

constant offsetIn: natural := sum( 0 & numNodeInputsFT, 0, k );
constant offsetOut: natural := sum( 0 & numNodeOutputsFT, 0, k );
constant numInputs: natural := numNodeInputsFT( k );
constant numOutputs: natural := numNodeOutputsFT( k );
constant config_memories: t_config_memories( 0 to numInputs - 1 ) := config_memories_in( sumMemInMC + offsetIn to sumMemInMC + offsetIn + numInputs - 1 );

signal din: t_datas( numInputs  - 1 downto 0 ) := ( others => nulll );
signal rout: t_reads( numInputs  - 1 downto 0 ) := ( others => nulll );
signal dout: t_datas( numOutputs  - 1 downto 0 ) := ( others => nulll );

signal reset, start: std_logic := '0';
signal bx: std_logic_vector ( widthBX - 1 downto 0 ) := ( others => '0' );

begin

din <= ft_din( offsetIn + numInputs - 1 downto offsetIn );
ft_rout( offsetIn + numInputs - 1 downto offsetIn ) <= rout;
ft_dout( offsetOut + numOutputs - 1 downto offsetOut ) <= dout;

start <= ft_din( offsetIn + 1 ).start;
bx <= ft_din( offsetIn + 1 ).bx;

process ( clk ) is
begin
if rising_edge( clk ) then

  reset <= ft_din( offsetIn + 1 ).reset;

end if;
end process;

c: entity work.TrackBuilder_L1L2 port map ( clk, reset, start, open, open, open, bx,
  rout( 0 ).addr( config_memories( 0 ).widthAddr - 1 downto 0 ), rout( 0 ).valid, din( 0 ).data( config_memories( 0 ).RAM_WIDTH - 1 downto 0 ),
  rout( 1 ).addr( config_memories( 1 ).widthAddr - 1 downto 0 ), rout( 1 ).valid, din( 1 ).data( config_memories( 1 ).RAM_WIDTH - 1 downto 0 ),
  rout( 2 ).addr( config_memories( 2 ).widthAddr - 1 downto 0 ), rout( 2 ).valid, din( 2 ).data( config_memories( 2 ).RAM_WIDTH - 1 downto 0 ),
  rout( 3 ).addr( config_memories( 3 ).widthAddr - 1 downto 0 ), rout( 3 ).valid, din( 3 ).data( config_memories( 3 ).RAM_WIDTH - 1 downto 0 ),
  rout( 4 ).addr( config_memories( 4 ).widthAddr - 1 downto 0 ), rout( 4 ).valid, din( 4 ).data( config_memories( 4 ).RAM_WIDTH - 1 downto 0 ),
  din( 1 ).nents( 0 )( config_memories( 1 ).widthNent - 1 downto 0 ), din( 1 ).nents( 1 )( config_memories( 1 ).widthNent - 1 downto 0 ),
  din( 2 ).nents( 0 )( config_memories( 2 ).widthNent - 1 downto 0 ), din( 2 ).nents( 1 )( config_memories( 2 ).widthNent - 1 downto 0 ),
  din( 3 ).nents( 0 )( config_memories( 3 ).widthNent - 1 downto 0 ), din( 3 ).nents( 1 )( config_memories( 3 ).widthNent - 1 downto 0 ),
  din( 4 ).nents( 0 )( config_memories( 4 ).widthNent - 1 downto 0 ), din( 4 ).nents( 1 )( config_memories( 4 ).widthNent - 1 downto 0 ),
  open, open,
  dout( 0 ).data( r_trackWord ), notFull, dout( 0 ).valid,
  dout( 1 ).data( r_stubWord ), notFull, dout( 1 ).valid,
  dout( 2 ).data( r_stubWord ), notFull, dout( 2 ).valid,
  dout( 3 ).data( r_stubWord ), notFull, dout( 3 ).valid,
  dout( 4 ).data( r_stubWord ), notFull, dout( 4 ).valid
);

gIn: for l in 0 to numInputs - 1 generate
rout( l ).start <= start;
end generate;

end generate;


end;