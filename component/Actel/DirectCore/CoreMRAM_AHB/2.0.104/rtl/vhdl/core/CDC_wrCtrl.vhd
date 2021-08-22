library ieee;
library CoreMRAM_AHB_LIB;

use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use CoreMRAM_AHB_LIB.mram_pkg.all;

entity CDC_wrCtrl is
    generic (
        FAMILY              : integer := 25;    -- Device Family
        ADDR_WIDTH          : integer := 3
        );
    port (

        clk                 : in std_logic;                                   
        rst                 : in std_logic; 
        terminate           : in std_logic;                                   
        rdPtr_gray          : in std_logic_vector (ADDR_WIDTH-1 downto 0);                                   
        wrPtr_gray          : in std_logic_vector (ADDR_WIDTH-1 downto 0);                                  
        nextwrPtr_gray      : in std_logic_vector (ADDR_WIDTH-1 downto 0);                                  
        infoInValid         : in std_logic;                                   
        readyForInfo        : out std_logic;                                   
        fifoWe              : out std_logic                 
	);
end CDC_wrCtrl;


architecture rtl of CDC_wrCtrl is
   
   

   signal ptrsEq_wrZone    : std_logic;
   signal rdEqWrP1         : std_logic;
   signal full             : std_logic;

   constant  SYNC_RESET : INTEGER := SYNC_MODE_SEL(FAMILY);
   signal    a_rst   : std_logic;
   signal    s_rst   : std_logic;

   begin

   a_rst <= '1' WHEN (SYNC_RESET=1) ELSE rst;
   s_rst <= rst WHEN (SYNC_RESET=1) ELSE '1';



   ptrsEq_wrZone <= '1' when (rdPtr_gray = wrPtr_gray) else '0';
   rdEqWrP1      <= '1' when (rdPtr_gray = nextwrPtr_gray) else '0';
 
   fifoWe        <= infoInValid; 
   readyForInfo  <= full;
 
 
   process (clk, a_rst)
   begin
      if (a_rst = '0') then
         full <= '0';
      elsif (clk'event and clk = '1') then
         if (s_rst = '0')then
	    full <= '0';
         else
            if(terminate ='1' ) then
               full <= '0';
	    elsif(ptrsEq_wrZone = '1')then
               full <= full;
            else 
               if ( rdEqWrP1= '1' ) then
                  if (infoInValid = '1') then
                     full <= '1';
	          else
                     full <= '0';
                  end if;
	       else
	          full <= '0';
               end if;
            end if;
         end if;
      end if;
   end process;




end rtl;
