-- ********************************************************************/
-- Actel Corporation Proprietary and Confidential
-- Copyright 2010 Actel Corporation.  All rights reserved.
--
-- ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
-- ACCORDANCE WITH THE ACTEL LICENSE AGREEMENT AND MUST BE APPROVED
-- IN ADVANCE IN WRITING.
--
-- Description:	
--
-- Revision Information:
-- Date			Description
-- ----			-----------------------------------------
-- 04AUG10		Production Release Version 1.0
--
-- SVN Revision Information:
-- SVN $Revision: $
-- SVN $Date: $
--
-- Resolved SARs
-- SAR      Date     Who   Description
--
-- Notes: 
--
-- *********************************************************************/
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.std_logic_arith.all;
use     ieee.std_logic_unsigned.all;
use     ieee.std_logic_misc.all;

ENTITY CoreAXItoAHBL_reset_syncXH IS
   PORT (
      ClockIn                 : IN std_logic;   
      RESETINn                : IN std_logic;   
      RESETOUTn               : OUT std_logic);   
END ENTITY CoreAXItoAHBL_reset_syncXH;
ARCHITECTURE translated OF CoreAXItoAHBL_reset_syncXH IS


   -------------------------------------------------------------------------------
   -- Register Declarations
   -------------------------------------------------------------------------------
   SIGNAL reset_sync_1             :  std_logic;   
   SIGNAL reset_sync_2             :  std_logic;   
   SIGNAL RESETOUTn_xhdl1          :  std_logic;   

BEGIN
   RESETOUTn <= RESETOUTn_xhdl1;

   -------------------------------------------------------------------------------
   -------------------------------------------------------------------------------
   
   reset_sync_logic : PROCESS (ClockIn, RESETINn)
   BEGIN
      IF (RESETINn = '0') THEN
         reset_sync_1 <= '0';    
         reset_sync_2 <= '0';    
      ELSIF (ClockIn'EVENT AND ClockIn = '1') THEN
         reset_sync_1 <= reset_sync_2;    
         reset_sync_2 <= '1';    
      END IF;
   END PROCESS reset_sync_logic;
   RESETOUTn_xhdl1 <= reset_sync_1 ;

END ARCHITECTURE translated;
