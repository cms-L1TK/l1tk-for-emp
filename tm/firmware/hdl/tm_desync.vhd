library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.hybrid_data_formats.all;
use work.hybrid_data_types.all;

entity tm_desync is
generic (
  index: natural
);
port (
  clk: in std_logic;
  desync_din: in t_trackTM;
  desync_dout: out t_trackTM
);
end;

architecture rtl of tm_desync is

constant widthTrack: natural := 1 + 1 + tmNumLayers + widthTMinv2R + widthTMphiT + widthTMzT;
constant widthStub: natural := 1 + widthTMstubId + widthTMr + widthTMphi + widthTMz;
constant widthRam: natural := widthTrack + tmNumLayers * widthStub;
constant widthAddr: natural := width( tbNumSeedTypes + 1 );
type t_ram is array ( 0 to 2 ** widthAddr - 1 ) of std_logic_vector( widthRam - 1 downto 0 );
function conv( std: std_logic_vector ) return t_trackTM is
  variable t: t_trackTM := nulll;
begin
  t.meta.reset  := std( 1 + tmNumLayers + widthTMinv2R + widthTMphiT + widthTMzT + tmNumLayers * widthStub );
  t.meta.valid  := std(     tmNumLayers + widthTMinv2R + widthTMphiT + widthTMzT + tmNumLayers * widthStub );
  t.meta.hits   := std(     tmNumLayers + widthTMinv2R + widthTMphiT + widthTMzT + tmNumLayers * widthStub - 1 downto widthTMinv2R + widthTMphiT + widthTMzT + tmNumLayers * widthStub );
  t.track.inv2R := std(                   widthTMinv2R + widthTMphiT + widthTMzT + tmNumLayers * widthStub - 1 downto                widthTMphiT + widthTMzT + tmNumLayers * widthStub );
  t.track.phiT  := std(                                  widthTMphiT + widthTMzT + tmNumLayers * widthStub - 1 downto                              widthTMzT + tmNumLayers * widthStub );
  t.track.zT    := std(                                                widthTMzT + tmNumLayers * widthStub - 1 downto                                          tmNumLayers * widthStub );
  for k in 0 to tmNumLayers - 1 loop
    t.stubs( k ).pst    := std( widthTMstubId + widthTMr + widthTMphi + widthTMz + k * widthStub );
    t.stubs( k ).stubId := std( widthTMstubId + widthTMr + widthTMphi + widthTMz + k * widthStub - 1 downto widthTMr + widthTMphi + widthTMz + k * widthStub );
    t.stubs( k ).r      := std(                 widthTMr + widthTMphi + widthTMz + k * widthStub - 1 downto            widthTMphi + widthTMz + k * widthStub );
    t.stubs( k ).phi    := std(                            widthTMphi + widthTMz + k * widthStub - 1 downto                         widthTMz + k * widthStub );
    t.stubs( k ).z      := std(                                         widthTMz + k * widthStub - 1 downto                                    k * widthStub );
  end loop;
  return t;
end function;
function conv( t: t_trackTM ) return std_logic_vector is
  variable std: std_logic_vector( widthRam - 1 downto 0 ) := ( others => '0' );
begin
  std( widthRam - 1 downto tmNumLayers * widthStub ) := t.meta.reset & t.meta.valid & t.meta.hits & t.track.inv2R & t.track.phiT & t.track.zT;
  for k in 0 to tmNumLayers - 1 loop
    std( ( k + 1 ) * widthStub - 1 downto k * widthStub ) := t.stubs( k ).pst & t.stubs( k ).stubId & t.stubs( k ).r & t.stubs( k ).phi & t.stubs( k ).z;
  end loop;
  return std;
end function;

signal ram: t_ram := ( others => ( others => '0' ) );
signal waddr, raddr: std_logic_vector( widthAddr - 1 downto 0 ) := ( others => '0' );
signal dout: t_trackTM := nulll;

begin

desync_dout <= dout;
waddr <= raddr + index + 1;

process ( clk ) is
begin
if rising_edge( clk ) then

  ram( uint( waddr ) ) <= conv( desync_din );
  dout <= conv( ram( uint( raddr ) ) );
  raddr <= raddr + 1;

end if;
end process;

end;