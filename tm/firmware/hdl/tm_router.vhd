library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.tm_data_types.all;

entity tm_router is
generic (
  seedType: natural
);
port (
  clk: in std_logic;
  router_din: in t_channelL;
  router_dout: out t_channelR
);
end;

architecture rtl of tm_router is

signal lookup_din: t_channelL := nulll;
signal lookup_dout: t_channelRL := nulll;
component router_lookUp
generic (
  seedType: natural
);
port (
  clk: in std_logic;
  lookup_din: in t_channelL;
  lookup_dout: out t_channelRL
);
end component;

constant numInputLayers: natural := tbMaxNumSeedingLayer + tbNumsProjectionLayers( seedType );
signal route_din: t_channelRL := nulll;
signal route_dout: t_channelR := nulll;
component router_route
generic (
  numInputLayers: natural
);
port (
  clk: in std_logic;
  route_din: in t_channelRL;
  route_dout: out t_channelR
);
end component;

begin

lookup_din <= router_din;

route_din <= lookup_dout;

router_dout <= route_dout;

cLookup: router_lookup generic map ( seedType ) port map ( clk, lookup_din, lookup_dout );

cRoute: router_route generic map ( numInputLayers ) port map ( clk, route_din, route_dout );

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.tm_data_types.all;
use work.tm_data_formats.all;

entity router_lookUp is
generic (
  seedType: natural
);
port (
  clk: in std_logic;
  lookup_din: in t_channelL;
  lookup_dout: out t_channelRL
);
end;

architecture rtl of router_lookUp is

signal track_din: t_trackL := nulll;
signal track_dout: t_trackR := nulll;
component lookup_track
port (
  clk: in std_logic;
  track_din: in t_trackL;
  track_dout: out t_trackR
);
end component;

signal stubs: t_stubsR( tbNumLayers - 1 downto 0 ) := ( others => nulll );
component lookup_stub
generic (
  layer: natural
);
port (
  clk: in std_logic;
  stub_track: in t_trackL;
  stub_din: in t_stubL;
  stub_dout: out t_stubR
);
end component;

begin

track_din <= lookup_din.track;
lookup_dout.track <= track_dout;
lookup_dout.stubs <= stubs;

c: lookup_track port map ( clk, track_din, track_dout );

g: for k in 0 to tbMaxNumSeedingLayer + tbNumsProjectionLayers( seedType ) - 1 generate

function init_layer return natural is
  variable layer: natural;
begin
  if k < tbNumsProjectionLayers( seedType ) then
    layer := seedTypesProjectionLayers( seedType )( k );
  else
    layer := seedTypesSeedLayers( seedType )( k - tbNumsProjectionLayers( seedType ) );
  end if;
  if layer < 10 then
    return layer - 1;
  end if;
  return layer - 5;
end function;
constant layer: natural := init_layer;

signal stub_din: t_stubL := nulll;
signal stub_dout: t_stubR := nulll;

begin

stub_din <= lookup_din.stubs( k );
stubs( k ) <= stub_dout;

c: lookup_stub generic map ( layer ) port map ( clk, track_din, stub_din, stub_dout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.tm_data_types.all;

entity lookup_track is
port (
  clk: in std_logic;
  track_din: in t_trackL;
  track_dout: out t_trackR
);
end;

architecture rtl of lookup_track is

signal din: t_trackL := nulll;
signal dout: t_trackR := nulll;

begin

din <= track_din;
track_dout <= dout;

process( clk ) is
begin
if rising_edge( clk ) then

  dout <= nulll;
  if din. reset = '1' then
    dout.reset <= '1';
  elsif din.valid = '1' then
    dout.valid <= '1';
    dout.inv2R <= din.inv2R;
    dout.phiT <= din.phiT;
    dout .zT <= din.zT;
  end if;

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.tm_data_types.all;
use work.tm_data_formats.all;
use work.tm_layerEncoding.all;

entity lookup_stub is
generic (
  layer: natural
);
port (
  clk: in std_logic;
  stub_track: in t_trackL;
  stub_din: in t_stubL;
  stub_dout: out t_stubR
);
end;

architecture rtl of lookup_stub is

attribute ram_style: string;
signal lut: t_layerEncoding := layerEncodings( layer );
signal encoded: std_logic_vector( 1 + widthRlayer - 1 downto 0 ) := ( others => '0' );
signal dout: t_stubR := nulll;
attribute ram_style of lut: signal is "register";

begin

stub_dout <= dout;
encoded <= lut( uint( stub_track.zT ) );

process ( clk ) is
begin
if rising_edge( clk ) then

  dout <= nulll;
  if stub_din.reset = '1' then
    dout.reset <= '1';
  elsif stub_din.valid = '1' and encoded( 1 + widthRlayer - 1 ) = '1' then
    dout.valid <= '1';
    dout.barrel <= '0';
    dout.ps <= stub_din.pst;
    dout.tilt <= '1';
    if layer < tbNumBarrelLayers then
      dout.barrel <= '1';
      dout.ps <= '0';
      dout.tilt <= '0';
      if layer < tbNumBarrelLayersPS then
        dout.ps <= '1';
        dout.tilt <= not stub_din.pst;
      end if;
    end if;
    dout.layer <= encoded( widthRlayer - 1 downto 0 );
    dout.r <= stub_din.r;
    dout.phi <= stub_din.phi;
    dout.z <= stub_din.z;
  end if;

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.hybrid_data_formats.all;
use work.hybrid_data_types.all;
use work.tm_data_types.all;

entity router_route is
generic (
  numInputLayers: natural := 10
);
port (
  clk: in std_logic;
  route_din: in t_channelRL;
  route_dout: out t_channelR
);
end;

architecture rtl of router_route is

function f_hitPattern( stubs: t_stubsR ) return std_logic_vector is
  variable hitPattern: std_logic_vector( widthLayer - 1 downto 0 ) := ( others => '0' );
begin
  
  for k in 0 to numLayers - 1 loop
    if stubs( k ).valid = '1' then
      hitPattern( k ) := '1';
    end if;
  end loop;
  return hitPattern;
end function;

-- step 1

signal din: t_channelRL := nulll;
signal track: t_trackR := nulll;
signal stubs: t_stubsR( numLayers - 1 downto 0 ) := ( others => nulll );

-- step 2
signal hitPattern:  std_logic_vector( widthLayer - 1 downto 0 ) := ( others => '0' );
signal dout: t_channelR := nulll;

begin

-- step 1
din <= route_din;

-- step 2
hitPattern <= f_hitPattern( stubs );
route_dout <= dout;

process ( clk ) is
begin
if rising_edge( clk ) then

  -- step 1

  track <= din.track;
  stubs <= ( others => nulll );
  for k in 0 to numLayers - 1 loop
    for j in 0 to numInputLayers - 1 loop
      if din.stubs( j ).valid = '1' and unsigned( din.stubs( j ).layer ) = k then
        stubs( k ) <= din.stubs( j );
      end if;
    end loop;
  end loop;

  -- step 2

  dout <= nulll;
  if track.reset = '1' then
    dout.track.reset <= '1';
    for k in dout.stubs'range loop
      dout.stubs( k ).reset <= '1';
    end loop;
  elsif track.valid = '1' and count( hitPattern, '1' ) >= kfMinStubs and count( hitPattern, 0, kfMaxSeedLayer - 1, '1' ) >= kfNumSeedLayer then
    dout <= ( track, stubs );
  end if;

end if;
end process;

end;