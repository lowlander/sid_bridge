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

-- Synchronous RAM - (synchronus write and synchronous read)

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.std_logic_arith.all;
use     ieee.std_logic_unsigned.all;
use     ieee.std_logic_misc.all;

ENTITY CoreAXItoAHBL_stroberam_XH IS
   PORT (
      WCLK                    : IN std_logic;   
      RCLK                    : IN std_logic;   
      WAddr                   : IN std_logic_vector(3 DOWNTO 0);   
      RAddr                   : IN std_logic_vector(3 DOWNTO 0);   
      We                      : IN std_logic;   
      Re                      : IN std_logic;   
      Wdata                   : IN std_logic_vector(9 DOWNTO 0);   
      Rdata                   : OUT std_logic_vector(9 DOWNTO 0));   
END ENTITY CoreAXItoAHBL_stroberam_XH;

ARCHITECTURE translated OF CoreAXItoAHBL_stroberam_XH IS
  FUNCTION to_integer (
      val      : std_logic_vector) RETURN integer IS

      CONSTANT vec      : std_logic_vector(val'high-val'low DOWNTO 0) := val;      
      VARIABLE rtn      : integer := 0;
   BEGIN
      FOR index IN vec'RANGE LOOP
         IF (vec(index) = '1') THEN
            rtn := rtn + (2**index);
         END IF;
      END LOOP;
      RETURN(rtn);
   END to_integer;


   CONSTANT  AWIDTH                :  integer := 4;    
   CONSTANT  DWIDTH                :  integer := 10;    
   --CONSTANT  RAMDEPTH              :  integer := to_integer('1' SLL AWIDTH);
   CONSTANT  RAMDEPTH              :  integer := 16;

   TYPE xhdl_2 IS ARRAY (0 TO (RAMDEPTH - 1)) OF std_logic_vector(DWIDTH - 
   1 DOWNTO 0);

    
   -- REgister declarations
   SIGNAL mem                      :  xhdl_2;   
   SIGNAL Rdata_xhdl1              :  std_logic_vector(DWIDTH - 1 DOWNTO 0);   

BEGIN
   Rdata <= Rdata_xhdl1;

   -------------------------------------------------------------
   -- RAM logic
   -------------------------------------------------------------
   
   PROCESS (RCLK)
   BEGIN
      IF (RCLK'EVENT AND RCLK = '1') THEN
         IF (Re = '1') THEN
            Rdata_xhdl1 <= mem(to_integer(RAddr));    
         ELSE
            Rdata_xhdl1 <= (others => '0');
            Rdata_xhdl1 <= "XXXXXXXXXX";    
         END IF;
      END IF;
   END PROCESS;

   PROCESS (WCLK)
   BEGIN
      IF (WCLK'EVENT AND WCLK = '1') THEN
         IF (We = '1') THEN
            mem(to_integer(WAddr)) <= Wdata;    
         END IF;
      END IF;
   END PROCESS;

END ARCHITECTURE translated;
