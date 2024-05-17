library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;


entity tm_multiplex is
port (
  clk: in std_logic;
  multiplex_din: in t_channelsTM( tbNumSeedTypes - 1 downto 0 );
  multiplex_dout: out t_channelTM
);
end;


architecture rtl of tm_multiplex is


begin


end;