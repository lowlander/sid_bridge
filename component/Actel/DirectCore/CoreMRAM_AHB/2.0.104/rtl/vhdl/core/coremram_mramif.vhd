library ieee;
library CoreMRAM_AHB_LIB;

use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.math_real.all;
use CoreMRAM_AHB_LIB.mram_pkg.all;



entity COREMRAM_MRAMIF is
generic (
FAMILY                  : integer := 25;    -- Device Family
BYTE_MODE_EN            : integer range 0 to 1 := 0;              -- Select 16 bits / 8bits Memory interface
DQ_SIZE                 : integer range 0 to 16 := 8;             -- 
CORE_CLK_FREQUENCY      : integer range 12 to 48 := 12           -- CORE_CLK frequency in Mhz

);
port (

----        AHB_BLOCK Interface Signals

TRANSACTION_MRAM_START       : in std_logic; 
MRAM_TRANSACTION_TYPE        : in std_logic_vector(1 downto 0);       --(00-no_trnsaction) ,(01 - read),(10-write)
MRAM_AHB_ADDR                : in std_logic_vector(20 downto 0);
MRAM_WR_DATA                 : in std_logic_vector(DQ_SIZE-1 downto 0);
MRAM_RD_DATA                 : out std_logic_vector(DQ_SIZE-1 downto 0);
MRAM_RD_DATA_EN              : out std_logic;
MRAM_TRANSACTION_DONE        : out std_logic;

-----       NVRAM Clock and Reset 
CORE_CLK                     : in std_logic;                          --  NVRAM Controller Clock
CORECLK_RESETN               : in std_logic;                          --  Async reset (Active low and asynchronous)
MRAMCLK_OUT                  : out std_logic;                         --  NVRAM interface Clock.
-----       NVRAM Interface Signals
MRAM_OVERFLOW_O              : in std_logic;                          --  Memory Internal Counter Overflow Flag, Active high signal indicates memory internal counter reached last address.
MRAM_CEB                     : out std_logic;                         --  Active low chip enable
MRAM_ADDR                    : out std_logic_vector(20 downto 0);     --  Memory Address
MRAM_WE                      : out std_logic;                         --  Write Enable
MRAM_OE                      : out std_logic;                         --  Output Enable 
MRAM_X8                      : out std_logic;                         --  Byte Mode configuration
MRAM_AUTO_INCR               : out std_logic;                         --  Auto Increment Mode Enable 
MRAM_OVERFLOW_I              : out std_logic;                         --  Memory Internal Counter Enable  Pin. Active High Enable for internal counter (when INIT=1,DONE=0). Used to daisy chain devices. 
MRAM_INIT                    : out std_logic;                         --  Active High Interface Pin used to reset internal address counter (when OVERFLOW I=1, DONE=0) 
MRAM_DONE                    : out std_logic;                         --  Active Low Interface Pin used to reset internal address counter (when OVERFLOW I=1, INIT=1). 
DQ_in                        : in std_logic_vector(DQ_SIZE-1 downto 0);      --  Data Input
DQ_out                       : out std_logic_vector(DQ_SIZE-1 downto 0)      --  Data output Signal
);
end entity COREMRAM_MRAMIF;

architecture COREMRAM_MRAMIF_ARCH of COREMRAM_MRAMIF is


--constant C1 : integer := ((95000 /((1000000/CORE_CLK_FREQUENCY)+1)) + 1 );
--Constant C2 : integer := ((95000 /((1000000/CORE_CLK_FREQUENCY)+1)) + 1 ) + (((120000-(((1000000/CORE_CLK_FREQUENCY)+1)*((95000 /((1000000/CORE_CLK_FREQUENCY)+1)) + 1 )))/((1000000/CORE_CLK_FREQUENCY)+1))+1);
--Constant C3 : integer := ((95000 /((1000000/CORE_CLK_FREQUENCY)+1)) + 1 ) + (((140000-(((1000000/CORE_CLK_FREQUENCY)+1)*((95000 /((1000000/CORE_CLK_FREQUENCY)+1)) + 1 )))/((1000000/CORE_CLK_FREQUENCY)+1))+1);


type State_type is (idle, rd_cmd_stable, rd_clk_posedge, rd_clk_negedge,rd_done,wr_cmd_stable,wr_clk_posedge,wr_clk_negedge ,write_done,read_done);  -- Define the states
signal State : State_Type;    -- Create a signal that uses 

