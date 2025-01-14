library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.hybrid_data_formats.all;
use work.kf_data_formats.all;
use work.kf_data_types.all;


entity kf_delay is
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


architecture rtl of kf_delay is


constant latency: integer := 20 + 4 + ( 16 + 5 - 1 ) * ( index - kfNumSeedLayer );
attribute ram_style: string;
constant widthAddr: natural := ilog2( latency + 1 );
constant widthRam: natural := 1 + 1 + widthTrack + widthH00 + widthm0 + widthm1 + widthd0 + widthd1;
type t_ram is array ( 0 to 2 ** widthAddr - 1 ) of std_logic_vector( widthRam - 1 downto 0 );
function conv( std: std_logic_vector ) return t_stub is
  variable stub: t_stub := nulll;
begin
  stub.meta.reset := std( 1 + 1 + widthTrack + widthH00 + widthm0 + widthm1 + widthd0 + widthd1 - 1 );
  stub.meta.valid := std(   + 1 + widthTrack + widthH00 + widthm0 + widthm1 + widthd0 + widthd1 - 1 );
  stub.meta.track := std(         widthTrack + widthH00 + widthm0 + widthm1 + widthd0 + widthd1 - 1 downto widthH00 + widthm0 + widthm1 + widthd0 + widthd1 );
  stub.param.H00 := std(                      widthH00 + widthm0 + widthm1 + widthd0 + widthd1 - 1 downto            widthm0 + widthm1 + widthd0 + widthd1 );
  stub.param.m0  := std(                                 widthm0 + widthm1 + widthd0 + widthd1 - 1 downto                      widthm1 + widthd0 + widthd1 );
  stub.param.m1  := std(                                           widthm1 + widthd0 + widthd1 - 1 downto                                widthd0 + widthd1 );
  stub.param.d0  := std(                                                     widthd0 + widthd1 - 1 downto                                          widthd1 );
  stub.param.d1  := std(                                                               widthd1 - 1 downto                                                0 );
  return stub;
end function;
function conv( t: t_found ) return std_logic_vector is begin return t.meta.reset & t.meta.hits( index ) & t.meta.track & t.stubs( index ).H00 & t.stubs( index ).m0 & t.stubs( index ).m1 & t.stubs( index ).d0 & t.stubs( index ).d1; end function;

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