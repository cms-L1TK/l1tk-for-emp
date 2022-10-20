library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.hybrid_data_formats.all;
use work.hybrid_data_types.all;
use work.kf_data_formats.all;
use work.kf_data_types.all;


entity kf_accumulator is
port (
  clk: in std_logic;
  accumulator_din: in t_channelResidual;
  accumulator_dout: out t_channelResidual
);
end;


architecture rtl of kf_accumulator is


attribute ram_style: string;
constant widthAddr: natural := widthTrack;
constant widthStub: natural := 1 + widthKFr + widthKFphi + widthKFz + widthKFdPhi + widthKFdZ;
constant widthBRam: natural := widthMaybe + widthx0 + widthx1 + widthx2 + widthx3 + numLayers * widthStub;
constant widthDRam: natural := 2 * widthLayer;
type t_bram is array ( 0 to 2 ** ( widthAddr + 1 ) - 1 ) of std_logic_vector( widthBRam - 1 downto 0 );
type t_dram is array ( 0 to 2 ** widthAddr - 1 ) of std_logic_vector( widthDRam - 1 downto 0 );
type t_fifo is array ( 0 to 2 ** widthAddr - 1 ) of std_logic_vector( widthTrack - 1 downto 0 );
type t_pingPong is record
  wen  : std_logic;
  read : std_logic;
  write: std_logic;
  addr : std_logic_vector( widthAddr - 1 downto 0 );
end record;
type t_val is record
  nGood: std_logic_vector( widthLayer - 1 downto 0 );
  nSkip: std_logic_vector( widthLayer - 1 downto 0 );
end record;
function conv( v: t_val ) return std_logic_vector is begin return v.nGood & v.nSkip; end function;
function conv( s: std_logic_vector ) return t_val is begin return ( s( 2 *widthLayer - 1 downto widthLayer ), s( widthLayer - 1 downto 0 ) ); end function;

function conv( c: t_channelResidual ) return std_logic_vector is
  variable s: std_logic_vector( widthBRam - 1 downto 0 ) := ( others => '0' );
  variable state: t_stateResidual := c.state;
  variable stub: t_stubKF := nulll;
begin
  s( widthMaybe + widthx0 + widthx1 + widthx2 + widthx3 + numLayers * widthStub - 1 downto numLayers * widthStub ) := state.maybe & state.x0 & state.x1 & state.x2 & state.x3;
  for k in 0 to numLayers - 1 loop
    stub := c.stubs( k );
    s( 1 + widthKFr + widthKFphi + widthKFz + widthKFdPhi + widthKFdZ + k * widthStub - 1 downto k * widthStub ) := stub.valid & stub.r & stub.phi & stub.z & stub.dPhi & stub.dZ;
  end loop;
  return s;
end function;

function f_val( c: t_channelResidual ) return t_val is
  variable stub: t_stubKF := nulll;
  variable hits: std_logic_vector( numLayers - 1 downto 0 ) := ( others => '0' );
  variable val: t_val := ( others => ( others => '0' ) );
  variable high: natural := 0;
  variable absPhi: std_logic_vector( widthKFphi - 1 - 1 downto 0 ) := ( others => '0' );
  variable dPhi: std_logic_vector( widthKFdPhi - 1 - 1 downto 0 ) := ( others => '0' );
  variable absZ: std_logic_vector( widthKFz - 1 - 1 downto 0 ) := ( others => '0' );
  variable dZ: std_logic_vector( widthKFdZ - 1 - 1 downto 0 ) := ( others => '0' );
begin
  for k in 0 to numLayers - 1 loop
    stub := c.stubs( k );
    if stub.valid = '1' then
      hits( k ) := '1';
      high := k;
      absPhi := abs( stub.phi );
      dPhi := stub.dPhi( widthKFdPhi - 1 downto 1 );
      absZ := abs( stub.z );
      dZ := stub.dZ( widthKFdZ - 1 downto 1 );
      if unsigned( absPhi ) <= unsigned( dPhi ) and unsigned( absZ ) <= unsigned( dZ ) then
        val.nGood := incr( val.nGood );
      end if;
    end if; 
    if c.state.maybe( k ) = '1' then
      hits( k ) := '1';
    end if;
  end loop;
  val.nSkip := stdu( count( hits, high, 0, '0' ), widthLayer);
  return val;
end function;

function f_better( a, b: t_val ) return std_logic is
  variable tie: boolean := a.nGood = b.nGood;
  variable moreGood: boolean := unsigned( a.nGood ) > unsigned( b.nGood );
  variable lessSkip: boolean := unsigned( a.nSkip ) < unsigned( b.nSkip );
begin
  if moreGood or ( tie and lessSkip ) then
    return '1';
  end if;
  return '0';
end function;

-- step 1
signal din: t_channelResidual := nulll;
signal val: t_val := ( others => ( others => '0' ) );

-- step 2
signal optional: std_logic_vector( widthBRam - 1 downto 0 ) := ( others => '0' );
signal valRam: t_val := ( others => ( others => '0' ) );
signal reset: std_logic := '0';
signal valid: std_logic := '0';
signal bram: t_bram := ( others => ( others => '0' ) );
signal dram: t_dram := ( others => ( others => '0' ) );
signal better, first: std_logic := '0';
signal fifo: t_fifo := ( others => ( others => '0' ) );
signal laddr, raddr, waddr, addr, addrReg: std_logic_vector( widthTrack - 1 downto 0 ) := ( others => '0' );
attribute ram_style of dram, fifo: signal is "distributed";
attribute ram_style of bram: signal is "block";

-- step 3
signal ramReg: t_channelResidual := nulll;

-- step 4
signal dout: t_channelResidual := nulll;

