library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.kf_data_formats.all;
use work.kf_data_types.all;

entity kf_format_in is
port (
  clk: in std_logic;
  in_din: in t_channelZHT;
  in_dout: out t_channelProto
);
end;

architecture rtl of kf_format_in is

function conv( t: std_logic_vector; ss: t_stubsZHT ) return t_stubsProto is
  variable p: t_stubsProto( ss'range ) := ( others => nulll );
  variable s: t_stubZHT := nulll;
begin
  for k in ss' range loop
    s := ss( k );
    p( k ) := ( s.reset, s.valid, t, s.r, s.phi, s.z, s.dPhi, s.dZ );
  end loop;
  return p;
end function;

-- step 1
signal din: t_channelZHT := nulll;

-- step 2
signal dout: t_stateProto := nulll;
signal track: std_logic_vector( widthTrack - 1 downto 0 ) := ( others => '0' );
signal stubs: t_stubsZHT( numLayers - 1 downto 0 ) := ( others => nulll );

begin

-- step 2
in_dout <= ( dout, conv( dout.track, stubs ) );

process( clk )
begin
if rising_edge( clk ) then

  -- step 1

  din <= in_din;

  -- step 2

  stubs <= din.stubs;
  dout <= nulll;
  if din.track.valid = '1' then
    track <= incr( track );
    dout.valid <= '1';
    dout.track <= track;
    dout.maybe <= din.track.maybe;
    dout.hitsT <= ( others => '0' );
    dout.skip <= '0';
    if din.stubs( 0 ).valid = '0' then
      dout.skip <= '1';
    end if;
    for k in din.stubs'range loop
      if din.stubs( k ).valid = '1' then
        dout.hitsT( k ) <= '1';
      end if;
    end loop;
  end if;

  if din.track.reset = '1' then
    dout.reset <= '1';
    track <= ( others => '0' );
  end if;

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.hybrid_data_formats.all;
use work.hybrid_data_types.all;
use work.kf_data_formats.all;
use work.kf_data_types.all;

entity kf_format_out is
port (
  clk: in std_logic;
  out_track: in t_trackZHT;
  out_channel: in t_channelResidual;
  out_dout: out t_channelKF
);
end;

architecture rtl of kf_format_out is

-- step 1

signal track: t_trackZHT := nulll;
signal state: t_stateResidual := nulll;
signal stubs: t_stubsKF( numLayers - 1 downto 0 ) := ( others => nulll );
signal inv2R: t_inv2R := nulll;
signal phiT: t_phiT := nulll;
signal cot: t_cot := nulll;
signal zT: t_zT := nulll;
signal dout: t_channelKF := nulll;

begin

-- step 1
track <= out_track;
state <= out_channel.state;
stubs <= out_channel.stubs;

inv2R.x <= resize( track.inv2R & '1' & ( baseShift0 - baseShiftx0 - 1 - 1 downto 0 => '0' ), widthKFinv2R - baseShiftx0 );
inv2R.dx <= resize( state.x0, widthKFinv2R - baseShiftx0 );
inv2R.sum <= inv2R.x + inv2R.dx;
inv2R.over <= state.x0( widthx0 - 1 downto baseShift0 - baseShiftx0 - 1 );
inv2R.match <= '1' when sint( inv2R.over ) = 0 or sint( inv2R.over ) = -1 else '0';

phiT.x <= resize( track.phiT & '1' & ( baseShift1 - baseShiftx1 - 1 - 1 downto 0 => '0' ), widthKFphiT - baseShiftx1 );
phiT.dx <= resize( state.x1, widthKFphiT - baseShiftx1 );
phiT.sum <= phiT.x + phiT.dx;
phiT.over <= state.x1( widthx1 - 1 downto baseShift1 - baseShiftx1 - 1 );
phiT.match <= '1' when sint( phiT.over ) = 0 or sint( phiT.over ) = -1 else '0';

cot.x <= resize( track.cot & '1' & ( baseShift2 - baseShiftx2 - 1 - 1 downto 0 => '0' ), widthKFcot - baseShiftx2 );
cot.dx <= resize( state.x2, widthKFcot - baseShiftx2 );
cot.sum <= cot.x + cot.dx;

zT.x <= resize( track.zT & '1' & ( baseShift3 - baseShiftx3 - 1 - 1 downto 0 => '0' ), widthKFzT - baseShiftx3 );
zT.dx <= resize( state.x3, widthKFzT - baseShiftx3 );
zT.sum <= zT.x + zT.dx;

out_dout <= dout;

process( clk )
begin
if rising_edge( clk ) then

  -- step 1

  dout <= nulll;
  if state.valid = '1' then
    dout.track.valid <= '1';
    dout.track.sector <= track.sector;
    dout.stubs <= stubs;
    dout.track.inv2R <= inv2R.sum( r_inv2R );
    dout.track.phiT <= phiT.sum( r_phiT );
    dout.track.cot <= cot.sum( r_cot );
    dout.track.zT <= zT.sum( r_zT );
    if inv2R.match = '1' and phiT.match = '1' then
      dout.track.match <= '1';
    end if;
  end if;
  if state.reset = '1' then
    dout.track.reset <= '1';
    for k in dout.stubs'range loop
      dout.stubs( k ).reset <= '1';
    end loop;
  end if;

end if;
end process;

end;