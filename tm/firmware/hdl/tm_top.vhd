library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;


entity tm_top is
port (
  clk: in std_logic;
  tm_din: in t_channelsTB( tbNumSeedTypes - 1 downto 0 );
  tm_dout: out t_channelTM
);
end;


architecture rtl of tm_top is


signal transform_din: t_channelsTB( tbNumSeedTypes - 1 downto 0 ) := ( others => nulll );
signal transform_dout: t_channelsTM( tbNumSeedTypes - 1 downto 0 ) := ( others => nulll );
component tm_transform
port (
  clk: in std_logic;
  transform_din: in t_channelsTB( tbNumSeedTypes - 1 downto 0 );
  transform_dout: out t_channelsTM( tbNumSeedTypes - 1 downto 0 )
);
end component;

signal multiplex_din: t_channelsTM( tbNumSeedTypes - 1 downto 0 ) := ( others => nulll );
signal multiplex_dout: t_channelTM := nulll;
component tm_multiplex
port (
  clk: in std_logic;
  multiplex_din: in t_channelsTM( tbNumSeedTypes - 1 downto 0 );
  multiplex_dout: out t_channelTM
);
end component;


begin


transform_din <= tm_din;

multiplex_din <= transform_dout;

tm_dout <= multiplex_dout;

cT: tm_transform port map ( clk, transform_din, transform_dout );

cM: tm_multiplex port map ( clk, multiplex_din, multiplex_dout );


end;