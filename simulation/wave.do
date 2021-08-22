onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /sid_saber_tb/NSYSRESET
add wave -noupdate /sid_saber_tb/SID_SABER_0/LED_STRIP_CTRL_0/HCLK
add wave -noupdate /sid_saber_tb/SID_SABER_0/LED_STRIP_CTRL_0/HRESETN
add wave -noupdate /sid_saber_tb/SID_SABER_0/LED_STRIP_CTRL_0/HADDR
add wave -noupdate /sid_saber_tb/SID_SABER_0/LED_STRIP_CTRL_0/HBURST
add wave -noupdate /sid_saber_tb/SID_SABER_0/LED_STRIP_CTRL_0/HREADYIN
add wave -noupdate /sid_saber_tb/SID_SABER_0/LED_STRIP_CTRL_0/HSEL
add wave -noupdate /sid_saber_tb/SID_SABER_0/LED_STRIP_CTRL_0/HSIZE
add wave -noupdate /sid_saber_tb/SID_SABER_0/LED_STRIP_CTRL_0/HTRANS
add wave -noupdate /sid_saber_tb/SID_SABER_0/LED_STRIP_CTRL_0/HWDATA
add wave -noupdate /sid_saber_tb/SID_SABER_0/LED_STRIP_CTRL_0/HWRITE
add wave -noupdate /sid_saber_tb/SID_SABER_0/LED_STRIP_CTRL_0/HPROT
add wave -noupdate /sid_saber_tb/SID_SABER_0/LED_STRIP_CTRL_0/HMASTLOCK
add wave -noupdate /sid_saber_tb/SID_SABER_0/LED_STRIP_CTRL_0/HRDATA
add wave -noupdate /sid_saber_tb/SID_SABER_0/LED_STRIP_CTRL_0/HREADYOUT
add wave -noupdate /sid_saber_tb/SID_SABER_0/LED_STRIP_CTRL_0/HRESP
add wave -noupdate /sid_saber_tb/SID_SABER_0/LED_STRIP_CTRL_0/DPRAM_A_WE_O
add wave -noupdate /sid_saber_tb/SID_SABER_0/LED_STRIP_CTRL_0/DPRAM_A_ADDR_O
add wave -noupdate /sid_saber_tb/SID_SABER_0/LED_STRIP_CTRL_0/DPRAM_A_DATA_O
add wave -noupdate /sid_saber_tb/SID_SABER_0/LED_STRIP_CTRL_0/DPRAM_A_DATA_I
add wave -noupdate /sid_saber_tb/SID_SABER_0/LED_STRIP_CTRL_0/DPRAM_B_WE_O
add wave -noupdate /sid_saber_tb/SID_SABER_0/LED_STRIP_CTRL_0/DPRAM_B_ADDR_O
add wave -noupdate /sid_saber_tb/SID_SABER_0/LED_STRIP_CTRL_0/DPRAM_B_DATA_O
add wave -noupdate /sid_saber_tb/SID_SABER_0/LED_STRIP_CTRL_0/DPRAM_B_DATA_I
add wave -noupdate /sid_saber_tb/SID_SABER_0/LED_STRIP_CTRL_0/NEOPIXEL_O
add wave -noupdate -expand /sid_saber_tb/SID_SABER_0/LED_STRIP_CTRL_0/reg
add wave -noupdate /sid_saber_tb/SID_SABER_0/LED_STRIP_CTRL_0/next_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {70241136760 fs} 0} {{Cursor 2} {71501700141 fs} 0}
quietly wave cursor active 2
configure wave -namecolwidth 382
configure wave -valuecolwidth 206
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {68388162788 fs} {72206786788 fs}
