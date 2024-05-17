library ieee;
use ieee.std_logic_1164.all;
use work.emp_device_decl.all;
use work.emp_data_types.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;

entity dr_isolation_in is
port (
  clk: in std_logic;
  in_din: in ldata( 4 * N_REGION - 1 downto 0 );
  in_dout: out t_channelTM
);
end;

architecture rtl of dr_isolation_in is

signal track_din: lword := nulll;
signal track_dout: t_trackTM := nulll;
component dr_isolation_in_track
port (
  clk: in std_logic;
  track_din: in lword;
  track_dout: out t_trackTM
);
end component;

signal stubs_din: ldata( numLayers - 1 downto 0 ) := ( others => nulll );
signal stubs_dout: t_stubsTM( numLayers - 1 downto 0 ) := ( others => nulll );
component dr_isolation_in_stubs
port (
  clk: in std_logic;
  stubs_din: in ldata( numLayers - 1 downto 0 );
  stubs_dout: out t_stubsTM( numLayers - 1 downto 0 )
);
end component;

begin

track_din <= in_din( 0 );
stubs_din <= in_din( numLayers + 1 - 1 downto 1 );

in_dout <= ( track_dout, stubs_dout );

cTrack: dr_isolation_in_track port map ( clk, track_din, track_dout );

cStubs: dr_isolation_in_stubs port map ( clk, stubs_din, stubs_dout );

end;


library ieee;
use ieee.std_logic_1164.all;
use work.emp_data_types.all;
use work.hybrid_config.all;
use work.hybrid_data_formats.all;
use work.hybrid_data_types.all;

entity dr_isolation_in_track is
port (
  clk: in std_logic;
  track_din: in lword;
  track_dout: out t_trackTM
);
end;

architecture rtl of dr_isolation_in_track is

-- step 1
signal din: lword := nulll;

-- step 2
signal dout: t_trackTM := nulll;

function conv( l: lword ) return t_trackTM is
  variable t: t_trackTM := nulll;
begin
  t.valid := l.data( widthTMinv2R + widthTMphiT + widthTMzT );
  t.inv2R := l.data( widthTMinv2R + widthTMphiT + widthTMzT - 1 downto widthTMphiT + widthTMzT );
  t.phiT  := l.data(                widthTMphiT + widthTMzT - 1 downto               widthTMzT );
  t.zT    := l.data(                              widthTMzT - 1 downto                       0 );
  return t;
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
    dout <= conv( din );
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
use work.hybrid_data_formats.all;
use work.hybrid_data_types.all;

entity dr_isolation_in_stubs is
port (
  clk: in std_logic;
  stubs_din: in ldata( numLayers - 1 downto 0 );
  stubs_dout: out t_stubsTM( numLayers - 1 downto 0 )
);
end;

architecture rtl of dr_isolation_in_stubs is

component dr_isolation_in_stub
port (
  clk: in std_logic;
  stub_din: in lword;
  stub_dout: out t_stubTM
);
end component;

begin

g: for k in 0 to numLayers - 1 generate

signal stub_din: lword := nulll;
signal stub_dout: t_stubTM := nulll;

begin

stub_din <= stubs_din( k );
stubs_dout( k ) <= stub_dout;