-----------signal Declaration---------------------------
signal CEB_int                         : std_logic;
signal A_int                           : std_logic_vector(20 downto 0);
signal WE_int                          : std_logic;
signal OE_int                          : std_logic;
signal X8_int                          : std_logic;
signal AUTO_INCR_int                   : std_logic;
signal OVERFLOW_I_int                  : std_logic;
signal INIT_int                        : std_logic;
signal DONE_int                        : std_logic;
signal MRAMCLK_OUT_int                 : std_logic;

signal transaction_done                : std_logic;
signal counter_negedge_start           : std_logic;
signal counter_negedge_done            : std_logic;
signal clk_counter_en                  : std_logic;
signal count                           : std_logic_vector(3 downto 0);  
signal C1                              : std_logic_vector(3 downto 0);  
signal C2                              : std_logic_vector(3 downto 0);  
signal C3                              : std_logic_vector(3 downto 0);  
signal C4                              : std_logic_vector(3 downto 0);  

constant  SYNC_RESET : INTEGER := SYNC_MODE_SEL(FAMILY);
signal    aresetn           : std_logic;
signal    sresetn           : std_logic;

begin

aresetn <= '1' WHEN (SYNC_RESET=1) ELSE CORECLK_RESETN;
sresetn <= CORECLK_RESETN WHEN (SYNC_RESET=1) ELSE '1';


MRAM_INTF_GEN : process (CORE_CLK, aresetn)
   begin 
   if (aresetn = '0') then 
      State            <= idle;
      CEB_int          <='1';
      WE_int           <='0';
      OE_int           <='0';
      AUTO_INCR_int    <='0';
      OVERFLOW_I_int   <='0';
      INIT_int         <='0';
      DONE_int         <='0';
      A_int            <=( others => '0');
      clk_counter_en   <='0';
      MRAM_RD_DATA_EN  <='0';
      transaction_done <= '0';
      MRAMCLK_OUT_int  <= '0';
      DQ_out           <=( others => '0');
      MRAM_RD_DATA     <=( others => '0');
 
   elsif rising_edge(CORE_CLK) then
      if (sresetn = '0') then
         State            <= idle;
         CEB_int          <='1';
         WE_int           <='0';
         OE_int           <='0';
         AUTO_INCR_int    <='0';
         OVERFLOW_I_int   <='0';
         INIT_int         <='0';
         DONE_int         <='0';
         A_int            <=( others => '0');
         clk_counter_en   <='0';
         MRAM_RD_DATA_EN  <='0';
         transaction_done <= '0';
         MRAMCLK_OUT_int  <= '0';
         DQ_out           <=( others => '0');
         MRAM_RD_DATA     <=( others => '0');
      else
         case State is
            when idle =>
               transaction_done  <= '0';
               if(TRANSACTION_MRAM_START ='1') then
                  if (MRAM_TRANSACTION_TYPE     = "01" ) then 
                     State           <= rd_clk_posedge;
                     A_int           <= MRAM_AHB_ADDR;
                     WE_int          <= '0';
                     CEB_int         <= '0';
                     OE_int          <= '1';
                     MRAMCLK_OUT_int <= '0';
                     clk_counter_en  <= '1';
                  elsif (MRAM_TRANSACTION_TYPE     = "10" ) then
                     State           <= wr_clk_posedge;
                     A_int           <= MRAM_AHB_ADDR;
                     DQ_out          <= MRAM_WR_DATA;
                     WE_int          <= '1';
                     CEB_int         <= '0';
                     OE_int          <= '0';
                     MRAMCLK_OUT_int <= '0';
                     clk_counter_en  <= '1';
                  end if;
               else
                  State           <= idle;
                  CEB_int         <= '1';
                  OE_int          <= '0';
                  DQ_out          <= ( others => '0');
               end if;
            when rd_cmd_stable =>
               State           <= rd_clk_posedge;
               clk_counter_en  <= '1';
               MRAMCLK_OUT_int <= '0';
            when rd_clk_posedge => 
               State           <= rd_clk_negedge;
               MRAMCLK_OUT_int <= '1';
            when rd_clk_negedge =>
               if (counter_negedge_start='1') then            ----95 ns read accees time
                  State           <= read_done;
                  MRAM_RD_DATA    <= DQ_in;
                  MRAM_RD_DATA_EN <= '1';
                  MRAMCLK_OUT_int <= '0';
               else
                  State           <= rd_clk_negedge;
                  MRAM_RD_DATA    <= DQ_in;
                  MRAM_RD_DATA_EN <= '0';
                  MRAMCLK_OUT_int <= '1';
               end if;
	     
            when read_done =>                                 --- 15 ns min clock low time to mentain , 120 ns read clock period
               if (counter_negedge_done='1') then
                  State           <= idle;
                  MRAM_RD_DATA_EN  <= '0';
                  transaction_done  <= '1';
                  MRAMCLK_OUT_int <= '0';
                  clk_counter_en  <= '0';
               else
                  State            <= read_done;
                  MRAM_RD_DATA_EN  <= '0';
                  transaction_done <= '0';
                  MRAMCLK_OUT_int  <= '0';
                  clk_counter_en   <= '1';
               end if; 
            when wr_cmd_stable => 
               State           <= wr_clk_posedge; 
               A_int           <= MRAM_AHB_ADDR;
               DQ_out          <= MRAM_WR_DATA;
               WE_int          <= '1';
               CEB_int         <= '0';
               OE_int          <= '0'; 
               MRAMCLK_OUT_int <= '0';
               clk_counter_en  <= '1';
            when wr_clk_posedge => 
               State           <= wr_clk_negedge; 
               MRAMCLK_OUT_int <= '1';
            when wr_clk_negedge => 
               if (counter_negedge_start='1') then
                  State           <= write_done; 
                  MRAMCLK_OUT_int <= '0';
               end if;
            when write_done =>                                --- 15 ns min clock low time to mentain
               if (counter_negedge_done='1') then
                  transaction_done  <= '1';
                  State           <= idle; 
                  MRAMCLK_OUT_int <= '0';
                  clk_counter_en  <= '0';
               end if; 
            when others =>
               State <= idle;
         end case;
      end if; 
   end if; 
