library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.hybrid_data_formats.all;
use work.kf_data_formats.all;
use work.kf_data_types.all;


entity kf_seed_delay is
generic (
  index: natural
);
port (
  clk: in std_logic;
  delay_din: in t_found;
  delay_stub: out t_stub;
  delay_dout: out t_found
);
end;


architecture rtl of kf_seed_delay is


constant latency: integer := 1 + 4 * index;
attribute ram_style: string;
constant widthAddr: natural := ilog2( latency + 1 );
constant widthRam: natural := 1 + 1 + widthTrack + widthH00 + widthm0 + widthm1 + widthd0 + widthd1;
type t_ram is array ( 0 to 2 ** widthAddr - 1 ) of std_logic_vector( widthRam - 1 downto 0 );
function conv( s: std_logic_vector ) return t_stub is
  variable t: t_stub := nulll;
begin
  t.meta.reset := s( 1 + 1 + widthTrack + widthH00 + widthm0 + widthm1 + widthd0 + widthd1 - 1 );
  t.meta.valid := s(   + 1 + widthTrack + widthH00 + widthm0 + widthm1 + widthd0 + widthd1 - 1 );
  t.meta.track := s(         widthTrack + widthH00 + widthm0 + widthm1 + widthd0 + widthd1 - 1 downto widthH00 + widthm0 + widthm1 + widthd0 + widthd1 );
  t.param.H00 := s(                      widthH00 + widthm0 + widthm1 + widthd0 + widthd1 - 1 downto            widthm0 + widthm1 + widthd0 + widthd1 );
  t.param.m0  := s(                                 widthm0 + widthm1 + widthd0 + widthd1 - 1 downto                      widthm1 + widthd0 + widthd1 );
  t.param.m1  := s(                                           widthm1 + widthd0 + widthd1 - 1 downto                                widthd0 + widthd1 );
  t.param.d0  := s(                                                     widthd0 + widthd1 - 1 downto                                          widthd1 );
  t.param.d1  := s(                                                               widthd1 - 1 downto                                                0 );
  return t;
end function;
function conv( t: t_found ) return std_logic_vector is
begin
  return t.meta.reset & t.meta.hits( index ) & t.meta.track & t.stubs( index ).H00 & t.stubs( index ).m0 & t.stubs( index ).m1 & t.stubs( index ).d0 & t.stubs( index ).d1;
end function;

-- step 1

signal dout: t_found := nulll;
signal ram: t_ram := ( others => ( others => '0' ) );
signal waddr, raddr: std_logic_vector( widthAddr - 1 downto 0 ) := ( others => '0' );
signal optional: t_stub := nulll;
attribute ram_style of ram: signal is "block";

-- step 2

signal stub: t_stub := nulll;


begin


-- step 1
delay_dout <= dout;
waddr <= raddr + latency;

-- track_dout 2
delay_stub <= stub;

process( clk ) is
begin
if rising_edge( clk ) then

  -- step 1;

  dout <= delay_din;
  ram( uint( waddr ) ) <= conv( delay_din );
  optional <= conv( ram( uint( raddr ) ) );
  raddr <= raddr + 1;

  -- step 2

  stub <= optional;

end if;
end process;


end;
