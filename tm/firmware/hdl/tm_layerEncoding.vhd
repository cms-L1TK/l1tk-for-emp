library ieee, std;
use ieee.std_logic_1164.all;
use std.textio.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.hybrid_data_formats.all;
use work.tm_data_formats.all;


package tm_layerEncoding is


type t_layerEncoding is array ( 0 to 2 ** widthLzT - 1 ) of std_logic_vector( 1 + widthLayer - 1 downto 0 );
type t_layerEncodings is array( 0 to tbNumBarrelLayers + tbNumEndcapDisks - 1 ) of t_layerEncoding;
constant c_layerIds: naturals( 0 to tbNumBarrelLayers + tbNumEndcapDisks - 1 ) := ( 1, 2, 3, 4, 5, 6, 11, 12, 13, 14, 15 );

type t_le is array ( 0 to 2 ** widthLzT - 1 ) of naturals( 0 to numLayers - 1 );
constant c_le: t_le := (
  ( 11, 12, 13, 14, 15,  0,  0,  0 ), -- -16
  ( 1,  11, 12, 13, 14, 15,  0,  0 ), -- -15
  ( 1,  11, 12, 13, 14, 15,  0,  0 ), -- -14
  ( 1,  11, 12, 13, 14, 15,  0,  0 ), -- -13
  ( 1,  11, 12, 13, 14, 15,  0,  0 ), -- -12
  ( 1,  11, 12, 13, 14, 15,  0,  0 ), -- -11
  ( 1,  2,  11, 12, 13, 14, 15,  0 ), -- -10
  ( 1,  2,  11, 12, 13, 14, 15,  0 ), -- - 9
  ( 1,  2,  11, 12, 13, 14, 15,  0 ), -- - 8
  ( 1,  2,  3,  11, 12, 13, 14, 15 ), -- - 7
  ( 1,  2,  3,  11, 12, 13, 14,  0 ), -- - 6
  ( 1,  2,  3,  4,  11, 12, 13,  0 ), 
  ( 1,  2,  3,  4,  5,  6,  11, 12 ), 
  ( 1,  2,  3,  4,  5,  6,  11,  0 ), 
  ( 1,  2,  3,  4,  5,  6,   0,  0 ), 
  ( 1,  2,  3,  4,  5,  6,   0,  0 ), 
  ( 1,  2,  3,  4,  5,  6,   0,  0 ), 
  ( 1,  2,  3,  4,  5,  6,   0,  0 ), 
  ( 1,  2,  3,  4,  5,  6,  11,  0 ), 
  ( 1,  2,  3,  4,  5,  6,  11, 12 ), 
  ( 1,  2,  3,  4,  11, 12, 13,  0 ), 
  ( 1,  2,  3,  11, 12, 13, 14,  0 ), 
  ( 1,  2,  3,  11, 12, 13, 14, 15 ), 
  ( 1,  2,  11, 12, 13, 14, 15,  0 ), 
  ( 1,  2,  11, 12, 13, 14, 15,  0 ), 
  ( 1,  2,  11, 12, 13, 14, 15,  0 ), 
  ( 1,  11, 12, 13, 14, 15,  0,  0 ), 
  ( 1,  11, 12, 13, 14, 15,  0,  0 ), 
  ( 1,  11, 12, 13, 14, 15,  0,  0 ), 
  ( 1,  11, 12, 13, 14, 15,  0,  0 ), 
  ( 1,  11, 12, 13, 14, 15,  0,  0 ), 
  ( 11, 12, 13, 14, 15,  0,  0,  0 )
);

function init_layerEncodings return t_layerEncodings;
constant layerEncodings: t_layerEncodings;

end;


package body tm_layerEncoding is



function init_layerEncodings return t_layerEncodings is
  variable les: t_layerEncodings := ( others => ( others => ( others => '0' ) ) );
  variable layerId: natural;
  variable zT: integer;
begin
  for layer in les'range loop
    layerId := c_layerIds( layer );
    for index in 0 to 2 ** widthLzT - 1 loop
      zT := sint( stdu( index, widthLzT ) ) + 2 ** ( widthLzT - 1 );
      for k in 0 to numLayers - 1 loop
        if layerId = c_le( zT )( k ) then
          les( layer )( index ) := '1' & stdu( k, widthLayer );
          exit;
        end if;
      end loop;
    end loop;
  end loop;
  return les;
end function;
constant layerEncodings: t_layerEncodings := init_layerEncodings;


end;