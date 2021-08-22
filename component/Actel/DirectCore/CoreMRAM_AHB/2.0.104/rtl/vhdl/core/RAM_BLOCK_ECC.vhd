library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity MRAMAHB_RAM_BLOCK_ECC is
   generic (
   FAMILY            : integer := 25;
   ECC               : integer := 1;
   MEM_DEPTH         : integer := 16;
   ADDR_WIDTH        : integer := 10;
   DATA_WIDTH        : integer := 32
   );
   port (
   clk_wr            : in std_logic;   
   clk_rd            : in std_logic;   
   wr_en             : in std_logic;   
   rd_addr           : in std_logic_vector (ADDR_WIDTH-1 downto 0);   
   wr_addr           : in std_logic_vector (ADDR_WIDTH-1 downto 0);   
   data_in           : in std_logic_vector (DATA_WIDTH-1 downto 0);   
   data_out          : out std_logic_vector (DATA_WIDTH-1 downto 0);  
   flag_sb_bd        : out std_logic;   
   flag_db_bd        : out std_logic   
   );
end  MRAMAHB_RAM_BLOCK_ECC;

architecture rtl of MRAMAHB_RAM_BLOCK_ECC is


component PF_URAM
   generic (
      MEM_DEPTH    : integer := 31;
      ADDR_WIDTH   : integer := 8
   );
   port (
      clk_wr       : in std_logic;
      clk_rd       : in std_logic; 
      wr_en        : in std_logic;
      wr_addr      : in std_logic_vector (ADDR_WIDTH-1 downto 0);
      rd_addr      : in std_logic_vector (ADDR_WIDTH-1 downto 0);
      data_in      : in std_logic_vector (31 downto 0);
      data_out     : out std_logic_vector (31 downto 0)
     );
end component;

component PF_LSRAM
   generic (
      ECC          : integer := 1;
      MEM_DEPTH    : integer := 31;
      ADDR_WIDTH   : integer := 8
   );
   port (
      clk_wr       : in std_logic;
      clk_rd       : in std_logic; 
      wr_en        : in std_logic;
      wr_addr      : in std_logic_vector (ADDR_WIDTH-1 downto 0);
      rd_addr      : in std_logic_vector (ADDR_WIDTH-1 downto 0);
      data_in      : in std_logic_vector (31 downto 0);
      data_out     : out std_logic_vector (31 downto 0);
      flag_sb_bd   : out std_logic;   
      flag_db_bd   : out std_logic   
   );
end component;

component RTG4_URAM
   generic (
      ECC          : integer := 1;
      MEM_DEPTH    : integer := 31;
      ADDR_WIDTH   : integer := 8  
   );
   port (
      clk_wr       : in std_logic;
      clk_rd       : in std_logic; 
      wr_en        : in std_logic;
      wr_addr      : in std_logic_vector (ADDR_WIDTH-1 downto 0);
      rd_addr      : in std_logic_vector (ADDR_WIDTH-1 downto 0);
      data_in      : in std_logic_vector (31 downto 0);
      data_out     : out std_logic_vector (31 downto 0);
      flag_sb_bd   : out std_logic;   
      flag_db_bd   : out std_logic   
   );
end component;


component RTG4_LSRAM
   generic (
      ECC          : integer := 1;
      MEM_DEPTH    : integer := 31;
      ADDR_WIDTH   : integer := 8
   );
   port (
      clk_wr       : in std_logic;
      clk_rd       : in std_logic; 
      wr_en        : in std_logic;
      wr_addr      : in std_logic_vector (ADDR_WIDTH-1 downto 0);
      rd_addr      : in std_logic_vector (ADDR_WIDTH-1 downto 0);
      data_in      : in std_logic_vector (31 downto 0);
      data_out     : out std_logic_vector (31 downto 0);
      flag_sb_bd   : out std_logic;   
      flag_db_bd   : out std_logic   
   );
end component;


component SF2_URAM
   generic (
      MEM_DEPTH    : integer := 31;
      ADDR_WIDTH   : integer := 8 
   );
   port (
      clk_wr       : in std_logic;
      clk_rd       : in std_logic; 
      wr_en        : in std_logic;
      wr_addr      : in std_logic_vector (ADDR_WIDTH-1 downto 0);
      rd_addr      : in std_logic_vector (ADDR_WIDTH-1 downto 0);
      data_in      : in std_logic_vector (31 downto 0);
      data_out     : out std_logic_vector (31 downto 0)
   );
end component;

component SF2_LSRAM
   generic (
      MEM_DEPTH    : integer := 31;
      ADDR_WIDTH   : integer := 8
   );
   port (
      clk_wr       : in std_logic;
      clk_rd       : in std_logic; 
      wr_en        : in std_logic;
      wr_addr      : in std_logic_vector (ADDR_WIDTH-1 downto 0);
      rd_addr      : in std_logic_vector (ADDR_WIDTH-1 downto 0);
      data_in      : in std_logic_vector (31 downto 0);
      data_out     : out std_logic_vector (31 downto 0)
   );
end component;

begin


