library Ieee;
use ieee.STD_logic_1164.all;
use ieee.STD_LOgic_unsigned.all;
entity tach_if is
generic (TACH_NUM: integer := 1); port (pclk: in STD_LOGIC;
presetn: in std_LOGIC;
TACHIN: in STD_LOGIC;
TACHMODE: in STD_LOGIC;
TACH_EDGe: in STD_LOGIC;
TAChstatus: in Std_logic;
status_clEAR: in std_logic;
tacH_CNT_CLK: in STD_LOGIC;
TACHpulsedur: out std_logic_VECTOR(15 downto 0);
UPDATE_status: out Std_logic);
end entity TACH_if;

architecture CPWMo of TACH_IF is

constant cnT0: STD_LOGIC := '0';

constant CNT1: std_logiC := '1';

signal CPWMI10l: STD_LOGIC_vector(15 downto 0);

signal CPWMoO1L: std_logic_vector(15 downto 0);

signal CPWMlo1l: std_logic;

signal CPWMIO1L: std_loGIC;

signal CPWMol1l: std_logic_vECTOR(15 downto 0);

signal CPWMll1l: STD_LOGIC_vector(15 downto 0);

signal CPWMil1l: std_logic;

signal CPWMoi1L: STd_logic;

signal CPWMli1L: std_logic;

signal CPWMII1L: std_logic;

signal CPWMo01l: STD_LOGIC;

signal CPWML01L: std_logic;

signal CPWMI01L: std_logic;

signal CPWMO11L: std_loGIC_VECTOR(15 downto 0);

signal CPWMl11L: STD_logic;

begin
process (pRESETN,PCLK)
begin
if ((not (PRESETN)) = '1') then
CPWMo11l <= "0000000000000000";
elsif (PCLK'evENT and PCLK = '1') then
CPWMo11L <= CPWMOL1l;
end if;
end process;
TACHpulsedur <= CPWMO11L;
UPDATE_STATUs <= CPWMl11l;
process (presetn,pclk)
begin
if ((not (PRESETN)) = '1') then
CPWMI10L <= "0000000000000000";
CPWMOL1L <= "0000000000000000";
CPWMo01l <= '0';
CPWMl01l <= '0';
CPWMi01l <= '0';
CPWMII1L <= '0';
CPWMlo1l <= '0';
CPWMl11l <= '0';
CPWMoi1l <= '0';
elsif (PCLK'EVENT and PCLK = '1') then
if (TACH_CNT_clk = '1') then
CPWMoi1l <= CPWMLI1l;
CPWMo01l <= tachin;
CPWMl01l <= CPWMo01l;
CPWMI01L <= CPWMl01l;
CPWMOL1l <= CPWMlL1L;
CPWMl11l <= CPWMIL1L;
CPWMi10l <= CPWMoo1l;
if (CPWMio1l = '1') then
CPWMLO1L <= '1';
elsif (CPWMII1L = '1') then
CPWMlo1L <= '0';
end if;
if ((TAchstatus = '0') and (TACH_EDGE = '1')) then
CPWMii1l <= ((CPWML01L) and (not (CPWMi01l)));
else
CPWMII1l <= ((not (CPWMl01l)) and (CPWMi01l));
end if;
end if;
end if;
end process;
process (CPWMol1l,CPWMoi1l,CPWMii1L,CPWMLO1L,statUS_CLEAR,tachmoDE,CPWMi10l)
begin
CPWMll1l <= CPWMol1l;
CPWMoo1l <= "0000000000000000";
CPWMil1l <= '0';
CPWMLi1l <= CPWMoi1l;
CPWMIO1l <= '0';
case CPWMoi1l is
when cnt0 =>
CPWMLI1L <= CNT0;
CPWMIO1l <= '0';
if (CPWMIi1l = '1') then
CPWMoo1l <= "0000000000000000";
CPWMli1l <= Cnt1;
end if;
when cnt1 =>
CPWMLL1L <= CPWMol1L;
CPWMil1l <= '0';
CPWMli1l <= cnt1;
CPWMIO1l <= '0';
if (CPWMii1l = '1') then
CPWMOO1l <= "0000000000000000";
CPWMio1l <= '0';
if ((CPWMLO1l = '1') and (STATUS_clear = '1')) then
CPWMLL1L <= "0000000000000000";
else
if ((tachmode = '1') and (STATUS_Clear = '1')) then
CPWMll1l <= CPWMI10L+"0000000000000001";
elsif (tachmODE = '0') then
if (CPWMlo1l = '1') then
CPWMll1l <= "0000000000000000";
else
CPWMll1L <= CPWMi10L+"0000000000000001";
end if;
end if;
if (STatus_clear = '1') then
CPWMIL1L <= '1';
end if;
end if;
else
if (CPWMLO1L = '0') then
CPWMOO1L <= CPWMI10L+"0000000000000001";
if (CPWMI10L = "1111111111111111") then
CPWMio1l <= '1';
end if;
end if;
end if;
when others =>
CPWMLI1L <= cnt0;
end case;
end process;
end architecture CPWMo;
