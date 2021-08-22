library ieee;
library CoreMRAM_AHB_LIB;

use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use CoreMRAM_AHB_LIB.mram_pkg.all;


entity COREMRAM_AHBLIF is
generic (
FAMILY                  : integer := 25;                         -- Device Family
ECC                     : integer range 0 to 1:= 1;              -- (0 - ECC Disabled) , (1 - ECC Enabled)
DQ_SIZE                 : integer range 0 to 16 := 8;  
BUFFER_DEPTH            : integer range 16 to 1024 := 16;        -- Configurable FIFO depth
BYTE_MODE_EN            : integer range 0 to 1:= 1               -- Select 16 bits / 8bits Memory interface

);
port (

----        AHBLite Slave Interface Signals
HCLK                    : in std_logic;                          --  AHB clock.
HRESETN                 : in std_logic;                          --  AHB reset (Active low and asynchronous)
HREADYIN                : in std_logic;                          --  AHB ready in
HWRITE                  : in std_logic;                          --  AHB write/read
HSEL                    : in std_logic;                          --  AHB slave select
HTRANS                  : in std_logic_vector(1 downto 0);       --  AHB transfer type
HBURST                  : in std_logic_vector(2 downto 0);       --  AHB Burst Type
HSIZE                   : in std_logic_vector(2 downto 0);       --  AHB transfer size
HADDR                   : in std_logic_vector(31 downto 0);      --  AHB address
HWDATA                  : in std_logic_vector(31 downto 0);      --  AHB data in
HREADY                  : out std_logic;                         --  AHB ready out
HRESP                   : out std_logic_vector(1 downto 0);      --  AHB response
HRDATA                  : out std_logic_vector(31 downto 0);     --  AHB data out
-----       NVRAM Clock and Reset 
CORE_CLK                : in std_logic;                          --  NVRAM Controller Clock
CORECLK_RESETN          : in std_logic;                          --  Async reset (Active low and asynchronous)
ecc_flag_sb             : out std_logic;   
ecc_flag_db             : out std_logic;   

---
TRANSACTION_MRAM_START  : out std_logic; 
TRANSACTION_TYPE        : out std_logic_vector(1 downto 0);      --  (00-no_trnsaction) ,(01 - read), (11-auto_read), (10-write)
MRAM_ADDR               : out std_logic_vector(20 downto 0);
WR_DATA_AHB             : out std_logic_vector(DQ_SIZE-1 downto 0);
RD_DATA_MRAM_EN         : in std_logic;
TRANSACTION_MRAM_DONE   : in std_logic;
RD_DATA_MRAM            : in std_logic_vector(DQ_SIZE-1 downto 0)

);
end entity COREMRAM_AHBLIF;

architecture COREMRAM_AHBLIF_ARCH of COREMRAM_AHBLIF is

   component CDC_FIFO
   generic (
      FAMILY             : integer := 25;    -- Device Family
      MEM_DEPTH          : integer := 4;
      ECC                : integer := 1;
      DATA_WIDTH         : integer := 20
   );
   port (
      W_RST_N            : in std_logic;
      R_RST_N            : in std_logic;
      CLK_WR             : in std_logic;
      CLK_RD             : in std_logic;
      WR_EN              : in std_logic;
      RD_EN              : in std_logic;
      terminate_wr       : in std_logic;
      terminate_rd       : in std_logic;
      DATA_IN            : in std_logic_vector(DATA_WIDTH-1 downto 0);
      DATA_OUT           : out std_logic_vector(DATA_WIDTH-1 downto 0);
      FIFO_FULL          : out std_logic;
      FIFO_EMPTY         : out std_logic;
      error_flag_sb_bd   : out std_logic;   
      error_flag_db_bd   : out std_logic   

   );
   end component;

   component CORESYNC_PULSE_CDC is
   generic (
      FAMILY             : integer := 25;    -- Device Family
      NUM_STAGES         : integer := 2
   );
   port (
      SRC_CLK            : in std_logic;
      DSTN_CLK           : in std_logic;
      SRC_RESET          : in std_logic;
      DSTN_RESET         : in std_logic;
      PULSE_IN           : in std_logic;
      SYNC_PULSE         : out std_logic
   );
   end component;

-------------------------------------signal declaration-----------------------------------------------
signal HREADY_AHB                 : std_logic;
signal HSEL_S                     : std_logic;
signal acen                       : std_logic;
signal HSELREG                    : std_logic;
signal HWRITE_d                   : std_logic;
signal HTRANS_d                   : std_logic_vector(1 downto 0);
signal HTRANS_d1                  : std_logic_vector(1 downto 0);

signal command_latch_en           : std_logic;
signal tx_data_latch_pending      : std_logic;
signal first_mram_trans           : std_logic;
signal new_trans_ahb              : std_logic;
signal new_trans_mram             : std_logic;
signal new_trans_mram_d           : std_logic;
signal new_trans_mram_d1          : std_logic;
signal new_trans_mram_d2          : std_logic;
signal rx_addr_load_en_ahb        : std_logic;
signal rx_addr_load_en_core       : std_logic;
signal rx_addr_load_en_core_d     : std_logic;
signal load_command_ahb           : std_logic;
signal load_command_core          : std_logic;
signal shift_mram_addr_ahb        : std_logic;
signal shift_mram_addr_core       : std_logic;
signal rx_fifo_first_read         : std_logic;

signal rx_fifo_rd_cnt             : std_logic_vector(4 downto 0);
signal cnt_rd                     : std_logic_vector(2 downto 0);
signal rx_fifo_rd_done            : std_logic;

signal tx_fifo_rd_en_ahb          : std_logic;
signal tx_fifo_rd_en_core         : std_logic;
signal tx_fifo_rd_en_core_d       : std_logic;
signal tx_fifo_rd_en_core_d1      : std_logic;
signal tx_fifo_data_out           : std_logic_vector(31 downto 0);
signal tx_fifo_wr_en              : std_logic;
signal rx_fifo_wr_en              : std_logic;
signal rx_fifo_wr_data            : std_logic_vector(31 downto 0);
signal rx_fifo_rd_en              : std_logic;
signal rx_fifo_rd_data            : std_logic_vector(31 downto 0);
signal hdataout_reg               : std_logic_vector(31 downto 0);
signal rx_fifo_rd_en_d            : std_logic;
signal transaction_mram_done_ahb  : std_logic;
signal burst_terminate_ahb        : std_logic;
signal burst_terminate_core       : std_logic;


signal tx_error_flag_sb_bd        : std_logic;   
signal tx_error_flag_db_bd        : std_logic;
signal rx_error_flag_sb_bd        : std_logic;   
signal rx_error_flag_db_bd        : std_logic;  

signal trans_type_ahb             : std_logic_vector(1 downto 0);
signal trans_type_core_s          : std_logic_vector(1 downto 0);
signal trans_type_core            : std_logic_vector(1 downto 0);
signal command                    : std_logic_vector(38 downto 0);
signal command_latch              : std_logic_vector(38 downto 0);
signal tx_fifo_data_en_count      : std_logic_vector(4 downto 0);

signal MRAM_ADDR_1                : std_logic_vector(20 downto 0);
signal MRAM_ADDR_2                : std_logic_vector(20 downto 0);
signal MRAM_ADDR_3                : std_logic_vector(20 downto 0);
signal MRAM_ADDR_4                : std_logic_vector(20 downto 0);
signal command_addr               : std_logic_vector(20 downto 0);
signal command_size               : std_logic_vector(2 downto 0);
signal command_burst              : std_logic_vector(2 downto 0);

