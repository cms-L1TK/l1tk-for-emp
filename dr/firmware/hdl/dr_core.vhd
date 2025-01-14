library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.dr_data_types.all;

entity dr_core is
port (
  clk: in std_logic;
  core_din: in t_trackTM;
  core_dout: out t_trackCore
);
end;

architecture rtl of dr_core is 

signal tracks: t_tracksCM( drNumComparisonModules downto 0 ) := ( others => nulll );
component dr_cm
port (
  clk: in std_logic;
  cm_din: in t_trackCM;
  cm_dout: out t_trackCM
);
end component;

begin

tracks( 0 ) <= conv( core_din );
core_dout <= conv( tracks( drNumComparisonModules ) );

g: for k in 0 to drNumComparisonModules - 1 generate

signal cm_din: t_trackCM := nulll;
signal cm_dout: t_trackCM := nulll;

begin

cm_din <= tracks( k );
tracks( k + 1 ) <= cm_dout;

c: dr_cm port map ( clk, cm_din, cm_dout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.dr_data_types.all;

entity dr_cm is
port (
  clk: in std_logic;
  cm_din: in t_trackCM;
  cm_dout: out t_trackCM
);
end;

architecture rtl of dr_cm is

signal din: t_trackCM := nulll;
signal dout: t_trackCM := nulll;
signal kill: std_logic := '0';
signal cm: t_cm := nulll;

function f_equalEnough( track: t_trackCM; cm: t_cm ) return boolean is
  variable layer: std_logic_vector( 0 to tmNumLayers - 1 ) := ( others => '0' );
begin
  for k in track.stubs'range loop
    if track.stubs( k ).valid = '1' and cm.ids( k ).valid = '1' and track.stubs( k ).stubId = cm.ids( k ).value then
      layer( k ) := '1';
    end if;
  end loop;
  return track.valid = '1' and track.cm = '0' and cm.valid = '1' and count( layer ) >= drMinSharedStubs;
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
