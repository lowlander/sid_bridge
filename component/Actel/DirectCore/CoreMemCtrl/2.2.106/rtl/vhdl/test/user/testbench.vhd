-- ********************************************************************/
-- Actel Corporation Proprietary and Confidential
--  Copyright 2009 Actel Corporation.  All rights reserved.
--
-- ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
-- ACCORDANCE WITH THE ACTEL LICENSE AGREEMENT AND MUST BE APPROVED
-- IN ADVANCE IN WRITING.
--
-- Description:  User Testbench for COREMEMCTRL
--
--
-- Revision Information:
-- Date     Description
--
-- SVN Revision Information:
-- SVN $Revision: 37897 $
-- SVN $Date: 2021-03-26 00:50:06 +0530 (Fri, 26 Mar 2021) $
--
-- Resolved SARs
-- SAR      Date     Who   Description
--
-- Notes:
--
-- ********************************************************************/

library ieee;
library work;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;
  use ieee.numeric_std.all;
  use work.corememctrl_core_pkg.all;
  use work.coreparameters.all;

entity testbench is
    generic (
        VECTFILE    : string := "corememctrl_usertb.vec"
    );
end entity testbench;

architecture test of testbench is

-- component declaration for DUT
component CoreMemCtrl is
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
        NUM_WS_FLASH_READ     : integer range 1 to 31  := 1;   -- range 0-3
        NUM_WS_FLASH_WRITE    : integer range 1 to 31  := 1;   -- range 1-3
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

      --  SRAMCSN         : out std_logic;                        -- SRAM chip select
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




component async_memory_8dq is
    port (
        -- Inputs
        A       : in  std_logic_vector(18 downto 0);    -- Address bus
        CSN     : in  std_logic;                        -- Chip enable
        OEN     : in  std_logic;                        -- Output enable
        WEN     : in  std_logic;                        -- Write enable
        BYTEN   : in  std_logic;     -- Byte enables
        -- Inout
        DQ      : inout std_logic_vector(7 downto 0)   -- Data bus
    );
end component;

component async_memory_16dq is
    port (
        -- Inputs
        A       : in  std_logic_vector(18 downto 0);    -- Address bus
        CSN     : in  std_logic;                        -- Chip enable
        OEN     : in  std_logic;                        -- Output enable
        WEN     : in  std_logic;                        -- Write enable
        BYTEN   : in  std_logic_vector(1 downto 0);     -- Byte enables
        -- Inout
        DQ      : inout std_logic_vector(15 downto 0)   -- Data bus
    );
end component;
component async_memory_32dq is
    port (
        -- Inputs
        A       : in  std_logic_vector(18 downto 0);    -- Address bus
        CSN     : in  std_logic;                        -- Chip enable
        OEN     : in  std_logic;                        -- Output enable
        WEN     : in  std_logic;                        -- Write enable
        BYTEN   : in  std_logic_vector(3 downto 0);     -- Byte enables
        -- Inout
        DQ      : inout std_logic_vector(31 downto 0)   -- Data bus
    );
end component;



component sync_memory_8dq is
    port (
        -- Inputs
        A       : in  std_logic_vector(18 downto 0);    -- Address bus
        CSN     : in  std_logic;                        -- Chip enable
        OEN     : in  std_logic;                        -- Output enable
        WEN     : in  std_logic;                        -- Write enable
        BYTEN   : in  std_logic;                        -- Byte enables
        CLK     : in  std_logic;                        -- Clock
        FTN     : in  std_logic;                        -- Flow-through/pipeline mode
        -- Inout
        DQ      : inout std_logic_vector(7 downto 0)   -- Data bus
    );
end component;
component sync_memory_16dq is
    port (
        -- Inputs
        A       : in  std_logic_vector(18 downto 0);    -- Address bus
        CSN     : in  std_logic;                        -- Chip enable
        OEN     : in  std_logic;                        -- Output enable
        WEN     : in  std_logic;                        -- Write enable
        BYTEN   : in  std_logic_vector(1 downto 0);     -- Byte enables
        CLK     : in  std_logic;                        -- Clock
        FTN     : in  std_logic;                        -- Flow-through/pipeline mode
        -- Inout
        DQ      : inout std_logic_vector(15 downto 0)   -- Data bus
    );
end component;

component sync_memory_32dq is
    port (
        -- Inputs
        A       : in  std_logic_vector(18 downto 0);    -- Address bus
        CSN     : in  std_logic;                        -- Chip enable
        OEN     : in  std_logic;                        -- Output enable
        WEN     : in  std_logic;                        -- Write enable
        BYTEN   : in  std_logic_vector(3 downto 0);     -- Byte enables
        CLK     : in  std_logic;                        -- Clock
        FTN     : in  std_logic;                        -- Flow-through/pipeline mode
        -- Inout
        DQ      : inout std_logic_vector(31 downto 0)   -- Data bus
    );
end component;

