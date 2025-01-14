library ieee;
use ieee.std_logic_1164.all;
use work.emp_data_types.all;



package cdc_pkg is


constant widthData: natural := LWORD_WIDTH;
type t_data is
record
  reset: std_logic;
  valid: std_logic;
  data: std_logic_vector( widthData - 1 downto 0 );
end record;
type t_datas is array ( natural range <> ) of t_data;
function nulll return t_data;


end;



package body cdc_pkg is


function nulll return t_data is begin return ( '0', '0', ( others => '0' ) ); end function;


end;

