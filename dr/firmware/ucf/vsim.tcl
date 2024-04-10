set_property SOURCE_SET sources_1 [get_filesets sim_1]
add_files -fileset sim_1 -norecurse /users/sb19423/l1tk/l1tf-work/proj/dr_update_vivado/in.txt
add_files -fileset sim_1 -norecurse /users/sb19423/l1tk/l1tf-work/proj/dr_update_vivado/out.txt
add_files -fileset constrs_1 -norecurse constraints.xdc

set_property -name {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} -value {-mode out_of_context} -objects [get_runs synth_1]
set_property STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY none [get_runs synth_1] 
set_property STEPS.SYNTH_DESIGN.ARGS.KEEP_EQUIVALENT_REGISTERS true [get_runs synth_1]
set_top emp_payload
update_compile_order -fileset sources_1