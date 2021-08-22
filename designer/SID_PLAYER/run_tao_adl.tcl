set_device -family {SmartFusion2} -die {M2S010} -speed {STD}
read_adl {D:\Clients\AlfheimSystems\SID_PLAYER\FPGA\SID_PLAYER\designer\SID_PLAYER\SID_PLAYER.adl}
read_afl {D:\Clients\AlfheimSystems\SID_PLAYER\FPGA\SID_PLAYER\designer\SID_PLAYER\SID_PLAYER.afl}
map_netlist
read_sdc {D:\Clients\AlfheimSystems\SID_PLAYER\FPGA\SID_PLAYER\constraint\SID_PLAYER_derived_constraints.sdc}
check_constraints {D:\Clients\AlfheimSystems\SID_PLAYER\FPGA\SID_PLAYER\constraint\placer_sdc_errors.log}
write_sdc -mode layout {D:\Clients\AlfheimSystems\SID_PLAYER\FPGA\SID_PLAYER\designer\SID_PLAYER\place_route.sdc}
