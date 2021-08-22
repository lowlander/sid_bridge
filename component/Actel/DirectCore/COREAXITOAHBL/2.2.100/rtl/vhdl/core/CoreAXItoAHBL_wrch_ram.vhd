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
-- Notes: Asynchronous fifo implementation
--
-- *********************************************************************/
-- RAM module
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.std_logic_arith.all;
use     ieee.std_logic_unsigned.all;
use     ieee.std_logic_misc.all;


ENTITY CoreAXItoAHBL_wrch_ram IS
   GENERIC (
      ADDR_BIT                       :  integer := 32;    
      RD_DATA_BIT                    :  integer := 32;    
      AXI_WRSTB                      :  integer := 8;    --   AXI bus write strobe width
      WR_DATA_BIT                    :  integer := 64);    
   PORT (
      WCLK                    : IN std_logic;   
      RCLK                    : IN std_logic;   
      WAddr                   : IN std_logic_vector(4 - 1 DOWNTO 0);   
      RAddr                   : IN std_logic_vector(4 - 1 DOWNTO 0);   
      We1                     : IN std_logic;   
      Re1                     : IN std_logic;   
      Wfull                   : IN std_logic;   
      Rempty                  : IN std_logic;   
      Wdata                   : IN std_logic_vector((WR_DATA_BIT + AXI_WRSTB) - 1 DOWNTO 0);   
      Rdata                   : OUT std_logic_vector((WR_DATA_BIT + AXI_WRSTB) - 1 DOWNTO 0)); 
END ENTITY CoreAXItoAHBL_wrch_ram;

ARCHITECTURE translated OF CoreAXItoAHBL_wrch_ram IS
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
      
   CONSTANT RAM_DWIDTH             :  integer := (WR_DATA_BIT + AXI_WRSTB);    
   CONSTANT RAM_AWIDTH             :  integer := 4;    
   CONSTANT FDEPTH                 :  integer := 16;    

   TYPE xhdl_2 IS ARRAY (0 TO (FDEPTH - 1)) OF std_logic_vector(RAM_DWIDTH - 1 
   DOWNTO 0);

   CONSTANT  MEM_DATA_BIT          :  integer := 32;    
   SIGNAL mem1                     :  xhdl_2;   
   SIGNAL Rdata_xhdl1              :  std_logic_vector(RAM_DWIDTH - 1 DOWNTO 0)
   ;   

BEGIN
   Rdata <= Rdata_xhdl1;

   -------------------------------------------------------------------------------
   -- Memory-1 Write and Read logic
   -------------------------------------------------------------------------------
   
   PROCESS (WCLK)
   BEGIN
      IF (WCLK'EVENT AND WCLK = '1') THEN
         IF ((We1 = '1') AND (Wfull = '0')) THEN
            mem1(to_integer(WAddr)) <= Wdata(RAM_DWIDTH - 1 DOWNTO 0);    
         END IF;
      END IF;
   END PROCESS;

   PROCESS (RCLK)
   BEGIN
      IF (RCLK'EVENT AND RCLK = '1') THEN
         IF ((Re1 = '1') AND (Rempty = '0')) THEN
            Rdata_xhdl1(RAM_DWIDTH - 1 DOWNTO 0) <= mem1(to_integer(RAddr));    
         ELSE
            Rdata_xhdl1(RAM_DWIDTH - 1 DOWNTO 0) <= (OTHERS => 'X');    
         END IF;
      END IF;
   END PROCESS;

END ARCHITECTURE translated;
