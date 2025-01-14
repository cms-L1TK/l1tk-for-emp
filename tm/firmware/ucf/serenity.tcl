
#add_cells_to_pblock [get_pblock payload] payload
delete_pblocks [get_pblocks *]

set_min_delay 0.000 -from [get_clocks clk_pseudo_aux_0] -to [get_clocks clk_pseudo_payload]
set_max_delay 2.778 -from [get_clocks clk_pseudo_aux_0] -to [get_clocks clk_pseudo_payload]

set_min_delay 0.000 -from [get_clocks clk_pseudo_payload] -to [get_clocks clk_pseudo_aux_0]
set_max_delay 2.778 -from [get_clocks clk_pseudo_payload] -to [get_clocks clk_pseudo_aux_0]