signal tx_fifo_data_out_mem_1     : std_logic_vector(DQ_SIZE-1 downto 0);
signal tx_fifo_data_out_mem_2     : std_logic_vector(DQ_SIZE-1 downto 0);
signal tx_fifo_data_out_mem_3     : std_logic_vector(DQ_SIZE-1 downto 0);
signal tx_fifo_data_out_mem_4     : std_logic_vector(DQ_SIZE-1 downto 0);
signal number_of_mram_trans       : std_logic_vector(2 downto 0);
signal number_of_mram_trans_ahb   : std_logic_vector(2 downto 0);
signal number_of_mram_trans_ahb_s : std_logic_vector(2 downto 0);
signal number_of_mram_trans_cnt   : std_logic_vector(2 downto 0);
signal number_of_ahb_trans_cnt    : std_logic_vector(4 downto 0);
signal number_of_ahb_trans        : std_logic_vector(4 downto 0);
signal wr_follow_rd               : std_logic;
signal wr_follow_rd_core          : std_logic;
signal wr_follow_rd_core_s        : std_logic;

type State_type is (IDLE, ADDRESS, TX_FIFO_WR,MEM_WR, MEM_RD,AHB_RD);  -- Define the states
signal state_ahb : State_Type;    -- Create a signal that uses 

constant  SYNC_RESET : INTEGER := SYNC_MODE_SEL(FAMILY);
signal    acoreresetn          : std_logic;
signal    scoreresetn          : std_logic;
signal    ahresetn             : std_logic;
signal    shresetn             : std_logic;

begin

acoreresetn <= '1' WHEN (SYNC_RESET=1) ELSE CORECLK_RESETN;
scoreresetn <= CORECLK_RESETN WHEN (SYNC_RESET=1) ELSE '1';

ahresetn <= '1' WHEN (SYNC_RESET=1) ELSE HRESETN;
shresetn <= HRESETN WHEN (SYNC_RESET=1) ELSE '1';


process (CORE_CLK, acoreresetn) 
begin
   if (acoreresetn = '0') then           
      new_trans_mram_d <= '0' ;
      new_trans_mram_d1 <= '0' ;
      new_trans_mram_d2 <= '0' ;
   elsif rising_edge(CORE_CLK) then
      if (scoreresetn = '0') then  
         new_trans_mram_d <= '0' ;
         new_trans_mram_d1 <= '0' ;
         new_trans_mram_d2 <= '0' ;
      else
         new_trans_mram_d <= new_trans_mram ; 
         new_trans_mram_d1 <= new_trans_mram_d ; 
         new_trans_mram_d2 <= new_trans_mram_d1 ; 
      end if;
   end if;
end process;

process (HCLK, ahresetn) 
begin
   if (ahresetn = '0') then           
      number_of_mram_trans_ahb   <= "000" ;
      number_of_mram_trans_ahb_s <= "000" ;
   elsif rising_edge(HCLK) then
      if (shresetn = '0') then           
         number_of_mram_trans_ahb   <= "000" ;
         number_of_mram_trans_ahb_s <= "000" ;
      else
         number_of_mram_trans_ahb_s <= number_of_mram_trans ; 
         number_of_mram_trans_ahb   <= number_of_mram_trans_ahb_s ; 
      end if;
   end if;
end process;

process (CORE_CLK, acoreresetn) 
begin
   if (acoreresetn = '0') then           
      trans_type_core_s <= "00" ;
      trans_type_core   <= "00" ;
   elsif rising_edge(CORE_CLK) then 
      if (scoreresetn = '0') then           
         trans_type_core_s <= "00" ;
         trans_type_core   <= "00" ;
      else
         trans_type_core_s <= trans_type_ahb ; 
         trans_type_core   <= trans_type_core_s ; 
      end if;
   end if;
end process;

process (CORE_CLK, acoreresetn) 
begin
   if (acoreresetn = '0') then           
      wr_follow_rd_core <= '0' ;
      wr_follow_rd_core_s <= '0' ;
   elsif rising_edge(CORE_CLK) then 
      if (scoreresetn = '0') then           
         wr_follow_rd_core <= '0' ;
         wr_follow_rd_core_s <= '0' ;
      else
         wr_follow_rd_core_s <= wr_follow_rd ; 
         wr_follow_rd_core   <= wr_follow_rd_core_s ; 
      end if;
   end if;
end process;

process (CORE_CLK, acoreresetn) 
begin
   if (acoreresetn = '0') then           
      tx_fifo_rd_en_core_d <= '0' ;
      tx_fifo_rd_en_core_d1 <= '0' ;
   elsif rising_edge(CORE_CLK) then
      if(scoreresetn = '0')then
         tx_fifo_rd_en_core_d <= '0' ;
         tx_fifo_rd_en_core_d1 <= '0' ;
      else 
         tx_fifo_rd_en_core_d <= tx_fifo_rd_en_core ; 
         tx_fifo_rd_en_core_d1 <= tx_fifo_rd_en_core_d ; 
      end if;
   end if;
end process;

   CORESYNC_TERMINATE : CORESYNC_PULSE_CDC 
      generic map(
         FAMILY            => FAMILY,
         NUM_STAGES        => 2
      )
      port map (
         SRC_CLK           => HCLK ,
         DSTN_CLK          => CORE_CLK,
         SRC_RESET         => HRESETN ,
         DSTN_RESET        => CORECLK_RESETN ,
         PULSE_IN          => burst_terminate_ahb ,
         SYNC_PULSE        => burst_terminate_core
    );

   CORESYNC_NEW_TRANS_MRAM : CORESYNC_PULSE_CDC 
      generic map(
         FAMILY            => FAMILY,
         NUM_STAGES        => 2
      )
      port map (
         SRC_CLK           => HCLK ,
         DSTN_CLK          => CORE_CLK,
         SRC_RESET         => HRESETN ,
         DSTN_RESET        => CORECLK_RESETN ,
         PULSE_IN          => new_trans_ahb ,
         SYNC_PULSE        => new_trans_mram
    );
    
    CORESYNC_TX_FIFO_RD_EN : CORESYNC_PULSE_CDC 
      generic map(
         FAMILY            => FAMILY,
         NUM_STAGES        => 2
      )
      port map (
         SRC_CLK           => HCLK ,
         DSTN_CLK          => CORE_CLK,
         SRC_RESET         => HRESETN ,
         DSTN_RESET        => CORECLK_RESETN ,
         PULSE_IN          => tx_fifo_rd_en_ahb ,
         SYNC_PULSE        => tx_fifo_rd_en_core
    );

    CORESYNC_RX_ADDR_LOAD_EN : CORESYNC_PULSE_CDC 
      generic map(
         FAMILY            => FAMILY,
         NUM_STAGES        => 2
      )
      port map (
         SRC_CLK           => HCLK ,
         DSTN_CLK          => CORE_CLK,
         SRC_RESET         => HRESETN ,
         DSTN_RESET        => CORECLK_RESETN ,
         PULSE_IN          => rx_addr_load_en_ahb ,
         SYNC_PULSE        => rx_addr_load_en_core
    );
   
    CORESYNC_SHIFT_MRAM_ADDR_EN : CORESYNC_PULSE_CDC 
      generic map(
         FAMILY            => FAMILY,
         NUM_STAGES        => 2
      )
      port map (
         SRC_CLK           => HCLK ,
         DSTN_CLK          => CORE_CLK,
         SRC_RESET         => HRESETN ,
         DSTN_RESET        => CORECLK_RESETN ,
         PULSE_IN          => shift_mram_addr_ahb ,
         SYNC_PULSE        => shift_mram_addr_core
    );

    CORESYNC_TRANSACTION_DONE: CORESYNC_PULSE_CDC 
      generic map(
         FAMILY            => FAMILY,
         NUM_STAGES        => 2
      )
      port map (
         SRC_CLK           => CORE_CLK ,
         DSTN_CLK          => HCLK,
         SRC_RESET         => CORECLK_RESETN ,
         DSTN_RESET        => HRESETN  ,
         PULSE_IN          => TRANSACTION_MRAM_DONE ,
         SYNC_PULSE        => transaction_mram_done_ahb 
    );
   
    coresync_load_address : CORESYNC_PULSE_CDC 
      generic map(
         FAMILY            => FAMILY,
         NUM_STAGES        => 2
      )
      port map (
         SRC_CLK           => HCLK ,
         DSTN_CLK          => CORE_CLK,
         SRC_RESET         => HRESETN ,
         DSTN_RESET        => CORECLK_RESETN ,
         PULSE_IN          => load_command_ahb ,
         SYNC_PULSE        => load_command_core
    );


    TX_DATA_FIFO : CDC_FIFO
      generic map(
         FAMILY            => FAMILY,
         MEM_DEPTH         => BUFFER_DEPTH,
         ECC               => ECC,
         DATA_WIDTH        => 32
      )
      port map (
         W_RST_N           => HRESETN,                                  
         R_RST_N           => CORECLK_RESETN, 
         CLK_WR            => HCLK,                                 
         CLK_RD            => CORE_CLK,                                  
         WR_EN             => tx_fifo_wr_en,                                   
         RD_EN             => tx_fifo_rd_en_core_d1,                                   
         terminate_wr      => '0',
         terminate_rd      => '0',                               
         DATA_IN           => HWDATA ,                
         DATA_OUT          => tx_fifo_data_out, 
         error_flag_sb_bd  => tx_error_flag_sb_bd,   
         error_flag_db_bd  => tx_error_flag_db_bd,
         FIFO_FULL         => open,                                  
         FIFO_EMPTY        => open
      ); 

   RX_DATA_FIFO : CDC_FIFO
      generic map(
         FAMILY            => FAMILY,
         MEM_DEPTH         => BUFFER_DEPTH,
         ECC               => ECC,
         DATA_WIDTH        => 32
      )
      port map (
         W_RST_N           => CORECLK_RESETN,                                  
         R_RST_N           => HRESETN, 
         CLK_WR            => CORE_CLK ,                                 
         CLK_RD            => HCLK ,                                  
         WR_EN             => rx_fifo_wr_en,                                   
         RD_EN             => rx_fifo_rd_en,                                   
         terminate_wr      => burst_terminate_core ,
         terminate_rd      => burst_terminate_ahb ,                                   
         DATA_IN           => rx_fifo_wr_data ,                
         DATA_OUT          => rx_fifo_rd_data , 
         error_flag_sb_bd  => rx_error_flag_sb_bd,   
         error_flag_db_bd  => rx_error_flag_db_bd,  
         FIFO_FULL         => open ,                                  
         FIFO_EMPTY        => open
      ); 

