--      Version:  4.0
--         Date:  July 14th, 2009
--  Description:  Timebase module
-- SVN Revision Information:
-- SVN $Revision: 10769 $
-- SVN $Date: 2009-11-05 15:38:11 -0800 (Thu, 05 Nov 2009) $  
-- COPYRIGHT 2009 BY ACTEL 
-- THE INFORMATION CONTAINED IN THIS DOCUMENT IS SUBJECT TO LICENSING RESTRICTIONS 
-- FROM ACTEL CORP.  IF YOU ARE NOT IN POSSESSION OF WRITTEN AUTHORIZATION FROM 
-- ACTEL FOR USE OF THIS FILE, THEN THE FILE SHOULD BE IMMEDIATELY DESTROYED AND 
-- NO BACK-UP OF THE FILE SHOULD BE MADE. 
library IEEe;
use Ieee.stD_LOGIC_1164.all;
use IEEE.STD_logic_unsigned.all;
entity timebase is
generic (APB_dwidth: integeR := 8); port (Presetn: in STD_logic;
pclk: in std_logic;
period_reg: in Std_logic_vector(APB_dwidth-1 downto 0);
PRESCALE_reg: in STD_LOGIC_Vector(APB_DWIDth-1 downto 0);
PERIOD_CNt: out std_logic_VECTOR(aPB_DWIDTH-1 downto 0);
synC_PULSE: out stD_LOGIC);
end TIMEbase;

architecture CPWMO of timebase is

signal CPWMi11l: std_logic_VECTOR(apb_dwidth-1 downto 0);

signal CPWMoooi: Std_logic_vector(APB_DWidth-1 downto 0);

begin
process (preSETN,PCLK)
begin
if ((not (PRESETN)) = '1') then
CPWMi11l <= ( others => '0');
elsif (pclk'event and PCLK = '1') then
if (CPWMI11L >= PRESCALE_REG) then
CPWMi11L <= ( others => '0');
else
CPWMi11L <= CPWMi11l+"01";
end if;
end if;
end process;
process (presetn,pclk)
begin
if ((not (Presetn)) = '1') then
CPWMoooi <= ( others => '0');
elsif (pclk'EVENT and pclk = '1') then
if ((CPWMOOOI >= PERIOD_reg) and (CPWMI11L >= PREScale_reg)) then
CPWMoooi <= ( others => '0');
elsif (CPWMi11l = prescale_reg) then
CPWMoooi <= CPWMoooi+"01";
end if;
end if;
end process;
PERIOD_cnt <= CPWMoooi;
syNC_PULSE <= '1' when CPWMi11l >= preSCALE_REG else
'0';
end CPWMo;
