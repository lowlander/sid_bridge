open_project -project {D:\Clients\AlfheimSystems\SID_PLAYER\FPGA\SID_PLAYER\designer\SID_PLAYER\SID_PLAYER_fp\SID_PLAYER.pro}\
         -connect_programmers {FALSE}
load_programming_data \
    -name {M2S010} \
    -fpga {D:\Clients\AlfheimSystems\SID_PLAYER\FPGA\SID_PLAYER\designer\SID_PLAYER\SID_PLAYER.map} \
    -header {D:\Clients\AlfheimSystems\SID_PLAYER\FPGA\SID_PLAYER\designer\SID_PLAYER\SID_PLAYER.hdr} \
    -envm {D:\Clients\AlfheimSystems\SID_PLAYER\FPGA\SID_PLAYER\designer\SID_PLAYER\SID_PLAYER.efc} \
    -spm {D:\Clients\AlfheimSystems\SID_PLAYER\FPGA\SID_PLAYER\designer\SID_PLAYER\SID_PLAYER.spm} \
    -dca {D:\Clients\AlfheimSystems\SID_PLAYER\FPGA\SID_PLAYER\designer\SID_PLAYER\SID_PLAYER.dca}
export_single_ppd \
    -name {M2S010} \
    -file {D:\Clients\AlfheimSystems\SID_PLAYER\FPGA\SID_PLAYER\designer\SID_PLAYER\SID_PLAYER.ppd}

save_project
close_project
