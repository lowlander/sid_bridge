-- ********************************************************************/
-- Actel Corporation Proprietary and Confidential
-- Copyright 2009 Actel Corporation.  All rights reserved.
--
-- ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
-- ACCORDANCE WITH THE ACTEL LICENSE AGREEMENT AND MUST BE APPROVED
-- IN ADVANCE IN WRITING.
--
--
-- corememctrl.vhd
--
-- Description :
--          Memory Controller
--          AHB slave which is designed to interface to Flash and
--          either asynchronous or synchronous SRAM.
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
-- v2.1: Added wait states, by widening WS counter WSCouter
--       (fix for SAR 57873)
--
-- *********************************************************************/
library ieee;
library work;

use     ieee.std_logic_1164.all;
use     IEEE.STD_LOGIC_UNSIGNED.ALL;
use     work.corememctrl_core_pkg.all;

entity CoreMemCtrl is
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

        SHARED_RW             :  integer range 0 to 1  := 0;
        MEM_0_BASEADDR_GEN    :  integer := 134217728;
        MEM_0_ENDADDR_GEN     :  integer := 167772159;
        MEM_1_BASEADDR_GEN    :  integer := 167772160;
        MEM_1_ENDADDR_GEN     :  integer := 201326591;
        MEM_2_BASEADDR_GEN    :  integer := 201326592;
        MEM_2_ENDADDR_GEN     :  integer := 234881023;
        MEM_3_BASEADDR_GEN    :  integer := 234881024;
        MEM_3_ENDADDR_GEN     :  integer := 268435455
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
end entity CoreMemCtrl;

architecture rtl of CoreMemCtrl is

--------------------------------------------------------------------------------
-- Functions
--------------------------------------------------------------------------------
      

    constant  DQ_SIZE : INTEGER := DQ_SIZE_SEL(MEM_0_DQ_SIZE , MEM_1_DQ_SIZE , MEM_2_DQ_SIZE , MEM_3_DQ_SIZE ,FLASH_DQ_SIZE);
    constant  DQ_SIZE_SRAM : INTEGER := DQ_SIZE_SRAM_SEL(MEM_0_DQ_SIZE , MEM_1_DQ_SIZE , MEM_2_DQ_SIZE , MEM_3_DQ_SIZE );

    function to_stdlogic (
        val     : in boolean
    )
    return std_logic is
    begin
        if (val) then
            return('1');
        else
            return('0');
        end if;
    end to_stdlogic;

    function to_stdlogicvector (
        val     : in integer;
        len     : in integer
    )
    return std_logic_vector is
    variable rtn    : std_logic_vector(len-1 downto 0) := (others => '0');
    variable num    : integer := val;
    variable r      : integer;
    begin
        for index in 0 to len-1 loop
            r := num rem 2;
            num := num/2;
            if (r = 1) then
                rtn(index) := '1';
            else
                rtn(index) := '0';
            end if;
        end loop;
        return(rtn);
    end to_stdlogicvector;

--------------------------------------------------------------------------------
-- Constant declarations
--------------------------------------------------------------------------------

    -- State constant definitions
    constant ST_IDLE        : std_logic_vector(3 downto 0) := "0000";
    constant ST_IDLE_1      : std_logic_vector(3 downto 0) := "0001";
    constant ST_FLASH_RD    : std_logic_vector(3 downto 0) := "0010";
    constant ST_FLASH_WR    : std_logic_vector(3 downto 0) := "0011";
    constant ST_ASRAM_RD    : std_logic_vector(3 downto 0) := "0100";
    constant ST_ASRAM_WR    : std_logic_vector(3 downto 0) := "0101";
    constant ST_WAIT        : std_logic_vector(3 downto 0) := "0110";
    constant ST_WAIT1       : std_logic_vector(3 downto 0) := "0111";
    constant ST_SSRAM_WR    : std_logic_vector(3 downto 0) := "1000";
    constant ST_SSRAM_RD1   : std_logic_vector(3 downto 0) := "1001";
    constant ST_SSRAM_RD2   : std_logic_vector(3 downto 0) := "1010";

    constant ZERO           : std_logic_vector(4 downto 0) := "00000";
    constant ONE            : std_logic_vector(4 downto 0) := "00001";
    constant MAX_WAIT       : std_logic_vector(4 downto 0) := "11111";

    -- AHB HTRANS constant definitions
    constant TRN_IDLE       : std_logic_vector(1 downto 0) := "00";
    constant TRN_BUSY       : std_logic_vector(1 downto 0) := "01";
    constant TRN_NSEQ       : std_logic_vector(1 downto 0) := "10";
    constant TRN_SEQU       : std_logic_vector(1 downto 0) := "11";

    -- AHB HRESP constant definitions
    constant RSP_OKAY       : std_logic_vector(1 downto 0) := "00";
    constant RSP_ERROR      : std_logic_vector(1 downto 0) := "01";
    constant RSP_RETRY      : std_logic_vector(1 downto 0) := "10";
    constant RSP_SPLIT      : std_logic_vector(1 downto 0) := "11";

    -- AHB HREADYOUT constant definitions
    constant H_WAIT         : std_logic := '0';
    constant H_READY        : std_logic := '1';

    -- AHB HSIZE constant definitions
    constant SZ_BYTE        : std_logic_vector(2 downto 0) := "000";
    constant SZ_HALF        : std_logic_vector(2 downto 0) := "001";
    constant SZ_WORD        : std_logic_vector(2 downto 0) := "010";

    -- SRAM byte enables encoding
    constant NONE           : std_logic_vector(3 downto 0) := "1111";
    constant WORD           : std_logic_vector(3 downto 0) := "0000";
    constant HALF1          : std_logic_vector(3 downto 0) := "0011";
    constant HALF0          : std_logic_vector(3 downto 0) := "1100";
    constant BYTE3          : std_logic_vector(3 downto 0) := "0111";
    constant BYTE2          : std_logic_vector(3 downto 0) := "1011";
    constant BYTE1          : std_logic_vector(3 downto 0) := "1101";
    constant BYTE0          : std_logic_vector(3 downto 0) := "1110";



    constant MEM_0_BASEADDR_REMAP_DIS        : integer := 134217728; 
    constant MEM_0_ENDADDR_REMAP_DIS         : integer := 268435455;

    constant MEM_0_BASEADDR_REMAP_EN         : integer := 0;
    constant MEM_0_ENDADDR_REMAP_EN          : integer := 134217727;
--------------------------------------------------------------------------------
-- Signal declarations
--------------------------------------------------------------------------------

    signal MemCntlState     : std_logic_vector( 3 downto 0);
    signal NextMemCntlState : std_logic_vector( 3 downto 0);
    signal CurrentWait      : std_logic_vector( 4 downto 0);
    signal NextWait         : std_logic_vector( 4 downto 0);
    signal WSCounterLoadVal : std_logic_vector( 4 downto 0);
    signal LoadWSCounter    : std_logic;

    signal HselFlash        : std_logic;
    signal HselSram         : std_logic;
    signal HselReg          : std_logic;
    signal HselFlashReg     : std_logic;
    signal HselSramReg      : std_logic;

    signal MEMDATAIn        : std_logic_vector(DQ_SIZE-1 downto 0);
    signal MEMDATAOut       : std_logic_vector(31 downto 0);
    signal MEMDATAOEN       : std_logic;

    signal MEMDATAInReg     : std_logic_vector(31 downto 0);
    signal iHRDATA          : std_logic_vector(31 downto 0);
    signal iHready          : std_logic;
    signal HaddrReg         : std_logic_vector(27 downto 0);
    signal HwriteReg        : std_logic;
    signal HsizeReg         : std_logic_vector( 2 downto 0);

    signal SelHaddrReg,  NextSelHaddrReg    : std_logic;
    signal iMEMDATAOEN,  NextMEMDATAOEN     : std_logic;
    signal iFLASHCSN,    NextFLASHCSN       : std_logic;
    signal iFLASHWEN,    NextFLASHWEN       : std_logic;
    signal iFLASHOEN,    NextFLASHOEN       : std_logic;
    signal iSRAMWEN,     NextSRAMWEN        : std_logic;
    signal iSRAMOEN,     NextSRAMOEN        : std_logic;
    signal iSRAMCSN                         : std_logic_vector (NUM_MEMORY_CHIP-1 downto 0);    -- SRAM chip select

    signal NextSRAMCSN      : std_logic;
    signal HoldHreadyLow    : std_logic;
    signal iMEMREADN        : std_logic;
    signal iMEMWRITEN       : std_logic;
    signal HreadyNext       : std_logic;
    signal Valid            : std_logic;
    signal Busy             : std_logic;
   -- signal ValidReg         : std_logic;
    signal ACRegEn          : std_logic;

    -- StateName is used for debug - intended to be displayed as ASCII in
    -- waveform viewer.
    signal StateName        : std_logic_vector(31 downto 0);

    constant  SYNC_RESET : INTEGER := SYNC_MODE_SEL(FAMILY);

    signal    aresetn           : std_logic;
    signal    sresetn           : std_logic;
   



    signal    CH0_EN_reg        : std_logic;
    signal    CH1_EN_reg        : std_logic;
    signal    CH2_EN_reg        : std_logic;
    signal    CH3_EN_reg        : std_logic;
    signal    SRAM_16BIT        : std_logic;
    signal    SRAM_8BIT         : std_logic;


    signal    wr_follow_rd      : std_logic;
    signal    wr_follow_rd_next : std_logic;
    signal    ssram_split_trans_load  : std_logic;
    signal    ssram_split_trans_en    : std_logic;
    signal    ssram_read_buzy   : std_logic;
    signal    HselFlash_d       : std_logic;
    signal    HWRITE_d          : std_logic;
    signal    Valid_d           : std_logic;
    signal    Busy_d            : std_logic;
    signal    HSIZE_d           : std_logic_vector(2 downto 0);


    signal    NUM_WS_SRAM_WRITE : std_logic_vector (4 downto 0);
    signal    NUM_WS_SRAM_READ  : std_logic_vector (4 downto 0);
    signal    MEMDATA_rd_flash  : std_logic_vector (31 downto 0);
    signal    trans_split_count : std_logic_vector (1 downto 0);
    signal    trans_split_en    : std_logic;
    signal    trans_split_reset : std_logic;

    signal    ssram_split_trans      : std_logic_vector (1 downto 0);
    signal    ssram_split_trans_next : std_logic_vector (1 downto 0);

    signal    transaction_done       : std_logic;
    signal    next_transaction_done  : std_logic;
    signal    ssram_read_buzy_next   : std_logic;
    signal    ssram_read_buzy_next_d : std_logic;
    signal    pipeline_rd            : std_logic;
    signal    pipeline_rd_d1         : std_logic;
    signal    pipeline_rd_d2         : std_logic;
    signal    iSRAMCSN_s             : std_logic;

