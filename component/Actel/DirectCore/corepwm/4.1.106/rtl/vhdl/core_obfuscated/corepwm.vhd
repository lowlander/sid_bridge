--      Version:  4.0
--         Date:  July 5th, 2009
--  Description:  Top level module
-- SVN Revision Information:
-- SVN $Revision: 10225 $
-- SVN $Date: 2009-10-14 10:36:41 -0700 (Wed, 14 Oct 2009) $  
-- COPYRIGHT 2009 BY ACTEL 
-- THE INFORMATION CONTAINED IN THIS DOCUMENT IS SUBJECT TO LICENSING RESTRICTIONS 
-- FROM ACTEL CORP.  IF YOU ARE NOT IN POSSESSION OF WRITTEN AUTHORIZATION FROM 
-- ACTEL FOR USE OF THIS FILE, THEN THE FILE SHOULD BE IMMEDIATELY DESTROYED AND 
-- NO BACK-UP OF THE FILE SHOULD BE MADE. 
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_uNSIGNED.all;
use IEEE.nuMERIC_STD.all;
entity corepwm is
generic (FAMIly: inteGER := 0;
CONfig_mode: INTEGer := 1;
pwm_num: INTEGER := 16;
apb_dWIDTH: Integer := 32;
fixed_prescALE_EN: integer := 1;
fiXED_PRESCALE: integER := 8;
fIXED_PERIOD_En: intEGER := 0;
fixED_PERIOD: INTEGEr := 8;
dac_MODE1: INTEGer := 0;
dac_mode2: integer := 0;
dac_mode3: inteGER := 0;
DAC_MODE4: INteger := 0;
DAC_MODE5: INTeger := 0;
Dac_mode6: integer := 0;
dac_mode7: integer := 0;
dac_mode8: integer := 0;
dac_mode9: inTEGER := 0;
DAC_mode10: Integer := 0;
dac_mode11: integer := 0;
DAC_MODE12: INTEger := 0;
DAC_MODE13: INTEGER := 0;
DAC_mode14: INTEger := 0;
DAC_mode15: INTEGEr := 0;
dac_mode16: integer := 0;
SHADOW_Reg_en1: INTEGer := 0;
SHADOW_REG_EN2: INTEGER := 0;
shadow_reg_en3: Integer := 0;
SHADOW_REG_EN4: INTEGER := 0;
SHAdow_reg_en5: INTEGEr := 0;
shadow_reg_en6: INteger := 0;
shadow_reg_en7: INTeger := 0;
Shadow_reg_en8: INTeger := 0;
shadow_reg_en9: INTEGER := 0;
shadow_reg_en10: INteger := 0;
shadow_REG_EN11: integer := 0;
Shadow_reg_en12: integer := 0;
SHADOW_REG_EN13: integer := 0;
SHADOw_reg_en14: INTEGER := 0;
shadow_REG_EN15: Integer := 0;
shadow_reg_en16: INTEGER := 0;
Fixed_pwm_pos_en1: INTEGER := 1;
FIXED_pwm_pos_en2: INTEGER := 1;
FIXED_PWM_POS_en3: integer := 1;
fixed_pwm_pos_EN4: INTEGEr := 1;
FIXEd_pwm_pos_en5: integer := 1;
fixed_pwm_pos_en6: INTEGER := 1;
fiXED_PWM_POS_En7: integer := 1;
FIXED_pwm_pos_en8: integer := 1;
fixed_pwm_pos_EN9: INTEGER := 1;
FIXED_PWM_pos_en10: integer := 1;
FIXed_pwm_pos_en11: integer := 1;
FIXed_pwm_pos_en12: integer := 1;
Fixed_pwm_pos_en13: integer := 1;
fixed_pwm_pos_en14: integeR := 1;
fixed_pwm_pos_EN15: integeR := 1;
Fixed_pwm_pos_en16: integer := 1;
FIXED_PWM_POSedge1: INTEGer := 0;
FIXED_PWM_POSedge2: INTEGER := 0;
fixed_pwm_posedgE3: integer := 0;
FIXED_PWM_Posedge4: INTEGER := 0;
fixed_pwm_POSEDGE5: integer := 0;
FIXED_PWM_posedge6: INTEGER := 0;
Fixed_pwm_posedge7: Integer := 0;
fixed_pwM_POSEDGE8: integer := 0;
FIXED_PWM_posedge9: INTEGER := 0;
FIxed_pwm_posedge10: INTEGER := 0;
fiXED_PWM_POSEDge11: intEGER := 0;
FIXED_PWM_Posedge12: iNTEGER := 0;
FIxed_pwm_posedge13: INTEGER := 0;
FIXED_PWM_posedge14: inteGER := 0;
fixED_PWM_POSEDGe15: integer := 0;
fixed_pwm_posedgE16: INTEGER := 0;
FIXED_PWm_neg_en1: integer := 0;
FIXed_pwm_neg_en2: integer := 0;
FIXEd_pwm_neg_en3: integer := 0;
FIXEd_pwm_neg_en4: integer := 0;
FIXED_PWm_neg_en5: integer := 0;
fixed_PWM_NEG_EN6: INTEGER := 0;
fixED_PWM_NEG_EN7: INTEGER := 0;
fIXED_PWM_NEG_en8: INTEGER := 0;
fixed_pwm_NEG_EN9: iNTEGER := 0;
fIXED_PWM_NEG_en10: INTEGer := 0;
FIXED_PWM_neg_en11: INTEGer := 0;
FIXED_pwm_neg_en12: INteger := 0;
FIXED_PWM_neg_en13: INTEGER := 0;
FIXED_pwm_neg_en14: INTEGER := 0;
fixed_pwm_neg_EN15: integer := 0;
FIXED_PWM_NEg_en16: INTEGER := 0;
FIXed_pwm_negedge1: INTEGER := 0;
fixed_pwm_negedge2: INTEGEr := 0;
fixed_pwm_negedge3: INTEGEr := 0;
fixed_pwm_negeDGE4: INTEger := 0;
fixed_pwm_negeDGE5: INTEger := 0;
fixed_pwm_NEGEDGE6: integer := 0;
fixed_pwm_neGEDGE7: INTEger := 0;
fixed_pwm_negedge8: INTEGER := 0;
fIXED_PWM_NEGEdge9: integer := 0;
fixed_pwm_negedge10: INTEGER := 0;
FIXED_PWM_negedge11: integer := 0;
fixed_pwm_NEGEDGE12: INTEGEr := 0;
FIXED_pwm_negedge13: integer := 0;
fixed_pwm_negedGE14: INTEGER := 0;
fiXED_PWM_NEGEDge15: INteger := 0;
FIXED_PWM_NEgedge16: INteger := 0;
Pwm_stretch_value1: integer := 0;
PWM_STRetch_value2: integer := 0;
PWM_STRETCH_value3: INTEGEr := 0;
pwm_stretCH_VALUE4: inteGER := 0;
pwm_streTCH_VALUE5: inteGER := 0;
pwm_stretch_valUE6: integer := 0;
PWm_stretch_value7: integer := 0;
pwM_STRETCH_VALue8: inTEGER := 0;
pwm_stretch_valUE9: integer := 0;
PWM_STRetch_value10: INTEGer := 0;
pwM_STRETCH_VALue11: INTEGER := 0;
PWM_stretch_value12: INTEGER := 0;
pwm_stRETCH_VALUE13: integeR := 0;
pwM_STRETCH_VALue14: integer := 0;
PWM_STRETch_value15: INTEGER := 0;
PWM_STretch_value16: iNTEGER := 0;
tach_NUM: INTEGER := 16;
tach_edgE1: integER := 0;
TACH_edge2: INteger := 0;
tach_eDGE3: inTEGER := 0;
tach_edge4: INTEger := 0;
tach_eDGE5: integer := 0;
TACH_Edge6: INTEGER := 0;
tach_edge7: INteger := 0;
tach_edGE8: integer := 0;
tach_edGE9: integer := 0;
TACH_EDGE10: INTEGER := 0;
TACH_EDGE11: INTEGER := 0;
TACH_edge12: INTEGER := 0;
tACH_EDGE13: integer := 0;
TACH_EDGE14: integeR := 0;
tacH_EDGE15: integer := 0;
tach_eDGE16: integer := 0;
tachint_act_leVEL: Integer := 0); port (PRESETN: in STD_Logic;
pclk: in STD_logic;
psel: in STD_LOGIC;
penable: in std_lOGIC;
PWRITE: in std_logic;
paddr: in std_LOGIC_VECTOR(7 downto 0);
PWDATA: in std_logic_vECTOR(apb_dwidTH-1 downto 0);
prdaTA: out STD_LOGIC_vector(APB_DWIDTH-1 downto 0);
pready: out std_logic;
PSLVERR: out STD_LOGic;
tACHIN: in STD_LOgic_vector(tacH_NUM-1 downto 0);
TAchint: out STD_Logic;
pwm: out std_logic_vector(PWM_NUM downto 1));
end COREPWM;

architecture CPWMO of COREPWM is

