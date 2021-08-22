library ieee;
library CoreMRAM_AHB_LIB;

use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.math_real.all;
use CoreMRAM_AHB_LIB.mram_pkg.all;


entity CDC_FIFO is
   generic (
      FAMILY                  : integer := 25;    -- Device Family
      MEM_DEPTH               : integer := 16;
      ECC                     : integer := 1;
      DATA_WIDTH              : integer := 20
   );
   port (
      W_RST_N                 : in std_logic;
      R_RST_N                 : in std_logic;
      CLK_WR                  : in std_logic;
      CLK_RD                  : in std_logic;
      WR_EN                   : in std_logic;
      RD_EN                   : in std_logic;
      terminate_wr            : in std_logic;
      terminate_rd            : in std_logic;
      DATA_IN                 : in std_logic_vector(DATA_WIDTH-1 downto 0);
      DATA_OUT                : out std_logic_vector(DATA_WIDTH-1 downto 0);
      FIFO_FULL               : out std_logic;
      FIFO_EMPTY              : out std_logic;
      error_flag_sb_bd        : out std_logic;
      error_flag_db_bd        : out std_logic
   );
end CDC_FIFO;


architecture rtl of CDC_FIFO is


constant FIFO_ADDR_WIDTH : positive := positive(ceil(log2(real(MEM_DEPTH))));

component MRAMAHB_RAM_BLOCK_ECC
   generic (
      FAMILY       : integer := 25;    -- Device Family
      ECC          : integer := 1;
      MEM_DEPTH    : integer := 31;
      ADDR_WIDTH   : integer := 8;  
      DATA_WIDTH   : integer := 12
   );
   port (
      clk_wr       : in std_logic;
      clk_rd       : in std_logic; 
      wr_en        : in std_logic;
      wr_addr      : in std_logic_vector (FIFO_ADDR_WIDTH-1 downto 0);
      rd_addr      : in std_logic_vector (FIFO_ADDR_WIDTH-1 downto 0);
      data_in      : in std_logic_vector (DATA_WIDTH-1 downto 0);
      data_out     : out std_logic_vector (DATA_WIDTH-1 downto 0);
      flag_sb_bd   : out std_logic;   
      flag_db_bd   : out std_logic   

   );
end component;


component CDC_grayCodeCounter
   generic (
      FAMILY         : integer := 25;    -- Device Family
      bin_rstValue   : integer := 3;   
      gray_rstValue  : integer := 3;   
      n_bits         : integer := FIFO_ADDR_WIDTH    
   );
   port (
      clk            : in std_logic;
      sysRst         : in std_logic;
      terminate      : in std_logic;
      syncRst        : in std_logic;
      inc            : in std_logic;
      cntGray        : out std_logic_vector (FIFO_ADDR_WIDTH-1 downto 0);
      syncRstOut     : out std_logic
   );
end component;

 
component CDC_wrCtrl
   generic (
      FAMILY         : integer := 25;    -- Device Family
      ADDR_WIDTH     : integer := 3
   );
   port (
      clk            : in std_logic;
      rst            : in std_logic;
      terminate      : in std_logic; 
      wrPtr_gray     : in std_logic_vector (FIFO_ADDR_WIDTH-1 downto 0);
      rdPtr_gray     : in std_logic_vector (FIFO_ADDR_WIDTH-1 downto 0);
      nextwrPtr_gray : in std_logic_vector (FIFO_ADDR_WIDTH-1 downto 0);
      infoInValid    : in std_logic; 
      readyForInfo   : out std_logic; 
      fifoWe         : out std_logic 
   );
end component;

component CDC_rdCtrl
   generic (
      FAMILY         : integer := 25;    -- Device Family
      ADDR_WIDTH     : integer := 3
   );
   port (
      clk            : in std_logic;
      rst            : in std_logic;
      terminate      : in std_logic;
      rdPtr_gray     : in std_logic_vector (FIFO_ADDR_WIDTH-1 downto 0);
      wrPtr_gray     : in std_logic_vector (FIFO_ADDR_WIDTH-1 downto 0);
      nextrdPtr_gray : in std_logic_vector (FIFO_ADDR_WIDTH-1 downto 0);
      readyForOut    : in std_logic;

      infoOutValid   : out std_logic;
      fifoRe         : out std_logic
   );
