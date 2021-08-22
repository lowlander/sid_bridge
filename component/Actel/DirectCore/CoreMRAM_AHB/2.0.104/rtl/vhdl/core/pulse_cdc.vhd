library ieee;
library CoreMRAM_AHB_LIB;

use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use CoreMRAM_AHB_LIB.mram_pkg.all;


entity pulse_cdc is
   generic (
      FAMILY                : integer := 25;    -- Device Family
      NUM_STAGES            : integer := 2
   );
   port (
      clk            : in std_logic;
      reset          : in std_logic;
      data_in        : in std_logic;
      sync_pulse     : out std_logic
   );
end entity pulse_cdc;

architecture pulse_cdc_ARCH of pulse_cdc is




signal sync_ff : std_logic_vector(NUM_STAGES downto 0);

constant  SYNC_RESET : INTEGER := SYNC_MODE_SEL(FAMILY);
signal    aresetn           : std_logic;
signal    sresetn           : std_logic;

begin

aresetn <= '1' WHEN (SYNC_RESET=1) ELSE reset;
sresetn <= reset WHEN (SYNC_RESET=1) ELSE '1';


   process (clk, aresetn)
   begin
      if (aresetn = '0') then
         sync_ff <= ( others => '0');
      elsif (clk'event and clk = '1') then
         if(sresetn = '0') then
            sync_ff <= ( others => '0');
         else
            sync_ff <=  sync_ff(NUM_STAGES-1 downto 0) &  data_in;
         end if;
      end if;
   end process ;
  
   sync_pulse <= sync_ff(NUM_STAGES) xor sync_ff(NUM_STAGES-1);


end pulse_cdc_ARCH;
