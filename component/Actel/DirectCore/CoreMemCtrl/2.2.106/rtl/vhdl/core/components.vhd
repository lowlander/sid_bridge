-- ********************************************************************
-- Actel Corporation Proprietary and Confidential
--  Copyright 2008 Actel Corporation.  All rights reserved.
--
-- ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
-- ACCORDANCE WITH THE ACTEL LICENSE AGREEMENT AND MUST BE APPROVED
-- IN ADVANCE IN WRITING.
--
-- Description:	VHDL components for COREMEMCTRL
--
-- Revision Information:
-- Date         Description
-- ----         -----------------------------------------
--
--
-- SVN Revision Information:
-- SVN $Revision: 37897 $
-- SVN $Date: 2021-03-26 00:50:06 +0530 (Fri, 26 Mar 2021) $
--
-- Resolved SARs
-- SAR      Date     Who   Description
--
-- Notes:
-- 1. best viewed with tabstops set to "4"
--
-- History:		11/17/08  - TFB created
--
-- *********************************************************************
library ieee;
library work;

use     ieee.std_logic_1164.all;
use     IEEE.STD_LOGIC_UNSIGNED.ALL;
use     work.corememctrl_core_pkg.all;

package components is

-----------------------------------------------------------------------------
-- components
-----------------------------------------------------------------------------
component CoreMemCtrl
    generic (
        
	FAMILY                : integer range 0 to 30 := 17;
        ENABLE_FLASH_IF       : integer range 0 to 1  := 1;
        ENABLE_SRAM_IF        : integer range 0 to 1  := 1;
        MEMORY_ADDRESS_CONFIG_MODE    : integer range 0 to 1  := 1;
        SYNC_SRAM             : integer range 0 to 1  := 1;
        FLASH_TYPE            : integer range 0 to 1  := 0;
        NUM_MEMORY_CHIP       : integer range 1 to 4  := 4;
        MEM_0_DQ_SIZE         : integer range 8 to 32  := 32;
        MEM_1_DQ_SIZE         : integer range 8 to 32  := 32;
        MEM_2_DQ_SIZE         : integer range 8 to 32  := 32;
        MEM_3_DQ_SIZE         : integer range 8 to 32  := 32;
        FLASH_DQ_SIZE         : integer range 8 to 32  := 32;
      
        FLOW_THROUGH          : integer range 0 to 1  := 0;
        NUM_WS_FLASH_READ     : integer range 1 to 31  := 1;   
        NUM_WS_FLASH_WRITE    : integer range 1 to 31  := 1;

        NUM_WS_SRAM_READ_CH0  : integer range 1 to 31  := 1;
        NUM_WS_SRAM_READ_CH1  : integer range 1 to 31  := 1;
        NUM_WS_SRAM_READ_CH2  : integer range 1 to 31  := 1;
        NUM_WS_SRAM_READ_CH3  : integer range 1 to 31  := 1;
        NUM_WS_SRAM_WRITE_CH0 : integer range 1 to 31  := 1;
        NUM_WS_SRAM_WRITE_CH1 : integer range 1 to 31  := 1;
        NUM_WS_SRAM_WRITE_CH2 : integer range 1 to 31  := 1;
        NUM_WS_SRAM_WRITE_CH3 : integer range 1 to 31  := 1;

        SHARED_RW             : integer range 0 to 1  := 0;
        MEM_0_BASEADDR_GEN    : integer := 134217728;
        MEM_0_ENDADDR_GEN     : integer := 167772159;
        MEM_1_BASEADDR_GEN    : integer := 167772160;
        MEM_1_ENDADDR_GEN     : integer := 201326591;
        MEM_2_BASEADDR_GEN    : integer := 201326592;
        MEM_2_ENDADDR_GEN     : integer := 234881023;
        MEM_3_BASEADDR_GEN    : integer := 234881024;
        MEM_3_ENDADDR_GEN     : integer := 268435455
    );
    port (
        -- AHB interface
        -- Inputs
        HCLK            : in  std_logic;                        -- AHB Clock
        HRESETN         : in  std_logic;                        -- AHB Reset
        HSEL            : in  std_logic;                        -- AHB select
        HWRITE          : in  std_logic;                        -- AHB Write
        HREADYIN        : in  std_logic;                        -- AHB HREADY line
        HTRANS          : in  std_logic_vector(1 downto 0);     -- AHB HTRANS
        HSIZE           : in  std_logic_vector(2 downto 0);     -- AHB transfer size
        HWDATA          : in  std_logic_vector(31 downto 0);    -- AHB write data bus
        HADDR           : in  std_logic_vector(27 downto 0);    -- AHB address bus
        -- Outputs
        HREADY          : out std_logic;                        -- AHB ready signal
        HRESP           : out std_logic_vector(1 downto 0);     -- AHB transfer response
        HRDATA          : out std_logic_vector(31 downto 0);    -- AHB read data bus

        -- Remap control
        REMAP           : in  std_logic;

        -- Memory interface
        -- Flash interface
        FLASHCSN        : out std_logic;                        -- Flash chip select
        FLASHOEN        : out std_logic;                        -- Flash output enable
        FLASHWEN        : out std_logic;                        -- Flash write enable
        -- SRAM interface
        SRAMCLK         : out std_logic;                        -- Clock signal for synchronous SRAM
        SRAMCSN         : out std_logic_vector(NUM_MEMORY_CHIP-1 downto 0);    -- SRAM chip select
        SRAMOEN         : out std_logic;                        -- SRAM output enable
        SRAMWEN         : out std_logic;                        -- SRAM write enable
        SRAMBYTEN       : out std_logic_vector(DQ_SIZE_SRAM_SEL(MEM_0_DQ_SIZE , MEM_1_DQ_SIZE , MEM_2_DQ_SIZE , MEM_3_DQ_SIZE)/8-1 downto 0);     -- SRAM byte enables
        -- Shared memory signals
        MEMREADN        : out std_logic;                        -- Flash/SRAM read enable
        MEMWRITEN       : out std_logic;                        -- Flash/SRAM write enable
        MEMADDR         : out std_logic_vector(27 downto 0);    -- Flash/SRAM address bus
	    MEMDATA         : inout std_logic_vector (DQ_SIZE_SEL(MEM_0_DQ_SIZE , MEM_1_DQ_SIZE , MEM_2_DQ_SIZE , MEM_3_DQ_SIZE ,FLASH_DQ_SIZE)-1 downto 0)

    );
end component;

end components;