component BFM_AHBL is
  generic ( VECTFILE         : string  := "test.vec";
            MAX_INSTRUCTIONS : integer := 16384;
            MAX_STACK        : integer := 1024;
            MAX_MEMTEST      : integer := 65536;
            TPD              : integer range 0 to 1000 := 1;
            DEBUGLEVEL       : integer range -1 to 5 := -1;
            ARGVALUE0        : integer :=0;
            ARGVALUE1        : integer :=0;
            ARGVALUE2        : integer :=0;
            ARGVALUE3        : integer :=0;
            ARGVALUE4        : integer :=0;
            ARGVALUE5        : integer :=0;
            ARGVALUE6        : integer :=0;
            ARGVALUE7        : integer :=0;
            ARGVALUE8        : integer :=0;
            ARGVALUE9        : integer :=0;
            ARGVALUE10       : integer :=0;
            ARGVALUE11       : integer :=0;
            ARGVALUE12       : integer :=0;
            ARGVALUE13       : integer :=0;
            ARGVALUE14       : integer :=0;
            ARGVALUE15       : integer :=0;
            ARGVALUE16       : integer :=0;
            ARGVALUE17       : integer :=0;
            ARGVALUE18       : integer :=0;
            ARGVALUE19       : integer :=0;
            ARGVALUE20       : integer :=0;
            ARGVALUE21       : integer :=0;
            ARGVALUE22       : integer :=0;
            ARGVALUE23       : integer :=0;
            ARGVALUE24       : integer :=0;
            ARGVALUE25       : integer :=0;
            ARGVALUE26       : integer :=0;
            ARGVALUE27       : integer :=0;
            ARGVALUE28       : integer :=0;
            ARGVALUE29       : integer :=0;
            ARGVALUE30       : integer :=0;
            ARGVALUE31       : integer :=0;
            ARGVALUE32       : integer :=0;
            ARGVALUE33       : integer :=0;
            ARGVALUE34       : integer :=0;
            ARGVALUE35       : integer :=0;
            ARGVALUE36       : integer :=0;
            ARGVALUE37       : integer :=0;
            ARGVALUE38       : integer :=0;
            ARGVALUE39       : integer :=0;
            ARGVALUE40       : integer :=0;
            ARGVALUE41       : integer :=0;
            ARGVALUE42       : integer :=0;
            ARGVALUE43       : integer :=0;
            ARGVALUE44       : integer :=0;
            ARGVALUE45       : integer :=0;
            ARGVALUE46       : integer :=0;
            ARGVALUE47       : integer :=0;
            ARGVALUE48       : integer :=0;
            ARGVALUE49       : integer :=0;
            ARGVALUE50       : integer :=0;
            ARGVALUE51       : integer :=0;
            ARGVALUE52       : integer :=0;
            ARGVALUE53       : integer :=0;
            ARGVALUE54       : integer :=0;
            ARGVALUE55       : integer :=0;
            ARGVALUE56       : integer :=0;
            ARGVALUE57       : integer :=0;
            ARGVALUE58       : integer :=0;
            ARGVALUE59       : integer :=0;
            ARGVALUE60       : integer :=0;
            ARGVALUE61       : integer :=0;
            ARGVALUE62       : integer :=0;
            ARGVALUE63       : integer :=0;
            ARGVALUE64       : integer :=0;
            ARGVALUE65       : integer :=0;
            ARGVALUE66       : integer :=0;
            ARGVALUE67       : integer :=0;
            ARGVALUE68       : integer :=0;
            ARGVALUE69       : integer :=0;
            ARGVALUE70       : integer :=0;
            ARGVALUE71       : integer :=0;
            ARGVALUE72       : integer :=0;
            ARGVALUE73       : integer :=0;
            ARGVALUE74       : integer :=0;
            ARGVALUE75       : integer :=0;
            ARGVALUE76       : integer :=0;
            ARGVALUE77       : integer :=0;
            ARGVALUE78       : integer :=0;
            ARGVALUE79       : integer :=0;
            ARGVALUE80       : integer :=0;
            ARGVALUE81       : integer :=0;
            ARGVALUE82       : integer :=0;
            ARGVALUE83       : integer :=0;
            ARGVALUE84       : integer :=0;
            ARGVALUE85       : integer :=0;
            ARGVALUE86       : integer :=0;
            ARGVALUE87       : integer :=0;
            ARGVALUE88       : integer :=0;
            ARGVALUE89       : integer :=0;
            ARGVALUE90       : integer :=0;
            ARGVALUE91       : integer :=0;
            ARGVALUE92       : integer :=0;
            ARGVALUE93       : integer :=0;
            ARGVALUE94       : integer :=0;
            ARGVALUE95       : integer :=0;
            ARGVALUE96       : integer :=0;
            ARGVALUE97       : integer :=0;
            ARGVALUE98       : integer :=0;
            ARGVALUE99       : integer :=0
           );
  port ( SYSCLK      : in    std_logic;
         SYSRSTN     : in    std_logic;
         HADDR       : out   std_logic_vector(31 downto 0);
         HCLK        : out   std_logic;
         HRESETN     : out   std_logic;
         -- AHB Interface
         HBURST      : out   std_logic_vector( 2 downto 0);
         HMASTLOCK   : out   std_logic;
         HPROT       : out   std_logic_vector( 3 downto 0);
         HSIZE       : out   std_logic_vector( 2 downto 0);
         HTRANS      : out   std_logic_vector( 1 downto 0);
         HWRITE      : out   std_logic;
         HWDATA      : out   std_logic_vector(31 downto 0);
         HRDATA      : in    std_logic_vector(31 downto 0);
         HREADY      : in    std_logic;
         HRESP       : in    std_logic;
         HSEL        : out   std_logic_vector(15 downto 0);
         INTERRUPT   : in    std_logic_vector(255 downto 0);
         --Control etc
         GP_OUT      : out   std_logic_vector(31 downto 0);
         GP_IN       : in    std_logic_vector(31 downto 0);
         EXT_WR      : out   std_logic;
         EXT_RD      : out   std_logic;
         EXT_ADDR    : out   std_logic_vector(31 downto 0);
         EXT_DATA    : inout std_logic_vector(31 downto 0);
         EXT_WAIT    : in    std_logic;
         FINISHED    : out   std_logic;
         FAILED      : out   std_logic
       );
