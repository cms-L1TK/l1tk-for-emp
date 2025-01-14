library ieee;
use ieee.std_logic_1164.all;
use work.emp_data_types.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.cdc_pkg.all;


entity cdc_fts is
port (
  clk360: in std_logic;
  clk240: in std_logic;
  fts_din: in lword;
  fts_dout: out t_data
);
end;


architecture rtl of cdc_fts is


constant widthRam: natural := 1 + widthData;
constant widthAddr: natural := widthFrames;
type t_ram is array ( 0 to 2 ** widthAddr - 1 ) of std_logic_vector( widthRam - 1 downto 0 );
function conv( s: std_logic_vector ) return t_data is
  variable d: t_data := nulll;
begin
  d.valid := s( 1 +  widthData - 1 );
  d.data  := s(      widthData - 1 downto 0 );
  return d;
end function;

-- 360 step 1

signal waddr: std_logic_vector( widthAddr - 1 downto 0 ) := ( others => '0' );
signal ram: t_ram := ( others => ( others => '0' ) );

-- 240 step 1

signal raddr: std_logic_vector( widthAddr - 1 downto 0 ) := ( others => '0' );
signal read: t_data := nulll;

-- 240 step 2

signal dout: t_data := nulll;


begin


-- 240 step 2
fts_dout <= dout;

process ( clk360 ) is
begin
if rising_edge( clk360 ) then

  -- step 1

  waddr <= ( others => '0' );
  ram( uint( waddr ) ) <= fts_din.valid & fts_din.data;
  if fts_din.valid = '1' then
    waddr <= waddr + 1;
  end if;

end if;
end process;


process ( clk240 ) is
begin
if rising_edge( clk240 ) then

  -- step 1

  read <= conv( ram( uint( raddr ) ) );

  -- step 2

  dout <= nulll;
  raddr <= ( others => '0' );
  if uint( raddr ) > 0 then
    dout <= read;
  elsif read.valid = '1' then
    dout.reset <= '1';
  end if;
  if read.valid = '1' and uint( raddr ) < numFramesLow - 1 then
    raddr <= raddr + 1;
  end if;

end if;
end process;

end;