component REG_IF is
generic (pwm_num: intEGER := 8;
APB_DWIDTh: intEGER := 8;
FIxed_prescale_en: Integer := 0;
FIxed_prescale: INTEGER := 8;
FIXED_PERIOd_en: inteGER := 0;
FIXed_period: intEGER := 8;
DAC_MOde: std_logIC_VECTOR(15 downto 0) := "0000000000000000";
shadow_REG_EN: STd_logic_vector(15 downto 0) := "0000000000000000";
fixED_PWM_POS_EN: std_logic_VECTOR(15 downto 0) := "0000000000000000";
FIXED_pwm_posedge: std_logIC_VECTOR(511 downto 0) := ( others => '0');
fixed_pWM_NEG_EN: std_logic_vector(15 downto 0) := "0000000000000000";
fixed_pwm_NEGEDGE: STD_Logic_vector(511 downto 0) := ( others => '0'));
port (PClk: in std_logiC;
PRESETN: in STD_logic;
psel: in std_logic;
PENABLE: in STD_LOGIC;
pwrite: in std_logic;
paddr: in std_LOGIC_VECTOR(5 downto 0);
PWData: in std_logic_vecTOR(apb_dwidth-1 downto 0);
pwm_streTCH: in sTD_LOGIC_VECTor(PWM_num-1 downto 0);
PRData_regif: out STD_LOGic_vector(apb_dwiDTH-1 downto 0);
period_cnt: in STD_LOGIC_VECtor(APB_DWIdth-1 downto 0);
SYNC_pulse: in std_loGIC;
perioD_OUT_WIRE_O: out sTD_LOGIC_VECTOr(apb_dwidth-1 downto 0);
prescale_ouT_WIRE_O: out std_LOGIC_VECTOR(apb_dwiDTH-1 downto 0);
pwm_enable_OUT_WIRE_O: out std_logIC_VECTOR(pwm_num downto 1);
pwm_posedge_out_WIRE_O: out STD_LOGIC_vector(PWM_NUm*apb_dwidth downto 1);
Pwm_negedge_out_wIRE_O: out std_logic_vectOR(PWM_NUM*apb_DWIDTH downto 1));
end component;

component TIMEBASE is
generic (apb_dwIDTH: iNTEGER := 8);
port (presetn: in STD_LOgic;
pclK: in STD_logic;
PEriod_reg: in Std_logic_vector(APB_dwidth-1 downto 0);
prescale_reg: in STD_logic_vector(APB_DWidth-1 downto 0);
perioD_CNT: out STD_logic_vector(apb_DWIDTH-1 downto 0);
SYNC_pulse: out STD_LOGIC);
end component;

component PWM_GEN is
generic (PWM_NUM: INteger := 8;
APB_DWIDTH: integer := 8;
dac_mode: std_logic_vectOR(15 downto 0));
port (PRESETN: in STd_logic;
PCLk: in STD_LOGIC;
pwm: out std_logic_vectOR(pwm_num downto 1);
Period_cnt: in std_logiC_VECTOR(apb_dwidth-1 downto 0);
PWM_ENABLE_reg: in STD_logic_vector(PWM_NUM downto 1);
PWM_POsedge_reg: in STD_LOGIC_Vector(pwm_NUM*APB_DWIDTH downto 1);
pwm_negeDGE_REG: in Std_logic_vector(pwm_num*APb_dwidth downto 1);
SYNc_pulse: in std_lOGIC);
end component;

component tach_if is
generic (TACH_Num: INTEGER := 1);
port (pclk: in STD_LOGIC;
presetn: in stD_LOGIC;
tachin: in std_lOGIC;
Tachmode: in std_logic;
TACH_edge: in std_logIC;
TACHStatus: in std_logic;
STATus_clear: in std_logiC;
tach_cnt_clk: in std_LOGIC;
TACHPULSEDUr: out std_logic_vector(15 downto 0);
UPDATE_status: out std_logIC);
end component;

type CPWMl is array (tach_num-1 downto 0) of std_logiC_VECTOR(15 downto 0);

signal preSCALE_REG: STD_LOGIC_VECtor(APB_dwidth-1 downto 0);

signal perIOD_REG: std_logiC_VECTOR(apb_dwidth-1 downto 0);

signal PERIOD_CNT: stD_LOGIC_VECTOR(APB_dwidth-1 downto 0);

signal PWM_enable_reg: STD_LOgic_vector(pwm_num downto 1);

signal pwm_posedge_reg: STD_logic_vector(pwm_num*apb_dWIDTH downto 1);

signal PWM_negedge_reg: STD_Logic_vector(pwm_num*apb_DWIDTH downto 1);

signal sync_pulSE: sTD_LOGIC;

signal CPWMi: std_logiC_VECTOR(pwm_NUM downto 1);

signal CPWMol: std_logic_VECTOR(15 downto 0);

signal CPWMll: std_LOGIC_VECTOR(PWM_NUM-1 downto 0);

signal tach_edgE: std_LOGIC_VECTOR(tach_nuM-1 downto 0);

signal CPWMiL: STD_LOGIC;

signal CPWMoi: STD_logic_vector(3 downto 0);

signal pwm_stretcH: std_logic_VECTOR(PWM_NUM-1 downto 0);

signal CPWMlI: std_logic_vectOR(tach_num-1 downto 0);

signal TACHMODe: std_LOGIC_VECTOR(tach_num-1 downto 0);

signal taCHSTATUS: std_logic_vECTOR(TACH_num-1 downto 0);

signal CPWMii: STD_LOGIC_vector(10 downto 0);

signal CPWMO0: std_logic_vecTOR(10 downto 0);

signal CPWMl0: STD_LOGIC_VEctor(10 downto 0);

signal TACH_Cnt_clk: STD_LOGic;

signal taCHPULSEDUR: CPWMl;

signal UPDATE_STATUS: STd_logic_vector(tach_num-1 downto 0);

signal STATUS_CLEAR: Std_logic_vector(tach_num-1 downto 0);

signal prdata_reGIF: STD_LOGIC_vector(APB_DWIDTH-1 downto 0);

constant ALL_ones: Std_logic_vector(511 downto 0) := ( others => '1');

constant CPWMI0: STD_logic_vector(511 downto 0) := ( others => '0');

constant DAC_MODE: STD_LOGIC_VECTor(15 downto 0) := (std_logic_vector(TO_UNSIGned(Dac_mode16,
1))&std_logic_veCTOR(to_UNSIGNED(Dac_mode15,
1))&STD_LOGic_vector(to_unsIGNED(dac_MODE14,
1))&STD_LOgic_vector(TO_UNSIGNED(dac_mode13,
1))&std_LOGIC_VECTOR(to_unsigned(dac_moDE12,
1))&Std_logic_vector(to_unSIGNED(dac_MODE11,
1))&std_logic_VECTOR(TO_UNSIGned(dac_mode10,
1))&STD_LOGIC_vector(to_unsiGNED(DAC_MODE9,
1))&STD_LOGIC_VECtor(TO_UNsigned(dAC_MODE8,
1))&std_LOGIC_VECTOR(TO_UNSIGned(dac_mODE7,
1))&Std_logic_vector(to_unsigned(DAC_mode6,
1))&std_loGIC_VECTOR(to_UNSIGNED(dac_mode5,
1))&Std_logic_vector(TO_UNSIGNED(DAc_mode4,
1))&STD_LOGic_vector(to_unsigned(DAC_mode3,
1))&std_logic_vectOR(TO_UNSIgned(DAC_mode2,
1))&STd_logic_vector(TO_UNsigned(DAC_MODE1,
1)));

constant shADOW_REG_EN: STD_LOGIC_vector(15 downto 0) := (std_logIC_VECTOR(to_unsigned(Shadow_reg_en16,
1))&std_LOGIC_VECTOR(to_unsigned(SHADOW_reg_en15,
1))&std_logIC_VECTOR(TO_UNSIGNED(SHadow_reg_en14,
1))&std_logic_VECTOR(to_unsigned(shadow_reg_en13,
1))&std_logic_vectoR(TO_UNSIGned(shadow_reg_en12,
1))&std_logic_vECTOR(TO_UNSigned(SHADow_reg_en11,
1))&STD_Logic_vector(to_unsiGNED(shadow_reg_EN10,
1))&std_logic_vectOR(TO_UNSIGNED(shadow_reg_en9,
1))&STD_Logic_vector(TO_UNSIGNED(shadow_reg_en8,
1))&std_logIC_VECTOR(to_UNSIGNED(shadow_rEG_EN7,
1))&Std_logic_vector(TO_UNSIGNED(SHADOW_REG_EN6,
1))&STD_Logic_vector(to_unsigned(shaDOW_REG_EN5,
1))&STD_logic_vector(TO_UNSIGNED(shadow_reg_en4,
1))&sTD_LOGIC_VECTor(to_unsignED(shadow_reg_en3,
1))&std_logic_vectoR(To_unsigned(shadow_REG_EN2,
1))&std_logic_vector(to_unsIGNED(shadow_reg_en1,
1)));

