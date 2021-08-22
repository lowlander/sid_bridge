
library ieee;
library CoreMRAM_AHB_LIB;

use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use CoreMRAM_AHB_LIB.mram_pkg.all;


entity CDC_rdCtrl is
    generic (
        FAMILY                  : integer := 25;    -- Device Family
        ADDR_WIDTH               : integer := 3
        );
    port (

        clk                 : in std_logic;                                   
        rst                 : in std_logic; 
        terminate           : in std_logic;                                   
        rdPtr_gray          : in std_logic_vector (ADDR_WIDTH-1 downto 0);                                   
        wrPtr_gray          : in std_logic_vector (ADDR_WIDTH-1 downto 0);                                  
        nextrdPtr_gray      : in std_logic_vector (ADDR_WIDTH-1 downto 0);                                  
        readyForOut         : in std_logic;                                   
        infoOutValid        : out std_logic;                                   
        fifoRe              : out std_logic                 
	);
end CDC_rdCtrl;


architecture rtl of CDC_rdCtrl is


   signal ptrsEq_rdZone    : std_logic;
   signal wrEqRdP1         : std_logic;
   signal fifoRe_int       : std_logic;
   signal infoOutValid_int : std_logic;
   signal empty            : std_logic;

   constant  SYNC_RESET : INTEGER := SYNC_MODE_SEL(FAMILY);
   signal    a_rst   : std_logic;
   signal    s_rst   : std_logic;

   begin

   a_rst <= '1' WHEN (SYNC_RESET=1) ELSE rst;
   s_rst <= rst WHEN (SYNC_RESET=1) ELSE '1';

 
   
   ptrsEq_rdZone <= '1' when (rdPtr_gray = wrPtr_gray) else '0';
   wrEqRdP1      <= '1' when (wrPtr_gray = nextrdPtr_gray) else '0';
 
   fifoRe_int        <= infoOutValid_int and  readyForOut;
   fifoRe            <= fifoRe_int;
   infoOutValid_int  <= not empty;
   infoOutValid      <= infoOutValid_int;
 
 
	
   process (clk, a_rst)
   begin
      if (a_rst = '0') then
         empty <= '1';
      elsif (clk'event and clk = '1') then
         if (s_rst = '0') then
            empty <= '1';
         else
            if(terminate = '1') then
               empty <= '1';
            else --then
               if(ptrsEq_rdZone = '1')then
                  empty <= empty;
               else --then
                  if ( wrEqRdP1= '1' ) then
                     if (fifoRe_int = '1') then
                        empty <= '1';
	             else --then
                        empty <= '0';
                     end if;
	          else --then
	             empty <= '0';
                  end if;
               end if;
            end if;
         end if;
      end if;
   end process;

 

end rtl;
 
