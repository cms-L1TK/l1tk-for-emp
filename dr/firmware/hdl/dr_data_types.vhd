 library ieee;
use ieee.std_logic_1164.all;

use work.hybrid_config.all;
use work.hybrid_data_formats.all;
use work.hybrid_data_types.all;
use ieee.numeric_std.all;
use std.textio.all; -- REMOVE ONCE DONE

package dr_data_types is


type t_track is
record
  reset     : std_logic;
  valid     : std_logic;
  cm        : std_logic;
  lastTrack : std_logic;
  inv2R     : std_logic_vector( widthDRinv2R  - 1 downto 0 );
  phiT      : std_logic_vector( widthDRphiT   - 1 downto 0 );
  zT        : std_logic_vector( widthDRzT     - 1 downto 0 );
  chi2      : std_logic_vector( widthDRchi2   - 1 downto 0 );
  noConsistentStubs: std_logic_vector( widthDRConsistentStubs - 1 downto 0);
  stubs : t_stubsDRin( numLayers - 1 downto 0 );
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

function conv( t: t_trackDRin ) return t_track;
function conv( t: t_track ) return t_trackDR;


end;


package body dr_data_types is


function nulll return t_track is begin return ( '0', '0', '0', '0', ( others => '0' ), ( others => '0' ), ( others => '0' ), ( others => '0' ), ( others => '0' ), ( others => nulll ) ); end function;
function nulll return t_stub is begin return ( '0', ( others => '0' ) ); end function; -- is it used?

function conv( t: t_trackDRin ) return t_track is
  variable res: t_track := ( t.reset, t.valid, '0', t.lastTrack, t.inv2R, t.phiT, t.zT, ( others => '0' ), ( others => '0' ), t.stubs );
  variable s: t_stubDRin;
  variable chi2: signed( widthDRchi2 - 1 downto 0 ) := ( others => '0' );
  -- variable chi2: real;
  variable noConsistentStubs: unsigned( widthDRConsistentStubs - 1 downto 0) := ( others => '0' );
  variable phi: signed( widthDRphi + 5 - 1 downto 0) :=  ( others => '0' ); -- 5 bit padding?!
  variable z: signed( widthDRz + 5 - 1 downto 0) :=  ( others => '0' );
  variable dPhi: signed( widthDRdPhi + 1 - 1 downto 0) :=  ( others => '0' ); -- extra bit for signed
  variable dZ: signed( widthDRdZ + 1 - 1 downto 0) :=  ( others => '0' );
begin

  -- Calculate things if track is valid
  if t.valid = '1' then

    for k in res.stubs'range loop

      s := t.stubs( k );

      if s.valid = '1' then

        phi(widthDRphi + 5 - 1 downto 5) := signed(s.phi); -- padded with 5 bits
        z(widthDRz + 5 - 1 downto 5) := signed(s.z);
        dPhi := signed('0' & s.dPhi); -- convert unsigned to signed
        dZ := signed('0' & s.dZ);

        -- Calculate the chi2
          chi2 := chi2 + resize((phi*phi)/(dPhi*dPhi), chi2'length) + resize((z*z)/(dZ*dZ), chi2'length); -- multiply by 2^-10 and divide by 2 to get the real value....

        -- Calculate the number of consistent stubs
        if abs(signed(s.phi)) < dPhi/2 and abs(signed(s.z)) < dZ/2 then -- Check that the residuals are smaller than half the resolution
          noConsistentStubs := noConsistentStubs + 1;
        end if;
      end if;

    end loop;

    res.chi2 := std_logic_vector(chi2);
    res.noConsistentStubs := std_logic_vector(noConsistentStubs);

  end if;

  return res;
end function;

function conv( t: t_track ) return t_trackDR is
  variable res: t_trackDR := ( t.reset, t.valid, t.inv2R, t.phiT, t.zT, ( others => nulll ) );
  variable s: t_stubDRin;
begin
  for k in res.stubs'range loop
    s := t.stubs( k );
    res.stubs( k ) := ( s.valid, s.r, s.phi, s.z, s.dPhi, s.dZ ); -- output
  end loop;
  return res;
end function;


end;