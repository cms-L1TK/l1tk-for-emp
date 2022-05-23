library ieee;
use ieee.numeric_std.all;
use work.hybrid_config.all;

package pkg_link_map is

    -- Map links to regions 
    -- Using the map of https://gitlab.cern.ch/p2-xware/firmware/emp-fwk/-/blob/v0.6.7/boards/serenity/dc_vu9p/regions-a2577.md

    type int_vector is array(natural range <>) of integer;

    -- Input 18 links from the LHS of each of three SLRs
    constant link_map_d : int_vector(0 to numInputLinks - 1) := (0,1,2,3,4,5,6,7,
                                                                    8,9,10,11,12,13,14,15,
                                                                    24,25,26,27,28,29,30,31,
                                                                    32,33,34,35,36,37,38,39,
                                                                    40,41,42,43,44,45,46,47,
                                                                    48,49,50,51,52,53,54,55,
                                                                    68,69,70,71);

    -- Output 10 links on the RHS each of three SLRs     
                                                                             
    constant link_map_q : int_vector(0 to numLinksTFP - 1) := (56,57);

end package pkg_link_map;
