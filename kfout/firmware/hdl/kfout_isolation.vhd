library ieee;
use ieee.std_logic_1164.all;

use work.emp_device_decl.all;
use work.emp_data_types.all;

use work.hybrid_config.all;
use work.hybrid_data_types.all;

entity kfout_isolation_in is
port (
    clk: in std_logic;
    in_din: in ldata( 4 * N_REGION - 1 downto 0 );
    in_dout: out t_channelsKF( numNodesKF - 1 downto 0 )
);
end;

architecture rtl of kfout_isolation_in is

component kfout_isolation_in_node
port (
    clk: in std_logic;
    node_din: in ldata( numLayers + 1 - 1 downto 0 );
    node_dout: out t_channelKF
);
end component;

begin

g: for k in 0 to numNodesKF - 1 generate

signal node_din: ldata( numLayers + 1 - 1 downto 0 ) := ( others => ( ( others => '0' ), '0', '0', '1' ) );
signal node_dout: t_channelKF := nulll;

begin

node_din <= in_din( ( k + 1 ) * ( numLayers + 1 ) - 1 downto k * ( numLayers + 1 ) );
in_dout( k ) <= node_dout;

c: kfout_isolation_in_node port map ( clk, node_din, node_dout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;

use work.emp_device_decl.all;
use work.emp_data_types.all;

use work.hybrid_config.all;
use work.hybrid_data_types.all;

entity kfout_isolation_in_node is
port (
    clk: in std_logic;
    node_din: in ldata( numLayers + 1 - 1 downto 0 );
    node_dout: out t_channelKF
);
end;

architecture rtl of kfout_isolation_in_node is

signal track_din: lword := ( ( others => '0' ), '0', '0', '1' );
signal track_dout: t_trackKF := nulll;
component kfout_isolation_in_track
port (
    clk: in std_logic;
    track_din: in lword;
    track_dout: out t_trackKF
);
end component;

component kfout_isolation_in_stub
port (
    clk: in std_logic;
    stub_din: in lword;
    stub_dout: out t_stubKF
);
end component;

begin

track_din <= node_din( 0 );
node_dout.track <= track_dout;

c: kfout_isolation_in_track port map ( clk, track_din, track_dout );

g: for k in 0 to numLayers - 1 generate

signal stub_din: lword := ( ( others => '0' ), '0', '0', '1' );
signal stub_dout: t_stubKF := nulll;

begin

stub_din <= node_din( k + 1 );
node_dout.stubs( k ) <= stub_dout;

c: kfout_isolation_in_stub port map ( clk, stub_din, stub_dout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;

use work.emp_data_types.all;

use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.hybrid_data_formats.all;

entity kfout_isolation_in_track is
port (
    clk: in std_logic;
    track_din: in lword;
    track_dout: out t_trackKF
);
end;

architecture rtl of kfout_isolation_in_track is

-- step 1
signal din: lword := ( ( others => '0' ), '0', '0', '1' );

-- step 2
signal dout: t_trackKF := nulll;

function conv( l: std_logic_vector ) return t_trackKF is
  variable s: t_trackKF := nulll;
begin
  s.valid  := l( 1 + 1 +  widthKFsector + widthKFphiT + widthKFinv2R + widthKFcot + widthKFzT - 1 );
  s.match  := l(     1 +  widthKFsector + widthKFphiT + widthKFinv2R + widthKFcot + widthKFzT - 1 );
  s.sector := l(          widthKFsector + widthKFphiT + widthKFinv2R + widthKFcot + widthKFzT - 1 downto  widthKFphiT + widthKFinv2R + widthKFcot + widthKFzT );
  s.phiT   := l(                          widthKFphiT + widthKFinv2R + widthKFcot + widthKFzT - 1 downto                widthKFinv2R + widthKFcot + widthKFzT );
  s.inv2R  := l(                                        widthKFinv2R + widthKFcot + widthKFzT - 1 downto                               widthKFcot + widthKFzT );
  s.cot    := l(                                                       widthKFcot + widthKFzT - 1 downto                                            widthKFzT );
  s.zT     := l(                                                                    widthKFzT - 1 downto                                                    0 );

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

use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.hybrid_data_formats.all;

entity kfout_isolation_in_stub is
port (
    clk: in std_logic;
    stub_din: in lword;
    stub_dout: out t_stubKF
);
end;

architecture rtl of kfout_isolation_in_stub is

-- step 1
signal din: lword := ( ( others => '0' ), '0', '0', '1' );

-- step 2
signal dout: t_stubKF := nulll;

function conv( l: std_logic_vector ) return t_stubKF is
  variable s: t_stubKF := nulll;
begin
  s.valid := l( 1 + widthKFr + widthKFphi + widthKFz + widthKFdPhi + widthKFdZ - 1 );
  s.r     := l(     widthKFr + widthKFphi + widthKFz + widthKFdPhi + widthKFdZ - 1 downto widthKFphi + widthKFz + widthKFdPhi + widthKFdZ );
  s.phi   := l(                widthKFphi + widthKFz + widthKFdPhi + widthKFdZ - 1 downto              widthKFz + widthKFdPhi + widthKFdZ );
  s.z     := l(                             widthKFz + widthKFdPhi + widthKFdZ - 1 downto                         widthKFdPhi + widthKFdZ );
  s.dPhi  := l(                                        widthKFdPhi + widthKFdZ - 1 downto                                       widthKFdZ );
  s.dZ    := l(                                                      widthKFdZ - 1 downto                                               0 );

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

use work.hybrid_config.all;
use work.hybrid_data_types.all;

entity kfout_isolation_out is
port (
    clk: in std_logic;
    out_packet: in std_logic_vector( numLinksTFP - 1 downto 0 );
    out_din: in t_frames( numLinksTFP - 1 downto 0 );
    out_dout: out ldata( numLinksTFP - 1 downto 0 )  
);
end;

architecture rtl of kfout_isolation_out is

signal dout: ldata( numLinksTFP - 1 downto 0 ) := ( others => ( ( others => '0' ), '0', '0', '1' ) );
component kfout_isolation_out_node
port (
    clk: in std_logic;
    node_packet: in std_logic;
    node_din: in t_frame;
    node_dout: out lword
);
end component;

begin

out_dout <= dout;

node: for k in 0 to numLinksTFP - 1 generate

signal node_packet: std_logic := '0';
signal node_din: t_frame := ( others => '0' );
signal node_dout: lword := ( ( others => '0' ), '0', '0', '1' );

begin

node_packet <= out_packet( k );
node_din <= out_din( k );
dout( k ) <= node_dout;

c: kfout_isolation_out_node port map ( clk, node_packet, node_din, node_dout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;

use work.emp_data_types.all;
use work.emp_project_decl.all;

use work.hybrid_config.all;
use work.hybrid_data_types.all;

entity kfout_isolation_out_node is
port (
    clk: in std_logic;
    node_packet: in std_logic;
    node_din: in t_frame;
    node_dout: out lword
);
end;

architecture rtl of kfout_isolation_out_node is

-- sr
signal sr: std_logic_vector( PAYLOAD_LATENCY - 1 downto 0 ) := ( others => '0' );

-- step 1
signal din:  t_frame := ( others => '0' );
signal dout: lword := ( ( others => '0' ), '0', '0', '1' );

begin

-- step 1
node_dout <= dout;

process( clk ) is
begin
if rising_edge( clk ) then

    -- sr

    sr <= sr( sr'high - 1 downto 0 ) & node_packet;

    -- step 1

    dout.valid <= '0';
    dout.data <= ( others => '0' );
    if sr( sr'high ) = '1' then
        dout.valid <= '1';
        dout.data <= node_din;
    end if;

end if;
end process;

end;