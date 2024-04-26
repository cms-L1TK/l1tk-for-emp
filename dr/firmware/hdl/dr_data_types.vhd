library ieee;
use ieee.std_logic_1164.all;

use work.hybrid_config.all;
use work.hybrid_data_formats.all;
use work.hybrid_data_types.all;
use work.hybrid_tools.all;
use ieee.numeric_std.all;

package dr_data_types is

-- RAM things
constant widthDRinvRAM        : natural := 18; -- Because it would fit in an 18k BRAM (when the address is 10 bits) and we have 27 x 18 bits DSPs
constant widthDRinvAddressRAM : natural := max(widthDRdZ, widthDRdPhi);
type t_ramInv2 is array ( 0 to 2 ** widthDRinvAddressRAM - 1 ) of std_logic_vector( widthDRinvRAM - 1 downto 0 );
function init_ramInv2 return t_ramInv2;

type t_track is
record
  reset           : std_logic;
  valid           : std_logic;
  cm              : std_logic;
  lastTrack       : std_logic;
  inv2R           : std_logic_vector( widthDRinv2R           - 1 downto 0 );
  phiT            : std_logic_vector( widthDRphiT            - 1 downto 0 );
  zT              : std_logic_vector( widthDRzT              - 1 downto 0 );
  chi2            : std_logic_vector( widthDRchi2            - 1 downto 0 );
  nConsistentStubs: std_logic_vector( widthDRConsistentStubs - 1 downto 0 );
  stubs           : t_stubsDRin( numLayers - 1 downto 0 );
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

function conv( t: t_track ) return t_trackDR;

end;


package body dr_data_types is


function nulll return t_track is begin return ( '0', '0', '0', '0', ( others => '0' ), ( others => '0' ), ( others => '0' ), ( others => '0' ), ( others => '0' ), ( others => nulll ) ); end function;
function nulll return t_stub is begin return ( '0', ( others => '0' ) ); end function; -- is it used?

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

function init_ramInv2 return t_ramInv2 is
  variable ram: t_ramInv2 := ( others => ( others => '0' ) );
  variable denom, inv2: real;
  constant baseInv: real := 1.0 / 2 ** widthDRinvRAM;
begin
  for i in ram'range loop
      denom := real( i ) + 0.5;
      inv2 := ( 1.0 / denom ** 2 ) / baseInv;
      ram( i ) := stdu( inv2, widthDRinvRAM );
  end loop;
  return ram;
end function;

end;



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.hybrid_config.all;
use work.hybrid_data_formats.all;
use work.hybrid_data_types.all;
use work.dr_data_types.all;
use work.hybrid_tools.all;

