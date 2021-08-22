library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity SF2_LSRAM is
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
end  SF2_LSRAM;

architecture rtl of SF2_LSRAM is

   component RAM1K18 
      port (
      A_DOUT         : out std_logic_vector(17 downto 0);
      B_DOUT         : out std_logic_vector(17 downto 0);  
      BUSY           : out std_logic;
      A_CLK          : in std_logic;
      A_DOUT_CLK     : in std_logic;
      A_ARST_N       : in std_logic;
      A_DOUT_EN      : in std_logic;
      A_BLK          : in std_logic_vector(2 downto 0);
      A_DOUT_ARST_N  : in std_logic;
      A_DOUT_SRST_N  : in std_logic;
      A_DIN          : in std_logic_vector(17 downto 0);
      A_ADDR         : in std_logic_vector(13 downto 0);
      A_WEN          : in std_logic_vector(1 downto 0);
      B_CLK          : in std_logic;
      B_DOUT_CLK     : in std_logic;
      B_ARST_N       : in std_logic;
      B_DOUT_EN      : in std_logic;
      B_BLK          : in std_logic_vector(2 downto 0);
      B_DOUT_ARST_N  : in std_logic;
      B_DOUT_SRST_N  : in std_logic;
      B_DIN          : in std_logic_vector(17 downto 0);
      B_ADDR         : in std_logic_vector(13 downto 0);
      B_WEN          : in std_logic_vector(1 downto 0);
      A_EN           : in std_logic;
      A_DOUT_LAT     : in std_logic;
      A_WIDTH        : in std_logic_vector(2 downto 0);
      A_WMODE        : in std_logic;
      B_EN           : in std_logic;
      B_DOUT_LAT     : in std_logic;
      B_WIDTH        : in std_logic_vector(2 downto 0);
      B_WMODE        : in std_logic;
      SII_LOCK       : in std_logic
      );
   end component;


signal A_DOUT_0  : std_logic_vector(17 downto 0);
signal B_DOUT_0  : std_logic_vector(17 downto 0);
signal A_DIN_0   : std_logic_vector(17 downto 0);
signal A_ADDR_0  : std_logic_vector(13 downto 0);
signal A_WEN_0   : std_logic_vector(1 downto 0);
signal B_BLK_0   : std_logic_vector(2 downto 0);
signal B_DIN_0   : std_logic_vector(17 downto 0);
signal B_ADDR_0  : std_logic_vector(13 downto 0);
signal B_WEN_0   : std_logic_vector(1 downto 0);
signal A_WIDTH_0 : std_logic_vector(2 downto 0);
signal A_WMODE_0 : std_logic;
signal B_WIDTH_0 : std_logic_vector(2 downto 0);
signal B_WMODE_0 : std_logic;

signal A_DOUT_1  : std_logic_vector(17 downto 0);
signal B_DOUT_1  : std_logic_vector(17 downto 0);
signal A_DIN_1   : std_logic_vector(17 downto 0);
signal A_ADDR_1  : std_logic_vector(13 downto 0);
signal A_WEN_1   : std_logic_vector(1 downto 0);
signal B_BLK_1   : std_logic_vector(2 downto 0);
signal B_DIN_1   : std_logic_vector(17 downto 0);
signal B_ADDR_1  : std_logic_vector(13 downto 0);
signal B_WEN_1   : std_logic_vector(1 downto 0);
signal A_WIDTH_1 : std_logic_vector(2 downto 0);
signal A_WMODE_1 : std_logic;
signal B_WIDTH_1 : std_logic_vector(2 downto 0);
signal B_WMODE_1 : std_logic;


begin

DEPTH128 : IF (MEM_DEPTH = 128) GENERATE
   data_out (31 downto 18) <= A_DOUT_0 (13 downto 0);
   data_out (17 downto 0)  <= B_DOUT_0 ;
   A_DIN_0   <= "0000" & data_in (31 downto 18) ;
   A_ADDR_0  <= "00" & rd_addr(6 downto 0) & "00000";
   A_WEN_0   <= "11";
   B_BLK_0   <= wr_en & wr_en & wr_en;
   B_DIN_0   <= data_in (17 downto 0) ;
   B_ADDR_0  <= "00" & wr_addr(6 downto 0) & "00000";
   B_WEN_0   <= "11";
   A_WIDTH_0 <= "110" ;
   A_WMODE_0 <= '0';
   B_WIDTH_0 <= "110";
   B_WMODE_0 <= '0';
END GENERATE;

DEPTH256 : IF (MEM_DEPTH = 256) GENERATE
   data_out (31 downto 18) <= A_DOUT_0 (13 downto 0);
   data_out (17 downto 0)  <= B_DOUT_0 ;
   A_DIN_0   <= "0000" & data_in (31 downto 18) ;
   A_ADDR_0  <= '0' & rd_addr(7 downto 0) & "00000";
   A_WEN_0   <= "11";
   B_BLK_0   <= wr_en & wr_en & wr_en;
   B_DIN_0   <= data_in (17 downto 0) ;
   B_ADDR_0  <= '0' & wr_addr(7 downto 0) & "00000";
   B_WEN_0   <= "11";
   A_WIDTH_0 <= "110" ;
   A_WMODE_0 <= '0';
   B_WIDTH_0 <= "110";
   B_WMODE_0 <= '0';
