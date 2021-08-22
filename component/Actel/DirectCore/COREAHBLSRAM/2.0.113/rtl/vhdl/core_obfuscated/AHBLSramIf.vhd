--  Copyright 2011 Actel Corporation.  All rights reserved.
-- ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
-- ACCORDANCE WITH THE ACTEL LICENSE AGREEMENT AND MUST BE APPROVED
-- Revision Information:
-- SVN Revision Information:
-- SVN $Revision: 4805 $
library IeEE;
use iEEe.sTD_LOGic_1164.all;
use ieEE.sTD_logIC_arITH.all;
use IEee.Std_LOgiC_UnsiGNed.all;
use ieEE.STd_lOGIc_MISc.all;
entity CHTOLSRAMl is
generic (ahb_DwidTH: INTegeR := 32;
ahB_awiDTH: INtegER := 32;
CHTOLSRAMi: std_LOgiC_VectOR(1 downto 0) := "00";
CHTOLSRAMoL: Std_LOGic_VEctoR(1 downto 0) := "01";
CHTOLSRAMll: STD_loGIC_vECTor(1 downto 0) := "00";
CHTOLSRAMil: sTD_loGIC_veCTor(1 downto 0) := "01";
CHTOLSRAMoi: Std_LOGic_VEctoR(1 downto 0) := "11";
CHTOLSRAMLI: Std_LOgic_VEctOR(1 downto 0) := "10"); port (hclK: in STd_lOGIc;
HREsetN: in STd_lOGIc;
HSEl: in stD_LogIC;
htrANS: in stD_logIC_veCTOr(1 downto 0);
HBursT: in STD_loGIC_vECTor(2 downto 0);
HWritE: in STd_lOGIc;
HsizE: in std_LogiC_VectOR(2 downto 0);
HadDR: in std_LOgiC_VectOR(19 downto 0);
HwdaTA: in sTD_loGIC_veCTOr(Ahb_DWidtH-1 downto 0);
hREAdyiN: in sTD_loGIC;
CHTOLSRAMII: in STd_LOGic;
CHTOLSRAMO0: in sTD_loGIC_veCTor(Ahb_DWidtH-1 downto 0);
HresP: out sTD_loGIC_veCTOr(1 downto 0);
HReadYOUt: out sTD_loGIC;
hrDATa: out sTD_loGIC_veCTor(ahB_dwiDTH-1 downto 0);
CHTOLSRAML0: out STd_lOGic;
CHTOLSRAMI0: out std_LogiC;
CHTOLSRAMO1: out std_LogiC_VecTOR(aHB_awIDTh-1 downto 0);
CHTOLSRAMl1: out STd_lOGIc_vECTor(2 downto 0);
CHTOLSRAMI1: out sTD_logIC_veCTOr(19 downto 0);
Busy: in Std_LOgic);
end entity CHTOLSRAML;

architecture CHTOLSRAMO of CHTOLSRAML is

constant CHTOLSRAMOIl: stD_logIC_veCTOr(1 downto 0) := "00";

constant CHTOLSRAMlIL: std_LogiC_VectOR(1 downto 0) := "01";

constant CHTOLSRAMiIL: STd_LOGic_VECtoR(1 downto 0) := "10";

signal CHTOLSRAMO0l: std_LogiC_VecTOR(1 downto 0);

signal CHTOLSRAMl0L: STD_loGIc_vECTor(2 downto 0);

signal CHTOLSRAMI0l: stD_logIC_vecTOr(2 downto 0);

signal CHTOLSRAMO1l: stD_logIC_vecTOr(19 downto 0);

signal CHTOLSRAMl1l: STD_lOGIc_vECtor(AHb_DWIdth-1 downto 0);

signal CHTOLSRAMi1L: stD_logIC;

signal CHTOLSRAMOOi: STD_loGIC;

signal CHTOLSRAMloI: Std_LOgic;

signal CHTOLSRAMioi: STd_lOGic_VECtor(1 downto 0);

