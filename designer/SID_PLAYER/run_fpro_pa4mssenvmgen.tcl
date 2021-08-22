set_device \
    -fam SmartFusion2 \
    -die PA4M1000_N \
    -pkg vf400
set_input_cfg \
	-path {D:/Clients/AlfheimSystems/SID_PLAYER/FPGA/SID_PLAYER/component/work/SID_PLAYER_sb_MSS/ENVM.cfg}
set_output_efc \
    -path {D:\Clients\AlfheimSystems\SID_PLAYER\FPGA\SID_PLAYER\designer\SID_PLAYER\SID_PLAYER.efc}
set_proj_dir \
    -path {D:\Clients\AlfheimSystems\SID_PLAYER\FPGA\SID_PLAYER}
set_is_relative_path \
    -value {FALSE}
set_root_path_dir \
    -path {}
gen_prg -use_init false
