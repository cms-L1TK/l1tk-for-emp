library ieee;
use ieee.std_logic_1164.all;

use work.tfp_config.all;
use work.tfp_data_types.all;
use work.kf_data_types.all;

entity kf_delay is
port (
    clk: in std_logic;
    delay_track: in t_trackSF;
    delay_channel: in t_channelProto;
    delay_fit: out t_channelProto;
    delay_residual: out t_stubsProto( numLayers - 1 downto 0 );
    delay_format: out t_trackSF
);
end;

architecture rtl of kf_delay is

signal state: t_stateProto := nulll;

signal fit_din: t_stubsProto( numLayers - 1 downto 0 ) := ( others => nulll );
signal fit_dout: t_stubsProto( numLayers - 1 downto 0 ) := ( others => nulll );
component kf_delay_fit
port (
    clk: in std_logic;
    fit_din: in t_stubsProto( numLayers - 1 downto 0 );
    fit_dout: out t_stubsProto( numLayers - 1 downto 0 )
);
end component;

signal residual_din: t_stubsProto( numLayers - 1 downto 0 ) := ( others => nulll );
signal residual_dout: t_stubsProto( numLayers - 1 downto 0 ) := ( others => nulll );
component kf_delay_residual
port (
    clk: in std_logic;
    residual_din: in t_stubsProto( numLayers - 1 downto 0 );
    residual_dout: out t_stubsProto( numLayers - 1 downto 0 )
);
end component;

signal format_din: t_trackSF := nulll;
signal format_dout: t_trackSF := nulll;
component kf_delay_format
port (
    clk: in std_logic;
    format_din: in t_trackSF;
    format_dout: out t_trackSF
);
end component;

begin

process( clk ) is
begin
if rising_edge( clk ) then

    state <= delay_channel.state;

end if;
end process;

fit_din <= delay_channel.stubs;

delay_fit <= ( state, fit_dout );
residual_din <= fit_dout;

delay_residual <= residual_dout;

format_din <= delay_track;

delay_format <= format_dout;

fit: kf_delay_fit port map ( clk, fit_din, fit_dout );

residual: kf_delay_residual port map ( clk, residual_din, residual_dout );

format: kf_delay_format port map ( clk, format_din, format_dout );

end;


library ieee;
use ieee.std_logic_1164.all;

use work.tfp_config.all;
use work.kf_data_types.all;

entity kf_delay_fit is
port (
    clk: in std_logic;
    fit_din: in t_stubsProto( numLayers - 1 downto 0 );
    fit_dout: out t_stubsProto( numLayers - 1 downto 0 )
);
end;

architecture rtl of kf_delay_fit is

component kf_delay_stub
generic (
    latency: integer
);
port (
    clk: in std_logic;
    stub_din: in t_stubProto;
    stub_dout: out t_stubProto
);
end component;

begin

g: for k in 0 to numLayers - 1 generate

constant latency: integer := 1 + k * ( 4 + 16 + 1 );
signal stub_din: t_stubProto := nulll;
signal stub_dout: t_stubProto := nulll;

begin

stub_din <= fit_din( k );
fit_dout( k ) <= stub_dout;

