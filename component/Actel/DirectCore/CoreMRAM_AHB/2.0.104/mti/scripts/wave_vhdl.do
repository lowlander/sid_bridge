onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /testbench/U_COREMRAM_AHB/HCLK
add wave -noupdate -format Logic /testbench/U_COREMRAM_AHB/HRESETN
add wave -noupdate -format Logic /testbench/U_COREMRAM_AHB/HSEL
add wave -noupdate -format Logic /testbench/U_COREMRAM_AHB/HREADYIN
add wave -noupdate -format Literal -radix hexadecimal /testbench/U_COREMRAM_AHB/HADDR
add wave -noupdate -format Literal /testbench/U_COREMRAM_AHB/HTRANS
add wave -noupdate -format Literal /testbench/U_COREMRAM_AHB/HSIZE
add wave -noupdate -format Logic /testbench/U_COREMRAM_AHB/HWRITE
add wave -noupdate -format Literal -radix hexadecimal /testbench/U_COREMRAM_AHB/HWDATA
add wave -noupdate -format Literal /testbench/U_COREMRAM_AHB/HRESP
add wave -noupdate -format Literal -radix hexadecimal /testbench/U_COREMRAM_AHB/HRDATA
add wave -noupdate -format Literal -radix hexadecimal /testbench/U_COREMRAM_AHB/HBURST
add wave -noupdate -format Logic /testbench/U_COREMRAM_AHB/HREADY
add wave -noupdate -format Logic /testbench/U_COREMRAM_AHB/CORE_CLK
add wave -noupdate -format Logic /testbench/U_COREMRAM_AHB/CORECLK_RESETN
add wave -noupdate -format Logic /testbench/U_COREMRAM_AHB/MRAMCLK_OUT
add wave -noupdate -format Logic /testbench/U_COREMRAM_AHB/ECC_ERROR_SB
add wave -noupdate -format Logic /testbench/U_COREMRAM_AHB/ECC_ERROR_DB
add wave -noupdate -format Literal -radix hexadecimal /testbench/U_COREMRAM_AHB/A
add wave -noupdate -format Literal /testbench/U_COREMRAM_AHB/CEB
add wave -noupdate -format Literal -radix binary /testbench/U_COREMRAM_AHB/WE
add wave -noupdate -format Literal -radix binary /testbench/U_COREMRAM_AHB/OE
add wave -noupdate -format Literal -radix binary /testbench/U_COREMRAM_AHB/X8
add wave -noupdate -format Literal -radix hexadecimal /testbench/U_COREMRAM_AHB/DQ
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {106267275 ps} 0} {{Cursor 2} {105352317 ps} 0}
configure wave -namecolwidth 288
configure wave -valuecolwidth 102
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
configure wave -timelineunits ps
update
WaveRestoreZoom {105278442 ps} {105372188 ps}

# this is needed for VHDL sim
when {STOPCLK == 1} {stop}
