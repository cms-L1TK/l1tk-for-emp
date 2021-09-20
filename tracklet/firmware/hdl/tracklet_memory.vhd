library ieee;
use ieee.std_logic_1164.all;
use work.tracklet_data_types.all;
use work.hybrid_tools.all;
use work.tf_pkg.all;
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

constant RAM_WIDTH: natural := config_memory.RAM_WIDTH;
constant NUM_PAGES: natural := config_memory.NUM_PAGES;
constant RAM_DEPTH: natural := config_memory.NUM_PAGES * 2 ** widthNent;
constant NUM_MEM_BINS: natural := work.tracklet_config_memory.NUM_MEM_BINS;
constant NUM_ENTRIES_PER_MEM_BINS: natural := work.tracklet_config_memory.NUM_ENTRIES_PER_MEM_BINS;
constant INIT_FILE: string := work.tracklet_config_memory.INIT_FILE;
constant INIT_HEX: boolean := work.tracklet_config_memory.INIT_HEX;
constant RAM_PERFORMANCE: string := work.tracklet_config_memory.RAM_PERFORMANCE;

signal clka: std_logic := '0';
signal clkb: std_logic := '0';
signal rsta: std_logic := '0';
signal wea: std_logic := '0';
signal enb: std_logic := '0';
signal rstb: std_logic := '0';
signal regceb: std_logic := '0';
signal addra: std_logic_vector( width( RAM_DEPTH ) - 1 downto 0 ) := ( others => '0' );
signal dina: std_logic_vector( RAM_WIDTH - 1 downto 0 ) := ( others => '0' );
signal addrb: std_logic_vector( width( RAM_DEPTH ) - 1 downto 0 ) := ( others => '0' );
signal doutb: std_logic_vector( RAM_WIDTH - 1 downto 0 ) := ( others => '0' );
signal sync_nent: std_logic := '0';

component tf_mem
generic (
  RAM_WIDTH: natural;
  NUM_PAGES: natural;
  RAM_DEPTH: natural;
  INIT_FILE: string;
  INIT_HEX: boolean;
  RAM_PERFORMANCE: string
);
port (
  clka: in std_logic;
  clkb: in std_logic;
  rsta: in std_logic;
  wea: in std_logic;
  enb: in std_logic;
  rstb: in std_logic;
  regceb: in std_logic;
  addra: in std_logic_vector( width( RAM_DEPTH ) - 1 downto 0 );
  dina: in std_logic_vector( RAM_WIDTH - 1 downto 0 );
  addrb: in std_logic_vector( width( RAM_DEPTH ) - 1 downto 0 );
  doutb: out std_logic_vector( RAM_WIDTH - 1 downto 0 );
  sync_nent: in std_logic;
  nent_o: out t_arr_7b( 0 to NUM_PAGES - 1 )
);
end component;

component tf_mem_bin
generic (
  RAM_WIDTH: natural;
  NUM_PAGES: natural;
  RAM_DEPTH: natural;
  NUM_MEM_BINS: natural;
  NUM_ENTRIES_PER_MEM_BINS: natural;
  INIT_FILE: string;
  INIT_HEX: boolean;
  RAM_PERFORMANCE: string
  );
port (
  clka: in std_logic;
  clkb: in std_logic;
  rsta: in std_logic;
  wea: in std_logic;
  enb: in std_logic;
  rstb: in std_logic;
  regceb: in std_logic;
  addra: in std_logic_vector( width( RAM_DEPTH ) - 1 downto 0 );
  dina: in std_logic_vector( RAM_WIDTH - 1 downto 0 );
  addrb: in std_logic_vector( width( RAM_DEPTH ) - 1 downto 0 );
  doutb: out std_logic_vector( RAM_WIDTH - 1 downto 0 );
  sync_nent: in std_logic;
  nent_o: out t_arr_8_5b(0 to NUM_PAGES-1)
  );
end component;

signal dout: t_data := nulll;


begin


clka <= clk ;
clkb <= clk ;
rsta <= memory_din.reset;
wea <= memory_din.valid;
enb <= memory_read.valid;
rstb <= not memory_read.valid;
regceb <= '1';
addra <= memory_din.addr( addra'range );
dina <= memory_din.data( dina'range );
addrb <= memory_read.addr( addrb'range );
sync_nent <= memory_read.start;

dout.reset <= memory_din.reset;
dout.start <= memory_din.start;
dout.bx <= memory_din.bx;
dout.data( doutb'range ) <= doutb;

memory_dout <= dout;

gMem: if config_memory.name = work.tracklet_data_types.tf_mem generate
signal nent_o: t_arr_7b( 0 to NUM_PAGES - 1 ) := ( others => ( others => '0' ) );
begin
dout.nents( nent_o'range ) <= conv( nent_o );
c: tf_mem generic map ( RAM_WIDTH, NUM_PAGES, RAM_DEPTH, INIT_FILE, INIT_HEX, RAM_PERFORMANCE )
  port map ( clka, clkb, rsta, wea, enb, rstb, regceb, addra, dina, addrb, doutb, sync_nent, nent_o );
end generate;

gMemBin: if config_memory.name = work.tracklet_data_types.tf_mem_bin generate
signal nent_o: t_arr_8_5b( 0 to NUM_PAGES - 1 ) := ( others => ( others => ( others => '0' ) ) );
begin
dout.nents( 0 to nent_o'length * t_arr8_5b'length - 1 ) <= conv( nent_o );
c: tf_mem_bin generic map ( RAM_WIDTH, NUM_PAGES, RAM_DEPTH, NUM_MEM_BINS, NUM_ENTRIES_PER_MEM_BINS, INIT_FILE, INIT_HEX, RAM_PERFORMANCE )
  port map ( clka, clkb, rsta, wea, enb, rstb, regceb, addra, dina, addrb, doutb, sync_nent, nent_o );
end generate;


end;