process (HCLK, ahresetn) 
begin
   if (ahresetn = '0') then           
      HSELREG <= '0' ;
   elsif rising_edge(HCLK) then
      if (shresetn = '0') then           
         HSELREG <= '0' ;
      else
         if (HREADYIN = '1') then
            HSELREG <= HSEL_S ; 
         end if; 
      end if; 
   end if;
end process;

process (HCLK, ahresetn) 
begin
   if (ahresetn = '0') then           
      HWRITE_d  <= '0' ;
   elsif rising_edge(HCLK) then 
      if (shresetn = '0') then           
         HWRITE_d  <= '0' ;
      else
         if (acen = '1') then
            HWRITE_d  <= HWRITE ;
         end if; 
      end if; 
   end if;
end process;

process (HCLK, ahresetn) 
begin
   if (ahresetn = '0') then           
      HTRANS_d       <= "00" ;
      HTRANS_d1      <= "00" ;
   elsif rising_edge(HCLK) then
      if (shresetn = '0') then           
         HTRANS_d       <= "00" ;
         HTRANS_d1      <= "00" ;
      else
         HTRANS_d1<= HTRANS ;
         if (acen = '1') then
            HTRANS_d<= HTRANS ;
         end if; 
      end if; 
   end if;
end process;

process (CORE_CLK, acoreresetn) 
begin
   if (acoreresetn = '0') then           
      command_addr            <= (others =>'0') ;
      command_size            <= (others =>'0') ;
      command_burst           <= (others =>'0') ;
   elsif rising_edge(CORE_CLK) then
      if (scoreresetn = '0') then           
         command_addr            <= (others =>'0') ;
         command_size            <= (others =>'0') ;
         command_burst           <= (others =>'0') ;
      else
         if (load_command_core = '1') then
            command_addr  <= command(20 downto 0);
            command_size  <= command(37 downto 35);
            if( command(37 downto 35)="000" and BYTE_MODE_EN = 0 ) then
               command_burst <= "000";
            else
               command_burst <= command(34 downto 32);
            end if;
         elsif(shift_mram_addr_core ='1') then 
            if (command_burst = "010")  then
               if(command_size = "000") then
                  if (command_addr(1 downto 0) = "11") then
                     command_addr <= command_addr(20 downto 2) & "00";
                  else
                     command_addr <= command_addr + '1';
                  end if;
               elsif(command_size = "001") then
                  if (command_addr(2 downto 0) = "110") then
                     command_addr <= command_addr(20 downto 3) & "000";
                  else
                     command_addr <= command_addr + "10";
                  end if;
               elsif(command_size = "010") then
                  if (command_addr(3 downto 0) = "1100") then
                     command_addr <= command_addr(20 downto 4) & "0000";
                  else
                     command_addr <= command_addr + "100";
                  end if;
               end if;
            elsif (command_burst = "011")  then
               if(command_size = "000") then
                  command_addr <= command_addr + "1";
               elsif(command_size = "001") then
                  command_addr <= command_addr + "10";
               elsif(command_size = "010") then
                  command_addr <= command_addr + "100";
               end if;
            elsif (command_burst = "100")  then
               if(command_size = "000") then
                  if (command_addr(2 downto 0) = "111") then
                     command_addr <= command_addr(20 downto 3) & "000";
                  else
                     command_addr <= command_addr + "1";
                  end if;
            elsif(command_size = "001") then
                  if (command_addr(3 downto 0) = "1110") then
                     command_addr <= command_addr(20 downto 4) & "0000";
                  else
                     command_addr <= command_addr + "10";
                  end if;
               elsif(command_size = "010") then
                  if (command_addr(4 downto 0) = "11100") then
                     command_addr <= command_addr(20 downto 5) & "00000";
                  else
                     command_addr <= command_addr + "100";
                  end if;
               end if;
            elsif (command_burst = "101")  then
               if(command_size = "000") then
                  command_addr <= command_addr + "1";
               elsif(command_size = "001") then
                  command_addr <= command_addr + "10";
               elsif(command_size = "010") then
                  command_addr <= command_addr + "100";
               end if;
            elsif (command_burst = "110")  then
               if(command_size = "000") then
                  if (command_addr(3 downto 0) = "1111") then
                     command_addr <= command_addr(20 downto 4) & "0000";
                  else
                     command_addr <= command_addr + "1";
                  end if;
               elsif(command_size = "001") then
                  if (command_addr(4 downto 0) = "11110") then
                     command_addr <= command_addr(20 downto 5) & "00000";
                  else
                     command_addr <= command_addr + "10";
                  end if;
               elsif(command_size = "010") then
                  if (command_addr(5 downto 0) = "111100") then
                     command_addr <= command_addr(20 downto 6) & "000000";
                  else
                     command_addr <= command_addr + "100";
                  end if;
               end if;
            elsif (command_burst = "111")  then
               if(command_size = "000") then
                  command_addr <= command_addr + "1";
               elsif(command_size = "001") then
                  command_addr <= command_addr + "10";
               elsif(command_size = "010") then
                  command_addr <= command_addr + "100";
               end if;
            end if;
         else 
            command_addr<=command_addr;
         end if;
      end if;
   end if;
end process;


DQ_16_fifo_wr_data : if BYTE_MODE_EN = 0 generate

