library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.hybrid_data_formats.all;
use work.hybrid_data_types.all;
use work.kf_data_formats.all;
use work.kf_data_types.all;


entity kf_accumulator is
port (
  clk: in std_logic;
  accumulator_din: in t_fitted;
  accumulator_dout: out t_trackKF
);
end;


architecture rtl of kf_accumulator is


attribute ram_style: string;
constant widthAddr: natural := widthTrack;
type t_fifo is array ( 0 to 2 ** widthAddr - 1 ) of std_logic_vector( widthTrack - 1 downto 0 );
type t_pingPong is record
  wen  : std_logic;
  read : std_logic;
  write: std_logic;
  addr : std_logic_vector( widthAddr - 1 downto 0 );
end record;

constant c_psZ: natural := ilog2( 0.5 * pitchCol2S / baseTMz ) - 1;
constant widthLayerPS: natural := ilog2( numLayers );
constant widthLayer2S: natural := widthLayerPS - 1;
type t_val is record
  nPS: std_logic_vector( widthLayerPS - 1 downto 0 );
  n2S: std_logic_vector( widthLayer2S - 1 downto 0 );
end record;

constant widthDRam: natural := widthLayerPS + widthLayer2S;
type t_dram is array ( 0 to 2 ** widthAddr - 1 ) of std_logic_vector( widthDRam - 1 downto 0 );
function conv( v: t_val ) return std_logic_vector is begin return v.nPS & v.n2S; end function;
function conv( s: std_logic_vector ) return t_val is begin return ( s( widthLayerPS + widthLayer2S - 1 downto widthLayer2S ), s( widthLayer2S - 1 downto 0 ) ); end function;

constant widthBRam: natural := widthHits + widthKFinv2R + widthKFphiT + widthKFcot + widthKFzT + numLayers * widthParameterStub;
type t_bram is array ( 0 to 2 ** ( widthAddr + 1 ) - 1 ) of std_logic_vector( widthBRam - 1 downto 0 );
function conv( f: t_fitted ) return std_logic_vector is
  variable std: std_logic_vector( widthBRam - 1 downto 0 ) := ( others => '0' );
begin
  std( widthHits + widthKFinv2R + widthKFphiT + widthKFcot + widthKFzT + numLayers * widthParameterStub - 1 downto numLayers * widthParameterStub ) := f.meta.hits & f.track.inv2R & f.track.phiT & f.track.cot & f.track.zT;
  for k in f.stubs'range loop
    std( widthH00 + widthm0 + widthm1 + widthd0 + widthd1 + k * widthParameterStub - 1 downto k * widthParameterStub ) := f.stubs( k ).H00 & f.stubs( k ).m0 & f.stubs( k ).m1 & f.stubs( k ).d0 & f.stubs( k ).d1;
  end loop;
  return std;
end function;

-- step 1
signal din: t_fitted := nulll;
signal hitPatternGood: std_logic_vector( 0 to widthHits - 1 ) := ( others => '0' );
signal hitPatternPS: std_logic_vector( 0 to widthHits - 1 ) := ( others => '0' );

-- step 2
signal toggle, first, morePS, more2S, tie, better: std_logic := '0';
signal fitted: t_fitted := nulll;
signal valNew, valOld: t_val := ( others => ( others => '0' ) );

-- step 3
signal toggleB, reset, valid: std_logic := '0';
signal bram: t_bram := ( others => ( others => '0' ) );
signal dram: t_dram := ( others => ( others => '0' ) );
signal fifo: t_fifo := ( others => ( others => '0' ) );
signal laddr, raddr, waddr, addr: std_logic_vector( widthTrack - 1 downto 0 ) := ( others => '0' );
attribute ram_style of dram, fifo: signal is "distributed";
attribute ram_style of bram: signal is "block";

-- step 4
signal toggleO: std_logic := '0';
signal read: std_logic_vector( widthBRam - 1 downto 0 ) := ( others => '0' );
signal optional: t_trackKF := nulll;

-- step 5
signal dout: t_trackKF := nulll;

-- pingPong

signal ping: t_pingPong := ( '0', '0', '0', ( others => '0' ) );
signal pong: t_pingPong := ( '0', '0', '0', ( others => '0' ) );
signal pingPongCaddr: std_logic_vector( widthAddr - 1 downto 0 ) := ( others => '0' );
signal pingRam: std_logics( 2 ** widthAddr - 1 downto 0 ) := ( others => '1' );
signal pongRam: std_logics( 2 ** widthAddr - 1 downto 0 ) := ( others => '1' );
attribute ram_style of pingRam, pongRam: signal is "distributed";

begin

-- step 2
valOld <= conv( dram( uint( fitted.meta.track ) ) );
tie <= '1' when valNew.nPS = valOld.nPS else '0';
morePS <= '1' when uint( valNew.nPS ) > uint( valOld.nPS ) else '0';
more2S <= '1' when uint( valNew.n2S ) > uint( valOld.n2S ) else '0';
better <= '1' when morePS = '1' or ( tie = '1' and more2S = '1' ) else '0';

-- step 4
read <= bram( uint( not toggleO & addr ) );

--step 5
accumulator_dout <= dout;

