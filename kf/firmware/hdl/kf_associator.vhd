library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.kf_data_types.all;

entity kf_associator is
generic (
  index: natural
);
port (
  clk: in std_logic;
  associator_state: in t_state;
  associator_stub: in t_stubProto;
  associator_dout: out t_state
);
end;

architecture rtl of kf_associator is

signal comb_updater: t_state := nulll;
signal comb_core: t_state := nulll;
signal comb_dout: t_state := nulll;
component kf_associator_comb
port (
  clk: in std_logic;
  comb_updater: in t_state;
  comb_core: in t_state;
  comb_dout: out t_state
);
end component;

signal core_state: t_state := nulll;
signal core_stub: t_stubProto := nulll;
signal core_comb: t_state := nulll;
signal core_update: t_state := nulll;
component kf_associator_core
generic (
  index: natural
);
port (
  clk: in std_logic;
  core_state: in t_state;
  core_stub: in t_stubProto;
  core_comb: out t_state;
  core_update: out t_state
);
end component;

begin

comb_updater <= associator_state;
comb_core <= core_comb;

core_state <= comb_dout;
core_stub <= associator_stub;
associator_dout <= core_update;

comb: kf_associator_comb port map ( clk, comb_updater, comb_core, comb_dout );

core: kf_associator_core generic map( index ) port map ( clk, core_state, core_stub, core_comb, core_update );

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.kf_data_formats.all;
use work.kf_data_types.all;

entity kf_associator_comb is
port (
  clk: in std_logic;
  comb_updater: in t_state;
  comb_core: in t_state;
  comb_dout: out t_state
);
end;

architecture rtl of kf_associator_comb is

constant widthRam: natural := 1 + widthTrack + widthLMap + widthLayer + widthStubs + widthMaybe + widthHitsT + widthHits + widthx0 + widthx1 + widthx2 + widthx3 + widthC00 +  widthC01 +  widthC11 + widthC22 + widthC23 + widthC33;
constant widthAddr: natural := widthFrames;
type t_ram is array ( 0 to 2 ** widthAddr - 1 ) of std_logic_vector( widthRam - 1 downto 0 );
attribute ram_style: string;
function conv( s: std_logic_vector ) return t_state is
  variable k: t_state := nulll;
