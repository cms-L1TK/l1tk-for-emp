library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.emp_device_decl.all;
use work.emp_data_types.all;

entity kf_isolation_in is
port (
    clk: in std_logic;
    in_din: in ldata( 4 * N_REGION - 1 downto 0 );
    in_dout: out t_trackDR
);
end;

architecture rtl of kf_isolation_in is

signal track_din: lword := nulll;
signal track_reset: std_logic := '0';
signal track_valid: std_logic := '0';
signal track_dout: t_parameterTrackDR := nulll;
component kf_isolation_in_track
port (
  clk: in std_logic;
  track_din: in lword;
  track_reset: out std_logic;
  track_valid: out std_logic;
  track_dout: out t_parameterTrackDR
);
end component;

signal stubs_din: ldata( 0 to numLayers - 1 ) := ( others => nulll );
signal stubs_hits: std_logic_vector( 0 to numLayers - 1 ) := ( others => '0' );
signal stubs_dout: t_parameterStubsDR( 0 to numLayers - 1 ) := ( others => nulll );
component kf_isolation_in_stubs
port (
  clk: in std_logic;
  stubs_din: in ldata( 0 to numLayers - 1 );
  stubs_hits: out std_logic_vector( 0 to numLayers - 1 );
  stubs_dout: out t_parameterStubsDR( 0 to numLayers - 1 )
);
end component;

function conv( l: ldata ) return ldata is
  variable res: ldata( 0 to numLayers - 1 );
begin
  for k in res'range loop
    res( k ) := l( k + 1 );
  end loop;
  return res;
end function;

begin

track_din <= in_din( 0 );
stubs_din <= conv( in_din );
in_dout <= ( ( track_reset, track_valid, stubs_hits ), track_dout, stubs_dout );

cTrack: kf_isolation_in_track port map ( clk, track_din, track_reset, track_valid, track_dout );

cStubs: kf_isolation_in_stubs port map ( clk, stubs_din, stubs_hits, stubs_dout );

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.emp_data_types.all;


entity kf_isolation_in_stubs is
port (
  clk: in std_logic;
  stubs_din: in ldata( 0 to numLayers - 1 );
  stubs_hits: out std_logic_vector( 0 to numLayers - 1 );
  stubs_dout: out t_parameterStubsDR( 0 to numLayers - 1 )
);
end;

architecture rtl of kf_isolation_in_stubs is

component kf_isolation_in_stub
port (
  clk: in std_logic;
  stub_din: in lword;
  stub_valid: out std_logic;
  stub_dout: out t_parameterStubDR
);
end component;

begin

g: for k in 0 to numLayers - 1 generate

signal stub_din: lword := nulll;
signal stub_valid: std_logic := '0';
signal stub_dout: t_parameterStubDR := nulll;

begin

stub_din <= stubs_din( k );
stubs_hits( k ) <= stub_valid;
stubs_dout( k ) <= stub_dout;

