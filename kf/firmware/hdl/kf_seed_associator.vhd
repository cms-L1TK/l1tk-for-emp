library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.kf_data_types.all;

entity kf_seed_associator is
generic (
  index: natural
);
port (
  clk: in std_logic;
  associator_din: in t_seed;
  associator_stub: in t_stub;
  associator_dout: out t_seed
);
end;

architecture rtl of kf_seed_associator is

signal comb_din: t_seed := nulll;
signal comb_core: t_seed := nulll;
signal comb_dout: t_seed := nulll;
component kf_seed_associator_comb
port (
  clk: in std_logic;
  comb_din: in t_seed;
  comb_core: in t_seed;
  comb_dout: out t_seed
);
end component;

signal core_din: t_seed := nulll;
signal core_stub: t_stub := nulll;
signal core_comb: t_seed := nulll;
signal core_dout: t_seed := nulll;
component kf_seed_associator_core
generic (
  index: natural
);
port (
  clk: in std_logic;
  core_din: in t_seed;
  core_stub: in t_stub;
  core_comb: out t_seed;
  core_dout: out t_seed
);
end component;

begin

comb_din <= associator_din;
comb_core <= core_comb;

core_din <= comb_dout;
core_stub <= associator_stub;
associator_dout <= core_dout;

comb: kf_seed_associator_comb port map ( clk, comb_din, comb_core, comb_dout );

core: kf_seed_associator_core generic map( index ) port map ( clk, core_din, core_stub, core_comb, core_dout );

end;


library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.hybrid_data_formats.all;
use work.kf_data_formats.all;
use work.kf_data_types.all;

entity kf_seed_associator_comb is
port (
  clk: in std_logic;
  comb_din: in t_seed;
  comb_core: in t_seed;
  comb_dout: out t_seed
);
end;

architecture rtl of kf_seed_associator_comb is

constant widthRam: natural := kfNumSeedLayer * widthParameterStub + widthTrack + widthHits + widthHits;
constant widthAddr: natural := widthFrames;
type t_ram is array ( 0 to 2 ** widthAddr - 1 ) of std_logic_vector( widthRam - 1 downto 0 );
attribute ram_style: string;
function conv( std: std_logic_vector( widthParameterStub - 1 downto 0 ) ) return t_parameterStub is
  variable stub: t_parameterStub;
begin
  stub.H00   := std( widthH00 + widthm0 + widthm1 + widthd0 + widthd1 - 1 downto widthm0 + widthm1 + widthd0 + widthd1 );
  stub.m0    := std(            widthm0 + widthm1 + widthd0 + widthd1 - 1 downto           widthm1 + widthd0 + widthd1 );
  stub.m1    := std(                      widthm1 + widthd0 + widthd1 - 1 downto                     widthd0 + widthd1 );
  stub.d0    := std(                                widthd0 + widthd1 - 1 downto                               widthd1 );
  stub.d1    := std(                                          widthd1 - 1 downto                                     0 );
  return stub;
end function;
function conv( std: std_logic_vector ) return t_parameterStubs is
  variable stubs: t_parameterStubs( 0 to kfNumSeedLayer - 1 );
begin
  for k in 0 to kfNumSeedLayer - 1 loop
    stubs( k ) := conv( std( ( k + 1 ) * widthParameterStub - 1 downto k * widthParameterStub ) );
  end loop;
  return stubs;
end function;
function conv( std: std_logic_vector ) return t_seed is
  variable s: t_seed := nulll;
  variable stubs: std_logic_vector( kfNumSeedLayer * widthParameterStub -1 downto 0 );
begin
  stubs       := std( kfNumSeedLayer * widthParameterStub + widthTrack + widthHits + widthHits - 1 downto widthTrack + widthHits + widthHits );
  s.meta.track := std(                                       widthTrack + widthHits + widthHits - 1 downto              widthHits + widthHits );
  s.meta.hitsT := std(                                                    widthHits + widthHits - 1 downto                          widthHits );
  s.meta.hitsS := std(                                                                widthHits - 1 downto                                  0 );
  s.stubs := conv( stubs );
  return s;
end function;
function conv( stub: t_parameterStub ) return std_logic_vector is
begin
  return stub.H00 & stub.m0 & stub.m1 & stub.d0 & stub.d1;
end function;
function conv( stubs: t_parameterStubs ) return std_logic_vector is
  variable s: std_logic_vector( kfNumSeedLayer * widthParameterStub - 1 downto 0 );
begin
  for k in 0 to kfNumSeedLayer - 1 loop
    s( ( k + 1 ) * widthParameterStub - 1 downto k * widthParameterStub ) := conv( stubs( k ) );
  end loop;
  return s;
