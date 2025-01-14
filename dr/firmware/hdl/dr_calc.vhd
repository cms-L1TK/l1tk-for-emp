library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.hybrid_data_formats.all;
use work.hybrid_data_types.all;
use work.dr_data_types.all;

entity dr_calc is
port (
  clk: in std_logic;
  calc_din: in t_trackCore;
  calc_dout: out t_trackCalc
);
end;

architecture rtl of dr_calc is

signal node_inv2R: std_logic_vector( widthTMinv2R - 1 downto 0 ) := ( others => '0' );
signal node_zT: std_logic_vector( widthTMzT - 1 downto 0 ) := ( others => '0' );
component dr_calc_node
generic (
  index: natural
);
port (
  clk: in std_logic;
  node_din: in t_stubCore;
  node_inv2R: in std_logic_vector( widthTMinv2R - 1 downto 0 );
  node_zT: in std_logic_vector( widthTMzT - 1 downto 0 );
  node_dout: out t_stubCalc
);
end component;

type t_word is
record
  reset: std_logic;
  valid: std_logic;
  param: t_parameterTrackDR;
end record;
function nulll return t_word is begin return ( '0', '0', nulll ); end function;

-- step 1

signal din: t_word := nulll;

-- step 2

signal dout: t_word := nulll;

begin

-- step 2

calc_dout.reset <= dout.reset;
calc_dout.valid <= dout.valid;
calc_dout.param <= dout.param;

process ( clk ) is
begin
if rising_edge( clk ) then

  -- step 1  

  din <= ( calc_din.reset, calc_din.valid, calc_din.param );

  -- step 2

  dout <= din;

end if;
end process;

node_inv2R <= calc_din.param.inv2R;
node_zT <= calc_din.param.zT;

g: for k in 0 to tmNumLayers - 1 generate

signal node_din: t_stubCore := nulll;
signal node_dout: t_stubCalc := nulll;

begin

node_din <= calc_din.stubs( k );
calc_dout.stubs( k ) <= node_dout;

c: dr_calc_node generic map ( k ) port map ( clk, node_din, node_inv2R, node_zT, node_dout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.hybrid_data_formats.all;
use work.hybrid_data_types.all;
use work.dr_data_types.all;

entity dr_calc_node is
generic (
  index: natural
);
port (
  clk: in std_logic;
  node_din: in t_stubCore;
  node_inv2R: in std_logic_vector( widthTMinv2R - 1 downto 0 );
  node_zT: in std_logic_vector( widthTMzT - 1 downto 0 );
  node_dout: out t_stubCalc
);
end;

architecture rtl of dr_calc_node is

type t_ramLayer is array ( 0 to 2 ** ( widthTMzT - 1 ) - 1 ) of std_logic_vector( 0 to numLayers - 1 );
constant layerId: natural := layerIds( index );
function init_ramLayer return t_ramLayer is
  variable ram: t_ramLayer := ( others => ( others => '0' ) );
  variable last: natural := 2 ** ( widthTMzT - 2 ) - 1;
begin
  for k in 0 to 2 ** ( widthTMzT - 2 ) - 1 loop
    for j in 0 to numLayers - 1 loop
      if layerEncodings( k )( j ) = layerId then
        ram( k )( j ) := '1';
        exit;
      end if;
    end loop;
  end loop;
  for k in 2 ** ( widthTMzT - 2 ) to 2 ** ( widthTMzT - 1 ) - 1 loop
    ram( k ) := ram( last );
  end loop;
  return ram;
end function;

function init_rams return t_rams is
begin
  if index < 6 then
    return c_barrel;
  end if;
  return c_endcap;
end function;
constant rams: t_rams := init_rams;

-- step 1

signal layerEncoding: t_ramLayer := init_ramLayer;
signal ramR: t_ramR := rams.r;
signal ramPhi: t_ramPhi := rams.phi;
signal ramZ: t_ramZ := rams.z;
signal indexLayer: std_logic_vector( widthTMzT - 1 - 1 downto 0 ) := ( others => '0' );
signal indexR: std_logic_vector( widthTMinv2R - 1 downto 0 ) := ( others => '0' );
signal indexPhi: std_logic_vector( bram18WidthAddr - 1 downto 0 ) := ( others => '0' );
signal indexZ: std_logic_vector( widthTMzT - 1 downto 0 ) := ( others => '0' );
signal din: t_stubCore := nulll;
signal layer: std_logic_vector( 0 to numLayers - 1 ) := ( others => '0' );
signal r: std_logic_vector( widthDRdPhi - 1 downto 0 ) := ( others => '0' );
signal phi: std_logic_vector( widthDRdPhi - 1 downto 0 ) := ( others => '0' );
signal z: std_logic_vector( widthDRdZ - 1 downto 0 ) := ( others => '0' );

-- step 2

signal sum: std_logic_vector( widthDRdPhi + 3 - 1 downto 0 ) := ( others => '0' );
signal dout: t_stubCalc := nulll;

begin

-- step 1
indexLayer <= abs( node_zT );
indexR <= node_din.pst & abs( node_inv2R );
indexPhi( bram18WidthAddr - 1 ) <= '1' when index < 3 or node_din.pst = '1' else '0';
indexPhi( bram18WidthAddr - 2 downto 0 ) <= node_din.r( widthTMr - 1 downto widthTMr - bram18WidthAddr + 1 );
indexZ <= node_din.pst & abs( node_zT );

-- step 2
sum <= ( '0' & r & '1' ) + ( '0' & phi & '1' );
node_dout <= dout;

process ( clk ) is
begin
if rising_edge( clk ) then

  -- step 1

  din <= node_din;
  layer <= layerEncoding( uint( indexLayer ) );
  r <= ramR( uint( indexR ) );
  phi <= ramPhi( uint( indexPhi ) );
  z <= ramZ( uint( indexZ ) );

  -- step 2

  dout <= ( din.valid, layer, ( din.r, din.phi, din.z, sum( widthDRdPhi + 1 - 1 downto 1 ), z ) );
  if index > 2 and index < 6 then
    dout.param.dZ <= stdu( 0.5 * pitchCol2S, baseTMz, widthDRdZ );
  end if;
  if index < 3 and din.pst = '0' then
    dout.param.dZ <= stdu( 0.5 * pitchColPS, baseTMz, widthDRdZ );
  end if;

  if din.valid = '0' then
    dout <= nulll;
  end if;

end if;
end process;

end;