--------------------------------------------------------------------------------
-- Main body of code
--------------------------------------------------------------------------------
begin

    aresetn <= '1' WHEN (SYNC_RESET=1) ELSE HRESETN;
    sresetn <= HRESETN WHEN (SYNC_RESET=1) ELSE '1';

    -- Bidirectional memory data bus
    MEMDATA   <= MEMDATAOut when (DQ_SIZE = 32 and MEMDATAOEN = '0') else MEMDATAOut(15 downto 0)  when (DQ_SIZE = 16 and MEMDATAOEN = '0') else MEMDATAOut(7 downto 0) when (DQ_SIZE = 8 and MEMDATAOEN = '0') else (others=> 'Z') ;
    MEMDATAIn <= MEMDATA;

    -- Clock signal for synchronous SRAM is inverted HCLK
    SRAMCLK <= not(HCLK);

    -- Drive outputs to memories with internal signals
    MEMDATAOEN  <= iMEMDATAOEN;
    FLASHCSN    <= iFLASHCSN;
    FLASHWEN    <= iFLASHWEN;
    FLASHOEN    <= iFLASHOEN;
    SRAMCSN     <= iSRAMCSN;
    SRAMWEN     <= iSRAMWEN;
    SRAMOEN     <= iSRAMOEN;
    MEMWRITEN   <= iMEMWRITEN;
    MEMREADN    <= iMEMREADN;

    -- MEMWRITEN asserted if either flash or SRAM WEnN asserted
    iMEMWRITEN  <= '1' when ( (iFLASHWEN = '1') and (iSRAMWEN = '1') )
                   else '0';

    -- MEMREADN  asserted if either flash or SRAM OEnN asserted
    iMEMREADN   <= '1' when ( (iFLASHOEN = '1') and (iSRAMOEN = '1') )
                   else '0';

    -- When REMAP is asserted, flash appears at 0x08000000 and SRAM at 0x00000000.

    xhdhsel_config_1 : IF (MEMORY_ADDRESS_CONFIG_MODE = 1) GENERATE
       HselFlash <= '0' when (ENABLE_FLASH_IF = 0 and ENABLE_SRAM_IF = 1 ) else HSEL when (ENABLE_FLASH_IF = 1 and ENABLE_SRAM_IF = 0 ) else (HSEL and HADDR(27) ) when REMAP = '1' else (HSEL and not(HADDR(27)));
       HselSram  <= HSEL when (ENABLE_FLASH_IF = 0 and ENABLE_SRAM_IF = 1 ) else '0' when (ENABLE_FLASH_IF = 1 and ENABLE_SRAM_IF = 0 ) else (HSEL and not(HADDR(27))) when REMAP = '1' else (HSEL and HADDR(27) );
    END GENERATE;

    xhdhsel_config_0 : IF (MEMORY_ADDRESS_CONFIG_MODE = 0) GENERATE
       HselFlash <= (HSEL and HADDR(27)) when REMAP = '1' else (HSEL and not(HADDR(27)));
       HselSram  <= (HSEL and not(HADDR(27))) when REMAP = '1' else (HSEL and HADDR(27));
    END GENERATE;

    --------------------------------------------------------------------------------
    -- Valid transfer detection
    --------------------------------------------------------------------------------
    -- The slave must only respond to a valid transfer, so this must be detected.
    process (aresetn, HCLK)
    begin
        if (aresetn = '0') then
            HselReg      <= '0';
            HselFlashReg <= '0';
            HselSramReg  <= '0';
        elsif (HCLK'event and HCLK = '1') then
          if (sresetn = '0') then
            HselReg      <= '0';
            HselFlashReg <= '0';
            HselSramReg  <= '0';
          else
            if HREADYIN = '1' then
                HselReg      <= HSEL;
                HselFlashReg <= HselFlash;
                HselSramReg  <= HselSram;
            end if;
          end if;
        end if;
    end process;

    -- Valid AHB transfers only take place when a non-sequential or sequential
    -- transfer is shown on HTRANS - an idle or busy transfer should be ignored.
    Valid <= '1' when (HSEL = '1' and HREADYIN = '1'
                       and (HTRANS = TRN_NSEQ or HTRANS = TRN_SEQU))
                else '0';
    Busy <= '1' when (HSEL = '1' and HREADYIN = '1' and HWRITE= '0' and  (HTRANS = TRN_BUSY)) else '0';

--    ValidReg <= '1' when HselReg = '1'
--               and (HtransReg = TRN_NSEQ or HtransReg = TRN_SEQU)
--                else '0';


    --------------------------------------------------------------------------------
    -- Address and control registers
    --------------------------------------------------------------------------------
    -- Registers are used to store the address and control signals from the address
    -- phase for use in the data phase of the transfer.
    -- Only enabled when the HREADYIN input is HIGH and the module is addressed.
    -- AS: SAR63820 fix
    -- ACRegEn <= HSEL and HREADYIN;
    ACRegEn <= HSEL and HREADYIN and iHready;
    
    process (aresetn, HCLK)
    begin
        if (aresetn = '0') then
            HaddrReg  <= (others => '0');
            HwriteReg <= '0';
            HsizeReg  <= (others => '0');
        elsif (HCLK'event and HCLK = '1') then
          if (sresetn = '0') then
            HaddrReg  <= (others => '0');
            HwriteReg <= '0';
            HsizeReg  <= (others => '0');
          else
            if (ACRegEn = '1') then
                HaddrReg  <= HADDR;
                HwriteReg <= HWRITE;
                HsizeReg  <= HSIZE;
            end if;
          end if;
        end if;
    end process;


    process (aresetn, HCLK)
    begin
       if (aresetn = '0') then
            Busy_d  <= '0';
       elsif (HCLK'event and HCLK = '1') then
          if (sresetn = '0') then
             Busy_d  <= '0';
          else
             Busy_d  <= Busy;
          end if;
       end if;
    end process;

xhdlch4 : if (NUM_MEMORY_CHIP = 4) generate
   process(HaddrReg)
   begin
      CH0_EN_reg        <= '0' ;
      CH1_EN_reg        <= '0' ;
      CH2_EN_reg        <= '0' ;
      CH3_EN_reg        <= '0' ;
      SRAM_16BIT        <= '0';
      SRAM_8BIT         <= '0';
      NUM_WS_SRAM_WRITE <= to_stdlogicvector(NUM_WS_SRAM_WRITE_CH0,5);
      NUM_WS_SRAM_READ  <= to_stdlogicvector(NUM_WS_SRAM_READ_CH0,5);
      if ((HaddrReg >= to_stdlogicvector(MEM_0_BASEADDR_GEN, 28)) and (HaddrReg <=to_stdlogicvector(MEM_0_ENDADDR_GEN, 28))) then
         CH0_EN_reg        <='1';
         NUM_WS_SRAM_WRITE <= to_stdlogicvector(NUM_WS_SRAM_WRITE_CH0,5);
         NUM_WS_SRAM_READ  <= to_stdlogicvector(NUM_WS_SRAM_READ_CH0,5);
         if(MEM_0_DQ_SIZE = 32 ) then
            SRAM_16BIT <= '0';
            SRAM_8BIT  <= '0';
         elsif (MEM_0_DQ_SIZE = 16 ) then
            SRAM_16BIT <= '1';
            SRAM_8BIT  <= '0';
         else
            SRAM_16BIT <= '0';
            SRAM_8BIT  <= '1';
         end if ;
      elsif ((HaddrReg >= to_stdlogicvector(MEM_1_BASEADDR_GEN, 28)) and (HaddrReg <= to_stdlogicvector(MEM_1_ENDADDR_GEN, 28))) then
         CH1_EN_reg        <= '1';
         NUM_WS_SRAM_WRITE <= to_stdlogicvector(NUM_WS_SRAM_WRITE_CH1,5);
         NUM_WS_SRAM_READ  <= to_stdlogicvector(NUM_WS_SRAM_READ_CH1,5);
         if(MEM_1_DQ_SIZE = 32 ) then
            SRAM_16BIT <= '0';
            SRAM_8BIT  <= '0';
         elsif (MEM_1_DQ_SIZE = 16 ) then
            SRAM_16BIT <= '1';
            SRAM_8BIT  <= '0';
         else
            SRAM_16BIT <= '0';
            SRAM_8BIT  <= '1';
         end if ; 
       elsif ((HaddrReg >= to_stdlogicvector(MEM_2_BASEADDR_GEN, 28)) and (HaddrReg <= to_stdlogicvector(MEM_2_ENDADDR_GEN, 28))) then
         CH2_EN_reg        <='1';
         NUM_WS_SRAM_WRITE <= to_stdlogicvector(NUM_WS_SRAM_WRITE_CH2,5);
         NUM_WS_SRAM_READ  <= to_stdlogicvector(NUM_WS_SRAM_READ_CH2,5);
         if(MEM_2_DQ_SIZE = 32 ) then
            SRAM_16BIT <= '0';
            SRAM_8BIT  <= '0';
         elsif (MEM_2_DQ_SIZE = 16 ) then
            SRAM_16BIT <= '1';
            SRAM_8BIT  <= '0';
         else
            SRAM_16BIT <= '0';
            SRAM_8BIT  <= '1';
         end if; 
       elsif ((HaddrReg >= to_stdlogicvector(MEM_3_BASEADDR_GEN, 28)) and (HaddrReg <= to_stdlogicvector(MEM_3_ENDADDR_GEN, 28))) then
         CH3_EN_reg        <='1';
         NUM_WS_SRAM_WRITE <= to_stdlogicvector(NUM_WS_SRAM_WRITE_CH3,5);
         NUM_WS_SRAM_READ  <= to_stdlogicvector(NUM_WS_SRAM_READ_CH3,5);
         if(MEM_3_DQ_SIZE = 32 ) then
            SRAM_16BIT <=  '0' ;
            SRAM_8BIT  <=  '0' ;
         elsif (MEM_3_DQ_SIZE = 16 ) then
            SRAM_16BIT <= '1';
            SRAM_8BIT  <= '0';
         else
            SRAM_16BIT <= '0';
            SRAM_8BIT  <= '1';
         end if;
      end if;
   end process;
end generate;

xhdlch3 : if (NUM_MEMORY_CHIP = 3) generate
   process(HaddrReg)
   begin
      CH0_EN_reg        <= '0' ;
      CH1_EN_reg        <= '0' ;
      CH2_EN_reg        <= '0' ;
      CH3_EN_reg        <= '0' ;
      SRAM_16BIT        <= '0';
      SRAM_8BIT         <= '0';
      NUM_WS_SRAM_WRITE <= to_stdlogicvector(NUM_WS_SRAM_WRITE_CH0,5);
      NUM_WS_SRAM_READ  <= to_stdlogicvector(NUM_WS_SRAM_READ_CH0,5);
      if ((HaddrReg >= to_stdlogicvector(MEM_0_BASEADDR_GEN, 28)) and (HaddrReg <= to_stdlogicvector(MEM_0_ENDADDR_GEN, 28))) then
         CH0_EN_reg        <='1';
         NUM_WS_SRAM_WRITE <= to_stdlogicvector(NUM_WS_SRAM_WRITE_CH0,5);
         NUM_WS_SRAM_READ  <= to_stdlogicvector(NUM_WS_SRAM_READ_CH0,5);
         if(MEM_0_DQ_SIZE = 32 ) then
            SRAM_16BIT <= '0';
            SRAM_8BIT  <= '0';
         elsif (MEM_0_DQ_SIZE = 16 ) then
            SRAM_16BIT <= '1';
            SRAM_8BIT  <= '0';
         else
            SRAM_16BIT <= '0';
            SRAM_8BIT  <= '1';
         end if ;
      elsif ((HaddrReg >= to_stdlogicvector(MEM_1_BASEADDR_GEN, 28)) and (HaddrReg <= to_stdlogicvector(MEM_1_ENDADDR_GEN, 28))) then
         CH1_EN_reg        <= '1';
         NUM_WS_SRAM_WRITE <= to_stdlogicvector(NUM_WS_SRAM_WRITE_CH1,5);
         NUM_WS_SRAM_READ  <= to_stdlogicvector(NUM_WS_SRAM_READ_CH1,5);
         if(MEM_1_DQ_SIZE = 32 ) then
            SRAM_16BIT <= '0';
            SRAM_8BIT  <= '0';
         elsif (MEM_1_DQ_SIZE = 16 ) then
            SRAM_16BIT <= '1';
            SRAM_8BIT  <= '0';
         else
            SRAM_16BIT <= '0';
            SRAM_8BIT  <= '1';
         end if ; 
      elsif ((HaddrReg >= to_stdlogicvector(MEM_2_BASEADDR_GEN, 28)) and (HaddrReg <= to_stdlogicvector(MEM_2_ENDADDR_GEN, 28))) then
         CH2_EN_reg        <='1';
         NUM_WS_SRAM_WRITE <= to_stdlogicvector(NUM_WS_SRAM_WRITE_CH2,5);
         NUM_WS_SRAM_READ  <= to_stdlogicvector(NUM_WS_SRAM_READ_CH2,5);
         if(MEM_2_DQ_SIZE = 32 ) then
            SRAM_16BIT <= '0';
            SRAM_8BIT  <= '0';
         elsif (MEM_2_DQ_SIZE = 16 ) then
            SRAM_16BIT <= '1';
            SRAM_8BIT  <= '0';
         else
            SRAM_16BIT <= '0';
            SRAM_8BIT  <= '1';
         end if; 
      end if;
   end process;
end generate;

xhdlch2 : if (NUM_MEMORY_CHIP = 2) generate
   process(HaddrReg)
   begin
      CH0_EN_reg        <= '0' ;
      CH1_EN_reg        <= '0' ;
      CH2_EN_reg        <= '0' ;
      CH3_EN_reg        <= '0' ;
      SRAM_16BIT        <= '0';
      SRAM_8BIT         <= '0';
      NUM_WS_SRAM_WRITE <= to_stdlogicvector(NUM_WS_SRAM_WRITE_CH0,5);
      NUM_WS_SRAM_READ  <= to_stdlogicvector(NUM_WS_SRAM_READ_CH0,5);
      if ((HaddrReg >= to_stdlogicvector(MEM_0_BASEADDR_GEN, 28)) and (HaddrReg <= to_stdlogicvector(MEM_0_ENDADDR_GEN, 28))) then
         CH0_EN_reg        <='1';
         NUM_WS_SRAM_WRITE <= to_stdlogicvector(NUM_WS_SRAM_WRITE_CH0,5);
         NUM_WS_SRAM_READ  <= to_stdlogicvector(NUM_WS_SRAM_READ_CH0,5);
         if(MEM_0_DQ_SIZE = 32 ) then
            SRAM_16BIT <= '0';
            SRAM_8BIT  <= '0';
         elsif (MEM_0_DQ_SIZE = 16 ) then
            SRAM_16BIT <= '1';
            SRAM_8BIT  <= '0';
         else
            SRAM_16BIT <= '0';
            SRAM_8BIT  <= '1';
         end if ;
      elsif ((HaddrReg >= to_stdlogicvector(MEM_1_BASEADDR_GEN, 28)) and (HaddrReg <= to_stdlogicvector(MEM_1_ENDADDR_GEN, 28))) then
         CH1_EN_reg        <= '1';
         NUM_WS_SRAM_WRITE <= to_stdlogicvector(NUM_WS_SRAM_WRITE_CH1,5);
         NUM_WS_SRAM_READ  <= to_stdlogicvector(NUM_WS_SRAM_READ_CH1,5);
         if(MEM_1_DQ_SIZE = 32 ) then
            SRAM_16BIT <= '0';
            SRAM_8BIT  <= '0';
         elsif (MEM_1_DQ_SIZE = 16 ) then
            SRAM_16BIT <= '1';
            SRAM_8BIT  <= '0';
         else
            SRAM_16BIT <= '0';
            SRAM_8BIT  <= '1';
         end if ; 
      end if;
   end process;
end generate;

xhdlch1 : if (NUM_MEMORY_CHIP = 1 and MEMORY_ADDRESS_CONFIG_MODE = 1) generate
   process(HaddrReg)
   begin
      CH0_EN_reg        <= '0' ;
      CH1_EN_reg        <= '0' ;
      CH2_EN_reg        <= '0' ;
      CH3_EN_reg        <= '0' ;
      SRAM_16BIT        <= '0';
      SRAM_8BIT         <= '0';
      NUM_WS_SRAM_WRITE <= to_stdlogicvector(NUM_WS_SRAM_WRITE_CH0,5);
      NUM_WS_SRAM_READ  <= to_stdlogicvector(NUM_WS_SRAM_READ_CH0,5);
      if ((HaddrReg >= to_stdlogicvector(MEM_0_BASEADDR_GEN, 28)) and (HaddrReg <= to_stdlogicvector(MEM_0_ENDADDR_GEN, 28))) then
         CH0_EN_reg        <='1';
         NUM_WS_SRAM_WRITE <= to_stdlogicvector(NUM_WS_SRAM_WRITE_CH0,5);
         NUM_WS_SRAM_READ  <= to_stdlogicvector(NUM_WS_SRAM_READ_CH0,5);
         if(MEM_0_DQ_SIZE = 32 ) then
            SRAM_16BIT <= '0';
            SRAM_8BIT  <= '0';
         elsif (MEM_0_DQ_SIZE = 16 ) then
            SRAM_16BIT <= '1';
            SRAM_8BIT  <= '0';
         else
            SRAM_16BIT <= '0';
            SRAM_8BIT  <= '1';
         end if ;
      end if;
   end process;
end generate;


xhdlch1_config0 : if (NUM_MEMORY_CHIP = 1 and MEMORY_ADDRESS_CONFIG_MODE = 0) generate
   process(HaddrReg, REMAP)
   begin
      CH0_EN_reg        <= '0' ;
      CH1_EN_reg        <= '0' ;
      CH2_EN_reg        <= '0' ;
      CH3_EN_reg        <= '0' ;
      SRAM_16BIT        <= '0';
      SRAM_8BIT         <= '0';
      NUM_WS_SRAM_WRITE <= to_stdlogicvector(NUM_WS_SRAM_WRITE_CH0,5);
      NUM_WS_SRAM_READ  <= to_stdlogicvector(NUM_WS_SRAM_READ_CH0,5);
     
      if(REMAP = '0' ) then
         if ((HaddrReg >= to_stdlogicvector(MEM_0_BASEADDR_REMAP_DIS, 28)) and (HaddrReg <= to_stdlogicvector(MEM_0_ENDADDR_REMAP_DIS, 28))) then
            CH0_EN_reg        <='1';
            NUM_WS_SRAM_WRITE <= to_stdlogicvector(NUM_WS_SRAM_WRITE_CH0,5);
            NUM_WS_SRAM_READ  <= to_stdlogicvector(NUM_WS_SRAM_READ_CH0,5);
            if(MEM_0_DQ_SIZE = 32 ) then
               SRAM_16BIT <= '0';
               SRAM_8BIT  <= '0';
            elsif (MEM_0_DQ_SIZE = 16 ) then
               SRAM_16BIT <= '1';
               SRAM_8BIT  <= '0';
            else
               SRAM_16BIT <= '0';
               SRAM_8BIT  <= '1';
            end if ;
         end if;
      else
         if ((HaddrReg >= to_stdlogicvector(MEM_0_BASEADDR_REMAP_EN, 28)) and (HaddrReg <= to_stdlogicvector(MEM_0_ENDADDR_REMAP_EN, 28))) then
            CH0_EN_reg        <='1';
            NUM_WS_SRAM_WRITE <= to_stdlogicvector(NUM_WS_SRAM_WRITE_CH0,5);
            NUM_WS_SRAM_READ  <= to_stdlogicvector(NUM_WS_SRAM_READ_CH0,5);
            if(MEM_0_DQ_SIZE = 32 ) then
               SRAM_16BIT <= '0';
               SRAM_8BIT  <= '0';
            elsif (MEM_0_DQ_SIZE = 16 ) then
               SRAM_16BIT <= '1';
               SRAM_8BIT  <= '0';
            else
               SRAM_16BIT <= '0';
               SRAM_8BIT  <= '1';
            end if ;
         end if;
      end if;
   end process;
end generate;

    --------------------------------------------------------------------------------
    -- Wait state counter
    --------------------------------------------------------------------------------
    -- Generates count signal depending on the type of memory access taking place.
    -- Counter decrements to zero.
    -- Wait states are inserted when CurrentWait is not equal to ZERO.

    -- Next counter value
    process (LoadWSCounter, WSCounterLoadVal, CurrentWait)
    begin
        if (LoadWSCounter = '1') then
            NextWait <= WSCounterLoadVal;
        elsif (CurrentWait = ZERO) then
            NextWait <= ZERO;
        else
            NextWait <= CurrentWait - "01";
        end if;
    end process;

    process (HCLK, aresetn)
    begin
        if (aresetn = '0') then
            CurrentWait <= ZERO;
        elsif (HCLK'event and HCLK = '1') then
          if (sresetn = '0') then
            CurrentWait <= ZERO;
          else
            CurrentWait <= NextWait;
          end if;
        end if;
    end process;

    --------------------------------------------------------------------------------
    -- HREADY generation
    --------------------------------------------------------------------------------
    -- HREADY is asserted when the wait state counter reaches zero.
    -- HoldHreadyLow can be used to negate HREADY during the first half of a
    -- word access when using 16-bit flash.
    HreadyNext <= '1' when NextWait = ZERO else '0';

    process (aresetn, HCLK)
    begin
       if (aresetn = '0') then
          iHready <= '1';
       elsif (HCLK'event and HCLK = '1') then
          if (sresetn = '0') then
             iHready <= '1';
          else
             if(HoldHreadyLow = '1') then
                iHready <= '0';
             else
                iHready <= HreadyNext;
             end if;
          end if;
       end if;
    end process;

    HREADY <= iHready;
     
    
    --------------------------------------------------------------------------------
    -- MEMDATAOut generation
    --------------------------------------------------------------------------------
   process (HselReg, HwriteReg, iFLASHCSN,wr_follow_rd_next,HsizeReg,trans_split_count,MEMDATA_rd_flash,ssram_split_trans_next,HaddrReg,SRAM_16BIT,SRAM_8BIT, HWDATA)
   begin
      if ( HselReg ='1' and HwriteReg='1' ) then
         if ( iFLASHCSN = '0' ) then   
            if ( FLASH_DQ_SIZE = 16 ) then
               if(wr_follow_rd_next ='1') then
                  if (HsizeReg = SZ_BYTE) then
                     if(HaddrReg (1 downto 0) = "00" ) then
                        MEMDATAOut <= "0000000000000000" & MEMDATA_rd_flash(15 downto 8) & HWDATA(7 downto 0);
                     elsif (HaddrReg (1 downto 0) ="01") then
                        MEMDATAOut <= "0000000000000000" & HWDATA(15 downto 8) & MEMDATA_rd_flash(7 downto 0);
                     elsif (HaddrReg (1 downto 0) ="10") then
                        MEMDATAOut <= "0000000000000000" & MEMDATA_rd_flash(15 downto 8) & HWDATA(23 downto 16);
                     else
                        MEMDATAOut <= "0000000000000000" & HWDATA(31 downto 24) & MEMDATA_rd_flash(7 downto 0);
                     end if;
                  else
                     MEMDATAOut <= HWDATA(31 downto 0);
                  end if;
               else
                  if(HsizeReg = SZ_WORD) then  
                     if ( trans_split_count(0) = '1' ) then
                        MEMDATAOut <= HWDATA(31 downto 16) & HWDATA(31 downto 16) ;
                     else
                        MEMDATAOut <= HWDATA(15 downto 0) & HWDATA(15 downto 0) ;
                     end if;
                  elsif(HsizeReg = SZ_HALF) then 
                     if(HaddrReg (1) = '0' ) then
                        MEMDATAOut <=  HWDATA(15 downto 0) & HWDATA(15 downto 0) ;
                     else
                        MEMDATAOut <=  HWDATA(31 downto 16) & HWDATA(31 downto 16);
                     end if;
                  else
                     if(HaddrReg ( 1) = '0' ) then
                        MEMDATAOut <=  HWDATA(15 downto 0) & HWDATA(15 downto 0) ;
                     else
                        MEMDATAOut <=  HWDATA(31 downto 16) & HWDATA(31 downto 16);
                     end if;
                  end if;
               end if;
            elsif(FLASH_DQ_SIZE = 8) then 
               if(HsizeReg = SZ_WORD) then     
                  if (trans_split_count = "00") then
                     MEMDATAOut <=  HWDATA(7 downto 0) & HWDATA(7 downto 0) & HWDATA(7 downto 0) & HWDATA(7 downto 0) ;
                  elsif (trans_split_count = "01") then
                     MEMDATAOut <=  HWDATA(15 downto 8) & HWDATA(15 downto 8) & HWDATA(15 downto 8) & HWDATA(15 downto 8) ;
                  elsif (trans_split_count = "10") then
                     MEMDATAOut <=  HWDATA(23 downto 16) & HWDATA(23 downto 16) & HWDATA(23 downto 16) & HWDATA(23 downto 16) ;
                  else
                     MEMDATAOut <=  HWDATA(31 downto 24) & HWDATA(31 downto 24) & HWDATA(31 downto 24) & HWDATA(31 downto 24) ;
                  end if;
               elsif(HsizeReg = SZ_HALF) then  
                  if(HaddrReg (1) = '0' ) then
                     if (trans_split_count(0) = '0') then
                        MEMDATAOut <=  HWDATA(7 downto 0) & HWDATA(7 downto 0) & HWDATA(7 downto 0) & HWDATA(7 downto 0) ;
                     else
                        MEMDATAOut <=  HWDATA(15 downto 8) & HWDATA(15 downto 8) & HWDATA(15 downto 8) & HWDATA(15 downto 8) ;
                     end if;
                  else
                     if (trans_split_count(0) = '0') then
                        MEMDATAOut <=  HWDATA(23 downto 16) & HWDATA(23 downto 16) & HWDATA(23 downto 16) & HWDATA(23 downto 16);
                     else
                        MEMDATAOut <=  HWDATA(31 downto 24) & HWDATA(31 downto 24) & HWDATA(31 downto 24) & HWDATA(31 downto 24) ;
                     end if;
                  end if;
               else
                  if(HaddrReg (1 downto 0) = "00" ) then
                     MEMDATAOut <=  HWDATA(7 downto 0) & HWDATA(7 downto 0) & HWDATA(7 downto 0) & HWDATA(7 downto 0) ;
                  elsif(HaddrReg (1 downto 0) = "01" ) then
                     MEMDATAOut <=  HWDATA(15 downto 8) & HWDATA(15 downto 8) & HWDATA(15 downto 8) & HWDATA(15 downto 8) ;
                  elsif(HaddrReg (1 downto 0) = "10" ) then
                     MEMDATAOut <=  HWDATA(23 downto 16) & HWDATA(23 downto 16) & HWDATA(23 downto 16) & HWDATA(23 downto 16);
                  else
                     MEMDATAOut <=  HWDATA(31 downto 24) & HWDATA(31 downto 24) & HWDATA(31 downto 24) & HWDATA(31 downto 24) ;
                  end if;
               end if;
            else
               if(wr_follow_rd_next = '1') then
                  if (HsizeReg = SZ_HALF) then
                     if(HaddrReg (1) = '0' ) then
                        MEMDATAOut <= MEMDATA_rd_flash(31 downto 16) & HWDATA(15 downto 0);
                     else
                        MEMDATAOut <= HWDATA(31 downto 16) & MEMDATA_rd_flash(15 downto 0);
                     end if;
                  elsif (HsizeReg = SZ_BYTE) then
                     if(HaddrReg (1 downto 0) = "00" ) then
                        MEMDATAOut <= MEMDATA_rd_flash(31 downto 8) & HWDATA(7 downto 0);
                     elsif (HaddrReg (1 downto 0) = "01") then
                        MEMDATAOut <= MEMDATA_rd_flash(31 downto 16) & HWDATA(15 downto 8) & MEMDATA_rd_flash(7 downto 0);
                     elsif (HaddrReg (1 downto 0) = "10") then
                        MEMDATAOut <= MEMDATA_rd_flash(31 downto 24) & HWDATA(23 downto 16) & MEMDATA_rd_flash(15 downto 0);
                     else
                        MEMDATAOut <= HWDATA(31 downto 24) & MEMDATA_rd_flash(23 downto 0);
                     end if;
                  else
                     MEMDATAOut <= HWDATA(31 downto 0);
                  end if;
               else
                  MEMDATAOut <= HWDATA(31 downto 0);
               end if;
            end if;
         else
            if ( SYNC_SRAM = 1 ) then
               if ( SRAM_16BIT ='1' ) then
                  if(HsizeReg = SZ_WORD) then     
                     if (ssram_split_trans_next( 0) = '0' ) then
                        MEMDATAOut <=  HWDATA(31 downto 16) & HWDATA(31 downto 16) ;
                     else
                        MEMDATAOut <=  HWDATA(15 downto 0) & HWDATA(15 downto 0) ;
                     end if;
                  elsif(HsizeReg = SZ_HALF) then
                     if(HaddrReg ( 1) = '0'  ) then
                        MEMDATAOut <=  HWDATA(15 downto 0) & HWDATA(15 downto 0) ;
                     else
                        MEMDATAOut <=  HWDATA(31 downto 16) & HWDATA(31 downto 16) ;
                     end if ;
                  else
                     if(HaddrReg ( 1) = '0'  ) then
                        MEMDATAOut <=  HWDATA(15 downto 0) & HWDATA(15 downto 0) ;
                     else
                        MEMDATAOut <=  HWDATA(31 downto 16) & HWDATA(31 downto 16) ;
                     end if;
                  end if;
               elsif(SRAM_8BIT = '1' ) then
                  if(HsizeReg = SZ_WORD) then     
                     if (ssram_split_trans_next = "11") then
                        MEMDATAOut <=  HWDATA(7 downto 0) & HWDATA(7 downto 0) & HWDATA(7 downto 0) & HWDATA(7 downto 0) ;
                     elsif (ssram_split_trans_next =  "10" ) then
                        MEMDATAOut <=  HWDATA(15 downto 8) & HWDATA(15 downto 8) & HWDATA(15 downto 8) & HWDATA(15 downto 8) ;
                     elsif (ssram_split_trans_next =  "01" ) then
                        MEMDATAOut <=  HWDATA(23 downto 16) & HWDATA(23 downto 16) & HWDATA(23 downto 16) & HWDATA(23 downto 16) ;
                     else
                        MEMDATAOut <=  HWDATA(31 downto 24) & HWDATA(31 downto 24) & HWDATA(31 downto 24) & HWDATA(31 downto 24) ;
                     end if;
                  elsif(HsizeReg = SZ_HALF) then
                     if(HaddrReg ( 1) = '0'  ) then
                        if (ssram_split_trans_next( 0) = '1' ) then
                           MEMDATAOut <=  HWDATA(7 downto 0) & HWDATA(7 downto 0) & HWDATA(7 downto 0) & HWDATA(7 downto 0) ;
                        else
                           MEMDATAOut <=  HWDATA(15 downto 8) & HWDATA(15 downto 8) & HWDATA(15 downto 8) & HWDATA(15 downto 8) ;
                        end if;
                     else
                        if (ssram_split_trans_next( 0) = '1' ) then
                           MEMDATAOut <=  HWDATA(23 downto 16) & HWDATA(23 downto 16) & HWDATA(23 downto 16) & HWDATA(23 downto 16);
                        else
                           MEMDATAOut <=  HWDATA(31 downto 24) & HWDATA(31 downto 24) & HWDATA(31 downto 24) & HWDATA(31 downto 24) ;
                        end if;
                     end if;
                  else
                     if(HaddrReg (1 downto 0) =  "00"  ) then
                        MEMDATAOut <=  HWDATA(7 downto 0) & HWDATA(7 downto 0) & HWDATA(7 downto 0) & HWDATA(7 downto 0) ;
                     elsif(HaddrReg (1 downto 0) =  "01"  ) then
                        MEMDATAOut <=  HWDATA(15 downto 8) & HWDATA(15 downto 8) & HWDATA(15 downto 8) & HWDATA(15 downto 8) ;
                     elsif(HaddrReg (1 downto 0) =  "10"  ) then
                        MEMDATAOut <=  HWDATA(23 downto 16) & HWDATA(23 downto 16) & HWDATA(23 downto 16) & HWDATA(23 downto 16);
                     else
                        MEMDATAOut <=  HWDATA(31 downto 24) & HWDATA(31 downto 24) & HWDATA(31 downto 24) & HWDATA(31 downto 24) ;
                     end if;
                  end if;
               else
                  MEMDATAOut <= HWDATA(31 downto 0);
               end if;
            else
               if ( SRAM_16BIT ='1' ) then
                  if(HsizeReg = SZ_WORD) then    
                     if (trans_split_count( 0) = '1' ) then
                        MEMDATAOut <=  HWDATA(31 downto 16) & HWDATA(31 downto 16) ;
                     else
                        MEMDATAOut <=  HWDATA(15 downto 0) & HWDATA(15 downto 0) ;
                     end if;
                  elsif(HsizeReg = SZ_HALF) then 
                     if(HaddrReg ( 1) = '0'  ) then
                        MEMDATAOut <=  HWDATA(15 downto 0) & HWDATA(15 downto 0) ;
                     else
                        MEMDATAOut <=  HWDATA(31 downto 16) & HWDATA(31 downto 16) ;
                     end if;
                  else
                     if(HaddrReg ( 1) = '0'  ) then
                        MEMDATAOut <=  HWDATA(15 downto 0) & HWDATA(15 downto 0) ;
                     else
                        MEMDATAOut <=  HWDATA(31 downto 16) & HWDATA(31 downto 16) ;
                     end if;
                  end if;
               elsif(SRAM_8BIT = '1' ) then
                  if(HsizeReg = SZ_WORD) then  
                     if (trans_split_count =  "00" ) then
                        MEMDATAOut <=  HWDATA(7 downto 0) & HWDATA(7 downto 0) & HWDATA(7 downto 0) & HWDATA(7 downto 0) ;
                     elsif (trans_split_count =  "01" ) then
                        MEMDATAOut <=  HWDATA(15 downto 8) & HWDATA(15 downto 8) & HWDATA(15 downto 8) & HWDATA(15 downto 8) ;
                     elsif (trans_split_count =  "10" ) then
                        MEMDATAOut <=  HWDATA(23 downto 16) & HWDATA(23 downto 16) & HWDATA(23 downto 16) & HWDATA(23 downto 16) ;
                     else
                        MEMDATAOut <=  HWDATA(31 downto 24) & HWDATA(31 downto 24) & HWDATA(31 downto 24) & HWDATA(31 downto 24) ;
                     end if;
                  elsif(HsizeReg = SZ_HALF) then 
                     if(HaddrReg ( 1) = '0'  ) then
                        if (trans_split_count( 0) = '0' ) then
                           MEMDATAOut <=  HWDATA(7 downto 0) & HWDATA(7 downto 0) & HWDATA(7 downto 0) & HWDATA(7 downto 0) ;
                        else
                           MEMDATAOut <=  HWDATA(15 downto 8) & HWDATA(15 downto 8) & HWDATA(15 downto 8) & HWDATA(15 downto 8) ;
                        end if;
                     else
                        if (trans_split_count( 0) = '0' ) then
                           MEMDATAOut <=  HWDATA(23 downto 16) & HWDATA(23 downto 16) & HWDATA(23 downto 16) & HWDATA(23 downto 16);
                        else
                           MEMDATAOut <=  HWDATA(31 downto 24) & HWDATA(31 downto 24) & HWDATA(31 downto 24) & HWDATA(31 downto 24) ;
                        end if;
                     end if;
                  else
                     if(HaddrReg (1 downto 0) =  "00"  ) then
                        MEMDATAOut <=  HWDATA(7 downto 0) & HWDATA(7 downto 0) & HWDATA(7 downto 0) & HWDATA(7 downto 0) ;
                     elsif(HaddrReg (1 downto 0) =  "01"  ) then
                        MEMDATAOut <=  HWDATA(15 downto 8) & HWDATA(15 downto 8) & HWDATA(15 downto 8) & HWDATA(15 downto 8) ;
                     elsif(HaddrReg (1 downto 0) =  "10"  ) then
                        MEMDATAOut <=  HWDATA(23 downto 16) & HWDATA(23 downto 16) & HWDATA(23 downto 16) & HWDATA(23 downto 16);
                     else
                        MEMDATAOut <=  HWDATA(31 downto 24) & HWDATA(31 downto 24) & HWDATA(31 downto 24) & HWDATA(31 downto 24) ;
                     end if;
                  end if;
               else
                  MEMDATAOut <= HWDATA(31 downto 0);
               end if;
            end if;
         end if;
      else
         MEMDATAOut <= (others => '0');
      end if;
   end process;

    --------------------------------------------------------------------------------
    -- StateName machine controlling memory access
    --------------------------------------------------------------------------------
   process (
      MemCntlState,
      Valid,
      Valid_d,
      HselFlash,
      HselFlash_d,
      HWRITE,
      HWRITE_d,
      HSIZE,
      HSIZE_d,
      CurrentWait,
      HsizeReg,
      HselFlashReg,
      HselSramReg,
      HwriteReg,
      iHready,
      SRAM_16BIT,
      SRAM_8BIT,
      next_transaction_done,
      ssram_read_buzy_next,
      ssram_read_buzy_next_d,
      ssram_split_trans_next,
      NUM_WS_SRAM_WRITE,
      NUM_WS_SRAM_READ,
      pipeline_rd_d1,
      trans_split_count,
      wr_follow_rd_next
   )
   begin
      NextMemCntlState    <= MemCntlState;
      NextMEMDATAOEN      <= '0';
      NextSelHaddrReg     <= '1';
      LoadWSCounter       <= '0';
      WSCounterLoadVal    <= ZERO;
      NextFLASHCSN        <= '1';
      NextFLASHWEN        <= '1';
      NextFLASHOEN        <= '1';
      NextSRAMCSN         <= '1';
      NextSRAMWEN         <= '1';
      NextSRAMOEN         <= '1';
      HoldHreadyLow       <= '0';
      trans_split_reset   <= '0' ;
      transaction_done    <= '0';
      wr_follow_rd        <= '0';
      ssram_split_trans_load    <= '0';
      ssram_split_trans_en<= '0';
      ssram_split_trans   <= "00";
      ssram_read_buzy     <= '0';
      pipeline_rd         <= '0';

      trans_split_en            <= '0';

      case MemCntlState is
         when ST_IDLE =>
            StateName        <= X"49444c45";   -- For debug - ASCII value for "IDLE"
            NextMEMDATAOEN   <= '0';           -- Drive memory data bus if remaining in IDLE state
            NextSelHaddrReg  <= '0';           -- Drive memory address bus with registered address
                                               --  to prevent unnecessary toggling of address lines
            trans_split_reset<= '1';
               if (Valid = '1') then
                  NextMemCntlState <= ST_IDLE_1;
                  HoldHreadyLow    <= '1';
                  NextSelHaddrReg  <= '1';
               else
                  NextMemCntlState <= ST_IDLE;
               end if;
         when ST_IDLE_1 =>
            StateName           <= X"49444c45";   -- For debug - ASCII value for "IDLE"
            NextMEMDATAOEN      <= '0';           -- Drive memory data bus if remaining in IDLE state
            NextSelHaddrReg     <= '1';           -- Drive memory address bus with registered address
                                                  --  to prevent unnecessary toggling of address lines
            trans_split_reset   <= '1';
            if (Valid_d = '1') then
               if (HselFlash_d = '1') then
                  NextFLASHCSN    <= '0';
                  NextSelHaddrReg <= '1';
                  if (HWRITE_d = '1') then
                     if((HSIZE_d = "000" and (FLASH_DQ_SIZE = 32 or FLASH_DQ_SIZE = 16)) or (HSIZE_d =  "001" and (FLASH_DQ_SIZE = 32 ))) then
                        NextMemCntlState <= ST_FLASH_RD;
                        LoadWSCounter    <= '1';
                        WSCounterLoadVal <= to_stdlogicvector(NUM_WS_FLASH_READ,5);
                        NextMEMDATAOEN   <= '1'; 
                        wr_follow_rd     <= '1';
                     else
                        NextMemCntlState <= ST_FLASH_WR;
                        LoadWSCounter    <= '1';
                        WSCounterLoadVal <= to_stdlogicvector(NUM_WS_FLASH_WRITE,5);
                     end if;
                  else
                     NextMemCntlState <= ST_FLASH_RD;
                     LoadWSCounter    <= '1';
                     WSCounterLoadVal <= to_stdlogicvector(NUM_WS_FLASH_READ,5);
                     NextMEMDATAOEN   <= '1'; -- negate
                  end if;
               else
                  if (SYNC_SRAM = 1) then
                     if (HWRITE_d = '1') then
                        NextMemCntlState <= ST_SSRAM_WR;
                        NextSRAMCSN      <= '0';
                        NextSRAMWEN      <= '0';
                        NextSelHaddrReg  <= '1';
                        if ( (SRAM_16BIT = '1' and (HSIZE_d = SZ_WORD)) or (SRAM_8BIT ='1' and (HSIZE_d = SZ_HALF))) then
                           ssram_split_trans <=  "01";
                           ssram_split_trans_load  <=  '1';
                           HoldHreadyLow     <=  '1';
                        elsif (((SRAM_8BIT= '1') and (HSIZE_d = SZ_WORD))) then
                           ssram_split_trans <= "11";
                           ssram_split_trans_load  <= '1';
                           HoldHreadyLow     <= '1';
                        else
                           LoadWSCounter     <= '1';
                           WSCounterLoadVal  <= ZERO;
                           transaction_done  <= '1';
                        end if;
                     else
                        if (FLOW_THROUGH = 1) then
                           NextMemCntlState <= ST_SSRAM_RD2;
                        else
                           NextMemCntlState <= ST_SSRAM_RD1;
                        end if;
                        if (((SRAM_16BIT='1') and (HSIZE_d = SZ_WORD)) or ((SRAM_8BIT='1') and (HSIZE_d = SZ_HALF))) then
                           ssram_split_trans<= "01";
                           ssram_split_trans_load <= '1';
                           NextMEMDATAOEN   <= '1'; 
                           NextSRAMCSN      <= '0';
                           NextSelHaddrReg  <= '1';
                           HoldHreadyLow    <= '1';
                        elsif ((SRAM_8BIT='1') and (HSIZE_d = SZ_WORD)) then
                           ssram_split_trans<= "11";
                           ssram_split_trans_load <= '1';
                           NextMEMDATAOEN   <= '1'; 
                           NextSRAMCSN      <= '0';
                           NextSelHaddrReg  <= '1';
                           HoldHreadyLow    <= '1';
                        else
                           NextMEMDATAOEN   <= '1'; 
                           NextSRAMCSN      <= '0';
                           NextSelHaddrReg  <= '1';
                           LoadWSCounter    <= '1';
                           WSCounterLoadVal <= ONE;
                           ssram_read_buzy  <= '1';   
                        end if;
                     end if;
                  else -- asynchronous SRAM
                     if (HWRITE_d = '1') then
                        NextMemCntlState <= ST_ASRAM_WR;
                        NextSRAMCSN      <= '0';
                        NextSelHaddrReg  <= '1';
                        LoadWSCounter    <= '1';
                        WSCounterLoadVal <= NUM_WS_SRAM_WRITE;
                     else
                        NextMemCntlState <= ST_ASRAM_RD;
                        NextMEMDATAOEN   <= '1'; -- negate
                        NextSRAMCSN      <= '0';
                        NextSelHaddrReg  <= '1';
                        LoadWSCounter    <= '1';
                        WSCounterLoadVal <= NUM_WS_SRAM_READ;
                     end if;
                  end if;
               end if;
            else
               NextMemCntlState <= ST_IDLE_1;
               NextSelHaddrReg  <= '0';
               wr_follow_rd     <= '0';      
            end if;

         when ST_FLASH_WR =>
            StateName <= X"465f5752"; -- For debug - ASCII value for "F_WR"
            NextFLASHCSN <= '0';
            NextFLASHWEN <= '0';
            if (CurrentWait = ZERO) then
               if ((((FLASH_DQ_SIZE = 16) and (HsizeReg = SZ_WORD)) or ((FLASH_DQ_SIZE = 8) and (HsizeReg = SZ_HALF))) and (trans_split_count(0) ='0') ) then
                  HoldHreadyLow    <= '1';
                  trans_split_en         <= '1';
                  NextFLASHWEN     <= '1';
                  NextMemCntlState <= ST_FLASH_WR;
                  LoadWSCounter    <= '1';
                  WSCounterLoadVal <= to_stdlogicvector(NUM_WS_FLASH_WRITE,5);
               elsif ((FLASH_DQ_SIZE = 8 and (HsizeReg = SZ_WORD)) and (trans_split_count /="11")) then
                  HoldHreadyLow    <= '1';   
                  trans_split_en         <= '1';
                  NextFLASHWEN     <= '1';
                  NextMemCntlState <= ST_FLASH_WR;
                  LoadWSCounter    <= '1';
                  WSCounterLoadVal <= to_stdlogicvector(NUM_WS_FLASH_WRITE,5);
               else
                  NextFLASHCSN     <= '1';
                  NextFLASHWEN     <= '1';
                  if (Valid = '1') then
                     trans_split_reset  <= '1';
                     if (HselFlash = '1') then
                        NextFLASHCSN <= '0';
                        if (HWRITE = '1') then
                           if((HSIZE = "000" and (FLASH_DQ_SIZE = 32 or FLASH_DQ_SIZE = 16)) or (HSIZE = "001" and (FLASH_DQ_SIZE = 32 ))) then
                              NextMemCntlState <= ST_FLASH_RD;
                              LoadWSCounter    <= '1';
                              WSCounterLoadVal <= to_stdlogicvector(NUM_WS_FLASH_READ,5);
                              NextMEMDATAOEN   <= '1';
                              wr_follow_rd     <= '1';
                           else
                              NextMemCntlState <= ST_FLASH_WR;
                              LoadWSCounter    <= '1';
                              WSCounterLoadVal <= to_stdlogicvector(NUM_WS_FLASH_WRITE,5);
                           end if;
                        else
                           NextMemCntlState <= ST_FLASH_RD;
                           NextMEMDATAOEN   <= '1';
                           LoadWSCounter    <= '1';
                           WSCounterLoadVal <= to_stdlogicvector(NUM_WS_FLASH_READ,5);
                        end if;
                     else
                        if (SYNC_SRAM = 1) then
                           NextMemCntlState <= ST_WAIT;
                           LoadWSCounter    <= '1';
                           WSCounterLoadVal <= MAX_WAIT;
                        else
                           NextMemCntlState <= ST_WAIT1;
                           LoadWSCounter    <= '1';
                           WSCounterLoadVal <= MAX_WAIT;
                        end if;
                     end if;
                  else
                     NextMemCntlState <= ST_IDLE;
                  end if;
               end if;
            elsif(CurrentWait = ONE) then
               if (wr_follow_rd_next = '1') then
                  wr_follow_rd <= '1';
               end if;
               if ((FLASH_DQ_SIZE = 8 and (HsizeReg = SZ_WORD)) and (trans_split_count /="11")) then
                  HoldHreadyLow <= '1';
               elsif (((FLASH_DQ_SIZE = 16 and (HsizeReg = SZ_WORD)) or (FLASH_DQ_SIZE = 8 and (HsizeReg = SZ_HALF))) and (trans_split_count(0) = '0') ) then
                  HoldHreadyLow <= '1';
               end if;
            elsif(wr_follow_rd_next ='1') then
               wr_follow_rd <= '1';
            end if;

         when ST_FLASH_RD =>
            StateName      <= X"465f5244"; -- For debug - ASCII value for "F_RD"
            NextFLASHCSN   <= '0';
            NextFLASHOEN   <= '0';
            NextMEMDATAOEN <= '1'; -- negate
            if (CurrentWait = ZERO) then
               if (((FLASH_DQ_SIZE = 16 and (HsizeReg = SZ_WORD)) or (FLASH_DQ_SIZE = 8 and (HsizeReg = SZ_HALF))) and (trans_split_count(0) = '0')) then
                  HoldHreadyLow    <= '1';
                  NextMemCntlState <= ST_FLASH_RD;
                  LoadWSCounter    <= '1';
                  WSCounterLoadVal <= to_stdlogicvector(NUM_WS_FLASH_READ,5);
                  trans_split_en         <= '1';
               elsif ((FLASH_DQ_SIZE = 8 and (HsizeReg = SZ_WORD)) and (trans_split_count /="11")) then
                  HoldHreadyLow    <= '1';
                  NextMemCntlState <= ST_FLASH_RD;
                  LoadWSCounter    <= '1';
                  WSCounterLoadVal <= to_stdlogicvector(NUM_WS_FLASH_READ,5);
                  trans_split_en         <= '1';
               elsif (wr_follow_rd_next ='1') then
                  HoldHreadyLow    <= '1';
                  wr_follow_rd     <= '1';
                  NextMemCntlState <= ST_WAIT;
                  LoadWSCounter    <= '1';
                  WSCounterLoadVal <= MAX_WAIT;
               else
                  NextFLASHCSN <= '1';
                  if (Valid ='1') then
                     trans_split_reset <= '1';
                     if (HselFlash = '1') then
                        NextFLASHCSN   <= '0';
                        if (HWRITE ='1') then
                           NextMemCntlState <= ST_WAIT;
                           LoadWSCounter    <= '1';
                           WSCounterLoadVal <= MAX_WAIT;
                        else
                           NextMemCntlState <= ST_FLASH_RD;
                           LoadWSCounter    <= '1';
                           WSCounterLoadVal <= to_stdlogicvector(NUM_WS_FLASH_READ,5);
                        end if;
                     else
                        if (SYNC_SRAM = 1) then
                           NextMemCntlState <= ST_WAIT;
                           LoadWSCounter    <= '1';
                           WSCounterLoadVal <= MAX_WAIT;
                        else
                           NextMemCntlState <= ST_WAIT1;
                           LoadWSCounter    <= '1';
                           WSCounterLoadVal <= MAX_WAIT;
                        end if;
                     end if;
                  else
                     NextMemCntlState <= ST_IDLE;
                  end if;
               end if;
            elsif(CurrentWait = ONE) then
               if (wr_follow_rd_next = '1') then
                  wr_follow_rd  <= '1';
                  HoldHreadyLow <= '1'; 
               end if;
               if ((FLASH_DQ_SIZE = 8 and (HsizeReg = SZ_WORD)) and (trans_split_count /= "11")) then
                  HoldHreadyLow <= '1';
               elsif (((FLASH_DQ_SIZE = 16 and (HsizeReg = SZ_WORD)) or (FLASH_DQ_SIZE =8 and (HsizeReg = SZ_HALF))) and (trans_split_count(0) ='0')) then
                  HoldHreadyLow <= '1';
               end if;
            elsif(wr_follow_rd_next = '1') then
               wr_follow_rd <= '1';
            end if;
         
         when ST_ASRAM_WR =>
            StateName        <= X"41535752"; -- For debug - ASCII value for "ASWR"
            NextSRAMCSN      <= '0';
            NextSRAMWEN      <= '0';
            transaction_done <= next_transaction_done;
            if (CurrentWait = ZERO) then
               NextSRAMCSN <= '1';
               NextSRAMWEN <= '1';
               if (((SRAM_16BIT = '1' and (HsizeReg = SZ_WORD)) or (SRAM_8BIT= '1' and (HsizeReg = SZ_HALF))) and (trans_split_count(0) /= '1')) then
                  NextSRAMCSN      <= '0';
                  trans_split_en         <= '1';
                  HoldHreadyLow    <= '1';
                  NextMemCntlState <= ST_ASRAM_WR;
                  LoadWSCounter    <= '1';
                  WSCounterLoadVal <= NUM_WS_SRAM_WRITE;
                  transaction_done <= '1';
               elsif ((SRAM_8BIT= '1' and (HsizeReg = SZ_WORD)) and (trans_split_count /= "11")) then
                  NextSRAMCSN      <= '0';
                  trans_split_en         <= '1';
                  HoldHreadyLow    <= '1';
                  NextMemCntlState <= ST_ASRAM_WR;
                  LoadWSCounter    <= '1';
                  WSCounterLoadVal <= NUM_WS_SRAM_WRITE;
                  transaction_done <= '1';
               else
                  if (Valid = '1') then
                     if (HselFlash = '1') then
                        NextFLASHCSN <= '0';
                        if (HWRITE = '1') then
                           if((HSIZE = "000" and (FLASH_DQ_SIZE = 32 or FLASH_DQ_SIZE = 16)) or (HSIZE = "001" and (FLASH_DQ_SIZE = 32 ))) then
                              NextMemCntlState <= ST_FLASH_RD;
                              LoadWSCounter    <= '1';
                              WSCounterLoadVal <= to_stdlogicvector(NUM_WS_FLASH_READ,5);
                              NextMEMDATAOEN   <= '1';
                              wr_follow_rd     <= '1';
                           else
                              NextMemCntlState <= ST_FLASH_WR;
                              LoadWSCounter    <= '1';
                              WSCounterLoadVal <= to_stdlogicvector(NUM_WS_FLASH_WRITE,5);
                             trans_split_reset <= '1';
                           end if;
                        else
                           NextMemCntlState <= ST_FLASH_RD;
                           NextMEMDATAOEN   <= '1';
                           LoadWSCounter    <= '1';
                           WSCounterLoadVal <= to_stdlogicvector(NUM_WS_FLASH_READ,5);
                           trans_split_reset<= '1';
                        end if;
                     else 
                        if(next_transaction_done = '0') then
                           transaction_done <= '1' ;
                           if (HWRITE ='1') then
                              NextMemCntlState <= ST_ASRAM_WR;
                              NextSRAMCSN      <= '0';
                              NextSRAMWEN      <= '1';
                              LoadWSCounter    <= '1';
                              WSCounterLoadVal <= NUM_WS_SRAM_WRITE;
                           else
                              trans_split_reset <= '1';
                              NextMemCntlState  <= ST_ASRAM_RD;
                              NextMEMDATAOEN    <= '1';
                              LoadWSCounter     <= '1';
                              NextSRAMCSN       <= '0';
                              WSCounterLoadVal  <= NUM_WS_SRAM_READ;
                           end if;
                        else
                           NextSRAMCSN      <= '1';
                           transaction_done <= '0' ;
                           NextMemCntlState <= ST_WAIT;
                           LoadWSCounter    <= '1';
                           WSCounterLoadVal <= MAX_WAIT;
                        end if;
                     end if;
                  else
                     NextMemCntlState <= ST_IDLE;
                     NextSRAMCSN      <= '1';
                  end if;
               end if;
            elsif(CurrentWait = ONE) then
               transaction_done <= '1' ;
               if ((((SRAM_16BIT= '1' and (HsizeReg = SZ_WORD)) or (SRAM_8BIT ='1' and (HsizeReg = SZ_HALF))) and (trans_split_count(0) /= '1')) or ((SRAM_8BIT ='1' and (HsizeReg = SZ_WORD)) and (trans_split_count /= "11"))) then
                  HoldHreadyLow <= '1';
               else
                  HoldHreadyLow <= '0';
               end if;
               if (wr_follow_rd_next ='1') then
                  wr_follow_rd <='1';
               end if;
            else
               if (wr_follow_rd_next ='1') then
                  wr_follow_rd <='1';
               end if;
            end if;
         
         when ST_ASRAM_RD =>
            StateName        <= X"41535244"; -- For debug - ASCII value for "ASRD"
            NextSRAMCSN      <= '0';
            NextSRAMOEN      <= '0';
            NextMEMDATAOEN   <= '1'; -- negate
            transaction_done <= next_transaction_done;
            if (CurrentWait = ZERO) then 
               if (((SRAM_16BIT ='1' and (HsizeReg = SZ_WORD)) or (SRAM_8BIT ='1' and (HsizeReg = SZ_HALF))) and (trans_split_count(0) /= '1') ) then
                  trans_split_en         <= '1';
                  HoldHreadyLow    <= '1';
                  NextMemCntlState <= ST_ASRAM_RD;
                  LoadWSCounter    <= '1';
                  transaction_done <= '1' ;
                  WSCounterLoadVal <= NUM_WS_SRAM_READ;
               elsif (((SRAM_8BIT= '1' and (HsizeReg = SZ_WORD))) and (trans_split_count /= "11")) then
                  trans_split_en         <= '1';
                  HoldHreadyLow    <= '1';
                  NextMemCntlState <= ST_ASRAM_RD;
                  LoadWSCounter    <= '1';
                  WSCounterLoadVal <= NUM_WS_SRAM_READ;
                  transaction_done <= '1';
               else
                  NextSRAMCSN <= '1';
                  if (Valid = '1') then
                     trans_split_reset <= '1';
                     if (HselFlash ='1') then
                        NextMemCntlState <= ST_WAIT;
                        LoadWSCounter    <= '1';
                        WSCounterLoadVal <= MAX_WAIT;
                     else
                        if(next_transaction_done = '0') then
                           transaction_done <= '1';
                           NextSRAMCSN      <= '0';
                           if (HWRITE ='1') then
                              NextMemCntlState <= ST_WAIT;
                              LoadWSCounter    <= '1';
                              WSCounterLoadVal <= MAX_WAIT;
                           else
                              NextMemCntlState <= ST_ASRAM_RD;
                              NextSelHaddrReg  <= '1';
                              LoadWSCounter    <= '1';
                              WSCounterLoadVal <= NUM_WS_SRAM_READ ;
                           end if;
                        else
                           NextSRAMCSN      <= '1';
                           transaction_done <= '0' ;
                           NextMemCntlState <= ST_WAIT;
                           LoadWSCounter    <= '1';
                           WSCounterLoadVal <= MAX_WAIT;
                        end if;
                     end if;
                  else
                     NextMemCntlState <= ST_IDLE;
                     NextSRAMCSN      <= '1';
                  end if;
               end if; 
            elsif(CurrentWait = ONE) then
               transaction_done <= '1' ;
               if ((((SRAM_16BIT='1' and (HsizeReg = SZ_WORD)) or (SRAM_8BIT='1' and (HsizeReg = SZ_HALF))) and (trans_split_count(0) /= '1')) or ((SRAM_8BIT='1' and (HsizeReg = SZ_WORD)) and (trans_split_count /="11"))) then
                  HoldHreadyLow <= '1';
               else
                  HoldHreadyLow <= '0';
               end if;
            end if;

         when ST_SSRAM_WR =>
            StateName        <= X"53535752"; -- For debug - ASCII value for "SSWR"
            transaction_done <= next_transaction_done;
            if(ssram_split_trans_next = "00" ) then
               if (Valid = '1') then
                  if (HselFlash ='1') then
                     if (SHARED_RW = 1) then
                        NextMemCntlState <= ST_WAIT;
                        LoadWSCounter    <= '1';
                        WSCounterLoadVal <= MAX_WAIT;
                     else
                        NextFLASHCSN <= '0';
                        if (HWRITE = '1') then
                           if((HSIZE = "000" and (FLASH_DQ_SIZE = 32 or FLASH_DQ_SIZE = 16)) or (HSIZE = "001" and (FLASH_DQ_SIZE = 32 ))) then
                              NextMemCntlState <= ST_FLASH_RD;
                              LoadWSCounter    <= '1';
                              WSCounterLoadVal <= to_stdlogicvector(NUM_WS_FLASH_READ,5);
                              NextMEMDATAOEN   <= '1';
                              wr_follow_rd     <= '1';
                           else
                              NextMemCntlState <= ST_FLASH_WR;
                              LoadWSCounter    <= '1';
                              WSCounterLoadVal <= to_stdlogicvector(NUM_WS_FLASH_WRITE,5);
                              trans_split_reset<= '1';
                           end if;
                        else
                           NextMemCntlState <= ST_FLASH_RD;
                           NextMEMDATAOEN   <= '1';
                           LoadWSCounter    <= '1';
                           WSCounterLoadVal <= to_stdlogicvector(NUM_WS_FLASH_READ,5);
                           trans_split_reset<= '1';
                        end if;
                     end if;
                  else
                     if(next_transaction_done = '0') then
                        transaction_done  <= '1' ;
                        if (HWRITE ='1') then
                           NextMemCntlState <= ST_WAIT;
                           NextSRAMCSN      <= '1';
                           NextSRAMWEN      <= '0';
                           HoldHreadyLow    <= '1';
                           LoadWSCounter    <= '1';
                           WSCounterLoadVal <= ZERO;
                        else
                           NextMemCntlState <= ST_WAIT;
                           NextMEMDATAOEN   <= '1';
                           NextSRAMCSN      <= '1';
                           NextSRAMWEN      <= '1';
                           LoadWSCounter    <= '1';
                           WSCounterLoadVal <= ONE;
                        end if;
                     else
                        NextSRAMCSN      <= '1';
                        transaction_done <= '0' ;
                        NextMemCntlState <= ST_WAIT;
                        LoadWSCounter    <= '1';
                        WSCounterLoadVal <= MAX_WAIT;
                     end if; 
                  end if;
               else
                  NextMemCntlState <= ST_IDLE;
                  NextSRAMCSN      <= '1';
                  NextSRAMWEN      <= '1';
               end if;
            else
               NextMemCntlState <= ST_SSRAM_WR;
               NextSRAMCSN      <= '0';
               NextSRAMWEN      <= '0';
               NextSelHaddrReg  <= '1';
               LoadWSCounter    <= '1';
               WSCounterLoadVal <= ZERO;
               ssram_split_trans_en   <= '1';
               if(ssram_split_trans_next = "01") then
                  HoldHreadyLow  <= '0';
               else
                  HoldHreadyLow  <= '1';
               end if;
            end if;

         when ST_SSRAM_RD1 =>
              StateName       <= X"53535231"; -- For debug - ASCII value for "SSR1"
              NextMemCntlState<= ST_SSRAM_RD2;
              NextMEMDATAOEN  <= '1'; -- negate
              NextSRAMCSN     <= '0';
              NextSelHaddrReg <= '1';
              HoldHreadyLow   <= '1';
              ssram_read_buzy <= '1';
              pipeline_rd            <= '1';
              NextSRAMOEN     <= '0';  

         when ST_SSRAM_RD2 =>
            StateName        <= X"53535232"; -- For debug - ASCII value for "SSR2"
            NextMEMDATAOEN   <= '1'; -- negate
            NextSRAMOEN      <= '0';
            transaction_done <= next_transaction_done;
            if(ssram_split_trans_next = "00" ) then
               if (Valid = '1') then
                  if (HselFlash = '1') then
                     NextMemCntlState <= ST_WAIT;
                     LoadWSCounter    <= '1';
                     WSCounterLoadVal <= MAX_WAIT;
                  else
                     if(next_transaction_done = '0') then
                        transaction_done <= '1' ;
                        if (HWRITE = '1') then
                           NextMemCntlState <= ST_WAIT;
                           NextSRAMCSN      <= '1';
                           NextSelHaddrReg  <= '1';
                           LoadWSCounter    <= '1';
                           WSCounterLoadVal <= ZERO;
                           HoldHreadyLow    <= '1';
                        else
                           NextMemCntlState <= ST_WAIT;
                           NextSRAMCSN      <= '1';
                           NextSelHaddrReg  <= '0';
                           LoadWSCounter    <= '1';
                           WSCounterLoadVal <= ZERO;
                           HoldHreadyLow    <= '1';
                        end if;
                     else
                        NextSRAMCSN      <= '1';
                        transaction_done <= '0' ;
                        NextMemCntlState <= ST_WAIT;
                        LoadWSCounter    <= '1';
                        WSCounterLoadVal <= MAX_WAIT;
                     end if;
                  end if;
               elsif(ssram_read_buzy_next ='1') then
                  NextMemCntlState <= ST_SSRAM_RD2;
                  NextSRAMCSN      <= '0';
                  LoadWSCounter    <= '1';
                  WSCounterLoadVal <= ONE;
               elsif(ssram_read_buzy_next_d ='1') then
                  NextMemCntlState <= ST_SSRAM_RD2;
                  NextSRAMCSN      <= '0';
                  LoadWSCounter    <= '1';
                  if(FLOW_THROUGH = 0) then
                     WSCounterLoadVal <= ZERO;
                  else
                     WSCounterLoadVal <= ONE;
                  end if;
               else
                  NextMemCntlState <= ST_IDLE;
                  NextSRAMCSN      <= '1';
               end if;
            else
               if(FLOW_THROUGH = 0 and ssram_split_trans_next /="00" ) then
                  if(pipeline_rd_d1 ='1') then
                     ssram_split_trans_en    <= '0';
                     HoldHreadyLow     <= '1';
                     NextMemCntlState  <= ST_SSRAM_RD2;
                     NextSRAMCSN       <= '0';
                  else
                     ssram_split_trans_en    <= '1';
                     HoldHreadyLow     <= '1';
                     NextMemCntlState  <= ST_SSRAM_RD1;
                     NextSRAMCSN       <= '0';
                  end if;
               else
                  ssram_split_trans_en    <= '0';
                  LoadWSCounter     <= '1';
                  WSCounterLoadVal  <= ONE;
                  NextMemCntlState  <= ST_WAIT;
                  NextSRAMCSN       <= '0';
                  ssram_read_buzy   <= '1';
               end if;
            end if;
         
         when ST_WAIT1 =>
            StateName         <= X"57414954"; -- For debug - ASCII value for "WAIT"
            NextMemCntlState  <= ST_WAIT;
            transaction_done  <= '0';
            trans_split_reset <= '1';
                    
         when ST_WAIT =>
            StateName        <= X"57414954"; -- For debug - ASCII value for "WAIT"
            transaction_done <= '0';
            trans_split_reset<= '1';
--            NextSRAMCSN      <= '1';
            HoldHreadyLow    <= '0';
            if(ssram_read_buzy_next = '1') then
               NextMemCntlState        <= ST_SSRAM_RD2;
               HoldHreadyLow           <= '1';
               NextSRAMCSN             <= '0';
               NextSRAMOEN             <= '0';
               ssram_split_trans_en    <= '1';
            else 
               if(HselFlashReg = '1') then
                  NextFLASHCSN <= '0';
                  NextSRAMCSN  <= '1';  
                  if (HwriteReg = '1' or wr_follow_rd_next = '1' ) then
                     if (wr_follow_rd_next = '1') then
                        NextMemCntlState <= ST_FLASH_WR;
                        NextMEMDATAOEN   <= '0';
                        LoadWSCounter    <= '1';
                        WSCounterLoadVal <= to_stdlogicvector(NUM_WS_FLASH_WRITE,5);
                        wr_follow_rd     <= '1';
                     elsif((HSIZE_d = "000" and (FLASH_DQ_SIZE = 32 or FLASH_DQ_SIZE = 16)) or (HSIZE_d = "001" and (FLASH_DQ_SIZE = 32 ))) then
                        NextMemCntlState <= ST_FLASH_RD;
                        LoadWSCounter    <= '1';
                        WSCounterLoadVal <= to_stdlogicvector(NUM_WS_FLASH_READ,5);
                        NextMEMDATAOEN   <= '1';
                        wr_follow_rd     <= '1';
                     else
                        NextMemCntlState <= ST_FLASH_WR;
                        NextMEMDATAOEN   <= '0';
                        LoadWSCounter    <= '1';
                        WSCounterLoadVal <= to_stdlogicvector(NUM_WS_FLASH_WRITE,5);
                     end if;
                  else
                     NextMemCntlState <= ST_FLASH_RD;
                     NextMEMDATAOEN   <= '1';
                     LoadWSCounter    <= '1';
                     WSCounterLoadVal <= to_stdlogicvector(NUM_WS_FLASH_READ,5);
                  end if;
               elsif (HselSramReg = '1') then
                  if (SYNC_SRAM = 1) then 
                     if (HwriteReg = '1') then
                        if ( (SRAM_16BIT ='1' and (HsizeReg = SZ_WORD)) or (SRAM_8BIT='1' and (HsizeReg = SZ_HALF))) then
                           ssram_split_trans<= "01";
                           ssram_split_trans_load <= '1';
                           HoldHreadyLow    <= '1';
                           LoadWSCounter    <= '1';
                           WSCounterLoadVal <= ZERO;
                        elsif ((SRAM_8BIT='1' and (HsizeReg = SZ_WORD))) then
                           ssram_split_trans<= "11";
                           ssram_split_trans_load <= '1';
                           HoldHreadyLow    <= '1';
                           LoadWSCounter    <= '1';
                           WSCounterLoadVal <= ZERO;
                        else
                           LoadWSCounter    <= '1';
                           WSCounterLoadVal <= ZERO;
                           transaction_done <= '1';
                        end if;
                        NextMemCntlState <= ST_SSRAM_WR;
                        NextSRAMCSN      <= '0';
                        NextSRAMWEN      <= '0';
                        NextSelHaddrReg  <= '1';
                     else
                        if (FLOW_THROUGH = 1) then
                           NextMemCntlState <= ST_SSRAM_RD2;
                        else
                           NextMemCntlState <= ST_SSRAM_RD1;
                        end if;
                        if ( (SRAM_16BIT ='1' and (HsizeReg = SZ_WORD)) or (SRAM_8BIT='1' and (HsizeReg = SZ_HALF))) then
                           ssram_split_trans<= "01";
                           ssram_split_trans_load <= '1';
                           HoldHreadyLow    <= '1';
                           LoadWSCounter    <= '1';
                           WSCounterLoadVal <= ZERO;
                        elsif ((SRAM_8BIT='1' and (HsizeReg = SZ_WORD))) then
                           ssram_split_trans<= "11";
                           ssram_split_trans_load <= '1';
                           HoldHreadyLow    <= '1';
                           LoadWSCounter    <= '1';
                           WSCounterLoadVal <= ZERO;
                        else
                           LoadWSCounter    <= '1';
                           WSCounterLoadVal <= ONE;
                           transaction_done <= '1';
                           NextMEMDATAOEN   <= '0';
                           ssram_read_buzy  <= '1';
                        end if;
                        NextMEMDATAOEN  <= '1';
                        NextSRAMCSN     <= '0';
                        NextSelHaddrReg <= '1';
                     end if;
                  else
                     if (HwriteReg ='1') then
                        NextMemCntlState <= ST_ASRAM_WR;
                        NextMEMDATAOEN   <= '0';
                        LoadWSCounter    <= '1';
                        NextSRAMCSN      <= '0';
                        WSCounterLoadVal <= NUM_WS_SRAM_WRITE;
                     else
                        NextMemCntlState <= ST_ASRAM_RD;
                        NextMEMDATAOEN   <= '1';
                        LoadWSCounter    <= '1';
                        NextSRAMCSN      <= '0';
                        WSCounterLoadVal <= NUM_WS_SRAM_READ ;
                     end if;
                  end if;
               else 
                  NextMemCntlState <= ST_IDLE;
                  NextSRAMCSN      <= '1';
               end if;
            end if;
         when others =>
            StateName <= X"64656674"; -- For debug - ASCII value for "deft"
            NextMemCntlState <= ST_IDLE;

      end case;
   end process;

    -- Synchronous part of state machine
   process (HCLK, aresetn)
   begin
      if ( aresetn = '0' ) then
         MemCntlState           <= ST_IDLE;
         SelHaddrReg            <= '0';
         iFLASHCSN              <= '1';
         iMEMDATAOEN            <= '0'; -- Driving memory data bus by default
         trans_split_count      <= "00";
         Valid_d                <= '0';
         HselFlash_d            <= '0';
         HWRITE_d               <= '0';
         HSIZE_d                <= "000";
         wr_follow_rd_next      <= '0';
         ssram_read_buzy_next   <= '0';
         ssram_read_buzy_next_d <= '0';
         next_transaction_done  <= '0';
         ssram_split_trans_next <= "00";
         pipeline_rd_d1         <= '0';
         pipeline_rd_d2         <= '0';
      elsif (HCLK'event and HCLK = '1') then
         if (sresetn = '0') then
            MemCntlState           <= ST_IDLE;
            SelHaddrReg            <= '0';
            iFLASHCSN              <= '1';
            iMEMDATAOEN            <= '0'; -- Driving memory data bus by default
            trans_split_count      <= "00";
            Valid_d                <= '0';
            HselFlash_d            <= '0';
            HWRITE_d               <= '0';
            HSIZE_d                <= "000";
            wr_follow_rd_next      <= '0';
            ssram_read_buzy_next   <= '0';
            ssram_read_buzy_next_d <= '0';
            next_transaction_done  <= '0';
            ssram_split_trans_next <= "00";
            pipeline_rd_d1         <= '0';
            pipeline_rd_d2         <= '0';
         else
            MemCntlState          <= NextMemCntlState;
            SelHaddrReg           <= NextSelHaddrReg;
            iFLASHCSN             <= NextFLASHCSN;
            iMEMDATAOEN           <= NextMEMDATAOEN;
            Valid_d               <= Valid;
            HselFlash_d           <= HselFlash;
            HWRITE_d              <= HWRITE;
            HSIZE_d               <= HSIZE;
            wr_follow_rd_next     <= wr_follow_rd;
            ssram_read_buzy_next  <= ssram_read_buzy;
            ssram_read_buzy_next_d<= ssram_read_buzy_next;
            next_transaction_done <= transaction_done;
            pipeline_rd_d1        <= pipeline_rd;
            pipeline_rd_d2        <= pipeline_rd_d1;

            if(ssram_split_trans_load ='1' ) then
               ssram_split_trans_next <= ssram_split_trans ;
            else
               ssram_split_trans_next <= ssram_split_trans_next - ssram_split_trans_en;
            end if;

            if (trans_split_reset = '1') then
               trans_split_count      <= "00";
            else
               trans_split_count      <= trans_split_count  + ('0' & trans_split_en);
            end if;
         end if;
      end if;
   end process;
   
 

xhdlcsn1 : if (NUM_MEMORY_CHIP = 1 ) generate
   process (HCLK, aresetn)
   begin
      if ( aresetn = '0' ) then
         iSRAMCSN(0)        <= '1';
      elsif (HCLK'event and HCLK = '1') then
         if (sresetn = '0') then
            iSRAMCSN(0)        <= '1';
         else
            if(CH0_EN_reg = '1') then
               iSRAMCSN(0)        <= NextSRAMCSN;
            else
               iSRAMCSN(0)        <= '1';
            end if;
         end if;
      end if;
   end process;
end generate ;

xhdlcsn2 : if (NUM_MEMORY_CHIP = 2 ) generate
   process (HCLK, aresetn)
   begin
      if ( aresetn = '0' ) then
         iSRAMCSN(1 downto 0)        <= "11";
      elsif (HCLK'event and HCLK = '1') then
         if (sresetn = '0') then
            iSRAMCSN(1 downto 0)        <= "11";
         else
            if(CH0_EN_reg ='1') then
               iSRAMCSN(0)        <= NextSRAMCSN;
               iSRAMCSN(1)        <= '1';
            elsif (CH1_EN_reg ='1') then
               iSRAMCSN(0)        <= '1';
               iSRAMCSN(1)        <= NextSRAMCSN;
            end if;
         end if;
      end if;
   end process;
end generate ;

xhdlcsn3 : if (NUM_MEMORY_CHIP = 3 ) generate
   process (HCLK, aresetn)
   begin
      if ( aresetn = '0' ) then
         iSRAMCSN(2 downto 0)        <= "111";
      elsif (HCLK'event and HCLK = '1') then
         if (sresetn = '0') then
            iSRAMCSN(2 downto 0)        <= "111";
         else
            if(CH0_EN_reg ='1') then
               iSRAMCSN(0)        <= NextSRAMCSN;
               iSRAMCSN(1)        <= '1';
               iSRAMCSN(2)        <= '1';
            elsif (CH1_EN_reg ='1') then
               iSRAMCSN(0)        <= '1';
               iSRAMCSN(1)        <= NextSRAMCSN;
               iSRAMCSN(2)        <= '1';
            elsif (CH2_EN_reg ='1') then
               iSRAMCSN(0)        <= '1';
               iSRAMCSN(1)        <= '1';
               iSRAMCSN(2)        <= NextSRAMCSN;
            end if;
         end if;
      end if;
   end process;
end generate ;

xhdlcsn4 : if (NUM_MEMORY_CHIP = 4 ) generate
   process (HCLK, aresetn)
   begin
      if ( aresetn = '0' ) then
         iSRAMCSN(3 downto 0)        <= "1111";
      elsif (HCLK'event and HCLK = '1') then
         if (sresetn = '0') then
            iSRAMCSN(3 downto 0)        <= "1111";
         else
            if(CH0_EN_reg ='1') then
               iSRAMCSN(0)        <= NextSRAMCSN;
               iSRAMCSN(1)        <= '1';
               iSRAMCSN(2)        <= '1';
               iSRAMCSN(3)        <= '1';
            elsif (CH1_EN_reg ='1') then
               iSRAMCSN(0)        <= '1';
               iSRAMCSN(1)        <= NextSRAMCSN;
               iSRAMCSN(2)        <= '1';
               iSRAMCSN(3)        <= '1';
            elsif (CH2_EN_reg ='1') then
               iSRAMCSN(0)        <= '1';
               iSRAMCSN(1)        <= '1';
               iSRAMCSN(2)        <= NextSRAMCSN;
               iSRAMCSN(3)        <= '1';
            elsif (CH3_EN_reg ='1') then
               iSRAMCSN(0)        <= '1';
               iSRAMCSN(1)        <= '1';
               iSRAMCSN(2)        <= '1';
               iSRAMCSN(3)        <= NextSRAMCSN;
            end if;
         end if;
      end if;
   end process;
end generate ;


    -- Signals clocked with falling edge of HCLK
   process (HCLK, aresetn)
   begin
      if ( aresetn = '0' ) then
         iFLASHOEN <= '1';
         iFLASHWEN <= '1';
         iSRAMOEN  <= '1';
      elsif (HCLK'event and HCLK = '0') then
         if (sresetn = '0') then
            iFLASHOEN <= '1';
            iFLASHWEN <= '1';
            iSRAMOEN  <= '1';
         else
            iFLASHOEN <= NextFLASHOEN;
            iFLASHWEN <= NextFLASHWEN;
            iSRAMOEN  <= NextSRAMOEN;
         end if;
      end if;
   end process;


    -- Clock SRAM write enable with rising edge of HCLK for sync. SRAM
    GenSSRAM : if (SYNC_SRAM = 1) generate
    begin
        process (HCLK, aresetn)
        begin
            if ( aresetn = '0' ) then
                iSRAMWEN  <= '1';
            elsif (HCLK'event and HCLK = '1') then
              if (sresetn = '0') then
                iSRAMWEN  <= '1';
              else
                iSRAMWEN  <= NextSRAMWEN;
              end if;
            end if;
        end process;
    end generate GenSSRAM;

    -- Clock SRAM write enable with falling edge of HCLK for async. SRAM
    GenASRAM : if (SYNC_SRAM = 0) generate
    begin
        process (HCLK, aresetn)
        begin
            if ( aresetn = '0' ) then
                iSRAMWEN  <= '1';
            elsif (HCLK'event and HCLK = '0') then
              if (sresetn = '0') then
                iSRAMWEN  <= '1';
              else
                iSRAMWEN  <= NextSRAMWEN;
              end if;
            end if;
        end process;
    end generate GenASRAM;


    --------------------------------------------------------------------------------
    -- Memory address mux
    --------------------------------------------------------------------------------
    -- AS: SAR64652 fix
    --process (HselFlashReg, Flash2ndHalf, SelHaddrReg, HaddrReg, HADDR)
   GenMEMADDR_ASYNC : if (SYNC_SRAM = 0) generate
   begin
     process(iFLASHWEN,iSRAMWEN,iSRAMCSN_s,iFLASHCSN,HsizeReg,trans_split_count,HaddrReg,SRAM_16BIT,SRAM_8BIT,SelHaddrReg )
      begin
         if (iFLASHCSN = '0') then
            if (FLASH_DQ_SIZE = 16) then
               if (FLASH_TYPE = 0) then
                  if (HsizeReg = SZ_WORD) then
                     if (trans_split_count(0) = '0') then
                        MEMADDR <= '0' & HaddrReg(27 downto 2) & '0';
                     else
                        MEMADDR <= '0' & HaddrReg(27 downto 2) & '1';
                     end if;
                  else
                     MEMADDR <=  '0'& HaddrReg(27 downto 1);
                  end if;
               else
                  if (HsizeReg = SZ_WORD) then
                     if (trans_split_count(0) = '0') then
                        MEMADDR <=  HaddrReg(27 downto 2) & "00";
                     else
                        MEMADDR <=  HaddrReg(27 downto 2) & "10";
                     end if;
                  else
                     MEMADDR <=  HaddrReg(27 downto 1) & '0';
                  end if;
               end if;
            elsif (FLASH_DQ_SIZE = 8) then
               if (HsizeReg = SZ_WORD) then
                  if (trans_split_count = "00") then
                     MEMADDR <= HaddrReg(27 downto 2) & "00";
                  elsif (trans_split_count ="01") then
                     MEMADDR <= HaddrReg(27 downto 2) & "01";
                  elsif (trans_split_count ="10") then
                     MEMADDR <= HaddrReg(27 downto 2) & "10";
                  elsif (trans_split_count ="11") then
                     MEMADDR <= HaddrReg(27 downto 2) & "11";
                  end if;
               elsif(HsizeReg = SZ_HALF) then
                  if (trans_split_count(0) = '0') then
                     MEMADDR <= HaddrReg(27 downto 1) & '0';
                  elsif (trans_split_count(0) = '1') then
                     MEMADDR <= HaddrReg(27 downto 1) & '1';
                  end if;
               else
                  MEMADDR <= HaddrReg(27 downto 0);
               end if;
            else
             MEMADDR <= "00" & HaddrReg(27 downto 2);
            end if;
         else  -- SRAM access
            if (SelHaddrReg ='1') then
               if (SRAM_16BIT = '1' ) then
                  if (HsizeReg = SZ_WORD) then
                     if (trans_split_count(0) ='0') then
                        MEMADDR <= '0' & HaddrReg(27 downto 2) & '0';
                     else
                        MEMADDR <= '0' & HaddrReg(27 downto 2) & '1';
                     end if;
                  else
                     MEMADDR <= '0' & HaddrReg(27 downto 1);
                  end if;
               elsif(SRAM_8BIT ='1') then
                  if (HsizeReg = SZ_WORD) then
                     if (trans_split_count ="00") then
                        MEMADDR <= HaddrReg(27 downto 2) & "00";
                     elsif (trans_split_count ="01") then
                        MEMADDR <= HaddrReg(27 downto 2) & "01";
                     elsif (trans_split_count ="10") then
                        MEMADDR <= HaddrReg(27 downto 2) & "10";
                     elsif (trans_split_count ="11") then
                        MEMADDR <= HaddrReg(27 downto 2) & "11";
                     end if;
                  elsif(HsizeReg = SZ_HALF) then
                     if (trans_split_count(0) ='0') then
                        MEMADDR <= HaddrReg(27 downto 1) & '0';
                     elsif (trans_split_count(0) ='1') then
                        MEMADDR <= HaddrReg(27 downto 1) & '1';
                     end if;
                  else
                     MEMADDR <= HaddrReg(27 downto 0);
                  end if;
               else
                  MEMADDR <= "00" & HaddrReg(27 downto 2);
               end if;
            else
               MEMADDR <= "00" & HADDR(27 downto 2);
            end if;
         end if;
      end process;
   end generate;

   GenMEMADDR_SYNC : if (SYNC_SRAM = 1) generate
   begin
      process(iFLASHWEN,iSRAMWEN,iSRAMCSN_s,iFLASHCSN,HsizeReg,trans_split_count,HaddrReg,SelHaddrReg,ssram_split_trans_next,SRAM_16BIT,SRAM_8BIT,HADDR )
      begin
         if (iFLASHCSN = '0') then
            if (FLASH_DQ_SIZE = 16) then
               if (FLASH_TYPE = 0) then
                  if (HsizeReg = SZ_WORD) then
                     if (trans_split_count(0) = '0') then
                        MEMADDR <= '0' & HaddrReg(27 downto 2) & '0';
                     else 
                        MEMADDR <= '0' & HaddrReg(27 downto 2) & '1';
                     end if;
                  else
                     MEMADDR <=  '0' & HaddrReg(27 downto 1);
                  end if;
               else
                  if (HsizeReg = SZ_WORD) then
                     if (trans_split_count(0) = '0') then
                        MEMADDR <=  HaddrReg(27 downto 2) & "00";
                     else
                        MEMADDR <=  HaddrReg(27 downto 2) & "10";
                     end if;
                  else
                     MEMADDR <=  HaddrReg(27 downto 1) & '0';
                  end if;
               end if;
            elsif (FLASH_DQ_SIZE = 8) then
               if (HsizeReg = SZ_WORD) then
                  if (trans_split_count = "00") then
                     MEMADDR <= HaddrReg(27 downto 2) & "00";
                  elsif (trans_split_count ="01") then
                     MEMADDR <= HaddrReg(27 downto 2) & "01";
                  elsif (trans_split_count ="10") then
                     MEMADDR <= HaddrReg(27 downto 2) & "10";
                  elsif (trans_split_count ="11") then
                     MEMADDR <= HaddrReg(27 downto 2) & "11";
                  end if;
               elsif(HsizeReg = SZ_HALF) then
                  if (trans_split_count(0) ='0') then
                     MEMADDR <= HaddrReg(27 downto 1) & '0';
                  elsif (trans_split_count(0) ='1') then
                     MEMADDR <= HaddrReg(27 downto 1) & '1';
                  end if;
               else 
                  MEMADDR <= HaddrReg(27 downto 0);
               end if;
            else
               MEMADDR <= "00" & HaddrReg(27 downto 2);
            end if;
         else
            if (SelHaddrReg = '1') then
               if (SRAM_16BIT = '1' ) then
                  if (HsizeReg = SZ_WORD) then
                     if (ssram_split_trans_next(0) ='1') then
                        MEMADDR <= '0'& HaddrReg(27 downto 2)&'0';
                     else
                        MEMADDR <= '0'& HaddrReg(27 downto 2)&'1';
                     end if;
                  else
                     MEMADDR <= '0'& HaddrReg(27 downto 1);
                  end if;
               elsif(SRAM_8BIT ='1') then
                  if (HsizeReg = SZ_WORD) then
                     if (ssram_split_trans_next ="11") then
                        MEMADDR <= HaddrReg(27 downto 2) & "00";
                     elsif (ssram_split_trans_next ="10") then
                        MEMADDR <= HaddrReg(27 downto 2) & "01";
                     elsif (ssram_split_trans_next ="01") then
                        MEMADDR <= HaddrReg(27 downto 2) & "10";
                     elsif (ssram_split_trans_next ="00") then
                        MEMADDR <= HaddrReg(27 downto 2) & "11";
                     end if;
                  elsif(HsizeReg = SZ_HALF) then
                     if (ssram_split_trans_next(0) ='1') then
                        MEMADDR <= HaddrReg(27 downto 1) & '0';
                     elsif (ssram_split_trans_next(0) ='0') then
                        MEMADDR <= HaddrReg(27 downto 1) & '1';
                     end if;
                  else
                     MEMADDR <= HaddrReg(27 downto 0);
                  end if;
               else
                  MEMADDR <= "00" & HaddrReg(27 downto 2);
               end if;
            else
               MEMADDR <= "00" & HADDR(27 downto 2);
            end if;
         end if;
      end process;
   end generate;



xhdlcsn_s_ch1 : if (NUM_MEMORY_CHIP = 1) generate
   iSRAMCSN_s <= iSRAMCSN(0);
end generate;

xhdlcsn_s_ch2 : if (NUM_MEMORY_CHIP = 2) generate
   iSRAMCSN_s <= iSRAMCSN(1) and iSRAMCSN(0);
end generate;

xhdlcsn_s_ch3 : if (NUM_MEMORY_CHIP = 3) generate
   iSRAMCSN_s <= iSRAMCSN(2) and iSRAMCSN(1) and iSRAMCSN(0) ;
end generate;

xhdlcsn_s_ch4 : if (NUM_MEMORY_CHIP = 4) generate
   iSRAMCSN_s <= iSRAMCSN(3) and iSRAMCSN(2) and iSRAMCSN(1) and iSRAMCSN(0) ;
end generate;
  
    --------------------------------------------------------------------------------
    -- Byte enables for RAM
    --------------------------------------------------------------------------------

xhdlbyte_en_dq32 : if (DQ_SIZE_SRAM = 32) generate
   process ( iFLASHWEN,iSRAMWEN, iFLASHCSN, iSRAMCSN_s, HsizeReg,SRAM_16BIT,SRAM_8BIT, HaddrReg )
   begin
      if ( iSRAMCSN_s = '0' ) then
         case  HsizeReg is
            when SZ_BYTE =>
               if(SRAM_16BIT = '1') then
                  case HaddrReg(1 downto 0) is
                     when "00" => SRAMBYTEN <= BYTE0;
                     when "01" => SRAMBYTEN <= BYTE1;
                     when "10" => SRAMBYTEN <= BYTE0;
                     when "11" => SRAMBYTEN <= BYTE1;
                     when others => SRAMBYTEN <= NONE;
                  end case;
               elsif(SRAM_8BIT = '1') then
                  SRAMBYTEN <= BYTE0;
               else
                  case HaddrReg(1 downto 0) is
                     when "00" => SRAMBYTEN <= BYTE0;
                     when "01" => SRAMBYTEN <= BYTE1;
                     when "10" => SRAMBYTEN <= BYTE2;
                     when "11" => SRAMBYTEN <= BYTE3;
                     when others => SRAMBYTEN <= NONE;
                  end case;
               end if;
            when SZ_HALF =>
               if(SRAM_16BIT = '1') then
                  SRAMBYTEN <= HALF0;
               elsif (SRAM_8BIT = '1' ) then
                  SRAMBYTEN <= BYTE0;
               else
                  case HaddrReg( 1) is
                     when '0' =>  SRAMBYTEN <= HALF0;
                     when '1' =>  SRAMBYTEN <= HALF1;
                     when others => SRAMBYTEN <= NONE;
                  end case;
               end if;
            when SZ_WORD =>
               SRAMBYTEN <= WORD;
            when others =>
               SRAMBYTEN <= NONE;
         end case;
      else
         SRAMBYTEN <= NONE;
      end if;
   end process;

end generate;


xhdlbyte_en_dq16 : if (DQ_SIZE_SRAM = 16) generate
   process ( iFLASHWEN,iSRAMWEN, iFLASHCSN, iSRAMCSN_s, HsizeReg,SRAM_16BIT,SRAM_8BIT, HaddrReg )
   begin
      if ( iSRAMCSN_s = '0' ) then
         case  HsizeReg is
            when SZ_BYTE =>
               if(SRAM_16BIT = '1') then
                  case HaddrReg(1 downto 0) is
                     when "00" => SRAMBYTEN <= "10";
                     when "01" => SRAMBYTEN <= "01";
                     when "10" => SRAMBYTEN <= "10";
                     when "11" => SRAMBYTEN <= "01";
                     when others => SRAMBYTEN <= "11";
                  end case;
               else -- (SRAM_8BIT = '1')
                  SRAMBYTEN(1 downto 0) <= "10" ;
               end if;
            when SZ_HALF =>
               if(SRAM_16BIT = '1') then
                  SRAMBYTEN(1 downto 0) <= "00";
               else
                  SRAMBYTEN(1 downto 0) <= "10";
               end if;
            when SZ_WORD =>
               SRAMBYTEN(1 downto 0) <= "00";
            when others =>
               SRAMBYTEN(1 downto 0) <= "11";
         end case;
      else
         SRAMBYTEN(1 downto 0) <= "11";
      end if;
   end process;

end generate;

xhdlbyte_en_dq8 :  if (DQ_SIZE_SRAM = 8) generate
   process ( iFLASHWEN,iSRAMWEN, iFLASHCSN, iSRAMCSN_s, HsizeReg, HaddrReg )
   begin
      if ( iSRAMCSN_s = '0' ) then
         case  HsizeReg is
            when SZ_BYTE =>
               SRAMBYTEN(0) <= '0' ;
            when SZ_HALF =>
               SRAMBYTEN(0) <= '0';
            when SZ_WORD =>
               SRAMBYTEN(0) <= '0';
            when others =>
               SRAMBYTEN(0) <= '1';
         end case;
      else
         SRAMBYTEN(0) <= '1';
      end if;
   end process;

end generate;


    --------------------------------------------------------------------------------
    -- Output AHB read data bus generation.
    --------------------------------------------------------------------------------
    -- Register lower half of MEMDATAIn to facilitate word reads when using 16-bit
    -- flash.
------------------------------------------------------------------------------------------------------------
xhdlMEMDATAInRegdq8_sync : if (DQ_SIZE =8 and SYNC_SRAM = 1) generate
begin
   process (HCLK, aresetn)
   begin
      if ( aresetn = '0' ) then
         MEMDATAInReg(31 downto 0)   <=  (others => '0');
      elsif (HCLK'event and HCLK = '1') then
         if (sresetn = '0') then
             MEMDATAInReg(31 downto 0)   <=  (others => '0');
         else
            if(SRAM_8BIT ='1' and  iFLASHCSN /= '0' ) then
               if ( pipeline_rd_d2 = '1' and FLOW_THROUGH = 0) then
                  MEMDATAInReg(31 downto 0) <= MEMDATAIn (7 downto 0)  & MEMDATAInReg(31 downto 8) ;
               elsif ( CurrentWait = ONE and FLOW_THROUGH = 1) then
                  MEMDATAInReg(31 downto 0) <= MEMDATAIn (7 downto 0) & MEMDATAInReg(31 downto 8);
               end if;
            elsif(iFLASHCSN = '0') then
               if ( CurrentWait = ZERO ) then
                  MEMDATAInReg(31 downto 0) <= MEMDATAIn (7 downto 0) & MEMDATAInReg(31 downto 8);
               end if;
            end if;
         end if;
      end if;
   end process;
end generate;

    
xhdlMEMDATAInRegdq8_async : if (DQ_SIZE =8 and SYNC_SRAM = 0) generate
begin
   process (HCLK, aresetn)
   begin
      if ( aresetn = '0' ) then
         MEMDATAInReg(31 downto 0)   <=  (others => '0');
      elsif (HCLK'event and HCLK = '1') then
         if (sresetn = '0') then
            MEMDATAInReg(31 downto 0)   <=  (others => '0');
         else
            if ( CurrentWait = ZERO ) then
               MEMDATAInReg(31 downto 0)   <= MEMDATAIn (7 downto 0)  & MEMDATAInReg(31 downto 8);
            end if;
         end if;
      end if;
   end process;
end generate;



xhdliHRDATAdq8 : if (DQ_SIZE = 8) generate
--   process(iFLASHCSN,MEMDATAInReg,MEMDATAIn )
   process(iFLASHCSN,HaddrReg,HsizeReg,HselFlashReg,MEMDATAIn,MEMDATAInReg)
   begin
      case  HsizeReg is
         when SZ_BYTE =>
            if (SYNC_SRAM = 1 and iFLASHCSN = '1') then
               iHRDATA <= MEMDATAInReg(31 downto 24) & MEMDATAInReg(31 downto 24) & MEMDATAInReg(31 downto 24) & MEMDATAInReg(31 downto 24);
            else
               iHRDATA <= MEMDATAIn(7 downto 0) & MEMDATAIn(7 downto 0) & MEMDATAIn(7 downto 0) & MEMDATAIn(7 downto 0) ;
            end if;
         when SZ_HALF =>
            if(SYNC_SRAM = 1 and iFLASHCSN = '1') then
               case HaddrReg(1) is
                  when '0'=>  iHRDATA <=  "0000000000000000" & MEMDATAInReg(31 downto 16) ;
                  when '1' =>  iHRDATA <=  MEMDATAInReg(31 downto 16) & "0000000000000000" ;
                  when others => iHRDATA <=  MEMDATAInReg(31 downto 0) ;
               end case;
            else
               case HaddrReg(1) is
                  when '0' =>  iHRDATA <=  "0000000000000000" & MEMDATAIn(7 downto 0) & MEMDATAInReg(31 downto 24) ;
                  when '1' =>  iHRDATA <=  MEMDATAIn(7 downto 0) & MEMDATAInReg(31 downto 24) & "0000000000000000" ;
                  when others => iHRDATA <=  MEMDATAInReg(31 downto 0) ;
               end case;
            end if;
         when SZ_WORD =>
            if(HselFlashReg ='1' or SYNC_SRAM = 0 ) then
               iHRDATA <=  MEMDATAIn(7 downto 0) & MEMDATAInReg(31 downto 8) ;
            else 
               iHRDATA <=  MEMDATAInReg(31 downto 0) ;
            end if;
         when others =>
            iHRDATA <=  MEMDATAInReg(31 downto 0) ;
      end case;
   end process;
end generate;

------------------------------------------------------------------------------------------------------------


xhdlMEMDATAInRegdq16_sync : if (DQ_SIZE =16 and SYNC_SRAM = 1) generate
begin
   process (HCLK, aresetn)
   begin
      if ( aresetn = '0' ) then
         MEMDATAInReg(31 downto 0)   <=  (others => '0');
      elsif (HCLK'event and HCLK = '1') then
         if (sresetn = '0') then
            MEMDATAInReg(31 downto 0)   <=  (others => '0');
         else
            if (wr_follow_rd_next = '1') then
                MEMDATAInReg(31 downto 0)   <=  (others => '0');
            elsif (SRAM_8BIT ='1' or (FLASH_DQ_SIZE = 8 and  iFLASHCSN = '0') ) then
               if ((CurrentWait = ONE and FLOW_THROUGH = 1 and (iSRAMCSN_s = '0'))) then
                  MEMDATAInReg(31 downto 0) <= MEMDATAIn (7 downto 0) & MEMDATAInReg(31 downto 8);
               elsif ((pipeline_rd_d2 = '1' and FLOW_THROUGH = 0 and (iSRAMCSN_s) = '0' )) then
                  MEMDATAInReg(31 downto 0) <= MEMDATAIn (7 downto 0) & MEMDATAInReg(31 downto 8);
               elsif ((CurrentWait = ZERO and ( iFLASHCSN ='0' ))) then
                  MEMDATAInReg(31 downto 0) <= MEMDATAIn (7 downto 0) & MEMDATAInReg(31 downto 8);
               end if; 
            else
               if (FLOW_THROUGH = 1) then
                  if ((CurrentWait = ONE and (iSRAMCSN_s = '0' )) or (CurrentWait = ZERO and ( iFLASHCSN ='0' ))) then
                     MEMDATAInReg <=  MEMDATAIn(15 downto 0) & MEMDATAInReg(31 downto 16);
                  end if;
               else 
                  if ((pipeline_rd_d2 = '1' and (iSRAMCSN_s = '0' )) or (CurrentWait = ZERO and ( iFLASHCSN ='0' ))) then
                     MEMDATAInReg <=  MEMDATAIn(15 downto 0) & MEMDATAInReg(31 downto 16);
                  end if;
               end if;
            end if;
         end if;
      end if;
   end process;
end generate;


xhdlMEMDATAInRegdq16_async :  if (DQ_SIZE =16 and SYNC_SRAM = 0) generate
begin
   process (HCLK, aresetn)
   begin
      if ( aresetn = '0' ) then
         MEMDATAInReg(31 downto 0)   <=  (others => '0');
      elsif (HCLK'event and HCLK = '1') then
         if (sresetn = '0' or wr_follow_rd_next = '1' ) then
            MEMDATAInReg(31 downto 0)   <=  (others => '0');
         else
            if(SRAM_8BIT ='1' or (FLASH_DQ_SIZE = 8 and  iFLASHCSN = '0') ) then
               if ( CurrentWait = ZERO ) then
                  MEMDATAInReg(31 downto 0) <= MEMDATAIn (7 downto 0) & MEMDATAInReg(31 downto 8);
               end if;
            else 
               if ( CurrentWait = ZERO and ( iFLASHCSN ='0' or (iSRAMCSN_s) = '0' )) then
                  MEMDATAInReg <=  MEMDATAIn(15 downto 0) & MEMDATAInReg(31 downto 16);
               end if;
            end if;
         end if;
      end if;
   end process;
end generate;



xhdliHRDATAdq16 :  if (DQ_SIZE = 16) generate
   process(iFLASHCSN,HaddrReg,HsizeReg,MEMDATAIn,MEMDATAInReg,SRAM_16BIT,SRAM_8BIT)
   begin
      if ( iFLASHCSN = '0' and FLASH_DQ_SIZE = 16 )  then
         case  HsizeReg is
            when SZ_BYTE =>
               case HaddrReg(0) is
                  when '0' =>  iHRDATA <= MEMDATAIn(7 downto 0) & MEMDATAIn(7 downto 0) &  MEMDATAIn(7 downto 0) & MEMDATAIn(7 downto 0) ;
                  when '1' =>  iHRDATA <= MEMDATAIn(15 downto 8) & MEMDATAIn(15 downto 8) &  MEMDATAIn(15 downto 8) & MEMDATAIn(15 downto 8) ;	
                  when others =>  iHRDATA <=MEMDATAIn(15 downto 0) & MEMDATAIn(15 downto 0) ;

               end case;
            when SZ_HALF =>
               iHRDATA <=   MEMDATAIn(15 downto 0) & MEMDATAIn(15 downto 0) ;
            when SZ_WORD =>
               iHRDATA <=   MEMDATAIn(15 downto 0) & MEMDATAInReg(31 downto 16) ;
            when others =>
               iHRDATA <=   MEMDATAIn(15 downto 0) & MEMDATAIn(15 downto 0) ;
         end case;
      elsif ( iFLASHCSN = '0' and FLASH_DQ_SIZE = 8 ) then
         case  HsizeReg is
            when SZ_BYTE =>
               iHRDATA <=  MEMDATAIn(7 downto 0) & MEMDATAIn(7 downto 0) & MEMDATAIn(7 downto 0) & MEMDATAIn(7 downto 0)   ;
            when SZ_HALF =>
               case  HaddrReg(1) is
                  when '0' =>  iHRDATA <=  "0000000000000000" & MEMDATAIn(7 downto 0) & MEMDATAInReg(31 downto 24) ;
                  when '1' =>  iHRDATA <=  MEMDATAIn(7 downto 0) & MEMDATAInReg(31 downto 24) & "0000000000000000" ;
                  when others =>  iHRDATA <=MEMDATAIn(15 downto 0) & MEMDATAIn(15 downto 0) ;
               end case;
            when SZ_WORD =>
               iHRDATA <=  MEMDATAIn(7 downto 0) & MEMDATAInReg(31 downto 8) ;
            when others =>
               iHRDATA <=  MEMDATAIn(15 downto 0) & MEMDATAIn(15 downto 0) ;
         end case;
      else
         case HsizeReg is
            when SZ_BYTE =>
               if(SRAM_8BIT ='1' ) then
                  if(SYNC_SRAM = 1) then
                     iHRDATA <=  MEMDATAInReg(31 downto 24) & MEMDATAInReg(31 downto 24) & MEMDATAInReg(31 downto 24) & MEMDATAInReg(31 downto 24)   ;
                  else
                     iHRDATA <=  MEMDATAIn(7 downto 0) & MEMDATAIn(7 downto 0) & MEMDATAIn(7 downto 0) & MEMDATAIn(7 downto 0)   ;
                  end if;
               else
                  if(SYNC_SRAM = 1) then
                     case ( HaddrReg(0) ) is
                        when '0'=> iHRDATA <=  MEMDATAInReg(23 downto 16) & MEMDATAInReg(23 downto 16) & MEMDATAInReg(23 downto 16) & MEMDATAInReg(23 downto 16)   ;
                        when '1'=> iHRDATA <=  MEMDATAInReg(31 downto 24) & MEMDATAInReg(31 downto 24) & MEMDATAInReg(31 downto 24) & MEMDATAInReg(31 downto 24)  ;
                        when others =>  iHRDATA <=MEMDATAIn(15 downto 0) & MEMDATAIn(15 downto 0) ;
                     end case;
                  else
                     case ( HaddrReg(0) ) is
                        when '0'=> iHRDATA <=  MEMDATAIn(7 downto 0) & MEMDATAIn(7 downto 0) & MEMDATAIn(7 downto 0) & MEMDATAIn(7 downto 0)   ;
                        when '1'=> iHRDATA <=  MEMDATAIn(15 downto 8) & MEMDATAIn(15 downto 8) & MEMDATAIn(15 downto 8) & MEMDATAIn(15 downto 8)  ;
                        when others =>  iHRDATA <=MEMDATAIn(15 downto 0) & MEMDATAIn(15 downto 0) ;
                     end case;
                  end if;
               end if;
            when SZ_HALF =>
               if(SRAM_8BIT ='1') then
                  if(SYNC_SRAM = 1) then
                     case ( HaddrReg(1) ) is
                        when '0'=>  iHRDATA <=  "0000000000000000" & MEMDATAInReg(31 downto 16) ;
                        when '1'=>  iHRDATA <=  MEMDATAInReg(31 downto 16) & "0000000000000000" ;
                        when others =>  iHRDATA <=MEMDATAIn(15 downto 0) & MEMDATAIn(15 downto 0) ;
                     end case;
                  else
                     case ( HaddrReg(1) ) is
                        when '0'=>  iHRDATA <=  "0000000000000000" & MEMDATAIn(7 downto 0) & MEMDATAInReg(31 downto 24) ;
                        when '1'=>  iHRDATA <=  MEMDATAIn(7 downto 0) & MEMDATAInReg(31 downto 24) & "0000000000000000" ;
                        when others =>  iHRDATA <=MEMDATAIn(15 downto 0) & MEMDATAIn(15 downto 0) ;
                     end case;
                  end if;
               else 
                  if(SYNC_SRAM = 1) then
                     iHRDATA <=  MEMDATAInReg(31 downto 16) & MEMDATAInReg(31 downto 16) ;
                  else
                     iHRDATA <=  MEMDATAIn(15 downto 0) & MEMDATAIn(15 downto 0) ;
                  end if ;
               end if;
            when SZ_WORD=>
               if(SYNC_SRAM = 0) then	 
                  if(SRAM_8BIT = '1') then
                     iHRDATA <=  MEMDATAIn(7 downto 0) & MEMDATAInReg(31 downto 8) ;
                  else 
                     iHRDATA <=  MEMDATAIn(15 downto 0) & MEMDATAInReg(31 downto 16) ;
                  end if;
               else 
                  if(SRAM_8BIT ='1') then
                     iHRDATA <=  MEMDATAInReg(31 downto 0) ;
                  elsif (SRAM_16BIT = '1') then 
                     iHRDATA <=  MEMDATAInReg(31 downto 0) ;
                  else
                     iHRDATA <=  MEMDATAIn(15 downto 0) &  MEMDATAInReg(31 downto 16) ;
                  end if;
               end if;
            when others =>
               iHRDATA <= MEMDATAIn(15 downto 0) & MEMDATAIn(15 downto 0);
         end case;
      end if;
   end process;
end generate;




xhdlMEMDATA_rd : if (FLASH_DQ_SIZE = 16 or FLASH_DQ_SIZE = 32 ) generate
   process (HCLK, aresetn)
   begin
      if ( aresetn = '0' ) then
         MEMDATA_rd_flash <=  (others => '0');
      elsif (HCLK'event and HCLK = '1') then
         if (sresetn = '0') then
            MEMDATA_rd_flash <=  (others => '0');
         else
            if ( CurrentWait = ZERO and wr_follow_rd_next='1' ) then
               if(FLASH_DQ_SIZE =32) then
                  MEMDATA_rd_flash <= MEMDATAIn;
               else
                  MEMDATA_rd_flash <=  MEMDATAIn(15 downto 0) & MEMDATAIn(15 downto 0);
               end if;
            end if;
         end if;
      end if;
   end process;
end generate;


------------------------------------------------------------------------------------------------------------


xhdlMEMDATAInRegdq32_sync : if (DQ_SIZE =32 and SYNC_SRAM = 1) generate
begin
   process (HCLK, aresetn)
   begin
      if ( aresetn = '0' ) then
         MEMDATAInReg(31 downto 0)   <=  (others => '0');
      elsif (HCLK'event and HCLK = '1') then
         if (sresetn = '0') then
            MEMDATAInReg(31 downto 0)   <=  (others => '0');
         else
            if (wr_follow_rd_next = '1') then
                MEMDATAInReg(31 downto 0)   <=  (others => '0');
            else
               if((FLASH_DQ_SIZE = 8) and (iFLASHCSN = '0')) then
                  if (CurrentWait = ZERO ) then
                     MEMDATAInReg <= MEMDATAIn(7 downto 0)& MEMDATAInReg(31 downto 8);
                  else
                     MEMDATAInReg <= MEMDATAInReg;
                  end if;
               elsif ((SRAM_8BIT ='1') and (iSRAMCSN_s = '0')) then	  
                  if (CurrentWait = ONE and FLOW_THROUGH = 1 ) then
                     MEMDATAInReg(31 downto 0) <= MEMDATAIn (7 downto 0) &MEMDATAInReg(31 downto 8);
                  elsif  (pipeline_rd_d2 = '1' and FLOW_THROUGH = 0 ) then
                     MEMDATAInReg(31 downto 0) <= MEMDATAIn (7 downto 0) &MEMDATAInReg(31 downto 8);
                  else
                     MEMDATAInReg <= MEMDATAInReg;
                  end if; 
               elsif(FLASH_DQ_SIZE = 16 and  iFLASHCSN = '0') then
                  if ( CurrentWait = ZERO ) then
                     MEMDATAInReg <=  MEMDATAIn(15 downto 0)& MEMDATAInReg(31 downto 16);
                  end if;
               else
                  if(SRAM_16BIT='1' ) then
                     if (FLOW_THROUGH = 1) then
                        if ((CurrentWait = ONE and ((iSRAMCSN_s) = '0' )) or (CurrentWait = ZERO and ( iFLASHCSN ='0' ))) then
                           MEMDATAInReg <=  MEMDATAIn(15 downto 0)& MEMDATAInReg(31 downto 16);
                        end if;
                     else
                        if ((pipeline_rd_d2 = '1' and ((iSRAMCSN_s) = '0' )) or (CurrentWait = ZERO and ( iFLASHCSN ='0' ))) then
                           MEMDATAInReg <=  MEMDATAIn(15 downto 0) & MEMDATAInReg(31 downto 16);
                        end if;
                     end if;
                  else
                     if (FLOW_THROUGH = 1) then
                        if (CurrentWait = ONE and ((iSRAMCSN_s) = '0' )) then
                           MEMDATAInReg <= MEMDATAIn(31 downto 0);
                        else
                           MEMDATAInReg <=  MEMDATAInReg;
                        end if;
                     else
                        if (pipeline_rd_d2 = '1' and (iSRAMCSN_s) = '0' ) then
                           MEMDATAInReg <= MEMDATAIn(31 downto 0);
                        else
                           MEMDATAInReg <=  MEMDATAInReg;
                        end if;
                     end if;
                  end if;
               end if;
            end if;
         end if;
      end if;
   end process;
end generate;


xhdlMEMDATAInRegdq32_async : if (DQ_SIZE =32 and SYNC_SRAM = 0) generate
begin
   process (HCLK, aresetn)
   begin
      if ( aresetn = '0' ) then
         MEMDATAInReg(31 downto 0)   <=  (others => '0');
      elsif (HCLK'event and HCLK = '1') then
         if (sresetn = '0') then
            MEMDATAInReg(31 downto 0)   <=  (others => '0');
         else
            if (wr_follow_rd_next = '1') then
                MEMDATAInReg(31 downto 0)   <=  (others => '0');
            else
               if(SRAM_8BIT='1' or (FLASH_DQ_SIZE = 8 and  iFLASHCSN = '0')) then
                  if ( CurrentWait = ZERO ) then
                     MEMDATAInReg(31 downto 0) <= MEMDATAIn (7 downto 0) &MEMDATAInReg(31 downto 8);
                  end if;
               else
                  if ( CurrentWait = ZERO) then
                     MEMDATAInReg <=  MEMDATAIn(15 downto 0)& MEMDATAInReg(31 downto 16);
                  end if;
               end if;
            end if;
         end if;
      end if;
   end process;
end generate;




xhdliHRDATAdq32 : if (DQ_SIZE = 32) generate
   process(iFLASHCSN,HsizeReg,HaddrReg,MEMDATAIn,MEMDATAInReg,SRAM_8BIT,SRAM_16BIT)
   begin
      if ( iFLASHCSN = '0' and FLASH_DQ_SIZE = 16 )  then
         case  HsizeReg is
            when SZ_BYTE =>
               case HaddrReg( 0) is
                  when '0' =>  iHRDATA <= MEMDATAIn(7 downto 0) & MEMDATAIn(7 downto 0) & MEMDATAIn(7 downto 0) & MEMDATAIn(7 downto 0)   ;
                  when '1' =>  iHRDATA <= MEMDATAIn(15 downto 8) & MEMDATAIn(15 downto 8) & MEMDATAIn(15 downto 8) & MEMDATAIn(15 downto 8)  ;
                  when others =>   iHRDATA <=   MEMDATAIn(31 downto 0);
               end case;
            when SZ_HALF =>
               iHRDATA <=   MEMDATAIn(15 downto 0) & MEMDATAIn(15 downto 0) ;
            when SZ_WORD =>
               iHRDATA <=   MEMDATAIn(15 downto 0) & MEMDATAInReg(31 downto 16) ;
            when others =>
               iHRDATA <=   MEMDATAIn(15 downto 0) & MEMDATAIn(15 downto 0) ;
         end case;
      elsif ( iFLASHCSN = '0' and FLASH_DQ_SIZE = 8 ) then
         case  HsizeReg is
            when SZ_BYTE =>
               iHRDATA <=  MEMDATAIn(7 downto 0)&   MEMDATAIn(7 downto 0)&   MEMDATAIn(7 downto 0)&   MEMDATAIn(7 downto 0) ;
            when SZ_HALF =>
               case HaddrReg( 1) is
                  when '0' =>  iHRDATA <=  "0000000000000000" & MEMDATAIn(7 downto 0) & MEMDATAInReg(31 downto 24) ;
                  when '1' =>  iHRDATA <=  MEMDATAIn(7 downto 0) & MEMDATAInReg(31 downto 24) & "0000000000000000" ;
                  when others =>   iHRDATA <=   MEMDATAIn(31 downto 0);
               end case;
            when SZ_WORD =>
               iHRDATA <=    MEMDATAIn(7 downto 0) & MEMDATAInReg(31 downto 8) ;
            when others =>
               iHRDATA <=    MEMDATAIn(15 downto 0) &  MEMDATAIn(15 downto 0) ;
         end case;
      elsif (iFLASHCSN = '0' and FLASH_DQ_SIZE = 32 ) then
         case  HsizeReg is
            when SZ_BYTE =>
               case HaddrReg( 1 downto 0) is
                  when "00" =>  iHRDATA <=  "000000000000000000000000" & MEMDATAIn(7 downto 0) ;
                  when "01" =>  iHRDATA <=  "0000000000000000" & MEMDATAIn(15 downto 8) & "00000000" ;
                  when "10" =>  iHRDATA <=  "00000000" & MEMDATAIn(23 downto 16) & "0000000000000000" ;
                  when "11" =>  iHRDATA <=  MEMDATAIn(31 downto 24) & "000000000000000000000000" ;
                  when others =>   iHRDATA <=   MEMDATAIn(31 downto 0);
               end case;
            when SZ_HALF =>
               case HaddrReg( 1) is
                  when '0' =>  iHRDATA <=  "0000000000000000" & MEMDATAIn(15 downto 0) ;
                  when '1' =>  iHRDATA <=  MEMDATAIn(31 downto 16) & "0000000000000000" ;
                  when others =>   iHRDATA <=   MEMDATAIn(31 downto 0);
               end case;
            when SZ_WORD =>
               iHRDATA <=   MEMDATAIn(31 downto 0);
            when others =>
               iHRDATA <=   MEMDATAIn(31 downto 0);
         end case;
      else
         case  HsizeReg is
            when SZ_BYTE =>
               if(SRAM_8BIT = '1') then
                  if(SYNC_SRAM = 1) then
                     iHRDATA <=  MEMDATAInReg(31 downto 24) & MEMDATAInReg(31 downto 24) & MEMDATAInReg(31 downto 24) & MEMDATAInReg(31 downto 24)   ;
                  else
                     iHRDATA <=  MEMDATAIn(7 downto 0) & MEMDATAIn(7 downto 0) & MEMDATAIn(7 downto 0) & MEMDATAIn(7 downto 0)   ;
                  end if;
               elsif (SRAM_16BIT ='1') then
                  if(SYNC_SRAM = 1) then
                     case ( HaddrReg(0) ) is
                        when  '0' => iHRDATA <=  MEMDATAInReg(23 downto 16) & MEMDATAInReg(23 downto 16) & MEMDATAInReg(23 downto 16) & MEMDATAInReg(23 downto 16)   ;
                        when  '1' => iHRDATA <=  MEMDATAInReg(31 downto 24) & MEMDATAInReg(31 downto 24) & MEMDATAInReg(31 downto 24) & MEMDATAInReg(31 downto 24)  ;
                        when others =>   iHRDATA <=   MEMDATAIn(31 downto 0);
                     end case ;
                  else
                     case ( HaddrReg(0) ) is
                        when  '0' => iHRDATA <=  MEMDATAIn(7 downto 0) & MEMDATAIn(7 downto 0) & MEMDATAIn(7 downto 0) & MEMDATAIn(7 downto 0)   ;
                        when  '1' => iHRDATA <=  MEMDATAIn(15 downto 8) & MEMDATAIn(15 downto 8) & MEMDATAIn(15 downto 8) & MEMDATAIn(15 downto 8)  ;
                        when others =>   iHRDATA <=   MEMDATAIn(31 downto 0);
                     end case ;
                  end if;
               else
                  if(SYNC_SRAM = 1) then
                     case ( HaddrReg(1 downto 0) ) is
                        when  "00" => iHRDATA <=  MEMDATAInReg(7 downto 0) & MEMDATAInReg(7 downto 0) & MEMDATAInReg(7 downto 0) & MEMDATAInReg(7 downto 0)   ;
                        when  "01" => iHRDATA <=  MEMDATAInReg(15 downto 8) & MEMDATAInReg(15 downto 8) & MEMDATAInReg(15 downto 8) & MEMDATAInReg(15 downto 8)  ;
                        when  "10" => iHRDATA <=  MEMDATAInReg(23 downto 16) & MEMDATAInReg(23 downto 16) & MEMDATAInReg(23 downto 16) & MEMDATAInReg(23 downto 16) ;
                        when  "11" => iHRDATA <=  MEMDATAInReg(31 downto 24) & MEMDATAInReg(31 downto 24) & MEMDATAInReg(31 downto 24) & MEMDATAInReg(31 downto 24) ;
                        when others =>   iHRDATA <=   MEMDATAIn(31 downto 0);
                     end case ;
                  else
                     case ( HaddrReg(1 downto 0) ) is
                        when  "00" => iHRDATA <=  MEMDATAIn(7 downto 0) & MEMDATAIn(7 downto 0)& MEMDATAIn(7 downto 0)& MEMDATAIn(7 downto 0)   ;
                        when  "01" => iHRDATA <=  MEMDATAIn(15 downto 8) & MEMDATAIn(15 downto 8)& MEMDATAIn(15 downto 8)& MEMDATAIn(15 downto 8)  ;
                        when  "10" => iHRDATA <=  MEMDATAIn(23 downto 16) & MEMDATAIn(23 downto 16)& MEMDATAIn(23 downto 16)& MEMDATAIn(23 downto 16) ;
                        when  "11" => iHRDATA <=  MEMDATAIn(31 downto 24) & MEMDATAIn(31 downto 24)& MEMDATAIn(31 downto 24)& MEMDATAIn(31 downto 24) ;
                        when others =>   iHRDATA <=   MEMDATAIn(31 downto 0);
                     end case;
                  end if;
               end if;
            when SZ_HALF => 
               if(SRAM_8BIT='1') then
                  if(SYNC_SRAM = 1) then
                     case ( HaddrReg(1) ) is
                        when  '0' =>  iHRDATA <=  "0000000000000000" & MEMDATAInReg(31 downto 16) ;
                        when  '1' =>  iHRDATA <=  MEMDATAInReg(31 downto 16) & "0000000000000000" ;
                        when others =>   iHRDATA <=   MEMDATAIn(31 downto 0);
                     end case;
                  else
                     case ( HaddrReg(1) ) is
                        when  '0' =>  iHRDATA <=  "0000000000000000" & MEMDATAIn(7 downto 0) & MEMDATAInReg(31 downto 24) ;
                        when  '1' =>  iHRDATA <=  MEMDATAIn(7 downto 0) & MEMDATAInReg(31 downto 24) & "0000000000000000" ;
                        when others =>   iHRDATA <=   MEMDATAIn(31 downto 0);
                     end case ;
                  end if;
               elsif (SRAM_16BIT ='1')  then
                  if(SYNC_SRAM = 1) then
                     iHRDATA <=  MEMDATAInReg(31 downto 16) & MEMDATAInReg(31 downto 16) ;
       	          else
                     iHRDATA <=  MEMDATAIn(15 downto 0) & MEMDATAIn(15 downto 0) ;
                  end if;
               else
                  if(SYNC_SRAM = 1) then
                     case ( HaddrReg(1) ) is
                        when  '0' =>  iHRDATA <=  MEMDATAInReg(15 downto 0) &  MEMDATAInReg(15 downto 0)  ;
                        when  '1' =>  iHRDATA <=  MEMDATAInReg(31 downto 16) & MEMDATAInReg(31 downto 16) ;
                        when others =>   iHRDATA <=   MEMDATAIn(31 downto 0);
                     end case;
                  else
                     case ( HaddrReg(1) ) is
                        when  '0' =>  iHRDATA <=  MEMDATAIn(15 downto 0) &  MEMDATAIn(15 downto 0)  ;
                        when  '1' =>  iHRDATA <=  MEMDATAIn(31 downto 16) & MEMDATAIn(31 downto 16) ;
                        when others =>   iHRDATA <=   MEMDATAIn(31 downto 0);
                     end case;
                  end if;
               end if;
            when SZ_WORD =>
               if(SRAM_8BIT ='1') then
                  if(SYNC_SRAM = 1) then  
                     iHRDATA <=  MEMDATAInReg(31 downto 0) ;
                  else
                     iHRDATA <=  MEMDATAIn(7 downto 0) & MEMDATAInReg(31 downto 8) ;
                  end if;
               elsif (SRAM_16BIT ='1') then
                  if(SYNC_SRAM = 1) then     
                     iHRDATA <=  MEMDATAInReg(31 downto 0) ;
                  else
                     iHRDATA <=  MEMDATAIn(15 downto 0) & MEMDATAInReg(31 downto 16) ;
                  end if;
               else
                  if(SYNC_SRAM = 1) then    
                     iHRDATA <=  MEMDATAInReg(31 downto 0) ;
                  else
                     iHRDATA <= MEMDATAIn(31 downto 0);
                  end if;
               end if;
            when others =>
               iHRDATA <= MEMDATAIn(31 downto 0);
         end case;
      end if;
   end process;
end generate;

 
    HRDATA  <= iHRDATA when (Busy_d = '0') else (others=> '0') ;


    --------------------------------------------------------------------------------
    -- Slave response
    --------------------------------------------------------------------------------
    -- Output response to AHB bus is always OKAY
    HRESP <= RSP_OKAY;

end rtl;

--================================ End ===================================--
