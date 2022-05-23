library ieee;
use ieee.std_logic_1164.all;

use work.emp_data_types.all;
use work.emp_project_decl.all;

use work.emp_device_decl.all;


-- defines link_map_d and link_map_q
use work.pkg_link_map.all;
use work.hybrid_config.all;

-- Map from physical links to logical links using link_map_d and link_map_q
-- for optimal placement and convenient indexing
-- d and q are connected to the framework d and q
-- d_mapped and q_mapped are for internal use to/from algorithms
entity link_map is
	port(
		d        : in  ldata(4 * N_REGION - 1 downto 0);                       -- unmapped data in
        d_mapped : out ldata( numInputLinks - 1 downto 0);  -- mapped data in
        q_mapped : in  ldata( numLinksTFP - 1 downto 0); -- mapped data for output
        q        : out ldata(4 * N_REGION - 1 downto 0)                        -- unmapped data for output
	);
end link_map;

architecture rtl of link_map is

begin

    GenDMap:
    for i in d_mapped'range generate
        d_mapped(i) <= d(link_map_d(i));
    end generate;

    GenQMap:
    for i in q_mapped'range generate
        q(link_map_q(i)) <= q_mapped(i);
    end generate;    

end rtl;
