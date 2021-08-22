library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity RTG4_LSRAM is
   generic (
   ECC               : integer := 1;
   MEM_DEPTH         : integer := 16;
   ADDR_WIDTH        : integer := 10
   );
   port (
   clk_wr            : in std_logic;   
   clk_rd            : in std_logic;   
   wr_en             : in std_logic;   
   rd_addr           : in std_logic_vector (ADDR_WIDTH-1 downto 0);   
   wr_addr           : in std_logic_vector (ADDR_WIDTH-1 downto 0);   
   data_in           : in std_logic_vector (31 downto 0);   
   data_out          : out std_logic_vector (31 downto 0);  
   flag_sb_bd        : out std_logic;   
   flag_db_bd        : out std_logic   

 
   );
end  RTG4_LSRAM;

architecture rtl of RTG4_LSRAM is

   component RAM1K18_RT
      port (
      A_DOUT        : out std_logic_vector(17 downto 0);
      B_DOUT        : out std_logic_vector(17 downto 0);
      A_SB_CORRECT  : out std_logic;
      A_DB_DETECT   : out std_logic;
      B_SB_CORRECT  : out std_logic;
      B_DB_DETECT   : out std_logic;
      BUSY          : out std_logic;
      A_CLK         : in std_logic;
      A_ADDR        : in std_logic_vector(10 downto 0);
      A_BLK         : in std_logic_vector(2 downto 0);
      A_DIN         : in std_logic_vector(17 downto 0);
      A_WEN         : in std_logic_vector(1 downto 0);
      A_REN         : in std_logic;
      A_WIDTH       : in std_logic_vector(1 downto 0);
      A_WMODE       : in std_logic_vector(1 downto 0);
      A_DOUT_BYPASS : in std_logic;
      A_DOUT_EN     : in std_logic;
      A_DOUT_SRST_N : in std_logic;
      B_CLK         : in std_logic;
      B_ADDR        : in std_logic_vector(10 downto 0);
      B_BLK         : in std_logic_vector(2 downto 0);
      B_DIN         : in std_logic_vector(17 downto 0);
      B_WEN         : in std_logic_vector(1 downto 0);
      B_REN         : in std_logic;
      B_WIDTH       : in std_logic_vector(1 downto 0);
      B_WMODE       : in std_logic_vector(1 downto 0);
      B_DOUT_BYPASS : in std_logic;
      B_DOUT_EN     : in std_logic;
      B_DOUT_SRST_N : in std_logic;
      ARST_N        : in std_logic;
      ECC           : in std_logic;
      ECC_DOUT_BYPASS: in std_logic;
      DELEN         : in std_logic;
      SECURITY      : in std_logic

    );
   end component;


signal A_DOUT_0                : std_logic_vector(17 downto 0);
signal B_DOUT_0                : std_logic_vector(17 downto 0);
signal A_SB_CORRECT_0          : std_logic ;
signal A_DB_DETECT_0           : std_logic ;
signal B_SB_CORRECT_0          : std_logic ;
signal B_DB_DETECT_0           : std_logic ;
signal A_ADDR_0                : std_logic_vector(10 downto 0);
signal A_DIN_0                 : std_logic_vector(17 downto 0);
signal A_WEN_0                 : std_logic_vector(1 downto 0) ;
signal A_WIDTH_0               : std_logic_vector(1 downto 0) ;
signal A_WMODE_0               : std_logic_vector(1 downto 0) ;
signal B_ADDR_0                : std_logic_vector(10 downto 0);
signal B_DIN_0                 : std_logic_vector(17 downto 0);
signal B_WEN_0                 : std_logic_vector(1 downto 0) ;
signal B_WIDTH_0               : std_logic_vector(1 downto 0) ;
signal B_WMODE_0               : std_logic_vector(1 downto 0) ;
signal B_BLK_0                 : std_logic_vector(2 downto 0) ;
signal A_DOUT_1                : std_logic_vector(17 downto 0);
signal B_DOUT_1                : std_logic_vector(17 downto 0);
signal A_SB_CORRECT_1          : std_logic ;
signal A_DB_DETECT_1           : std_logic ;
signal B_SB_CORRECT_1          : std_logic ;
signal B_DB_DETECT_1           : std_logic ;
signal A_ADDR_1                : std_logic_vector(10 downto 0);
signal A_DIN_1                 : std_logic_vector(17 downto 0);
signal A_WEN_1                 : std_logic_vector(1 downto 0) ;
signal A_WIDTH_1               : std_logic_vector(1 downto 0) ;
signal A_WMODE_1               : std_logic_vector(1 downto 0) ;

