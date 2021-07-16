library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.tracklet_data_types.all;
use work.tracklet_config.all;
use work.tracklet_config_memory.all;


entity tracklet_memory is
generic (
  index: natural
);
port (
  clk: in std_logic;
  memory_din: in t_write;
  memory_read: in t_read;
  memory_dout: out t_data
);
end;


architecture rtl of tracklet_memory is


constant config_memory: t_config_memory := work.tracklet_config_memory.config_memories_out( index );

constant numBins  : natural    := config_memory.numBins;
constant widthAddr: natural    := config_memory.widthAddr;
constant widthData: natural    := config_memory.widthData;
constant widthNent: natural    := config_memory.widthNent;
constant ramStyle : t_ramStyle := config_memory.ramStyle;

function init_widthNentIn return natural is begin if numBins = 1 then return widthNent; end if; return widthNent - 1; end function;
constant widthNentIn: natural := init_widthNentIn;
function init_widthIndexBX return natural is begin if widthAddr = 8 then return 1; end if; return 3; end function;
constant widthIndexBX: natural := init_widthIndexBX;
constant widthIndexNent: natural := widthAddr - widthNentIn;

type t_ram is array ( 0 to  2 ** widthAddr - 1 ) of std_logic_vector( widthData - 1 downto 0 );

signal bx, bxReg: std_logic_vector( widthIndexBX - 1 downto 0 ) := ( others => '0' );
signal ram: t_ram := ( others => ( others => '0' ) );
signal nent: std_logic_vector( widthNent - 1 downto 0 ) := ( others => '0' );
signal indexNent: std_logic_vector( widthIndexNent - 1 downto 0 ) := ( others => '0' );
signal optional: std_logic_vector( widthData - 1 downto 0 ) := ( others => '0' );
signal reg: std_logic_vector( widthData - 1 downto 0 ) := ( others => '0' );
signal dout: t_data := nulll;

attribute ram_style: string;
attribute ram_style of ram: signal is conv( ramStyle );


begin


memory_dout <= dout;

-- step 1

nent <= incr( resize( memory_din.addr( widthNentIn - 1 downto 0 ), widthNent ) );
indexNent <= memory_din.addr( widthAddr - 1 downto widthAddr - widthIndexNent );
dout.reset <= memory_din.reset;
dout.start <= memory_din.start;
dout.bx <= memory_din.bx;
bx <= memory_din.bx( widthIndexBX - 1 downto 0 );

-- step 2

dout.data( widthData - 1 downto 0 ) <= reg;


process ( clk ) is
begin
if rising_edge( clk ) then

  -- step 1

  bxReg <= bx;
  optional <= ram( uint( memory_read.addr( widthAddr - 1 downto 0 ) ) );

  if bxReg /= bx then
    for k in 0 to numBins - 1 loop
      dout.nents( uint( incr( bx ) ) * numBins + k )( widthNent - 1 downto 0 ) <= ( others => '0' );
    end loop;
  end if;

  if memory_din.valid = '1' then
    dout.nents( uint( indexNent ) )( widthNent - 1 downto 0 ) <= nent;
    ram( uint( memory_din.addr( widthAddr - 1 downto 0 ) ) ) <= memory_din.data( widthData - 1 downto 0 );
  end if; 

  if memory_din.reset = '1' then
    for k in 0 to 2 ** widthIndexNent - 1 loop
      dout.nents( k )( widthNent - 1 downto 0 ) <= ( others => '0' );
    end loop;
  end if;

  -- step 2

  reg <= optional;

end if;
end process;


end;