process (CORE_CLK, acoreresetn) 
begin
   if (acoreresetn = '0') then           
      rx_fifo_wr_data     <= (others =>'0') ;
      rx_fifo_wr_en       <= '0' ;
      cnt_rd              <= (others =>'0') ;
   elsif rising_edge(CORE_CLK) then
      if (scoreresetn = '0') then           
         rx_fifo_wr_data     <= (others =>'0') ;
         rx_fifo_wr_en       <= '0' ;
         cnt_rd              <= (others =>'0') ;
       else
         if(RD_DATA_MRAM_EN ='1' and wr_follow_rd_core = '0') then
            if (cnt_rd ="00") then
               if(command_size = "000") then
                  if(command_addr(1 downto 0) = "00") then
                     rx_fifo_wr_data(7 downto 0)   <= RD_DATA_MRAM(7 downto 0) ;
                     rx_fifo_wr_data(31 downto 8)  <= (others =>'0') ;
                  elsif( command_addr(1 downto 0) = "01") then
                     rx_fifo_wr_data(7 downto 0)   <= (others =>'0') ;
                     rx_fifo_wr_data(15 downto 8)   <= RD_DATA_MRAM(15 downto 8) ;
                     rx_fifo_wr_data(31 downto 16)   <= (others =>'0') ;
                  elsif(command_addr(1 downto 0) = "10") then
                     rx_fifo_wr_data(15 downto 0)   <= (others =>'0') ;
                     rx_fifo_wr_data(23 downto 16)   <= RD_DATA_MRAM(7 downto 0) ;
                     rx_fifo_wr_data(31 downto 24)   <=(others =>'0') ;
                  else
                     rx_fifo_wr_data(23 downto 0)  <= (others =>'0') ;
                     rx_fifo_wr_data(31 downto 24)  <= RD_DATA_MRAM(15 downto 8) ;
                  end if;
                  rx_fifo_wr_en              <= '1' ;
                  cnt_rd                     <= "000";
               elsif(command_size = "001") then
                  if(command_addr(1) = '0') then
                     rx_fifo_wr_data(15 downto 0)  <= RD_DATA_MRAM ;
                  else
                     rx_fifo_wr_data(31 downto 16) <= RD_DATA_MRAM ;
                  end if;
                  rx_fifo_wr_en              <= '1' ;
                  cnt_rd                     <= "000";
               elsif(command_size = "010") then
                  rx_fifo_wr_data(15 downto 0)<= RD_DATA_MRAM ;
                  rx_fifo_wr_en               <= '0' ;
                  cnt_rd                      <= cnt_rd +'1';
               end if;
            elsif (cnt_rd ="01") then
               rx_fifo_wr_data(31 downto 16)<= RD_DATA_MRAM ;
               rx_fifo_wr_en                <= '1' ;
               cnt_rd                       <= "000";
            end if;
         else
            rx_fifo_wr_en              <= '0' ;
         end if;
      end if;
   end if;
end process;

end generate DQ_16_fifo_wr_data;


DQ_8_fifo_wr_data : if BYTE_MODE_EN = 1 generate

process (CORE_CLK, acoreresetn) 
begin
   if (acoreresetn = '0') then           
      rx_fifo_wr_data     <= (others =>'0') ;
      rx_fifo_wr_en       <= '0' ;
      cnt_rd              <= (others =>'0') ;
   elsif rising_edge(CORE_CLK) then
      if (scoreresetn = '0') then           
         rx_fifo_wr_data     <= (others =>'0') ;
         rx_fifo_wr_en       <= '0' ;
         cnt_rd              <= (others =>'0') ;
      else
         if(RD_DATA_MRAM_EN ='1') then
            if (cnt_rd ="000") then
               if(command_size = "000") then
                  if(command_addr(1 downto 0) = "00") then
                     rx_fifo_wr_data(7 downto 0)   <= RD_DATA_MRAM ;
                  elsif (command_addr(1 downto 0) = "01") then
                     rx_fifo_wr_data(15 downto 8)  <= RD_DATA_MRAM ;
                  elsif (command_addr(1 downto 0) = "10") then
                     rx_fifo_wr_data(23 downto 16) <= RD_DATA_MRAM ;
                  else
                     rx_fifo_wr_data(31 downto 24) <= RD_DATA_MRAM ;
                  end if;
                  rx_fifo_wr_en              <= '1' ;
                  cnt_rd                     <= "000";
               elsif(command_size = "001") then
                  if(command_addr(1 downto 0) = "00") then
                     rx_fifo_wr_data(7 downto 0)   <= RD_DATA_MRAM ;
                  else
                     rx_fifo_wr_data(23 downto 16) <= RD_DATA_MRAM ;
                  end if;
                  rx_fifo_wr_en              <= '0' ;
                  cnt_rd                     <= cnt_rd +'1';
               elsif(command_size = "010") then
                  rx_fifo_wr_data(7 downto 0)<= RD_DATA_MRAM ;
                  rx_fifo_wr_en              <= '0' ;
                  cnt_rd                     <= cnt_rd +'1';
               end if;
            elsif (cnt_rd ="001") then
               if(command_size = "001") then
                  if(command_addr(1 downto 0) = "00") then
                     rx_fifo_wr_data(15 downto 8)  <= RD_DATA_MRAM ;
                  else
                     rx_fifo_wr_data(31 downto 24) <= RD_DATA_MRAM ;
                  end if;
                  rx_fifo_wr_en                <= '1' ;
                  cnt_rd                       <= "000";
               else
                  rx_fifo_wr_data(15 downto 8) <= RD_DATA_MRAM ;
                  rx_fifo_wr_en                <= '0' ;
                  cnt_rd                       <= cnt_rd +'1';
               end if;
            elsif (cnt_rd ="010") then
               rx_fifo_wr_data(23 downto 16)<= RD_DATA_MRAM ;
               rx_fifo_wr_en                <= '0' ;
               cnt_rd                       <= cnt_rd +'1';
            elsif (cnt_rd ="011") then
               rx_fifo_wr_data(31 downto 24)<= RD_DATA_MRAM ;
               rx_fifo_wr_en                <= '1' ;
               cnt_rd                       <= "000";
            end if;
         else
            rx_fifo_wr_en              <= '0' ;
         end if;
      end if;
   end if;
end process;

end generate DQ_8_fifo_wr_data;

process (HCLK, ahresetn) 
begin
   if (ahresetn = '0') then     
      rx_fifo_rd_cnt     <= (others =>'0'); 
      rx_fifo_rd_done <= '0';
   elsif rising_edge(HCLK) then
      if (shresetn = '0') then     
         rx_fifo_rd_cnt     <= (others =>'0'); 
         rx_fifo_rd_done <= '0';
      else
         if (rx_fifo_first_read ='1' or (((state_ahb = AHB_RD) and (acen ='1')) and ((HTRANS = "10") or (HTRANS = "11"))) ) then
            if(command_burst = "000" or command_burst = "001" ) then
               rx_fifo_rd_done <= '1';
            elsif (command_burst = "010" or command_burst  = "011") then
               if(rx_fifo_rd_cnt = "00100" ) then
                  rx_fifo_rd_cnt     <= (others =>'0'); 
                  rx_fifo_rd_done    <= '0';
               elsif(rx_fifo_rd_cnt = "00011" ) then
                  rx_fifo_rd_done    <= '1';
                  rx_fifo_rd_cnt <= rx_fifo_rd_cnt + '1' ; 
               else
                  rx_fifo_rd_cnt <= rx_fifo_rd_cnt + '1' ; 
               end if;
            elsif (command_burst = "100" or command_burst  = "101") then
               if(rx_fifo_rd_cnt = "01000" )then
                  rx_fifo_rd_cnt     <= (others =>'0'); 
                  rx_fifo_rd_done    <= '0';
               elsif(rx_fifo_rd_cnt = "00111" ) then
                  rx_fifo_rd_done    <= '1';
                  rx_fifo_rd_cnt <= rx_fifo_rd_cnt + '1' ; 
               else 
                  rx_fifo_rd_cnt <= rx_fifo_rd_cnt + '1' ; 
               end if;
            elsif (command_burst = "110" or command_burst  = "111") then
               if(rx_fifo_rd_cnt = "10000" ) then
                  rx_fifo_rd_cnt     <= (others =>'0'); 
                  rx_fifo_rd_done    <= '0';
               elsif(rx_fifo_rd_cnt = "01111" ) then
                  rx_fifo_rd_done    <= '1';
                  rx_fifo_rd_cnt <= rx_fifo_rd_cnt + '1' ; 
               else 
                  rx_fifo_rd_cnt <= rx_fifo_rd_cnt + '1' ; 
               end if;
            end if;
         elsif ((acen ='1') and (HTRANS = "01")) then
            rx_fifo_rd_done <=rx_fifo_rd_done;
            rx_fifo_rd_cnt  <=rx_fifo_rd_cnt ; 
         else 
            rx_fifo_rd_done <='0';
            rx_fifo_rd_cnt     <= (others =>'0'); 
         end if;  
      end if;
   end if;