signal CHTOLSRAMoLI: std_LOgiC_VectOR(1 downto 0);

signal CHTOLSRAMllI: std_LogiC;

signal CHTOLSRAMilI: std_LogiC;

signal CHTOLSRAMoII: stD_logIC;

signal CHTOLSRAMlii: sTD_loGIC_veCTor(Ahb_DWIdth-1 downto 0);

signal CHTOLSRAMiII: sTD_logIC;

signal CHTOLSRAMO0i: sTD_loGIC;

signal CHTOLSRAMl0i: sTD_loGIC_veCTOr(Ahb_DWIdth-1 downto 0);

signal CHTOLSRAMI0I: std_LOgiC_VectOR(19 downto 0);

signal CHTOLSRAMO1i: std_LogiC_VectOR(2 downto 0);

signal CHTOLSRAMl1I: stD_logIC;

signal CHTOLSRAMiOL: STd_lOGic_VECtor(1 downto 0);

signal CHTOLSRAMi1I: STd_lOGic_VECtor(ahB_DwidTH-1 downto 0);

signal CHTOLSRAMOO0: STd_lOGIc;

signal CHTOLSRAMLO0: Std_LOGic;

signal CHTOLSRAMIO0: Std_LOgic_VectOR(ahb_AWidtH-1 downto 0);

signal CHTOLSRAMol0: Std_LOGic_VEctoR(2 downto 0);

signal CHTOLSRAMll0: STD_loGIc_vECTor(19 downto 0);

function CHTOLSRAMil0(VAL: in BoolEAN)
return STd_lOGic is
begin
if (vAL) then
return ('1');
else
return ('0');
end if;
end CHTOLSRAMIL0;

function CHTOLSRAMoI0(Val: in bOOLean)
return STd_LOGic is
begin
return (CHTOLSRAMiL0(VAL));
end CHTOLSRAMoI0;

