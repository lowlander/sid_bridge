quietly set ACTELLIBNAME SmartFusion2
quietly set PROJECT_DIR "D:/Clients/AlfheimSystems/SID_PLAYER/FPGA/SID_PLAYER"
source "${PROJECT_DIR}/simulation/bfmtovec_compile.tcl";
source "${PROJECT_DIR}/simulation/CM3_compile_bfm.tcl";


if {[file exists presynth/_info]} {
   echo "INFO: Simulation library presynth already exists"
} else {
   file delete -force presynth 
   vlib presynth
}
vmap presynth presynth
vmap SmartFusion2 "D:/Microsemi/Libero_SoC_v2021.2/Designer/lib/modelsimpro/precompiled/vlog/SmartFusion2"
vmap COREAHBLITE_LIB "../component/Actel/DirectCore/CoreAHBLite/5.2.100/mti/user_vhdl/COREAHBLITE_LIB"
vcom -work COREAHBLITE_LIB -force_refresh
vlog -work COREAHBLITE_LIB -force_refresh
if {[file exists CORESDR_AXI_LIB/_info]} {
   echo "INFO: Simulation library CORESDR_AXI_LIB already exists"
} else {
   file delete -force CORESDR_AXI_LIB 
   vlib CORESDR_AXI_LIB
}
vmap CORESDR_AXI_LIB "CORESDR_AXI_LIB"
if {[file exists COREAHBLSRAM_OBF_LIB/_info]} {
   echo "INFO: Simulation library COREAHBLSRAM_OBF_LIB already exists"
} else {
   file delete -force COREAHBLSRAM_OBF_LIB 
   vlib COREAHBLSRAM_OBF_LIB
}
vmap COREAHBLSRAM_OBF_LIB "COREAHBLSRAM_OBF_LIB"