end process;

process (HCLK, ahresetn) 
begin
   if (ahresetn = '0') then     
      rx_fifo_rd_en_d <= '0' ;
   elsif rising_edge(HCLK) then
      if (shresetn = '0') then     
         rx_fifo_rd_en_d <= '0' ;
      else
         rx_fifo_rd_en_d <=rx_fifo_rd_en;
      end if;
   end if;
end process;

process (CORE_CLK, acoreresetn) 
begin
   if (acoreresetn = '0') then     
      rx_addr_load_en_core_d <= '0' ;
   elsif rising_edge(CORE_CLK) then
      if (scoreresetn = '0') then     
         rx_addr_load_en_core_d <= '0' ;
      else
         rx_addr_load_en_core_d <=rx_addr_load_en_core;
      end if;
   end if;
end process;

DQ_16_MRAM_ADDR : if BYTE_MODE_EN = 0 generate

process (CORE_CLK, acoreresetn) 
begin
   if (acoreresetn = '0') then           
      tx_fifo_data_out_mem_1 <= (others =>'0') ;
      tx_fifo_data_out_mem_2 <= (others =>'0') ;
      MRAM_ADDR_1            <= (others =>'0') ;
      MRAM_ADDR_2            <= (others =>'0') ;
      number_of_mram_trans   <= (others =>'0') ;
   elsif rising_edge(CORE_CLK) then
      if (scoreresetn = '0') then           
         tx_fifo_data_out_mem_1 <= (others =>'0') ;
         tx_fifo_data_out_mem_2 <= (others =>'0') ;
         MRAM_ADDR_1            <= (others =>'0') ;
         MRAM_ADDR_2            <= (others =>'0') ;
         number_of_mram_trans   <= (others =>'0') ;
      else
         if (tx_fifo_rd_en_core_d1 = '1' or rx_addr_load_en_core_d = '1') then
            if(command_size = "000" and command_addr(1 downto 0) = "00" ) then
               if(wr_follow_rd_core='1') then
                  tx_fifo_data_out_mem_1 <=RD_DATA_MRAM(15 downto 8) & tx_fifo_data_out(7 downto 0) ;
               else
                  tx_fifo_data_out_mem_1 <= tx_fifo_data_out(15 downto 0) ;
               end if;
               number_of_mram_trans   <= "001";
               MRAM_ADDR_1            <= '0'& command_addr(20 downto 1);
            elsif(command_size = "000" and command_addr(1 downto 0) = "01" ) then
               if(wr_follow_rd_core='1') then
                  tx_fifo_data_out_mem_1 <= tx_fifo_data_out(15 downto 8) & RD_DATA_MRAM(7 downto 0) ;
               else
                  tx_fifo_data_out_mem_1 <= tx_fifo_data_out(15 downto 0) ;
               end if;
               number_of_mram_trans   <= "001";
               MRAM_ADDR_1            <= '0'& command_addr(20 downto 1);
            elsif(command_size = "000" and command_addr(1 downto 0) = "10" ) then
               if(wr_follow_rd_core='1') then
                  tx_fifo_data_out_mem_1 <= RD_DATA_MRAM(15 downto 8) & tx_fifo_data_out(23 downto 16) ;
               else
                  tx_fifo_data_out_mem_1 <= tx_fifo_data_out(31 downto 16) ;
               end if;
               number_of_mram_trans   <= "001";
               MRAM_ADDR_1            <= '0' & command_addr(20 downto 1);
            elsif(command_size = "000" and command_addr(1 downto 0) = "11" ) then
               if(wr_follow_rd_core='1') then
                  tx_fifo_data_out_mem_1 <= tx_fifo_data_out(31 downto 24) & RD_DATA_MRAM(7 downto 0) ;
               else
                  tx_fifo_data_out_mem_1 <= tx_fifo_data_out(31 downto 16) ;
               end if;
               number_of_mram_trans   <= "001";
               MRAM_ADDR_1            <= '0' & command_addr(20 downto 1);
            elsif(command_size = "001" and command_addr(1) = '0' ) then
               tx_fifo_data_out_mem_1 <= tx_fifo_data_out(15 downto 0) ;
               number_of_mram_trans   <= "001";
               MRAM_ADDR_1            <= ('0' & command_addr(20 downto 1));
            elsif(command_size = "001" and command_addr(1) = '1' ) then
               tx_fifo_data_out_mem_1 <= tx_fifo_data_out(31 downto 16) ;
               number_of_mram_trans   <= "001";
               MRAM_ADDR_1            <= '0' & command_addr(20 downto 1);
            elsif(command_size = "010") then
               tx_fifo_data_out_mem_1 <= tx_fifo_data_out(15 downto 0) ;
               tx_fifo_data_out_mem_2 <= tx_fifo_data_out(31 downto 16) ;
               number_of_mram_trans   <= "010";
               MRAM_ADDR_1            <= '0' & command_addr(20 downto 1);
               MRAM_ADDR_2            <= ('0' & command_addr(20 downto 2) & '1');
            end if;
         else
            tx_fifo_data_out_mem_1    <= tx_fifo_data_out_mem_1 ;
            tx_fifo_data_out_mem_2    <= tx_fifo_data_out_mem_2 ;
         end if; 
      end if;
   end if;  
end process ;

 MRAM_ADDR             <= MRAM_ADDR_1 when ( number_of_mram_trans_cnt = "001") else MRAM_ADDR_2 ; 
 WR_DATA_AHB           <= tx_fifo_data_out_mem_1 when ( number_of_mram_trans_cnt = "001") else tx_fifo_data_out_mem_2 ;

end generate DQ_16_MRAM_ADDR;





DQ_8_MRAM_ADDR : if BYTE_MODE_EN = 1 generate

