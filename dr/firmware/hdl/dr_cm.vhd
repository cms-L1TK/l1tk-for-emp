library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
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


signal din      : t_track   := nulll;
signal dout     : t_track   := nulll;
signal cm       : t_track   := nulll;
signal kill     : std_logic := '0';
signal kill_cm  : std_logic := '0';
signal start_out: std_logic := '0';

function f_equalEnough( track: t_track; cm: t_track ) return boolean is
  variable layer: std_logic_vector( numLayers - 1 downto 0 ) := ( others => '0' );
begin
  for k in track.stubs'range loop
    if track.stubs( k ).valid = '1' and cm.stubs( k ).valid = '1' and track.stubs( k ).stubId = cm.stubs( k ).stubId then
      layer( k ) := '1';
    end if;
  end loop;
  return track.valid = '1' and track.cm = '0' and cm.valid = '1' and count( layer, '1' ) >= minSharedStubs;
end function;

-- Compares the chi2 and number of consistent stubs of a track and a CM
function f_killCM( track: t_track; cm_track: t_track) return boolean is
  variable killCM: boolean := false;
begin
  if track.valid = '1' and track.cm = '0' and cm_track.valid = '1' then 
    if unsigned(cm_track.nConsistentStubs) < unsigned(track.nConsistentStubs) then
      killCM := true;
    elsif unsigned(cm_track.chi2) > unsigned(track.chi2) and cm_track.nConsistentStubs = track.nConsistentStubs then
      killCM := true;
    end if;
    return killCM;
  else
    return false;
  end if;
end function;

begin


din     <= cm_din;
cm_dout <= dout;

kill    <= '1' when f_equalEnough( din, cm ) else '0';
kill_cm <= '1' when f_killCM( din, cm)       else '0'; -- kill the track with the lowest chi2

process ( clk ) is
begin
if rising_edge( clk ) then

  dout <= din;

  -- Add track to CM
  if din.valid = '1' and din.cm = '0' and cm.valid = '0' then -- and din.lastTrack = '0'
    cm    <= din;
    cm.cm <= '1';
    dout  <= nulll; -- don't read out CM track until last track has arrived
  end if;

  -- Choose which track to kill
  if kill = '1' then
    if kill_cm = '1' then
      cm    <= din;
      cm.cm <= '1';
    end if;
    dout <= nulll; -- no output
  end if;

  -- Start sending out CM track next clock tick...
  if din.lastTrack = '1' or din.cm = '1' then
    start_out <= '1';
  end if;

  -- Send out CM track
  if start_out = '1' and din.valid = '0' then
    dout      <= cm;
    dout.cm   <= '1';
    start_out <= '0';
  end if;

  -- Reset
  if din.reset = '1' then
    cm        <= nulll;
    start_out <= '0';
  end if;

end if;
end process;


end;
