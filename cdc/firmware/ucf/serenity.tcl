
add_cells_to_pblock [get_pblock payload] payload

set_multicycle_path 2 -setup -from [get_clocks clks_aux_u_0] -to [get_clocks clk_payload_extern0]
set_multicycle_path 1 -hold -end -from [get_clocks clks_aux_u_0] -to [get_clocks clk_payload_extern0]
