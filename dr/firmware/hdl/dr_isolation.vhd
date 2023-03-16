library ieee;
use ieee.std_logic_1164.all;
use work.emp_device_decl.all;
use work.emp_data_types.all;
use work.emp_ttc_decl.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;

entity dr_isolation_in is
port (
  clk: in std_logic;
  in_din: in ldata( 4 * N_REGION - 1 downto 0 );
  in_dout: out t_tracksDRin( numNodesDR - 1 downto 0 )
);
end;

architecture rtl of dr_isolation_in is

component dr_isolation_in_node
port (
  clk: in std_logic;
  node_din: in ldata( 1 + numLayers - 1 downto 0 );
  node_dout: out t_trackDRin
);
end component;

begin

g: for k in 0 to numNodesDR - 1 generate

signal node_din: ldata( 1 + numLayers - 1 downto 0 ) := ( others => nulll );
signal node_dout: t_trackDRin := nulll;

begin

node_din <= in_din( ( k + 1 ) * ( 1 + numLayers ) - 1 downto k * ( 1 + numLayers ) );
in_dout( k ) <= node_dout;

c: dr_isolation_in_node port map ( clk, node_din, node_dout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.emp_data_types.all;
use work.hybrid_data_types.all;
use work.hybrid_data_formats.all;

entity dr_isolation_in_node is
port (
  clk: in std_logic;
  node_din: in ldata( 1 + numLayers - 1 downto 0 );
  node_dout: out t_trackDRin
);
end;

architecture rtl of dr_isolation_in_node is

-- step 1
signal din: ldata( 1 + numLayers - 1 downto 0 ) := nulll;

-- step 2
signal dout: t_trackDRin := nulll;

function conv( l: ldata( 1 + numLayers - 1 downto 0 ) ) return t_trackDRin is
  variable t: t_trackDRin := nulll;
  reset: std_logic;
  valid: std_logic;
  inv2R: std_logic_vector( widthDRinv2R - 1 downto 0 );
  phiT : std_logic_vector( widthDRphiT  - 1 downto 0 );
  zT   : std_logic_vector( widthDRzT    - 1 downto 0 );
  cot  : std_logic_vector( widthDRcot   - 1 downto 0 );
  stubs: t_stubsDRin( numLayers - 1 downto 0 );
begin
  t.valid := l( 0 ).data( widthDRinv2R + widthDRphiT + widthDRzT + widthDRcot );
  t.inv2R := l( 0 ).data( widthDRinv2R + widthDRphiT + widthDRzT + widthDRcot - 1 downto widthDRphiT + widthDRzT + widthDRcot );
  t.phiT  := l( 0 ).data(                widthDRphiT + widthDRzT + widthDRcot - 1 downto               widthDRzT + widthDRcot );
  t.zT    := l( 0 ).data(                              widthDRzT + widthDRcot - 1 downto                           widthDRcot );
  t.cot   := l( 0 ).data(                                          widthDRcot - 1 downto                                    0 );
  for k in 0 to numLayers - 1 loop
    t.stubs( k ).valid   = l( k + 1 ).data( 1 + widthDRlayerId + widthDRstubId + widthDRr + widthDRphi + widthDRz );
    t.stubs( k ).tilt    = l( k + 1 ).data(     widthDRlayerId + widthDRstubId + widthDRr + widthDRphi + widthDRz );
    t.stubs( k ).layerId = l( k + 1 ).data(     widthDRlayerId + widthDRstubId + widthDRr + widthDRphi + widthDRz - 1 downto widthDRstubId + widthDRr + widthDRphi + widthDRz );
    t.stubs( k ).stubId  = l( k + 1 ).data(                      widthDRstubId + widthDRr + widthDRphi + widthDRz - 1 downto                 widthDRr + widthDRphi + widthDRz );
    t.stubs( k ).r       = l( k + 1 ).data(                                      widthDRr + widthDRphi + widthDRz - 1 downto                            widthDRphi + widthDRz );
    t.stubs( k ).phi     = l( k + 1 ).data(                                                 widthDRphi + widthDRz - 1 downto                                         widthDRz );
    t.stubs( k ).z       = l( k + 1 ).data(                                                              widthDRz - 1 downto                                                0 );
  end loop;
  return t;
end function;

begin

-- step 2
node_dout <= dout;

process( clk ) is
begin
if rising_edge( clk ) then

  -- step 1

  din <= node_din;

  -- step 2

  dout <= nulll;
  if din.valid = '1' then
    dout <= conv( din.data );
  elsif node_din.valid = '1' then
    dout.reset <= '1';
  end if;

end if;
end process;

end;


library ieee;
use ieee.std_logic_1164.all;

use work.emp_device_decl.all;
use work.emp_data_types.all;

use work.hybrid_config.all;
use work.hybrid_data_types.all;

entity dr_isolation_out is
port (
  clk: in std_logic;
  out_packet: in t_packets( numNodesDR * ( 1 + numLayers ) - 1 downto 0 );
  out_din: in t_tracksDR( numNodesDR - 1 downto 0 );
  out_dout: out ldata( 4 * N_REGION - 1 downto 0 )
);
end;

architecture rtl of dr_isolation_out is

signal dout: ldata( 4 * N_REGION - 1 downto 0 ) := ( others => nulll );

component dr_isolation_out_node
port (
  clk: in std_logic;
  node_packet: in t_packets( 1 + numLayers - 1 downto 0 );
  node_din: in t_trackDR;
  node_dout: out ldata( 1 + numLayers - 1 downto 0 )
);
end component;

begin

out_dout <= dout;

g: for k in 0 to numNodesDR - 1 generate

signal node_packet: t_packets( 1 + numLayers - 1 downto 0 ) := ( others => ( others => '0' ) );
signal node_din: t_trackDR := nulll;
signal node_dout: ldata( 1 + numLayers - 1 downto 0 ) := ( others => nulll );

begin

node_packet <= out_packet( ( k + 1 ) * ( 1 + numLayers ) - 1 downto k * ( 1 + numLayers ) );
node_din <= out_din( k );
dout( ( k + 1 ) * ( 1 + numLayers ) - 1 downto k * ( 1 + numLayers ) ) <= node_dout;

c: dr_isolation_out_node port map ( clk, node_packet, node_din, node_dout );

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;

use work.emp_data_types.all;
use work.emp_project_decl.all;

use work.hybrid_data_types.all;
use work.hybrid_data_formats.all;

entity dr_isolation_out_node is
port (
  clk: in std_logic;
  node_packet: in t_packets( 1 + numLayers - 1 downto 0 );
  node_din: in t_trackDR;
  node_dout: out ldata( 1 + numLayers - 1 downto 0 )
);
end;

architecture rtl of dr_isolation_out_track is

constant widthTrack: natural := 1 + widthDRinv2R + widthDRphiT + widthDRzT + widthDRcot;
constant widthStub: natural := 1 + 1 + widthDRlayerId + widthDRstubId + widthDRr + widthDRphi + widthDRz;
type t_sr is array ( PAYLOAD_LATENCY - 1 downto 0 ) of t_packets( 0 to numLayers );
-- sr
signal sr: t_sr := ( others => ( others => ( others => '0' ) ) );

-- step 1
signal din:  t_trackDR := nulll;
signal dout: ldata( 1 + numLayers - 1 downto 0 ) := ( others => nulll );

function conv( t: t_trackDR ) return std_logic_vector is
begin
  return t.valid & t.inv2R & t.phiT & t.zT & t.cot;
end function;

function conv( s: t_stubDR ) return std_logic_vector is
begin
  return s.valid & s.tilt & s.layerId & s.stubId & s.r & s.phi & z;
end function;

begin

-- step 1
din <= track_din;
track_dout <= dout;

process( clk ) is
begin
if rising_edge( clk ) then

  -- sr

  sr <= sr( sr'high - 1 downto 0 ) & node_packet;

  -- step 1

  for k in 0 to numLayers loop
    dout( k ).start_of_orbit <= sr( sr'high )( k ).start_of_orbit;
    dout( k ).valid <= '0';
    dout( k ).data <= ( others => '0' );
    if sr( sr'high )( k ).valid = '1' then
      dout( k ).valid <= '1';
      if k = 0 then
        dout( k ).data( widthTrack - 1 downto 0  ) <= conv( din );
      else
        dout( k ).data( widthStub - 1 downto 0  ) <= conv( din.stubs( k - 1 ) );
      end if;
    end if;
  end loop;

end if;
end process;

end;
