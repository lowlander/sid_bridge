library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity SF2_URAM is
   generic (
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
   data_out          : out std_logic_vector (31 downto 0) 
   );
end  SF2_URAM;

architecture rtl of SF2_URAM is

   component RAM64x18
      port (
      A_DOUT         : out std_logic_vector(17 downto 0);
      B_DOUT         : out std_logic_vector(17 downto 0);
      BUSY           : out std_logic;
      A_ADDR_CLK     : in std_logic;
      A_DOUT_CLK     : in std_logic;
      A_ADDR_SRST_N  : in std_logic;
      A_DOUT_SRST_N  : in std_logic;
      A_ADDR_ARST_N  : in std_logic;
      A_DOUT_ARST_N  : in std_logic;
      A_ADDR_EN      : in std_logic;
      A_DOUT_EN      : in std_logic;
      A_BLK          : in std_logic_vector(1 downto 0);
      A_ADDR         : in std_logic_vector(9 downto 0);
      B_ADDR_CLK     : in std_logic;
      B_DOUT_CLK     : in std_logic;
      B_ADDR_SRST_N  : in std_logic;
      B_DOUT_SRST_N  : in std_logic;
      B_ADDR_ARST_N  : in std_logic;
      B_DOUT_ARST_N  : in std_logic;
      B_ADDR_EN      : in std_logic;
      B_DOUT_EN      : in std_logic;
      B_BLK          : in std_logic_vector(1 downto 0);
      B_ADDR         : in std_logic_vector(9 downto 0);
      C_CLK          : in std_logic;
      C_ADDR         : in std_logic_vector(9 downto 0);
      C_DIN          : in std_logic_vector(17 downto 0);
      C_WEN          : in std_logic;
      C_BLK          : in std_logic_vector(1 downto 0);
      A_EN           : in std_logic;
      A_ADDR_LAT     : in std_logic;
      A_DOUT_LAT     : in std_logic;
      A_WIDTH        : in std_logic_vector(2 downto 0);
      B_EN           : in std_logic;
      B_ADDR_LAT     : in std_logic;
      B_DOUT_LAT     : in std_logic;
      B_WIDTH        : in std_logic_vector(2 downto 0);
      C_EN           : in std_logic;
      C_WIDTH        : in std_logic_vector(2 downto 0);
      SII_LOCK       : in std_logic
      );
   end component;


signal A_DOUT_1         : std_logic_vector(17 downto 0);
signal A_DOUT_0         : std_logic_vector(17 downto 0);
signal C_DIN_1         : std_logic_vector(17 downto 0);
signal A_ADDR_MEM         : std_logic_vector(9 downto 0);
signal B_ADDR_MEM         : std_logic_vector(9 downto 0);
signal C_ADDR_MEM         : std_logic_vector(9 downto 0);

begin

DEPTH16 : IF (MEM_DEPTH = 16) GENERATE
   A_ADDR_MEM         <= "00" & rd_addr(3 downto 0) & "0000" ; 
   B_ADDR_MEM         <= "00" & rd_addr(3 downto 0) & "0000" ; 
   C_ADDR_MEM         <= "00" & wr_addr(3 downto 0) & "0000" ;  
END GENERATE;

DEPTH32 : IF (MEM_DEPTH = 32) GENERATE
   A_ADDR_MEM         <= '0' & rd_addr(4 downto 0) & "0000" ; 
   B_ADDR_MEM         <= '0' & rd_addr(4 downto 0) & "0000" ; 
   C_ADDR_MEM         <= '0' & wr_addr(4 downto 0) & "0000" ;  
END GENERATE;
DEPTH64 : IF (MEM_DEPTH = 64) GENERATE
   A_ADDR_MEM         <=  rd_addr(5 downto 0) & "0000" ; 
   B_ADDR_MEM         <=  rd_addr(5 downto 0) & "0000" ; 
   C_ADDR_MEM         <=  wr_addr(5 downto 0) & "0000" ;  
END GENERATE;

data_out <= A_DOUT_1 (13 downto 0) & A_DOUT_0 (17 downto 0 );
C_DIN_1  <= "0000" & data_in(31 downto 18);

   mem_mem_0_0 : RAM64x18
      port map (
      A_DOUT         => A_DOUT_0,
      B_DOUT         => open,
      BUSY           => open,
      A_ADDR_CLK     => '1' ,
      A_DOUT_CLK     => clk_rd,
      A_ADDR_SRST_N  => '1' ,
      A_DOUT_SRST_N  => '1' ,
      A_ADDR_ARST_N  => '1' ,
      A_DOUT_ARST_N  => '1' ,
      A_ADDR_EN      => '1' ,
      A_DOUT_EN      => '1' ,
      A_BLK          => "11",
      A_ADDR         => A_ADDR_MEM,
      B_ADDR_CLK     => '1',
      B_DOUT_CLK     => clk_rd,
      B_ADDR_SRST_N  => '1' ,
      B_DOUT_SRST_N  => '1' ,
      B_ADDR_ARST_N  => '1' ,
      B_DOUT_ARST_N  => '1' ,
      B_ADDR_EN      => '1' ,
      B_DOUT_EN      => '1' ,
      B_BLK          => "11",
      B_ADDR         => B_ADDR_MEM,
      C_CLK          => clk_wr,
      C_ADDR         => C_ADDR_MEM,
      C_DIN          => data_in (17 downto 0),
      C_WEN          => wr_en,
      C_BLK          => "11",
      A_EN           => '1' ,
      A_ADDR_LAT     => '1' ,
      A_DOUT_LAT     => '0' ,
      A_WIDTH        => "100",
      B_EN           => '0' ,
      B_ADDR_LAT     => '1' ,
      B_DOUT_LAT     => '0' ,
      B_WIDTH        => "100",
      C_EN           => '1' ,
      C_WIDTH        => "100",
      SII_LOCK       => '0'
      );
   mem_mem_0_1 : RAM64x18
      port map (
      A_DOUT         => A_DOUT_1,
      B_DOUT         => open,
      BUSY           => open,
      A_ADDR_CLK     => '1',
      A_DOUT_CLK     => clk_rd,
      A_ADDR_SRST_N  => '1',
      A_DOUT_SRST_N  => '1',
      A_ADDR_ARST_N  => '1',
      A_DOUT_ARST_N  => '1',
      A_ADDR_EN      => '1',
      A_DOUT_EN      => '1',
      A_BLK          => "11",
      A_ADDR         => A_ADDR_MEM ,
      B_ADDR_CLK     => '1',
      B_DOUT_CLK     => clk_rd,
      B_ADDR_SRST_N  => '1',
      B_DOUT_SRST_N  => '1',
      B_ADDR_ARST_N  => '1',
      B_DOUT_ARST_N  => '1',
      B_ADDR_EN      => '1',
      B_DOUT_EN      => '1',
      B_BLK          => "11",
      B_ADDR         => B_ADDR_MEM ,
      C_CLK          => clk_wr,
      C_ADDR         => C_ADDR_MEM,
      C_DIN          => C_DIN_1,
      C_WEN          => wr_en,
      C_BLK          => "11",
      A_EN           => '1',
      A_ADDR_LAT     => '1',
      A_DOUT_LAT     => '0',
      A_WIDTH        => "100",
      B_EN           => '0',
      B_ADDR_LAT     => '1',
      B_DOUT_LAT     => '0',
      B_WIDTH        => "100",
      C_EN           => '1',
      C_WIDTH        => "100",
      SII_LOCK       => '0'
      );

end rtl;




