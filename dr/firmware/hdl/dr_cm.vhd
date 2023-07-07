library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.dr_data_types.all;


entity dr_cm is
port (
  clk: in std_logic;
  cm_din: in t_track;
  cm_dout: out t_track
);
end;


architecture rtl of dr_cm is


signal din: t_track := nulll;
signal dout: t_track := nulll;
signal kill: std_logic := '0';
signal cm: t_cm := nulll;

function f_equalEnough( track: t_track; cm: t_cm ) return boolean is
  variable layer: std_logic_vector( numLayers - 1 downto 0 ) := ( others => '0' );
begin
  for k in track.stubs'range loop
    if track.stubs( k ).valid = '1' and cm.stubs( k ).valid = '1' and track.stubs( k ).stubId = cm.stubs( k ).stubId then
      layer( k ) := '1';
    end if;
  end loop;
  return track.valid = '1' and track.cm = '0' and cm.valid = '1' and count( layer, '1' ) >= minSharedStubs;
end function;

begin


din <= cm_din;
cm_dout <= dout;

kill <= '1' when f_equalEnough( din, cm ) else '0';

process ( clk ) is
begin
if rising_edge( clk ) then

  dout <= din;
  if din.valid = '1' and din.cm = '0' and cm.valid = '0' then
    dout.cm <= '1';
    cm <= conv( din );
  end if;

  if din.reset = '1' then
    cm <= nulll;
  end if;
  if kill = '1' then
    dout <= nulll;
  end if;

end if;
end process;


end;
