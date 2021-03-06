----------------------------------------------------------------------
-- Created by Microsemi SmartDesign Sat Aug 21 11:12:33 2021
-- Parameters for COREAHBLSRAM
----------------------------------------------------------------------


LIBRARY ieee;
   USE ieee.std_logic_1164.all;
   USE ieee.std_logic_unsigned.all;
   USE ieee.numeric_std.all;

package coreparameters is
    constant AHB_AWIDTH : integer := 32;
    constant AHB_DWIDTH : integer := 32;
    constant FAMILY : integer := 19;
    constant HDL_License : string( 1 to 1 ) := "O";
    constant LSRAM_NUM_LOCATIONS_DWIDTH32 : integer := 65536;
    constant SEL_SRAM_TYPE : integer := 0;
    constant Testbench : string( 1 to 4 ) := "User";
    constant USRAM_NUM_LOCATIONS_DWIDTH32 : integer := 512;
end coreparameters;