end process;


MRAM_CLK_GEN: process (CORE_CLK, aresetn)
begin
   if (aresetn = '0') then
      count                 <= (others=>'0');
      counter_negedge_start <= '0';
      counter_negedge_done  <= '0';
   elsif (rising_edge(CORE_CLK)) then
      if (sresetn = '0') then
         count                 <= (others=>'0');
         counter_negedge_start <= '0';
         counter_negedge_done  <= '0';
      else
         if (MRAM_TRANSACTION_TYPE     ="01" ) then
            if (clk_counter_en = '1') then
               count <= count + 1;              
               if (count = C1) then
                  counter_negedge_start <= '1';
                  counter_negedge_done  <= '0';
               elsif (count = C2) then
                  counter_negedge_start <= '0';
                  counter_negedge_done  <= '1';
               else
                  counter_negedge_done  <= '0';
                  counter_negedge_start <= '0';
               end if;
            else
               count                 <= (others=>'0');
               counter_negedge_start <= '0'; 
               counter_negedge_done  <= '0';  
            end if;
         else
            if (clk_counter_en = '1') then
               count <= count + 1;
               if (count = C3) then
                  counter_negedge_start <= '1';
                  counter_negedge_done  <= '0';
               elsif (count = C4) then
                  counter_negedge_start <= '0';
                  counter_negedge_done  <= '1';
               else
                  counter_negedge_done  <= '0';
                  counter_negedge_start <= '0';
               end if;
            else
               count                 <= (others=>'0');
               counter_negedge_start <= '0'; 
               counter_negedge_done  <= '0';  
            end if;
         end if;
      end if;
   end if;
end process MRAM_CLK_GEN;

xhdl1 : IF (CORE_CLK_FREQUENCY = 12) GENERATE
   C1 <="0001";    
   C2 <="0010";    
   C3 <="0000";    
   C4 <="0001";    
END GENERATE;

xhdl2 : IF (CORE_CLK_FREQUENCY = 24) GENERATE
   C1 <="0010";     
   C2 <="0011";    
   C3 <="0001";    
   C4 <="0010";    
END GENERATE;
xhdl3 : IF (CORE_CLK_FREQUENCY = 48) GENERATE
   C1 <="0100";    
   C2 <="0101";    
   C3 <="0011";  
   C4 <="0100";  
END GENERATE;

MRAM_TRANSACTION_DONE <= transaction_done;

X8_int          <='1' when BYTE_MODE_EN = 1 else '0' ;
MRAM_X8         <= X8_int;
MRAMCLK_OUT     <= MRAMCLK_OUT_int;

MRAM_CEB        <= CEB_int;

MRAM_ADDR       <= A_int;
MRAM_WE         <= WE_int;
MRAM_OE         <= OE_int;

MRAM_AUTO_INCR  <= AUTO_INCR_int;
MRAM_OVERFLOW_I <= OVERFLOW_I_int; 
MRAM_INIT       <= INIT_int;
MRAM_DONE       <= DONE_int;



end architecture COREMRAM_MRAMIF_ARCH;










