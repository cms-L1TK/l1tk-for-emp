library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

use work.tfp_tools.all;
use work.tfp_config.all;
use work.tfp_data_types.all;
use work.kf_data_formats.all;
use work.kf_data_types.all;

entity kf_format_in is
port (
    clk: in std_logic;
    in_din: in t_channelSF;
    in_dout: out t_channelProto
);
end;

architecture rtl of kf_format_in is

function f_valid( c: t_channelSF ) return boolean is
begin
    for k in c.stubs'range loop
        if c.stubs( k ).valid = '1' then
            return true;
        end if;
    end loop;
    return false;
end function;
function f_valid( c: t_channelProto ) return boolean is
begin
    for k in c.stubs'range loop
        if c.stubs( k ).valid = '1' then
            return true;
        end if;
    end loop;
    return false;
end function;
function f_lmap( l: std_logic_vector; c: t_channelSF ) return std_logic_vector is
    variable lmap: t_lmap := conv( l );
begin
    for k in c.stubs'range loop
        if c.stubs( k ).valid = '1' then
            lmap( k ) := incr( lmap( k ) );
        end if;
    end loop;
    return conv( lmap );
end function;
function conv( t: std_logic_vector; ss: t_stubsSF ) return t_stubsProto is
    variable p: t_stubsProto( ss'range ) := ( others => nulll );
    variable s: t_stubSF := nulll;
begin
    for k in ss' range loop
        s := ss( k );
        p( k ) := ( s.reset, s.valid, t, s.r, s.phi, s.z, s.dPhi, s.dZ );
    end loop;
    return p;
end function;

-- step 1
signal din: t_channelSF := nulll;

-- step 2
signal first, last, lastReg: std_logic := '0';
signal dout: t_stateProto := nulll;
signal stubs: t_stubsSF( numLayers - 1 downto 0 ) := ( others => nulll );

begin

-- step 2
first <= '1' when din.track.reset = '1' and in_din.track.reset = '0' else '0';
last <= '1' when f_valid( din ) and not f_valid( in_din ) else '0';
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
        dout.maybe <= din.track.maybe;
        dout.hitsT <= ( others => '0' );
        dout.lmap <= ( others => '0' );
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

    lastReg <= last;
    if din.track.reset = '1' then
        dout.reset <= '1';
        lastReg <= '1';
    elsif din.track.valid = '0' and lastReg = '0' then
        dout <= dout;
        dout.lmap <= f_lmap( dout.lmap, din );
    end if;

    dout.valid <= '0';
    if ( last = '1' or ( in_din.track.valid = '1' and din.track.reset = '0' ) ) then
        dout.valid <= '1';
    end if;

    if dout.valid = '1' and lastReg = '0' then
        dout.track <= incr( dout.track );
    end if;

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

use work.tfp_tools.all;
use work.tfp_config.all;
use work.tfp_data_formats.all;
use work.tfp_data_types.all;
use work.kf_data_formats.all;
use work.kf_data_types.all;

entity kf_format_out is
port (
    clk: in std_logic;
    out_track: in t_trackSF;
    out_channel: in t_channelResidual;
    out_dout: out t_channelKF
);
end;

architecture rtl of kf_format_out is

-- step 1

signal track: t_trackSF := nulll;
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