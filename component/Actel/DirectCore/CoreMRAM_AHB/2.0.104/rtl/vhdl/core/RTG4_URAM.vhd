library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity RTG4_URAM is
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
end  RTG4_URAM;

architecture rtl of RTG4_URAM is

   component RAM64x18_RT 
      port (
      A_DOUT          : out std_logic_vector(17 downto 0);
      B_DOUT          : out std_logic_vector(17 downto 0);
      A_SB_CORRECT    : out std_logic;
      A_DB_DETECT     : out std_logic;
      B_SB_CORRECT    : out std_logic;
      B_DB_DETECT     : out std_logic;
      BUSY            : out std_logic;
      A_CLK           : in std_logic;
      A_ADDR          : in std_logic_vector(6 downto 0);
      A_BLK           : in std_logic_vector(1 downto 0);
      A_WIDTH         : in std_logic;
      A_DOUT_EN       : in std_logic;
      A_DOUT_BYPASS   : in std_logic;
      A_DOUT_SRST_N   : in std_logic;
      A_ADDR_EN       : in std_logic;
      A_ADDR_BYPASS   : in std_logic;
      A_ADDR_SRST_N   : in std_logic;
      B_CLK           : in std_logic;
      B_ADDR          : in std_logic_vector(6 downto 0);
      B_BLK           : in std_logic_vector(1 downto 0);
      B_WIDTH         : in std_logic;
      B_DOUT_EN       : in std_logic;
      B_DOUT_BYPASS   : in std_logic;
      B_DOUT_SRST_N   : in std_logic;
      B_ADDR_EN       : in std_logic;
      B_ADDR_BYPASS   : in std_logic;
      B_ADDR_SRST_N   : in std_logic;
      C_CLK           : in std_logic;
      C_ADDR          : in std_logic_vector(6 downto 0);
      C_DIN           : in std_logic_vector(17 downto 0);
      C_WEN           : in std_logic;
      C_BLK           : in std_logic_vector(1 downto 0);
      C_WIDTH         : in std_logic;
      ARST_N          : in std_logic;
      ECC             : in std_logic;
      ECC_DOUT_BYPASS : in std_logic;
      DELEN           : in std_logic;
      SECURITY        : in std_logic
      );
   end component;

   

signal A_DOUT_1           : std_logic_vector(17 downto 0);
signal A_DOUT_0           : std_logic_vector(17 downto 0);
signal C_DIN_1            : std_logic_vector(17 downto 0);
signal A_ADDR_MEM         : std_logic_vector(6 downto 0);
signal B_ADDR_MEM         : std_logic_vector(6 downto 0);
signal C_ADDR_MEM         : std_logic_vector(6 downto 0);

signal ECC_EN_MEM         : std_logic;
signal A_SB_CORRECT_0     : std_logic;
signal B_SB_CORRECT_0     : std_logic;
signal A_SB_CORRECT_1     : std_logic;
signal B_SB_CORRECT_1     : std_logic;
signal A_DB_DETECT_0     : std_logic;
signal B_DB_DETECT_0     : std_logic;
signal A_DB_DETECT_1     : std_logic;
signal B_DB_DETECT_1     : std_logic;

begin


ECC_ENABLE : IF (ECC = 1) GENERATE
   ECC_EN_MEM         <= '1' ;
   flag_sb_bd         <= A_SB_CORRECT_0 or B_SB_CORRECT_0 or A_SB_CORRECT_1 or B_SB_CORRECT_1 ;
   flag_db_bd         <= A_DB_DETECT_0 or B_DB_DETECT_0 or A_DB_DETECT_1 or B_DB_DETECT_1 ;

END GENERATE;
ECC_DISABLE : IF (ECC = 0) GENERATE
   ECC_EN_MEM         <= '0' ;
END GENERATE;


DEPTH16 : IF (MEM_DEPTH = 16) GENERATE
   A_ADDR_MEM         <= "00" & rd_addr(3 downto 0) & '0' ; 
   B_ADDR_MEM         <= "00" & rd_addr(3 downto 0) & '0' ; 
   C_ADDR_MEM         <= "00" & wr_addr(3 downto 0) & '0' ;  
END GENERATE;

