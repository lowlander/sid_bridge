library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity PF_LSRAM is
   generic (
   ECC         : integer := 1;
   MEM_DEPTH   : integer := 16;
   ADDR_WIDTH  : integer := 10
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
end  PF_LSRAM;

architecture rtl of PF_LSRAM is

   component RAM1K20
      port (
      A_DOUT        : out std_logic_vector(19 downto 0);
      B_DOUT        : out std_logic_vector(19 downto 0);
      ACCESS_BUSY   : out std_logic;
      DB_DETECT     : out std_logic;
      SB_CORRECT    : out std_logic;
      BUSY_FB       : in std_logic;
      ECC_EN        : in std_logic;
      ECC_BYPASS    : in std_logic;
      A_CLK         : in std_logic;
      A_DOUT_EN     : in std_logic;
      A_BLK_EN      : in std_logic_vector(2 downto 0);
      A_DOUT_SRST_N : in std_logic;
      A_DOUT_ARST_N : in std_logic;
      A_BYPASS      : in std_logic;
      A_DIN         : in std_logic_vector(19 downto 0);
      A_ADDR        : in std_logic_vector(13 downto 0);
      A_WEN         : in std_logic_vector(1 downto 0);
      A_REN         : in std_logic;
      A_WIDTH       : in std_logic_vector(2 downto 0);
      A_WMODE       : in std_logic_vector(1 downto 0);
      B_CLK         : in std_logic;
      B_DOUT_EN     : in std_logic;
      B_BLK_EN      : in std_logic_vector(2 downto 0);
      B_DOUT_SRST_N : in std_logic;
      B_DOUT_ARST_N : in std_logic;
      B_BYPASS      : in std_logic;
      B_DIN         : in std_logic_vector(19 downto 0);
      B_ADDR        : in std_logic_vector(13 downto 0);
      B_WEN         : in std_logic_vector(1 downto 0);
      B_REN         : in std_logic;
      B_WIDTH       : in std_logic_vector(2 downto 0);
      B_WMODE       : in std_logic_vector(1 downto 0)
      );
   end component;


signal A_ADDR_MEM         : std_logic_vector(13 downto 0);
signal A_BLK_EN_MEM       : std_logic_vector(2  downto 0);
signal A_CLK_MEM          : std_logic ;
signal A_DIN_MEM          : std_logic_vector(19 downto 0);
signal A_DOUT_MEM         : std_logic_vector(19 downto 0);
signal A_DOUT_MEM_1       : std_logic_vector(19 downto 0);
signal A_WEN_MEM          : std_logic_vector(1  downto 0);
signal A_REN_MEM          : std_logic ;
signal A_WIDTH_MEM        : std_logic_vector(2  downto 0);
signal A_WMODE_MEM        : std_logic_vector(1  downto 0);
signal A_BYPASS_MEM       : std_logic ;
signal A_DOUT_EN_MEM      : std_logic ;
signal A_DOUT_SRST_N_MEM  : std_logic ;
signal A_DOUT_ARST_N_MEM  : std_logic ;
signal B_ADDR_MEM         : std_logic_vector(13 downto 0);
signal B_BLK_EN_MEM       : std_logic_vector(2  downto 0);
signal B_CLK_MEM          : std_logic ;
signal B_DIN_MEM          : std_logic_vector(19 downto 0);
signal B_DIN_MEM_1        : std_logic_vector(19 downto 0);
signal B_DOUT_MEM         : std_logic_vector(19 downto 0);
signal B_DOUT_MEM_1       : std_logic_vector(19 downto 0);
signal B_WEN_MEM          : std_logic_vector(1  downto 0);
signal B_REN_MEM          : std_logic ;
signal B_WIDTH_MEM        : std_logic_vector(2  downto 0);
signal B_WMODE_MEM        : std_logic_vector(1  downto 0);
signal B_BYPASS_MEM       : std_logic ;
signal B_DOUT_EN_MEM      : std_logic ;
signal B_DOUT_SRST_N_MEM  : std_logic ;
signal B_DOUT_ARST_N_MEM  : std_logic ;
signal ECC_EN_MEM         : std_logic ;
signal ECC_BYPASS_MEM     : std_logic ;
signal SB_CORRECT_MEM     : std_logic ;
signal SB_CORRECT_MEM_1   : std_logic ;
signal DB_DETECT_MEM      : std_logic ;
signal DB_DETECT_MEM_1    : std_logic ;
signal BUSY_FB_MEM        : std_logic ;
signal ACCESS_BUSY_MEM    : std_logic ;
signal ACCESS_BUSY_MEM_1  : std_logic ;

begin

ECC_ENABLE : IF (ECC = 1) GENERATE
   ECC_EN_MEM         <= '1' ;
END GENERATE;
ECC_DISABLE : IF (ECC = 0) GENERATE
   ECC_EN_MEM         <= '0' ;
END GENERATE;

DEPTH16 : IF (MEM_DEPTH = 16) GENERATE
   A_ADDR_MEM         <= "00000" & rd_addr(3 downto 0) & "00000" ; 
   B_ADDR_MEM         <= "00000" & wr_addr(3 downto 0) & "00000" ;
END GENERATE;

DEPTH32 : IF (MEM_DEPTH = 32) GENERATE
   A_ADDR_MEM         <= "0000" & rd_addr(4 downto 0) & "00000" ; 
   B_ADDR_MEM         <= "0000" & wr_addr(4 downto 0) & "00000" ;
END GENERATE;
DEPTH64 : IF (MEM_DEPTH = 64) GENERATE
   A_ADDR_MEM         <= "000" & rd_addr(5 downto 0) & "00000" ; 
   B_ADDR_MEM         <= "000" & wr_addr(5 downto 0) & "00000" ;
END GENERATE;
DEPTH128 : IF (MEM_DEPTH = 128) GENERATE
   A_ADDR_MEM         <= "00" & rd_addr(6 downto 0) & "00000" ; 
   B_ADDR_MEM         <= "00" & wr_addr(6 downto 0) & "00000" ;
END GENERATE;
DEPTH256 : IF (MEM_DEPTH = 256) GENERATE
   A_ADDR_MEM         <= "0" & rd_addr(7 downto 0) & "00000" ; 
   B_ADDR_MEM         <= "0" & wr_addr(7 downto 0) & "00000" ;
END GENERATE;
DEPTH512 : IF (MEM_DEPTH = 512) GENERATE
   A_ADDR_MEM         <=  rd_addr(8 downto 0) & "00000" ; 
   B_ADDR_MEM         <=  wr_addr(8 downto 0) & "00000" ;
END GENERATE;

DEPTHNOT1024 : IF (MEM_DEPTH < 1024) GENERATE
   A_DIN_MEM          <= "0000" & data_in (31 downto 16);
   B_DIN_MEM          <= "0000" & data_in (15 downto 0);
   A_BLK_EN_MEM       <= "111" ;                        
   A_CLK_MEM          <= clk_rd;                        
   A_WEN_MEM          <= "11" ; 
   A_REN_MEM          <= '1' ; 
   A_WIDTH_MEM        <= "101" ;
   A_WMODE_MEM        <= "00" ;    
   A_BYPASS_MEM       <= '1' ;
   A_DOUT_EN_MEM      <= '1' ; 
   A_DOUT_SRST_N_MEM  <= '1' ;
   A_DOUT_ARST_N_MEM  <= '1' ; 
   B_BLK_EN_MEM       <= wr_en & wr_en & wr_en;
   B_CLK_MEM          <= clk_wr; 
   B_WEN_MEM          <= "11" ; 
   B_REN_MEM          <= '1' ; 
   B_WIDTH_MEM        <= "101" ;
   B_WMODE_MEM        <= "00" ;    
   B_BYPASS_MEM       <= '1' ;
   B_DOUT_EN_MEM      <= '1' ;
   B_DOUT_SRST_N_MEM  <= '1' ;
   B_DOUT_ARST_N_MEM  <= '1' ;
   BUSY_FB_MEM        <= '0' ;
   ECC_BYPASS_MEM     <= '1' ;
   data_out (15 downto 0)  <= B_DOUT_MEM (15 downto 0) ;
   data_out (31 downto 16) <= A_DOUT_MEM (15 downto 0) ;
   flag_sb_bd              <= SB_CORRECT_MEM ;
   flag_db_bd              <= DB_DETECT_MEM ;

END GENERATE;

DEPTH1024 : IF (MEM_DEPTH = 1024) GENERATE
   A_ADDR_MEM         <=  rd_addr(9 downto 0) & "0000" ; 
   B_ADDR_MEM         <=  wr_addr(9 downto 0) & "0000" ;
   A_DIN_MEM          <= (others =>'0') ;
   B_DIN_MEM          <= data_in (19 downto 0);
   B_DIN_MEM_1        <= "00000000" & data_in (31 downto 20);
   A_BLK_EN_MEM       <= "111" ;                        
   A_CLK_MEM          <= clk_rd;                        
   A_WEN_MEM          <= "00" ; 
   A_REN_MEM          <= '1' ; 
   A_WIDTH_MEM        <= "100" ;
   A_WMODE_MEM        <= "01" ;    
   A_BYPASS_MEM       <= '1' ;
   A_DOUT_EN_MEM      <= '1' ; 
   A_DOUT_SRST_N_MEM  <= '1' ;
   A_DOUT_ARST_N_MEM  <= '1' ; 
   B_BLK_EN_MEM       <= "111";
   B_CLK_MEM          <= clk_wr; 
   B_WEN_MEM          <= wr_en & wr_en ; 
   B_REN_MEM          <= '1' ; 
   B_WIDTH_MEM        <= "100" ;
   B_WMODE_MEM        <= "01" ;    
   B_BYPASS_MEM       <= '1' ;
   B_DOUT_EN_MEM      <= '1' ;
   B_DOUT_SRST_N_MEM  <= '1' ;
   B_DOUT_ARST_N_MEM  <= '1' ;
   BUSY_FB_MEM        <= '0' ;
   ECC_BYPASS_MEM     <= '1' ;
   data_out (19 downto 0) <= A_DOUT_MEM  ;
   data_out (31 downto 20) <= A_DOUT_MEM_1 (11 downto 0) ;
   flag_sb_bd              <= SB_CORRECT_MEM or SB_CORRECT_MEM_1;
   flag_db_bd              <= DB_DETECT_MEM or DB_DETECT_MEM_1 ;

   MEM_0_1 : RAM1K20
      port map (
      A_ADDR          =>  A_ADDR_MEM ,
      A_BLK_EN        =>  A_BLK_EN_MEM ,
      A_CLK           =>  A_CLK_MEM,
      A_DIN           =>  A_DIN_MEM,
      A_DOUT          =>  A_DOUT_MEM_1,
      A_WEN           =>  A_WEN_MEM,
      A_REN           =>  A_REN_MEM,
      A_WIDTH         =>  A_WIDTH_MEM,
      A_WMODE         =>  A_WMODE_MEM,
      A_BYPASS        =>  A_BYPASS_MEM,
      A_DOUT_EN       =>  A_DOUT_EN_MEM,
      A_DOUT_SRST_N   =>  A_DOUT_SRST_N_MEM,
      A_DOUT_ARST_N   =>  A_DOUT_ARST_N_MEM,
      B_ADDR          =>  B_ADDR_MEM,
      B_BLK_EN        =>  B_BLK_EN_MEM,
      B_CLK           =>  B_CLK_MEM,
      B_DIN           =>  B_DIN_MEM_1,
      B_DOUT          =>  B_DOUT_MEM_1,
      B_WEN           =>  B_WEN_MEM,
      B_REN           =>  B_REN_MEM,
      B_WIDTH         =>  B_WIDTH_MEM,
      B_WMODE         =>  B_WMODE_MEM,
      B_BYPASS        =>  B_BYPASS_MEM,
      B_DOUT_EN       =>  B_DOUT_EN_MEM,
      B_DOUT_SRST_N   =>  B_DOUT_SRST_N_MEM,
      B_DOUT_ARST_N   =>  B_DOUT_ARST_N_MEM,
      ECC_EN          =>  ECC_EN_MEM,
      ECC_BYPASS      =>  ECC_BYPASS_MEM,
      SB_CORRECT      =>  SB_CORRECT_MEM_1,
      DB_DETECT       =>  DB_DETECT_MEM_1,
      BUSY_FB         =>  BUSY_FB_MEM,
      ACCESS_BUSY     =>  ACCESS_BUSY_MEM_1 
      );

END GENERATE;

   MEM_0_0 : RAM1K20
      port map (
      A_ADDR          =>  A_ADDR_MEM ,
      A_BLK_EN        =>  A_BLK_EN_MEM ,
      A_CLK           =>  A_CLK_MEM,
      A_DIN           =>  A_DIN_MEM,
      A_DOUT          =>  A_DOUT_MEM,
      A_WEN           =>  A_WEN_MEM,
      A_REN           =>  A_REN_MEM,
      A_WIDTH         =>  A_WIDTH_MEM,
      A_WMODE         =>  A_WMODE_MEM,
      A_BYPASS        =>  A_BYPASS_MEM,
      A_DOUT_EN       =>  A_DOUT_EN_MEM,
      A_DOUT_SRST_N   =>  A_DOUT_SRST_N_MEM,
      A_DOUT_ARST_N   =>  A_DOUT_ARST_N_MEM,
      B_ADDR          =>  B_ADDR_MEM,
      B_BLK_EN        =>  B_BLK_EN_MEM,
      B_CLK           =>  B_CLK_MEM,
      B_DIN           =>  B_DIN_MEM,
      B_DOUT          =>  B_DOUT_MEM,
      B_WEN           =>  B_WEN_MEM,
      B_REN           =>  B_REN_MEM,
      B_WIDTH         =>  B_WIDTH_MEM,
      B_WMODE         =>  B_WMODE_MEM,
      B_BYPASS        =>  B_BYPASS_MEM,
      B_DOUT_EN       =>  B_DOUT_EN_MEM,
      B_DOUT_SRST_N   =>  B_DOUT_SRST_N_MEM,
      B_DOUT_ARST_N   =>  B_DOUT_ARST_N_MEM,
      ECC_EN          =>  ECC_EN_MEM,
      ECC_BYPASS      =>  ECC_BYPASS_MEM,
      SB_CORRECT      =>  SB_CORRECT_MEM,
      DB_DETECT       =>  DB_DETECT_MEM,
      BUSY_FB         =>  BUSY_FB_MEM,
      ACCESS_BUSY     =>  ACCESS_BUSY_MEM 
      );

end rtl;







