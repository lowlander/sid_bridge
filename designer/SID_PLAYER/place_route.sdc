# Microsemi Corp.
# Date: 2021-Aug-22 16:31:32
# This file was generated based on the following SDC source files:
#   D:/Clients/AlfheimSystems/SID_PLAYER/FPGA/SID_PLAYER/constraint/SID_PLAYER_derived_constraints.sdc
#

create_clock -name {SID_PLAYER_sb_0/FABOSC_0/I_RCOSC_25_50MHZ/CLKOUT} -period 20 [ get_pins { SID_PLAYER_sb_0/FABOSC_0/I_RCOSC_25_50MHZ/CLKOUT } ]
create_generated_clock -name {SID_PLAYER_sb_0/CCC_0/GL0} -multiply_by 71 -divide_by 50 -source [ get_pins { SID_PLAYER_sb_0/CCC_0/CCC_INST/INST_CCC_IP/RCOSC_25_50MHZ } ] -phase 0 [ get_pins { SID_PLAYER_sb_0/CCC_0/CCC_INST/INST_CCC_IP/GL0 } ]
set_false_path -through [ get_pins { SID_PLAYER_sb_0/SID_PLAYER_sb_MSS_0/MSS_ADLIB_INST/INST_MSS_010_IP/CONFIG_PRESET_N } ]
set_false_path -through [ get_pins { SID_PLAYER_sb_0/SYSRESET_POR/INST_SYSRESET_FF_IP/POWER_ON_RESET_N } ]