-- DRin Track Conversion
entity track_conversion is
  port (
    clk: in std_logic;
    trk_in: in t_trackDRin;
    trk_out: out t_track
  );
  end;
  
  architecture rtl of track_conversion is

  -- Latency of this track conversion thingy
  constant latency : natural := 7;
  constant latency2: natural := 2; -- clks used for nConsistentStubs
  
  -- Tracks storage
  signal trk      : t_track := nulll;
  signal trks: t_tracks( 0 to latency - 1 ) := ( others => nulll ); -- latency of this 

  -- Initialise RAM for division
  signal ramInv2: t_ramInv2 := init_ramInv2;
  attribute ram_style: string;
  attribute ram_style of ramInv2: signal is "block";

  -- Signals for number of consistent stubs
  type nStubsArray is array ( 0 to latency - latency2 - 1) of std_logic_vector( widthDRConsistentStubs - 1 downto 0 );
  signal consistentStubs : std_logic_vector( 0 to numLayers - 1 ) := ( others => '0' ); -- Each bit represent a consistent stub
  signal nConsistentStubs: nStubsArray := ( others => ( others => '0' ) ); -- The number of consistent stubs, i.e. the number of 1s in the above vector

  -- Signals for chi2
  constant widthPhi2    : integer := widthDRphi * 2 - 0;
  constant widthZ2      : integer := widthDRz   * 2 - 0;
  constant widthChi2Phi : integer := widthPhi2 + widthDRinvRAM;
  constant widthChi2Z   : integer := widthZ2   + widthDRinvRAM;

  type t_dspChi2Phi is
    record
        A   : std_logic_vector( widthPhi2     - 1 downto 0 );
        B0  : std_logic_vector( widthDRinvRAM - 1 downto 0 );
        B1  : std_logic_vector( widthDRinvRAM + 1 downto 0 );
        res : std_logic_vector( widthChi2Phi  + 1 downto 0 );
    end record;

  type t_dspChi2Z is
    record
        A   : std_logic_vector( widthZ2       - 1 downto 0 );
        B0  : std_logic_vector( widthDRinvRAM - 1 downto 0 );
        B1  : std_logic_vector( widthDRinvRAM + 1 downto 0 );
        res : std_logic_vector( widthChi2Z    + 1 downto 0 );
    end record;

  type t_chi2s is array ( 0 to numLayers - 1 ) of unsigned( widthDRchi2 - 1 downto 0 );

  signal chi2s   : t_chi2s;
  signal chi2Sum : unsigned( widthDRchi2 - 1 downto 0 );


  begin
  
  -- Store and shift tracks
  trks( 0 ) <= ( trk_in.reset, trk_in.valid, '0', trk_in.lastTrack, trk_in.inv2R, trk_in.phiT, trk_in.zT, ( others => '0' ), ( others => '0' ), trk_in.stubs );
  trk_out <= trk;

  g_shift : for i in 0 to latency - 2 generate
  begin
    process ( clk ) is
    begin
    if rising_edge( clk ) then
      trks( i + 1 ) <= trks( i );
    end if;
  end process;
  end generate;

  -- Loop over all stubs in track
  g_stub: for k in trks( 0 ).stubs'range generate

  -- clk 1
  signal phi      : std_logic_vector( widthDRphi    - 0 downto 0 );
  signal z        : std_logic_vector( widthDRz      - 0 downto 0 );
  signal invdPhi2 : std_logic_vector( widthDRinvRAM - 1 downto 0 );
  signal invdZ2   : std_logic_vector( widthDRinvRAM - 1 downto 0 );

  -- clk 2
  signal phi2 : std_logic_vector( widthPhi2 + 1 downto 0 );
  signal z2   : std_logic_vector( widthZ2   + 1 downto 0 );

  attribute use_dsp : string;
  attribute use_dsp of phi2: signal is "yes"; -- otherwise 9x9 bits are considered too small for DSP

  -- clk 2-5
  signal dspChi2Phi : t_dspChi2Phi;
  signal dspChi2Z   : t_dspChi2Z;
  
  begin
    process ( clk ) is

    variable s : t_stubDRin := nulll;
    variable chi2 : std_logic_vector( widthChi2Z downto 0) := ( others => '0' );

    begin
    if rising_edge( clk ) then

      s := trk_in.stubs( k ); -- Get the stub on layer k

      -- clk 1: Check if consistent stub
      consistentStubs( k ) <= '0';
      if '0' & abs( s.phi ) & '1' < '0' & s.dPhi and '0' & abs( s.z ) & '1' < '0' & s.dZ then -- Check that the residuals are smaller than half the resolution.
        consistentStubs( k ) <= '1';
      end if;

      -- clk 1: Read values from stub and RAM
      phi      <= s.phi & '1'; -- add '1' due to biased integers
      z        <= s.z   & '1'; -- add '1' due to biased integers
      invdPhi2 <= ramInv2( uint( s.dPhi ) );
      invdZ2   <= ramInv2( uint( s.dZ ) );
  
      -- clk 2: Calculate squared phi and z
      phi2          <= phi * phi;
      z2            <= z * z;
      dspChi2Phi.B0 <= invdPhi2;
      dspChi2Z.B0   <= invdZ2;

      -- clk 3: Save signals to DSP registers
      dspChi2Phi.A  <= phi2( widthPhi2 downto 2 ) & '1'; -- Should have '0' sign padding from previously...
      dspChi2Z.A    <= z2( widthZ2 downto 2 ) & '1';
      dspChi2Phi.B1 <= '0' & dspChi2Phi.B0 & '1';
      dspChi2Z.B1   <= '0' & dspChi2Z.B0 & '1';

      -- clk 4: Calculate the chi2 separately
      dspChi2Phi.res <= dspChi2Phi.A * dspChi2Phi.B1;
      dspChi2Z.res   <= dspChi2Z.A * dspChi2Z.B1;
      -- Technically should be divided by 2 because of the number of degrees of freedom but doesn't matter atm

      -- clk 5: Save phi and z chi2
      chi2 := dspChi2Phi.res( widthChi2Phi + 1 downto 2 ) + dspChi2Z.res( widthChi2Z + 1 downto 2 );
      chi2s( k ) <= resize( unsigned( chi2 ), widthDRchi2 );

    end if; -- clk
    end process;
  end generate;


  -- clk 4-6: Shift nConsistentStubs
  g_shift_stubs : for i in 0 to latency - latency2 - 2 generate
  begin
    process ( clk ) is
    begin
    if rising_edge( clk ) then
      nConsistentStubs( i + 1 ) <= nConsistentStubs( i );
    end if;
  end process;
  end generate;


  -- Save values to output track
  process ( clk ) is

  -- clk 7
  variable chi2Sum_tmp: unsigned( widthDRchi2 - 1 downto 0 ) := ( others => '0' );

  begin
  if rising_edge( clk ) then

    -- clk 2: Sum the number of consistent stubs
    nConsistentStubs( 0 ) <= stdu( count( consistentStubs, '1' ), widthDRConsistentStubs );

    -- clk 6: Sum the temporary chi2 values
    chi2Sum_tmp := ( others => '0' );
    for k in 0 to numLayers - 1 loop
      chi2Sum_tmp := chi2Sum_tmp + chi2s( k );
    end loop;
    chi2Sum <= chi2Sum_tmp;

    -- clk 7: Set values to track
    trk.reset            <= trks( latency - 1 ).reset;
    trk.valid            <= trks( latency - 1 ).valid;
    trk.cm               <= '0';
    trk.lastTrack        <= trks( latency - 1 ).lastTrack;
    trk.inv2R            <= trks( latency - 1 ).inv2R;
    trk.phiT             <= trks( latency - 1 ).phiT;
    trk.zT               <= trks( latency - 1 ).zT;
    trk.chi2             <= std_logic_vector( chi2Sum );
    trk.nConsistentStubs <= nConsistentStubs( nConsistentStubs'high );
    trk.stubs            <= trks( latency - 1 ).stubs;

  end if;
  end process;

end;