begin
  k.skip  := s( widthTrack + widthLMap + widthLayer + widthStubs + widthMaybe + widthHitsT + widthHits + widthx0 + widthx1 + widthx2 + widthx3 + widthC00 +  widthC01 +  widthC11 + widthC22 + widthC23 + widthC33);
  k.track := s( widthTrack + widthLMap + widthLayer + widthStubs + widthMaybe + widthHitsT + widthHits + widthx0 + widthx1 + widthx2 + widthx3 + widthC00 +  widthC01 +  widthC11 + widthC22 + widthC23 + widthC33 - 1 downto widthLMap + widthLayer + widthStubs + widthMaybe + widthHitsT + widthHits + widthx0 + widthx1 + widthx2 + widthx3 + widthC00 +  widthC01 +  widthC11 + widthC22 + widthC23 + widthC33 );
  k.lmap  := s(              widthLMap + widthLayer + widthStubs + widthMaybe + widthHitsT + widthHits + widthx0 + widthx1 + widthx2 + widthx3 + widthC00 +  widthC01 +  widthC11 + widthC22 + widthC23 + widthC33 - 1 downto             widthLayer + widthStubs + widthMaybe + widthHitsT + widthHits + widthx0 + widthx1 + widthx2 + widthx3 + widthC00 +  widthC01 +  widthC11 + widthC22 + widthC23 + widthC33 );
  k.layer := s(                          widthLayer + widthStubs + widthMaybe + widthHitsT + widthHits + widthx0 + widthx1 + widthx2 + widthx3 + widthC00 +  widthC01 +  widthC11 + widthC22 + widthC23 + widthC33 - 1 downto                          widthStubs + widthMaybe + widthHitsT + widthHits + widthx0 + widthx1 + widthx2 + widthx3 + widthC00 +  widthC01 +  widthC11 + widthC22 + widthC23 + widthC33 );
  k.stub  := s(                                       widthStubs + widthMaybe + widthHitsT + widthHits + widthx0 + widthx1 + widthx2 + widthx3 + widthC00 +  widthC01 +  widthC11 + widthC22 + widthC23 + widthC33 - 1 downto                                       widthMaybe + widthHitsT + widthHits + widthx0 + widthx1 + widthx2 + widthx3 + widthC00 +  widthC01 +  widthC11 + widthC22 + widthC23 + widthC33 );
  k.maybe := s(                                                    widthMaybe + widthHitsT + widthHits + widthx0 + widthx1 + widthx2 + widthx3 + widthC00 +  widthC01 +  widthC11 + widthC22 + widthC23 + widthC33 - 1 downto                                                    widthHitsT + widthHits + widthx0 + widthx1 + widthx2 + widthx3 + widthC00 +  widthC01 +  widthC11 + widthC22 + widthC23 + widthC33 );
  k.hitsT := s(                                                                 widthHitsT + widthHits + widthx0 + widthx1 + widthx2 + widthx3 + widthC00 +  widthC01 +  widthC11 + widthC22 + widthC23 + widthC33 - 1 downto                                                                 widthHits + widthx0 + widthx1 + widthx2 + widthx3 + widthC00 +  widthC01 +  widthC11 + widthC22 + widthC23 + widthC33 );
  k.hits  := s(                                                                              widthHits + widthx0 + widthx1 + widthx2 + widthx3 + widthC00 +  widthC01 +  widthC11 + widthC22 + widthC23 + widthC33 - 1 downto                                                                             widthx0 + widthx1 + widthx2 + widthx3 + widthC00 +  widthC01 +  widthC11 + widthC22 + widthC23 + widthC33 );
  k.x0    := s(                                                                                          widthx0 + widthx1 + widthx2 + widthx3 + widthC00 +  widthC01 +  widthC11 + widthC22 + widthC23 + widthC33 - 1 downto                                                                                       widthx1 + widthx2 + widthx3 + widthC00 +  widthC01 +  widthC11 + widthC22 + widthC23 + widthC33 );
  k.x1    := s(                                                                                                    widthx1 + widthx2 + widthx3 + widthC00 +  widthC01 +  widthC11 + widthC22 + widthC23 + widthC33 - 1 downto                                                                                                 widthx2 + widthx3 + widthC00 +  widthC01 +  widthC11 + widthC22 + widthC23 + widthC33 );
  k.x2    := s(                                                                                                              widthx2 + widthx3 + widthC00 +  widthC01 +  widthC11 + widthC22 + widthC23 + widthC33 - 1 downto                                                                                                           widthx3 + widthC00 +  widthC01 +  widthC11 + widthC22 + widthC23 + widthC33 );
  k.x3    := s(                                                                                                                        widthx3 + widthC00 +  widthC01 +  widthC11 + widthC22 + widthC23 + widthC33 - 1 downto                                                                                                                     widthC00 +  widthC01 +  widthC11 + widthC22 + widthC23 + widthC33 );
  k.C00   := s(                                                                                                                                  widthC00 +  widthC01 +  widthC11 + widthC22 + widthC23 + widthC33 - 1 downto                                                                                                                                 widthC01 +  widthC11 + widthC22 + widthC23 + widthC33 );
  k.C01   := s(                                                                                                                                              widthC01 +  widthC11 + widthC22 + widthC23 + widthC33 - 1 downto                                                                                                                                             widthC11 + widthC22 + widthC23 + widthC33 );
  k.C11   := s(                                                                                                                                                          widthC11 + widthC22 + widthC23 + widthC33 - 1 downto                                                                                                                                                        widthC22 + widthC23 + widthC33 );
  k.C22   := s(                                                                                                                                                                     widthC22 + widthC23 + widthC33 - 1 downto                                                                                                                                                                   widthC23 + widthC33 );
  k.C23   := s(                                                                                                                                                                                widthC23 + widthC33 - 1 downto                                                                                                                                                                              widthC33 );
  k.C33   := s(                                                                                                                                                                                           widthC33 - 1 downto                                                                                                                                                                                     0 );
  return k;
end function;
function conv( k: t_state ) return std_logic_vector is
begin
  return k.skip & k.track & k.lmap & k.layer & k.stub & k.maybe  & k.hitsT  & k.hits & k.x0 & k.x1 & k.x2 & k.x3 & k.C00 & k.C01 & k.C11 & k.C22 & k.C23 & k.C33;
end function;

-- step 1
signal dead: std_logic := '0';
signal din: t_state := nulll;
signal ram: t_ram := ( others => ( others => '0' ) );
signal waddr, raddr: std_logic_vector( widthAddr - 1 downto 0 ) := ( others => '0' );
signal optional: t_state := nulll;
attribute ram_style of ram: signal is "block";

-- step 2
signal regDin: t_state := nulll;
signal regRam: t_state := nulll;

-- step 3
signal dout: t_state := nulll;

begin

-- step 3
comb_dout <= dout;