constant FIxed_pwm_pos_en: Std_logic_vector(15 downto 0) := (Std_logic_vector(TO_UNSIGNed(FIXed_pwm_pos_en16,
1))&std_logic_vector(TO_UNSIGNED(fixED_PWM_POS_EN15,
1))&STD_LOGIC_VECtor(to_uNSIGNED(fixed_pwM_POS_EN14,
1))&std_logic_VECTOR(to_unSIGNED(fixed_pwM_POS_EN13,
1))&std_loGIC_VECTOR(to_unsigned(fixed_pwm_pOS_EN12,
1))&Std_logic_vector(to_unsigned(fIXED_PWM_POS_en11,
1))&std_logic_vECTOR(to_unsigned(fixed_pwm_pos_EN10,
1))&STD_LOGic_vector(TO_UNSIgned(fiXED_PWM_POS_En9,
1))&std_logic_vecTOR(to_unSIGNED(Fixed_pwm_pos_en8,
1))&STD_Logic_vector(TO_UNsigned(fixed_pwm_pos_EN7,
1))&Std_logic_vector(to_unsiGNED(FIXed_pwm_pos_en6,
1))&stD_LOGIC_VECTOr(TO_UNSIGNED(FIXED_PWm_pos_en5,
1))&std_logic_VECTOR(to_unsigNED(FIXED_Pwm_pos_en4,
1))&STD_LOGIC_vector(to_unsignED(FIxed_pwm_pos_en3,
1))&STD_LOGIC_vector(TO_unsigned(fixed_pwm_pos_eN2,
1))&STD_LOGIC_VECtor(to_UNSIGNED(fixed_pwm_pos_en1,
1)));

constant fixED_PWM_POSEDGe: STD_LOGic_vector(511 downto 0) := (CPWMi0((32-apb_DWIDTH)*16-1 downto 0)&STD_LOGIc_vector(to_unsigned(FIXED_PWM_posedge16,
apb_dwidth))&std_logic_VECTOR(TO_Unsigned(fixed_pwm_POSEDGE15,
apb_dWIDTH))&STD_LOGIC_vector(to_unsigned(fixED_PWM_POSEDGe14,
apb_dwidth))&std_logic_vector(TO_Unsigned(fixed_pwm_posedgE13,
apb_dwidth))&std_logic_vector(to_unsigNED(FIXED_PWM_Posedge12,
APB_DWIdth))&std_logic_vectoR(to_unSIGNED(FIXED_PWM_Posedge11,
APB_DWIDth))&stD_LOGIC_VECTOr(To_unsigned(FIXed_pwm_posedge10,
APB_DWIDth))&std_logic_vectOR(TO_unsigned(FIXED_PWM_posedge9,
apb_DWIDTH))&STD_LOGIC_Vector(TO_UNSIgned(FIXED_pwm_posedge8,
APB_DWIDth))&STD_LOGIC_vector(TO_UNSIGNED(fixed_pwm_poSEDGE7,
apb_dWIDTH))&std_logic_vectOR(to_unsigned(fixED_PWM_POSEDGe6,
apb_dwidTH))&std_logic_vector(TO_UNSIgned(FIxed_pwm_posedge5,
apb_dwidtH))&STd_logic_vector(to_unsigNED(fixed_pwm_poSEDGE4,
apB_DWIDTH))&std_logic_veCTOR(to_unsiGNED(FIXed_pwm_posedge3,
APB_DWIDTH))&STd_logic_vector(to_unsigned(fixed_pwm_posedgE2,
APB_dwidth))&std_logic_vectoR(tO_UNSIGNED(FIXed_pwm_posedge1,
APB_DWIDTH)));

constant fixed_pwm_neG_EN: std_logic_VECTOR(15 downto 0) := (STd_logic_vector(To_unsigned(fixed_pwm_neg_EN16,
1))&std_logic_VECTOR(TO_UNSIGNED(FIXed_pwm_neg_en15,
1))&std_logic_VECTOR(TO_UNSIGned(fixeD_PWM_NEG_EN14,
1))&STD_LOGIC_vector(to_unsigneD(FIXED_pwm_neg_en13,
1))&STD_LOgic_vector(TO_UNSIGNED(fixed_pwm_neg_EN12,
1))&STD_LOGIC_vector(to_uNSIGNED(FIXED_pwm_neg_en11,
1))&stD_LOGIC_VECTOr(to_unsigned(fixed_pwm_neg_en10,
1))&STD_LOGIC_vector(TO_UNsigned(FIXEd_pwm_neg_en9,
1))&STD_logic_vector(TO_unsigned(FIXEd_pwm_neg_en8,
1))&std_logic_VECTOR(TO_UNSIGNED(FIXED_PWM_NEG_en7,
1))&Std_logic_vector(TO_UNSIGNED(FIXED_PWM_neg_en6,
1))&std_logic_VECTOR(to_unsigned(fixed_pwm_neg_eN5,
1))&STD_Logic_vector(TO_UNSIGned(FIXED_PWM_NEG_en4,
1))&std_logic_veCTOR(To_unsigned(fixed_pwm_neg_en3,
1))&std_LOGIC_VECTOR(to_unsigned(fixed_pwm_neG_EN2,
1))&STD_LOGIC_VECtor(To_unsigned(FIXEd_pwm_neg_en1,
1)));

constant FIXED_PWM_negedge: std_lOGIC_VECTOR(511 downto 0) := (CPWMi0((32-apb_dWIDTH)*16-1 downto 0)&STD_logic_vector(to_unsigned(fixed_pwm_NEGEDGE16,
apb_dwIDTH))&STD_logic_vector(TO_unsigned(fixED_PWM_NEGEDGe15,
Apb_dwidth))&STD_LOgic_vector(TO_UNSIgned(fixed_pwm_negeDGE14,
APB_DWidth))&std_loGIC_VECTOR(to_unsiGNED(fixed_pwm_NEGEDGE13,
APB_DWIDTH))&STD_logic_vector(TO_Unsigned(fixed_pwm_negeDGE12,
apb_dwidth))&std_logic_vecTOR(to_unsigned(FIXED_PWM_NEGedge11,
apb_dwidth))&std_loGIC_VECTOR(to_unsigned(FIXEd_pwm_negedge10,
APB_Dwidth))&std_logiC_VECTOR(TO_UNSIGNED(fixed_pwm_negedGE9,
apb_dwidth))&STD_LOGIC_Vector(to_unsigned(FIxed_pwm_negedge8,
apb_dwidth))&STD_logic_vector(TO_Unsigned(fixed_pwm_negEDGE7,
apb_dwidth))&STD_LOgic_vector(to_unsigned(FIXED_PWm_negedge6,
APB_DWIdth))&STD_LOGic_vector(TO_UNSIGNED(FIXED_PWM_NEGedge5,
APB_DWidth))&std_logic_vector(to_UNSIGNED(fixed_pwm_negeDGE4,
apb_dwidth))&std_logIC_VECTOR(TO_Unsigned(fixED_PWM_NEGEDGE3,
APB_DWIDTH))&STD_LOGIC_vector(To_unsigned(FIXED_PWm_negedge2,
apb_dWIDTH))&std_logic_VECTOR(TO_UNSigned(fiXED_PWM_NEGEDGe1,
aPB_DWIDTH)));

function CPWMo1(x: INTEGER)
return std_logic is
variable Y: Std_logic;
begin
if x = 0 then
Y := '0';
else
Y := '1';
end if;
return y;
end CPWMO1;

