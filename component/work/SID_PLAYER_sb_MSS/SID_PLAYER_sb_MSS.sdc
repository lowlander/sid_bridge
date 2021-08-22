set_component SID_PLAYER_sb_MSS
# Microsemi Corp.
# Date: 2021-Aug-21 21:31:34
#

create_clock -period 28.169 [ get_pins { MSS_ADLIB_INST/CLK_CONFIG_APB } ]
set_false_path -ignore_errors -through [ get_pins { MSS_ADLIB_INST/CONFIG_PRESET_N } ]