process( clk ) is
begin
if rising_edge( clk ) then

  -- step 1

  din <= comb_updater;
  ram( uint( waddr ) ) <= conv( comb_core );
  optional <= conv( ram( uint( raddr ) ) );
  if comb_core.valid = '1' and dead = '0' then
    waddr <= incr( waddr );
  end if;
  if comb_updater.valid = '0' and raddr /= waddr then
    optional.valid <= '1';
    raddr <= incr( raddr );
  end if;
  if comb_updater.reset = '1' then
    optional.valid <= '0';
    waddr <= ( others => '0' );
    raddr <= ( others => '0' );
    dead <= '1';
  end if;
  if comb_core.reset = '1' then
    dead <= '0';
  end if;

  -- step 2

  regDin <= din;
  regRam <= optional;

  -- step 3

  dout <= regDin;
  if regRam.valid = '1' then
    dout <= regRam;
  end if;

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.kf_data_formats.all;
use work.kf_data_types.all;

entity kf_associator_core is
generic (
  index: natural
);
port (
  clk: in std_logic;
  core_state: in t_state;
  core_stub: in t_stubProto;
  core_comb: out t_state;
  core_update: out t_state
);
end;

architecture rtl of kf_associator_core is

attribute ram_style: string;
constant widthRam: natural := widthH00 + widthm0 + widthm1 + widthd0 + widthd1;
constant widthAddr: natural := widthTrack + widthStubs;
type t_ram is array ( 0 to 2 ** widthAddr - 1 ) of std_logic_vector( widthRam - 1 downto 0 );
function conv( s: t_stubProto ) return std_logic_vector is
begin
  return s.r & s.phi & s.z & s.dPhi & s.dZ;
end function;
function conv( s: std_logic_vector ) return t_stubProto is
  variable r: t_stubProto := nulll;
begin
  r.r    := s( widthH00 + widthm0 + widthm1 + widthd0 + widthd1 - 1 downto widthm0 + widthm1 + widthd0 + widthd1 );
  r.phi  := s(            widthm0 + widthm1 + widthd0 + widthd1 - 1 downto           widthm1 + widthd0 + widthd1 );
  r.z    := s(                      widthm1 + widthd0 + widthd1 - 1 downto                     widthd0 + widthd1 );
  r.dPhi := s(                                widthd0 + widthd1 - 1 downto                               widthd1 );
  r.dZ   := s(                                          widthd1 - 1 downto                                     0 );
  return r;
end function;

function f_skip( state: t_state ) return boolean is
  variable available: natural;
  variable needed: natural := maxStubs - count( state.hits, '1' );
begin
  if index = numLayers - 1 then
    return false;
  end if;
  available := count( state.hitsT, numLayers - 1, index + 1, '1' );
  return available >= needed;
end function;

-- step 1
signal state: t_state := nulll;
signal valid: std_logic := '0';
signal track: std_logic_vector( widthTrack - 1 downto 0 ) := ( others => '0' );
signal ram: t_ram := ( others => ( others => '0' ) );
signal waddr, raddr: std_logic_vector( widthAddr - 1 downto 0 ) := ( others => '0' ); 
signal counter: std_logic_vector( widthStubs - 1 downto 0 ) := ( others => '0' );
signal counterReg: std_logic_vector( widthStubs - 1 downto 0 ) := ( others => '0' );
signal optional: t_stubProto := nulll;
attribute ram_style of ram: signal is "block";

-- step 2
signal lmap: t_lmap := ( others => ( others => '0' ) );
signal update, comb: t_state := nulll;

begin

-- step 1
counter <= ( others => '0' ) when core_stub.valid = '0' or valid /= core_stub.valid or track /= core_stub.track else incr( counterReg );
waddr <= core_stub.track & counter;
raddr <= core_state.track & core_state.stub;

-- step 2
lmap <= conv( state.lmap );
core_comb <= comb;
core_update <= update;

process( clk ) is
begin
if rising_edge( clk ) then

  -- step 1

  valid <= core_stub.valid;
  track <= core_stub.track;
  state <= core_state;
  counterReg <= counter;
  if core_stub.valid = '1' then
    ram( uint( waddr ) ) <= conv( core_stub );
  end if;
  optional <= conv( ram( uint( raddr ) ) );

  -- step 2

  update <= state;
  comb <= state;
  if state.valid = '1' then
    update.H00 <= optional.r;
    update.m0 <= optional.phi;
    update.m1 <= optional.z;
    update.d0 <= optional.dPhi;
    update.d1 <= optional.dZ;
    comb.valid <= '0';
    if state.skip = '0' then
      if unsigned( state.stub ) < unsigned( lmap( index ) ) then
        comb.valid <= '1';
        comb.stub <= incr( state.stub );
      elsif f_skip( state ) then
        comb.valid <= '1';
        comb.skip <= '1';
        comb.stub <= ( others => '0' );
      end if;
    end if;
  end if;

end if;
end process;

end;