end function;
function conv( s: t_seed ) return std_logic_vector is
begin
  return conv( s.stubs ) & s.meta.track  & s.meta.hitsT  & s.meta.hitsS;
end function;

-- step 1
signal dead: std_logic := '0';
signal din: t_seed := nulll;
signal ram: t_ram := ( others => ( others => '0' ) );
signal waddr, raddr: std_logic_vector( widthAddr - 1 downto 0 ) := ( others => '0' );
signal optional: t_seed := nulll;
attribute ram_style of ram: signal is "block";

-- step 2
signal regDin: t_seed := nulll;
signal regRam: t_seed := nulll;

-- step 3
signal dout: t_seed := nulll;

begin

-- step 3
comb_dout <= dout;

process( clk ) is
begin
if rising_edge( clk ) then

  -- step 1

  din <= comb_din;
  ram( uint( waddr ) ) <= conv( comb_core );
  optional <= conv( ram( uint( raddr ) ) );
  if comb_core.meta.valid = '1' and dead = '0' then
    waddr <= waddr + 1;
  end if;
  if comb_din.meta.valid = '0' and raddr /= waddr then
    optional.meta.valid <= '1';
    raddr <= raddr + 1;
  end if;
  if comb_din.meta.reset = '1' then
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

entity kf_seed_associator_core is
generic (
  index: natural
);
port (
  clk: in std_logic;
  core_din: in t_seed;
  core_stub: in t_stub;
  core_comb: out t_seed;
  core_dout: out t_seed
);
end;

architecture rtl of kf_seed_associator_core is

attribute ram_style: string;
constant widthRam: natural := widthH00 + widthm0 + widthm1 + widthd0 + widthd1;
constant widthAddr: natural := widthTrack;
type t_ram is array ( 0 to 2 ** widthAddr - 1 ) of std_logic_vector( widthRam - 1 downto 0 );
function conv( stub: t_parameterStub ) return std_logic_vector is begin return stub.H00 & stub.m0 & stub.m1 & stub.d0 & stub.d1; end function;
function conv( std: std_logic_vector ) return t_parameterStub is
  variable stub: t_parameterStub;
begin
  stub.H00 := std( widthH00 + widthm0 + widthm1 + widthd0 + widthd1 - 1 downto widthm0 + widthm1 + widthd0 + widthd1 );
  stub.m0  := std(            widthm0 + widthm1 + widthd0 + widthd1 - 1 downto           widthm1 + widthd0 + widthd1 );
  stub.m1  := std(                      widthm1 + widthd0 + widthd1 - 1 downto                     widthd0 + widthd1 );
  stub.d0  := std(                                widthd0 + widthd1 - 1 downto                               widthd1 );
  stub.d1  := std(                                          widthd1 - 1 downto                                     0 );
  return stub;
end;

-- step 1
signal validNext, validSkip: std_logic := '0';
signal seed: t_seed := nulll;
signal ram: t_ram := ( others => ( others => '0' ) );
signal read: std_logic_vector( widthRam - 1 downto 0 ) := ( others => '0' );
attribute ram_style of ram: signal is "block";

-- step 2
signal dout, comb: t_seed := nulll;


begin


-- step 2
core_comb <= comb;
core_dout <= dout;

process( clk ) is
begin
if rising_edge( clk ) then

  -- step 1

  validNext <= '0';
  validSkip <= '0';
  if core_din.meta.valid = '1' and count( core_din.meta.hitsS, 0, index ) <= kfNumSeedLayer and core_din.meta.hitsS( index ) = '1' then
    validNext <= '1';
    if count( core_din.meta.hitsT, index + 1, kfMaxSeedLayer - 1 ) + count( core_din.meta.hitsS, 0, index - 1 ) >= kfNumSeedLayer and count( core_din.meta.hitsT, index + 1, numLayers - 1 ) + count( core_din.meta.hitsS, 0, index - 1 ) >= kfMinStubs then
      validSkip <= '1';
    end if;
  end if;
  seed <= core_din;
  if core_stub.meta.valid = '1' then
    ram( uint( core_stub.meta.track ) ) <= conv( core_stub.param );
  end if;
  read <= ram( uint( core_din.meta.track ) );

  -- step 2

  dout <= seed;
  comb <= seed;
  comb.meta.valid <= '0';
  if validNext = '1' then
    dout.meta.hitsS( find( seed.meta.hitsT, index + 1, numLayers - 1, '1' ) ) <= '1';
    dout.stubs( count( seed.meta.hitsS, 0, index ) - 1 ) <= conv( read );
  end if;
  if validSkip = '1' then
    comb.meta.valid <= '1';
    comb.meta.hitsS( index ) <= '0';
    comb.meta.hitsS( find( seed.meta.hitsT, index + 1, numLayers - 1, '1' ) ) <= '1';
  end if;

end if;
end process;

end;