begin
hREadyOUT <= CHTOLSRAML1i;
HREsp <= CHTOLSRAMIOl;
HrdaTA <= CHTOLSRAMi1i;
CHTOLSRAMl0 <= CHTOLSRAMOO0;
CHTOLSRAMi0 <= CHTOLSRAMLO0;
CHTOLSRAMO1 <= CHTOLSRAMIO0;
CHTOLSRAML1 <= CHTOLSRAMOL0;
CHTOLSRAMI1 <= CHTOLSRAMlL0;
CHTOLSRAMIII <= (HREadYIN and hseL) and CHTOLSRAMOI0(HTraNS = CHTOLSRAMlI);
CHTOLSRAMIOL <= CHTOLSRAMI;
process (hWDAta)
variable CHTOLSRAMli0: Std_LOgic_VEctOR(ahb_DWidTH-1 downto 0);
begin
CHTOLSRAMlI0 := HwdaTA;
CHTOLSRAMLIi <= CHTOLSRAMLI0;
end process;
process (hcLK,hrESEtn)
begin
if (HReseTN = '0') then
CHTOLSRAMo1L <= ( others => '0');
CHTOLSRAML1l <= ( others => '0');
CHTOLSRAMo0L <= "00";
CHTOLSRAMi0L <= "000";
CHTOLSRAMl0L <= "000";
CHTOLSRAMI1l <= '0';
CHTOLSRAMooI <= '0';
CHTOLSRAMloi <= '0';
elsif (Hclk'eveNT and HCLk = '1') then
if (CHTOLSRAMlLI = '1') then
CHTOLSRAMO1L <= HadDR;
CHTOLSRAMo0l <= HtraNS;
CHTOLSRAMi0L <= HsizE;
CHTOLSRAML0l <= hbURSt;
CHTOLSRAMi1L <= hwRITe;
CHTOLSRAML1l <= CHTOLSRAMliI;
CHTOLSRAMOOI <= Hsel;
CHTOLSRAMlOI <= HreaDYIn;
end if;
end if;
end process;
process (hcLK,hrESetn)
begin
if (hRESetN = '0') then
CHTOLSRAMIoi <= CHTOLSRAMoIL;
elsif (HCLk'eVEnt and hclK = '1') then
CHTOLSRAMIoi <= CHTOLSRAMOli;
end if;
end process;
process (HwrITE,CHTOLSRAMiI,CHTOLSRAMiiI,CHTOLSRAMolI,CHTOLSRAMiOI,CHTOLSRAMllI)
variable CHTOLSRAMIi0: stD_LogIC;
variable CHTOLSRAMO00: sTD_loGIC;
variable CHTOLSRAML00: STD_loGIC_vECTor(1 downto 0);
begin
CHTOLSRAMii0 := '0';
CHTOLSRAMo00 := '0';
CHTOLSRAMl00 := CHTOLSRAMIOi;
case CHTOLSRAMioi is
when CHTOLSRAMOil =>
if (CHTOLSRAMiII = '1') then
CHTOLSRAMii0 := '1';
if (hwRIte = '1') then
CHTOLSRAML00 := CHTOLSRAMLil;
else
CHTOLSRAML00 := CHTOLSRAMIIL;
end if;
end if;
when CHTOLSRAMLil =>
CHTOLSRAMiI0 := '0';
CHTOLSRAMo00 := '1';
if (CHTOLSRAMII = '1') then
CHTOLSRAML00 := CHTOLSRAMoIL;
end if;
when CHTOLSRAMiiL =>
CHTOLSRAMIi0 := '0';
CHTOLSRAMO00 := '1';
if (CHTOLSRAMiI = '1') then
CHTOLSRAMl00 := CHTOLSRAMOIl;
end if;
when others =>
CHTOLSRAMl00 := CHTOLSRAMoil;
end case;
CHTOLSRAMLLi <= CHTOLSRAMiI0;
CHTOLSRAMiLI <= CHTOLSRAMO00;
CHTOLSRAMOLi <= CHTOLSRAML00;
end process;
CHTOLSRAML1i <= not CHTOLSRAMili;
CHTOLSRAMO0i <= CHTOLSRAMi1L when (CHTOLSRAMoo0 and not CHTOLSRAMiI) = '1' else
'0';
CHTOLSRAMLO0 <= CHTOLSRAMo0I;
CHTOLSRAML0i <= hwdATa;
CHTOLSRAMiO0 <= CHTOLSRAMl0I;
CHTOLSRAMi0i <= CHTOLSRAMO1l when (CHTOLSRAMILi and not CHTOLSRAMiI) = '1' else
CHTOLSRAMO1l;
CHTOLSRAMLL0 <= CHTOLSRAMI0i;
CHTOLSRAMo1I <= CHTOLSRAMI0L when (CHTOLSRAMiLI and not CHTOLSRAMii) = '1' else
HsizE;
CHTOLSRAMOl0 <= CHTOLSRAMO1i;
process (HClk,hRESetN)
begin
if (HresETn = '0') then
CHTOLSRAMoii <= '0';
elsif (Hclk'EVEnt and Hclk = '1') then
CHTOLSRAMOII <= CHTOLSRAMiLI;
end if;
end process;
CHTOLSRAMoo0 <= (CHTOLSRAMILI and not CHTOLSRAMOIi) and CHTOLSRAMOI0(CHTOLSRAML0l = "000");
process (CHTOLSRAMo0,hrEADyin,CHTOLSRAMl1i)
variable CHTOLSRAMI00: sTD_loGIC_veCTOr(AHB_dwIDTh-1 downto 0);
begin
if ((CHTOLSRAML1I and HREadyIN) = '1') then
CHTOLSRAMI00 := CHTOLSRAMo0;
else
CHTOLSRAMi00 := CHTOLSRAMO0;
end if;
CHTOLSRAMI1I <= CHTOLSRAMi00;
end process;
end architecture CHTOLSRAMo;