vlog -sv -work presynth "${PROJECT_DIR}/component/Actel/DirectCore/CORESDR_AHB/4.4.107/rtl/vlog/core/RAM_BLOCK_ECC.v"
vlog -sv -work presynth "${PROJECT_DIR}/component/Actel/DirectCore/CORESDR_AHB/4.4.107/rtl/vlog/core/RAM_BLOCK.v"
vlog -sv -work presynth "${PROJECT_DIR}/component/Actel/DirectCore/CORESDR_AHB/4.4.107/rtl/vlog/core/Bin2Gray.v"
vlog -sv -work presynth "${PROJECT_DIR}/component/Actel/DirectCore/CORESDR_AHB/4.4.107/rtl/vlog/core/CDC_grayCodeCounter.v"
vlog -sv -work presynth "${PROJECT_DIR}/component/Actel/DirectCore/CORESDR_AHB/4.4.107/rtl/vlog/core/CDC_rdCtrl.v"
vlog -sv -work presynth "${PROJECT_DIR}/component/Actel/DirectCore/CORESDR_AHB/4.4.107/rtl/vlog/core/CDC_wrCtrl.v"
vlog -sv -work presynth "${PROJECT_DIR}/component/Actel/DirectCore/CORESDR_AHB/4.4.107/rtl/vlog/core/CDC_FIFO.v"
vlog -sv -work presynth "${PROJECT_DIR}/component/Actel/DirectCore/CORESDR_AHB/4.4.107/rtl/vlog/core/pulse_cdc_sync.v"
vlog -sv -work presynth "${PROJECT_DIR}/component/Actel/DirectCore/CORESDR_AHB/4.4.107/rtl/vlog/core/pulse_cdc.v"
vlog -sv -work presynth "${PROJECT_DIR}/component/Actel/DirectCore/CORESDR_AHB/4.4.107/rtl/vlog/core/pulse_gen_sync.v"
vlog -sv -work presynth "${PROJECT_DIR}/component/Actel/DirectCore/CORESDR_AHB/4.4.107/rtl/vlog/core/pulse_gen.v"
vlog -sv -work presynth "${PROJECT_DIR}/component/Actel/DirectCore/CORESDR_AHB/4.4.107/rtl/vlog/core/CoreSync_pulse_cdc.v"
vlog -sv -work presynth "${PROJECT_DIR}/component/Actel/DirectCore/CORESDR_AHB/4.4.107/rtl/vlog/core/coresdrahb_openbank.v"
vlog -sv -work presynth "${PROJECT_DIR}/component/Actel/DirectCore/CORESDR_AHB/4.4.107/rtl/vlog/core/coresdrahb_fastsdram.v"
vlog -sv -work presynth "${PROJECT_DIR}/component/Actel/DirectCore/CORESDR_AHB/4.4.107/rtl/vlog/core/coresdrahb_fastinit.v"
vlog -sv -work presynth "${PROJECT_DIR}/component/Actel/DirectCore/CORESDR_AHB/4.4.107/rtl/vlog/core/coresdrahb_coresdr.v"
vlog -sv -work presynth "${PROJECT_DIR}/component/Actel/DirectCore/CORESDR_AHB/4.4.107/rtl/vlog/core/coresdrahb_coresdr_ahb_burst_32dq.v"
vlog -sv -work presynth "${PROJECT_DIR}/component/Actel/DirectCore/CORESDR_AHB/4.4.107/rtl/vlog/core/coresdrahb_coresdr_ahb_single.v"
vlog -sv -work presynth "${PROJECT_DIR}/component/Actel/DirectCore/CORESDR_AHB/4.4.107/rtl/vlog/core/coresdrahb_coresdr_ahb_burst_16dq.v"
vlog -sv -work presynth "${PROJECT_DIR}/component/work/CORESDR_AHB_C1/CORESDR_AHB_C1_0/rtl/vlog/core/coresdrahb_coresdr_ahb.v"
vlog -sv -work presynth "${PROJECT_DIR}/component/work/CORESDR_AHB_C1/CORESDR_AHB_C1.v"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/hdl/SID_BRIDGE.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/component/work/SID_PLAYER_sb/CCC_0/SID_PLAYER_sb_CCC_0_FCCC.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/component/work/SID_PLAYER_sb/FABOSC_0/SID_PLAYER_sb_FABOSC_0_OSC.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/component/work/SID_PLAYER_sb_MSS/SID_PLAYER_sb_MSS.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/component/Actel/DirectCore/CoreResetP/7.1.100/rtl/vhdl/core/coreresetp_pcie_hotreset.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/component/Actel/DirectCore/CoreResetP/7.1.100/rtl/vhdl/core/coreresetp.vhd"
vcom -2008 -explicit  -work COREAHBLITE_LIB "${PROJECT_DIR}/component/Actel/DirectCore/CoreAHBLite/5.2.100/rtl/vhdl/core/coreahblite_slavearbiter.vhd"
vcom -2008 -explicit  -work COREAHBLITE_LIB "${PROJECT_DIR}/component/Actel/DirectCore/CoreAHBLite/5.2.100/rtl/vhdl/core/coreahblite_slavestage.vhd"
vcom -2008 -explicit  -work COREAHBLITE_LIB "${PROJECT_DIR}/component/Actel/DirectCore/CoreAHBLite/5.2.100/rtl/vhdl/core/coreahblite_defaultslavesm.vhd"
vcom -2008 -explicit  -work COREAHBLITE_LIB "${PROJECT_DIR}/component/Actel/DirectCore/CoreAHBLite/5.2.100/rtl/vhdl/core/coreahblite_addrdec.vhd"
vcom -2008 -explicit  -work COREAHBLITE_LIB "${PROJECT_DIR}/component/Actel/DirectCore/CoreAHBLite/5.2.100/rtl/vhdl/core/coreahblite_masterstage.vhd"
vcom -2008 -explicit  -work COREAHBLITE_LIB "${PROJECT_DIR}/component/Actel/DirectCore/CoreAHBLite/5.2.100/rtl/vhdl/core/coreahblite_matrix4x16.vhd"
vcom -2008 -explicit  -work COREAHBLITE_LIB "${PROJECT_DIR}/component/Actel/DirectCore/CoreAHBLite/5.2.100/rtl/vhdl/core/coreahblite_pkg.vhd"
vcom -2008 -explicit  -work COREAHBLITE_LIB "${PROJECT_DIR}/component/Actel/DirectCore/CoreAHBLite/5.2.100/rtl/vhdl/core/coreahblite.vhd"
vcom -2008 -explicit  -work COREAHBLITE_LIB "${PROJECT_DIR}/component/Actel/DirectCore/CoreAHBLite/5.2.100/rtl/vhdl/core/components.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/component/work/SID_PLAYER_sb/SID_PLAYER_sb.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/component/work/SID_PLAYER/SID_PLAYER.vhd"
vcom -2008 -explicit  -work COREAHBLITE_LIB "${PROJECT_DIR}/component/Actel/DirectCore/CoreAHBLite/5.2.100/rtl/vhdl/test/user/testbench.vhd"

vsim -L SmartFusion2 -L presynth -L COREAHBLITE_LIB -L CORESDR_AXI_LIB -L COREAHBLSRAM_OBF_LIB  -t 1fs COREAHBLITE_LIB.SIB_SABER_TB
add wave /testbench/*
run -all
