set_property SOURCE_SET sources_1 [get_filesets sim_1]
add_files -fileset sim_1 -norecurse ../emData/in.txt
add_files -fileset sim_1 -norecurse ../emData/out.txt
