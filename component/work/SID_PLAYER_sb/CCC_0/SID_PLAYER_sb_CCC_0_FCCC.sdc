set_component SID_PLAYER_sb_CCC_0_FCCC
# Microsemi Corp.
# Date: 2021-Aug-21 21:31:37
#

create_clock -period 20 [ get_pins { CCC_INST/RCOSC_25_50MHZ } ]
create_generated_clock -multiply_by 71 -divide_by 50 -source [ get_pins { CCC_INST/RCOSC_25_50MHZ } ] -phase 0 [ get_pins { CCC_INST/GL0 } ]