begin
CPWML1:
if (config_mode > 0)
generate
process (Presetn,pclk)
begin
if ((not (presetn)) = '1') then
CPWMOi <= "0000";
elsif (PCLK'evenT and pclk = '1') then
if ((psel = '1') and (PWRITE = '1')
and (penable = '1')) then
case Paddr(7 downto 2) is
when "100101" =>
CPWMOI <= PWDATA(3 downto 0);
when others =>
CPWMoi <= CPWMoi;
end case;
end if;
end if;
end process;
process (PRESETN,pCLK)
begin
if ((not (PRESetn)) = '1') then
CPWMli <= ( others => '0');
TAChmode <= ( others => '0');
elsif (PCLK'Event and PCLK = '1') then
if ((PSEL = '1') and (pwrite = '1')
and (Penable = '1')) then
case paddr(7 downto 2) is
when "100111" =>
CPWMli <= pwdata(tacH_NUM-1 downto 0);
when "101000" =>
TACHMODE <= Pwdata(TACH_NUM-1 downto 0);
when others =>
CPWMli <= CPWMli;
tachmODE <= tachmode;
end case;
end if;
end if;
end process;
process (CPWMOI)
begin
case CPWMOI is
when "0000" =>
CPWMl0 <= "00000000000";
when "0001" =>
CPWMl0 <= "00000000001";
when "0010" =>
CPWML0 <= "00000000011";
when "0011" =>
CPWML0 <= "00000000111";
when "0100" =>
CPWMl0 <= "00000001111";
when "0101" =>
CPWMl0 <= "00000011111";
when "0110" =>
CPWMl0 <= "00000111111";
when "0111" =>
CPWML0 <= "00001111111";
when "1000" =>
CPWMl0 <= "00011111111";
when "1001" =>
CPWML0 <= "00111111111";
when "1010" =>
CPWML0 <= "01111111111";
when "1011" =>
CPWMl0 <= "11111111111";
when others =>
CPWML0 <= "11111111111";
end case;
end process;
process (presetn,pclk)
begin
if ((not (PResetn)) = '1') then
CPWMII <= "00000000000";
CPWMO0 <= "00000000000";
tach_cnt_clk <= '0';
elsif (Pclk'event and PCLK = '1') then
if (CPWMii >= CPWMo0) then
CPWMii <= "00000000000";
CPWMO0 <= CPWML0;
TACH_cnt_clk <= '1';
else
CPWMII <= CPWMii+"00000000001";
TACH_Cnt_clk <= '0';
end if;
end if;
end process;
end generate;
CPWMI1:
for x in 0 to (tach_nUM-1)
generate
process (PRESETn,PCLK)
begin
if ((not (presETN)) = '1') then
TACHSTATUS(x) <= '0';
STATUS_clear(x) <= '1';
elsif (pCLK'EVENT and PCLK = '1') then
if ((PSEL = '1') and (PWRITE = '1')
and (penable = '1')
and (paDDR(7 downto 2) = "100110")) then
if (PWDATA(X) = '1') then
tachstATUS(x) <= '0';
status_clear(x) <= '1';
end if;
else
if (update_STATUS(x) = '1') then
TACHSTATUS(X) <= '1';
STATUS_CLEar(x) <= '0';
end if;
end if;
end if;
end process;
end generate;
CPWMool:
if (config_mode > 0)
generate
Tachint <= (CPWMil) when (TACHINT_ACT_Level /= 0) else
not (CPWMIl);
end generate;
CPWMlol:
if ((pwm_num > 0) and (CONFIG_MODE > 0))
generate
CPWMLL(0) <= CPWMO1(PWM_STRETch_value1);
end generate;
CPWMiol:
if ((PWM_NUM > 1) and (config_MODE > 0))
generate
CPWMLL(1) <= CPWMO1(PWM_STRETCH_value2);
end generate;
CPWMoll:
if ((pWM_NUM > 2) and (cONFIG_MODE > 0))
generate
CPWMll(2) <= CPWMO1(pwm_stretch_vaLUE3);
end generate;
CPWMLLL:
if ((pwm_nuM > 3) and (config_mode > 0))
generate
CPWMLL(3) <= CPWMo1(pWM_STRETCH_Value4);
end generate;
CPWMiLL:
if ((pwm_num > 4) and (CONFIG_MODE > 0))
generate
CPWMLl(4) <= CPWMO1(Pwm_stretch_value5);
end generate;
CPWMoil:
if ((PWM_NUm > 5) and (config_MODE > 0))
generate
CPWMLL(5) <= CPWMo1(pwm_sTRETCH_VALUE6);
end generate;
CPWMlil:
if ((pwm_NUM > 6) and (CONFig_mode > 0))
generate
CPWMll(6) <= CPWMO1(PWM_STRETCH_VAlue7);
end generate;
CPWMiil:
if ((pwm_num > 7) and (coNFIG_MODE > 0))
generate
CPWMll(7) <= CPWMo1(PWM_STRETCH_Value8);
end generate;
CPWMo0L:
if ((PWM_NUM > 8) and (config_moDE > 0))
generate
CPWMll(8) <= CPWMo1(PWM_stretch_value9);
end generate;
CPWMl0l:
if ((PWM_NUM > 9) and (conFIG_MODE > 0))
generate
CPWMlL(9) <= CPWMO1(pwm_streTCH_VALUE10);
end generate;
CPWMi0l:
if ((pwm_num > 10) and (CONFIG_mode > 0))
generate
CPWMLL(10) <= CPWMo1(pwm_stretCH_VALUE11);
end generate;
CPWMO1L:
if ((pwM_NUM > 11) and (config_mode > 0))
generate
CPWMLL(11) <= CPWMO1(PWM_stretch_value12);
end generate;
CPWML1L:
if ((PWM_NUM > 12) and (config_mode > 0))
generate
CPWMLL(12) <= CPWMO1(pwm_STRETCH_VALUe13);
end generate;
CPWMi1l:
if ((pwm_nuM > 13) and (CONFIG_mode > 0))
generate
CPWMLL(13) <= CPWMO1(PWM_stretch_value14);
end generate;
CPWMooi:
if ((Pwm_num > 14) and (config_mODE > 0))
generate
CPWMLL(14) <= CPWMO1(pWM_STRETCH_VALue15);
end generate;
CPWMloi:
if ((pwm_num > 15) and (CONFIG_MODE > 0))
generate
CPWMLl(15) <= CPWMO1(PWM_Stretch_value16);
end generate;
CPWMIOI:
if ((TACH_NUM = 1) and (Config_mode > 0))
generate
TACH_EDGE(0) <= (CPWMo1(tach_edge1));
CPWMil <= (tachstaTUS(0) and CPWMlI(0));
end generate;
CPWMoli:
if ((tach_num = 2) and (CONFIG_mode > 0))
generate
tach_edgE <= (CPWMo1(tach_edge2)&CPWMO1(TACH_EDGE1));
CPWMil <= (((tachsTATUS(1) and CPWMLI(1)) or (tachstatus(0) and CPWMli(0))));
end generate;
CPWMLLI:
if ((Tach_num = 3) and (CONFIG_Mode > 0))
generate
TACH_edge <= (CPWMO1(TACH_edge3)&CPWMO1(TACH_EDGE2)&CPWMO1(TACH_EDGE1));
CPWMil <= (((tachstATUS(2) and CPWMLi(2))) or ((tachstatus(1) and CPWMLI(1)) or (TACHSTATus(0) and CPWMLI(0))));
end generate;
CPWMILI:
if ((tach_num = 4) and (config_mode > 0))
generate
tach_edge <= (CPWMo1(TACh_edge4)&CPWMO1(TACH_EDGE3)&CPWMo1(tach_eDGE2)&CPWMo1(TACH_edge1));
CPWMil <= (((TACHSTATus(3) and CPWMli(3))) or ((tachstatuS(2) and CPWMli(2)))
or ((Tachstatus(1) and CPWMLI(1)) or (tachstatuS(0) and CPWMli(0))));
end generate;
CPWMoii:
if ((Tach_num = 5) and (CONFIG_Mode > 0))
generate
Tach_edge <= (CPWMo1(tacH_EDGE5)&CPWMo1(tach_edge4)&CPWMo1(tach_eDGE3)&CPWMO1(TACH_EDGE2)&CPWMo1(tach_eDGE1));
CPWMil <= ((TACHSTATUS(4) and CPWMLI(4)) or (Tachstatus(3) and CPWMli(3))
or (TACHSTAtus(2) and CPWMli(2))
or ((TACHSTATUS(1) and CPWMLI(1)) or (tachstatUS(0) and CPWMli(0))));
end generate;
CPWMlii:
if ((tach_num = 6) and (confiG_MODE > 0))
generate
tach_edge <= (CPWMO1(TACH_EDGE6)&CPWMO1(TAch_edge5)&CPWMo1(taCH_EDGE4)&CPWMo1(TACH_EDGE3)&CPWMo1(tach_edGE2)&CPWMO1(tach_edge1));
CPWMil <= ((TACHSTATUS(5) and CPWMlI(5)) or (TACHSTATUS(4) and CPWMLI(4))
or (TACHSTATUS(3) and CPWMLI(3))
or (TACHstatus(2) and CPWMli(2))
or ((TACHSTATUS(1) and CPWMLI(1)) or (TACHStatus(0) and CPWMli(0))));
end generate;
CPWMIii:
if ((TACH_num = 7) and (CONFig_mode > 0))
generate
tach_edge <= (CPWMo1(tacH_EDGE7)&CPWMO1(TACH_EDGE6)&CPWMo1(TACh_edge5)&CPWMo1(tach_edge4)&CPWMo1(tach_edge3)&CPWMO1(tach_edge2)&CPWMo1(tacH_EDGE1));
CPWMIL <= ((tACHSTATUS(6) and CPWMli(6)) or (TACHSTATus(5) and CPWMLI(5))
or (tACHSTATUS(4) and CPWMli(4))
or (TACHStatus(3) and CPWMLI(3))
or (tachstatus(2) and CPWMLI(2))
or ((TACHSTATUs(1) and CPWMli(1)) or (tachstatus(0) and CPWMli(0))));
end generate;
CPWMO0i:
if ((TACH_NUM = 8) and (CONFIG_MOde > 0))
generate
tach_EDGE <= (CPWMo1(tach_edge8)&CPWMo1(tach_eDGE7)&CPWMO1(tach_edGE6)&CPWMO1(tach_eDGE5)&CPWMo1(Tach_edge4)&CPWMO1(tach_edge3)&CPWMO1(Tach_edge2)&CPWMO1(tach_edge1));
CPWMil <= ((tachstaTUS(7) and CPWMli(7)) or (tachstatus(6) and CPWMli(6))
or (TACHSTATus(5) and CPWMLI(5))
or (TACHSTATUS(4) and CPWMli(4))
or (TACHSTATUS(3) and CPWMli(3))
or (TAchstatus(2) and CPWMli(2))
or ((TACHSTATUS(1) and CPWMli(1)) or (TACHstatus(0) and CPWMLI(0))));
end generate;
CPWML0I:
if ((tACH_NUM = 9) and (CONFIG_Mode > 0))
generate
tach_edge <= (CPWMO1(tach_edge9)&CPWMo1(tach_edge8)&CPWMO1(tach_edge7)&CPWMO1(tach_edge6)&CPWMo1(tach_edge5)&CPWMo1(tach_edge4)&CPWMO1(tACH_EDGE3)&CPWMO1(TACH_Edge2)&CPWMo1(tach_edge1));
CPWMIL <= ((tachstatus(8) and CPWMli(8)) or (tachstatus(7) and CPWMLI(7))
or (TACHSTATUs(6) and CPWMli(6))
or (TACHSTATUS(5) and CPWMlI(5))
or (taCHSTATUS(4) and CPWMLI(4))
or (tachsTATUS(3) and CPWMli(3))
or (TACHSTatus(2) and CPWMli(2))
or ((TACHstatus(1) and CPWMLI(1)) or (TACHSTATus(0) and CPWMLI(0))));
end generate;
CPWMi0i:
if ((TACH_NUM = 10) and (config_MODE > 0))
generate
tach_EDGE <= (CPWMO1(tach_edgE10)&CPWMo1(TACH_edge9)&CPWMO1(tach_edGE8)&CPWMo1(TACH_EDGE7)&CPWMo1(tach_edge6)&CPWMo1(TACH_Edge5)&CPWMO1(tach_edGE4)&CPWMo1(TACH_edge3)&CPWMo1(TACH_EDge2)&CPWMO1(TACH_EDGE1));
CPWMil <= ((TAchstatus(9) and CPWMli(9)) or (TACHSTATUS(8) and CPWMLI(8))
or (TACHStatus(7) and CPWMLI(7))
or (tachstatus(6) and CPWMli(6))
or (TACHSTATUs(5) and CPWMLI(5))
or (tachstatus(4) and CPWMli(4))
or (TACHSTATUS(3) and CPWMli(3))
or (TACHSTATUs(2) and CPWMLI(2))
or ((TACHSTATUS(1) and CPWMLI(1)) or (tachstatUS(0) and CPWMli(0))));
end generate;
CPWMO1I:
if ((TAch_num = 11) and (COnfig_mode > 0))
generate
tach_edge <= (CPWMO1(tach_EDGE11)&CPWMO1(Tach_edge10)&CPWMO1(Tach_edge9)&CPWMO1(TACH_EDGE8)&CPWMo1(tach_edge7)&CPWMO1(tach_edge6)&CPWMO1(tach_edgE5)&CPWMo1(TACH_EDGe4)&CPWMo1(tach_edge3)&CPWMo1(TACH_EDGe2)&CPWMo1(TACH_EDGE1));
CPWMIL <= ((tachSTATUS(10) and CPWMLI(10)) or (tachstatus(9) and CPWMLI(9))
or (tachstATUS(8) and CPWMLI(8))
or (TACHSTATus(7) and CPWMli(7))
or (TAChstatus(6) and CPWMli(6))
or (TACHSTATUs(5) and CPWMli(5))
or (tACHSTATUS(4) and CPWMli(4))
or (tachsTATUS(3) and CPWMli(3))
or (tachstatus(2) and CPWMli(2))
or ((tachstatus(1) and CPWMli(1)) or (TACHSTATUS(0) and CPWMLI(0))));
end generate;
CPWMl1i:
if ((tach_nUM = 12) and (config_moDE > 0))
generate
tach_edgE <= (CPWMO1(TACH_EDGE12)&CPWMO1(TACH_Edge11)&CPWMo1(taCH_EDGE10)&CPWMo1(tach_edge9)&CPWMo1(TAch_edge8)&CPWMO1(TACH_EDGE7)&CPWMo1(tach_edgE6)&CPWMO1(TACH_EDGE5)&CPWMO1(tach_edge4)&CPWMo1(Tach_edge3)&CPWMO1(tach_edge2)&CPWMO1(TACH_edge1));
CPWMil <= ((tACHSTATUS(11) and CPWMLI(11)) or (TACHSTATus(10) and CPWMLI(10))
or (tachstatus(9) and CPWMli(9))
or (TACHSTATUS(8) and CPWMli(8))
or (TACHstatus(7) and CPWMli(7))
or (tachsTATUS(6) and CPWMli(6))
or (TACHSTatus(5) and CPWMli(5))
or (tACHSTATUS(4) and CPWMli(4))
or (tacHSTATUS(3) and CPWMLI(3))
or (tacHSTATUS(2) and CPWMli(2))
or ((tachstatus(1) and CPWMLI(1)) or (TAChstatus(0) and CPWMLI(0))));
end generate;
CPWMi1i:
if ((TAch_num = 13) and (confIG_MODE > 0))
generate
TACH_EDGE <= (CPWMO1(tach_EDGE13)&CPWMO1(taCH_EDGE12)&CPWMo1(tach_eDGE11)&CPWMO1(Tach_edge10)&CPWMo1(tacH_EDGE9)&CPWMo1(tach_eDGE8)&CPWMO1(tach_edge7)&CPWMo1(TACH_EDGE6)&CPWMO1(Tach_edge5)&CPWMO1(TACH_EDGE4)&CPWMo1(TACH_EDGE3)&CPWMO1(TAch_edge2)&CPWMO1(tach_edge1));
CPWMil <= ((TACHSTATUS(12) and CPWMLI(12)) or (tachstatus(11) and CPWMli(11))
or (TACHSTAtus(10) and CPWMLI(10))
or (tachsTATUS(9) and CPWMli(9))
or (TACHSTATUS(8) and CPWMli(8))
or (tachsTATUS(7) and CPWMLI(7))
or (TAChstatus(6) and CPWMli(6))
or (tacHSTATUS(5) and CPWMLI(5))
or (tachstatus(4) and CPWMli(4))
or (TAchstatus(3) and CPWMli(3))
or (Tachstatus(2) and CPWMli(2))
or ((TACHSTATUS(1) and CPWMLI(1)) or (Tachstatus(0) and CPWMLI(0))));
end generate;
CPWMOO0:
if ((TACH_NUM = 14) and (CONFIG_MODE > 0))
generate
TAch_edge <= (CPWMo1(TACH_edge14)&CPWMo1(TACH_Edge13)&CPWMO1(tach_edge12)&CPWMo1(tach_edgE11)&CPWMo1(tach_edgE10)&CPWMo1(TACH_EDGE9)&CPWMO1(tach_EDGE8)&CPWMo1(TACH_EDGE7)&CPWMo1(TACH_EDGE6)&CPWMO1(TACH_EDGE5)&CPWMO1(tach_edge4)&CPWMO1(Tach_edge3)&CPWMo1(tach_EDGE2)&CPWMo1(taCH_EDGE1));
CPWMIL <= ((TACHstatus(13) and CPWMli(13)) or (tachstatus(12) and CPWMli(12))
or (TACHstatus(11) and CPWMLI(11))
or (tachsTATUS(10) and CPWMli(10))
or (tachstATUS(9) and CPWMli(9))
or (tachsTATUS(8) and CPWMLI(8))
or (Tachstatus(7) and CPWMli(7))
or (TACHSTatus(6) and CPWMLI(6))
or (TACHStatus(5) and CPWMLI(5))
or (Tachstatus(4) and CPWMli(4))
or (tachstatus(3) and CPWMli(3))
or (tachSTATUS(2) and CPWMLI(2))
or ((TACHSTATUS(1) and CPWMLI(1)) or (TACHStatus(0) and CPWMli(0))));
end generate;
CPWMlo0:
if ((tach_nuM = 15) and (CONfig_mode > 0))
generate
tach_edge <= (CPWMO1(TACH_EDGe15)&CPWMo1(TACH_EDGE14)&CPWMo1(TACh_edge13)&CPWMo1(tacH_EDGE12)&CPWMO1(TACH_EDGE11)&CPWMo1(tach_edge10)&CPWMo1(TACH_EDge9)&CPWMo1(tach_edge8)&CPWMo1(tach_edge7)&CPWMO1(tach_edge6)&CPWMO1(tach_EDGE5)&CPWMo1(tach_edge4)&CPWMo1(TACH_EDge3)&CPWMo1(tach_edge2)&CPWMo1(tach_EDGE1));
CPWMil <= ((tachstATUS(14) and CPWMli(14)) or (tachstaTUS(13) and CPWMLI(13))
or (tachstatus(12) and CPWMli(12))
or (TACHSTAtus(11) and CPWMlI(11))
or (TACHSTATUS(10) and CPWMLI(10))
or (tachsTATUS(9) and CPWMLI(9))
or (tachstatus(8) and CPWMli(8))
or (tachstaTUS(7) and CPWMLI(7))
or (TACHSTatus(6) and CPWMLi(6))
or (tachstatus(5) and CPWMLi(5))
or (TACHSTAtus(4) and CPWMLI(4))
or (TACHSTATUS(3) and CPWMLI(3))
or (tachstatUS(2) and CPWMli(2))
or ((TACHStatus(1) and CPWMLI(1)) or (TACHSTAtus(0) and CPWMLI(0))));
end generate;
CPWMIO0:
if ((tach_num = 16) and (config_MODE > 0))
generate
tach_edge <= (CPWMo1(TACH_edge16)&CPWMo1(TACH_EDGE15)&CPWMo1(TACH_edge14)&CPWMo1(TAch_edge13)&CPWMo1(Tach_edge12)&CPWMO1(tach_edge11)&CPWMo1(tach_edge10)&CPWMo1(TACH_Edge9)&CPWMo1(tach_edge8)&CPWMO1(tach_edge7)&CPWMo1(tach_edge6)&CPWMo1(tach_edge5)&CPWMO1(tach_EDGE4)&CPWMo1(tach_edGE3)&CPWMO1(tach_edge2)&CPWMo1(TACH_edge1));
CPWMIL <= ((TACHSTATUS(15) and CPWMli(15)) or (Tachstatus(14) and CPWMLI(14))
or (tachstatus(13) and CPWMLI(13))
or (tachstatUS(12) and CPWMli(12))
or (tachstatus(11) and CPWMLI(11))
or (TAchstatus(10) and CPWMli(10))
or (TACHStatus(9) and CPWMli(9))
or (TACHSTatus(8) and CPWMli(8))
or (tacHSTATUS(7) and CPWMli(7))
or (TACHSTATUS(6) and CPWMLI(6))
or (TACHStatus(5) and CPWMli(5))
or (TACHSTATUS(4) and CPWMli(4))
or (tachstatuS(3) and CPWMli(3))
or (tachstatus(2) and CPWMLI(2))
or ((TACHSTATUs(1) and CPWMLI(1)) or (TACHSTATUS(0) and CPWMli(0))));
end generate;
CPWMol0:
if ((TACH_num = 1) and (config_moDE > 0))
generate
process (paddr,pwm_stretch,CPWMoi,Tachstatus,CPWMli,TACHMODE,TACHPULSEDur)
begin
case PADDR(7 downto 2) is
when "100101" =>
CPWMOL <= ("000000000000"&CPWMOI(3 downto 0));
when "100110" =>
CPWMOL <= ("000000000000000"&tACHSTATUS(tacH_NUM-1 downto 0));
when "100111" =>
CPWMol <= ("000000000000000"&CPWMli(tach_num-1 downto 0));
when "101000" =>
CPWMOL <= ("000000000000000"&tachmode(tach_nUM-1 downto 0));
when "101001" =>
CPWMol <= TACHpulsedur(0);
when others =>
CPWMol <= "0000000000000000";
end case;
end process;
end generate;
CPWMLL0:
if ((TACH_num = 2) and (config_modE > 0))
generate
process (paddr,PWM_stretch,CPWMoi,TACHSTatus,CPWMLI,tachMODE,tachpulsedur)
begin
case PADDR(7 downto 2) is
when "100101" =>
CPWMOL <= ("000000000000"&CPWMoi(3 downto 0));
when "100110" =>
CPWMol <= ("00000000000000"&taCHSTATUS(Tach_num-1 downto 0));
when "100111" =>
CPWMOL <= ("00000000000000"&CPWMli(tach_num-1 downto 0));
when "101000" =>
CPWMOl <= ("00000000000000"&TACHMODE(tach_num-1 downto 0));
when "101001" =>
CPWMOL <= tachpulsedur(0);
when "101010" =>
CPWMol <= TAChpulsedur(1);
when others =>
CPWMol <= "0000000000000000";
end case;
end process;
end generate;
CPWMil0:
if ((tach_nuM = 3) and (CONFIG_Mode > 0))
generate
process (paddr,PWM_Stretch,CPWMoi,TACHSTATUS,CPWMLI,tachmode,TACHPULSEdur)
begin
case PADDR(7 downto 2) is
when "100101" =>
CPWMol <= ("000000000000"&CPWMoi(3 downto 0));
when "100110" =>
CPWMOL <= ("0000000000000"&TACHstatus(TACh_num-1 downto 0));
when "100111" =>
CPWMol <= ("0000000000000"&CPWMLI(TACH_num-1 downto 0));
when "101000" =>
CPWMOL <= ("0000000000000"&tachmode(tacH_NUM-1 downto 0));
when "101001" =>
CPWMol <= TACHPULSEDur(0);
when "101010" =>
CPWMOL <= tachpulseduR(1);
when "101011" =>
CPWMol <= tachpulsedur(2);
when others =>
CPWMol <= "0000000000000000";
end case;
end process;
end generate;
CPWMoi0:
if ((tach_num = 4) and (config_MODE > 0))
generate
process (PADDR,pwm_stretCH,CPWMoi,TACHSTATus,CPWMli,TAchmode,tachpulseduR)
begin
case PADDR(7 downto 2) is
when "100101" =>
CPWMol <= ("000000000000"&CPWMOI(3 downto 0));
when "100110" =>
CPWMol <= ("000000000000"&tachstatuS(tach_NUM-1 downto 0));
when "100111" =>
CPWMOL <= ("000000000000"&CPWMli(tach_num-1 downto 0));
when "101000" =>
CPWMol <= ("000000000000"&tachmode(TACH_num-1 downto 0));
when "101001" =>
CPWMOL <= TACHPULSEDUr(0);
when "101010" =>
CPWMOL <= TACHPULSEDUR(1);
when "101011" =>
CPWMOL <= tachpulSEDUR(2);
when "101100" =>
CPWMOl <= TACHPULSedur(3);
when others =>
CPWMol <= "0000000000000000";
end case;
end process;
end generate;
CPWMli0:
if ((tach_num = 5) and (config_mode > 0))
generate
process (paddr,pwm_stretcH,CPWMoi,TACHstatus,CPWMLI,tachmode,TACHPULSedur)
begin
case PADDR(7 downto 2) is
when "100101" =>
CPWMol <= ("000000000000"&CPWMoi(3 downto 0));
when "100110" =>
CPWMOL <= ("00000000000"&tachstatuS(tach_num-1 downto 0));
when "100111" =>
CPWMOL <= ("00000000000"&CPWMli(taCH_NUM-1 downto 0));
when "101000" =>
CPWMol <= ("00000000000"&Tachmode(tACH_NUM-1 downto 0));
when "101001" =>
CPWMol <= tachpulsedur(0);
when "101010" =>
CPWMol <= TACHPULSEDUR(1);
when "101011" =>
CPWMol <= tACHPULSEDUR(2);
when "101100" =>
CPWMol <= tachpulSEDUR(3);
when "101101" =>
CPWMol <= tachpulsedUR(4);
when others =>
CPWMOL <= "0000000000000000";
end case;
end process;
end generate;
CPWMII0:
if ((TAch_num = 6) and (confIG_MODE > 0))
generate
process (PADDR,pwm_stretch,CPWMoi,tachSTATUS,CPWMli,tachMODE,TAchpulsedur)
begin
case paddr(7 downto 2) is
when "100101" =>
CPWMoL <= ("000000000000"&CPWMOI(3 downto 0));
when "100110" =>
CPWMol <= ("0000000000"&tachstatus(tach_nUM-1 downto 0));
when "100111" =>
CPWMol <= ("0000000000"&CPWMLI(TACH_Num-1 downto 0));
when "101000" =>
CPWMOL <= ("0000000000"&TACHMODE(tach_NUM-1 downto 0));
when "101001" =>
CPWMol <= tachpulsEDUR(0);
when "101010" =>
CPWMOL <= tachpulsedur(1);
when "101011" =>
CPWMol <= tacHPULSEDUR(2);
when "101100" =>
CPWMol <= TACHPULSEdur(3);
when "101101" =>
CPWMOL <= tachpulsedur(4);
when "101110" =>
CPWMol <= tachpulsedur(5);
when others =>
CPWMol <= "0000000000000000";
end case;
end process;
end generate;
CPWMo00:
if ((TACH_num = 7) and (config_mODE > 0))
generate
process (Paddr,PWM_STRETCH,CPWMOI,tachstatus,CPWMli,tachmode,TACHPULSEDur)
begin
case PADDR(7 downto 2) is
when "100101" =>
CPWMOL <= ("000000000000"&CPWMoi(3 downto 0));
when "100110" =>
CPWMol <= ("000000000"&TACHStatus(tach_num-1 downto 0));
when "100111" =>
CPWMol <= ("000000000"&CPWMLI(tacH_NUM-1 downto 0));
when "101000" =>
CPWMOL <= ("000000000"&tachmode(TACH_NUm-1 downto 0));
when "101001" =>
CPWMoL <= tachpulsedur(0);
when "101010" =>
CPWMol <= tachpulsedur(1);
when "101011" =>
CPWMol <= TACHPULSEDUR(2);
when "101100" =>
CPWMol <= TACHPULSEDUR(3);
when "101101" =>
CPWMOL <= TAChpulsedur(4);
when "101110" =>
CPWMol <= tachpulseDUR(5);
when "101111" =>
CPWMOL <= tachpulsedur(6);
when others =>
CPWMol <= "0000000000000000";
end case;
end process;
end generate;
CPWML00:
if ((TACH_Num = 8) and (Config_mode > 0))
generate
process (paddr,pwm_STRETCH,CPWMoI,TACHstatus,CPWMLI,TACHMOde,tachPULSEDUR)
begin
case paddr(7 downto 2) is
when "100101" =>
CPWMol <= ("000000000000"&CPWMoi(3 downto 0));
when "100110" =>
CPWMOL <= ("00000000"&tachstatus(TAch_num-1 downto 0));
when "100111" =>
CPWMOL <= ("00000000"&CPWMLI(TACH_num-1 downto 0));
when "101000" =>
CPWMOL <= ("00000000"&tachmode(tach_nUM-1 downto 0));
when "101001" =>
CPWMOL <= tachpulsedur(0);
when "101010" =>
CPWMOL <= tachpulsEDUR(1);
when "101011" =>
CPWMOL <= TACHpulsedur(2);
when "101100" =>
CPWMOL <= tachpulsedur(3);
when "101101" =>
CPWMol <= tachpulsedur(4);
when "101110" =>
CPWMol <= tachpuLSEDUR(5);
when "101111" =>
CPWMol <= tachpulsedUR(6);
when "110000" =>
CPWMol <= TACHPUlsedur(7);
when others =>
CPWMOL <= "0000000000000000";
end case;
end process;
end generate;
CPWMI00:
if ((TACH_NUm = 9) and (COnfig_mode > 0))
generate
process (PADDR,pwm_stretCH,CPWMoi,tachstaTUS,CPWMli,tachmode,tACHPULSEDUR)
begin
case paddr(7 downto 2) is
when "100101" =>
CPWMol <= ("000000000000"&CPWMoi(3 downto 0));
when "100110" =>
CPWMol <= ("0000000"&TACHStatus(TACH_Num-1 downto 0));
when "100111" =>
CPWMOL <= ("0000000"&CPWMli(TACH_NUM-1 downto 0));
when "101000" =>
CPWMOL <= ("0000000"&TACHMOde(tach_num-1 downto 0));
when "101001" =>
CPWMol <= TACHPULSedur(0);
when "101010" =>
CPWMol <= TACHPULSEDur(1);
when "101011" =>
CPWMol <= tachpuLSEDUR(2);
when "101100" =>
CPWMOL <= tachpulseDUR(3);
when "101101" =>
CPWMol <= TAChpulsedur(4);
when "101110" =>
CPWMOL <= Tachpulsedur(5);
when "101111" =>
CPWMOL <= TACHPULsedur(6);
when "110000" =>
CPWMol <= TAchpulsedur(7);
when "110001" =>
CPWMol <= Tachpulsedur(8);
when others =>
CPWMOL <= "0000000000000000";
end case;
end process;
end generate;
CPWMO10:
if ((taCH_NUM = 10) and (Config_mode > 0))
generate
process (PADDR,pwm_stretch,CPWMoi,tachstATUS,CPWMli,tachmode,tACHPULSEDUR)
begin
case paddR(7 downto 2) is
when "100101" =>
CPWMol <= ("000000000000"&CPWMoi(3 downto 0));
when "100110" =>
CPWMol <= ("000000"&tachstatus(TACH_NUm-1 downto 0));
when "100111" =>
CPWMOL <= ("000000"&CPWMli(TACH_NUM-1 downto 0));
when "101000" =>
CPWMOL <= ("000000"&TACHmode(tach_num-1 downto 0));
when "101001" =>
CPWMOL <= TACHPulsedur(0);
when "101010" =>
CPWMOL <= TACHPulsedur(1);
when "101011" =>
CPWMOL <= tachpulsedUR(2);
when "101100" =>
CPWMOL <= TACHPUlsedur(3);
when "101101" =>
CPWMol <= TAchpulsedur(4);
when "101110" =>
CPWMol <= Tachpulsedur(5);
when "101111" =>
CPWMol <= tachpuLSEDUR(6);
when "110000" =>
CPWMoL <= tachpulsedur(7);
when "110001" =>
CPWMol <= tachpulsedur(8);
when "110010" =>
CPWMol <= Tachpulsedur(9);
when others =>
CPWMOL <= "0000000000000000";
end case;
end process;
end generate;
CPWML10:
if ((tach_num = 11) and (config_modE > 0))
generate
process (PADdr,pwm_stretcH,CPWMoi,tachstatUS,CPWMLi,TAchmode,tachpulSEDUR)
begin
case PADDR(7 downto 2) is
when "100101" =>
CPWMol <= ("000000000000"&CPWMoi(3 downto 0));
when "100110" =>
CPWMol <= ("00000"&tachstatus(TACH_NUm-1 downto 0));
when "100111" =>
CPWMOL <= ("00000"&CPWMLI(Tach_num-1 downto 0));
when "101000" =>
CPWMOL <= ("00000"&TACHMODe(tach_num-1 downto 0));
when "101001" =>
CPWMol <= TACHPULSEDUR(0);
when "101010" =>
CPWMol <= TACHPULSEDur(1);
when "101011" =>
CPWMol <= TACHPULSEDUR(2);
when "101100" =>
CPWMol <= tachpulSEDUR(3);
when "101101" =>
CPWMOL <= TACHPULSEDUr(4);
when "101110" =>
CPWMol <= TACHPULSEDUr(5);
when "101111" =>
CPWMOL <= tACHPULSEDUR(6);
when "110000" =>
CPWMol <= TACHPUlsedur(7);
when "110001" =>
CPWMOl <= taCHPULSEDUR(8);
when "110010" =>
CPWMOL <= tachpulSEDUR(9);
when "110011" =>
CPWMoL <= Tachpulsedur(10);
when others =>
CPWMOL <= "0000000000000000";
end case;
end process;
end generate;
CPWMI10:
if ((tach_num = 12) and (config_mode > 0))
generate
process (paddr,pWM_STRETCH,CPWMoi,tachSTATUS,CPWMli,Tachmode,tachpulseDUR)
begin
case PADdr(7 downto 2) is
when "100101" =>
CPWMol <= ("000000000000"&CPWMoi(3 downto 0));
when "100110" =>
CPWMOl <= ("0000"&TACHSTatus(tach_num-1 downto 0));
when "100111" =>
CPWMol <= ("0000"&CPWMli(tach_num-1 downto 0));
when "101000" =>
CPWMOL <= ("0000"&TACHMODE(tach_num-1 downto 0));
when "101001" =>
CPWMol <= TACHPULsedur(0);
when "101010" =>
CPWMOL <= tachpulsedur(1);
when "101011" =>
CPWMOL <= TACHPULSEDur(2);
when "101100" =>
CPWMol <= taCHPULSEDUR(3);
when "101101" =>
CPWMol <= Tachpulsedur(4);
when "101110" =>
CPWMol <= tachpulSEDUR(5);
when "101111" =>
CPWMOL <= TACHPULSEDUR(6);
when "110000" =>
CPWMOL <= tACHPULSEDUR(7);
when "110001" =>
CPWMOL <= tachpulseDUR(8);
when "110010" =>
CPWMol <= TACHPULSEDUR(9);
when "110011" =>
CPWMol <= TACHPULSEDUr(10);
when "110100" =>
CPWMol <= TACHPULSEDUR(11);
when others =>
CPWMol <= "0000000000000000";
end case;
end process;
end generate;
CPWMOO1:
if ((taCH_NUM = 13) and (CONFIG_mode > 0))
generate
process (paddR,PWM_STRETch,CPWMOI,TACHSTATUS,CPWMli,tachmode,tachpulsEDUR)
begin
case PADDR(7 downto 2) is
when "100101" =>
CPWMol <= ("000000000000"&CPWMoi(3 downto 0));
when "100110" =>
CPWMOL <= ("000"&tachstatUS(TAch_num-1 downto 0));
when "100111" =>
CPWMOL <= ("000"&CPWMlI(TACH_NUM-1 downto 0));
when "101000" =>
CPWMOL <= ("000"&TACHMODE(TACH_num-1 downto 0));
when "101001" =>
CPWMol <= tachpulSEDUR(0);
when "101010" =>
CPWMol <= tachPULSEDUR(1);
when "101011" =>
CPWMol <= tachpuLSEDUR(2);
when "101100" =>
CPWMOL <= TAChpulsedur(3);
when "101101" =>
CPWMol <= TACHPUlsedur(4);
when "101110" =>
CPWMol <= Tachpulsedur(5);
when "101111" =>
CPWMol <= tachpulsedur(6);
when "110000" =>
CPWMol <= Tachpulsedur(7);
when "110001" =>
CPWMol <= Tachpulsedur(8);
when "110010" =>
CPWMol <= TACHPULSedur(9);
when "110011" =>
CPWMOL <= tachpulsedur(10);
when "110100" =>
CPWMol <= TACHPULSEDUR(11);
when "110101" =>
CPWMoL <= TACHPULSedur(12);
when others =>
CPWMOL <= "0000000000000000";
end case;
end process;
end generate;
CPWMLO1:
if ((tach_num = 14) and (config_mode > 0))
generate
process (PADDR,pwm_stretch,CPWMOI,TAChstatus,CPWMli,tachmode,tachpulsEDUR)
begin
case PADDr(7 downto 2) is
when "100101" =>
CPWMOL <= ("000000000000"&CPWMoi(3 downto 0));
when "100110" =>
CPWMol <= ("00"&TACHSTATus(tach_nuM-1 downto 0));
when "100111" =>
CPWMol <= ("00"&CPWMli(tach_NUM-1 downto 0));
when "101000" =>
CPWMol <= ("00"&TAChmode(tach_num-1 downto 0));
when "101001" =>
CPWMol <= TACHpulsedur(0);
when "101010" =>
CPWMol <= TACHPUlsedur(1);
when "101011" =>
CPWMOL <= tACHPULSEDUR(2);
when "101100" =>
CPWMol <= tachpulsedur(3);
when "101101" =>
CPWMol <= TAChpulsedur(4);
when "101110" =>
CPWMOL <= Tachpulsedur(5);
when "101111" =>
CPWMOL <= TACHPulsedur(6);
when "110000" =>
CPWMOL <= TACHPULSEDUr(7);
when "110001" =>
CPWMol <= tachpulseduR(8);
when "110010" =>
CPWMol <= tachpulSEDUR(9);
when "110011" =>
CPWMOL <= tachPULSEDUR(10);
when "110100" =>
CPWMol <= TAChpulsedur(11);
when "110101" =>
CPWMol <= TAChpulsedur(12);
when "110110" =>
CPWMol <= TACHPULSedur(13);
when others =>
CPWMol <= "0000000000000000";
end case;
end process;
end generate;
CPWMiO1:
if ((TACH_NUM = 15) and (confiG_MODE > 0))
generate
process (paddr,PWM_STRETCh,CPWMOI,tachstatus,CPWMLI,TACHMODE,TAChpulsedur)
begin
case PADDR(7 downto 2) is
when "100101" =>
CPWMol <= ("000000000000"&CPWMoi(3 downto 0));
when "100110" =>
CPWMol <= ("0"&tachstaTUS(tach_num-1 downto 0));
when "100111" =>
CPWMol <= ("0"&CPWMLI(tach_NUM-1 downto 0));
when "101000" =>
CPWMol <= ("0"&TAchmode(TACH_NUM-1 downto 0));
when "101001" =>
CPWMol <= tachpulsedur(0);
when "101010" =>
CPWMol <= Tachpulsedur(1);
when "101011" =>
CPWMol <= tacHPULSEDUR(2);
when "101100" =>
CPWMOL <= TAChpulsedur(3);
when "101101" =>
CPWMOL <= tachpulsedur(4);
when "101110" =>
CPWMOL <= tachpulsedur(5);
when "101111" =>
CPWMol <= tachPULSEDUR(6);
when "110000" =>
CPWMOl <= TACHPULSedur(7);
when "110001" =>
CPWMol <= tachpuLSEDUR(8);
when "110010" =>
CPWMOL <= TAchpulsedur(9);
when "110011" =>
CPWMol <= TACHPULSEDUR(10);
when "110100" =>
CPWMol <= tachpulseDUR(11);
when "110101" =>
CPWMol <= TACHPULSEDUR(12);
when "110110" =>
CPWMol <= TACHPULSEDUR(13);
when "110111" =>
CPWMol <= tachpulSEDUR(14);
when others =>
CPWMOL <= "0000000000000000";
end case;
end process;
end generate;
CPWMol1:
if ((Tach_num = 16) and (config_mode > 0))
generate
process (Paddr,pwm_stretch,CPWMOI,TACHSTAtus,CPWMli,tachmode,tachpulsEDUR)
begin
case paddr(7 downto 2) is
when "100101" =>
CPWMol <= ("000000000000"&CPWMoi(3 downto 0));
when "100110" =>
CPWMOL <= (tachstatus(tach_num-1 downto 0));
when "100111" =>
CPWMol <= (CPWMli(tach_num-1 downto 0));
when "101000" =>
CPWMol <= (tACHMODE(tach_num-1 downto 0));
when "101001" =>
CPWMol <= tachpulseduR(0);
when "101010" =>
CPWMol <= TACHPULSEdur(1);
when "101011" =>
CPWMol <= tachpulsedur(2);
when "101100" =>
CPWMOL <= tachpulseDUR(3);
when "101101" =>
CPWMol <= tachPULSEDUR(4);
when "101110" =>
CPWMol <= tachpulsedur(5);
when "101111" =>
CPWMOL <= TACHPULSEDUR(6);
when "110000" =>
CPWMOL <= tACHPULSEDUR(7);
when "110001" =>
CPWMol <= TAChpulsedur(8);
when "110010" =>
CPWMol <= TACHPULsedur(9);
when "110011" =>
CPWMol <= tachPULSEDUR(10);
when "110100" =>
CPWMOL <= tachpulsedur(11);
when "110101" =>
CPWMOL <= tachpulseDUR(12);
when "110110" =>
CPWMol <= TACHpulsedur(13);
when "110111" =>
CPWMOL <= taCHPULSEDUR(14);
when "111000" =>
CPWMol <= tachpulsedur(15);
when others =>
CPWMOL <= "0000000000000000";
end case;
end process;
end generate;
CPWMll1:
if (APb_dwidth = 32)
generate
PRDATA <= PRDATa_regif when ((PADDR(7 downto 2) <= "100100") or (paddr(7 downto 2) = "111001")) else
("0000000000000000"&CPWMol(15 downto 0));
end generate;
CPWMIL1:
if (Apb_dwidth = 16)
generate
PRdata <= prdata_regiF when ((paddR(7 downto 2) <= "100100") or (paddr(7 downto 2) = "111001")) else
CPWMol(15 downto 0);
end generate;
CPWMoi1:
if (APB_DWidth = 8)
generate
prdata <= prdata_regif;
end generate;
process (PRESETN,pCLK)
begin
if ((not (PRESETN)) = '1') then
pwm_strETCH <= ( others => '0');
elsif (PCLK'event and PCLK = '1') then
if ((PSEL = '1') and (pwrite = '1')
and (PENABLE = '1')) then
case paddr(7 downto 2) is
when "100100" =>
pwm_stretch <= pwdaTA(PWM_num-1 downto 0);
when others =>
PWM_STRetch <= PWM_Stretch;
end case;
end if;
end if;
end process;
CPWMli1:
for L in 1 to (PWM_NUM)
generate
CPWMii1:
if (CONFIG_MODe = 0)
generate
PWM(l) <= CPWMI(l);
end generate;
CPWMo01:
if (not (cONFIG_MODE = 0))
generate
CPWMl01:
if (CONFIG_mode = 1)
generate
PWM(L) <= CPWMLL(L-1) when ((PWM_STRETCH(L-1)) = '1') else
CPWMI(L);
end generate;
end generate;
end generate;
CPWMi01:
if (CONFIG_mode < 2)
generate
CPWMo11: reg_if
generic map (PWM_Num,
APB_DWIDTH,
FIXED_prescale_en,
fixed_prESCALE,
fixed_period_en,
fixed_period,
dac_mode,
SHADOW_reg_en,
fixed_pwm_pos_EN,
FIXED_PWM_posedge,
fixed_pwm_neg_en,
FIxed_pwm_negedge)
port map (PCLK => PCLK,
presetn => presetn,
PSEL => psel,
PENABLE => penablE,
PWRITe => pWRITE,
PADdr => paddr(7 downto 2),
PWDATA => PWDATA,
pwm_stretch => pwm_stretch,
prdata_rEGIF => pRDATA_REGIF,
pwm_posedgE_OUT_WIRE_O => PWM_POSEdge_reg,
pWM_NEGEDGE_OUt_wire_o => pWM_NEGEDGE_REg,
prescale_out_wiRE_O => Prescale_reg,
period_OUT_WIRE_O => PERIOD_reg,
pERIOD_CNT => PERIOD_Cnt,
PWM_enable_out_wire_O => Pwm_enable_reg,
SYNC_pulse => SYNC_PULse);
end generate;
CPWMl11:
if ((SHADOW_REG_EN(PWm_num-1 downto 0) = CPWMi0(pWM_NUM-1 downto 0)) and (DAC_MODE(PWM_NUM-1 downto 0) = aLL_ONES(Pwm_num-1 downto 0)))
generate
PEriod_cnt <= ( others => '0');
SYNC_PULSE <= '0';
end generate;
CPWMI11:
if ((not ((SHADOw_reg_en(PWM_NUM-1 downto 0) = CPWMi0(Pwm_num-1 downto 0)) and (DAC_MODE(pwm_num-1 downto 0) = all_ONES(pwm_NUM-1 downto 0))
and (CONFIG_MOde < 2))))
generate
CPWMOOOL: TIMEBASE
generic map (apb_dwidth)
port map (pCLK => PCLK,
preSETN => PRESETN,
prescale_reg => PRescale_reg,
PERIOD_REg => period_reg,
PERIOD_cnt => PERIOD_Cnt,
sync_pULSE => Sync_pulse);
end generate;
CPWMLOOL:
if ((Config_mode > 0) and (APB_Dwidth > 15))
generate
CPWMiool:
for T in 0 to (tach_nUM-1)
generate
CPWMOLOL: tach_if
generic map (tach_NUM => TACh_num)
port map (PCLK => PCLK,
PRESETN => preseTN,
tacHSTATUS => tachstatus(T),
TACH_edge => TACH_EDGe(t),
TACHIN => taCHIN(T),
tachMODE => TACHMODE(T),
STATUs_clear => status_clear(T),
TACH_cnt_clk => tach_cnt_CLK,
TAChpulsedur => TACHPUlsedur(t),
update_statUS => update_status(T));
end generate;
end generate;
pready <= '1';
PSLVERR <= '0';
CPWMLLOL:
if (config_mode < 2)
generate
CPWMilol: PWM_gen
generic map (PWM_NUM,
APB_Dwidth,
DAC_MODE)
port map (pCLK => PCLK,
PRESETN => PRESETN,
PWm => CPWMi,
PERIOD_CNT => perIOD_CNT,
pwm_enaBLE_REG => pwm_enabLE_REG,
pwm_POSEDGE_REG => PWM_POSEDge_reg,
PWM_NEgedge_reg => PWM_negedge_reg,
SYNC_PULSe => sync_pulse);
end generate;
end CPWMo;