end component;


signal fifoWe             : std_logic;
signal fifoRe             : std_logic;
signal syncRstWrCnt       : std_logic;
signal syncRstRdCnt       : std_logic;
signal FIFO_EMPTY_wire    : std_logic;

signal wrPtr_s1           : std_logic_vector(FIFO_ADDR_WIDTH-1 downto 0);
signal wrPtr_s2           : std_logic_vector(FIFO_ADDR_WIDTH-1 downto 0);
signal rdPtr_s1           : std_logic_vector(FIFO_ADDR_WIDTH-1 downto 0);
signal rdPtr_s2           : std_logic_vector(FIFO_ADDR_WIDTH-1 downto 0);
signal wrPtr              : std_logic_vector(FIFO_ADDR_WIDTH-1 downto 0);
signal rdPtr              : std_logic_vector(FIFO_ADDR_WIDTH-1 downto 0);
signal wrPtrP1            : std_logic_vector(FIFO_ADDR_WIDTH-1 downto 0);
signal wrPtrP2            : std_logic_vector(FIFO_ADDR_WIDTH-1 downto 0);
signal rdPtrP1            : std_logic_vector(FIFO_ADDR_WIDTH-1 downto 0);
signal infoOut_reg        : std_logic_vector(DATA_WIDTH-1 downto 0);


constant  SYNC_RESET : INTEGER := SYNC_MODE_SEL(FAMILY);
signal    A_W_RST_N          : std_logic;
signal    S_W_RST_N          : std_logic;
signal    A_R_RST_N          : std_logic;
signal    S_R_RST_N          : std_logic;

begin

A_W_RST_N <= '1' WHEN (SYNC_RESET=1) ELSE W_RST_N;
S_W_RST_N <= W_RST_N WHEN (SYNC_RESET=1) ELSE '1';

A_R_RST_N <= '1' WHEN (SYNC_RESET=1) ELSE R_RST_N;
S_R_RST_N <= R_RST_N WHEN (SYNC_RESET=1) ELSE '1';