c: dr_isolation_in_stub port map ( clk, stub_din, stub_dout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.emp_data_types.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.hybrid_data_formats.all;

entity dr_isolation_in_stub is
port (
  clk: in std_logic;
  stub_din: in lword;
  stub_dout: out t_stubTM
);
end;

architecture rtl of dr_isolation_in_stub is

-- step 1
signal din: lword := nulll;

-- step 2
signal dout: t_stubTM := nulll;

function conv( l: lword ) return t_stubTM is
  variable t: t_stubTM := nulll;
begin
    t.valid  := l.data( widthTMstubId + widthTMr + widthTMphi + widthTMz + widthTMdPhi + widthTMdZ);
    t.stubId := l.data( widthTMstubId + widthTMr + widthTMphi + widthTMz + widthTMdPhi + widthTMdZ - 1 downto widthTMr + widthTMphi + widthTMz + widthTMdPhi + widthTMdZ );
    t.r      := l.data(                 widthTMr + widthTMphi + widthTMz + widthTMdPhi + widthTMdZ - 1 downto            widthTMphi + widthTMz + widthTMdPhi + widthTMdZ );
    t.phi    := l.data(                            widthTMphi + widthTMz + widthTMdPhi + widthTMdZ - 1 downto                         widthTMz + widthTMdPhi + widthTMdZ );
    t.z      := l.data(                                         widthTMz + widthTMdPhi + widthTMdZ - 1 downto                                    widthTMdPhi + widthTMdZ );
    t.dPhi   := l.data(                                                    widthTMdPhi + widthTMdZ - 1 downto                                                  widthTMdZ );
    t.dZ     := l.data(                                                                  widthTMdZ - 1 downto                                                          0 );
  return t;
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
    dout <= conv( din );
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

entity dr_isolation_out is
port (
  clk: in std_logic;
  out_packet: in t_packets( drNumLinks - 1 downto 0 );
  out_din: in t_channelDR;
  out_dout: out ldata( 4 * N_REGION - 1 downto 0 )
);
end;

architecture rtl of dr_isolation_out is

signal track_packet: t_packet := ( others => '0' );
signal track_din: t_trackDR := nulll;
signal track_dout: lword := nulll;
component dr_isolation_out_track
port (
  clk: in std_logic;
  track_packet: in t_packet;
  track_din: in t_trackDR;
  track_dout: out lword
);
end component;

signal stubs_packet: t_packets( numLayers - 1 downto 0 ) := ( others => ( others => '0' ) );
signal stubs_din: t_stubsDR( numLayers - 1 downto 0 ) := ( others => nulll );
signal stubs_dout: ldata( numLayers - 1 downto 0 ) := ( others => nulll );
component dr_isolation_out_stubs
port (
  clk: in std_logic;
  stubs_packet: in t_packets( numLayers - 1 downto 0 );
  stubs_din: in t_stubsDR( numLayers - 1 downto 0 );
  stubs_dout: out ldata( numLayers - 1 downto 0 )
);
end component;

begin

track_packet <= out_packet( 0 );
track_din <= out_din.track;

stubs_packet <= out_packet( numLayers + 1 - 1 downto 1 );
stubs_din <= out_din.stubs;

out_dout( 4 * N_REGION - 1 downto drNumLinks ) <= ( others => nulll );
out_dout( drNumLinks - 1 downto 0 ) <= stubs_dout & track_dout;

cTrack: dr_isolation_out_track port map ( clk, track_packet, track_din, track_dout );

cStubs: dr_isolation_out_stubs port map ( clk, stubs_packet, stubs_din, stubs_dout );

end;


library ieee;
use ieee.std_logic_1164.all;
use work.emp_data_types.all;
use work.emp_project_decl.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.hybrid_data_formats.all;

entity dr_isolation_out_track is
port (
  clk: in std_logic;
  track_packet: in t_packet;
  track_din: in t_trackDR;
  track_dout: out lword
);
end;

architecture rtl of dr_isolation_out_track is

constant widthTrack: natural := 1 + widthDRinv2R + widthDRphiT + widthDRzT;

-- sr
signal sr: t_packets( PAYLOAD_LATENCY - 1 downto 0 ) := ( others => ( others => '0' ) );

-- step 1
signal din:  t_trackDR := nulll;
signal dout: lword := nulll;

function conv( t: t_trackDR ) return std_logic_vector is
begin
  return t.valid & t.inv2R & t.phiT & t.zT;
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

  dout.start_of_orbit <= sr( sr'high ).start_of_orbit;
  dout.valid <= '0';
  dout.data <= ( others => '0' );
  if sr( sr'high ).valid = '1' then
    dout.valid <= '1';
    dout.data( widthTrack - 1 downto 0  ) <= conv( din );
  end if;

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.emp_data_types.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;

entity dr_isolation_out_stubs is
port (
  clk: in std_logic;
  stubs_packet: in t_packets( numLayers - 1 downto 0 );
  stubs_din: in t_stubsDR( numLayers - 1 downto 0 );
  stubs_dout: out ldata( numLayers - 1 downto 0 )
);
end;

architecture rtl of dr_isolation_out_stubs is

component dr_isolation_out_stub
port (
  clk: in std_logic;
  stub_packet: in t_packet;
  stub_din: in t_stubDR;
  stub_dout: out lword
);
end component;

begin

g: for k in 0 to numLayers - 1 generate

signal stub_packet: t_packet := ( others => '0' );
signal stub_din: t_stubDR := nulll;
signal stub_dout: lword := nulll;

begin

stub_packet <= stubs_packet( k );
stub_din <= stubs_din( k );
stubs_dout( k ) <= stub_dout;

c: dr_isolation_out_stub port map ( clk, stub_packet, stub_din, stub_dout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.emp_data_types.all;
use work.emp_project_decl.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.hybrid_data_formats.all;

entity dr_isolation_out_stub is
port (
  clk: in std_logic;
  stub_packet: in t_packet;
  stub_din: in t_stubDR;
  stub_dout: out lword
);
end;

architecture rtl of dr_isolation_out_stub is

constant widthStub: natural := 1 + widthDRr + widthDRphi + widthDRz + widthDRdPhi + widthDRdZ;

-- sr
signal sr: t_packets( PAYLOAD_LATENCY - 1 downto 0 ) := ( others => ( others => '0' ) );

-- step 1
signal din:  t_stubDR := nulll;
signal dout: lword := nulll;

function conv( s: t_stubDR ) return std_logic_vector is
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

  dout.start_of_orbit <= sr( sr'high ).start_of_orbit;
  dout.valid <= '0';
  dout.data <= ( others => '0' );
  if sr( sr'high ).valid = '1' then
    dout.valid <= '1';
    dout.data( widthStub - 1 downto 0  ) <= conv( din );
  end if;

end if;
end process;

end;
