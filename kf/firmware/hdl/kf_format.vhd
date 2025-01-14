library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.hybrid_data_types.all;
use work.kf_data_formats.all;
use work.kf_data_types.all;


entity kf_format is
port (
  clk: in std_logic;
  format_din: in t_trackDR;
  format_found: out t_found;
  format_dout: out t_metaTHH
);
end;


architecture rtl of kf_format is


-- step 1
signal full: std_logic := '0';
signal meta: t_metaTHH := nulll;
signal found: t_found := nulll;
signal counter: std_logic_vector( widthTrack - 1 downto 0 ) := ( others => '0' );

-- step 2
signal dout: t_metaTHH := nulll;

function conv( stubs: t_parameterStubsDR ) return t_parameterStubs is
  variable res: t_parameterStubs( stubs'range );
begin
  for k in stubs'range loop
    res( k ) := ( stubs( k ).r, stubs( k ).phi, stubs( k ).z, stubs( k ).dPhi, stubs( k ).dZ );
  end loop;
  return res;
end function;


begin


-- step 1
format_found <= found;

-- step 2
format_dout <= dout;

process( clk )
begin
if rising_edge( clk ) then

  -- step 1

  meta <= nulll;
  found <= nulll;
  if format_din.meta.valid = '1' and full = '0' and count( format_din.meta.hits, 0, kfMaxSeedLayer - 1 ) >= kfNumSeedLayer and count( format_din.meta.hits ) >= kfMinStubs then
    meta <= ( '0', '1', counter, format_din.meta.hits, ( find( format_din.meta.hits, 0, numLayers - 1, '1' ) => '1', others => '0' ) );
    found <= ( ( '0', '1', counter, format_din.meta.hits ), format_din.track, conv( format_din.stubs ) );
    counter <= counter + 1;
    if sint( counter + 1 ) = -1 then
      full <= '1';
    end if;
  end if;

  if format_din.meta.reset = '1' then
    meta.reset <= '1';
    found.meta.reset <= '1';
    full <= '0';
    counter <= ( others => '0' );
  end if;

  -- step 2

  dout <= meta;

end if;
end process;


end;