-- ********************************************************************/
-- Actel Corporation Proprietary and Confidential
-- Copyright 2009 Actel Corporation.  All rights reserved.
--
-- ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
-- ACCORDANCE WITH THE ACTEL LICENSE AGREEMENT AND MUST BE APPROVED
-- IN ADVANCE IN WRITING.
--
--
-- Description :
--          Simple model of asynchronous type memory
--
--
-- SVN Revision Information:
-- SVN $Revision: 6822 $
-- SVN $Date: 2009-02-23 20:54:01 +0530 (Mon, 23 Feb 2009) $
--
-- Resolved SARs
-- SAR      Date     Who   Description
--
--
-- Notes:
--
--
-- *********************************************************************/

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.std_logic_unsigned."-";
use     ieee.numeric_std.all;

entity async_memory_32dq is
    port (
        -- Inputs
        A       : in  std_logic_vector(18 downto 0);    -- Address bus
        CSN     : in  std_logic;                        -- Chip enable
        OEN     : in  std_logic;                        -- Output enable
        WEN     : in  std_logic;                        -- Write enable
        BYTEN   : in  std_logic_vector(3 downto 0);     -- Byte enables
        -- Inout
        DQ      : inout std_logic_vector(31 downto 0)   -- Data bus
    );
end async_memory_32dq;

architecture behav of async_memory_32dq is
    type arr is array(0 to 1023) of std_logic_vector(31 downto 0);

    signal iDQ              : std_logic_vector(31 downto 0);
    signal A_latch          : std_logic_vector(18 downto 0);
    signal mem              : arr;

    signal read             : std_logic;
    signal write            : std_logic;
    signal BYTEN_i          : std_logic_vector(3 downto 0); 

begin

    BYTEN_i<= inertial BYTEN after 10 ns;
    read  <= not(CSN) and not(OEN) and   WEN   ;
    write <= not(CSN) and   OEN    and not(WEN);

    DQ <= iDQ when (read = '1' or OEN = '0') else "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";

    process (read, A,OEN)
    variable iA : integer;
    begin
        iA := to_integer(unsigned(A));
        if (read = '1') then
            iDQ <= mem(iA);
        elsif(OEN ='0') then
            iDQ <= iDQ;
        else
            iDQ <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
        end if;
    end process;

    -- Latch address input on write rising edge
    process (write, A)
    begin
        if (write'event and write = '1') then
            A_latch <= A;
        end if;
    end process;

    -- Write data on write falling edge
    process (write, BYTEN_i, A_latch, DQ)
    variable iA_latch : integer;
    begin
        iA_latch := to_integer(unsigned(A_latch));
        if (write'event and write = '0') then
           case BYTEN_i(3 downto 0) is
              when "1110" => mem(iA_latch) <= mem(iA_latch)(31 downto 8) & DQ(7 downto 0);
              when "1101" => mem(iA_latch) <= mem(iA_latch)(31 downto 16) & DQ(15 downto 8) & mem(iA_latch)(7 downto 0);
              when "1011" => mem(iA_latch) <= mem(iA_latch)(31 downto 24) & DQ(23 downto 16) & mem(iA_latch)(15 downto 0);
              when "0111" => mem(iA_latch) <= DQ(31 downto 24) & mem(iA_latch)(23 downto 0);
              when "1100" => mem(iA_latch) <= mem(iA_latch)(31 downto 16) & DQ(15 downto 0);
              when "0011" => mem(iA_latch) <= DQ(31 downto 16) & mem(iA_latch)(15 downto 0);
              when "0000" => mem(iA_latch) <= DQ(31 downto 0);
              when others => mem(iA_latch) <= mem(iA_latch);
           end case;
        end if;
    end process;

end behav;