FIFO_EMPTY <=  not FIFO_EMPTY_wire;
DATA_OUT   <=  infoOut_reg;

   ram : MRAMAHB_RAM_BLOCK_ECC
      generic map(
         FAMILY          => FAMILY,
         ECC             => ECC,
         MEM_DEPTH       =>  ( 2**(FIFO_ADDR_WIDTH) ),
         ADDR_WIDTH      =>  FIFO_ADDR_WIDTH ,
         DATA_WIDTH      =>  DATA_WIDTH  
      )
      port map (
         clk_wr           =>  CLK_WR,
         clk_rd           =>  CLK_RD,
         wr_en            =>  fifoWe,
         wr_addr          =>  wrPtr,
         rd_addr          =>  rdPtr, 
         data_in          =>  DATA_IN, 
         data_out         =>  infoOut_reg,
         flag_sb_bd       =>  error_flag_sb_bd,
         flag_db_bd       =>  error_flag_db_bd
      );  


   wrGrayCounter : CDC_grayCodeCounter
      generic map(
         FAMILY        => FAMILY,
         bin_rstValue  => 1,
         gray_rstValue => 0,
         n_bits        => ( FIFO_ADDR_WIDTH )
      )
      port map (
         clk           => CLK_WR ,
         sysRst        => W_RST_N ,
         terminate     => terminate_wr ,
         syncRst       => '1',
         inc           => fifoWe ,
         cntGray       => wrPtr ,
         syncRstOut    => syncRstWrCnt
    );

    wrGrayCounterP1 : CDC_grayCodeCounter
      generic map(
         FAMILY        => FAMILY,
         bin_rstValue  => 2,
         gray_rstValue => 1,
         n_bits        => ( FIFO_ADDR_WIDTH )
      )
      port map (
         clk           => CLK_WR ,
         sysRst        => W_RST_N ,
         terminate     => terminate_wr ,
         syncRst       => syncRstWrCnt ,
         inc           => fifoWe ,
         cntGray       => wrPtrP1 ,
         syncRstOut    => open 
    );

    wrGrayCounterP2 : CDC_grayCodeCounter 
      generic map(
         FAMILY        => FAMILY,
         bin_rstValue  => 3,
         gray_rstValue => 3,
         n_bits        => ( FIFO_ADDR_WIDTH )
      )
      port map (
         clk           => CLK_WR ,
         sysRst        => W_RST_N ,
         terminate     => terminate_wr ,
         syncRst       => syncRstWrCnt ,
         inc           => fifoWe ,
         cntGray       => wrPtrP2 ,
         syncRstOut    => open
    );


   process (CLK_WR, A_W_RST_N)
   begin
      if (A_W_RST_N = '0') then
         rdPtr_s1 <=( others => '0');
         rdPtr_s2 <= ( others => '0');
      elsif (CLK_WR'event and CLK_WR = '1') then
         if(S_W_RST_N='0') then
            rdPtr_s1 <=( others => '0');
            rdPtr_s2 <= ( others => '0');
         else
            if(terminate_wr = '1') then
               rdPtr_s1 <= ( others => '0');
               rdPtr_s2 <= ( others => '0');
            else
               rdPtr_s1 <= rdPtr;
               rdPtr_s2 <= rdPtr_s1;
            end if;
         end if;
      end if;
   end process ; 
 
   CDC_wrCtrl_inst : CDC_wrCtrl
      generic map(
         FAMILY        => FAMILY,
         ADDR_WIDTH    => ( FIFO_ADDR_WIDTH )
      )
      port map (
         clk           => CLK_WR ,
         rst           => W_RST_N ,
         terminate     => terminate_wr ,
         wrPtr_gray    => wrPtrP1 ,
         rdPtr_gray    => rdPtr_s2 ,
         nextwrPtr_gray=> wrPtrP2 ,
         readyForInfo  => FIFO_FULL,
         infoInValid   => WR_EN ,
         fifoWe        => fifoWe
    );



   rdGrayCounter : CDC_grayCodeCounter 
      generic map(
         FAMILY        => FAMILY,
         bin_rstValue  => 1,
         gray_rstValue => 0,
         n_bits        => ( FIFO_ADDR_WIDTH )
      )
      port map (
         clk           => CLK_RD ,
         sysRst        => R_RST_N ,
         terminate     => terminate_rd ,
         syncRst       => '1' ,
         inc           => fifoRe ,
         cntGray       => rdPtr ,
         syncRstOut    => syncRstRdCnt
    );

    rdGrayCounterP1 : CDC_grayCodeCounter 
      generic map(
         FAMILY        => FAMILY,
         bin_rstValue  => 2,
         gray_rstValue => 1,
         n_bits        => ( FIFO_ADDR_WIDTH )
      )
      port map (
         clk           => CLK_RD ,
         sysRst        => R_RST_N ,
         terminate     => terminate_rd ,
         syncRst       => syncRstRdCnt,
         inc           => fifoRe ,
         cntGray       => rdPtrP1 ,
         syncRstOut    => open
    );


   
   process (CLK_RD, A_R_RST_N)
   begin
      if (A_R_RST_N = '0') then
         wrPtr_s1 <= ( others => '0');
         wrPtr_s2 <= ( others => '0');
      elsif (CLK_RD'event and CLK_RD = '1') then
         if(S_R_RST_N = '0')then
            wrPtr_s1 <= ( others => '0');
            wrPtr_s2 <= ( others => '0');
         else
            if(terminate_rd = '1') then
               wrPtr_s1 <= ( others => '0');
               wrPtr_s2 <= ( others => '0');
            else
               wrPtr_s1 <= wrPtr;
               wrPtr_s2 <= wrPtr_s1;
            end if;
         end if;
      end if;
   end process ; 


   CDC_rdCtrl_inst : CDC_rdCtrl
      generic map(
         FAMILY        => FAMILY,
         ADDR_WIDTH    => ( FIFO_ADDR_WIDTH )
      )
      port map (
         clk           => CLK_RD ,
         rst           => R_RST_N ,
         terminate     => terminate_rd ,
         rdPtr_gray    => rdPtr ,
         wrPtr_gray    => wrPtr_s2 ,
         nextrdPtr_gray=> rdPtrP1 ,
         readyForOut   => RD_EN,
         infoOutValid  => FIFO_EMPTY_wire ,
         fifoRe        => fifoRe
    );

end rtl;
