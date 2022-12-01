library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.hybrid_data_types.all;
use work.tracklet_data_types.all;
use work.tracklet_config.all;
use work.hybrid_config.all;

entity tracklet_format_in is
port (
  clk: in std_logic;
  in_din: in t_stubsDTC;
  in_dout: out t_datas( numInputsIR  - 1 downto 0 )
);
end;

architecture rtl of tracklet_format_in is

begin

gPS: for k in in_din.ps'range generate

signal din: t_stubDTCPS := nulll;
signal dout: t_data := nulll;
signal counter: std_logic_vector( widthFrames - 1 downto 0 ) := ( others => '0' );

begin

din <= in_din.ps( k );

dout.valid <= '1';
in_dout( k ) <= dout;

process ( clk ) is
begin
if rising_edge( clk ) then

  dout.data( r_dataDTC ) <= din.r & din.z & din.phi & din.bend & din.layer & din.valid;
  counter <= incr( counter );
  if uint( counter ) = numFrames then
    dout.start <= '0';
  end if;

  if din.reset = '1' then
    dout.start <= '1';
    dout.bx <= incr( dout.bx );
    counter <= ( others => '0' );
  end if;

end if;
end process;

end generate;

g2S: for k in in_din.ss'range generate

constant l: natural := numTypedStubs( t_stubTypes'pos( LayerPS ) ) + k;
signal din: t_stubDTC2S := nulll;
signal dout: t_data := nulll;
signal counter: std_logic_vector( widthFrames - 1 downto 0 ) := ( others => '0' );

begin

din <= in_din.ss( k );

dout.valid <= '1';
in_dout( l ) <= dout;

process ( clk ) is
begin
if rising_edge( clk ) then

  dout.data( r_dataDTC ) <= din.r & din.z & din.phi & din.bend & din.layer & din.valid;
  counter <= incr( counter );
  if uint( counter ) = numFrames then
    dout.start <= '0';
  end if;

  if din.reset = '1' then
    dout.start <= '1';
    dout.bx <= incr( dout.bx );
    counter <= ( others => '0' );
  end if;

end if;
end process;

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.hybrid_tools.all;
use work.hybrid_data_types.all;
use work.hybrid_data_formats.all;
use work.tracklet_config.all;
use work.tracklet_data_types.all;

entity tracklet_format_out is
port (
  clk: in std_logic;
  out_din: in t_datas( numOutputsFT - 1 downto 0 );
  out_dout: out t_channlesTB( numSeedTypes - 1 downto 0 )
);
end;

architecture rtl of tracklet_format_out is

signal dout: t_channlesTB( numSeedTypes - 1 downto 0 ) := ( others => nulll );

begin

out_dout <= dout;

process ( clk ) is
begin
if rising_edge( clk ) then

  dout( 0 ) <= nulll;
  dout( 0 ).track.reset <= out_din( 0 ).start;
  if out_din( 0 ).valid = '1' then
    dout( 0 ).track.valid    <= out_din( 0 ).data( 1 + widthTBseedType + widthTBinv2R + widthTBphi0 + widthTBz0 + widthTBcot + widthTrackletLmap - 1 );
    dout( 0 ).track.seedtype <= out_din( 0 ).data(     widthTBseedType + widthTBinv2R + widthTBphi0 + widthTBz0 + widthTBcot + widthTrackletLmap - 1 downto widthTBinv2R + widthTBphi0 + widthTBz0 + widthTBcot + widthTrackletLmap );
    dout( 0 ).track.inv2R    <= out_din( 0 ).data(                       widthTBinv2R + widthTBphi0 + widthTBz0 + widthTBcot + widthTrackletLmap - 1 downto                widthTBphi0 + widthTBz0 + widthTBcot + widthTrackletLmap );
    dout( 0 ).track.phi0     <= out_din( 0 ).data(                                      widthTBphi0 + widthTBz0 + widthTBcot + widthTrackletLmap - 1 downto                              widthTBz0 + widthTBcot + widthTrackletLmap );
    dout( 0 ).track.z0       <= out_din( 0 ).data(                                                    widthTBz0 + widthTBcot + widthTrackletLmap - 1 downto                                          widthTBcot + widthTrackletLmap );
    dout( 0 ).track.cot      <= out_din( 0 ).data(                                                                widthTBcot + widthTrackletLmap - 1 downto                                                       widthTrackletLmap );
    for k in 1 to numOutputsFT - 1 loop
      dout( 0 ).stubs( k - 1 ).valid   <= out_din( k ).data( 1 + widthTBtrackId + widthTBstubId + widthsTBr( 0 ) + widthsTBphi( 0 ) + widthsTBz( 0 ) - 1 );
      dout( 0 ).stubs( k - 1 ).trackId <= out_din( k ).data(     widthTBtrackId + widthTBstubId + widthsTBr( 0 ) + widthsTBphi( 0 ) + widthsTBz( 0 ) - 1 downto widthTBstubId + widthsTBr( 0 ) + widthsTBphi( 0 ) + widthsTBz( 0 ) );
      dout( 0 ).stubs( k - 1 ).stubId  <= out_din( k ).data(                      widthTBstubId + widthsTBr( 0 ) + widthsTBphi( 0 ) + widthsTBz( 0 ) - 1 downto                 widthsTBr( 0 ) + widthsTBphi( 0 ) + widthsTBz( 0 ) );
      dout( 0 ).stubs( k - 1 ).r       <= resize( out_din( k ).data(                                      widthsTBr( 0 ) + widthsTBphi( 0 ) + widthsTBz( 0 ) - 1 downto                                  widthsTBphi( 0 ) + widthsTBz( 0 ) ), widthTBr   );
      dout( 0 ).stubs( k - 1 ).phi     <= resize( out_din( k ).data(                                                       widthsTBphi( 0 ) + widthsTBz( 0 ) - 1 downto                                                     widthsTBz( 0 ) ), widthTBphi );
      dout( 0 ).stubs( k - 1 ).z       <= resize( out_din( k ).data(                                                                          widthsTBz( 0 ) - 1 downto                                                                  0 ), widthTBz   );
    end loop;
  end if;

end if;
end process;

end;