-- pingPong

signal toggle: std_logic := '1';
signal ping: t_pingPong := ( '0', '0', '0', ( others => '0' ) );
signal pong: t_pingPong := ( '0', '0', '0', ( others => '0' ) );
signal pingPongCaddr: std_logic_vector( widthAddr - 1 downto 0 ) := ( others => '0' );
signal pingRam: std_logics( 2 ** widthAddr - 1 downto 0 ) := ( others => '1' );
signal pongRam: std_logics( 2 ** widthAddr - 1 downto 0 ) := ( others => '1' );
attribute ram_style of pingRam, pongRam: signal is "distributed";

signal counter: std_logic_vector( widthFrames - 1 downto 0 ) := ( others => '0' );

begin

-- step 2
first <= ping.read when toggle = '0' else pong.read;
valRam <= conv( dram( uint( din.state.track ) ) );
better <= f_better( val, valRam );
addr <= fifo( uint( raddr ) );

--step 4
accumulator_dout <= dout;

-- pingPong
ping.write <= toggle;
pong.write <= not toggle;
ping.read <= pingRam( uint( ping.addr ) );
pong.read <= pongRam( uint( pong.addr ) );
ping.wen  <= din.state.valid when toggle = '0' else '1';
pong.wen  <= '1'             when toggle = '0' else din.state.valid;
ping.addr <= din.state.track when toggle = '0' else pingPongCaddr;
pong.addr <= pingPongCaddr   when toggle = '0' else din.state.track;


process( clk ) is
begin
if rising_edge( clk ) then

  -- step 1

  din <= accumulator_din;
  val <= f_val( accumulator_din );
  counter <= incr(counter);
  if accumulator_din.state.reset = '1' then
    counter <= ( others => '0' );
  end if;

  -- step 2

  reset <= din.state.reset;
  valid <= '0';
  optional <= bram( uint( not toggle & addr ) );
  addrReg <= addr;
  if din.state.valid = '1' then
    if better = '1' or first = '1' then
      bram( uint( toggle & din.state.track ) ) <= conv( din );
      dram( uint( din.state.track ) ) <= conv( val );
    end if;
    if first = '1' then
      fifo( uint( waddr ) ) <= din.state.track;
      waddr <= incr( waddr );
    end if;
  end if;
  if din.state.reset = '1' then
    laddr <= waddr;
    waddr <= ( others => '0' );
    raddr <= ( others => '0' );
  elsif raddr /= laddr then
    raddr <= incr( raddr );
    valid <= '1';
  end if;

  -- step 3

  ramReg.state.reset <= reset;
  ramReg.state.valid <= valid;
  ramReg.state.track <= addrReg;
  ramReg.state.maybe <= optional( widthMaybe + widthx0 + widthx1 + widthx2 + widthx3 + numLayers * widthStub - 1 downto widthx0 + widthx1 + widthx2 + widthx3 + numLayers * widthStub );
  ramReg.state.x0    <= optional(              widthx0 + widthx1 + widthx2 + widthx3 + numLayers * widthStub - 1 downto           widthx1 + widthx2 + widthx3 + numLayers * widthStub );
  ramReg.state.x1    <= optional(                        widthx1 + widthx2 + widthx3 + numLayers * widthStub - 1 downto                     widthx2 + widthx3 + numLayers * widthStub );
  ramReg.state.x2    <= optional(                                  widthx2 + widthx3 + numLayers * widthStub - 1 downto                               widthx3 + numLayers * widthStub );
  ramReg.state.x3    <= optional(                                            widthx3 + numLayers * widthStub - 1 downto                                         numLayers * widthStub );
  for k in 0 to numLayers - 1 loop
    ramReg.stubs( k ).valid <= optional( 1 + widthKFr + widthKFphi + widthKFz + widthKFdPhi + widthKFdZ + k * widthStub - 1 );
    ramReg.stubs( k ).r     <= optional(     widthKFr + widthKFphi + widthKFz + widthKFdPhi + widthKFdZ + k * widthStub - 1 downto widthKFphi + widthKFz + widthKFdPhi + widthKFdZ + k * widthStub );
    ramReg.stubs( k ).phi   <= optional(                widthKFphi + widthKFz + widthKFdPhi + widthKFdZ + k * widthStub - 1 downto              widthKFz + widthKFdPhi + widthKFdZ + k * widthStub );
    ramReg.stubs( k ).z     <= optional(                             widthKFz + widthKFdPhi + widthKFdZ + k * widthStub - 1 downto                         widthKFdPhi + widthKFdZ + k * widthStub );
    ramReg.stubs( k ).dPhi  <= optional(                                        widthKFdPhi + widthKFdZ + k * widthStub - 1 downto                                       widthKFdZ + k * widthStub );
    ramReg.stubs( k ).dZ    <= optional(                                                      widthKFdZ + k * widthStub - 1 downto                                                   k * widthStub );
  end loop;

  -- step 4

  dout <= nulll;
  if ramReg.state.reset = '1' then
    dout.state.reset <= '1';
    for k in dout.stubs'range loop
      dout.stubs( k ).reset <= '1';
    end loop;
  end if;
  if ramReg.state.valid = '1' then
    dout <= ramReg;
  end if;

  -- pingPong

  pingPongCaddr <= incr( pingPongCaddr );
  if din.state.reset = '1' then
    toggle <= not toggle;
    pingPongCaddr <= ( others => '0' );
  end if;
  if ping.wen = '1' then
    pingRam( uint( ping.addr ) ) <= ping.write;
  end if;
  if pong.wen = '1' then
    pongRam( uint( pong.addr ) ) <= pong.write;
  end if;

end if;
end process;

end;