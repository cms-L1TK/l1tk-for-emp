library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_data_types.all;
use work.tracklet_data_types.all;
use work.tracklet_config.all;
use work.hybrid_config.all;

entity tracklet_format_in is
port (
  clk: in std_logic;
  in_reset: in t_resets( numQuads - 1 downto 0 );
  in_din: in t_stubsDTC;
  in_dout: out t_datas( numInputsIR  - 1 downto 0 )
);
end;

architecture rtl of tracklet_format_in is

begin

gPS: for k in in_din.ps'range generate

signal r: t_reset := nulll;
signal s: t_stubDTCPS := nulll;
signal d: t_data := nulll;

begin

r <= in_reset( k / 4 );
s <= in_din.ps( k );
d.reset <= r.reset;
d.start <= r.start;
d.bx <= r.bx;
d.valid <= '1';
d.data( r_dataDTC ) <= s.r & s.z & s.phi & s.bend & s.layer & s.valid;
in_dout( k ) <= d;

end generate;

g2S: for k in in_din.ss'range generate

constant l: natural := numDTCPS + k;
signal r: t_reset := nulll;
signal s: t_stubDTC2S := nulll;
signal reset, start: std_logic := '0';
signal d: t_data := nulll;

begin

r <= in_reset( l / 4 );
s <= in_din.ss( k );
d.reset <= r.reset;
d.start <= r.start;
d.bx <= r.bx;
d.valid <= '1';
d.data( r_dataDTC ) <= s.r & s.z & s.phi & s.bend & s.layer & s.valid;
in_dout( l ) <= d;

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_data_types.all;
use work.hybrid_data_formats.all;
use work.tracklet_config.all;
use work.tracklet_data_types.all;

entity tracklet_format_out is
port (
  clk: in std_logic;
  out_din: in t_datas( numOutputsFT - 1 downto 0 );
  out_dout: out t_candTracklet
);
end;

architecture rtl of tracklet_format_out is

signal dout: t_candTracklet := nulll;

begin

out_dout <= dout;

process ( clk ) is
begin
if rising_edge( clk ) then

  dout <= nulll;
  if out_din( 0 ).valid = '1' then
    dout.track.valid    <= out_din( 0 ).data( 1 + widthTrackletSeedType + widthTrackletInv2R + widthTrackletPhi0 + widthTrackletZ0 + widthTrackletCot + widthTrackletLmap - 1 );
    dout.track.seedtype <= out_din( 0 ).data(     widthTrackletSeedType + widthTrackletInv2R + widthTrackletPhi0 + widthTrackletZ0 + widthTrackletCot + widthTrackletLmap - 1 downto widthTrackletInv2R + widthTrackletPhi0 + widthTrackletZ0 + widthTrackletCot + widthTrackletLmap );
    dout.track.inv2R    <= out_din( 0 ).data(                             widthTrackletInv2R + widthTrackletPhi0 + widthTrackletZ0 + widthTrackletCot + widthTrackletLmap - 1 downto                      widthTrackletPhi0 + widthTrackletZ0 + widthTrackletCot + widthTrackletLmap );
    dout.track.phi0     <= out_din( 0 ).data(                                                  widthTrackletPhi0 + widthTrackletZ0 + widthTrackletCot + widthTrackletLmap - 1 downto                                          widthTrackletZ0 + widthTrackletCot + widthTrackletLmap );
    dout.track.z0       <= out_din( 0 ).data(                                                                      widthTrackletZ0 + widthTrackletCot + widthTrackletLmap - 1 downto                                                            widthTrackletCot + widthTrackletLmap );
    dout.track.cot      <= out_din( 0 ).data(                                                                                        widthTrackletCot + widthTrackletLmap - 1 downto                                                                               widthTrackletLmap );
    for k in 1 to numOutputsFT - 1 loop
      dout.stubs( k - 1 ).valid   <= out_din( k ).data( 1 + widthTrackletTrackId + widthTrackletStubId + widthTrackletR + widthTrackletPhi + widthTrackletZ - 1 );
      dout.stubs( k - 1 ).trackId <= out_din( k ).data(     widthTrackletTrackId + widthTrackletStubId + widthTrackletR + widthTrackletPhi + widthTrackletZ - 1 downto widthTrackletStubId + widthTrackletR + widthTrackletPhi + widthTrackletZ );
      dout.stubs( k - 1 ).stubId  <= out_din( k ).data(                            widthTrackletStubId + widthTrackletR + widthTrackletPhi + widthTrackletZ - 1 downto                       widthTrackletR + widthTrackletPhi + widthTrackletZ );
      dout.stubs( k - 1 ).r       <= out_din( k ).data(                                                  widthTrackletR + widthTrackletPhi + widthTrackletZ - 1 downto                                        widthTrackletPhi + widthTrackletZ );
      dout.stubs( k - 1 ).phi     <= out_din( k ).data(                                                                   widthTrackletPhi + widthTrackletZ - 1 downto                                                           widthTrackletZ );
      dout.stubs( k - 1 ).z       <= out_din( k ).data(                                                                                      widthTrackletZ - 1 downto                                                                        0 );
    end loop;
  end if;

end if;
end process;

end;