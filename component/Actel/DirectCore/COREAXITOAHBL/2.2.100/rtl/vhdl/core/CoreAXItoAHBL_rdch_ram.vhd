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
-- Notes: Read Channel Asynchronous fifo implementation
--
-- *********************************************************************/

-- RAM module
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.std_logic_arith.all;
use     ieee.std_logic_unsigned.all;
use     ieee.std_logic_misc.all;

ENTITY CoreAXItoAHBL_rdch_ram IS
   GENERIC (
      ADDR_BIT                       :  integer := 32;    
      WR_DATA_BIT                    :  integer := 32;    
      RD_DATA_BIT                    :  integer := 32;    
      RAM_AWIDTH                     :  integer := 5);    
   PORT (
      WCLK                    : IN std_logic;   
      RCLK                    : IN std_logic;   
      WAddr                   : IN std_logic_vector(RAM_AWIDTH - 1 DOWNTO 0);   
      RAddr                   : IN std_logic_vector(RAM_AWIDTH - 1 DOWNTO 0);   
      We1                     : IN std_logic;   
      Re1                     : IN std_logic;   
      Wfull                   : IN std_logic;   
      Rempty                  : IN std_logic;   
      Wdata                   : IN std_logic_vector(WR_DATA_BIT - 1 DOWNTO 0);  
      Wresp                   : IN std_logic_vector(1 DOWNTO 0);   
      Rdata                   : OUT std_logic_vector(RD_DATA_BIT - 1 DOWNTO 0); 
      Rresp                   : OUT std_logic_vector(1 DOWNTO 0));   
END ENTITY CoreAXItoAHBL_rdch_ram;

ARCHITECTURE translated OF CoreAXItoAHBL_rdch_ram IS
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

   CONSTANT  MEM_DATA_BIT          :  integer := 32;    
   CONSTANT  FDEPTH                :  integer := 32;    
   TYPE xhdl_3 IS ARRAY (0 TO (FDEPTH - 1)) OF std_logic_vector(MEM_DATA_BIT + 
   1 DOWNTO 0);



   SIGNAL Rdata_m                  :  std_logic_vector(RD_DATA_BIT + 1 DOWNTO 0)
   ;   
   SIGNAL mem1                     :  xhdl_3;   
   SIGNAL Rdata_xhdl1              :  std_logic_vector(RD_DATA_BIT - 1 DOWNTO 0)
   ;   
   SIGNAL Rresp_xhdl2              :  std_logic_vector(1 DOWNTO 0);   

BEGIN
   Rdata <= Rdata_xhdl1;
   Rresp <= Rresp_xhdl2;

   -------------------------------------------------------------------------------
   -- Memory-1 Write and Read logic
   -------------------------------------------------------------------------------
   
   PROCESS (WCLK)
   BEGIN
      IF (WCLK'EVENT AND WCLK = '1') THEN
         IF ((We1 = '1') AND (Wfull = '0')) THEN
            mem1(to_integer(WAddr)) <= Wresp(1 DOWNTO 0) & Wdata(31 DOWNTO 0);  
         END IF;
      END IF;
   END PROCESS;

   PROCESS (RCLK)
   BEGIN
      IF (RCLK'EVENT AND RCLK = '1') THEN
         IF (Re1 = '1') THEN
            Rdata_m(RD_DATA_BIT + 1 DOWNTO 0) <= mem1(to_integer(RAddr));    
         ELSE
            Rdata_m(RD_DATA_BIT + 1 DOWNTO 0) <= (OTHERS => 'X');    
         END IF;
      END IF;
   END PROCESS;
   Rdata_xhdl1(RD_DATA_BIT - 1 DOWNTO 0) <= Rdata_m(RD_DATA_BIT - 1 DOWNTO 0) 
   ;
   Rresp_xhdl2(1 DOWNTO 0) <= Rdata_m(RD_DATA_BIT + 1 DOWNTO RD_DATA_BIT) ;

END ARCHITECTURE translated;