DEPTH32 : IF (MEM_DEPTH = 32) GENERATE
   A_ADDR_MEM         <= '0' & rd_addr(4 downto 0) & '0' ; 
   B_ADDR_MEM         <= '0' & rd_addr(4 downto 0) & '0' ; 
   C_ADDR_MEM         <= '0' & wr_addr(4 downto 0) & '0' ;  
END GENERATE;
DEPTH64 : IF (MEM_DEPTH = 64) GENERATE
   A_ADDR_MEM         <=  rd_addr(5 downto 0) & '0' ; 
   B_ADDR_MEM         <=  rd_addr(5 downto 0) & '0' ; 
   C_ADDR_MEM         <=  wr_addr(5 downto 0) & '0' ;  
END GENERATE;

data_out <= A_DOUT_1 (13 downto 0) & A_DOUT_0 (17 downto 0 );
C_DIN_1  <= "0000" & data_in(31 downto 18);

 
   mem_mem_0_0 : RAM64x18_RT
      port map (
      A_DOUT           => A_DOUT_0,
      B_DOUT           => open,
      A_SB_CORRECT     => A_SB_CORRECT_0,
      A_DB_DETECT      => A_DB_DETECT_0,
      B_SB_CORRECT     => B_SB_CORRECT_0,
      B_DB_DETECT      => B_DB_DETECT_0,
      BUSY             => open,
      A_CLK            => (clk_rd),
      A_ADDR           => A_ADDR_MEM,
      A_BLK            => "11",
      A_WIDTH          => '1',
      A_DOUT_EN        => '1',
      A_DOUT_BYPASS    => '0',
      A_DOUT_SRST_N    => '1',
      A_ADDR_EN        => '1',
      A_ADDR_BYPASS    => '1',
      A_ADDR_SRST_N    => '1',
      B_CLK            => (clk_rd),
      B_ADDR           => B_ADDR_MEM,
      B_BLK            => "11",
      B_WIDTH          => '1',
      B_DOUT_EN        => '1',
      B_DOUT_BYPASS    => '0',
      B_DOUT_SRST_N    => '1',
      B_ADDR_EN        => '1',
      B_ADDR_BYPASS    => '1',
      B_ADDR_SRST_N    => '1',
      C_CLK            => clk_wr,
      C_ADDR           => C_ADDR_MEM,
      C_DIN            => data_in(17 downto 0),
      C_WEN            => wr_en,
      C_BLK            => "11",
      C_WIDTH          => '1',
      ARST_N           => '1',
      ECC              =>  ECC_EN_MEM,
      ECC_DOUT_BYPASS  => '1',
      DELEN            => '0',
      SECURITY         => '0'
      );
  
   mem_mem_0_1 : RAM64x18_RT
      port map (
      A_DOUT           => A_DOUT_1,
      B_DOUT           => open,
      A_SB_CORRECT     => A_SB_CORRECT_1,
      A_DB_DETECT      => A_DB_DETECT_1,
      B_SB_CORRECT     => B_SB_CORRECT_1,
      B_DB_DETECT      => B_DB_DETECT_1,
      BUSY             => open,
      A_CLK            => clk_rd,
      A_ADDR           => A_ADDR_MEM,
      A_BLK            => "11",
      A_WIDTH          => '1',
      A_DOUT_EN        => '1',
      A_DOUT_BYPASS    => '0',
      A_DOUT_SRST_N    => '1',
      A_ADDR_EN        => '1',
      A_ADDR_BYPASS    => '1',
      A_ADDR_SRST_N    => '1',
      B_CLK            => clk_rd,
      B_ADDR           => B_ADDR_MEM,
      B_BLK            => "11",
      B_WIDTH          => '1',
      B_DOUT_EN        => '1',
      B_DOUT_BYPASS    => '0',
      B_DOUT_SRST_N    => '1',
      B_ADDR_EN        => '1',
      B_ADDR_BYPASS    => '1',
      B_ADDR_SRST_N    => '1',
      C_CLK            => clk_wr,
      C_ADDR           => C_ADDR_MEM,
      C_DIN            => C_DIN_1,
      C_WEN            => wr_en,
      C_BLK            => "11",
      C_WIDTH          => '1',
      ARST_N           => '1',
      ECC              =>  ECC_EN_MEM,
      ECC_DOUT_BYPASS  => '1',
      DELEN            => '0',
      SECURITY         => '0'
      );

end rtl;

