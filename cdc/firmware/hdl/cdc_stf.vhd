library ieee;
use ieee.std_logic_1164.all;
use work.emp_data_types.all;
use work.emp_project_decl.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.cdc_pkg.all;


entity cdc_stf is
port (
  clk360: in std_logic;
  clk240: in std_logic;
  stf_packet: in t_packet;
  stf_din: in t_data;
  stf_dout: out lword
);
end;


architecture rtl of cdc_stf is


type t_state is ( s1, s2, s3 );
function init_state return t_state is
  variable state: t_state := s1;
begin
  case PAYLOAD_LATENCY - 1 mod 3 is
    when 0 => state := s1;
    when 1 => state := s2;
    when 2 => state := s3;
    when others => null;
  end case;
  return state;
end function;
constant init: t_state := init_state;
signal state: t_state := init;

signal sr: t_packets( 0 to PAYLOAD_LATENCY - 2 ) := ( others => ( others => '0' ) );

signal din: t_data := nulll;
signal dout: lword := nulll;


begin


stf_dout <= dout;

process ( clk240 ) is
begin
if rising_edge( clk240 ) then

  -- step 1

  din <= stf_din;

end if;
end process;

process ( clk360 ) is
begin
if rising_edge( clk360 ) then

  -- sr

  sr <= stf_packet & sr( sr'low to sr'high - 1 );

  -- state

  state <= s1;
  if state /= s3 then
    state <= t_state'val( t_state'pos( state ) + 1 );
  end if;

  -- step 1

  dout <= nulll;
  dout.start_of_orbit <= sr( sr'high ).start_of_orbit;
  dout.valid <= sr( sr'high ).valid;
  if state = s1 or state = s2 then
    dout.data <= din.data;
  end if; 
  if sr( sr'high - 1 ).start_of_orbit = '1' then
    state <= init;
  end if;

end if;
end process;


end;