c: kf_isolation_in_stub port map ( clk, stub_din, stub_valid, stub_dout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_data_types.all;
use work.hybrid_data_formats.all;
use work.emp_data_types.all;


entity kf_isolation_in_track is
port (
  clk: in std_logic;
  track_din: in lword;
  track_reset: out std_logic;
  track_valid: out std_logic;
  track_dout: out t_parameterTrackDR
);
end;

architecture rtl of kf_isolation_in_track is

-- step 1
signal din: lword := nulll;

-- step 2
signal reset: std_logic := '0';
signal valid: std_logic := '0';
signal dout: t_parameterTrackDR := nulll;

begin

-- step 2
track_reset <= reset;
track_valid <= valid;
track_dout <= dout;

process( clk ) is
begin
if rising_edge( clk ) then

  -- step 1

  din <= track_din;

  -- step 2

  reset <= '0';
  valid <= '0';
  dout <= nulll;
  if din.valid = '1' then
    valid      <= din.data( widthDRinv2R + widthDRphiT + widthDRzT );
    dout.inv2R <= din.data( widthDRinv2R + widthDRphiT + widthDRzT - 1 downto widthDRphiT + widthDRzT );
    dout.phiT  <= din.data(                widthDRphiT + widthDRzT - 1 downto               widthDRzT );
    dout.zT    <= din.data(                              widthDRzT - 1 downto                       0 );
  elsif track_din.valid = '1' then
    reset <= '1';
  end if;

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_data_types.all;
use work.hybrid_data_formats.all;
use work.emp_data_types.all;

entity kf_isolation_in_stub is
port (
  clk: in std_logic;
  stub_din: in lword;
  stub_valid: out std_logic;
  stub_dout: out t_parameterStubDR
);
end;

architecture rtl of kf_isolation_in_stub is

-- step 1
signal din: lword := nulll;

-- step 2
signal valid: std_logic := '0';
signal dout: t_parameterStubDR := nulll;

begin

-- step 2
stub_valid <= valid;
stub_dout <= dout;

process( clk ) is
begin
if rising_edge( clk ) then

  -- step 1

  din <= stub_din;

  -- step 2

  valid <= '0';
  dout <= nulll;
  if din.valid = '1' then
    valid     <= din.data( widthDRr + widthDRphi + widthDRz + widthDRdPhi + widthDRdZ );
    dout.r    <= din.data( widthDRr + widthDRphi + widthDRz + widthDRdPhi + widthDRdZ - 1 downto widthDRphi + widthDRz + widthDRdPhi + widthDRdZ );
    dout.phi  <= din.data(            widthDRphi + widthDRz + widthDRdPhi + widthDRdZ - 1 downto              widthDRz + widthDRdPhi + widthDRdZ );
    dout.z    <= din.data(                         widthDRz + widthDRdPhi + widthDRdZ - 1 downto                         widthDRdPhi + widthDRdZ );
    dout.dPhi <= din.data(                                    widthDRdPhi + widthDRdZ - 1 downto                                       widthDRdZ );
    dout.dZ   <= din.data(                                                  widthDRdZ - 1 downto                                               0 );
  end if;

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.emp_device_decl.all;
use work.emp_data_types.all;

entity kf_isolation_out is
port (
  clk: in std_logic;
  out_packet: in t_packets( 0 to numLinksTrack - 1 );
  out_din: in t_trackKF;
  out_dout: out ldata( 4 * N_REGION - 1 downto 0 )
);
end;

architecture rtl of kf_isolation_out is

signal track_packet: t_packet := ( others => '0' );
signal track_din: t_parameterTrackKF := nulll;
signal track_valid: std_logic := '0';
signal track_dout: lword := nulll;
component kf_isolation_out_track
port (
  clk: in std_logic;
  track_packet: in t_packet;
  track_din: in t_parameterTrackKF;
  track_valid: in std_logic;
  track_dout: out lword
);
end component;

signal stubs_packet: t_packets( 0 to numLayers - 1 ) := ( others => ( others => '0' ) );
signal stubs_din: t_parameterStubsKF( 0 to numLayers - 1 ) := ( others => nulll );
signal stubs_hits: std_logic_vector( 0 to numLayers - 1 ) := ( others => '0' );
signal stubs_dout: ldata( 0 to numLayers - 1 ) := ( others => nulll );
component kf_isolation_out_stubs
port (
  clk: in std_logic;
  stubs_packet: in t_packets( 0 to numLayers - 1 );
  stubs_din: in t_parameterStubsKF( 0 to numLayers - 1 );
  stubs_hits: in std_logic_vector( 0 to numLayers - 1 );
  stubs_dout: out ldata( 0 to numLayers - 1 )
);
end component;

function conv( track: lword; stubs: ldata ) return ldata is
  variable res: ldata( 4 * N_REGION - 1 downto 0 ) := ( others => nulll );
begin
  res( 0 ) := track;
  for k in stubs'range loop
    res( k + 1 ) := stubs( k );
  end loop;
  return res;
end function;

begin

track_packet <= out_packet( 0 );
track_din <= out_din.track;
track_valid <= out_din.meta.valid;

stubs_packet <= out_packet( 1 to numLayers );
stubs_din <= out_din.stubs;
stubs_hits <= out_din.meta.hits;

out_dout <= conv( track_dout, stubs_dout );

cTrack: kf_isolation_out_track port map ( clk, track_packet, track_din, track_valid, track_dout );

cStubs: kf_isolation_out_stubs port map ( clk, stubs_packet, stubs_din, stubs_hits, stubs_dout );

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.emp_data_types.all;

entity kf_isolation_out_stubs is
port (
  clk: in std_logic;
  stubs_packet: in t_packets( 0 to numLayers - 1 );
  stubs_din: in t_parameterStubsKF( 0 to numLayers - 1 );
  stubs_hits: in std_logic_vector( 0 to numLayers - 1 );
  stubs_dout: out ldata( 0 to numLayers - 1 )
);
end;

architecture rtl of kf_isolation_out_stubs is

component kf_isolation_out_stub
port (
  clk: in std_logic;
  stub_packet: in t_packet;
  stub_din: in t_parameterStubKF;
  stub_valid: in std_logic;
  stub_dout: out lword
);
end component;

begin

g: for k in 0 to numLayers - 1 generate

signal stub_packet: t_packet := ( others => '0' );
signal stub_din: t_parameterStubKF := nulll;
signal stub_valid: std_logic := '0';
signal stub_dout: lword := nulll;

begin

stub_packet <= stubs_packet( k );
stub_din <= stubs_din( k );
stub_valid <= stubs_hits( k );
stubs_dout( k ) <= stub_dout;

c: kf_isolation_out_stub port map ( clk, stub_packet, stub_din, stub_valid, stub_dout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_data_types.all;
use work.hybrid_data_formats.all;
use work.emp_data_types.all;
use work.emp_project_decl.all;

entity kf_isolation_out_track is
port (
  clk: in std_logic;
  track_packet: in t_packet;
  track_din: in t_parameterTrackKF;
  track_valid: in std_logic;
  track_dout: out lword
);
end;

architecture rtl of kf_isolation_out_track is

constant widthTrack: natural := 1 + widthKFinv2R + widthKFphiT + widthKFcot + widthKFzT;
-- sr
signal sr: t_packets( PAYLOAD_LATENCY - 1 downto 0 ) := ( others => ( others => '0' ) );

-- step 1
signal dout: lword := nulll;

function conv( v: std_logic; t: t_parameterTrackKF ) return std_logic_vector is
begin
  return v & t.inv2R & t.phiT & t.cot & t.zT;
end function;

begin

-- step 1
track_dout <= dout;

process( clk ) is
begin
if rising_edge( clk ) then

  -- sr

  sr <= sr( sr'high - 1 downto 0 ) & track_packet;

  -- step 1

  dout.start_of_orbit <= sr( sr'high ).start_of_orbit;
  dout.valid <= '0';
  dout.data <= ( others => '0' );
  if sr( sr'high ).valid = '1' then
    dout.valid <= '1';
    dout.data( widthTrack - 1 downto 0  ) <= conv( track_valid, track_din );
  end if;

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_data_types.all;
use work.hybrid_data_formats.all;
use work.emp_data_types.all;
use work.emp_project_decl.all;

entity kf_isolation_out_stub is
port (
  clk: in std_logic;
  stub_packet: in t_packet;
  stub_din: in t_parameterStubKF;
  stub_valid: in std_logic;
  stub_dout: out lword
);
end;

architecture rtl of kf_isolation_out_stub is

constant widthStub: natural := 1 + widthKFr + widthKFphi + widthKFz + widthKFdPhi + widthKFdZ;
-- sr
signal sr: t_packets( PAYLOAD_LATENCY - 1 downto 0 ) := ( others => ( others => '0' ) );

-- step 1
signal dout: lword := nulll;

function conv( v: std_logic; s: t_parameterStubKF ) return std_logic_vector is
begin
  return v & s.r & s.phi & s.z & s.dPhi & s.dZ;
end function;

begin

-- step 1
stub_dout <= dout;

process( clk ) is
begin
if rising_edge( clk ) then

  -- sr

  sr <= sr( sr'high - 1 downto 0 ) & stub_packet;

  -- step 1

  dout.start_of_orbit <= sr( sr'high ).start_of_orbit;
  dout.valid <= '0';
  dout.data <= ( others => '0' );
  if sr( sr'high ).valid = '1' then
    dout.valid <= '1';
    dout.data( widthStub - 1 downto 0  ) <= conv( stub_valid, stub_din );
  end if;

end if;
end process;

end;