IGLOO_SF2_URAM_GENERATE : if ((FAMILY = 19 or FAMILY = 24) and (MEM_DEPTH =16 or MEM_DEPTH =32 or MEM_DEPTH = 64))  generate
   ram_mem : SF2_URAM
      generic map(
         MEM_DEPTH        =>  MEM_DEPTH,
         ADDR_WIDTH       =>  ADDR_WIDTH
      )
      port map (
         clk_wr           =>  clk_wr,
         clk_rd           =>  clk_rd,
         wr_en            =>  wr_en,
         wr_addr          =>  wr_addr,
         rd_addr          =>  rd_addr, 
         data_in          =>  data_in, 
         data_out         =>  data_out
      );  
end generate IGLOO_SF2_URAM_GENERATE;

IGLOO_SF2_LSRAM_GENERATE : if ((FAMILY = 19 or FAMILY = 24) and (MEM_DEPTH =128 or MEM_DEPTH =256 or MEM_DEPTH = 512 or MEM_DEPTH = 1024))  generate
   ram_mem : SF2_LSRAM
      generic map(
         MEM_DEPTH        =>  MEM_DEPTH,
         ADDR_WIDTH       =>  ADDR_WIDTH
      )
      port map (
         clk_wr           =>  clk_wr,
         clk_rd           =>  clk_rd,
         wr_en            =>  wr_en,
         wr_addr          =>  wr_addr,
         rd_addr          =>  rd_addr, 
         data_in          =>  data_in, 
         data_out         =>  data_out
      );  
end generate IGLOO_SF2_LSRAM_GENERATE;


RTG4_URAM_GENERATE : if ((FAMILY = 25) and (MEM_DEPTH =16 or MEM_DEPTH =32 or MEM_DEPTH = 64))  generate
   ram_mem : RTG4_URAM
      generic map(
         ECC              =>  ECC,
         MEM_DEPTH        =>  MEM_DEPTH,
         ADDR_WIDTH       =>  ADDR_WIDTH
      )
      port map (
         clk_wr           =>  clk_wr,
         clk_rd           =>  clk_rd,
         wr_en            =>  wr_en,
         wr_addr          =>  wr_addr,
         rd_addr          =>  rd_addr, 
         data_in          =>  data_in, 
         data_out         =>  data_out,
	 flag_sb_bd       =>  flag_sb_bd,
         flag_db_bd       =>  flag_db_bd
      );  
end generate RTG4_URAM_GENERATE;

RTG4_LSRAM_GENERATE : if ((FAMILY = 25) and (MEM_DEPTH =128 or MEM_DEPTH =256 or MEM_DEPTH = 512 or MEM_DEPTH = 1024))  generate
   ram_mem : RTG4_LSRAM
      generic map(
         ECC              =>  ECC,
         MEM_DEPTH        =>  MEM_DEPTH,
         ADDR_WIDTH       =>  ADDR_WIDTH
      )
      port map (
         clk_wr           =>  clk_wr,
         clk_rd           =>  clk_rd,
         wr_en            =>  wr_en,
         wr_addr          =>  wr_addr,
         rd_addr          =>  rd_addr, 
         data_in          =>  data_in, 
         data_out         =>  data_out,
         flag_sb_bd       =>  flag_sb_bd,
         flag_db_bd       =>  flag_db_bd
      );  
end generate RTG4_LSRAM_GENERATE;



PF_URAM_GENERATE : if ((FAMILY = 26 or FAMILY = 27) and ((ECC = 0) and (MEM_DEPTH =16 or MEM_DEPTH =32 or MEM_DEPTH = 64)))  generate
   ram_mem : PF_URAM
      generic map(
         MEM_DEPTH        =>  MEM_DEPTH,
         ADDR_WIDTH       =>  ADDR_WIDTH
      )
      port map (
         clk_wr           =>  clk_wr,
         clk_rd           =>  clk_rd,
         wr_en            =>  wr_en,
         wr_addr          =>  wr_addr,
         rd_addr          =>  rd_addr, 
         data_in          =>  data_in, 
         data_out         =>  data_out
      );  
end generate PF_URAM_GENERATE;

PF_LSRAM_GENERATE : if ((FAMILY = 26 or FAMILY = 27) and (((ECC = 1) and (MEM_DEPTH =16 or MEM_DEPTH =32 or MEM_DEPTH = 64)) or (MEM_DEPTH =128 or MEM_DEPTH =256 or MEM_DEPTH = 512 or MEM_DEPTH = 1024)))  generate
   ram_mem : PF_LSRAM
      generic map(
         ECC              =>  ECC,
         MEM_DEPTH        =>  MEM_DEPTH,
         ADDR_WIDTH       =>  ADDR_WIDTH
      )
      port map (
         clk_wr           =>  clk_wr,
         clk_rd           =>  clk_rd,
         wr_en            =>  wr_en,
         wr_addr          =>  wr_addr,
         rd_addr          =>  rd_addr, 
         data_in          =>  data_in, 
         data_out         =>  data_out,
         flag_sb_bd       =>  flag_sb_bd,
         flag_db_bd       =>  flag_db_bd
      );  
end generate PF_LSRAM_GENERATE;

end rtl;