END GENERATE;

DEPTH512 : IF (MEM_DEPTH = 512) GENERATE
   data_out (31 downto 18) <= A_DOUT_0 (13 downto 0);
   data_out (17 downto 0)  <= B_DOUT_0 ;
   A_DIN_0   <= "0000" & data_in (31 downto 18) ;
   A_ADDR_0  <= rd_addr(8 downto 0) & "00000";
   A_WEN_0   <= "11";
   B_BLK_0   <= wr_en & wr_en & wr_en;
   B_DIN_0   <=  data_in (17 downto 0) ;
   B_ADDR_0  <= wr_addr(8 downto 0) & "00000";
   B_WEN_0   <= "11";
   A_WIDTH_0 <="110" ;
   A_WMODE_0 <= '0';
   B_WIDTH_0 <= "110";
   B_WMODE_0 <= '0';
END GENERATE;

DEPTH1024 : IF (MEM_DEPTH = 1024) GENERATE
   data_out (31 downto 18) <= A_DOUT_1 (13 downto 0);
   data_out (17 downto 0)  <= A_DOUT_0 (17 downto 0);

   A_DIN_0   <= (others => '0') ;
   A_ADDR_0  <= rd_addr(9 downto 0) & "0000";
   A_WEN_0   <= "00";
   B_BLK_0   <= "111" ;
   B_DIN_0   <= data_in (17 downto 0) ;
   B_ADDR_0  <= wr_addr(9 downto 0) & "0000";
   B_WEN_0   <= wr_en & wr_en ;
   A_WIDTH_0 <= "100" ;
   A_WMODE_0 <= '1';
   B_WIDTH_0 <= "100";
   B_WMODE_0 <= '1';

   A_DIN_1   <= (others => '0') ;
   A_ADDR_1  <= rd_addr(9 downto 0) & "0000";
   A_WEN_1   <= "00";
   B_BLK_1   <= "111" ;
   B_DIN_1   <= "0000" & data_in (31 downto 18) ;
   --B_DIN_1   <= data_in (17 downto 0) ;
   B_ADDR_1  <= wr_addr(9 downto 0) & "0000";
   B_WEN_1   <= wr_en & wr_en ;
   A_WIDTH_1 <= "100" ;
   A_WMODE_1 <= '1';
   B_WIDTH_1 <= "100";
   B_WMODE_1 <= '1';

   mem_mem_0_1 : RAM1K18
      port map (
      A_DOUT        => A_DOUT_1,
      B_DOUT        => B_DOUT_1,
      BUSY          => open,
      A_CLK         => clk_rd,
      A_DOUT_CLK    => '1',
      A_ARST_N      => '1',
      A_DOUT_EN     => '1',
      A_BLK         => "111",
      A_DOUT_ARST_N => '1',
      A_DOUT_SRST_N => '1',
      A_DIN         => A_DIN_1 ,
      A_ADDR        => A_ADDR_1,
      A_WEN         => A_WEN_1,
      B_CLK         => clk_wr,
      B_DOUT_CLK    => '1',
      B_ARST_N      => '1',
      B_DOUT_EN     => '1',
      B_BLK         => B_BLK_1,
      B_DOUT_ARST_N => '1',
      B_DOUT_SRST_N => '1',
      B_DIN         => B_DIN_1,
      B_ADDR        => B_ADDR_1,
      B_WEN         => B_WEN_1,
      A_EN          => '1',
      A_DOUT_LAT    => '1',
      A_WIDTH       => A_WIDTH_1,
      A_WMODE       => A_WMODE_1,
      B_EN          => '1',
      B_DOUT_LAT    => '1',
      B_WIDTH       => B_WIDTH_1,
      B_WMODE       => B_WMODE_1,
      SII_LOCK      => '0'
      );
END GENERATE;

   mem_mem_0_0 : RAM1K18
      port map (
      A_DOUT        => A_DOUT_0,
      B_DOUT        => B_DOUT_0,
      BUSY          => open,
      A_CLK         => clk_rd,
      A_DOUT_CLK    => '1',
      A_ARST_N      => '1',
      A_DOUT_EN     => '1',
      A_BLK         => "111",
      A_DOUT_ARST_N => '1',
      A_DOUT_SRST_N => '1',
      A_DIN         => A_DIN_0 ,
      A_ADDR        => A_ADDR_0,
      A_WEN         => A_WEN_0,
      B_CLK         => clk_wr,
      B_DOUT_CLK    => '1',
      B_ARST_N      => '1',
      B_DOUT_EN     => '1',
      B_BLK         => B_BLK_0,
      B_DOUT_ARST_N => '1',
      B_DOUT_SRST_N => '1',
      B_DIN         => B_DIN_0,
      B_ADDR        => B_ADDR_0,
      B_WEN         => B_WEN_0,
      A_EN          => '1',
      A_DOUT_LAT    => '1',
      A_WIDTH       => A_WIDTH_0,
      A_WMODE       => A_WMODE_0,
      B_EN          => '1',
      B_DOUT_LAT    => '1',
      B_WIDTH       => B_WIDTH_0,
      B_WMODE       => B_WMODE_0,
      SII_LOCK      => '0'
      );

end rtl;
