for { set y 0 } { $y < 10 } { incr y }  {
    delete_pblocks quad_R${y}
}
for { set y 0 } { $y < 10 } { incr y }  {
    delete_pblocks quad_L${y}
}

for { set y 0 } { $y < 9 } { incr y }  {
  set b [expr 60 * (1 + ${y})]
  set t [expr 60 * (2 + ${y}) - 1]
  create_pblock quad_R${y}
  resize_pblock quad_R${y} -add SLICE_X149Y${b}:SLICE_X168Y${t}
  set_property gridtypes {URAM288 RAMB36 RAMB18 DSP48E2 SLICE} [get_pblocks quad_R${y}]
  add_cells_to_pblock quad_R${y} datapath/rgen\[${y}\].region
  constrain_mgts ${y} [get_pblocks quad_R${y}]  1
}

delete_pblocks payload

create_pblock payload
resize_pblock payload -add SLICE_X0Y60:SLICE_X148Y599
set_property gridtypes {URAM288 RAMB36 RAMB18 DSP48E2 SLICE} [get_pblocks payload]

add_cells_to_pblock [get_pblock payload] payload

create_pblock infra
resize_pblock infra -add SLICE_X0Y0:SLICE_X168Y59
set_property gridtypes {URAM288 RAMB36 RAMB18 DSP48E2 SLICE} [get_pblocks infra]

#add_cells_to_pblock [get_pblock infra] ttc
#remove_cells_from_pblock [get_pblock infra] ttc/*osc_clock
#remove_cells_from_pblock [get_pblock infra] ttc/clocks
#remove_cells_from_pblock [get_pblock infra] ttc/gen_master_tcds2*

#add_cells_to_pblock [get_pblock infra] infra
#add_cells_to_pblock [get_pblock infra] ctrl
#add_cells_to_pblock [get_pblock infra] info
