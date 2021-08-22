library ieee;
library CoreMRAM_AHB_LIB;

use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use CoreMRAM_AHB_LIB.mram_pkg.all;


entity CORESYNC_PULSE_CDC is
   generic (
      FAMILY             : integer := 25;    -- Device Family
      NUM_STAGES         : integer := 2
   );
   port (
      SRC_CLK            : in std_logic;
      DSTN_CLK           : in std_logic;
      SRC_RESET          : in std_logic;
      DSTN_RESET         : in std_logic;
      PULSE_IN           : in std_logic;
      SYNC_PULSE         : out std_logic

);
end entity CORESYNC_PULSE_CDC;

architecture CORESYNC_PULSE_CDC_ARCH of CORESYNC_PULSE_CDC is


component pulse_gen
   generic (
      FAMILY                  : integer := 25     -- Device Family
   );
   port (
      src_clk                 : in std_logic;
      src_reset               : in std_logic;
      pulse_in                : in std_logic;
      toggle_out              : out std_logic
   );	 
end component;

component pulse_cdc
   generic (
      FAMILY                  : integer := 25;    -- Device Family
      NUM_STAGES              : integer := 2
   );
   port (
      clk                     : in std_logic;
      reset                   : in std_logic;
      data_in                 : in std_logic;
      sync_pulse              : out std_logic
   );	 
end component;

signal toggle : std_logic;

begin


   pulse_gen_i : pulse_gen
   generic map(
      FAMILY       =>  FAMILY
   )
   port map (
      src_clk      =>  SRC_CLK,
      src_reset    =>  SRC_RESET,
      pulse_in     =>  PULSE_IN,
      toggle_out   =>  toggle 
   );

   pulse_cdc_sync_i : pulse_cdc
   generic map(
      FAMILY       =>  FAMILY,
      NUM_STAGES   =>  NUM_STAGES
   )
   port map (
      clk          =>  DSTN_CLK,
      reset        =>  DSTN_RESET,
      data_in      =>  toggle,
      sync_pulse   =>  SYNC_PULSE
   );

end CORESYNC_PULSE_CDC_ARCH;