c: kf_delay_stub generic map ( latency ) port map ( clk, stub_din, stub_dout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;

use work.tfp_config.all;
use work.tfp_data_types.all;
use work.kf_data_types.all;

entity kf_delay_residual is
port (
    clk: in std_logic;
    residual_din: in t_stubsProto( numLayers - 1 downto 0 );
    residual_dout: out t_stubsProto( numLayers - 1 downto 0 )
);
end;

architecture rtl of kf_delay_residual is

component kf_delay_stub
generic (
    latency: integer
);
port (
    clk: in std_logic;
    stub_din: in t_stubProto;
    stub_dout: out t_stubProto
);
end component;

begin

g: for k in 0 to numLayers - 1 generate

constant latency: integer := 1 + 2 + numLayers * ( 4 + 16 ) - k * ( 4 + 16 + 1 ) - 1;

signal stub_din: t_stubProto := nulll;
signal stub_dout: t_stubProto := nulll;

begin

stub_din <= residual_din( k );
residual_dout( k ) <= stub_dout;

c: kf_delay_stub generic map ( latency ) port map ( clk, stub_din, stub_dout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;

use work.tfp_config.all;
use work.tfp_data_types.all;

entity kf_delay_format is
port (
    clk: in std_logic;
    format_din: in t_trackSF;
    format_dout: out t_trackSF
);
end;

architecture rtl of kf_delay_format is

signal event_din: t_trackSF := nulll;
signal event_dout: t_trackSF := nulll;
component kf_delay_event
port (
    clk: in std_logic;
    event_din: in t_trackSF;
    event_dout: out t_trackSF
);
end component;

signal track_din: t_trackSF := nulll;
signal track_dout: t_trackSF := nulll;
component kf_delay_track
port (
    clk: in std_logic;
    track_din: in t_trackSF;
    track_dout: out t_trackSF
);
end component;

begin

event_din <= format_din;
track_din <= event_dout;
format_dout <= track_dout;

event: kf_delay_event port map ( clk, event_din, event_dout );

track: kf_delay_track port map ( clk, track_din, track_dout );

end;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.tfp_config.all;
use work.tfp_data_types.all;
use work.tfp_data_formats.all;
use work.tfp_tools.all;

entity kf_delay_event is
port (
    clk: in std_logic;
    event_din: in t_trackSF;
    event_dout: out t_trackSF
);
end;

architecture rtl of kf_delay_event is

attribute ram_style: string;
constant widthAddr: natural := widthFrames;
constant widthRam: natural := widthSFhits + widthSFsector + widthSFinv2R + widthSFphiT + widthSFcot + widthSFzT;
type t_ram is array ( 0 to 2 ** widthAddr - 1 ) of std_logic_vector( widthRam - 1 downto 0 );
function conv( s: std_logic_vector ) return t_trackSF is
    variable t: t_trackSF := nulll;
begin
    t.maybe  := s( widthSFhits + widthSFsector + widthSFinv2R + widthSFphiT + widthSFcot + widthSFzT - 1 downto widthSFsector + widthSFinv2R + widthSFphiT + widthSFcot + widthSFzT );
    t.sector := s(               widthSFsector + widthSFinv2R + widthSFphiT + widthSFcot + widthSFzT - 1 downto                 widthSFinv2R + widthSFphiT + widthSFcot + widthSFzT );
    t.inv2R  := s(                               widthSFinv2R + widthSFphiT + widthSFcot + widthSFzT - 1 downto                                widthSFphiT + widthSFcot + widthSFzT );
    t.phiT   := s(                                              widthSFphiT + widthSFcot + widthSFzT - 1 downto                                              widthSFcot + widthSFzT );
    t.cot    := s(                                                            widthSFcot + widthSFzT - 1 downto                                                           widthSFzT );
    t.zT     := s(                                                                         widthSFzT - 1 downto                                                                   0 );
    return t;
end function;
function conv( t: t_trackSF ) return std_logic_vector is
begin
    return t.maybe & t.sector & t.inv2R & t.phiT & t.cot & t.zT;
end function;

-- step 1

signal ram: t_ram := ( others => ( others => '0' ) );
signal waddr, raddr, laddr: std_logic_vector( widthAddr - 1 downto 0 ) := ( others => '0' );
signal optional: t_trackSF := nulll;
attribute ram_style of ram: signal is "block";

-- step 2

signal dout: t_trackSF := nulll;

begin

-- step 2
event_dout <= dout;

process( clk ) is
begin
if rising_edge( clk ) then

    -- step 1;

    ram( uint( waddr ) ) <= conv( event_din );
    optional <= conv( ram( uint( raddr ) ) );
    if event_din.valid = '1' then
        waddr <= incr( waddr );
    end if;
    if raddr /= laddr then
        optional.valid <= '1';
        raddr <= incr( raddr );
    end if;

    if event_din.reset = '1' then
        optional.reset <= '1';
        raddr <= laddr;
        laddr <= waddr;
    end if;

    -- step 2

    dout <= nulll;
    if optional.valid = '1' then
        dout <= optional;
    end if;

    if optional.reset = '1' then
        dout.reset <= '1';
    end if;

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.tfp_config.all;
use work.tfp_data_types.all;
use work.tfp_data_formats.all;
use work.tfp_tools.all;

entity kf_delay_track is
port (
    clk: in std_logic;
    track_din: in t_trackSF;
    track_dout: out t_trackSF
);
end;

architecture rtl of kf_delay_track is

attribute ram_style: string;
constant latency: natural := 1 + numLayers * ( 5 + 16 - 1 ) + 7 + 2 - 3 + 1 + 5 - 2 - 5 + 10 - 2 + 1;
constant widthAddr: natural := widthFrames;
constant widthRam: natural := 1 + 1 + widthSFhits + widthSFsector + widthSFinv2R + widthSFphiT + widthSFcot + widthSFzT;
type t_ram is array ( 0 to 2 ** widthAddr - 1 ) of std_logic_vector( widthRam - 1 downto 0 );
function conv( s: std_logic_vector ) return t_trackSF is
    variable t: t_trackSF := nulll;
begin
    t.reset  := s( 1 + 1 + widthSFhits + widthSFsector + widthSFinv2R + widthSFphiT + widthSFcot + widthSFzT - 1);
    t.valid  := s(     1 + widthSFhits + widthSFsector + widthSFinv2R + widthSFphiT + widthSFcot + widthSFzT - 1);
    t.maybe  := s(         widthSFhits + widthSFsector + widthSFinv2R + widthSFphiT + widthSFcot + widthSFzT - 1 downto widthSFsector + widthSFinv2R + widthSFphiT + widthSFcot + widthSFzT );
    t.sector := s(                       widthSFsector + widthSFinv2R + widthSFphiT + widthSFcot + widthSFzT - 1 downto                 widthSFinv2R + widthSFphiT + widthSFcot + widthSFzT );
    t.inv2R  := s(                                       widthSFinv2R + widthSFphiT + widthSFcot + widthSFzT - 1 downto                                widthSFphiT + widthSFcot + widthSFzT );
    t.phiT   := s(                                                      widthSFphiT + widthSFcot + widthSFzT - 1 downto                                              widthSFcot + widthSFzT );
    t.cot    := s(                                                                    widthSFcot + widthSFzT - 1 downto                                                           widthSFzT );
    t.zT     := s(                                                                                 widthSFzT - 1 downto                                                                   0 );
    return t;
end function;
function conv( t: t_trackSF ) return std_logic_vector is
begin
    return t.reset & t.valid & t.maybe & t.sector & t.inv2R & t.phiT & t.cot & t.zT;
end function;

-- step 1

signal ram: t_ram := ( others => ( others => '0' ) );
signal waddr, raddr: std_logic_vector( widthAddr - 1 downto 0 ) := ( others => '0' );
signal optional: t_trackSF := nulll;
attribute ram_style of ram: signal is "block";

-- step 2

signal dout: t_trackSF := nulll;

begin

-- step 1
waddr <= std_logic_vector( unsigned( raddr ) + latency );

-- track_dout 2
track_dout <= dout;

process( clk ) is
begin
if rising_edge( clk ) then

    -- step 1;

    ram( uint( waddr ) ) <= conv( track_din );
    optional <= conv( ram( uint( raddr ) ) );
    raddr <= incr( raddr );

    -- step 2

    dout <= optional;

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.tfp_config.all;
use work.kf_data_types.all;
use work.tfp_data_formats.all;
use work.kf_data_formats.all;
use work.tfp_tools.all;

entity kf_delay_stub is
generic (
    latency: natural
);
port (
    clk: in std_logic;
    stub_din: in t_stubProto;
    stub_dout: out t_stubProto
);
end;

architecture rtl of kf_delay_stub is

attribute ram_style: string;
constant widthAddr: natural := widthFrames;
constant widthRam: natural := 1 + 1 + widthTrack + widthSFr + widthSFphi + widthSFz + widthSFdPhi + widthSFdZ;
type t_ram is array ( 0 to 2 ** widthAddr - 1 ) of std_logic_vector( widthRam - 1 downto 0 );
function conv( s: std_logic_vector ) return t_stubProto is
    variable t: t_stubProto := nulll;
begin
    t.reset := s( 1 + 1 + widthTrack + widthSFr + widthSFphi + widthSFz + widthSFdPhi + widthSFdZ - 1 );
    t.valid := s(   + 1 + widthTrack + widthSFr + widthSFphi + widthSFz + widthSFdPhi + widthSFdZ - 1 );
    t.track := s(         widthTrack + widthSFr + widthSFphi + widthSFz + widthSFdPhi + widthSFdZ - 1 downto widthSFr + widthSFphi + widthSFz + widthSFdPhi + widthSFdZ );
    t.r     := s(                      widthSFr + widthSFphi + widthSFz + widthSFdPhi + widthSFdZ - 1 downto            widthSFphi + widthSFz + widthSFdPhi + widthSFdZ );
    t.phi   := s(                                 widthSFphi + widthSFz + widthSFdPhi + widthSFdZ - 1 downto                         widthSFz + widthSFdPhi + widthSFdZ );
    t.z     := s(                                              widthSFz + widthSFdPhi + widthSFdZ - 1 downto                                    widthSFdPhi + widthSFdZ );
    t.dPhi  := s(                                                         widthSFdPhi + widthSFdZ - 1 downto                                                  widthSFdZ );
    t.dZ    := s(                                                                       widthSFdZ - 1 downto                                                          0 );
    return t;
end function;
function conv( t: t_stubProto ) return std_logic_vector is
begin
    return t.reset & t.valid & t.track & t.r & t.phi & t.z & t.dPhi & t.dZ;
end function;

-- step 1

signal ram: t_ram := ( others => ( others => '0' ) );
signal waddr, raddr: std_logic_vector( widthAddr - 1 downto 0 ) := ( others => '0' );
signal optional: t_stubProto := nulll;
attribute ram_style of ram: signal is "block";

-- step 2

signal dout: t_stubProto := nulll;

begin

-- step 1
waddr <= std_logic_vector( unsigned( raddr ) + latency );

-- track_dout 2
stub_dout <= dout;

process( clk ) is
begin
if rising_edge( clk ) then

    -- step 1;

    ram( uint( waddr ) ) <= conv( stub_din );
    optional <= conv( ram( uint( raddr ) ) );
    raddr <= incr( raddr );

    -- step 2

    dout <= optional;

end if;
end process;

end;