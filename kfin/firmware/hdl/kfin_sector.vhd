library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.kfin_data_types.all;
use work.kfin_data_formats.all;



entity kfin_sector is
port (
  clk: in std_logic;
  sector_din: in t_channelH;
  sector_dout: out t_channelS
);
end;



architecture rtl of kfin_sector is


function conv( h: t_stubH ) return t_stubS is begin return ( h.reset, h.valid, h.pst, h.r, h.phi, h.z ); end function;
function conv( h: t_channelH ) return t_channelS is
  variable s: t_channelS := nulll;
  variable zT1, zT0, zT, cot: real;
begin
  s.track := ( '0', '1', ( others => '0' ), ( others => '0' ), h.track.inv2R( widthSinv2R - 1 downto 0 ), ( others => '0' ), ( others => '0' ), ( others => '0' ) );
  s.track.sectorPhi := ( others => not h.track.phiT( widthSphiT ) );
  --s.track.phiT := sba( h.track.phiT( widthSphiT - 1 downto 0 ) );
  if s.track.sectorPhi = "1" then
    s.track.phiT := resize( h.track.phiT - stdu( 2.0 * MATH_PI / real( numRegions ) / 4.0 / baseHphiT, widthHphiT ), widthSphiT );
  else
    s.track.phiT := resize( h.track.phiT + stdu( 2.0 * MATH_PI / real( numRegions ) / 4.0 / baseHphiT, widthHphiT ), widthSphiT );
  end if;
  for k in 0 to numSectorsEta - 1 loop
    zT1 := sinh( etaBoundaries( k + 1 ) ) * chosenRofZ;
    zT0 := sinh( etaBoundaries( k )     ) * chosenRofZ;
    zT := ( zT1 + zT0 ) / 2.0;
    cot := zT / chosenRofZ;
    if signed( h.track.zT ) < int( zT1, baseHzT ) then
      s.track.sectorEta := stdu( k, widthSSectorEta );
      s.track.cot := h.track.cot - stds( cot / baseHcot, widthHcot );
      s.track.zT := h.track.zT - stds( zT / baseHzT, widthHzT );
      exit;
    end if;
  end loop;
  for k in s.stubs'range loop
    s.stubs( k ) := conv( h.stubs( k ) );
  end loop;
  return s;
end function;

-- step 1

signal dout: t_channelS := nulll;

begin


-- step 1
sector_dout <= dout;

process( clk ) is
begin
if rising_edge( clk ) then

  -- step 1

  dout <= nulll;
  if sector_din.track.reset = '1' then
    dout.track.reset <= '1';
    for k in sector_din.stubs'range loop
      dout.stubs( k ).reset <= '1';
    end loop;
  elsif sector_din.track.valid = '1' then
    dout <= conv( sector_din );
  end if;

end if;
end process;



end;