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
  reset : std_logic;
  valid : std_logic;
  cm    : std_logic;
  sector: std_logic_vector( widthDRsector - 1 downto 0 );
  inv2R : std_logic_vector( widthDRinv2R  - 1 downto 0 );
  phiT  : std_logic_vector( widthDRphiT   - 1 downto 0 );
  zT    : std_logic_vector( widthDRzT     - 1 downto 0 );
  cot   : std_logic_vector( widthDRcot    - 1 downto 0 );
  chi2  : std_logic_vector( widthDRchi2   - 1 downto 0 );
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


function nulll return t_track is begin return ( '0', '0', '0', ( others => '0' ), ( others => '0' ), ( others => '0' ), ( others => '0' ), ( others => '0' ), ( others => '0' ), ( others => '0' ), ( others => nulll ) ); end function;
function nulll return t_stub is begin return ( '0', ( others => '0' ) ); end function; -- is it used?

function conv( t: t_trackDRin ) return t_track is
  variable res: t_track := ( t.reset, t.valid, '0', t.sector, t.inv2R, t.phiT, t.zT, t.cot, ( others => '0' ), ( others => '0' ), t.stubs );
  variable s: t_stubDRin;
  variable chi2: signed( widthDRchi2 - 1 downto 0 ) := ( others => '0' );
  variable noConsistentStubs: signed( widthDRConsistentStubs - 1 downto 0) := ( others => '0' );
  variable phi: signed( widthDRphi - 1 downto 0) :=  ( others => '0' );
  variable z: signed( widthDRz - 1 downto 0) :=  ( others => '0' );
  variable dPhi: signed( widthDRdPhi - 1 downto 0) :=  ( others => '0' );
  variable dZ: signed( widthDRdZ - 1 downto 0) :=  ( others => '0' );
begin
  -- Calculate things if track is valid
  -- if t.valid = '1' then -- no tracks have valid stubs?!
    for k in res.stubs'range loop
      s := t.stubs( k );

      if s.valid = '1' then

        phi := signed(s.phi);
        z := signed(s.z);
        dPhi := signed(s.dPhi);
        dZ := signed(s.dZ);

        -- Calculate the chi2
        if dPhi > 0 then
          chi2 := chi2 + resize((phi*phi)/(dPhi*dPhi)/2, chi2'length); -- (phi*phi)/(dPhi*dPhi) OR (phi/dPhi)*(phi/dPhi) The 2 is for the number of degrees of freedom... unecessary?
        end if;

        if dZ > 0 then
          chi2 := chi2 + resize((z/dZ)*(z/dZ)/2, chi2'length);
        end if;

        -- Calculate the number of consistent stubs
        if abs(phi) < dPhi/2 and abs(z) < dZ/2 then -- Check that the residuals are smaller than half the resolution
          noConsistentStubs := noConsistentStubs + 1;
        end if;
      end if;

    end loop;

    res.chi2 := std_logic_vector(chi2);
    res.noConsistentStubs := std_logic_vector(noConsistentStubs);

  -- end if;

  return res;
end function;

function conv( t: t_track ) return t_trackDR is
  variable res: t_trackDR := ( t.reset, t.valid, t.sector, t.inv2R, t.phiT, t.zT, t.cot, ( others => nulll ) );
  variable s: t_stubDRin;
begin
  for k in res.stubs'range loop
    s := t.stubs( k );
    res.stubs( k ) := ( s.valid, s.r, s.phi, s.z, s.dPhi, s.dZ ); -- output
  end loop;
  return res;
end function;


end;