process (CORE_CLK, acoreresetn) 
begin
   if (acoreresetn = '0') then           
      tx_fifo_data_out_mem_1 <= (others =>'0') ;
      tx_fifo_data_out_mem_2 <= (others =>'0') ;
      tx_fifo_data_out_mem_3 <= (others =>'0') ;
      tx_fifo_data_out_mem_4 <= (others =>'0') ;
      MRAM_ADDR_1            <= (others =>'0') ;
      MRAM_ADDR_2            <= (others =>'0') ;
      MRAM_ADDR_3            <= (others =>'0') ;
      MRAM_ADDR_4            <= (others =>'0') ;
      number_of_mram_trans   <= (others =>'0') ;
   elsif rising_edge(CORE_CLK) then
      if (scoreresetn = '0') then           
         tx_fifo_data_out_mem_1 <= (others =>'0') ;
         tx_fifo_data_out_mem_2 <= (others =>'0') ;
         tx_fifo_data_out_mem_3 <= (others =>'0') ;
         tx_fifo_data_out_mem_4 <= (others =>'0') ;
         MRAM_ADDR_1            <= (others =>'0') ;
         MRAM_ADDR_2            <= (others =>'0') ;
         MRAM_ADDR_3            <= (others =>'0') ;
         MRAM_ADDR_4            <= (others =>'0') ;
         number_of_mram_trans   <= (others =>'0') ;
      else
         if (tx_fifo_rd_en_core_d1 = '1' or rx_addr_load_en_core_d = '1') then
            if(command_size = "000" and command_addr(1 downto 0) = "00" ) then
               tx_fifo_data_out_mem_1 <= tx_fifo_data_out(7 downto 0) ;
               number_of_mram_trans   <= "001";
               MRAM_ADDR_1            <= command_addr(20 downto 0);
            elsif(command_size = "000" and command_addr(1 downto 0) = "01" ) then
               tx_fifo_data_out_mem_1 <= tx_fifo_data_out(15 downto 8) ;
               number_of_mram_trans   <= "001";
               MRAM_ADDR_1            <= command_addr(20 downto 0);
            elsif(command_size = "000" and command_addr(1 downto 0) = "10" ) then
               tx_fifo_data_out_mem_1 <= tx_fifo_data_out(23 downto 16) ;
               number_of_mram_trans   <= "001";
               MRAM_ADDR_1            <= command_addr(20 downto 0);
            elsif(command_size = "000" and command_addr(1 downto 0) = "11" ) then
               tx_fifo_data_out_mem_1 <= tx_fifo_data_out(31 downto 24) ;
               number_of_mram_trans   <= "001";
               MRAM_ADDR_1            <= command_addr(20 downto 0);
            elsif(command_size = "001" and command_addr(1) = '0' ) then
               tx_fifo_data_out_mem_1 <= tx_fifo_data_out(7 downto 0) ;
               tx_fifo_data_out_mem_2 <= tx_fifo_data_out(15 downto 8) ;
               number_of_mram_trans   <= "010";
               MRAM_ADDR_1            <= command_addr(20 downto 0);
               MRAM_ADDR_2            <= (command_addr(20 downto 1) & '1');
            elsif(command_size = "001" and command_addr(1) = '1' ) then
               tx_fifo_data_out_mem_1 <= tx_fifo_data_out(23 downto 16) ;
               tx_fifo_data_out_mem_2 <= tx_fifo_data_out(31 downto 24) ;
               number_of_mram_trans   <= "010";
               MRAM_ADDR_1            <= command_addr(20 downto 0);
               MRAM_ADDR_2            <= (command_addr(20 downto 1) & '1');
            elsif(command_size = "010") then
               tx_fifo_data_out_mem_1 <= tx_fifo_data_out(7 downto 0) ;
               tx_fifo_data_out_mem_2 <= tx_fifo_data_out(15 downto 8) ;
               tx_fifo_data_out_mem_3 <= tx_fifo_data_out(23 downto 16) ;
               tx_fifo_data_out_mem_4 <= tx_fifo_data_out(31 downto 24) ;
               number_of_mram_trans   <= "100";
               MRAM_ADDR_1            <= command_addr(20 downto 0);
               MRAM_ADDR_2            <= (command_addr(20 downto 2) & "01");
               MRAM_ADDR_3            <= (command_addr(20 downto 2) & "10");
               MRAM_ADDR_4            <= (command_addr(20 downto 2) & "11");
        end if;
         else
            tx_fifo_data_out_mem_1    <= tx_fifo_data_out_mem_1 ;
            tx_fifo_data_out_mem_2    <= tx_fifo_data_out_mem_2 ;
            tx_fifo_data_out_mem_3    <= tx_fifo_data_out_mem_3 ;
            tx_fifo_data_out_mem_4    <= tx_fifo_data_out_mem_4 ;
         end if; 
      end if; 
   end if;
end process;
MRAM_ADDR             <= MRAM_ADDR_1 when ( number_of_mram_trans_cnt = "001") else MRAM_ADDR_2 when ( number_of_mram_trans_cnt = "010") else MRAM_ADDR_3 when ( number_of_mram_trans_cnt = "011") else MRAM_ADDR_4 ; 
WR_DATA_AHB           <= tx_fifo_data_out_mem_1 when ( number_of_mram_trans_cnt = "001") else tx_fifo_data_out_mem_2 when ( number_of_mram_trans_cnt = "010") 
                         else tx_fifo_data_out_mem_3  when ( number_of_mram_trans_cnt = "011") else tx_fifo_data_out_mem_4 ; 

end generate DQ_8_MRAM_ADDR;




