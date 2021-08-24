library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.tfp_config.all;
use work.tfp_data_types.all;
use work.kf_data_types.all;

entity kf_residual is
port (
    clk: in std_logic;
    residual_din: in t_channelFit;
    residual_dout: out t_channelResidual
);
end;

architecture rtl of kf_residual is

--signal valid: std_logic_vector( 4 - 1 downto 0 ) := ( others => '0' );
--signal x0: std_logic_vector( widthValidx0 - 1 downto 0 ) := ( others => '0' );
--signal x1: std_logic_vector( widthValidx1 - 1 downto 0 ) := ( others => '0' );
--signal x2: std_logic_vector( widthValidx2 - 1 downto 0 ) := ( others => '0' );
--signal x3: std_logic_vector( widthValidx3 - 1 downto 0 ) := ( others => '0' );
signal state, dout: t_stateResidual := nulll;
signal states: t_statesResidual( 6 - 1 downto 1 + 1 ) := ( others => nulll );
component kf_residual_layer
generic (
    index: integer
);
port (
    clk: in std_logic;
    layer_state: in t_stateFit;
    layer_stub: in t_stubProto;
    layer_dout: out t_stubKF
);
end component;

begin

state <= states( states'high );
--x0 <= state.x0( r_validx0 );
--x1 <= state.x1( r_validx1 );
--x2 <= state.x2( r_validx2 );
--x3 <= state.x3( r_validx3 );
--valid( 0 ) <= '1' when unsigned( x0 ) = 0 or signed( x0 ) = -1 else '0';
--valid( 1 ) <= '1' when unsigned( x1 ) = 0 or signed( x1 ) = -1 else '0';
--valid( 2 ) <= '1' when unsigned( x2 ) = 0 or signed( x2 ) = -1 else '0';
--valid( 3 ) <= '1' when unsigned( x3 ) = 0 or signed( x3 ) = -1 else '0';

process( clk ) is
begin
if rising_edge( clk ) then

    states <= states( states'high - 1 downto states'low ) & f_conv( residual_din.state );

--    dout <= nulll;
--    if state.valid = '1' and signed( valid ) = -1 then
--        dout <= state;
--    end if;
--    if state.reset = '1' then
--        dout.reset <= '1';
--    end if;
    dout <= state;

end if;
end process;

residual_dout.state <= dout;

g: for k in 0 to numLayers - 1 generate

signal layer_state: t_stateFit := nulll;
signal layer_stub: t_stubProto := nulll;
signal layer_dout: t_stubKF := nulll;

begin

layer_state <= residual_din.state;
layer_stub <= residual_din.stubs( k );
residual_dout.stubs( k ) <= layer_dout;

c: kf_residual_layer generic map ( k ) port map ( clk, layer_state, layer_stub, layer_dout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;

use work.tfp_tools.all;
use work.tfp_config.all;
use work.tfp_data_formats.all;
use work.tfp_data_types.all;
use work.kf_data_formats.all;
use work.kf_data_types.all;

entity kf_residual_layer is
generic (
    index: integer
);
port (
    clk: in std_logic;
    layer_state: in t_stateFit;
    layer_stub: in t_stubProto;
    layer_dout: out t_stubKF
);
end;

architecture rtl of kf_residual_layer is

attribute ram_style: string;
constant widthRam: natural := widthSFr + widthSFphi + widthSFz + widthSFdPhi + widthSFdZ;
constant widthAddr: natural := widthTrack + widthStubs;
type t_ram is array ( 0 to 2 ** widthAddr - 1 ) of std_logic_vector( widthRam - 1 downto 0 );
function conv( s: t_stubProto ) return std_logic_vector is
begin
    return s.r & s.phi & s.z & s.dPhi & s.dZ;
end function;
function conv( s: std_logic_vector ) return t_stubProto is
    variable r: t_stubProto := nulll;
begin
    r.r    := s( widthSFr + widthSFphi + widthSFz + widthSFdPhi + widthSFdZ - 1 downto widthSFphi + widthSFz + widthSFdPhi + widthSFdZ );
    r.phi  := s(            widthSFphi + widthSFz + widthSFdPhi + widthSFdZ - 1 downto              widthSFz + widthSFdPhi + widthSFdZ );
    r.z    := s(                         widthSFz + widthSFdPhi + widthSFdZ - 1 downto                         widthSFdPhi + widthSFdZ );
    r.dPhi := s(                                    widthSFdPhi + widthSFdZ - 1 downto                                       widthSFdZ );
    r.dZ   := s(                                                  widthSFdZ - 1 downto                                               0 );
    return r;
end function;
type t_stub is
record
    reset : std_logic;
    valid : std_logic;
    track : std_logic_vector( widthtrack  - 1 downto 0 );
    r     : std_logic_vector( widthSFr    - 1 downto 0 );
    dPhi  : std_logic_vector( widthSFdPhi - 1 downto 0 );
    dZ    : std_logic_vector( widthSFdZ   - 1 downto 0 );
end record;
type t_stubs is array ( natural range <> ) of t_stub;
function nulll return t_stub is begin return ( '0', '0', others => ( others => '0' ) ); end function;
function f_conv( s: t_stubProto ) return t_stub is begin return ( s.reset, s.valid, s.track, s.r, s.dPhi, s.dZ ); end function;
type t_x1 is array ( natural range <> ) of std_logic_vector( widthx1 - 1 downto 0 );
type t_x3 is array ( natural range <> ) of std_logic_vector( widthx3 - 1 downto 0 );

-- step 1
signal reset: std_logic := '0';
signal valid: std_logic := '0';
signal state: t_stateFit := nulll;
signal stub: t_stubProto := nulll;
signal lmap: t_lmap := ( others => ( others => '0' ) );
signal val: std_logic := '0';
signal track: std_logic_vector( widthTrack - 1 downto 0 ) := ( others => '0' );
signal x0: std_logic_vector( widthx0 - 1 downto 0 ) := ( others => '0' );
signal x1: t_x1( 3 downto 1 + 1 ) := ( others => ( others => '0' ) );
signal x2: std_logic_vector( widthx2 - 1 downto 0 ) := ( others => '0' );
signal x3: t_x3( 3 downto 1 + 1 ) := ( others => ( others => '0' ) );
signal dspr0: t_r0 := ( others => ( others => '0' ) );
signal dspr1: t_r1 := ( others => ( others => '0' ) );
signal ramOptional: std_logic_vector( widthRam - 1 downto 0 ) := ( others => '0' );
signal ram: t_ram := ( others => ( others => '0' ) );
signal waddr, raddr: std_logic_vector( widthAddr - 1 downto 0 ) := ( others => '0' ); 
signal counter: std_logic_vector( widthStubs - 1 downto 0 ) := ( others => '0' );
signal counterReg: std_logic_vector( widthStubs - 1 downto 0 ) := ( others => '0' );
attribute ram_style of ram: signal is "block";

-- step 2
signal ramReg: t_stubProto := nulll;

-- step 3
signal stubs: t_stubs( 5 downto 3 + 1 ) := ( others => nulll );
signal r0C: t_r0C := ( others => ( others => '0' ) );
signal r1C: t_r1C := ( others => ( others => '0' ) );

-- step 5
signal sr: t_stub := nulll;
signal dout: t_stubKF := nulll;

begin

-- step 1
state <= layer_state;
stub <= layer_stub;
lmap <= conv( state.lmap );
counter <= ( others => '0' ) when stub.valid = '0' or val /= stub.valid or track /= stub.track else incr( counterReg );
waddr <= stub.track & counter;
raddr <= state.track & lmap( index );

-- step 3
r0C.m0 <= ramReg.phi & '1' & ( baseShiftm0 - baseShiftx1 - 1 downto 0 => '0' );
r0C.x1 <= x1( x1'high ) & '1';
r0C.sum <= r0C.m0 - r0C.x1;
r1C.m1 <= ramReg.z & '1'& ( baseShiftm1 - baseShiftx3 - 1 downto 0 => '0' );
r1C.x3 <= x3( x3'high ) & '1';
r1C.sum <= r1C.m1 - r1C.x3;

-- step 5
sr <= stubs( stubs'high );
layer_dout <= dout;

process( clk ) is
begin
if rising_edge( clk ) then

    -- step 1

    reset <= state.reset;
    valid <= state.valid and state.hits( index );
    val <= stub.valid;
    track <= stub.track;
    counterReg <= counter;
    ramOptional <= ram( uint( raddr ) );
    if stub.valid = '1' then
        ram( uint( waddr ) ) <= conv( stub );
    end if;
    x0 <= state.x0;
    x1 <= x1( x1'high - 1 downto x1'low ) & state.x1;
    x2 <= state.x2;
    x3 <= x3( x3'high - 1 downto x1'low ) & state.x3;

    -- step 2
    ramReg <= conv( ramOptional );
    ramReg.reset <= reset;
    ramReg.valid <= valid;
    dspr0.B0 <= x0 & '1';
    dspr1.B0 <= x2 & '1';

    -- step 3

    stubs <= stubs( stubs'high - 1 downto stubs'low ) & f_conv( ramReg );
    dspr0.A0 <= ramReg.r & '1';
    dspr0.B1 <= dspr0.B0;
    dspr0.C <= r0C.sum( r_r0C ) & '1' & ( baseShiftx1 - ( baseShiftx0 + baseShiftH00 ) + 1 - 1 downto 0 => '0' );
    dspr1.A <= ramReg.r & '1';
    dspr1.B1 <= dspr1.B0;
    dspr1.D <= dH & '0';
    dspr1.C <= r1C.sum( r_r1C ) & '1' & ( baseShiftx3 - ( baseShiftx2 + baseShiftH12 ) + 1 - 1 downto 0 => '0' );

    -- step 4

    dspr0.P <= dspr0.C - dspr0.A0 * dspr0.B1;
    dspr1.P <= dspr1.C - ( dspr1.A + dspr1.D ) * dspr1.B1;

    -- step 5

    dout <= nulll;
    dout.reset <= sr.reset;
    if sr.valid = '1' then
        dout.valid <= '1';
        dout.r <= sr.r;
        dout.phi <= dspr0.P( r_phi );
        dout.z <= dspr1.P( r_z );
        dout.dPhi <= sr.dPhi;
        dout.dZ <= sr.dZ;
    end if;

end if;
end process;

end;