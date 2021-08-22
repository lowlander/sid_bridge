--      Version:  4.0
--         Date:  Jul 19th, 2009
--  Description:  Register Interface
-- SVN Revision Information:
-- SVN $Revision: 11673 $
-- SVN $Date: 2009-12-18 14:05:16 -0800 (Fri, 18 Dec 2009) $
-- COPYRIGHT 2009 BY ACTEL
-- THE INFORMATION CONTAINED IN THIS DOCUMENT IS SUBJECT TO LICENSING RESTRICTIONS
-- FROM ACTEL CORP.  IF YOU ARE NOT IN POSSESSION OF WRITTEN AUTHORIZATION FROM
-- ACTEL FOR USE OF THIS FILE, THEN THE FILE SHOULD BE IMMEDIATELY DESTROYED AND
-- NO BACK-UP OF THE FILE SHOULD BE MADE.
library IEEE;
use IEEE.STD_logic_1164.all;
use ieee.STD_logic_unsigned.all;
use ieee.Numeric_std.all;
entity reg_IF is
generic (PWM_Num: integer := 8;
APB_DWidth: INTEGer := 8;
fixed_PRESCALE_EN: INteger := 0;
fixeD_PRESCALE: INTEGER := 8;
fixed_PERIOD_EN: INTEGER := 0;
fixed_periOD: integer := 8;
DAC_MODe: STD_LOGIC_VECtor(15 downto 0) := "0000000000000000";
shadow_reg_en: STD_LOGic_vector(15 downto 0) := "0000000000000000";
fixed_pwm_pos_EN: Std_logic_vector(15 downto 0) := "0000000000000000";
fixED_PWM_POSEDGe: std_logIC_VECTOR(511 downto 0) := ( others => '0');
FIXED_pwm_neg_en: stD_LOGIC_VECTOr(15 downto 0) := "0000000000000000";
FIxed_pwm_negedge: STD_LOGIC_VEctor(511 downto 0) := ( others => '0')); port (pcLK: in STD_LOGIC;
presetn: in std_logic;
PSEL: in STd_logic;
PENABLe: in std_loGIC;
PWRITE: in std_logic;
paDDR: in STD_LOGIC_vector(5 downto 0);
PWDATA: in std_logic_vECTOR(APB_dwidth-1 downto 0);
Pwm_stretch: in std_logic_veCTOR(pWM_NUM-1 downto 0);
pRDATA_REGIF: out STD_LOGIC_vector(APB_DWidth-1 downto 0);
PERIOD_CNT: in STD_logic_vector(APB_DWIDTH-1 downto 0);
SYNC_pulse: in STD_Logic;
PERIOD_out_wire_o: out std_logic_vector(APB_DWIDTH-1 downto 0);
pRESCALE_OUT_WIre_o: out STD_LOGIC_VEctor(Apb_dwidth-1 downto 0);
PWM_ENABLE_Out_wire_o: out STD_LOGIC_Vector(pWM_NUM downto 1);
pwm_POSEDGE_OUT_Wire_o: out Std_logic_vector(PWm_num*apb_dwidth downto 1);
PWm_negedge_out_wiRE_O: out sTD_LOGIC_VECTOr(PWm_num*APB_DWIdth downto 1));
end reg_if;

architecture CPWMo of reg_if is

constant ALl_ones: STD_logic_vector(256 downto 0) := ( others => '1');

constant CPWMI0: std_logic_vector(256 downto 0) := ( others => '0');

constant CPWMl0ol: std_logic_VECTOR(apb_dwidth-1 downto pWM_NUM) := ( others => '0');

signal CPWMi0ol: STD_LOGIC_vector(apb_dwidth-1 downto 0);

signal CPWMo1ol: std_logic_vectOR(aPB_DWIDTH-1 downto 0);

signal CPWMl1ol: std_logic_VECTOR(PWM_NUM*APB_DWIDTH downto 1);

signal CPWMI1OL: STD_logic_vector(pwm_num*APB_Dwidth downto 1);

signal CPWMooll: std_LOGIC_VECTOR(Apb_dwidth-1 downto 0);

signal CPWMLOll: STD_LOGIC_vector(apb_dwidth-1 downto 0);

signal period_reg: STD_logic_vector(Apb_dwidth-1 downto 0);

signal prescale_reg: STD_Logic_vector(APb_dwidth-1 downto 0);

signal CPWMIOll: STD_LOGIc_vector(8 downto 1);

signal CPWMolll: STD_LOGIC_VECTor(16 downto 9);

signal pwm_enable_reg: STD_LOGIC_vector(16 downto 1);

signal CPWMllLL: STD_logic_vector(PWM_NUM*APB_DWIDTH downto 1);

signal CPWMilll: sTD_LOGIC_VECTor(pwm_num*apb_dwidth downto 1);

signal pwm_posedgE_REG: std_logic_vector(pwm_num*apb_dwidth downto 1);

signal pwm_negedge_rEG: STD_LOGIC_Vector(pwm_num*Apb_dwidth downto 1);

signal period_out_wiRE: std_LOGIC_VECTOR(apb_dwidth-1 downto 0);

signal prescale_OUT_WIRE: STD_LOGIC_Vector(APB_DWIDTH-1 downto 0);

signal CPWMoill: std_logic_VECTOR(16 downto 1);

signal PWM_ENABLE_out_wire: std_logic_vECTOR(16 downto 1);

signal PWM_POSEdge_out_wire: std_logic_vECTOR(pwm_nuM*APB_Dwidth downto 1);

signal pwm_nEGEDGE_OUT_Wire: STD_logic_vector(PWM_num*apb_dwidtH downto 1);

signal CPWMlill: STD_logic_vector(apb_dwidth-1 downto 0);

signal CPWMiill: STD_LOGIc_vector(APB_DWIDTH-1 downto 0);

signal CPWMo0ll: stD_LOGIC;

