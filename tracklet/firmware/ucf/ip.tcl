set script_path [ file dirname [ file normalize [ info script ] ] ]
set_property ip_repo_paths  ${script_path}/../cgn/ [current_project]
update_ip_catalog  
