for { set y 0 } { $y < 1 } { incr y }  {
    delete_pblocks quad_R${y}
}
for { set y 0 } { $y < 15 } { incr y }  {
    delete_pblocks quad_L${y}
}

delete_pblocks payload

create_pblock payload
resize_pblock payload -add SLICE_X0Y60:SLICE_X153Y899
set_property gridtypes {URAM288 RAMB36 RAMB18 DSP48E2 SLICE} [get_pblocks payload]

#add_cells_to_pblock [get_pblock payload] payload
