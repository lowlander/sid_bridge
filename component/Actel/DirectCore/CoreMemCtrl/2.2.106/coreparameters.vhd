----------------------------------------------------------------------
-- Created by Microsemi SmartDesign Mon Aug  9 02:14:21 2021
-- Parameters for CoreMemCtrl
----------------------------------------------------------------------


LIBRARY ieee;
   USE ieee.std_logic_1164.all;
   USE ieee.std_logic_unsigned.all;
   USE ieee.numeric_std.all;

package coreparameters is
    constant DQ_SIZE_GEN : integer := 8;
    constant DQ_SIZE_SRAM_GEN : integer := 8;
    constant ENABLE_FLASH_IF : integer := 1;
    constant ENABLE_SRAM_IF : integer := 1;
    constant FAMILY : integer := 19;
    constant FLASH_DQ_SIZE : integer := 8;
    constant FLASH_TYPE : integer := 0;
    constant FLOW_THROUGH : integer := 0;
    constant HDL_license : string( 1 to 1 ) := "U";
    constant MEM_0_BASEADDR : string( 1 to 8 ) := "08000000";
    constant MEM_0_BASEADDR_GEN : integer := 134217728;
    constant MEM_0_DQ_SIZE : integer := 8;
    constant MEM_0_ENDADDR : string( 1 to 8 ) := "09FFFFFF";
    constant MEM_0_ENDADDR_GEN : integer := 167772159;
    constant MEM_1_BASEADDR : string( 1 to 8 ) := "0A000000";
    constant MEM_1_BASEADDR_GEN : integer := 167772160;
    constant MEM_1_DQ_SIZE : integer := 8;
    constant MEM_1_ENDADDR : string( 1 to 8 ) := "0BFFFFFF";
    constant MEM_1_ENDADDR_GEN : integer := 201326591;
    constant MEM_2_BASEADDR : string( 1 to 8 ) := "0C000000";
    constant MEM_2_BASEADDR_GEN : integer := 201326592;
    constant MEM_2_DQ_SIZE : integer := 8;
    constant MEM_2_ENDADDR : string( 1 to 8 ) := "0DFFFFFF";
    constant MEM_2_ENDADDR_GEN : integer := 234881023;
    constant MEM_3_BASEADDR : string( 1 to 8 ) := "0E000000";
    constant MEM_3_BASEADDR_GEN : integer := 234881024;
    constant MEM_3_DQ_SIZE : integer := 8;
    constant MEM_3_ENDADDR : string( 1 to 8 ) := "0FFFFFFF";
    constant MEM_3_ENDADDR_GEN : integer := 268435455;
    constant MEMORY_ADDRESS_CONFIG_MODE : integer := 0;
    constant NUM_MEMORY_CHIP : integer := 1;
    constant NUM_WS_FLASH_READ : integer := 1;
    constant NUM_WS_FLASH_WRITE : integer := 1;
    constant NUM_WS_SRAM_READ_CH0 : integer := 1;
    constant NUM_WS_SRAM_READ_CH1 : integer := 1;
    constant NUM_WS_SRAM_READ_CH2 : integer := 1;
    constant NUM_WS_SRAM_READ_CH3 : integer := 1;
    constant NUM_WS_SRAM_WRITE_CH0 : integer := 1;
    constant NUM_WS_SRAM_WRITE_CH1 : integer := 1;
    constant NUM_WS_SRAM_WRITE_CH2 : integer := 1;
    constant NUM_WS_SRAM_WRITE_CH3 : integer := 1;
    constant SHARED_RW : integer := 0;
    constant SYNC_SRAM : integer := 1;
    constant testbench : string( 1 to 4 ) := "User";
end coreparameters;