end component;

constant DQ_SIZE_TB : INTEGER := DQ_SIZE_SEL(MEM_0_DQ_SIZE , MEM_1_DQ_SIZE , MEM_2_DQ_SIZE , MEM_3_DQ_SIZE ,FLASH_DQ_SIZE);
constant DQ_SIZE_SRAM_TB : INTEGER := DQ_SIZE_SRAM_SEL(MEM_0_DQ_SIZE , MEM_1_DQ_SIZE , MEM_2_DQ_SIZE , MEM_3_DQ_SIZE );

-- Constant declarations
constant SYSCLK_PERIOD      : integer :=  20  ;

-- Printing constants
constant dash_str               :   string(1 to 77) :=
"-----------------------------------------------------------------------------";
constant uline_str              :   string(1 to 77) :=
"_____________________________________________________________________________";
constant pound_str              :   string(1 to 77) :=
"#############################################################################";
constant space77_str            :   string(1 to 77) :=
"                                                                             ";
constant copyright_str          :   string(1 to 77) :=
"(c) Copyright 2009 Actel Corporation. All rights reserved.                   ";
constant tb_name_str            :   string(1 to 77) :=
"Testbench for: CoreMemCtrl                                                   ";
constant tb_ver_str             :   string(1 to 77) :=
"Version: 2.0 23Feb09                                                         ";

type STR_ARRAY1 is array (integer range 0 to 11) of string (1 to 77);

-- initialization of testbench string
constant init_str_mem : STR_ARRAY1 := (
space77_str,space77_str,uline_str,space77_str,copyright_str,space77_str,
tb_name_str,tb_ver_str,uline_str,space77_str,space77_str,space77_str
);

-- Run simulation for given number of clock cycles
procedure cyc(
    constant c: in integer range 0 to 65536) is
begin
    cloop: for i in 1 to c loop
        wait for SYSCLK_PERIOD * 1 ns ;
    end loop cloop;
end cyc;

-- Signal declarations
signal simerrors    : integer;
signal stopsim      : boolean;
signal poll         : std_logic;
signal SYSCLK       : std_logic;
signal NSYSRESET    : std_logic;
signal REMAP        : std_logic;
signal FLASHCSN     : std_logic;
signal FLASHOEN     : std_logic;
signal FLASHWEN     : std_logic;
signal SRAMCLK      : std_logic;
signal MEMADDR      : std_logic_vector(27 downto 0);
signal MEMREADN     : std_logic;
signal MEMWRITEN    : std_logic;
signal SRAMBYTEN    : std_logic_vector(DQ_SIZE_SRAM_TB/8-1 downto 0);
signal SRAMCSN      : std_logic_vector(NUM_MEMORY_CHIP-1 downto 0);
signal SRAMOEN      : std_logic;
signal SRAMWEN      : std_logic;
signal MEMDATA      : std_logic_vector(DQ_SIZE_TB-1 downto 0);
signal HADDR        : std_logic_vector(31 downto 0);
signal HCLK         : std_logic;
signal HRESETN      : std_logic;
signal HBURST       : std_logic_vector(2 downto 0);
signal HMASTLOCK    : std_logic;
signal HPROT        : std_logic_vector(3 downto 0);
signal HSIZE        : std_logic_vector(2 downto 0);
signal HTRANS       : std_logic_vector(1 downto 0);
signal HWRITE       : std_logic;
signal HWDATA       : std_logic_vector(31 downto 0);
signal HRDATA       : std_logic_vector(31 downto 0);
signal HREADY       : std_logic;
signal HRESP        : std_logic_vector(1 downto 0);
signal HSEL         : std_logic_vector(15 downto 0);
signal HSEL_reg     : std_logic_vector(15 downto 0);
signal FINISHED     : std_logic;
signal FAILED       : std_logic;
signal FTN          : std_logic;
signal iSRAMOEN     : std_logic;
signal iSRAMWEN     : std_logic;
signal iFLASHOEN    : std_logic;
signal iFLASHWEN    : std_logic;
signal pullup1      : std_logic;

