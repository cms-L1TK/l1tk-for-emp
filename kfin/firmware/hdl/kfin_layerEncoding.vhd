library ieee, std;
use ieee.std_logic_1164.all;
use std.textio.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.kfin_data_formats.all;


package kfin_layerEncoding is


type t_layerEncoding is array ( 0 to 2 ** ( widthLsectorEta + widthLzT + widthLcot ) - 1 ) of std_logic_vector( 1 + widthRlayer + 1 - 1 downto 0 );
type t_layerEncodings is array( 0 to numBarrelLayers + numEndcapDisks - 1 ) of t_layerEncoding;

impure function init_layerEncodings return t_layerEncodings;
constant layerEncodings: t_layerEncodings;

end;


package body kfin_layerEncoding is



impure function init_layerEncodings return t_layerEncodings is
  file f: text open read_mode is "/heplnw039/tschuh/work/src/l1tk-for-emp/kfin/firmware/luts/layerEncoding.mem";
  variable l: line;
  variable w: bit_vector( 1 + widthRlayer + 1 - 1 downto 0 );
  variable le: t_layerEncoding := ( others => ( others => '0' ) );
  variable les: t_layerEncodings := ( others => ( others => ( others => '0' ) ) );
begin
  for layer in les'range loop
    le := ( others => ( others => '0' ) );
    for index in le'range loop
      readline( f, l );
      read( l, w );
      if w( 1 + widthRlayer + 1 - 1 ) = '1' then
        le( index ) := to_stdlogicvector( w );
      else
        le( index ) := '0' & ( widthRlayer + 1 - 1 downto 0 => '-' );
      end if;
    end loop;
    les( layer ) := le;
  end loop;
  return les;
end function;


constant layerEncodings: t_layerEncodings := init_layerEncodings;


end;