begin
period_OUT_WIRE_O <= period_OUT_WIRE;
PREscale_out_wire_o <= prESCALE_OUT_WIre;
CPWMoill(16 downto 1) <= (CPWMOlll&CPWMIOLL);
pwm_enABLE_OUT_WIRE_o(PWm_num downto 1) <= PWM_ENABLE_OUt_wire(pwm_num downto 1);
PWM_POSEDge_out_wire_o <= PWm_posedge_out_wiRE;
pwm_negeDGE_OUT_WIRE_o <= pwm_negedGE_OUT_WIRE;
process (presetn,pclk)
begin
if ((not (presetN)) = '1') then
CPWMooll(3 downto 0) <= "1000";
CPWMooll((APB_DWIDTH-1) downto 4) <= ( others => '0');
CPWMloll(3 downto 0) <= "1000";
CPWMloll((APB_dwidth-1) downto 4) <= ( others => '0');
CPWMiolL <= ( others => '0');
CPWMolll <= ( others => '0');
elsif (pclk'EVent and pcLK = '1') then
if ((pseL = '1') and (PWRITE = '1')
and (PENABle = '1')) then
case (paddr) is
when "000000" =>
CPWMOOLL <= PWDATA;
when "000001" =>
CPWMLOLL <= PWDATA;
when "000010" =>
CPWMiolL <= PWDATA(7 downto 0);
when "000011" =>
CPWMolll <= pWDATA(7 downto 0);
when others =>
null
;
end case;
end if;
end if;
end process;
process (PRESETN,pclk)
begin
if ((not (presetn)) = '1') then
CPWMO0ll <= '0';
elsif (pclk'event and pclk = '1') then
if ((PSEL = '1') and (pWRITE = '1')
and (peNABLE = '1')) then
case paddr is
when "111001" =>
CPWMo0ll <= pwdaTA(0);
when others =>
CPWMo0ll <= CPWMO0LL;
end case;
end if;
end if;
end process;
CPWMl0ll:
for h in 1 to (pwm_NUM)
generate
process (presetN,PCLK)
begin
if ((not (presetn)) = '1') then
CPWMllll(h*APB_DWIDTH downto (H-1)*APB_DWIDTH+1) <= ( others => '0');
CPWMILLl(h*APB_DWIDTH downto (H-1)*apb_dwidth+1) <= ( others => '0');
elsif (pclk'EVENT and pclk = '1') then
if ((PSEL = '1') and (pwrite = '1')
and (penable = '1')) then
if (PADdr = STD_LOGIC_vector(to_unsigneD(2+H*2,
6))) then
CPWMllll(h*Apb_dwidth downto (H-1)*APB_DWIDTh+1) <= PWDAta(apb_DWIDTH-1 downto 0);
elsif (PADDR = std_logic_vectoR(to_unsigned(3+h*2,
6))) then
CPWMILll(h*APb_dwidth downto (h-1)*apb_DWIDTH+1) <= pwdata(APB_DWIDTH-1 downto 0);
end if;
end if;
end if;
end process;
end generate;
CPWMi0ll:
for CPWMo1ll in 1 to (PWM_NUM)
generate
process (presetn,pclk)
begin
if ((not (Presetn)) = '1') then
pwm_poseDGE_REG(CPWMo1ll*APB_DWidth downto (CPWMo1ll-1)*APB_DWIDth+1) <= ( others => '0');
PWM_NEGEdge_reg(CPWMo1ll*APB_DWIDTH downto (CPWMO1ll-1)*APB_DWIDTH+1) <= ( others => '0');
elsif (Pclk'event and pclk = '1') then
if ((PERIOD_CNT >= PERIOD_OUT_wire) and (sync_puLSE = '1')
and (CPWMo0lL = '1')) then
pWM_POSEDGE_REg(CPWMo1ll*apb_dwidth downto (CPWMo1lL-1)*aPB_DWIDTH+1) <= CPWMllll(CPWMo1ll*APB_DWIDTH downto (CPWMo1LL-1)*apb_dwidth+1);
pwm_negedge_reG(CPWMo1LL*APb_dwidth downto (CPWMo1ll-1)*apb_dWIDTH+1) <= CPWMILLL(CPWMo1ll*apb_dwidTH downto (CPWMo1ll-1)*APB_Dwidth+1);
end if;
end if;
end process;
end generate;
CPWML1ll:
for J in 1 to (PWM_NUM)
generate
CPWMI1LL:
if (shADOW_REG_EN(j-1) = '1')
generate
CPWMl1ol(J*Apb_dwidth downto (j-1)*APB_DWIDTH+1) <= PWM_POSEdge_reg(j*apb_dwidth downto (J-1)*APb_dwidth+1);
CPWMI1OL(j*apB_DWIDTH downto (J-1)*apb_dwidth+1) <= pwm_NEGEDGE_REG(j*APB_dwidth downto (J-1)*apb_dwidth+1);
end generate;
CPWMooil:
if (shadow_reg_EN(j-1) = '0')
generate
CPWML1Ol(J*apb_DWIDTH downto (J-1)*APB_DWIDTh+1) <= CPWMllll(j*apb_dWIDTH downto (j-1)*apb_dwidth+1);
CPWMI1OL(j*APB_DWIdth downto (j-1)*aPB_DWIDTH+1) <= CPWMILll(j*APB_dwidth downto (J-1)*apb_dwidth+1);
end generate;
end generate;
CPWMlOIL:
for L in 1 to (PWM_NUm)
generate
CPWMIOIL:
if (fixed_PWM_POS_EN(l-1) = '1')
generate
PWM_POSEDGE_out_wire(l*APB_DWIDTh downto (l-1)*apB_DWIDTH+1) <= FIXED_PWm_posedge(L*apb_DWIDTH-1 downto (l-1)*apb_dwIDTH);
end generate;
CPWMoliL:
if (fiXED_PWM_POS_En(l-1) = '0')
generate
pwm_posedge_ouT_WIRE(l*APB_DWIDth downto (L-1)*apb_dwiDTH+1) <= CPWMl1ol(l*APB_dwidth downto (L-1)*APB_dwidth+1);
end generate;
end generate;
CPWMllil:
for m in 1 to (PWM_NUM)
generate
CPWMilil:
if (Fixed_pwm_neg_en(M-1) = '1')
generate
pwm_negedGE_OUT_WIRE(M*APB_DWIDth downto (M-1)*apb_dwidth+1) <= fiXED_PWM_NEGEDge(m*apb_dwidth-1 downto (M-1)*apb_dWIDTH);
end generate;
CPWMoiiL:
if (FIXEd_pwm_neg_en(m-1) = '0')
generate
pwm_negedge_OUT_WIRE(m*apb_dwidth downto (M-1)*apb_dwidth+1) <= CPWMi1ol(M*apb_dwidth downto (M-1)*apb_dwIDTH+1);
end generate;
end generate;
process (PRESETN,Pclk)
begin
if ((not (presetn)) = '1') then
prescALE_REG(3 downto 0) <= "1000";
prescale_rEG((aPB_DWIDTH-1) downto 4) <= ( others => '0');
Period_reg(3 downto 0) <= "1000";
PERiod_reg((apb_DWIDTH-1) downto 4) <= ( others => '0');
PWm_enable_reg <= ( others => '0');
elsif (PCLK'EVENT and PCLK = '1') then
if ((PERIOD_Cnt >= PERIod_out_wire) and ((SYNC_PUlse)) = '1') then
prescALE_REG <= CPWMOOLL;
PERiod_reg <= CPWMloll;
PWM_ENABLE_reg <= (CPWMolll&CPWMIOLL);
end if;
end if;
end process;
CPWMliil:
for CPWMiiil in 1 to (PWM_NUM)
generate
CPWMO0IL:
if (SHADOW_Reg_en(CPWMiiil-1) = '1')
generate
pwm_enABLE_OUT_WIRe(CPWMiiil) <= PWM_ENABLE_reg(CPWMiiil);
end generate;
CPWML0Il:
if (SHADOW_REG_EN(CPWMiiil-1) = '0')
generate
PWM_ENABLE_Out_wire(CPWMIIIL) <= CPWMOILL(CPWMiiil);
end generate;
end generate;
CPWMI0OL <= prescale_reg;
CPWMo1OL <= period_REG;
PRESCALE_out_wire <= STD_logic_vector(tO_UNSIGNED(fIXED_PRESCALE,
apb_dwidth)) when stD_LOGIC_VECTOr(TO_unsigned(fixed_prescalE_EN,
2)) = "01" else
CPWMI0OL;
perioD_OUT_WIRE <= STD_LOGIC_Vector(to_unsigned(fixeD_PERIOD,
apb_dwidth)) when std_logic_VECTOR(TO_UNSIGNed(fixed_period_EN,
2)) = "01" else
CPWMO1ol;
CPWMI0IL:
if (apb_DWIDTH = 8)
generate
process (PADDR,PRESCALE_out_wire,period_out_WIRE,PWM_ENABLE_Out_wire)
begin
case (paDDR) is
when "000000" =>
CPWMlill <= Prescale_out_wire;
when "000001" =>
CPWMLILL <= perioD_OUT_WIRE;
when "000010" =>
CPWMlill(7 downto 0) <= PWM_Enable_out_wire(8 downto 1);
when "000011" =>
CPWMlill(7 downto 0) <= PWM_ENABLE_Out_wire(16 downto 9);
when others =>
CPWMLILL <= ( others => '0');
end case;
end process;
end generate;
CPWMo1il:
if (APB_DWIDTh > 8)
generate
process (PADdr,PRESCALE_Out_wire,period_out_wire,pwm_ENABLE_OUT_WIre)
begin
case (paddr) is
when "000000" =>
CPWMLILL <= prescaLE_OUT_WIRE;
when "000001" =>
CPWMlill <= PERIOD_OUt_wire;
when "000010" =>
CPWMlill <= (CPWMi0(APB_dwidth-1 downto 8)&pwm_enable_oUT_WIRE(8 downto 1));
when "000011" =>
CPWMlill <= (CPWMi0(APB_Dwidth-1 downto 8)&Pwm_enable_out_wiRE(16 downto 9));
when others =>
CPWMlill <= ( others => '0');
end case;
end process;
end generate;
CPWML1il:
if (PWm_num <= 1)
generate
process (paddr,pwm_posedge_out_WIRE,PWM_Negedge_out_wire)
begin
case (paddr) is
when "000100" =>
CPWMIILL <= pwm_POSEDGE_OUT_Wire(1*apb_dWIDTH downto 0*APB_DWIDTH+1);
when "000101" =>
CPWMiill <= PWM_NEGEDGe_out_wire(1*apb_dwidth downto 0*apb_dwidth+1);
when "100100" =>
CPWMIILL <= (CPWMl0OL&PWM_stretch(PWM_NUM-1 downto 0));
when others =>
CPWMIILL <= ( others => '0');
end case;
end process;
end generate;
CPWMi1il:
if (PWM_NUM = 2)
generate
process (Paddr,pwm_posedge_out_wIRE,PWM_NEgedge_out_wire)
begin
case (PADDR) is
when "000100" =>
CPWMiill <= pwm_posedge_out_WIRE(1*apb_dwidtH downto 0*APB_DWIDTH+1);
when "000101" =>
CPWMiill <= Pwm_negedge_out_wIRE(1*APB_DWidth downto 0*Apb_dwidth+1);
when "000110" =>
CPWMiill <= pWM_POSEDGE_OUt_wire(2*apb_dwidtH downto 1*apb_DWIDTH+1);
when "000111" =>
CPWMiill <= PWM_NEGEDGE_out_wire(2*apb_dWIDTH downto 1*APB_DWIDTH+1);
when "100100" =>
CPWMiilL <= (CPWMl0ol&PWM_stretch(PWM_num-1 downto 0));
when others =>
CPWMiill <= ( others => '0');
end case;
end process;
end generate;
CPWMoo0l:
if (PWM_NUM = 3)
generate
process (paDDR,pwm_posedge_out_WIRE,PWM_NEGEdge_out_wire)
begin
case (PADDR) is
when "000100" =>
CPWMIILL <= pwm_POSEDGE_OUT_Wire(1*APB_DWIDTH downto 0*APB_dwidth+1);
when "000101" =>
CPWMIILL <= pwm_negeDGE_OUT_WIRe(1*apb_dwIDTH downto 0*APB_DWIDTH+1);
when "000110" =>
CPWMIill <= pwm_POSEDGE_OUT_wire(2*apb_DWIDTH downto 1*APB_DWIdth+1);
when "000111" =>
CPWMIILL <= PWM_NEGEDGE_Out_wirE(2*APB_dwidth downto 1*apb_dwidth+1);
when "001000" =>
CPWMiill <= pwm_poSEDGE_OUT_WIRe(3*Apb_dwidth downto 2*apb_dwidth+1);
when "001001" =>
CPWMiill <= pwm_negedgE_OUT_WIRE(3*Apb_dwidth downto 2*APb_dwidth+1);
when "100100" =>
CPWMiill <= (CPWMl0ol&PWM_STRETCH(pwm_num-1 downto 0));
when others =>
CPWMiill <= ( others => '0');
end case;
end process;
end generate;
CPWMlo0l:
if (PWM_NUM = 4)
generate
process (PADDr,PWM_POSEDGE_Out_wire,pwm_neGEDGE_OUT_WIRe)
begin
case (paddr) is
when "000100" =>
CPWMIILL <= pWM_POSEDGE_OUt_wire(1*APB_Dwidth downto 0*apb_dwidth+1);
when "000101" =>
CPWMiill <= pwm_negedGE_OUT_WIRE(1*apb_dwIDTH downto 0*APB_DWIDTH+1);
when "000110" =>
CPWMIILL <= pwm_pOSEDGE_OUT_Wire(2*apb_dWIDTH downto 1*apB_DWIDTH+1);
when "000111" =>
CPWMIILl <= pwm_negEDGE_OUT_WIRe(2*APB_DWIDTH downto 1*APB_dwidth+1);
when "001000" =>
CPWMIILL <= pwm_posEDGE_OUT_WIRe(3*apb_dwidth downto 2*apb_dwidtH+1);
when "001001" =>
CPWMiill <= PWM_NEGEDGE_out_wire(3*APB_dwidth downto 2*apb_dwidth+1);
when "001010" =>
CPWMiILL <= PWM_Posedge_out_wire(4*aPB_DWIDTH downto 3*APB_DWIDTH+1);
when "001011" =>
CPWMiill <= pwm_negEDGE_OUT_WIRE(4*Apb_dwidth downto 3*apb_dwidth+1);
when "100100" =>
CPWMiILL <= (CPWMl0ol&PWM_stretch(PWM_num-1 downto 0));
when others =>
CPWMIILL <= ( others => '0');
end case;
end process;
end generate;
CPWMio0l:
if (PWM_NUM = 5)
generate
process (PADDR,pWM_POSEDGE_OUt_wire,pwm_negedge_OUT_WIRE)
begin
case (PADDR) is
when "000100" =>
CPWMIILl <= PWm_posedge_out_wiRE(1*Apb_dwidth downto 0*apb_dwiDTH+1);
when "000101" =>
CPWMIILL <= pwm_neGEDGE_OUT_Wire(1*apb_dwidth downto 0*apb_dwidth+1);
when "000110" =>
CPWMIILL <= PWM_POSEDGE_Out_wire(2*apb_dwidth downto 1*apb_dwidth+1);
when "000111" =>
CPWMiill <= PWM_NEGEDGE_out_wire(2*apb_dwidth downto 1*apB_DWIDTH+1);
when "001000" =>
CPWMiill <= PWM_posedge_out_wirE(3*APB_DWidth downto 2*APB_DWIdth+1);
when "001001" =>
CPWMIILL <= pwm_negedge_OUT_WIRE(3*apb_dwidth downto 2*Apb_dwidth+1);
when "001010" =>
CPWMIILL <= pwm_posedge_OUT_WIRE(4*APB_Dwidth downto 3*aPB_DWIDTH+1);
when "001011" =>
CPWMIILL <= pwm_negedGE_OUT_WIRE(4*APB_dwidth downto 3*Apb_dwidth+1);
when "001100" =>
CPWMiill <= PWM_POSEDGe_out_wire(5*apb_dwIDTH downto 4*APB_DWIDTH+1);
when "001101" =>
CPWMIill <= Pwm_negedge_out_wIRE(5*apB_DWIDTH downto 4*APB_DWIDTH+1);
when "100100" =>
CPWMiill <= (CPWMl0ol&PWM_Stretch(pwm_num-1 downto 0));
when others =>
CPWMiill <= ( others => '0');
end case;
end process;
end generate;
CPWMol0l:
if (pwm_nuM = 6)
generate
process (paddr,PWM_POsedge_out_wire,pwm_negEDGE_OUT_WIRE)
begin
case (paddr) is
when "000100" =>
CPWMIILL <= pwm_posedge_out_WIRE(1*apb_dwidTH downto 0*APB_DWIDTH+1);
when "000101" =>
CPWMIILL <= Pwm_negedge_out_wIRE(1*apB_DWIDTH downto 0*APB_DWIdth+1);
when "000110" =>
CPWMiill <= pwm_POSEDGE_OUT_Wire(2*apb_dwidth downto 1*apb_dwidtH+1);
when "000111" =>
CPWMIILL <= pwm_negedge_out_WIRE(2*apb_dwidth downto 1*apb_dwidth+1);
when "001000" =>
CPWMIILL <= PWM_POSEDGE_out_wire(3*apb_dwidth downto 2*apb_dwidth+1);
when "001001" =>
CPWMiill <= PWM_NEGEDge_out_wire(3*apb_dwIDTH downto 2*apb_dwIDTH+1);
when "001010" =>
CPWMiill <= PWM_POSEDge_out_wire(4*apb_dwidth downto 3*apb_dwidth+1);
when "001011" =>
CPWMIILL <= pwm_negedge_OUT_WIRE(4*APB_dwidth downto 3*APB_dwidth+1);
when "001100" =>
CPWMIILL <= pwm_posedge_out_WIRE(5*APB_DWIDTH downto 4*apb_dwidth+1);
when "001101" =>
CPWMiill <= PWM_NEGEDGe_out_wire(5*apb_dwidTH downto 4*apb_dwidth+1);
when "001110" =>
CPWMIILL <= pwm_poSEDGE_OUT_WIre(6*APB_Dwidth downto 5*APB_DWIDTH+1);
when "001111" =>
CPWMiiLL <= PWM_NEGEdge_out_wire(6*apb_dwidtH downto 5*Apb_dwidth+1);
when "100100" =>
CPWMIILL <= (CPWML0OL&pwm_stretcH(PWM_NUM-1 downto 0));
when others =>
CPWMiilL <= ( others => '0');
end case;
end process;
end generate;
CPWMll0L:
if (pwm_NUM = 7)
generate
process (PADDR,pwm_posedgE_OUT_WIRE,PWM_negedge_out_wirE)
begin
case (PADDR) is
when "000100" =>
CPWMiill <= pwm_POSEDGE_OUT_wire(1*apb_dwidth downto 0*apb_DWIDTH+1);
when "000101" =>
CPWMIILL <= pwm_negedge_oUT_WIRE(1*apb_dwidth downto 0*apb_dwidth+1);
when "000110" =>
CPWMiill <= Pwm_posedge_out_wIRE(2*APB_dwidth downto 1*apb_dwidth+1);
when "000111" =>
CPWMiill <= PWM_NEgedge_out_wire(2*apb_DWIDTH downto 1*APB_DWIDTH+1);
when "001000" =>
CPWMIILL <= pwm_pOSEDGE_OUT_WIre(3*apb_dwidth downto 2*apb_dwidth+1);
when "001001" =>
CPWMiill <= PWM_NEGEDGE_out_wire(3*apb_dwidth downto 2*apb_dwidth+1);
when "001010" =>
CPWMIILl <= pwM_POSEDGE_OUT_wire(4*apb_dwidtH downto 3*apb_dwiDTH+1);
when "001011" =>
CPWMIILL <= pwm_negEDGE_OUT_WIRe(4*Apb_dwidth downto 3*apb_dwidth+1);
when "001100" =>
CPWMIill <= pWM_POSEDGE_OUt_wire(5*apb_dwidth downto 4*Apb_dwidth+1);
when "001101" =>
CPWMiill <= PWM_NEGEDGe_out_wire(5*APB_DWIDth downto 4*APB_DWIdth+1);
when "001110" =>
CPWMiiLL <= PWm_posedge_out_wirE(6*apb_dwidTH downto 5*apb_dwidTH+1);
when "001111" =>
CPWMIILL <= pwm_negEDGE_OUT_WIRE(6*APB_DWIDTH downto 5*APB_DWIDTH+1);
when "010000" =>
CPWMiill <= pwm_posEDGE_OUT_WIRE(7*APB_DWIDTH downto 6*apb_dwidth+1);
when "010001" =>
CPWMIILL <= pwm_negedge_OUT_WIRE(7*apb_dWIDTH downto 6*apb_dwidth+1);
when "100100" =>
CPWMIILL <= (CPWMl0oL&PWM_STRETCh(Pwm_num-1 downto 0));
when others =>
CPWMiill <= ( others => '0');
end case;
end process;
end generate;
CPWMIL0L:
if (pwm_nUM = 8)
generate
process (paddr,pWM_POSEDGE_OUt_wire,pwm_negedge_out_WIRE)
begin
case (PADDR) is
when "000100" =>
CPWMiill <= pwM_POSEDGE_OUT_wire(1*apb_dwidth downto 0*APB_Dwidth+1);
when "000101" =>
CPWMiill <= PWM_Negedge_out_wire(1*APB_dwidth downto 0*APB_DWIDTH+1);
when "000110" =>
CPWMIILL <= PWM_POSEDge_out_wire(2*APB_Dwidth downto 1*apb_dwidth+1);
when "000111" =>
CPWMiill <= PWm_negedge_out_wiRE(2*APB_DWIdth downto 1*apb_dwidth+1);
when "001000" =>
CPWMiill <= PWM_POSEDGE_out_wire(3*APB_DWIDTH downto 2*APB_dwidth+1);
when "001001" =>
CPWMIill <= pWM_NEGEDGE_OUt_wire(3*apb_dwIDTH downto 2*APB_DWIDTH+1);
when "001010" =>
CPWMiILL <= pwm_posedge_oUT_WIRE(4*APb_dwidth downto 3*APb_dwidth+1);
when "001011" =>
CPWMIILL <= pwm_negedGE_OUT_WIRE(4*APB_DWidth downto 3*APB_DWidth+1);
when "001100" =>
CPWMIILL <= pwm_pOSEDGE_OUT_Wire(5*apb_dwidth downto 4*Apb_dwidth+1);
when "001101" =>
CPWMIILL <= pwm_negedge_out_WIRE(5*APB_DWIDTH downto 4*APB_DWIDTH+1);
when "001110" =>
CPWMiill <= PWM_POSEDGE_out_wire(6*apb_dwidth downto 5*apb_dwidth+1);
when "001111" =>
CPWMIILL <= pwm_negedge_oUT_WIRE(6*APB_DWIDTh downto 5*APB_DWIDTH+1);
when "010000" =>
CPWMiill <= PWM_POSEDGE_Out_wire(7*apb_dwidth downto 6*APB_dwidth+1);
when "010001" =>
CPWMiill <= PWM_NEGEDGE_Out_wire(7*apb_dwidth downto 6*APb_dwidth+1);
when "010010" =>
CPWMIill <= PWM_posedge_out_wIRE(8*apb_dwidth downto 7*APB_DWIDTH+1);
when "010011" =>
CPWMiILL <= pwM_NEGEDGE_OUT_wire(8*apb_DWIDTH downto 7*APB_DWIDTH+1);
when "100100" =>
CPWMiill <= (CPWML0ol&PWM_Stretch(pwM_NUM-1 downto 0));
when others =>
CPWMiill <= ( others => '0');
end case;
end process;
end generate;
CPWMOI0L:
if (pwm_num = 9)
generate
process (PADDR,pwm_posedge_out_WIRE,pwm_NEGEDGE_OUT_wire)
begin
case (paddr) is
when "000100" =>
CPWMiill <= PWM_posedge_out_wire(1*apb_dwiDTH downto 0*Apb_dwidth+1);
when "000101" =>
CPWMiill <= PWM_NEGEdge_out_wire(1*APb_dwidth downto 0*APB_DWIDTH+1);
when "000110" =>
CPWMiill <= PWM_POSEDge_out_wire(2*Apb_dwidth downto 1*apb_dwIDTH+1);
when "000111" =>
CPWMIILL <= pwm_NEGEDGE_OUT_Wire(2*APB_DWIdth downto 1*apb_dwidth+1);
when "001000" =>
CPWMiill <= PWM_posedge_out_wirE(3*apb_dwidTH downto 2*apb_DWIDTH+1);
when "001001" =>
CPWMiill <= PWM_NEGedge_out_wire(3*APB_DWidth downto 2*apb_dwidth+1);
when "001010" =>
CPWMiill <= PWM_POSEDge_out_wire(4*apb_DWIDTH downto 3*Apb_dwidth+1);
when "001011" =>
CPWMiill <= pWM_NEGEDGE_Out_wire(4*APB_DWIDTH downto 3*APb_dwidth+1);
when "001100" =>
CPWMIill <= Pwm_posedge_out_wIRE(5*aPB_DWIDTH downto 4*APB_DWIDth+1);
when "001101" =>
CPWMIIll <= pwm_negedge_OUT_WIRE(5*apb_dwidth downto 4*APb_dwidth+1);
when "001110" =>
CPWMIill <= pwm_posedge_out_WIRE(6*APB_Dwidth downto 5*Apb_dwidth+1);
when "001111" =>
CPWMiiLL <= PWM_negedge_out_wire(6*APB_dwidth downto 5*apb_dwidth+1);
when "010000" =>
CPWMiill <= pwm_POSEDGE_OUT_wire(7*Apb_dwidth downto 6*APB_DWIdth+1);
when "010001" =>
CPWMIILL <= PWM_negedge_out_wirE(7*apb_dwidTH downto 6*apb_dwidth+1);
when "010010" =>
CPWMIILL <= pwm_posedge_out_WIRE(8*apb_dWIDTH downto 7*apb_dwidth+1);
when "010011" =>
CPWMiILL <= pwm_negedge_OUT_WIRE(8*APB_DWIDTH downto 7*apb_dwidtH+1);
when "010100" =>
CPWMiill <= pwm_pOSEDGE_OUT_Wire(9*apb_DWIDTH downto 8*APB_dwidth+1);
when "010101" =>
CPWMiill <= PWM_Negedge_out_wire(9*aPB_DWIDTH downto 8*APB_Dwidth+1);
when "100100" =>
CPWMIILL <= (CPWMl0OL&PWM_STREtch(PWM_NUM-1 downto 0));
when others =>
CPWMIILL <= ( others => '0');
end case;
end process;
end generate;
CPWMli0l:
if (pwm_num = 10)
generate
process (paddr,PWM_POSEDGE_Out_wire,Pwm_negedge_out_wIRE)
begin
case (paddr) is
when "000100" =>
CPWMIILl <= pwm_posedge_out_wIRE(1*Apb_dwidth downto 0*APB_dwidth+1);
when "000101" =>
CPWMIILL <= pwm_NEGEDGE_OUT_wire(1*APb_dwidth downto 0*APB_Dwidth+1);
when "000110" =>
CPWMiill <= PWM_Posedge_out_wire(2*apb_dwidth downto 1*APB_DWIDTH+1);
when "000111" =>
CPWMIILL <= pwM_NEGEDGE_OUT_wire(2*apb_dWIDTH downto 1*APB_DWIDTH+1);
when "001000" =>
CPWMiill <= PWM_POSEDGE_out_wire(3*Apb_dwidth downto 2*apb_DWIDTH+1);
when "001001" =>
CPWMiill <= PWM_NEGEdge_out_wire(3*APB_Dwidth downto 2*apb_dwidth+1);
when "001010" =>
CPWMiill <= PWM_POSEdge_out_wire(4*APB_DWIDTh downto 3*APB_dwidth+1);
when "001011" =>
CPWMiill <= PWM_negedge_out_wirE(4*APB_DWIDTH downto 3*apb_dwidth+1);
when "001100" =>
CPWMiiLL <= pwm_posedge_out_WIRE(5*APB_DWIdth downto 4*APB_dwidth+1);
when "001101" =>
CPWMiill <= pwm_NEGEDGE_OUT_wire(5*apb_dwidtH downto 4*apb_dwIDTH+1);
when "001110" =>
CPWMiill <= PWM_POSEDGE_out_wire(6*APB_DWIDTH downto 5*APB_DWIDTH+1);
when "001111" =>
CPWMIILL <= Pwm_negedge_out_wIRE(6*APB_DWIDTH downto 5*APB_DWIDTH+1);
when "010000" =>
CPWMiill <= PWM_POSEDGE_OUt_wire(7*apb_dwidth downto 6*APB_Dwidth+1);
when "010001" =>
CPWMiill <= pwM_NEGEDGE_OUT_wire(7*Apb_dwidth downto 6*APB_DWIdth+1);
when "010010" =>
CPWMiilL <= PWM_posedge_out_wirE(8*aPB_DWIDTH downto 7*apb_dwiDTH+1);
when "010011" =>
CPWMIILL <= PWM_NEGEdge_out_wire(8*apb_dwidth downto 7*APB_dwidth+1);
when "010100" =>
CPWMiill <= pwm_poSEDGE_OUT_Wire(9*APB_DWidth downto 8*APB_DWIDth+1);
when "010101" =>
CPWMiill <= pwm_negedgE_OUT_WIRE(9*APB_DWIdth downto 8*APB_DWIDTH+1);
when "010110" =>
CPWMIILL <= PWM_posedge_out_wiRE(10*apb_dwiDTH downto 9*apB_DWIDTH+1);
when "010111" =>
CPWMIILL <= Pwm_negedge_out_wIRE(10*APB_DWIDTH downto 9*APB_dwidth+1);
when "100100" =>
CPWMiill <= (CPWMl0ol&pwM_STRETCH(PWM_NUM-1 downto 0));
when others =>
CPWMIILL <= ( others => '0');
end case;
end process;
end generate;
CPWMii0l:
if (pwm_num = 11)
generate
process (PADdr,pwm_poseDGE_OUT_WIRE,PWM_NEGedge_out_wire)
begin
case (PADDR) is
when "000100" =>
CPWMIILL <= pwm_poseDGE_OUT_WIRE(1*apb_dwidth downto 0*APB_dwidth+1);
when "000101" =>
CPWMiill <= PWM_NEgedge_out_wire(1*apb_dwidth downto 0*APB_DWIDTH+1);
when "000110" =>
CPWMIILL <= PWM_POSEDGE_out_wire(2*apb_DWIDTH downto 1*APb_dwidth+1);
when "000111" =>
CPWMIILL <= pwm_NEGEDGE_OUT_Wire(2*APb_dwidth downto 1*apb_dwiDTH+1);
when "001000" =>
CPWMIILL <= pwm_posedge_OUT_WIRE(3*apb_DWIDTH downto 2*Apb_dwidth+1);
when "001001" =>
CPWMiill <= PWM_NEGEDge_out_wire(3*APB_dwidth downto 2*apb_dwidth+1);
when "001010" =>
CPWMiill <= PWM_POSedge_out_wire(4*APB_DWIDTH downto 3*APB_dwidth+1);
when "001011" =>
CPWMIILL <= PWM_NEGEDGE_OUt_wire(4*APB_DWIDTH downto 3*apb_dwidth+1);
when "001100" =>
CPWMiill <= PWM_POSEDGE_out_wire(5*APB_DWIDTH downto 4*APB_DWIdth+1);
when "001101" =>
CPWMIILL <= pWM_NEGEDGE_OUt_wire(5*apb_dwidth downto 4*apb_dwiDTH+1);
when "001110" =>
CPWMiill <= pwm_POSEDGE_OUT_wire(6*apb_dwidth downto 5*APB_DWIDTH+1);
when "001111" =>
CPWMiill <= pwm_negeDGE_OUT_WIRE(6*apb_dwidth downto 5*apb_dwidTH+1);
when "010000" =>
CPWMiill <= PWM_POSEDGE_out_wire(7*apb_dwidth downto 6*apb_dWIDTH+1);
when "010001" =>
CPWMIILL <= PWM_NEGEdge_out_wire(7*Apb_dwidth downto 6*APB_DWidth+1);
when "010010" =>
CPWMiiLL <= PWM_POSedge_out_wire(8*apb_dwidth downto 7*apb_dwidth+1);
when "010011" =>
CPWMiilL <= PWM_NEGEDGE_out_wire(8*apb_dwidth downto 7*APB_dwidth+1);
when "010100" =>
CPWMiill <= pwm_posedge_oUT_WIRE(9*apb_DWIDTH downto 8*apb_dwidth+1);
when "010101" =>
CPWMiill <= pWM_NEGEDGE_OUt_wire(9*APB_Dwidth downto 8*APB_DWIDTH+1);
when "010110" =>
CPWMiill <= PWM_POSEDGe_out_wire(10*apb_dwidth downto 9*APB_dwidth+1);
when "010111" =>
CPWMiill <= pwm_nEGEDGE_OUT_Wire(10*Apb_dwidth downto 9*APB_DWIdth+1);
when "011000" =>
CPWMiill <= pwm_posedge_out_wIRE(11*APB_DWIDTH downto 10*APB_DWIDTH+1);
when "011001" =>
CPWMIill <= Pwm_negedge_out_wIRE(11*apb_dwidth downto 10*APB_dwidth+1);
when "100100" =>
CPWMiill <= (CPWML0OL&PWM_stretch(pwm_num-1 downto 0));
when others =>
CPWMIILL <= ( others => '0');
end case;
end process;
end generate;
CPWMO00L:
if (PWM_NUM = 12)
generate
process (paddr,pwM_POSEDGE_OUT_wire,pwm_negedge_OUT_WIRE)
begin
case (Paddr) is
when "000100" =>
CPWMiill <= pwm_posedge_out_wIRE(1*apb_dWIDTH downto 0*apb_dwidth+1);
when "000101" =>
CPWMiill <= pwm_negedge_out_WIRE(1*apb_DWIDTH downto 0*apb_dwidth+1);
when "000110" =>
CPWMiill <= Pwm_posedge_out_wiRE(2*APB_DWidth downto 1*APB_DWIDTH+1);
when "000111" =>
CPWMIill <= PWM_negedge_out_wiRE(2*apb_dwidth downto 1*APB_DWIDTH+1);
when "001000" =>
CPWMIIll <= PWM_POSEDGe_out_wire(3*APB_DWIDTh downto 2*apb_dwiDTH+1);
when "001001" =>
CPWMIILL <= pwm_negEDGE_OUT_WIRe(3*apb_dwidth downto 2*APB_Dwidth+1);
when "001010" =>
CPWMIILL <= PWM_POSEDGE_out_wire(4*apb_DWIDTH downto 3*APB_dwidth+1);
when "001011" =>
CPWMiill <= PWM_negedge_out_wiRE(4*APB_Dwidth downto 3*APB_DWIDTH+1);
when "001100" =>
CPWMIILL <= pwm_posedGE_OUT_WIRE(5*apb_dwidth downto 4*apb_dwidtH+1);
when "001101" =>
CPWMiill <= PWM_NEGEDGe_out_wire(5*apb_dwidtH downto 4*apb_dWIDTH+1);
when "001110" =>
CPWMiill <= PWM_POsedge_out_wire(6*apb_dWIDTH downto 5*APB_DWidth+1);
when "001111" =>
CPWMIIll <= pwm_negedgE_OUT_WIRE(6*APB_Dwidth downto 5*apb_dwidth+1);
when "010000" =>
CPWMIILL <= Pwm_posedge_out_wIRE(7*APB_DWIDTh downto 6*APB_DWidth+1);
when "010001" =>
CPWMiilL <= PWm_negedge_out_wiRE(7*apb_dWIDTH downto 6*apb_DWIDTH+1);
when "010010" =>
CPWMiill <= pWM_POSEDGE_OUt_wire(8*apb_dwidth downto 7*apb_dwidTH+1);
when "010011" =>
CPWMiill <= pwm_NEGEDGE_OUT_Wire(8*APB_dwidth downto 7*APB_dwidth+1);
when "010100" =>
CPWMiill <= pWM_POSEDGE_OUt_wire(9*apb_dwidth downto 8*APB_dwidth+1);
when "010101" =>
CPWMIILL <= PWm_negedge_out_wIRE(9*apb_dwidth downto 8*apb_dwidth+1);
when "010110" =>
CPWMIILL <= pwm_posedge_ouT_WIRE(10*APB_DWIDTH downto 9*APB_DWIDTH+1);
when "010111" =>
CPWMiiLL <= PWM_NEgedge_out_wire(10*apB_DWIDTH downto 9*apb_dwidtH+1);
when "011000" =>
CPWMiill <= PWM_POSEDGe_out_wire(11*aPB_DWIDTH downto 10*apb_dwidtH+1);
when "011001" =>
CPWMiill <= pwm_nEGEDGE_OUT_WIre(11*APB_DWidth downto 10*apb_dwidth+1);
when "011010" =>
CPWMiill <= pwm_posedge_out_WIRE(12*apb_dwidTH downto 11*APB_dwidth+1);
when "011011" =>
CPWMiill <= pwm_negedge_ouT_WIRE(12*APB_DWIdth downto 11*aPB_DWIDTH+1);
when "100100" =>
CPWMIILL <= (CPWMl0ol&pwm_stretcH(PWM_NUM-1 downto 0));
when others =>
CPWMiill <= ( others => '0');
end case;
end process;
end generate;
CPWMl00l:
if (Pwm_num = 13)
generate
process (PADDR,pwm_posedge_oUT_WIRE,pWM_NEGEDGE_OUT_wire)
begin
case (PADDR) is
when "000100" =>
CPWMiill <= pwm_poseDGE_OUT_WIRE(1*apb_dwidth downto 0*APB_DWIdth+1);
when "000101" =>
CPWMIIll <= PWM_Negedge_out_wire(1*APb_dwidth downto 0*APB_DWIDTH+1);
when "000110" =>
CPWMIILL <= PWM_POSEDGE_out_wire(2*apb_dwidtH downto 1*APB_DWidth+1);
when "000111" =>
CPWMiill <= pwm_negedge_out_wIRE(2*apb_dwiDTH downto 1*apb_dwidth+1);
when "001000" =>
CPWMiill <= pwm_posedge_ouT_WIRE(3*apb_dwidTH downto 2*Apb_dwidth+1);
when "001001" =>
CPWMiill <= pwm_negedge_out_WIRE(3*apb_dwidth downto 2*apB_DWIDTH+1);
when "001010" =>
CPWMIILL <= pwm_posEDGE_OUT_WIRE(4*apb_dwidTH downto 3*APB_DWIDTH+1);
when "001011" =>
CPWMIILL <= pwm_neGEDGE_OUT_WIRe(4*apb_DWIDTH downto 3*APB_Dwidth+1);
when "001100" =>
CPWMiill <= PWM_POSedge_out_wire(5*APB_DWIDTH downto 4*APB_DWidth+1);
when "001101" =>
CPWMIILL <= pwm_NEGEDGE_OUT_wire(5*apb_dwidTH downto 4*apb_dWIDTH+1);
when "001110" =>
CPWMIILL <= pwm_posedge_OUT_WIRE(6*apb_dwidth downto 5*apb_dwidth+1);
when "001111" =>
CPWMIILL <= pwm_negedGE_OUT_WIRE(6*Apb_dwidth downto 5*apb_dwidth+1);
when "010000" =>
CPWMiill <= pWM_POSEDGE_OUt_wire(7*apb_dwidtH downto 6*apb_dwidth+1);
when "010001" =>
CPWMiill <= pwm_negedge_out_wIRE(7*APB_DWIdth downto 6*APb_dwidth+1);
when "010010" =>
CPWMIILL <= pwm_posedge_OUT_WIRE(8*apb_dwidth downto 7*apb_dwidth+1);
when "010011" =>
CPWMIILL <= PWm_negedge_out_wiRE(8*APB_DWIDTH downto 7*APB_DWidth+1);
when "010100" =>
CPWMIill <= pwm_pOSEDGE_OUT_Wire(9*APB_dwidth downto 8*apb_dwidth+1);
when "010101" =>
CPWMIILL <= pwm_negedGE_OUT_WIRE(9*APB_Dwidth downto 8*APB_DWidth+1);
when "010110" =>
CPWMiill <= PWM_POSEDGE_out_wire(10*apb_dwidth downto 9*apb_dwidth+1);
when "010111" =>
CPWMIILL <= PWM_negedge_out_wire(10*apb_dwIDTH downto 9*apb_dwidth+1);
when "011000" =>
CPWMIILL <= PWM_POSEDge_out_wire(11*apb_dwidth downto 10*apb_dwidtH+1);
when "011001" =>
CPWMIill <= pwm_negedGE_OUT_WIRE(11*APB_dwidth downto 10*APB_DWIDth+1);
when "011010" =>
CPWMiill <= pwm_posedgE_OUT_WIRE(12*APB_DWIDTh downto 11*APB_DWIDTH+1);
when "011011" =>
CPWMIIll <= pwm_negedge_out_wIRE(12*apb_dwiDTH downto 11*APB_dwidth+1);
when "011100" =>
CPWMiill <= pwm_poseDGE_OUT_WIRE(13*APB_DWIDTH downto 12*apb_DWIDTH+1);
when "011101" =>
CPWMiill <= PWM_NEGEDGE_out_wire(13*apb_dwidth downto 12*APB_Dwidth+1);
when "100100" =>
CPWMIILl <= (CPWML0OL&PWM_stretch(pwm_num-1 downto 0));
when others =>
CPWMIILl <= ( others => '0');
end case;
end process;
end generate;
CPWMi00l:
if (pwm_NUM = 14)
generate
process (paddr,pwm_poseDGE_OUT_WIRE,PWM_NEgedge_out_wire)
begin
case (paddr) is
when "000100" =>
CPWMIIll <= PWM_posedge_out_wirE(1*APB_Dwidth downto 0*APB_dwidth+1);
when "000101" =>
CPWMiilL <= pwm_negEDGE_OUT_WIRe(1*apb_dWIDTH downto 0*apb_dwidth+1);
when "000110" =>
CPWMiill <= pwm_posedge_OUT_WIRE(2*apb_dwidtH downto 1*apb_dwiDTH+1);
when "000111" =>
CPWMiill <= pwm_negedgE_OUT_WIRE(2*APB_DWIDTH downto 1*apb_dwidth+1);
when "001000" =>
CPWMiill <= pwm_posedge_OUT_WIRE(3*apb_dWIDTH downto 2*apb_dwidth+1);
when "001001" =>
CPWMIIll <= PWM_NEGEDGE_out_wire(3*APB_DWIdth downto 2*apb_dwidth+1);
when "001010" =>
CPWMiiLL <= pwm_posedGE_OUT_WIRE(4*apb_DWIDTH downto 3*APB_Dwidth+1);
when "001011" =>
CPWMiill <= PWM_negedge_out_wire(4*APB_DWIDth downto 3*apb_dwidTH+1);
when "001100" =>
CPWMiill <= Pwm_posedge_out_wIRE(5*Apb_dwidth downto 4*apb_dwidth+1);
when "001101" =>
CPWMIILL <= pwm_negedge_out_wIRE(5*APb_dwidth downto 4*apb_dwidth+1);
when "001110" =>
CPWMiill <= pWM_POSEDGE_OUt_wire(6*apb_DWIDTH downto 5*APB_DWIDTH+1);
when "001111" =>
CPWMIILL <= pwm_negedge_OUT_WIRE(6*APB_dwidth downto 5*Apb_dwidth+1);
when "010000" =>
CPWMiill <= pwm_posEDGE_OUT_WIRe(7*apb_dwidth downto 6*Apb_dwidth+1);
when "010001" =>
CPWMIIll <= pwm_negEDGE_OUT_WIRe(7*apb_dwidth downto 6*apb_dwidth+1);
when "010010" =>
CPWMIILL <= PWm_posedge_out_wIRE(8*APB_DWIDth downto 7*Apb_dwidth+1);
when "010011" =>
CPWMiill <= PWM_NEGEdge_out_wire(8*apb_dWIDTH downto 7*APB_DWIDTH+1);
when "010100" =>
CPWMiill <= pwm_POSEDGE_OUT_Wire(9*APB_dwidth downto 8*Apb_dwidth+1);
when "010101" =>
CPWMIIll <= pwm_nEGEDGE_OUT_Wire(9*aPB_DWIDTH downto 8*apb_dwidth+1);
when "010110" =>
CPWMiill <= pwm_posedgE_OUT_WIRE(10*APB_DWIDTH downto 9*APB_DWIDTH+1);
when "010111" =>
CPWMIill <= PWM_negedge_out_wire(10*apb_dwidth downto 9*APb_dwidth+1);
when "011000" =>
CPWMiill <= pwm_posedge_out_WIRE(11*apb_dwidth downto 10*apb_DWIDTH+1);
when "011001" =>
CPWMiill <= PWm_negedge_out_wirE(11*APB_dwidth downto 10*apb_DWIDTH+1);
when "011010" =>
CPWMiill <= pwm_poseDGE_OUT_WIRE(12*apb_dwidTH downto 11*APB_DWIDTH+1);
when "011011" =>
CPWMIILL <= pwm_negEDGE_OUT_WIRE(12*APB_dwidth downto 11*APB_dwidth+1);
when "011100" =>
CPWMiill <= pwm_pOSEDGE_OUT_Wire(13*apb_dwIDTH downto 12*APB_DWIDTh+1);
when "011101" =>
CPWMiill <= PWm_negedge_out_wiRE(13*APB_DWIDTh downto 12*APB_Dwidth+1);
when "011110" =>
CPWMiill <= PWM_POSEDGE_out_wire(14*apb_dwidth downto 13*APB_dwidth+1);
when "011111" =>
CPWMIILL <= pwm_negedge_OUT_WIRe(14*apb_DWIDTH downto 13*apb_dwidth+1);
when "100100" =>
CPWMiill <= (CPWML0OL&pwm_stRETCH(PWM_num-1 downto 0));
when others =>
CPWMiill <= ( others => '0');
end case;
end process;
end generate;
CPWMo10l:
if (pwm_num = 15)
generate
process (paddr,PWM_POsedge_out_wire,pwm_nEGEDGE_OUT_WIre)
begin
case (Paddr) is
when "000100" =>
CPWMIILL <= PWM_POSEDGe_out_wire(1*APB_DWIDTH downto 0*APB_DWIDTH+1);
when "000101" =>
CPWMIILL <= PWM_NEGEDGE_out_wire(1*apb_dwidth downto 0*apb_dwidth+1);
when "000110" =>
CPWMIILL <= PWM_Posedge_out_wire(2*apb_dwidTH downto 1*APB_DWIDTH+1);
when "000111" =>
CPWMiilL <= PWM_negedge_out_wirE(2*apB_DWIDTH downto 1*apb_dwidth+1);
when "001000" =>
CPWMIILL <= PWM_POSEDGE_out_wire(3*APb_dwidth downto 2*apb_dWIDTH+1);
when "001001" =>
CPWMiill <= PWM_negedge_out_wirE(3*apb_dwidth downto 2*apB_DWIDTH+1);
when "001010" =>
CPWMiill <= PWM_posedge_out_wirE(4*Apb_dwidth downto 3*APB_DWIDTH+1);
when "001011" =>
CPWMiill <= pwm_negedge_OUT_WIRE(4*apb_dwIDTH downto 3*apb_dwidth+1);
when "001100" =>
CPWMiill <= Pwm_posedge_out_WIRE(5*apb_dwiDTH downto 4*Apb_dwidth+1);
when "001101" =>
CPWMIILl <= Pwm_negedge_out_wIRE(5*apb_DWIDTH downto 4*apb_dwidth+1);
when "001110" =>
CPWMiill <= PWm_posedge_out_wiRE(6*APB_dwidth downto 5*APB_DWIDTH+1);
when "001111" =>
CPWMiill <= PWM_NEGEDGE_out_wire(6*APB_DWIDTH downto 5*APB_dwidth+1);
when "010000" =>
CPWMiill <= Pwm_posedge_out_wIRE(7*APB_DWIdth downto 6*apb_dwidth+1);
when "010001" =>
CPWMIILL <= pWM_NEGEDGE_OUt_wire(7*apB_DWIDTH downto 6*APB_DWIDTh+1);
when "010010" =>
CPWMIILL <= pwm_POSEDGE_OUT_wire(8*apb_dwidth downto 7*apb_dwIDTH+1);
when "010011" =>
CPWMiill <= PWM_NEGEdge_out_wire(8*aPB_DWIDTH downto 7*APB_DWIdth+1);
when "010100" =>
CPWMiill <= pwm_posedgE_OUT_WIRE(9*APB_DWIDTH downto 8*APB_DWIdth+1);
when "010101" =>
CPWMIILL <= Pwm_negedge_out_wIRE(9*APB_DWIDTh downto 8*APB_DWIDTH+1);
when "010110" =>
CPWMIILL <= pwm_POSEDGE_OUT_wire(10*apb_dwidth downto 9*Apb_dwidth+1);
when "010111" =>
CPWMIIll <= pwm_negedGE_OUT_WIRE(10*apb_dwidTH downto 9*APB_dwidth+1);
when "011000" =>
CPWMIILL <= Pwm_posedge_out_wIRE(11*APB_DWIDTh downto 10*APB_DWidth+1);
when "011001" =>
CPWMIill <= pwm_NEGEDGE_OUT_wire(11*APB_dwidth downto 10*APB_dwidth+1);
when "011010" =>
CPWMIILL <= Pwm_posedge_out_wIRE(12*APB_DWIdth downto 11*APB_DWIDTH+1);
when "011011" =>
CPWMiill <= PWM_NEGEDGE_out_wire(12*apB_DWIDTH downto 11*aPB_DWIDTH+1);
when "011100" =>
CPWMiill <= pwM_POSEDGE_OUT_wire(13*APb_dwidth downto 12*APB_DWIDth+1);
when "011101" =>
CPWMIILL <= PWM_NEgedge_out_wire(13*apb_dwidTH downto 12*Apb_dwidth+1);
when "011110" =>
CPWMiill <= pwm_POSEDGE_OUT_wire(14*APB_dwidth downto 13*APB_DWIDth+1);
when "011111" =>
CPWMiill <= pwm_negedge_ouT_WIRE(14*APB_DWIDTH downto 13*apB_DWIDTH+1);
when "100000" =>
CPWMiill <= Pwm_posedge_out_wIRE(15*apb_dwidth downto 14*APB_DWIDTH+1);
when "100001" =>
CPWMiill <= pwm_negedge_ouT_WIRE(15*apb_dwIDTH downto 14*Apb_dwidth+1);
when "100100" =>
CPWMiill <= (CPWML0OL&PWM_STRETCH(PWM_NUM-1 downto 0));
when others =>
CPWMiill <= ( others => '0');
end case;
end process;
end generate;
CPWML10l:
if (pwm_num >= 16)
generate
process (Paddr,pwm_posedge_oUT_WIRE,pWM_NEGEDGE_OUt_wire)
begin
case (PADDR) is
when "000100" =>
CPWMiill <= pwm_posedge_ouT_WIRE(1*apB_DWIDTH downto 0*Apb_dwidth+1);
when "000101" =>
CPWMiill <= pwm_negedge_oUT_WIRE(1*apb_dwIDTH downto 0*apb_dwidTH+1);
when "000110" =>
CPWMIILL <= PWM_POSEDGE_out_wire(2*APB_DWidth downto 1*APB_DWIDTH+1);
when "000111" =>
CPWMIILL <= PWM_negedge_out_wire(2*apb_dwidth downto 1*APB_DWIDTH+1);
when "001000" =>
CPWMiill <= pwm_posedge_OUT_WIRE(3*APB_DWIDTH downto 2*apB_DWIDTH+1);
when "001001" =>
CPWMIILL <= pwM_NEGEDGE_OUT_wire(3*APB_Dwidth downto 2*APB_DWIDTH+1);
when "001010" =>
CPWMIILL <= pWM_POSEDGE_OUt_wire(4*APB_DWIdth downto 3*APB_DWIDTH+1);
when "001011" =>
CPWMIILL <= PWM_NEGEDge_out_wire(4*aPB_DWIDTH downto 3*APB_DWIdth+1);
when "001100" =>
CPWMIILL <= PWM_Posedge_out_wire(5*apb_dWIDTH downto 4*apb_dwidTH+1);
when "001101" =>
CPWMIILL <= PWM_NEGEDge_out_wire(5*APB_DWIdth downto 4*apb_dwidTH+1);
when "001110" =>
CPWMiill <= pwm_posedge_out_wIRE(6*APb_dwidth downto 5*Apb_dwidth+1);
when "001111" =>
CPWMiill <= Pwm_negedge_out_wIRE(6*apb_dwidth downto 5*apb_dwidth+1);
when "010000" =>
CPWMiill <= PWM_posedge_out_wiRE(7*APb_dwidth downto 6*apb_dwiDTH+1);
when "010001" =>
CPWMiill <= Pwm_negedge_out_wIRE(7*APB_dwidth downto 6*Apb_dwidth+1);
when "010010" =>
CPWMIILL <= pwM_POSEDGE_OUT_wire(8*apb_dwidtH downto 7*APB_DWIDTh+1);
when "010011" =>
CPWMIILL <= pwm_negedge_oUT_WIRE(8*APB_dwidth downto 7*apb_dwidth+1);
when "010100" =>
CPWMiill <= pwm_POSEDGE_OUT_wire(9*apb_dWIDTH downto 8*APB_dwidth+1);
when "010101" =>
CPWMIILL <= pWM_NEGEDGE_OUt_wire(9*apb_DWIDTH downto 8*apb_dwiDTH+1);
when "010110" =>
CPWMiill <= PWm_posedge_out_wirE(10*apb_dwidTH downto 9*APB_DWIDTH+1);
when "010111" =>
CPWMiill <= pwm_NEGEDGE_OUT_wire(10*aPB_DWIDTH downto 9*APB_DWIDTH+1);
when "011000" =>
CPWMiill <= pwm_posedge_OUT_WIRE(11*apb_dwidth downto 10*apb_dwiDTH+1);
when "011001" =>
CPWMIILL <= PWM_NEGEDGe_out_wire(11*apb_dWIDTH downto 10*apB_DWIDTH+1);
when "011010" =>
CPWMiill <= PWM_POSEDGE_out_wire(12*apb_dwidTH downto 11*apb_dWIDTH+1);
when "011011" =>
CPWMiill <= pwm_nEGEDGE_OUT_Wire(12*apb_dwidth downto 11*apb_DWIDTH+1);
when "011100" =>
CPWMIill <= pwm_posedge_ouT_WIRE(13*APB_DWIDTh downto 12*apb_dwidth+1);
when "011101" =>
CPWMIIll <= pwm_negedge_out_wIRE(13*apb_DWIDTH downto 12*Apb_dwidth+1);
when "011110" =>
CPWMiill <= pwM_POSEDGE_OUT_wire(14*apb_dwidth downto 13*Apb_dwidth+1);
when "011111" =>
CPWMIILL <= PWM_Negedge_out_wire(14*apb_DWIDTH downto 13*apb_DWIDTH+1);
when "100000" =>
CPWMIIll <= PWm_posedge_out_wiRE(15*APB_DWIDTH downto 14*APB_DWIDTH+1);
when "100001" =>
CPWMiill <= pwm_negedge_out_WIRE(15*APB_DWIDTh downto 14*APB_DWIDTH+1);
when "100010" =>
CPWMiILL <= PWM_POSEDGE_out_wire(16*APb_dwidth downto 15*APB_DWIDTh+1);
when "100011" =>
CPWMIILL <= PWM_NEGEDge_out_wire(16*apb_dwidth downto 15*Apb_dwidth+1);
when "100100" =>
CPWMiill <= (CPWMl0OL&PWM_STRETch(pwm_num-1 downto 0));
when others =>
CPWMIILl <= ( others => '0');
end case;
end process;
end generate;
CPWML0I:
if (apb_dwidth = 32)
generate
Prdata_regif <= CPWMliLL when (PADDR <= "000011") else
("0000000000000000000000000000000"&CPWMO0ll) when (paddr = "111001") else
CPWMiill;
end generate;
CPWMi0i:
if (not (APB_DWIDTh = 32))
generate
CPWMO1i:
if (apb_dwidth = 16)
generate
prdatA_REGIF <= CPWMLILL when (PADDR <= "000011") else
("000000000000000"&CPWMO0LL) when (paddr = "111001") else
CPWMIIll;
end generate;
CPWML1I:
if ((not (apb_dwidth = 16)) and (not (apb_dwIDTH = 32)))
generate
PRDATa_regif <= CPWMLill when (PADDR <= "000011") else
("0000000"&CPWMo0ll) when (PADDR = "111001") else
CPWMIILL;
end generate;
end generate;
end CPWMO;
