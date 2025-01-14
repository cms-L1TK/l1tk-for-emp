library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;

entity tm_cdc is
port (
  clk240: in std_logic;
  clk360: in std_logic;
  cdc_din: in t_trackTM;
  cdc_packet: in t_packet;
  cdc_dout: out t_trackTM
);
end;

architecture rtl of tm_cdc is

type t_state is ( reset, wordA, wordB );
signal state: t_state := reset;

signal valid: std_logic := '0';
signal sr: std_logic_vector( 0 to tbLatency - 1 ) := ( others => '0' );

signal din: t_trackTM := nulll;
signal dout: t_trackTM := nulll;

begin

cdc_dout <= dout;

process ( clk240 ) is
begin
if rising_edge( clk240 ) then

  din <= cdc_din;

end if;
end process;

process ( clk360 ) is
begin
if rising_edge( clk360 ) then

  -- sr

  valid <= cdc_packet.valid;
  sr <= '0' & sr( sr'low to sr'high - 1 );
  if valid = '0' and cdc_packet.valid = '1' then
    sr( 0 ) <= '1';
  end if;

  -- state

  state <= t_state'low;
  if state /= t_state'high then
    state <= t_state'val( t_state'pos( state ) + 1 );
  end if;

  -- cdc

  dout <= din;
  if state = reset then
    dout <= nulll;
  end if;
  dout.meta.reset <= sr( sr'high );

  if sr( sr'high - 1 ) = '1' then
    state <= wordA;
  end if;

end if;
end process;

end;