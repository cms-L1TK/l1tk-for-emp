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
  associator_stub: in t_stub;
  associator_dout: out t_update
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
signal core_stub: t_stub := nulll;
signal core_comb: t_state := nulll;
signal core_update: t_update := nulll;
component kf_associator_core
generic (
  index: natural
);
port (
  clk: in std_logic;
  core_state: in t_state;
  core_stub: in t_stub;
  core_comb: out t_state;
  core_update: out t_update
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
use work.hybrid_data_formats.all;
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

constant widthRam: natural := widthTrack + widthHits + widthHits + widthx0 + widthx1 + widthx2 + widthx3 + widthC00 +  widthC01 +  widthC11 + widthC22 + widthC23 + widthC33;
constant widthAddr: natural := widthFrames;
type t_ram is array ( 0 to 2 ** widthAddr - 1 ) of std_logic_vector( widthRam - 1 downto 0 );
attribute ram_style: string;
function conv( s: std_logic_vector ) return t_state is
  variable k: t_state := nulll;
begin
  k.meta.track := s( widthTrack + widthHits + widthHits + widthx0 + widthx1 + widthx2 + widthx3 + widthC00 +  widthC01 +  widthC11 + widthC22 + widthC23 + widthC33 - 1 downto widthHits + widthHits + widthx0 + widthx1 + widthx2 + widthx3 + widthC00 +  widthC01 +  widthC11 + widthC22 + widthC23 + widthC33 );
  k.meta.hitsT := s(              widthHits + widthHits + widthx0 + widthx1 + widthx2 + widthx3 + widthC00 +  widthC01 +  widthC11 + widthC22 + widthC23 + widthC33 - 1 downto             widthHits + widthx0 + widthx1 + widthx2 + widthx3 + widthC00 +  widthC01 +  widthC11 + widthC22 + widthC23 + widthC33 );
  k.meta.hitsS := s(                          widthHits + widthx0 + widthx1 + widthx2 + widthx3 + widthC00 +  widthC01 +  widthC11 + widthC22 + widthC23 + widthC33 - 1 downto                         widthx0 + widthx1 + widthx2 + widthx3 + widthC00 +  widthC01 +  widthC11 + widthC22 + widthC23 + widthC33 );
  k.track.x0  := s(                                      widthx0 + widthx1 + widthx2 + widthx3 + widthC00 +  widthC01 +  widthC11 + widthC22 + widthC23 + widthC33 - 1 downto                                   widthx1 + widthx2 + widthx3 + widthC00 +  widthC01 +  widthC11 + widthC22 + widthC23 + widthC33 );
  k.track.x1  := s(                                                widthx1 + widthx2 + widthx3 + widthC00 +  widthC01 +  widthC11 + widthC22 + widthC23 + widthC33 - 1 downto                                             widthx2 + widthx3 + widthC00 +  widthC01 +  widthC11 + widthC22 + widthC23 + widthC33 );
  k.track.x2  := s(                                                          widthx2 + widthx3 + widthC00 +  widthC01 +  widthC11 + widthC22 + widthC23 + widthC33 - 1 downto                                                       widthx3 + widthC00 +  widthC01 +  widthC11 + widthC22 + widthC23 + widthC33 );
  k.track.x3  := s(                                                                    widthx3 + widthC00 +  widthC01 +  widthC11 + widthC22 + widthC23 + widthC33 - 1 downto                                                               + widthC00 +  widthC01 +  widthC11 + widthC22 + widthC23 + widthC33 );
  k.cov.C00   := s(                                                                              widthC00 +  widthC01 +  widthC11 + widthC22 + widthC23 + widthC33 - 1 downto                                                                             widthC01 +  widthC11 + widthC22 + widthC23 + widthC33 );
  k.cov.C01   := s(                                                                                          widthC01 +  widthC11 + widthC22 + widthC23 + widthC33 - 1 downto                                                                                         widthC11 + widthC22 + widthC23 + widthC33 );
  k.cov.C11   := s(                                                                                                      widthC11 + widthC22 + widthC23 + widthC33 - 1 downto                                                                                                    widthC22 + widthC23 + widthC33 );
  k.cov.C22   := s(                                                                                                                 widthC22 + widthC23 + widthC33 - 1 downto                                                                                                               widthC23 + widthC33 );
  k.cov.C23   := s(                                                                                                                            widthC23 + widthC33 - 1 downto                                                                                                                          widthC33 );
  k.cov.C33   := s(                                                                                                                                       widthC33 - 1 downto                                                                                                                                 0 );
  return k;
end function;
function conv( k: t_state ) return std_logic_vector is
begin
  return k.meta.track & k.meta.hitsT & k.meta.hitsS & k.track.x0 & k.track.x1 & k.track.x2 & k.track.x3 & k.cov.C00 & k.cov.C01 & k.cov.C11 & k.cov.C22 & k.cov.C23 & k.cov.C33;
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
  if comb_core.meta.valid = '1' and dead = '0' then
    waddr <= waddr + 1;
  end if;
  if comb_updater.meta.valid = '0' and raddr /= waddr then
    optional.meta.valid <= '1';
    raddr <= raddr + 1;
  end if;
  if comb_updater.meta.reset = '1' then
    optional.meta.valid <= '0';
    waddr <= ( others => '0' );
    raddr <= ( others => '0' );
    dead <= '1';
  end if;
  if comb_core.meta.reset = '1' then
    dead <= '0';
  end if;

  -- step 2

  regDin <= din;
  regRam <= optional;

  -- step 3

  dout <= regDin;
  if regRam.meta.valid = '1' then
    dout <= regRam;
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

entity kf_associator_core is
generic (
  index: natural := 0
);
port (
  clk: in std_logic;
  core_state: in t_state;
  core_stub: in t_stub;
  core_comb: out t_state;
  core_update: out t_update
);
end;

architecture rtl of kf_associator_core is

attribute ram_style: string;
constant widthRam: natural := widthH00 + widthm0 + widthm1 + widthd0 + widthd1;
constant widthAddr: natural := widthTrack;
type t_ram is array ( 0 to 2 ** widthAddr - 1 ) of std_logic_vector( widthRam - 1 downto 0 );
function conv( stub: t_parameterStub ) return std_logic_vector is begin return stub.H00 & stub.m0 & stub.m1 & stub.d0 & stub.d1; end function;
function conv( std: std_logic_vector ) return t_parameterStub is
  variable stub: t_parameterStub := nulll;
begin
  stub.H00 := std( widthH00 + widthm0 + widthm1 + widthd0 + widthd1 - 1 downto widthm0 + widthm1 + widthd0 + widthd1 );
  stub.m0  := std(            widthm0 + widthm1 + widthd0 + widthd1 - 1 downto           widthm1 + widthd0 + widthd1 );
  stub.m1  := std(                      widthm1 + widthd0 + widthd1 - 1 downto                     widthd0 + widthd1 );
  stub.d0  := std(                                widthd0 + widthd1 - 1 downto                               widthd1 );
  stub.d1  := std(                                          widthd1 - 1 downto                                     0 );
  return stub;
end function;

-- step 1
signal validUpdate, validMin, validNext, validSkip: std_logic := '0';
signal state: t_state := nulll;
signal ram: t_ram := ( others => ( others => '0' ) );
signal optional: t_parameterStub := nulll;
attribute ram_style of ram: signal is "block";

-- step 2
signal update: t_update := nulll;
signal comb: t_state := nulll;

begin

-- step 2
core_comb <= comb;
core_update <= update;

process( clk ) is
begin
if rising_edge( clk ) then

  -- step 1

  validUpdate <= '0';
  validMin <= '0';
  validNext <= '0';
  validSkip <= '0';
  state <= core_state;
  if core_state.meta.valid = '1' and count( core_state.meta.hitsS, index + 1, numLayers - 1 ) = 0 then
    if core_state.meta.hitsS( index ) = '0' then
      if core_state.meta.hitsT( index ) = '1' and count( core_state.meta.hitsS, 0, index ) < kfMaxStubs then
        validMin <= '1';
      end if;
    else
      validUpdate <= '1';
      if count( core_state.meta.hitsS, 0, index ) < kfMaxStubs and count( core_state.meta.hitsT, index + 1, numLayers - 1 ) > 0 then
        if count( core_state.meta.hitsT, index + 1, numLayers - 1 ) + count( core_state.meta.hitsS, 0, index - 1 ) >= kfMinStubs then
          validSkip <= '1';
        end if;
        if count( core_state.meta.hitsS, 0, index ) < kfMinStubs then
          validNext <= '1';
        end if;
      end if;
    end if;
  end if;
  if core_stub.meta.valid = '1' then
    ram( uint( core_stub.meta.track ) ) <= conv( core_stub.param );
  end if;
  optional <= conv( ram( uint( core_state.meta.track ) ) );

  -- step 2

  update <= ( state.meta, nulll, state.track, state.cov );
  comb <= state;
  comb.meta.valid <= '0';
  if validUpdate = '1' then
    update.stub <= optional;
  end if;
  if validMin = '1' then
    comb.meta.valid <= '1';
    comb.meta.hitsS( index ) <= '1';
  end if;
  if validSkip = '1' then
    comb.meta.valid <= '1';
    comb.meta.hitsS( index ) <= '0';
    comb.meta.hitsS( find( state.meta.hitsT, index + 1, numLayers - 1, '1' ) ) <= '1';
  end if;
  if validNext = '1' then
    update.meta.hitsS( find( state.meta.hitsT, index + 1, numLayers - 1, '1' ) ) <= '1';
  end if;

end if;
end process;

end;