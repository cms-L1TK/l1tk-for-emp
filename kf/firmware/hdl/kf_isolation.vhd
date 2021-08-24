library ieee;
use ieee.std_logic_1164.all;

use work.emp_device_decl.all;
use work.emp_data_types.all;

use work.tfp_config.all;
use work.tfp_data_types.all;

entity kf_isolation_in is
port (
    clk: in std_logic;
    in_din: in ldata( 4 * N_REGION - 1 downto 0 );
    in_dout: out t_channelsSF( numNodesKF - 1 downto 0 )
);
end;

architecture rtl of kf_isolation_in is

component kf_isolation_in_node
port (
    clk: in std_logic;
    node_din: in ldata( numLayers + 1 - 1 downto 0 );
    node_dout: out t_channelSF
);
end component;

begin

g: for k in 0 to numNodesKF - 1 generate

signal node_din: ldata( numLayers + 1 - 1 downto 0 ) := ( others => ( ( others => '0' ), '0', '0', '1' ) );
signal node_dout: t_channelSF := nulll;

begin

node_din <= in_din( ( k + 1 ) * ( numLayers + 1 ) - 1 downto k * ( numLayers + 1 ) );
in_dout( k ) <= node_dout;

c: kf_isolation_in_node port map ( clk, node_din, node_dout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;

use work.emp_device_decl.all;
use work.emp_data_types.all;

use work.tfp_tools.all;
use work.tfp_config.all;
use work.tfp_data_types.all;

entity kf_isolation_in_node is
port (
    clk: in std_logic;
    node_din: in ldata( numLayers + 1 - 1 downto 0 );
    node_dout: out t_channelSF
);
end;

architecture rtl of kf_isolation_in_node is

signal track_din: lword := ( ( others => '0' ), '0', '0', '1' );
signal track_dout: t_trackSF := nulll;
component kf_isolation_in_track
port (
    clk: in std_logic;
    track_din: in lword;
    track_dout: out t_trackSF
);
end component;

component kf_isolation_in_stub
port (
    clk: in std_logic;
    stub_din: in lword;
    stub_dout: out t_stubSF
);
end component;

begin

track_din <= node_din( 0 );
node_dout.track <= track_dout;

c: kf_isolation_in_track port map ( clk, track_din, track_dout );

g: for k in 0 to numLayers - 1 generate

signal stub_din: lword := ( ( others => '0' ), '0', '0', '1' );
signal stub_dout: t_stubSF := nulll;

begin

stub_din <= node_din( k + 1 );
node_dout.stubs( k ) <= stub_dout;

c: kf_isolation_in_stub port map ( clk, stub_din, stub_dout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;

use work.emp_data_types.all;

use work.tfp_tools.all;
use work.tfp_config.all;
use work.tfp_data_types.all;
use work.tfp_data_formats.all;

entity kf_isolation_in_track is
port (
    clk: in std_logic;
    track_din: in lword;
    track_dout: out t_trackSF
);
end;

architecture rtl of kf_isolation_in_track is

-- step 1
signal din: lword := ( ( others => '0' ), '0', '0', '1' );

-- step 2
signal dout: t_trackSF := nulll;

function conv( l: std_logic_vector ) return t_trackSF is
    variable s: t_trackSF := nulll;
begin
    s.valid  := l( 1 + widthSFhits + widthSFsector + widthSFphiT + widthSFinv2R + widthSFzT + widthSFcot - 1 );
    s.maybe  := l(     widthSFhits + widthSFsector + widthSFphiT + widthSFinv2R + widthSFzT + widthSFcot - 1 downto widthSFsector + widthSFphiT + widthSFinv2R + widthSFzT + widthSFcot );
    s.sector := l(                   widthSFsector + widthSFphiT + widthSFinv2R + widthSFzT + widthSFcot - 1 downto                 widthSFphiT + widthSFinv2R + widthSFzT + widthSFcot );
    s.phiT   := l(                                   widthSFphiT + widthSFinv2R + widthSFzT + widthSFcot - 1 downto                               widthSFinv2R + widthSFzT + widthSFcot );
    s.inv2R  := l(                                                 widthSFinv2R + widthSFzT + widthSFcot - 1 downto                                              widthSFzT + widthSFcot );
    s.zT     := l(                                                                widthSFzT + widthSFcot - 1 downto                                                          widthSFcot );
    s.cot    := l(                                                                            widthSFcot - 1 downto                                                                   0 );
    return s;
end function;

begin

-- step 2
track_dout <= dout;

process( clk ) is
begin
if rising_edge( clk ) then

    -- step 1

    din <= track_din;

    -- step 2

    dout <= nulll;
    if din.valid = '1' then
        dout <= conv( din.data );
    elsif track_din.valid = '1' then
        dout.reset <= '1';
    end if;

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;

use work.emp_data_types.all;

use work.tfp_tools.all;
use work.tfp_config.all;
use work.tfp_data_types.all;
use work.tfp_data_formats.all;

entity kf_isolation_in_stub is
port (
    clk: in std_logic;
    stub_din: in lword;
    stub_dout: out t_stubSF
);
end;

architecture rtl of kf_isolation_in_stub is

-- step 1
signal din: lword := ( ( others => '0' ), '0', '0', '1' );

-- step 2
signal dout: t_stubSF := nulll;

function conv( l: std_logic_vector ) return t_stubSF is
    variable s: t_stubSF := nulll;
begin
    s.valid := l( 1 + widthSFr + widthSFphi + widthSFz + widthSFdPhi + widthSFdZ - 1 );
    s.r     := l(     widthSFr + widthSFphi + widthSFz + widthSFdPhi + widthSFdZ - 1 downto widthSFphi + widthSFz + widthSFdPhi + widthSFdZ );
    s.phi   := l(                widthSFphi + widthSFz + widthSFdPhi + widthSFdZ - 1 downto              widthSFz + widthSFdPhi + widthSFdZ );
    s.z     := l(                             widthSFz + widthSFdPhi + widthSFdZ - 1 downto                         widthSFdPhi + widthSFdZ );
    s.dPhi  := l(                                        widthSFdPhi + widthSFdZ - 1 downto                                       widthSFdZ );
    s.dZ    := l(                                                      widthSFdZ - 1 downto                                               0 );
    return s;
end function;

begin

-- step 2
stub_dout <= dout;

process( clk ) is
begin
if rising_edge( clk ) then

    -- step 1

    din <= stub_din;

    -- step 2

    dout <= nulll;
    if din.valid = '1' then
        dout <= conv( din.data );
    elsif stub_din.valid = '1' then
        dout.reset <= '1';
    end if;

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;

use work.emp_device_decl.all;
use work.emp_data_types.all;

use work.tfp_tools.all;
use work.tfp_config.all;
use work.tfp_data_types.all;

entity kf_isolation_out is
port (
    clk: in std_logic;
    out_packet: in std_logic_vector( numNodesDR * ( numLayers + 1 ) - 1 downto 0 );
    out_din: in t_channelsKF( numNodesDR - 1 downto 0 );
    out_dout: out ldata( 4 * N_REGION - 1 downto 0 )
);
end;

architecture rtl of kf_isolation_out is

signal dout: ldata( 4 * N_REGION - 1 downto 0 ) := ( others => ( ( others => '0' ), '0', '0', '1' ) );
component kf_isolation_out_node
port (
    clk: in std_logic;
    node_packet: in std_logic_vector( numLayers + 1 - 1 downto 0 );
    node_din: in t_channelKF;
    node_dout: out ldata( numLayers + 1 - 1 downto 0 )
);
end component;

begin

out_dout <= dout;

node: for k in 0 to numNodesKF - 1 generate

signal node_packet: std_logic_vector( numLayers + 1 - 1 downto 0 ) := ( others => '0' );
signal node_din: t_channelKF := nulll;
signal node_dout: ldata( numLayers + 1 - 1 downto 0 ) := ( others => ( ( others => '0' ), '0', '0', '1' ) );

begin

node_packet <= out_packet( ( k + 1 ) * ( numLayers + 1 ) - 1 downto k * ( numLayers + 1 ) );
node_din <= out_din( k );
dout( ( k + 1 ) * ( numLayers + 1 ) - 1 downto k * ( numLayers + 1 ) ) <= node_dout;

c: kf_isolation_out_node port map ( clk, node_packet, node_din, node_dout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;

use work.emp_data_types.all;
use work.emp_project_decl.all;

use work.tfp_tools.all;
use work.tfp_config.all;
use work.tfp_data_types.all;

entity kf_isolation_out_node is
port (
    clk: in std_logic;
    node_packet: in std_logic_vector( numLayers + 1 - 1 downto 0 );
    node_din: in t_channelKF;
    node_dout: out ldata( numLayers + 1 - 1 downto 0 )
);
end;

architecture rtl of kf_isolation_out_node is

signal track_packet: std_logic := '0';
signal track_din: t_trackKF := nulll;
signal track_dout: lword := ( ( others => '0' ), '0', '0', '1' );
component kf_isolation_out_track
port (
    clk: in std_logic;
    track_packet: in std_logic;
    track_din: in t_trackKF;
    track_dout: out lword
);
end component;

component kf_isolation_out_stub
port (
    clk: in std_logic;
    stub_packet: in std_logic;
    stub_din: in t_stubKF;
    stub_dout: out lword
);
end component;

begin

track_packet <= node_packet( 0 );
track_din <= node_din.track;
node_dout( 0 ) <= track_dout;

c: kf_isolation_out_track port map ( clk, track_packet, track_din, track_dout );

g: for k in 0 to numLayers - 1 generate

signal stub_packet: std_logic := '0';
signal stub_din: t_stubKF := nulll;
signal stub_dout: lword := ( ( others => '0' ), '0', '0', '1' );

begin

stub_packet <= node_packet( k + 1 );
stub_din <= node_din.stubs( k );
node_dout( k + 1 ) <= stub_dout;

c: kf_isolation_out_stub port map ( clk, stub_packet, stub_din, stub_dout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;

use work.emp_data_types.all;
use work.emp_project_decl.all;

use work.tfp_tools.all;
use work.tfp_config.all;
use work.tfp_data_types.all;
use work.tfp_data_formats.all;

entity kf_isolation_out_track is
port (
    clk: in std_logic;
    track_packet: in std_logic;
    track_din: in t_trackKF;
    track_dout: out lword
);
end;

architecture rtl of kf_isolation_out_track is

constant widthTrack: natural := 1 + 1 + widthKFsector + widthKFphiT + widthKFinv2R + widthKFcot + widthKFzT;
-- sr
signal sr: std_logic_vector( PAYLOAD_LATENCY - 1 downto 0 ) := ( others => '0' );

-- step 1
signal din:  t_trackKF := nulll;
signal dout: lword := ( ( others => '0' ), '0', '0', '1' );

function conv( s: t_trackKF ) return std_logic_vector is
begin
    return s.valid & s.match & s.sector & s.phiT & s.inv2R & s.cot & s.zT;
end function;

begin

-- step 1
din <= track_din;
track_dout <= dout;

process( clk ) is
begin
if rising_edge( clk ) then

    -- sr

    sr <= sr( sr'high - 1 downto 0 ) & track_packet;

    -- step 1

    dout.valid <= '0';
    dout.data <= ( others => '0' );
    if msb( sr ) = '1' then
        dout.valid <= '1';
        dout.data( widthTrack - 1 downto 0  ) <= conv( din );
    end if;

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;

use work.emp_data_types.all;
use work.emp_project_decl.all;

use work.tfp_tools.all;
use work.tfp_config.all;
use work.tfp_data_types.all;
use work.tfp_data_formats.all;

entity kf_isolation_out_stub is
port (
    clk: in std_logic;
    stub_packet: in std_logic;
    stub_din: in t_stubKF;
    stub_dout: out lword
);
end;

architecture rtl of kf_isolation_out_stub is

constant widthStub: natural := 1 + widthKFr + widthKFphi + widthKFz + widthKFdPhi + widthKFdZ;
-- sr
signal sr: std_logic_vector( PAYLOAD_LATENCY - 1 downto 0 ) := ( others => '0' );

-- step 1
signal din:  t_stubKF := nulll;
signal dout: lword := ( ( others => '0' ), '0', '0', '1' );

function conv( s: t_stubKF ) return std_logic_vector is
begin
    return s.valid & s.r & s.phi & s.z & s.dPhi & s.dZ;
end function;

begin

-- step 1
din <= stub_din;
stub_dout <= dout;

process( clk ) is
begin
if rising_edge( clk ) then

    -- sr

    sr <= sr( sr'high - 1 downto 0 ) & stub_packet;

    -- step 1

    dout.valid <= '0';
    dout.data <= ( others => '0' );
    if msb( sr ) = '1' then
        dout.valid <= '1';
        dout.data( widthStub - 1 downto 0  ) <= conv( din );
    end if;

end if;
end process;

end;
