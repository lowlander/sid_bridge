new_project \
         -name {SID_PLAYER} \
         -location {D:\Clients\AlfheimSystems\SID_PLAYER\FPGA\SID_PLAYER\designer\SID_PLAYER\SID_PLAYER_fp} \
         -mode {chain} \
         -connect_programmers {FALSE}
add_actel_device \
         -device {M2S010} \
         -name {M2S010}
enable_device \
         -name {M2S010} \
         -enable {TRUE}
save_project
close_project
