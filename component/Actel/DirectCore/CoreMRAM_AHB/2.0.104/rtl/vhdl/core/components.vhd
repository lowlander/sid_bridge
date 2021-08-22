-- *********************************************************************/ 
-- Copyright (c) 2009 Actel Corporation.  All rights reserved.  
-- 
-- accordance with the Actel license agreement and must be approved 
-- in advance in writing.  
--  
-- File : components.vhd 
--     
-- Description: 
-- Notes:
--
-- *********************************************************************/ 

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


package components is

component ACT_UNIQUE_COREMRAM_AHB
   generic (
      FAMILY                  : integer := 25;    -- Device Family
      BYTE_MODE_EN            : integer range 0 to 1     := 0;            -- Select 16 bits / 8bits Memory interface
      ECC                     : integer range 0 to 1     := 1;            -- (0 - ECC Disabled) , (1 - ECC Enabled)
      BUFFER_DEPTH            : integer range 16 to 1024 := 16;           -- Configurable FIFO depth
      CORE_CLK_FREQUENCY      : integer range 12 to 48   := 12            -- CORE_CLK frequency in Mhz
   );
   port (
      ----        AHBLite Slave Interface Signals
      HCLK	                : in std_logic;                          --  AHB clock.
      HRESETN	                : in std_logic;                          --  AHB reset (Active low and asynchronous)
      HREADYIN	                : in std_logic;                          --  AHB ready in
      HTRANS                    : in std_logic_vector(1 downto 0);       --  AHB transfer type
      HWRITE	                : in std_logic;                          --  AHB write/read
      HBURST                    : in std_logic_vector(2 downto 0);       --  AHB Burst Type
      HSIZE                     : in std_logic_vector(2 downto 0);       --  AHB transfer size
      HSEL	                : in std_logic;                          --  AHB slave select
      HADDR                     : in std_logic_vector(31 downto 0);      --  AHB address
      HWDATA                    : in std_logic_vector(31 downto 0);      --  AHB data in
      HREADY	                : out std_logic;                         --  AHB ready out
      HRESP                     : out std_logic_vector(1 downto 0);      --  AHB response
      HRDATA                    : out std_logic_vector(31 downto 0);     --  AHB data out
      -----       NVRAM Clock and Reset 
      CORE_CLK                : in std_logic;                            --  NVRAM Controller Clock
      CORECLK_RESETN          : in std_logic;                            --  Async reset (Active low and asynchronous)
      MRAMCLK_OUT             : out std_logic;	                         --  NVRAM interface Clock.

      ECC_ERROR_SB            : out std_logic;	              
      ECC_ERROR_DB            : out std_logic;	             
      -----       NVRAM Interface Signals
      OVERFLOW_O              : in std_logic;                          --  Memory Internal Counter Overflow Flag, Active high signal indicates memory internal counter reached last address.
      CEB                     : out std_logic;                         --  Active low chip enable
      A                       : out std_logic_vector(20 downto 0);     --  Memory Address
      WE                      : out std_logic;                         --  Write Enable
      OE                      : out std_logic;                         --  Output Enable 
      X8                      : out std_logic;                         --  Byte Mode configuration
      AUTO_INCR               : out std_logic;                         --  Auto Increment Mode Enable 
      OVERFLOW_I              : out std_logic;                         --  Memory Internal Counter Enable  Pin. Active High Enable for internal counter (when INIT=1,DONE=0). Used to daisy chain devices. 
      INIT                    : out std_logic;                         --  Active High Interface Pin used to reset internal address counter (when OVERFLOW I=1, DONE=0) 
      DONE                    : out std_logic;                         --  Active Low Interface Pin used to reset internal address counter (when OVERFLOW I=1, INIT=1). 
      DQ                      : inout std_logic_vector(15 downto 0)    --  Data Input/output Signal
   );
end component;

end components;
