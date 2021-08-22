library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity PF_URAM is
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
end  PF_URAM;

architecture rtl of PF_URAM is

   component RAM64x12
      port (
      BUSY_FB        : in std_logic;
      W_CLK          : in std_logic;
      W_ADDR         : in std_logic_vector(5 downto 0);
      W_EN           : in std_logic;
      W_DATA         : in std_logic_vector(11 downto 0);
      BLK_EN         : in std_logic;
      R_CLK          : in std_logic;
      R_ADDR         : in std_logic_vector(5 downto 0);
      R_DATA         : out std_logic_vector(11 downto 0);
      R_ADDR_BYPASS  : in std_logic;
      R_ADDR_EN      : in std_logic;
      R_ADDR_SL_N    : in std_logic;
      R_ADDR_SD      : in std_logic;
      R_ADDR_AL_N    : in std_logic;
      R_ADDR_AD_N    : in std_logic;
      R_DATA_BYPASS  : in std_logic;
      R_DATA_EN      : in std_logic;
      R_DATA_SL_N    : in std_logic;
      R_DATA_SD      : in std_logic;
      R_DATA_AL_N    : in std_logic;
      R_DATA_AD_N    : in std_logic;
      ACCESS_BUSY    : out std_logic
      );
   end component;


signal R_DATA_0         : std_logic_vector(11 downto 0);
signal R_DATA_1         : std_logic_vector(11 downto 0);
signal R_DATA_2         : std_logic_vector(11 downto 0);
signal W_DATA_2         : std_logic_vector(11 downto 0);
signal W_ADDR_MEM         : std_logic_vector(5 downto 0);
signal R_ADDR_MEM         : std_logic_vector(5 downto 0);
signal mem_0_2_R_DATA     : std_logic_vector(3  downto 0);

begin

DEPTH16 : IF (MEM_DEPTH = 16) GENERATE
   W_ADDR_MEM         <= "00" & wr_addr(3 downto 0) ; 
   R_ADDR_MEM         <= "00" & rd_addr(3 downto 0) ;
END GENERATE;

DEPTH32 : IF (MEM_DEPTH = 32) GENERATE
   W_ADDR_MEM         <= '0' & wr_addr(4 downto 0) ; 
   R_ADDR_MEM         <= '0' & rd_addr(4 downto 0) ;
END GENERATE;
DEPTH64 : IF (MEM_DEPTH = 64) GENERATE
   W_ADDR_MEM         <= wr_addr(5 downto 0) ; 
   R_ADDR_MEM         <= rd_addr(5 downto 0) ; 
END GENERATE;

data_out  <= R_DATA_2 (7 downto 0) & R_DATA_1 (11 downto 0 ) & R_DATA_0 (11 downto 0);
W_DATA_2  <= "0000" & data_in(31 downto 24);


   mem_mem_0_0 : RAM64x12
      port map (
      BUSY_FB       => '0',
      W_CLK         => clk_wr,
      W_ADDR        => W_ADDR_MEM,
      W_EN          => wr_en,
      W_DATA        => data_in(11 downto 0),
      BLK_EN        => '1',
      R_CLK         => clk_rd,
      R_ADDR        => R_ADDR_MEM,
      R_DATA        => R_DATA_0,
      R_ADDR_BYPASS => '1',
      R_ADDR_EN     => '1',
      R_ADDR_SL_N   => '1',
      R_ADDR_SD     => '0',
      R_ADDR_AL_N   => '1',
      R_ADDR_AD_N   => '1',
      R_DATA_BYPASS => '0',
      R_DATA_EN     => '1',
      R_DATA_SL_N   => '1',
      R_DATA_SD     => '0',
      R_DATA_AL_N   => '1',
      R_DATA_AD_N   => '1',
      ACCESS_BUSY   => open
      );

   mem_mem_0_1 : RAM64x12 
      port map(
      BUSY_FB       => '0',
      W_CLK         => clk_wr,
      W_ADDR        => W_ADDR_MEM,
      W_EN          => wr_en,
      W_DATA        => data_in(23 downto 12),
      BLK_EN        => '1',
      R_CLK         => clk_rd,
      R_ADDR        => R_ADDR_MEM,
      R_DATA        => R_DATA_1,
      R_ADDR_BYPASS => '1',
      R_ADDR_EN     => '1',
      R_ADDR_SL_N   => '1',
      R_ADDR_SD     => '0',
      R_ADDR_AL_N   => '1',
      R_ADDR_AD_N   => '1',
      R_DATA_BYPASS => '0',
      R_DATA_EN     => '1',
      R_DATA_SL_N   => '1',
      R_DATA_SD     => '0',
      R_DATA_AL_N   => '1',
      R_DATA_AD_N   => '1',
      ACCESS_BUSY   => open
      );

   mem_mem_0_2 : RAM64x12
      port map (
      BUSY_FB       => '0',
      W_CLK         => clk_wr,
      W_ADDR        => W_ADDR_MEM,
      W_EN          => wr_en,
      W_DATA        => W_DATA_2,
      BLK_EN        => '1',
      R_CLK         => clk_rd,
      R_ADDR        => R_ADDR_MEM,
      R_DATA        => R_DATA_2,
      R_ADDR_BYPASS => '1',
      R_ADDR_EN     => '1',
      R_ADDR_SL_N   => '1',
      R_ADDR_SD     => '0',
      R_ADDR_AL_N   => '1',
      R_ADDR_AD_N   => '1',
      R_DATA_BYPASS => '0',
      R_DATA_EN     => '1',
      R_DATA_SL_N   => '1',
      R_DATA_SD     => '0',
      R_DATA_AL_N   => '1',
      R_DATA_AD_N   => '1',
      ACCESS_BUSY   => open
      );

end rtl;



