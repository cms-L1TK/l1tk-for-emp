 library ieee;
use ieee.std_logic_1164.all;

use work.hybrid_config.all;
use work.hybrid_data_formats.all;
use work.hybrid_data_types.all;


package dr_data_types is


type t_track is
record
  reset : std_logic;
  valid : std_logic;
  cm    : std_logic;
  inv2R : std_logic_vector( widthDRinv2R  - 1 downto 0 );
  phiT  : std_logic_vector( widthDRphiT   - 1 downto 0 );
  zT    : std_logic_vector( widthDRzT     - 1 downto 0 );
  stubs : t_stubsTM( numLayers - 1 downto 0 );
end record;
type t_tracks is array ( natural range <> ) of t_track;
function nulll return t_track;

type t_stub is
record
  valid : std_logic;
  stubId: std_logic_vector( widthDRstubId - 1 downto 0 );
end record;
type t_stubs is array ( natural range <> ) of t_stub;
function nulll return t_stub;

type t_cm is
record
  valid : std_logic;
  stubs : t_stubs( numLayers - 1 downto 0 );
end record;
type t_cms is array ( natural range <> ) of t_cm;
function nulll return t_cm;

function conv( t: t_channelTM ) return t_track;
function conv( t: t_track ) return t_cm;
function conv( t: t_track ) return t_channelDR;


end;


package body dr_data_types is


function nulll return t_track is begin return ( '0', '0', '0', ( others => '0' ), ( others => '0' ), ( others => '0' ), ( others => nulll ) ); end function;
function nulll return t_stub is begin return ( '0', ( others => '0' ) ); end function;
function nulll return t_cm is begin return ( '0', ( others => nulll ) ); end function;

function conv( t: t_channelTM ) return t_track is
  variable res: t_track := ( t.track.reset, t.track.valid, '0', t.track.inv2R, t.track.phiT, t.track.zT, t.stubs );
begin
  return res;
end function;

function conv( t: t_track ) return t_cm is
  variable res: t_cm := ( t.valid, ( others => nulll ) );
  variable s: t_stubTM;
begin
  for k in res.stubs'range loop
    s := t.stubs( k );
    res.stubs( k ) := ( s.valid, s.stubId );
  end loop;
  return res;
end function;

function conv( t: t_track ) return t_channelDR is
  variable res: t_channelDR := ( ( t.reset, t.valid, t.inv2R, t.phiT, t.zT ), ( others => nulll ) );
  variable s: t_stubTM;
begin
  for k in res.stubs'range loop
    s := t.stubs( k );
    res.stubs( k ) := ( s.reset, s.valid, s.r, s.phi, s.z, s.dPhi, s.dZ );
  end loop;
  return res;
end function;


end;