process (HCLK, ahresetn) 
begin 
   if (ahresetn = '0') then           
      state_ahb                 <= IDLE;
      HREADY_AHB                <= '1' ;
      first_mram_trans          <= '0';
      new_trans_ahb             <= '0';
      tx_fifo_rd_en_ahb         <= '0'; 
      rx_addr_load_en_ahb       <= '0'; 
      load_command_ahb          <= '0';
      shift_mram_addr_ahb       <= '0';
      rx_fifo_first_read        <= '0';
      number_of_mram_trans_cnt  <= "000" ;
      number_of_ahb_trans_cnt   <= "00001" ;
      trans_type_ahb            <= (others =>'0');  --- sync not required from ahb domain to core clk domain
      tx_fifo_data_en_count     <= "00001"; 
      number_of_ahb_trans       <= "00000";
      command                   <=(others =>'0');
      command_latch             <=(others =>'0');
      command_latch_en          <= '0';
      burst_terminate_ahb       <= '0';
      tx_data_latch_pending     <= '0';
      wr_follow_rd              <= '0';
   elsif rising_edge(HCLK) then 
      if (shresetn = '0') then           
         state_ahb                 <= IDLE;
         HREADY_AHB                <= '1' ;
         first_mram_trans          <= '0';
         new_trans_ahb             <= '0';
         tx_fifo_rd_en_ahb         <= '0'; 
         rx_addr_load_en_ahb       <= '0'; 
         load_command_ahb          <= '0';
         shift_mram_addr_ahb       <= '0';
         rx_fifo_first_read        <= '0';
         number_of_mram_trans_cnt  <= "000" ;
         number_of_ahb_trans_cnt   <= "00001" ;
         trans_type_ahb            <= (others =>'0');  --- sync not required from ahb domain to core clk domain
         tx_fifo_data_en_count     <= "00001"; 
         number_of_ahb_trans       <= "00000";
         command                   <=(others =>'0');
         command_latch             <=(others =>'0');
         command_latch_en          <= '0';
         burst_terminate_ahb       <= '0';
         tx_data_latch_pending     <= '0';
         wr_follow_rd              <= '0';
      else
         case state_ahb is
            when IDLE =>
               state_ahb           <= ADDRESS ; 
               HREADY_AHB          <= '1' ;
               trans_type_ahb      <= "00";
               burst_terminate_ahb <= '0';
            when ADDRESS => 
               burst_terminate_ahb      <= '0';
               if (( acen ='1') and ((HTRANS = "10") or ((HBURST ="001" or HSIZE="000") and HTRANS = "11"))) then
                  command       <= HWRITE & HSIZE & HBURST & HADDR ;
                  if (HWRITE = '1') then 
                     HREADY_AHB         <= '1';
                     load_command_ahb   <= '1';
                     state_ahb          <= TX_FIFO_WR ;
                     tx_data_latch_pending     <= '1';
                     if(HSIZE = "000" and  BYTE_MODE_EN = 0 ) then
                        wr_follow_rd       <= '1';
                        trans_type_ahb     <= "01"; --write
                     else
                        wr_follow_rd       <= '0';
                        trans_type_ahb     <= "10"; --write
                     end if;                   
                  else 
                     HREADY_AHB         <= '0';
                     load_command_ahb   <= '1';
                     first_mram_trans   <= '1';
                     trans_type_ahb     <= "01"; --read
                     state_ahb          <= MEM_RD ;
                     if (((HBURST = "000" or HBURST = "001" or HSIZE ="000") and  BYTE_MODE_EN = 0 )  or ((HBURST = "000" or HBURST = "001" ) and  BYTE_MODE_EN = 1 )) then
                        number_of_ahb_trans       <= "00001";
                     elsif ((HBURST = "010") or (HBURST = "011")) then
                        number_of_ahb_trans       <= "00100";
                     elsif ((HBURST = "100") or (HBURST = "101")) then
                        number_of_ahb_trans       <= "01000";
                     elsif ((HBURST= "110") or (HBURST = "111")) then
                        number_of_ahb_trans       <= "10000";
                     end if;
                  end if;
               else 
                  state_ahb           <= ADDRESS ; 
                  HREADY_AHB          <= '1' ;
               end if;
            when TX_FIFO_WR =>
                if (acen ='1' and ((((HTRANS = "10") or ((HBURST ="001" or HSIZE="000") and HTRANS = "11")) and BYTE_MODE_EN = 0) or (((HTRANS = "10") or (HBURST ="001" and HTRANS = "11")) and BYTE_MODE_EN = 1))) then
                  command_latch       <= HWRITE & HSIZE & HBURST & HADDR ;
                  command_latch_en    <= '1';
               end if;
               load_command_ahb          <= '0';
               if (tx_fifo_wr_en ='1') then
                  if(wr_follow_rd ='1') then
                     if(HTRANS ="01") then 
                        HREADY_AHB                <= '1';
                     else
                        HREADY_AHB                <= '0';
                     end if;
                     state_ahb                 <= MEM_RD ;
                     tx_data_latch_pending     <= '0';
                     first_mram_trans          <= '1';
                     trans_type_ahb            <= "01"; --read
                     number_of_ahb_trans       <= "00001";
                  else 
                     if (((command (34 downto 32) = "000" or command (34 downto 32) = "001" or command (37 downto 35) = "000") and BYTE_MODE_EN = 0) or ((command (34 downto 32) = "000" or command (34 downto 32) = "001") and BYTE_MODE_EN = 1)) then
                        if(HTRANS="01") then 
                           HREADY_AHB                <= '1';
                           first_mram_trans          <= '1';
                           state_ahb                 <= MEM_WR ;
                           tx_data_latch_pending     <= '0';
                           number_of_ahb_trans       <= "00001";
                        else 
                           HREADY_AHB                <= '0';
                           first_mram_trans          <= '1';
                           state_ahb                 <= MEM_WR ;
                           tx_data_latch_pending     <= '0';
                           number_of_ahb_trans       <= "00001";
                        end if;
                     elsif ((command (34 downto 32) = "010" or command (34 downto 32)="011")) then
                        if(tx_fifo_data_en_count = "00100" ) then
                           tx_fifo_data_en_count     <= "00001";
                           HREADY_AHB                <= '0';
                           first_mram_trans          <= '1';
                           state_ahb                 <= MEM_WR ;
                           tx_data_latch_pending     <= '0';
                           number_of_ahb_trans       <= "00100";
                        else
                           if(tx_fifo_data_en_count /="00100" and HTRANS = "00" and acen = '0') then
                              tx_fifo_data_en_count     <= "00001";
                              HREADY_AHB                <= '0';
                              first_mram_trans          <= '1';
                              state_ahb                 <= MEM_WR ;
                              tx_data_latch_pending     <= '0';
                              number_of_ahb_trans       <= tx_fifo_data_en_count;
                           else
                              tx_fifo_data_en_count     <= tx_fifo_data_en_count +'1';
                              HREADY_AHB                <= '1';
                           end if;
                        end if;
                     elsif ((command (34 downto 32) = "100" or command (34 downto 32)="101")) then
                        if(tx_fifo_data_en_count = "01000" ) then
                           tx_fifo_data_en_count     <= "00001";
                           HREADY_AHB                <= '0';
                           first_mram_trans          <= '1';
                           state_ahb                 <= MEM_WR ;
                           tx_data_latch_pending     <= '0';
                           number_of_ahb_trans       <= "01000";
                        else
                           if(tx_fifo_data_en_count /="01000" and HTRANS = "00" and acen = '0') then
                              tx_fifo_data_en_count     <= "00001";
                              HREADY_AHB                <= '0';
                              first_mram_trans          <= '1';
                              state_ahb                 <= MEM_WR ;
                              tx_data_latch_pending     <= '0';
                              number_of_ahb_trans       <= tx_fifo_data_en_count;
                           else
                              tx_fifo_data_en_count     <= tx_fifo_data_en_count +'1';
                              HREADY_AHB                <= '1';
                           end if;
                        end if;
                     elsif ((command (34 downto 32) = "110" or command (34 downto 32)="111")) then
                        if(tx_fifo_data_en_count = "10000" ) then
                           tx_fifo_data_en_count     <= "00001";
                           HREADY_AHB                <= '0';
                           first_mram_trans          <= '1';
                           state_ahb                 <= MEM_WR ;
                           tx_data_latch_pending     <= '0';
                           number_of_ahb_trans       <= "10000";
                        else 
                           if(tx_fifo_data_en_count /="10000" and HTRANS = "00" and acen = '0') then
                              tx_fifo_data_en_count     <= "00001";
                              HREADY_AHB                <= '0';
                              first_mram_trans          <= '1';
                              state_ahb                 <= MEM_WR ;
                              tx_data_latch_pending     <= '0';
                              number_of_ahb_trans       <= tx_fifo_data_en_count;
                           else
                              tx_fifo_data_en_count     <= tx_fifo_data_en_count +'1';
                              HREADY_AHB                <= '1';
                           end if;
                        end if;
                     end if;
                  end if;
               end if;
            when MEM_WR => 
                if (acen ='1' and ((((HTRANS = "10") or ((HBURST ="001" or HSIZE="000") and HTRANS = "11")) and BYTE_MODE_EN = 0) or (((HTRANS = "10") or (HBURST ="001" and HTRANS = "11")) and BYTE_MODE_EN = 1))) then
                  command_latch       <= HWRITE & HSIZE & HBURST & HADDR ;
                  command_latch_en    <= '1';
               end if;
               if (first_mram_trans = '1' )  then
                  state_ahb                 <= MEM_WR ;
                  new_trans_ahb             <= '1'; 
                  tx_fifo_rd_en_ahb         <= '1'; 
                  HREADY_AHB                <= '0';
                  first_mram_trans          <= '0';
                  number_of_mram_trans_cnt  <= number_of_mram_trans_cnt +'1';
                  shift_mram_addr_ahb       <= '0';
               elsif ((number_of_mram_trans_cnt = number_of_mram_trans_ahb) and (number_of_ahb_trans_cnt = number_of_ahb_trans) and transaction_mram_done_ahb = '1') then
                  if(command_latch_en ='1') then
                     command              <= command_latch;
                     command_latch_en     <= '0';
                     if(command_latch(38) = '1') then
                        state_ahb         <=TX_FIFO_WR;
                        tx_data_latch_pending  <= '1';
                        HREADY_AHB        <= '1';
                        load_command_ahb  <= '1';
                        new_trans_ahb     <= '0';
                        number_of_mram_trans_cnt  <= "000" ;    
                        number_of_ahb_trans_cnt   <= "00001" ;
                        if(command_latch(37 downto 35) = "000" and  BYTE_MODE_EN = 0 ) then
                           wr_follow_rd              <= '1';
                           trans_type_ahb            <= "01"; 
                        else
                           wr_follow_rd              <= '0';
                        end if;      
                     else
                        state_ahb         <=MEM_RD;
                        wr_follow_rd      <= '0';
                        HREADY_AHB        <= '0';
                        trans_type_ahb    <= "01"; 
                        load_command_ahb  <= '1';
                        first_mram_trans  <= '1';
                        number_of_mram_trans_cnt  <= "000" ;    
                        number_of_ahb_trans_cnt   <= "00001" ;
                        if (((command_latch (34 downto 32) = "000") or (command_latch (34 downto 32) = "001") or (command_latch (37 downto 35) = "000") )) then
                           number_of_ahb_trans       <= "00001";
                        elsif (((command_latch (34 downto 32) = "010") or (command_latch (34 downto 32) = "011"))) then
                           number_of_ahb_trans       <= "00100";
                        elsif (((command_latch (34 downto 32) = "100") or (command_latch (34 downto 32) = "101"))) then
                           number_of_ahb_trans       <= "01000";
                        elsif (((command_latch (34 downto 32) = "110") or (command_latch (34 downto 32) = "111"))) then
                           number_of_ahb_trans       <= "10000";
                        end if;
                     end if;
                  else
                     state_ahb                 <= ADDRESS ;
                     new_trans_ahb             <= '0';
                     HREADY_AHB                <= '0';
                     number_of_mram_trans_cnt  <= "000" ;    
                     number_of_ahb_trans_cnt   <= "00001" ;
                     shift_mram_addr_ahb       <= '0';
                     wr_follow_rd              <= '0';
                  end if;
               elsif ((number_of_mram_trans_cnt = number_of_mram_trans_ahb) and (number_of_ahb_trans_cnt /= number_of_ahb_trans) and transaction_mram_done_ahb = '1') then
                  state_ahb                 <= MEM_WR ;
                  first_mram_trans          <= '1';
                  new_trans_ahb             <= '0';
                  HREADY_AHB                <= '0';
                  number_of_mram_trans_cnt  <= "000" ;
                  shift_mram_addr_ahb       <= '1';
                  number_of_ahb_trans_cnt   <= number_of_ahb_trans_cnt +'1';
               elsif (transaction_mram_done_ahb = '1' )  then
                  state_ahb                 <= MEM_WR ;
                  new_trans_ahb             <= '1'; 
                  number_of_mram_trans_cnt  <= number_of_mram_trans_cnt +'1';
                  HREADY_AHB                <= '0';
                  shift_mram_addr_ahb       <= '0';
               else 
                  state_ahb                 <= MEM_WR ;
                  new_trans_ahb             <= '0'; 
                  tx_fifo_rd_en_ahb         <= '0'; 
                  shift_mram_addr_ahb       <= '0';
                  HREADY_AHB                <= '0';
               end if;
            when MEM_RD => 
               load_command_ahb  <= '0';
               if (( acen ='1') and ((((HTRANS = "10") or ((HBURST ="001" or HSIZE="000") and HTRANS = "11")) and BYTE_MODE_EN = 0))) then
                  command_latch       <= HWRITE & HSIZE & HBURST & HADDR ;
                  command_latch_en    <= '1';
               end if;
               if (first_mram_trans = '1' )  then
                  state_ahb                 <= MEM_RD ;
                  new_trans_ahb             <= '1'; 
                  HREADY_AHB                <= '0';
                  first_mram_trans          <= '0';
                  shift_mram_addr_ahb       <= '0';
                  rx_addr_load_en_ahb       <= '1'; 
                  number_of_mram_trans_cnt  <= number_of_mram_trans_cnt +'1';
               elsif ((number_of_mram_trans_cnt = number_of_mram_trans_ahb) and (number_of_ahb_trans_cnt = number_of_ahb_trans) and transaction_mram_done_ahb = '1') then
                  if(wr_follow_rd ='1') then
                     HREADY_AHB                <= '0';
                     first_mram_trans          <= '1';
                     state_ahb                 <= MEM_WR ;
                     trans_type_ahb            <= "10";
                     number_of_mram_trans_cnt  <= "000" ;    
                     number_of_ahb_trans       <= "00001";
                  else 
                     state_ahb                 <= AHB_RD ;
                     new_trans_ahb             <= '0';
                     HREADY_AHB                <= '0';
                     number_of_mram_trans_cnt  <= "000" ;    
                     number_of_ahb_trans_cnt   <= "00001" ;
                     shift_mram_addr_ahb       <= '0';
                     rx_fifo_first_read        <= '1';
                  end if;
               elsif ((number_of_mram_trans_cnt = number_of_mram_trans_ahb) and (number_of_ahb_trans_cnt /= number_of_ahb_trans) and transaction_mram_done_ahb = '1') then
                  state_ahb                 <= MEM_RD ;
                  first_mram_trans          <= '1';
                  new_trans_ahb             <= '0';
                  HREADY_AHB                <= '0';
                  number_of_mram_trans_cnt  <= "000" ;
                  shift_mram_addr_ahb       <= '1';
                  number_of_ahb_trans_cnt   <= number_of_ahb_trans_cnt +'1';
               elsif (transaction_mram_done_ahb = '1' )  then
                  state_ahb                 <= MEM_RD ;
                  new_trans_ahb             <= '1'; 
                  number_of_mram_trans_cnt  <= number_of_mram_trans_cnt +'1';
                  HREADY_AHB                <= '0';
                  shift_mram_addr_ahb       <= '0';
               else 
                  state_ahb                 <= MEM_RD ;
                  new_trans_ahb             <= '0'; 
                  rx_addr_load_en_ahb       <= '0'; 
                  shift_mram_addr_ahb       <= '0';
                  HREADY_AHB                <= '0';
               end if;
            when AHB_RD =>
               rx_fifo_first_read        <= '0';
                if (acen ='1' and ((((HTRANS = "10") or ((HBURST ="001" or HSIZE="000") and HTRANS = "11")) and BYTE_MODE_EN = 0) or (((HTRANS = "10") or (HBURST ="001" and HTRANS = "11")) and BYTE_MODE_EN = 1))) then
                  command       <= HWRITE & HSIZE & HBURST & HADDR ;
                  if (rx_fifo_rd_done = '1' )  then
                     if(HWRITE = '1') then
                        state_ahb             <= TX_FIFO_WR ;
                        tx_data_latch_pending <= '1';
                        HREADY_AHB            <= '1';
                        load_command_ahb      <= '1';
                        if( HSIZE = "000" and BYTE_MODE_EN = 0 ) then
                           wr_follow_rd              <= '1';
                           trans_type_ahb            <= "01"; 
                        else
                           wr_follow_rd              <= '0';
                           trans_type_ahb            <= "10"; 
                        end if;      
                     else
                        state_ahb             <= MEM_RD ;
                        HREADY_AHB            <= '0';
                        load_command_ahb      <= '1';
                        first_mram_trans      <= '1';
                        if (((HBURST = "000" or HBURST = "001" or HSIZE ="000") and BYTE_MODE_EN = 0 ) or ((HBURST = "000" or HBURST = "001") and BYTE_MODE_EN = 1) ) then
                           number_of_ahb_trans       <= "00001";
                        elsif ((HBURST = "010") or (HBURST = "011")) then
                           number_of_ahb_trans       <= "00100";
                        elsif ((HBURST = "100") or (HBURST = "101")) then
                           number_of_ahb_trans       <= "01000";
                        elsif ((HBURST= "110") or (HBURST = "111")) then
                           number_of_ahb_trans       <= "10000";
                        end if;
                     end if;
                  end if;
               elsif (HTRANS ="00" and (command (34 downto 32) /="000" )) then
                  burst_terminate_ahb       <='1';
                  state_ahb                 <= ADDRESS ;
                  HREADY_AHB                <= '1';
                  load_command_ahb          <= '0';
               elsif (rx_fifo_rd_done = '1' )  then
                  state_ahb                 <= ADDRESS ;
                  HREADY_AHB                <= '1';
                  load_command_ahb          <= '0';
               else
                  state_ahb                 <= AHB_RD ;
                  HREADY_AHB                <= '1';
                  load_command_ahb          <= '0';
               end if;
            when others =>
               state_ahb <= IDLE;
         end case; 
      end if; 
   end if; 
