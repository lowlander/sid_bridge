--      Version:  4.0
--         Date:  July 14th, 2009
--  Description:  PWM Generation Module
-- SVN Revision Information:
-- SVN $Revision: 10769 $
-- SVN $Date: 2009-11-05 15:38:11 -0800 (Thu, 05 Nov 2009) $  
-- COPYRIGHT 2009 BY ACTEL 
-- THE INFORMATION CONTAINED IN THIS DOCUMENT IS SUBJECT TO LICENSING RESTRICTIONS 
-- FROM ACTEL CORP.  IF YOU ARE NOT IN POSSESSION OF WRITTEN AUTHORIZATION FROM 
-- ACTEL FOR USE OF THIS FILE, THEN THE FILE SHOULD BE IMMEDIATELY DESTROYED AND 
-- NO BACK-UP OF THE FILE SHOULD BE MADE. 
library ieee;
use Ieee.STD_logic_1164.all;
use ieee.numeric_std.all;
use ieEE.std_logIC_ARITH.all;
use IEEE.std_logic_unsIGNED.all;
entity pwm_gen is
generic (PWM_NUM: integer := 1;
APB_Dwidth: INTEGER := 8;
DAC_mode: stD_LOGIC_VECTOr(15 downto 0) := "0000000000000000"); port (PRESETn: in std_logIC;
PCLK: in STD_logic;
pwm: out std_logic_vectOR(Pwm_num downto 1);
PERIOd_cnt: in sTD_LOGIC_VECTor(APB_DWidth-1 downto 0);
PWM_Enable_reg: in sTD_LOGIC_VECTor(PWM_NUM downto 1);
pwm_posedgE_REG: in STD_LOGIC_VEctor((Pwm_num*APb_dwidth) downto 1);
PWM_NEGEDGe_reg: in stD_LOGIC_VECTOr((pwm_num*apb_DWIDTH) downto 1);
SYNC_PUlse: in STD_LOgic);
end PWM_gen;

architecture CPWMo of PWM_GEN is

signal CPWMi: sTD_LOGIC_VECTor(pwm_num downto 1);

signal CPWMoiol: std_loGIC_VECTOR(PWM_num*(apb_DWIDTH+1) downto 1);

begin
pwm(pwm_num downto 1) <= CPWMI(Pwm_num downto 1);
CPWMLIOL:
for Z in 1 to Pwm_num
generate
CPWMiiol:
if (dac_mode(z-1) = '0')
generate
process (presetn,PCLK)
begin
if ((not (PRESETN)) = '1') then
CPWMI(Z) <= '0';
elsif (PCLK'EVENT and Pclk = '1') then
if (PWM_ENABle_reg(Z) = '0') then
CPWMI(Z) <= '0';
elsif ((pWM_ENABLE_REG(z) = '1') and (sync_pULSE = '1')) then
if ((pwm_POSEDGE_REG(z*APB_dwidth downto (Z-1)*APB_DWIDTH+1) = PWM_NEGEDGE_reg(z*apb_DWIDTH downto (Z-1)*APB_DWIDTH+1)) and ((PWM_POSEdge_reg(z*apb_dWIDTH downto (z-1)*APb_dwidth+1)) = period_cnt)) then
CPWMi(z) <= not (CPWMI(Z));
elsif ((PWM_ENABLE_reg(z) = '1') and (SYNC_PULSE = '1')
and (Pwm_posedge_reg(z*APB_DWidth downto (Z-1)*APB_DWIDTH+1)) = pERIOD_CNT) then
CPWMI(z) <= '1';
elsif ((pwm_enaBLE_REG(z) = '1') and (sync_pulSE = '1')
and (pwm_negeDGE_REG(z*APB_DWIDTH downto (z-1)*APB_DWIDTH+1)) = period_cnt) then
CPWMi(Z) <= '0';
end if;
end if;
end if;
end process;
end generate;
CPWMo0ol:
if (not (dac_mode(Z-1) = '0'))
generate
process (presetN,pclk)
begin
if ((not (presetn)) = '1') then
CPWMOIOL(z*(APB_DWIDTH+1) downto (Z-1)*(Apb_dwidth+1)+1) <= ( others => '0');
CPWMi(Z) <= '0';
elsif (PCLK'event and pclk = '1') then
if (pwm_enable_reG(z) = '0') then
CPWMI(z) <= '0';
elsif (pwm_enable_REG(z) = '1') then
CPWMoiol(z*(apb_dwidth+1) downto (Z-1)*(apb_dwidth+1)+1) <= ('0'&CPWMoiol((z*(APB_dwidth+1))-1 downto (Z-1)*(apB_DWIDTH+1)+1)+pwm_negedge_reg(Z*Apb_dwidth downto ((Z-1)*aPB_DWIDTH)+1));
CPWMI(Z) <= CPWMoiol(z*(apb_dwidtH+1));
end if;
end if;
end process;
end generate;
end generate;
end CPWMO;
