library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.dr_data_types.all;

entity dr_route is
port (
  clk: in std_logic;
  route_din: in t_trackCalc;
  route_dout: out t_trackDR
);
end;

architecture rtl of dr_route is

signal node_din: t_stubsCalc( 0 to tmNumLayers - 1 ) := ( others => nulll );
component dr_route_node
generic (
  index: natural
);
port (
  clk: in std_logic;
  node_din: in t_stubsCalc( 0 to tmNumLayers - 1 );
  node_valid: out std_logic;
  node_dout: out t_parameterStubDR
);
end component;

-- step 3

signal reset, valid: std_logic := '0';
signal track: t_parameterTrackDR := nulll;

begin

-- step 3
route_dout.meta.reset <= reset;
route_dout.meta.valid <= valid;
route_dout.track <= track;

process ( clk ) is
begin
if rising_edge( clk ) then

  -- step 3

  reset <= route_din.reset;
  valid <= route_din.valid;
  track <= route_din.param;

end if;
end process;

node_din <= route_din.stubs;

g: for k in 0 to numLayers - 1 generate

signal node_valid: std_logic := '0';
signal node_dout: t_parameterStubDR := nulll;

begin

route_dout.meta.hits( k ) <= node_valid;
route_dout.stubs( k ) <= node_dout;

c: dr_route_node generic map ( k ) port map ( clk, node_din, node_valid, node_dout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.dr_data_types.all;

entity dr_route_node is
generic (
  index: natural
);
port (
  clk: in std_logic;
  node_din: in t_stubsCalc( 0 to tmNumLayers - 1 );
  node_valid: out std_logic;
  node_dout: out t_parameterStubDR
);
end;

architecture rtl of dr_route_node is

constant layerId: natural := layerIds( index );
function conv( n: natural ) return natural is begin if n > 10 then return n - 5; end if; return n - 1; end function;
function init_enable return std_logic_vector is
  variable enable: std_logic_vector( 0 to tmNumLayers - 1 ) := ( others => '0' );
begin
  for k in 0 to numLayers - 1 loop
    for j in 0 to gpNumBinszT / 2 - 1 loop
      if layerEncodings( j )( k ) > 0 then
        enable( conv( layerEncodings( j )( k ) ) ) := '1';
      end if;
    end loop;
  end loop;
  return enable;
end function;
constant enable: std_logic_vector( 0 to tmNumLayers - 1 ) := init_enable;

-- step 3

signal valid: std_logic := '0';
signal dout: t_parameterStubDR := nulll;

begin

-- step 3
node_valid <= valid;
node_dout <= dout;

process ( clk ) is
begin
if rising_edge( clk ) then

  -- step3

  valid <= '0';
  dout <= nulll;
  for k in 0 to tmNumLayers - 1 loop
    if enable( k ) = '1' and node_din( k ).layer( index ) = '1' then
      valid <= '1';
      dout <= node_din( k ).param;
    end if;
  end loop;

end if;
end process;

end;
