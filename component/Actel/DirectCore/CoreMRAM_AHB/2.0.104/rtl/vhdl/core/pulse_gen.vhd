library ieee;
library CoreMRAM_AHB_LIB;

use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use CoreMRAM_AHB_LIB.mram_pkg.all;


entity pulse_gen is
   generic (
      FAMILY             : integer := 25    -- Device Family
   );
   port (
      src_clk            : in std_logic;                          
      src_reset          : in std_logic;                        
      pulse_in           : in std_logic;                         
      toggle_out         : out std_logic

);
end entity pulse_gen;

architecture pulse_gen_ARCH of pulse_gen is

signal toggle_out_int : std_logic;
constant  SYNC_RESET : INTEGER := SYNC_MODE_SEL(FAMILY);
signal    aresetn           : std_logic;
signal    sresetn           : std_logic;

begin

aresetn <= '1' WHEN (SYNC_RESET=1) ELSE src_reset;
sresetn <= src_reset WHEN (SYNC_RESET=1) ELSE '1';

process (src_clk, aresetn)
begin
   if (aresetn = '0') then
      toggle_out_int <= '0';
   elsif (src_clk'event and src_clk = '1') then
      if(sresetn ='0') then
         toggle_out_int <= '0';
      else
         if(pulse_in = '1') then
            toggle_out_int <= not toggle_out_int;
         end if;
      end if;
   end if;
end process ; 


toggle_out <=toggle_out_int;

end pulse_gen_ARCH;