signal B_ADDR_1                : std_logic_vector(10 downto 0);
signal B_DIN_1                 : std_logic_vector(17 downto 0);
signal B_WEN_1                 : std_logic_vector(1 downto 0) ;
signal B_WIDTH_1               : std_logic_vector(1 downto 0) ;
signal B_WMODE_1               : std_logic_vector(1 downto 0) ;
signal B_BLK_1                 : std_logic_vector(2 downto 0) ;
signal ECC_EN                  : std_logic ;




begin
 
   ECC_ENABLE : IF ( ECC = 1) GENERATE
      ECC_EN <= '1';
   END GENERATE;

   ECC_DISABLE : IF ( ECC = 0) GENERATE
      ECC_EN <= '0';
   END GENERATE;

   DEPTH1024_ECC : IF (MEM_DEPTH = 1024 and ECC = 1) GENERATE
      flag_sb_bd  <= A_SB_CORRECT_0 or  B_SB_CORRECT_0 or  A_SB_CORRECT_1 or  B_SB_CORRECT_1;
      flag_db_bd  <= A_DB_DETECT_0 or B_DB_DETECT_0 or A_DB_DETECT_1 or B_DB_DETECT_1 ;
   END GENERATE;
   DEPTHNOT1024_ECC : IF (MEM_DEPTH < 1024 and ECC = 1) GENERATE
      flag_sb_bd  <= A_SB_CORRECT_0  or  B_SB_CORRECT_0 ;
      flag_db_bd  <= A_DB_DETECT_0 or B_DB_DETECT_0 ;
   END GENERATE;

   DEPTH128 : IF (MEM_DEPTH = 128) GENERATE
      data_out(31 downto 18)  <= A_DOUT_0(13 downto 0);
      data_out(17 downto 0)   <= B_DOUT_0(17 downto 0);
      A_ADDR_0      <= "00" & rd_addr(6 downto 0) & "00" ;
      A_DIN_0       <= "0000" & data_in(31 downto 18);
      A_WEN_0       <= "11" ;
      A_WIDTH_0     <= "10" ;
      A_WMODE_0     <= "00" ;
      B_ADDR_0      <= "00" & wr_addr(6 downto 0) & "00" ;
      B_DIN_0       <= data_in(17 downto 0);
      B_WEN_0       <= "11" ;
      B_WIDTH_0     <= "10" ;
      B_WMODE_0     <= "00" ;
      B_BLK_0       <= wr_en & wr_en & wr_en;
   END GENERATE;

   DEPTH256 : IF (MEM_DEPTH = 256) GENERATE
      data_out(31 downto 18)  <= A_DOUT_0(13 downto 0);
      data_out(17 downto 0)   <= B_DOUT_0(17 downto 0);
      A_ADDR_0      <= '0' & rd_addr(7 downto 0) & "00" ;
      A_DIN_0       <= "0000" & data_in(31 downto 18);
      A_WEN_0       <= "11" ;
      A_WIDTH_0     <= "10" ;
      A_WMODE_0     <= "00" ;
      B_ADDR_0      <= '0' & wr_addr(7 downto 0) & "00" ;
      B_DIN_0       <= data_in(17 downto 0);
      B_WEN_0       <= "11" ;
      B_WIDTH_0     <= "10" ;
      B_WMODE_0     <= "00" ;
      B_BLK_0       <= wr_en & wr_en & wr_en;
   END GENERATE;

   DEPTH512 : IF (MEM_DEPTH = 512) GENERATE
      data_out(31 downto 18)  <= A_DOUT_0(13 downto 0);
      data_out(17 downto 0)   <= B_DOUT_0(17 downto 0);
      A_ADDR_0      <= rd_addr(8 downto 0) & "00" ;
      A_DIN_0       <= "0000" & data_in(31 downto 18);
      A_WEN_0       <= "11" ;
      A_WIDTH_0     <= "10" ;
      A_WMODE_0     <= "00" ;
      B_ADDR_0      <= wr_addr(8 downto 0) & "00" ;
      B_DIN_0       <= data_in(17 downto 0);
      B_WEN_0       <= "11" ;
      B_WIDTH_0     <= "10" ;
      B_WMODE_0     <= "00" ;
      B_BLK_0       <= wr_en & wr_en & wr_en;
   END GENERATE;


   DEPTH1024 : IF (MEM_DEPTH = 1024) GENERATE
      
      data_out(17 downto 0)  <= A_DOUT_0;
      data_out(31 downto 18)  <= A_DOUT_1 (13 downto 0 );
      A_ADDR_0      <= rd_addr(9 downto 0) & '0' ;
      A_DIN_0       <= (others => '0');
      A_WEN_0       <= "00" ;
      A_WIDTH_0     <= "01" ;
      A_WMODE_0     <= "00" ;
      B_ADDR_0      <= wr_addr(9 downto 0) & '0' ;
      B_DIN_0       <= data_in(17 downto 0);
      B_WEN_0       <= wr_en & wr_en;
      B_WIDTH_0     <= "01" ;
      B_WMODE_0     <= "00" ;
      B_BLK_0       <= "111";

      A_ADDR_1      <= rd_addr(9 downto 0) & '0' ;
      A_DIN_1       <= (others => '0');
      A_WEN_1       <= "00" ;
      A_WIDTH_1     <= "01" ;
      A_WMODE_1     <= "00" ;
      B_ADDR_1      <= wr_addr(9 downto 0) & '0' ;
      B_DIN_1       <= "0000" & data_in(31 downto 18);
      B_WEN_1       <= wr_en & wr_en;
      B_WIDTH_1     <= "01" ;
      B_WMODE_1     <= "00" ;
      B_BLK_1       <= "111";

   mem_mem_0_1 : RAM1K18_RT
      port map (
      A_DOUT          => A_DOUT_1 ,
      B_DOUT          => B_DOUT_1 ,
      A_SB_CORRECT    => A_SB_CORRECT_1,
      A_DB_DETECT     => A_DB_DETECT_1,
      B_SB_CORRECT    => B_SB_CORRECT_1,
      B_DB_DETECT     => B_DB_DETECT_1,
      BUSY            => open,
      A_CLK           => clk_rd,
      A_ADDR          => A_ADDR_1,
      A_BLK           => "111",
      A_DIN           => A_DIN_1,
      A_WEN           => A_WEN_1,
      A_REN           => '1',
      A_WIDTH         => A_WIDTH_1,
      A_WMODE         => A_WMODE_1,
      A_DOUT_BYPASS   => '1',
      A_DOUT_EN       => '1',
      A_DOUT_SRST_N   => '1',
      B_CLK           => clk_wr,
      B_ADDR          => B_ADDR_1,
      B_BLK           => B_BLK_1,
      B_DIN           => B_DIN_1,
      B_WEN           => B_WEN_1,
      B_REN           => '1',
      B_WIDTH         => B_WIDTH_1,
      B_WMODE         => B_WMODE_1,
      B_DOUT_BYPASS   => '1',
      B_DOUT_EN       => '1',
      B_DOUT_SRST_N   => '1',
      ARST_N          => '1',
      ECC             => ECC_EN,
      ECC_DOUT_BYPASS => '1',
      DELEN           => '0',
      SECURITY        => '0'
      );
   END GENERATE;

   mem_mem_0_0 : RAM1K18_RT
      port map (
      A_DOUT          => A_DOUT_0 ,
      B_DOUT          => B_DOUT_0 ,
      A_SB_CORRECT    => A_SB_CORRECT_0,
      A_DB_DETECT     => A_DB_DETECT_0,
      B_SB_CORRECT    => B_SB_CORRECT_0,
      B_DB_DETECT     => B_DB_DETECT_0,
      BUSY            => open,
      A_CLK           => clk_rd,
      A_ADDR          => A_ADDR_0,
      A_BLK           => "111",
      A_DIN           => A_DIN_0,
      A_WEN           => A_WEN_0,
      A_REN           => '1',
      A_WIDTH         => A_WIDTH_0,
      A_WMODE         => A_WMODE_0,
      A_DOUT_BYPASS   => '1',
      A_DOUT_EN       => '1',
      A_DOUT_SRST_N   => '1',
      B_CLK           => clk_wr,
      B_ADDR          => B_ADDR_0,
      B_BLK           => B_BLK_0,
      B_DIN           => B_DIN_0,
      B_WEN           => B_WEN_0,
      B_REN           => '1',
      B_WIDTH         => B_WIDTH_0,
      B_WMODE         => B_WMODE_0,
      B_DOUT_BYPASS   => '1',
      B_DOUT_EN       => '1',
      B_DOUT_SRST_N   => '1',
      ARST_N          => '1',
      ECC             => ECC_EN,
      ECC_DOUT_BYPASS => '1',
      DELEN           => '0',
      SECURITY        => '0'
      );

end rtl;
