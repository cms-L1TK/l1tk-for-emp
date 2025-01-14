set_property target_language VHDL [current_project]
set_property simulator_language VHDL [current_project]
set_property -name {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} -value {-mode out_of_context} -objects [get_runs synth_1]

#set_property used_in_synthesis false [get_files testbench_top.vhd]
#set_property used_in_synthesis false [get_files EMPCaptureFileReader.vhd]
#set_property used_in_synthesis false [get_files EMPCaptureFileWriter.vhd]

#set_property top emp_payload [current_fileset]

set script_path [ file dirname [ file normalize [ info script ] ] ]
set source_path [join [lreplace [split $script_path/ "\/"] end-1 end-1] "\/"]vsim
set_property SOURCE_SET sources_1 [get_filesets sim_1]
import_files -fileset sim_1 -norecurse $source_path/in.txt
import_files -fileset sim_1 -norecurse $source_path/out.txt
import_files -fileset sim_1 -norecurse $source_path/top_behav.wcfg
import_files -fileset constrs_1 -norecurse $source_path/top.xdc
