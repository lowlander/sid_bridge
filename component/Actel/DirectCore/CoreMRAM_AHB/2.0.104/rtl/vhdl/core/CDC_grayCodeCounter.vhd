library ieee;
library CoreMRAM_AHB_LIB;

use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use CoreMRAM_AHB_LIB.mram_pkg.all;


entity CDC_grayCodeCounter is
    generic (
        FAMILY               : integer := 25;    -- Device Family
        bin_rstValue         : integer := 1;
        gray_rstValue        : integer := 0;
        n_bits               : integer := 4
        );
    port (

        clk                 : in std_logic;                                   
        sysRst              : in std_logic; 
        terminate           : in std_logic;                                   
        syncRst             : in std_logic;                                   
        inc                 : in std_logic;                                  
        syncRstOut          : out std_logic;                                   
        cntGray             : out std_logic_vector (n_bits-1 downto 0)                 
	);
end CDC_grayCodeCounter;


architecture rtl of CDC_grayCodeCounter is
 
   component Bin2Gray
      generic (
         n_bits       : in integer := 4 
      );
      port ( 
         cntBinary    : in std_logic_vector (n_bits-1 downto 0);                                  
         nextGray     : out std_logic_vector (n_bits-1 downto 0)
      );
   end component;




   signal cntBinary           : std_logic_vector (n_bits-1 downto 0);
   signal nextGray            : std_logic_vector (n_bits-1 downto 0);
   signal cntBinary_next      : std_logic_vector (n_bits-1 downto 0);

   constant  SYNC_RESET : INTEGER := SYNC_MODE_SEL(FAMILY);
   signal    a_sysRst   : std_logic;
   signal    s_sysRst   : std_logic;

   begin

   a_sysRst <= '1' WHEN (SYNC_RESET=1) ELSE sysRst;
   s_sysRst <= sysRst WHEN (SYNC_RESET=1) ELSE '1';

 
   bin2gray_inst : Bin2Gray
        generic map(
            n_bits     =>     n_bits
        )
        port map (
            cntBinary  =>     cntBinary,
            nextGray   =>     nextGray
        );                         
	
   process (clk, a_sysRst)
   begin
      if (a_sysRst = '0') then
         cntBinary               <= conv_std_logic_vector(bin_rstValue, cntBinary'length);
         cntGray                 <= conv_std_logic_vector(gray_rstValue, cntGray'length);
      elsif (clk'event and clk = '1') then
         if(s_sysRst = '0')then
	    cntBinary               <= conv_std_logic_vector(bin_rstValue, cntBinary'length);
            cntGray                 <= conv_std_logic_vector(gray_rstValue, cntGray'length);
         else
            if( terminate = '1' ) then
               cntBinary               <= conv_std_logic_vector(bin_rstValue, cntBinary'length);
               cntGray                 <= conv_std_logic_vector(gray_rstValue, cntGray'length);
	    elsif(inc = '1' )then
               if ( syncRst= '0' ) then
                  cntBinary               <= conv_std_logic_vector(bin_rstValue, cntBinary'length);
	          cntGray                 <= conv_std_logic_vector(gray_rstValue, cntGray'length);
	       else 
                  cntBinary               <= cntBinary_next;
                  cntGray                 <= nextGray;
               end if;
            end if;
         end if;
      end if;
   end process;

   cntBinary_next <= cntBinary + 1 ;
   syncRstOut     <= '0' when (cntBinary = (cntBinary'range => '0') ) else '1';

end rtl;
