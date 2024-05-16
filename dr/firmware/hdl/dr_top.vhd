library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.dr_data_types.all;

entity dr_top is
port (
  clk: in std_logic;
  dr_din: in t_channelTM;
  dr_dout: out t_channelDR
);
end;

architecture rtl of dr_top is

signal tracks: t_tracks( drNumComparisonModules downto 0 ) := ( others => nulll );
component dr_cm
port (
  clk: in std_logic;
  cm_din: in t_track;
  cm_dout: out t_track
);
end component;

begin

tracks( 0 ) <= conv( dr_din );
dr_dout <= conv( tracks( drNumComparisonModules ) );

g: for k in 0 to drNumComparisonModules - 1 generate

signal cm_din: t_track := nulll;
signal cm_dout: t_track := nulll;

begin

cm_din <= tracks( k );
tracks( k + 1 ) <= cm_dout;

c: dr_cm port map ( clk, cm_din, cm_dout );

end generate;

end;
