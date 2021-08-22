# Microsemi Corp.
# Date: 2021-Aug-22 16:30:19
# This file was generated based on the following SDC source files:
#   D:/Clients/AlfheimSystems/SID_PLAYER/FPGA/SID_PLAYER/component/work/SID_PLAYER_sb/CCC_0/SID_PLAYER_sb_CCC_0_FCCC.sdc
#   D:/Microsemi/Libero_SoC_v2021.2/Designer/data/aPA4M/cores/constraints/coreresetp.sdc
#   D:/Clients/AlfheimSystems/SID_PLAYER/FPGA/SID_PLAYER/component/work/SID_PLAYER_sb/FABOSC_0/SID_PLAYER_sb_FABOSC_0_OSC.sdc
#   D:/Clients/AlfheimSystems/SID_PLAYER/FPGA/SID_PLAYER/component/work/SID_PLAYER_sb_MSS/SID_PLAYER_sb_MSS.sdc
#   D:/Microsemi/Libero_SoC_v2021.2/Designer/data/aPA4M/cores/constraints/sysreset.sdc
#

create_clock -name {SID_PLAYER_sb_0/FABOSC_0/I_RCOSC_25_50MHZ/CLKOUT} -period 20 [ get_pins { SID_PLAYER_sb_0/FABOSC_0/I_RCOSC_25_50MHZ/CLKOUT } ]
create_generated_clock -name {SID_PLAYER_sb_0/CCC_0/GL0} -multiply_by 71 -divide_by 50 -source [ get_pins { SID_PLAYER_sb_0/CCC_0/CCC_INST/RCOSC_25_50MHZ } ] -phase 0 [ get_pins { SID_PLAYER_sb_0/CCC_0/CCC_INST/GL0 } ]
set_false_path -ignore_errors -through [ get_nets { SID_PLAYER_sb_0/CORERESETP_0/ddr_settled SID_PLAYER_sb_0/CORERESETP_0/count_ddr_enable SID_PLAYER_sb_0/CORERESETP_0/release_sdif*_core SID_PLAYER_sb_0/CORERESETP_0/count_sdif*_enable } ]
set_false_path -ignore_errors -from [ get_cells { SID_PLAYER_sb_0/CORERESETP_0/MSS_HPMS_READY_int } ] -to [ get_cells { SID_PLAYER_sb_0/CORERESETP_0/sm0_areset_n_rcosc SID_PLAYER_sb_0/CORERESETP_0/sm0_areset_n_rcosc_q1 } ]
set_false_path -ignore_errors -from [ get_cells { SID_PLAYER_sb_0/CORERESETP_0/MSS_HPMS_READY_int SID_PLAYER_sb_0/CORERESETP_0/SDIF*_PERST_N_re } ] -to [ get_cells { SID_PLAYER_sb_0/CORERESETP_0/sdif*_areset_n_rcosc* } ]
set_false_path -ignore_errors -through [ get_nets { SID_PLAYER_sb_0/CORERESETP_0/CONFIG1_DONE SID_PLAYER_sb_0/CORERESETP_0/CONFIG2_DONE SID_PLAYER_sb_0/CORERESETP_0/SDIF*_PERST_N SID_PLAYER_sb_0/CORERESETP_0/SDIF*_PSEL SID_PLAYER_sb_0/CORERESETP_0/SDIF*_PWRITE SID_PLAYER_sb_0/CORERESETP_0/SDIF*_PRDATA[*] SID_PLAYER_sb_0/CORERESETP_0/SOFT_EXT_RESET_OUT SID_PLAYER_sb_0/CORERESETP_0/SOFT_RESET_F2M SID_PLAYER_sb_0/CORERESETP_0/SOFT_M3_RESET SID_PLAYER_sb_0/CORERESETP_0/SOFT_MDDR_DDR_AXI_S_CORE_RESET SID_PLAYER_sb_0/CORERESETP_0/SOFT_FDDR_CORE_RESET SID_PLAYER_sb_0/CORERESETP_0/SOFT_SDIF*_PHY_RESET SID_PLAYER_sb_0/CORERESETP_0/SOFT_SDIF*_CORE_RESET SID_PLAYER_sb_0/CORERESETP_0/SOFT_SDIF0_0_CORE_RESET SID_PLAYER_sb_0/CORERESETP_0/SOFT_SDIF0_1_CORE_RESET } ]
set_false_path -ignore_errors -through [ get_pins { SID_PLAYER_sb_0/SID_PLAYER_sb_MSS_0/MSS_ADLIB_INST/CONFIG_PRESET_N } ]
set_false_path -ignore_errors -through [ get_pins { SID_PLAYER_sb_0/SYSRESET_POR/POWER_ON_RESET_N } ]