begin
    pullup1 <= '1';

    -- Active low flow through input (FTN) to some SSRAM models
    FTN <= '0' when FLOW_THROUGH = 1 else '1';

    iSRAMOEN  <= MEMREADN  when SHARED_RW = 1 else SRAMOEN;
    iSRAMWEN  <= MEMWRITEN when SHARED_RW = 1 else SRAMWEN;

    iFLASHOEN <= MEMREADN  when SHARED_RW = 1 else FLASHOEN;
    iFLASHWEN <= MEMWRITEN when SHARED_RW = 1 else FLASHWEN;

    test: process
    variable i : integer;
    begin
        i := 0;

        -- print out copyright info, testbench version, name of testbench, etc.
        while (i < 12) loop
         -- printf( init_str_mem(i));
          i := i + 1;
        end loop;

        -- initialize signals
        NSYSRESET <= '0';
        REMAP <= '0';

        -- sync to HCLK rising edge
        wait until (SYSCLK'event and SYSCLK = '1');

        -- release reset
        wait for SYSCLK_PERIOD * 20 ns ;
        NSYSRESET <= '1';

        -- BFM will assert its FINISHED output when it has processed all commands
        wait until (FINISHED = '1');
        wait for SYSCLK_PERIOD * 2 ns;
        stopsim <= true;
        wait;
    end process test;

    -- SYSCLK signal
    -- generate the system clock
    process
    begin
        if (stopsim) then
            wait;   -- end simulation
        else
            SYSCLK <= '0';
            wait for ((SYSCLK_PERIOD * 1 ns)/2);
            SYSCLK <= '1';
            wait for ((SYSCLK_PERIOD * 1 ns)/2);
        end if;
    end process;

    -- Update registered version of HSEL[15:0] when HREADY and
    -- HTRANS[1] are asserted. This condition indicates a valid transfer
    -- on the bus.
    -- HSEL_reg is used to control muxing of the (pipelined) read data
    -- and response from the slave back to master.
    process (HCLK, HRESETN)
    begin
        if (HRESETN'event and HRESETN = '0') then
            HSEL_reg <= (others => '0');
        elsif (HCLK'event and HCLK = '1') then
            if (HREADY = '1' and HTRANS(1) = '1') then
                HSEL_reg <= HSEL;
            end if;
        end if;
    end process;


    -- SRAM models
gen_async_asram8_0 :  if (NUM_MEMORY_CHIP > 0 and SYNC_SRAM = 0 and ENABLE_SRAM_IF = 1 and MEM_0_DQ_SIZE = 8 ) generate
 ram_dq8_0 : async_memory_8dq
    port map (
        A      => MEMADDR(18 downto 0),
        CSN    => SRAMCSN(0),
        OEN    => iSRAMOEN,
        WEN    => iSRAMWEN,
        BYTEN  => SRAMBYTEN(0),
        DQ     => MEMDATA(7 downto 0)
    );
end generate;
gen_async_asram16_0 :  if (NUM_MEMORY_CHIP > 0 and SYNC_SRAM = 0 and ENABLE_SRAM_IF = 1 and MEM_0_DQ_SIZE = 16 ) generate
 ram_dq16_0 : async_memory_16dq
    port map (
        A      => MEMADDR(18 downto 0),
        CSN    => SRAMCSN(0),
        OEN    => iSRAMOEN,
        WEN    => iSRAMWEN,
        BYTEN  => SRAMBYTEN(1 downto 0),
        DQ     => MEMDATA(15 downto 0)
    );
end generate;

gen_async_asram32_0 :  if (NUM_MEMORY_CHIP > 0 and SYNC_SRAM =0 and ENABLE_SRAM_IF = 1 and MEM_0_DQ_SIZE = 32 ) generate
    ram_dq32_0 : async_memory_32dq
    port map (
        A      => MEMADDR(18 downto 0),
        CSN    => SRAMCSN(0),
        OEN    => iSRAMOEN,
        WEN    => iSRAMWEN,
        BYTEN  => SRAMBYTEN(3 downto 0),
        DQ     => MEMDATA(31 downto 0)
    );
end generate;

gen_async_asram8_1 :  if (NUM_MEMORY_CHIP > 1 and SYNC_SRAM = 0 and ENABLE_SRAM_IF = 1 and MEM_1_DQ_SIZE = 8 ) generate
 ram_dq8_1 : async_memory_8dq
    port map (
        A      => MEMADDR(18 downto 0),
        CSN    => SRAMCSN(1),
        OEN    => iSRAMOEN,
        WEN    => iSRAMWEN,
        BYTEN  => SRAMBYTEN(0),
        DQ     => MEMDATA(7 downto 0)
    );
end generate;
gen_async_asram16_1 :  if (NUM_MEMORY_CHIP > 1 and SYNC_SRAM = 0 and ENABLE_SRAM_IF = 1 and MEM_1_DQ_SIZE = 16 ) generate
 ram_dq16_1 : async_memory_16dq
    port map (
        A      => MEMADDR(18 downto 0),
        CSN    => SRAMCSN(1),
        OEN    => iSRAMOEN,
        WEN    => iSRAMWEN,
        BYTEN  => SRAMBYTEN(1 downto 0),
        DQ     => MEMDATA(15 downto 0)
    );
end generate;


gen_async_asram32_1 :  if (NUM_MEMORY_CHIP > 1 and SYNC_SRAM =0 and ENABLE_SRAM_IF = 1 and MEM_1_DQ_SIZE = 32 ) generate
    ram_dq32_1 : async_memory_32dq
    port map (
        A      => MEMADDR(18 downto 0),
        CSN    => SRAMCSN(1),
        OEN    => iSRAMOEN,
        WEN    => iSRAMWEN,
        BYTEN  => SRAMBYTEN(3 downto 0),
        DQ     => MEMDATA(31 downto 0)
    );
end generate;
gen_async_asram8_2 :  if (NUM_MEMORY_CHIP > 2 and SYNC_SRAM = 0 and ENABLE_SRAM_IF = 1 and MEM_2_DQ_SIZE = 8 ) generate
 ram_dq8_2 : async_memory_8dq
    port map (
        A      => MEMADDR(18 downto 0),
        CSN    => SRAMCSN(2),
        OEN    => iSRAMOEN,
        WEN    => iSRAMWEN,
        BYTEN  => SRAMBYTEN(0),
        DQ     => MEMDATA(7 downto 0)
    );
end generate;
gen_async_asram16_2 :  if (NUM_MEMORY_CHIP > 2 and SYNC_SRAM = 0 and ENABLE_SRAM_IF = 1 and MEM_2_DQ_SIZE = 16 ) generate
 ram_dq16_2 : async_memory_16dq
    port map (
        A      => MEMADDR(18 downto 0),
        CSN    => SRAMCSN(2),
        OEN    => iSRAMOEN,
        WEN    => iSRAMWEN,
        BYTEN  => SRAMBYTEN(1 downto 0),
        DQ     => MEMDATA(15 downto 0)
    );
end generate;


gen_async_asram32_2 :  if (NUM_MEMORY_CHIP > 2 and SYNC_SRAM =0 and ENABLE_SRAM_IF = 1 and MEM_2_DQ_SIZE = 32 ) generate
    ram_dq32_2 : async_memory_32dq
    port map (
        A      => MEMADDR(18 downto 0),
        CSN    => SRAMCSN(2),
        OEN    => iSRAMOEN,
        WEN    => iSRAMWEN,
        BYTEN  => SRAMBYTEN(3 downto 0),
        DQ     => MEMDATA(31 downto 0)
    );
end generate;

gen_async_asram8_3 :  if (NUM_MEMORY_CHIP > 3 and SYNC_SRAM = 0 and ENABLE_SRAM_IF = 1 and MEM_3_DQ_SIZE = 8 ) generate
 ram_dq8_3 : async_memory_8dq
    port map (
        A      => MEMADDR(18 downto 0),
        CSN    => SRAMCSN(3),
        OEN    => iSRAMOEN,
        WEN    => iSRAMWEN,
        BYTEN  => SRAMBYTEN(0),
        DQ     => MEMDATA(7 downto 0)
    );
end generate;

gen_async_asram16_3 :  if (NUM_MEMORY_CHIP > 3 and SYNC_SRAM = 0 and ENABLE_SRAM_IF = 1 and MEM_3_DQ_SIZE = 16 ) generate
 ram_dq16_3 : async_memory_16dq
    port map (
        A      => MEMADDR(18 downto 0),
        CSN    => SRAMCSN(3),
        OEN    => iSRAMOEN,
        WEN    => iSRAMWEN,
        BYTEN  => SRAMBYTEN(1 downto 0),
        DQ     => MEMDATA(15 downto 0)
    );
end generate;


gen_async_asram32_3 :  if (NUM_MEMORY_CHIP > 3 and SYNC_SRAM =0 and ENABLE_SRAM_IF = 1 and MEM_3_DQ_SIZE = 32 ) generate
    ram_dq32_3 : async_memory_32dq
    port map (
        A      => MEMADDR(18 downto 0),
        CSN    => SRAMCSN(3),
        OEN    => iSRAMOEN,
        WEN    => iSRAMWEN,
        BYTEN  => SRAMBYTEN(3 downto 0),
        DQ     => MEMDATA(31 downto 0)
    );
end generate;


gen_async_ssram8_0 :  if (NUM_MEMORY_CHIP > 0 and SYNC_SRAM = 1 and ENABLE_SRAM_IF = 1 and MEM_0_DQ_SIZE = 8 ) generate
 ram_dq8_0 : sync_memory_8dq
    port map (
         A      => MEMADDR(18 downto 0),
        CSN    => SRAMCSN(0),
        OEN    => iSRAMOEN,
        WEN    => iSRAMWEN,
        BYTEN  => SRAMBYTEN(0),
        CLK    => SRAMCLK,
        FTN    => FTN,
        DQ     => MEMDATA(7 downto 0)
    );
end generate;
gen_async_ssram16_0 :  if (NUM_MEMORY_CHIP > 0 and SYNC_SRAM = 1 and ENABLE_SRAM_IF = 1 and MEM_0_DQ_SIZE = 16 ) generate
 ram_dq16_0 : sync_memory_16dq
    port map (
         A      => MEMADDR(18 downto 0),
        CSN    => SRAMCSN(0),
        OEN    => iSRAMOEN,
        WEN    => iSRAMWEN,
        BYTEN  => SRAMBYTEN(1 downto 0),
        CLK    => SRAMCLK,
        FTN    => FTN,
        DQ     => MEMDATA(15 downto 0)
    );
end generate;

gen_async_ssram32_0 :  if (NUM_MEMORY_CHIP > 0 and SYNC_SRAM =1 and ENABLE_SRAM_IF = 1 and MEM_0_DQ_SIZE = 32 ) generate
    ram_dq32_0 : sync_memory_32dq
    port map (
        A      => MEMADDR(18 downto 0),
        CSN    => SRAMCSN(0),
        OEN    => iSRAMOEN,
        WEN    => iSRAMWEN,
        BYTEN  => SRAMBYTEN(3 downto 0),
        CLK    => SRAMCLK,
        FTN    => FTN,
        DQ     => MEMDATA(31 downto 0)
    );
end generate;

gen_async_ssram8_1 :  if (NUM_MEMORY_CHIP > 1 and SYNC_SRAM = 1 and ENABLE_SRAM_IF = 1 and MEM_1_DQ_SIZE = 8 ) generate
 ram_dq8_1 : sync_memory_8dq
    port map (
        A      => MEMADDR(18 downto 0),
        CSN    => SRAMCSN(1),
        OEN    => iSRAMOEN,
        WEN    => iSRAMWEN,
        BYTEN  => SRAMBYTEN(0),
        CLK    => SRAMCLK,
        FTN    => FTN,
        DQ     => MEMDATA(7 downto 0)
    );
end generate;
gen_async_ssram16_1 :  if (NUM_MEMORY_CHIP > 1 and SYNC_SRAM = 1 and ENABLE_SRAM_IF = 1 and MEM_1_DQ_SIZE = 16 ) generate
 ram_dq16_1 : sync_memory_16dq
    port map (
        A      => MEMADDR(18 downto 0),
        CSN    => SRAMCSN(1),
        OEN    => iSRAMOEN,
        WEN    => iSRAMWEN,
        BYTEN  => SRAMBYTEN(1 downto 0),
        CLK    => SRAMCLK,
        FTN    => FTN,
        DQ     => MEMDATA(15 downto 0)
    );
end generate;


gen_async_ssram32_1 :  if (NUM_MEMORY_CHIP > 1 and SYNC_SRAM =1 and ENABLE_SRAM_IF = 1 and MEM_1_DQ_SIZE = 32 ) generate
    ram_dq32_1 : sync_memory_32dq
    port map (
        A      => MEMADDR(18 downto 0),
        CSN    => SRAMCSN(1),
        OEN    => iSRAMOEN,
        WEN    => iSRAMWEN,
        BYTEN  => SRAMBYTEN(3 downto 0),
        CLK    => SRAMCLK,
        FTN    => FTN,
        DQ     => MEMDATA(31 downto 0)
    );
end generate;

gen_async_ssram8_2 :  if (NUM_MEMORY_CHIP > 2 and SYNC_SRAM = 1 and ENABLE_SRAM_IF = 1 and MEM_2_DQ_SIZE = 8 ) generate
 ram_dq8_2 : sync_memory_8dq
    port map (
        A      => MEMADDR(18 downto 0),
        CSN    => SRAMCSN(2),
        OEN    => iSRAMOEN,
        WEN    => iSRAMWEN,
        BYTEN  => SRAMBYTEN(0),
        CLK    => SRAMCLK,
        FTN    => FTN,
        DQ     => MEMDATA(7 downto 0)
    );
end generate;
gen_async_ssram16_2 :  if (NUM_MEMORY_CHIP > 2 and SYNC_SRAM = 1 and ENABLE_SRAM_IF = 1 and MEM_2_DQ_SIZE = 16 ) generate
 ram_dq16_2 : sync_memory_16dq
    port map (
        A      => MEMADDR(18 downto 0),
        CSN    => SRAMCSN(2),
        OEN    => iSRAMOEN,
        WEN    => iSRAMWEN,
        BYTEN  => SRAMBYTEN(1 downto 0),
        CLK    => SRAMCLK,
        FTN    => FTN,
        DQ     => MEMDATA(15 downto 0)
    );
end generate;


gen_async_ssram32_2 :  if (NUM_MEMORY_CHIP > 2 and SYNC_SRAM =1 and ENABLE_SRAM_IF = 1 and MEM_2_DQ_SIZE = 32 ) generate
    ram_dq32_2 : sync_memory_32dq
    port map (
        A      => MEMADDR(18 downto 0),
        CSN    => SRAMCSN(2),
        OEN    => iSRAMOEN,
        WEN    => iSRAMWEN,
        BYTEN  => SRAMBYTEN(3 downto 0),
        CLK    => SRAMCLK,
        FTN    => FTN,
        DQ     => MEMDATA(31 downto 0)
    );
end generate;


gen_async_ssram8_3 :  if (NUM_MEMORY_CHIP > 3 and SYNC_SRAM = 1 and ENABLE_SRAM_IF = 1 and MEM_3_DQ_SIZE = 8 ) generate
 ram_dq8_3 : sync_memory_8dq
    port map (
        A      => MEMADDR(18 downto 0),
        CSN    => SRAMCSN(3),
        OEN    => iSRAMOEN,
        WEN    => iSRAMWEN,
        BYTEN  => SRAMBYTEN(0),
        CLK    => SRAMCLK,
        FTN    => FTN,
        DQ     => MEMDATA(7 downto 0)
    );
end generate;

gen_async_ssram16_3 :  if (NUM_MEMORY_CHIP > 3 and SYNC_SRAM = 1 and ENABLE_SRAM_IF = 1 and MEM_3_DQ_SIZE = 16 ) generate
 ram_dq16_3 : sync_memory_16dq
    port map (
        A      => MEMADDR(18 downto 0),
        CSN    => SRAMCSN(3),
        OEN    => iSRAMOEN,
        WEN    => iSRAMWEN,
        BYTEN  => SRAMBYTEN(1 downto 0),
        CLK    => SRAMCLK,
        FTN    => FTN,
        DQ     => MEMDATA(15 downto 0)
    );
end generate;


gen_async_ssram32_3 :  if (NUM_MEMORY_CHIP > 3 and SYNC_SRAM =1 and ENABLE_SRAM_IF = 1 and MEM_3_DQ_SIZE = 32 ) generate
    ram_dq32_3 : sync_memory_32dq
    port map (
        A      => MEMADDR(18 downto 0),
        CSN    => SRAMCSN(3),
        OEN    => iSRAMOEN,
        WEN    => iSRAMWEN,
        BYTEN  => SRAMBYTEN(3 downto 0),
        CLK    => SRAMCLK,
        FTN    => FTN,
        DQ     => MEMDATA(31 downto 0)
    );
end generate;

gen_flash8 :  if ( ENABLE_FLASH_IF = 1 and FLASH_DQ_SIZE = 8 ) generate
   flash_dq8_0 : async_memory_8dq
   port map (
      A      => MEMADDR(18 downto 0),
      CSN    => FLASHCSN,
      OEN    => iFLASHOEN,
      WEN    => iFLASHWEN,
      BYTEN  => '0',
      DQ     => MEMDATA(7 downto 0)
   );
end generate;


gen_flash16 :  if ( ENABLE_FLASH_IF = 1 and FLASH_DQ_SIZE = 16 ) generate
   flash_dq16_0 : async_memory_16dq
   port map (
      A      => MEMADDR(18 downto 0),
      CSN    => FLASHCSN,
      OEN    => iFLASHOEN,
      WEN    => iFLASHWEN,
      BYTEN  => "00",
      DQ     => MEMDATA(15 downto 0)
   );
end generate;

gen_flash32 :  if ( ENABLE_FLASH_IF = 1 and FLASH_DQ_SIZE = 32 ) generate
   flash_dq32_0 : async_memory_32dq
   port map (
      A      => MEMADDR(18 downto 0),
      CSN    => FLASHCSN,
      OEN    => iFLASHOEN,
      WEN    => iFLASHWEN,
      BYTEN  => "0000",
      DQ     => MEMDATA(31 downto 0)
   );
end generate;




--  Flash models
--   flash_lwr : async_memory
--   port map (
--        A      => MEMADDR(18 downto 0),
--        CSN    => FLASHCSN,
--        OEN    => iFLASHOEN,
--        WEN    => iFLASHWEN,
--        BYTEN  => "00",
--        DQ     => MEMDATA(15 downto 0)
--    );
--   gen_flash_upr: if (FLASH_DQ_SIZE = 32) generate
--      flash_upr : async_memory
--      port map (
--         A      => MEMADDR(18 downto 0),
--         CSN    => FLASHCSN,
--         OEN    => iFLASHOEN,
--         WEN    => iFLASHWEN,
--         BYTEN  => "00",
--         DQ     => MEMDATA(31 downto 16)
--      );
--   end generate;


    -- Memory controller (device under test)
    COREMEMCTRL_00 : CoreMemCtrl
    generic map (
        -- Configuration parameters

	FAMILY                => FAMILY,
        ENABLE_FLASH_IF       => ENABLE_FLASH_IF,
        ENABLE_SRAM_IF        => ENABLE_SRAM_IF,
        MEMORY_ADDRESS_CONFIG_MODE    => MEMORY_ADDRESS_CONFIG_MODE,	
        SYNC_SRAM             => SYNC_SRAM,
        FLASH_TYPE            => FLASH_TYPE,
        NUM_MEMORY_CHIP       => NUM_MEMORY_CHIP,
        MEM_0_DQ_SIZE         => MEM_0_DQ_SIZE,
        MEM_1_DQ_SIZE         => MEM_1_DQ_SIZE,
        MEM_2_DQ_SIZE         => MEM_2_DQ_SIZE,
        MEM_3_DQ_SIZE         => MEM_3_DQ_SIZE,
        FLASH_DQ_SIZE         => FLASH_DQ_SIZE,
        FLOW_THROUGH          => FLOW_THROUGH,
        NUM_WS_FLASH_READ     => NUM_WS_FLASH_READ,   
	    NUM_WS_FLASH_WRITE    => NUM_WS_FLASH_WRITE,
        NUM_WS_SRAM_READ_CH0  => NUM_WS_SRAM_READ_CH0,
        NUM_WS_SRAM_READ_CH1  => NUM_WS_SRAM_READ_CH1,
        NUM_WS_SRAM_READ_CH2  => NUM_WS_SRAM_READ_CH2,
        NUM_WS_SRAM_READ_CH3  => NUM_WS_SRAM_READ_CH3,
        NUM_WS_SRAM_WRITE_CH0 => NUM_WS_SRAM_WRITE_CH0,
        NUM_WS_SRAM_WRITE_CH1 => NUM_WS_SRAM_WRITE_CH1,
        NUM_WS_SRAM_WRITE_CH2 => NUM_WS_SRAM_WRITE_CH2,
        NUM_WS_SRAM_WRITE_CH3 => NUM_WS_SRAM_WRITE_CH3,
        SHARED_RW             => SHARED_RW ,
        MEM_0_BASEADDR_GEN    => MEM_0_BASEADDR_GEN,
        MEM_0_ENDADDR_GEN     => MEM_0_ENDADDR_GEN,
        MEM_1_BASEADDR_GEN    => MEM_1_BASEADDR_GEN,
        MEM_1_ENDADDR_GEN     => MEM_1_ENDADDR_GEN,
        MEM_2_BASEADDR_GEN    => MEM_2_BASEADDR_GEN,
        MEM_2_ENDADDR_GEN     => MEM_2_ENDADDR_GEN,
        MEM_3_BASEADDR_GEN    => MEM_3_BASEADDR_GEN,
        MEM_3_ENDADDR_GEN     => MEM_3_ENDADDR_GEN 
    )
    port map (
        -- Inputs
        HADDR               => HADDR(27 downto 0),
        HCLK                => HCLK,
        HREADYIN            => HREADY,
        HRESETN             => HRESETN,
        HSEL                => HSEL(0),
        HSIZE               => HSIZE,
        HTRANS              => HTRANS,
        HWDATA              => HWDATA,
        HWRITE              => HWRITE,
        REMAP               => REMAP,
        -- Outputs
        HRDATA              => HRDATA,
        HREADY              => HREADY,
        HRESP               => HRESP,
        MEMADDR             => MEMADDR,
        MEMREADN            => MEMREADN,
        MEMWRITEN           => MEMWRITEN,
        FLASHCSN            => FLASHCSN,
        FLASHOEN            => FLASHOEN,
        FLASHWEN            => FLASHWEN,
        SRAMBYTEN           => SRAMBYTEN,
        SRAMCSN             => SRAMCSN,
        SRAMCLK             => SRAMCLK,
        SRAMOEN             => SRAMOEN,
        SRAMWEN             => SRAMWEN,
        -- Inouts
        MEMDATA             => MEMDATA
    );

    -- AMBA AHB-Lite Bus Functional Model
    BFM_AHBL_00 : BFM_AHBL
    generic map (
        VECTFILE            => VECTFILE
    )
    port map (
        SYSCLK              => SYSCLK,
        SYSRSTN             => NSYSRESET,
        HADDR               => HADDR,
        HCLK                => HCLK,
        HRESETN             => HRESETN,
        HBURST              => HBURST,
        HMASTLOCK           => HMASTLOCK,
        HPROT               => HPROT,
        HSIZE               => HSIZE,
        HTRANS              => HTRANS,
        HWRITE              => HWRITE,
        HWDATA              => HWDATA,
        HRDATA              => HRDATA,
        HREADY              => HREADY,
        HRESP               => HRESP(0),
        HSEL                => HSEL,
        INTERRUPT           => (others => '0'),
        GP_OUT              => open,
        GP_IN               => (others => '0'),
        EXT_WR              => open,
        EXT_RD              => open,
        EXT_ADDR            => open,
        EXT_DATA            => open,
        EXT_WAIT            => '0',
        FINISHED            => FINISHED,
        FAILED              => FAILED
    );

end test;