end process;

ecc_flag_sb <= tx_error_flag_sb_bd or rx_error_flag_sb_bd;
ecc_flag_db <= tx_error_flag_db_bd or rx_error_flag_db_bd;

HSEL_S <=  '1' when (HSEL = '1' and HTRANS /= "00")
           else '0' when (HSEL = '1' and HTRANS = "00")
           else '0' ;

acen                  <= HSEL_S and HREADYIN;

tx_fifo_wr_en         <=  '1' when ((HREADYIN ='1' and HWRITE_d = '1' and tx_data_latch_pending ='1') and (
                                    (HTRANS = "01" and HTRANS_d /="01") or 
                                    (HTRANS = "11" and HTRANS_d /="01" ) or
                                    (HTRANS = "00" and ( HSELREG = '1' ) and (HTRANS_d /= "00" )) or 
                                    (HTRANS = "10" and HTRANS_d1 /="00" ))) 
                           else '0'; 

rx_fifo_rd_en         <= '1' when (((state_ahb=AHB_RD) and (acen ='1') and (HTRANS /= "01") and ((not rx_fifo_rd_done) ='1' )) or (rx_fifo_first_read = '1') ) else '0';
hdataout_reg          <= rx_fifo_rd_data when (rx_fifo_rd_en_d ='1')  else  (others =>'0') ;

TRANSACTION_MRAM_START<= new_trans_mram_d2;
TRANSACTION_TYPE      <= trans_type_core;

HRDATA                <= hdataout_reg; 
HRESP                 <= "00" ;
HREADY                <= HREADY_AHB;

end architecture COREMRAM_AHBLIF_ARCH;