-- pingPong
ping.write <= toggle;
pong.write <= not toggle;
ping.read <= pingRam( uint( ping.addr ) );
pong.read <= pongRam( uint( pong.addr ) );
ping.wen  <= din.meta.valid when toggle = '0' else '1';
pong.wen  <= '1'           when toggle = '0' else din.meta.valid;
ping.addr <= din.meta.track when toggle = '0' else pingPongCaddr;
pong.addr <= pingPongCaddr when toggle = '0' else din.meta.track;


process( clk ) is
begin
if rising_edge( clk ) then

  -- step 1

  hitPatternGood <= ( others => '0' );
  hitPatternPS <= ( others => '0' );
  din <= accumulator_din;
  if count( accumulator_din.meta.hits ) < kfMinStubs then
    din.meta.valid <= '0';
  end if;
  for k in 0 to numLayers - 1 loop
    if accumulator_din.meta.hits( k ) = '1' then
      if ( '0' & abs( accumulator_din.stubs( k ).m0 ) ) <= ( '0' & accumulator_din.stubs( k ).d0 ) and ( '0' & abs( accumulator_din.stubs( k ).m1 ) ) <= ( '0' & accumulator_din.stubs( k ).d1 ) then
        hitPatternGood( k ) <= '1';
      end if;
      if count( accumulator_din.stubs( k ).d1, c_psZ, widthKFdZ ) = 0 then
        hitPatternPS( k ) <= '1';
      end if;
    end if;
  end loop;

  -- step 2

  fitted <= din;
  valNew <= ( stdu( count( hitPatternPS and hitPatternGood ), widthLayerPS ), stdu( count( hitPatternGood ) - count( hitPatternPS and hitPatternGood ), widthLayer2S ) );

  toggleB <= toggle;
  first <= ping.read;
  if toggle = '1' then
    first <= pong.read;
  end if;

  -- step 3

  valid <= '0';
  toggleO <= toggleB;
  reset <= fitted.meta.reset;
  if fitted.meta.valid = '1' then
    if better = '1' or first = '1' then
      bram( uint( toggleB & fitted.meta.track ) ) <= conv( fitted );
      dram( uint( fitted.meta.track ) ) <= conv( valNew );
    end if;
    if first = '1' then
      fifo( uint( waddr ) ) <= fitted.meta.track;
      waddr <=  waddr + 1;
    end if;
  end if;

  addr <= fifo( uint( raddr ) );
  if raddr /= laddr then
    raddr <= raddr + 1;
    valid <= '1';
  end if;

  if fitted.meta.reset = '1' then
    laddr <= waddr;
    valid <= '0';
    waddr <= ( others => '0' );
    raddr <= ( others => '0' );
  end if;

  -- step 4

  optional.meta.reset <= reset;
  optional.meta.valid <= valid;
  optional.meta.hits    <= read( widthHits + widthKFinv2R + widthKFphiT + widthKFcot + widthKFzT + numLayers * widthParameterStub - 1 downto widthKFinv2R + widthKFphiT + widthKFcot + widthKFzT + numLayers * widthParameterStub );
  optional.track.inv2R <= read(             widthKFinv2R + widthKFphiT + widthKFcot + widthKFzT + numLayers * widthParameterStub - 1 downto                widthKFphiT + widthKFcot + widthKFzT + numLayers * widthParameterStub );
  optional.track.phiT  <= read(                            widthKFphiT + widthKFcot + widthKFzT + numLayers * widthParameterStub - 1 downto                              widthKFcot + widthKFzT + numLayers * widthParameterStub );
  optional.track.cot   <= read(                                          widthKFcot + widthKFzT + numLayers * widthParameterStub - 1 downto                                           widthKFzT + numLayers * widthParameterStub );
  optional.track.zT    <= read(                                                       widthKFzT + numLayers * widthParameterStub - 1 downto                                                       numLayers * widthParameterStub );
  for k in optional.stubs'range loop
    optional.stubs( k ).r     <= read( widthKFr + widthKFphi + widthKFz + widthKFdPhi + widthKFdZ + k * widthParameterStub - 1 downto widthKFphi + widthKFz + widthKFdPhi + widthKFdZ + k * widthParameterStub );
    optional.stubs( k ).phi   <= read(            widthKFphi + widthKFz + widthKFdPhi + widthKFdZ + k * widthParameterStub - 1 downto              widthKFz + widthKFdPhi + widthKFdZ + k * widthParameterStub );
    optional.stubs( k ).z     <= read(                         widthKFz + widthKFdPhi + widthKFdZ + k * widthParameterStub - 1 downto                         widthKFdPhi + widthKFdZ + k * widthParameterStub );
    optional.stubs( k ).dPhi  <= read(                                    widthKFdPhi + widthKFdZ + k * widthParameterStub - 1 downto                                       widthKFdZ + k * widthParameterStub );
    optional.stubs( k ).dZ    <= read(                                                  widthKFdZ + k * widthParameterStub - 1 downto                                                   k * widthParameterStub );
  end loop;

  if reset = '1' or valid = '0' then
    optional.meta.hits <= ( others => '0' );
    optional.track <= nulll; 
    optional.stubs <= ( others => nulll );
  end if;

  -- step 5

  dout <= optional;

  -- pingPong

  pingPongCaddr <= pingPongCaddr + 1;
  if accumulator_din.meta.reset = '1' then
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