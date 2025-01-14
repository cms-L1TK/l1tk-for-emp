library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.tm_data_types.all;


entity tm_router is
generic (
  seedType: natural
);
port (
  clk: in std_logic;
  router_din: in t_trackL;
  router_dout: out t_trackTM
);
end;


architecture rtl of tm_router is 


signal dout: t_trackTM := nulll;

function f_seedId( n: natural ) return natural is
  variable id: natural := seedTypesSeedLayers( seedType )( n );
begin
  if id > 10 then
    id := id - 10 + tbNumBarrelLayers;
  end if;
  return id - 1;
end function;

function f_projId( n: natural ) return natural is
  variable id: natural := seedTypesProjectionLayers( seedType )( n );
begin
  if id > 10 then
    id := id - 10 + tbNumBarrelLayers;
  end if;
  return id - 1;
end function;


begin


router_dout <= dout;

process ( clk ) is
begin
if rising_edge( clk ) then

  dout.meta.reset <= router_din.meta.reset;
  dout.meta.valid <= router_din.meta.valid;
  dout.meta.hits <= ( others => '0' );
  dout.track <= router_din.track;
  dout.stubs <= ( others => nulll );
  for k in 0 to tbMaxNumSeedingLayer - 1 loop
    dout.meta.hits( f_seedId( k ) ) <= router_din.meta.hits( k );
    dout.stubs( f_seedId( k ) ) <= router_din.stubs( k );
  end loop;
  for k in 0 to tbNumsProjectionLayers( seedType ) - 1 loop
    dout.meta.hits( f_projId( k ) ) <= router_din.meta.hits( tbMaxNumSeedingLayer + k );
    dout.stubs( f_projId( k ) ) <= router_din.stubs( tbMaxNumSeedingLayer + k );
  end loop;

  if router_din.meta.valid = '1' and count( router_din.meta.hits, 0, tbMaxNumSeedingLayer + tbNumsProjectionLayers( seedType ) - 1 ) < kfMinStubs then
    dout <= nulll;
  end if;

end if;
end process;


end;