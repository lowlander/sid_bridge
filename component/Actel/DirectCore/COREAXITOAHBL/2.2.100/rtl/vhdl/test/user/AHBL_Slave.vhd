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
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.xhdl_std_logic.all;
use work.xhdl_misc.all;
use work.coreparameters.all;

ENTITY AHBL_Slave IS
   GENERIC (
      -----------------------------------------------------
      -- Global parameters
      -----------------------------------------------------
      AHB_AWIDTH                     :  integer := 32;    
      AHB_DWIDTH                     :  integer := 32);    
   PORT (
-----------------------------------------------------
-- Input-Output Ports
-----------------------------------------------------
-- Inputs on the AHBL interface

      HCLK                    : IN std_logic;   
      HSEL                    : IN std_logic;   
      HADDR                   : IN std_logic_vector(AHB_AWIDTH - 1 DOWNTO 0);   
      HWRITE                  : IN std_logic;   
      HREADY_slave            : IN std_logic;   
      HTRANS                  : IN std_logic_vector(1 DOWNTO 0);   
      HSIZE                   : IN std_logic_vector(2 DOWNTO 0);   
      HWDATA                  : IN std_logic_vector(AHB_DWIDTH - 1 DOWNTO 0);   
      HBURST                  : IN std_logic_vector(2 DOWNTO 0);   
      HMASTLOCK               : IN std_logic;   
      -- Outputs on the AHBL Interface

      HREADYOUT_slave         : OUT std_logic;   
      HRESP                   : OUT std_logic_vector(1 DOWNTO 0);   
      HRDATA                  : OUT std_logic_vector(AHB_DWIDTH - 1 DOWNTO 0)); 
END ENTITY AHBL_Slave;

ARCHITECTURE translated OF AHBL_Slave IS
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

   CONSTANT xhdl_timescale         : time := 1 ns;
   CONSTANT  CH_DEPTH              :  integer := 256;    
  CONSTANT  ITER_COUNT            :  integer := 1;
   TYPE xhdl_4 IS ARRAY (0 TO CH_DEPTH - 1) OF std_logic_vector(7 DOWNTO 0);

   -------------------------------------------------------------------------------
  --PROCEDURE dut_reset IS
  --BEGIN
  --   nreset_xhdl14 := TRANSPORT '1' AFTER 2 ns;    
  --END PROCEDURE dut_reset;


   SIGNAL haddr_r                  :  std_logic_vector(AHB_AWIDTH - 1 DOWNTO 0)
   ;   
   SIGNAL haddr_r0                 :  std_logic_vector(AHB_AWIDTH - 1 DOWNTO 0)
   ;   
   SIGNAL hsize_r                  :  std_logic_vector(2 DOWNTO 0);   
   SIGNAL hreadyout_r              :  std_logic;   
   SIGNAL wr_actual_mem            :  xhdl_4;   
   SIGNAL rd_golden_mem            :  xhdl_4;   
   SIGNAL haddr_hsize              :  std_logic_vector(AHB_AWIDTH - 1 DOWNTO 0)
   ;   
   SIGNAL hready_custom            :  std_logic;   
   SIGNAL ahb_wr_addr              :  std_logic_vector(7 DOWNTO 0);   
   SIGNAL nreset                   :  std_logic;   
   SIGNAL start_ahb_read_task      :  boolean;   
   SIGNAL htrans_xhdl5             :  std_logic_vector(1 DOWNTO 0);   
   SIGNAL haddr_xhdl6              :  std_logic_vector(31 DOWNTO 0);   
   SIGNAL hburst_xhdl7             :  std_logic_vector(4 DOWNTO 0);   
   SIGNAL hwrite_xhdl8             :  std_logic;   
   SIGNAL hrdata_xhdl9             :  std_logic_vector(AHB_DWIDTH - 1 DOWNTO 0)
   ;   
   SIGNAL rd_addr_r                :  std_logic_vector(7 DOWNTO 0);   
   SIGNAL rd_size_r                :  std_logic_vector(2 DOWNTO 0);   
   SIGNAL rd_trans_r               :  std_logic_vector(1 DOWNTO 0);   
   SIGNAL rd_write_r               :  std_logic;   
   SIGNAL HREADYOUT_slave_xhdl1               :  std_logic;   
   SIGNAL cnt                      :  integer;   
   SIGNAL HRESP_xhdl2              :  std_logic_vector(1 DOWNTO 0);   
   SIGNAL HRDATA_xhdl3             :  std_logic_vector(AHB_DWIDTH - 1 DOWNTO 0)
   ;   

BEGIN
   HREADYOUT_slave <= HREADYOUT_slave_xhdl1;
   HRESP <= HRESP_xhdl2;
   HRDATA <= HRDATA_xhdl3;

   -----------------------------------------------------------------------------
   -- Initial value declarations
   -----------------------------------------------------------------------------
   
   PROCESS IS
      VARIABLE xhdl_initial : BOOLEAN := TRUE;
      VARIABLE HRESP_xhdl2_xhdl10  : std_logic_vector(1 DOWNTO 0);
      VARIABLE HRDATA_xhdl3_xhdl11  : std_logic_vector(AHB_DWIDTH - 1 DOWNTO 0)
      ;
      VARIABLE HREADYOUT_slave_xhdl1_xhdl12  : std_logic;
      VARIABLE cnt_xhdl19  : integer;
   BEGIN
   --   IF (xhdl_initial) THEN
     WAIT UNTIL (HCLK'EVENT AND HCLK = '1');
         cnt_xhdl19 := 0;
         WHILE (cnt_xhdl19 < ITER_COUNT) LOOP


         HRESP_xhdl2_xhdl10 := "00";    
         HRDATA_xhdl3_xhdl11 := (OTHERS => '0');    
         HREADYOUT_slave_xhdl1_xhdl12 := '1';    
         --cnt_xhdl13 := 0;    
         HRESP_xhdl2 <= HRESP_xhdl2_xhdl10;
         --HRDATA_xhdl3 <= HRDATA_xhdl3_xhdl11;
         HRDATA_xhdl3 <= X"AAAA5555";
         HREADYOUT_slave_xhdl1 <= HREADYOUT_slave_xhdl1_xhdl12;
         cnt_xhdl19 := cnt_xhdl19 + 1;
         xhdl_initial := FALSE;

         END LOOP;
    --  ELSE
    --    WAIT;
    --  END IF;
   END PROCESS;

   PROCESS (HCLK)
      VARIABLE nreset_xhdl14  : std_logic;
   BEGIN
      IF (HCLK'EVENT AND HCLK = '1') THEN
         haddr_r <= HADDR;    
         haddr_r0 <= haddr_r;    
         hsize_r <= HSIZE;    
         hreadyout_r <= HREADY_slave;    
      END IF;
      nreset <= nreset_xhdl14;
   END PROCESS;
   ahb_wr_addr(7 DOWNTO 0) <= haddr_r(7 DOWNTO 0) ;
   hready_custom <= HREADY_slave AND hreadyout_r ;
   haddr_hsize <= haddr_r ;

   PROCESS (HCLK)
      VARIABLE wr_actual_mem_xhdl15  : xhdl_4;
   BEGIN
      IF (HCLK'EVENT AND HCLK = '1') THEN
         IF ((((hready_custom) AND (HREADY_slave)) AND HWRITE) = '1') THEN
            CASE hsize_r(1 DOWNTO 0) IS
               WHEN "10" =>
                        wr_actual_mem_xhdl15(to_integer(ahb_wr_addr)) := 
                        HWDATA(7 DOWNTO 0);    
                        wr_actual_mem_xhdl15(to_integer(ahb_wr_addr + 
                        "00000001")) := HWDATA(15 DOWNTO 8);    
                        wr_actual_mem_xhdl15(to_integer(ahb_wr_addr + 
                        "00000010")) := HWDATA(23 DOWNTO 16);    
                        wr_actual_mem_xhdl15(to_integer(ahb_wr_addr + 
                        "00000011")) := HWDATA(31 DOWNTO 24);    
               WHEN "01" =>
                        IF (haddr_hsize(1 DOWNTO 0) = "00") THEN
                           wr_actual_mem_xhdl15(to_integer(ahb_wr_addr)) := 
                           HWDATA(7 DOWNTO 0);    
                           wr_actual_mem_xhdl15(to_integer(ahb_wr_addr + 
                           "00000001")) := HWDATA(15 DOWNTO 8);    
                        ELSE
                           IF (haddr_hsize(1 DOWNTO 0) = "10") THEN
                              wr_actual_mem_xhdl15(to_integer(ahb_wr_addr)) := 
                              HWDATA(23 DOWNTO 16);    
                              wr_actual_mem_xhdl15(to_integer(ahb_wr_addr + 
                              "00000001")) := HWDATA(31 DOWNTO 24);    
                           END IF;
                        END IF;
               WHEN "00" =>
                        IF (haddr_hsize(1 DOWNTO 0) = "00") THEN
                           wr_actual_mem_xhdl15(to_integer(ahb_wr_addr)) := 
                           HWDATA(7 DOWNTO 0);    
                        ELSE
                           IF (haddr_hsize(1 DOWNTO 0) = "01") THEN
                              wr_actual_mem_xhdl15(to_integer(ahb_wr_addr)) := 
                              HWDATA(15 DOWNTO 8);    
                           ELSE
                              IF (haddr_hsize(1 DOWNTO 0) = "10") THEN
                                 wr_actual_mem_xhdl15(to_integer(ahb_wr_addr)) 
                                 := HWDATA(23 DOWNTO 16);    
                              ELSE
                                 IF (haddr_hsize(1 DOWNTO 0) = "11") THEN
                                    wr_actual_mem_xhdl15(to_integer(ahb_wr_addr)
                                    ) := HWDATA(31 DOWNTO 24);    
                                 END IF;
                              END IF;
                           END IF;
                        END IF;
               WHEN OTHERS =>
                        NULL;
               
            END CASE;
         END IF;
      END IF;
      wr_actual_mem <= wr_actual_mem_xhdl15;
   END PROCESS;

   PROCESS (HCLK)
   BEGIN
      IF (HCLK'EVENT AND HCLK = '1') THEN
         IF (HREADY_slave = '1') THEN
            rd_addr_r <= HADDR(7 DOWNTO 0);    
         END IF;
         rd_addr_r <= haddr_r(7 DOWNTO 0);
         
         rd_size_r <= HSIZE;    
         rd_trans_r <= HTRANS;    
         rd_write_r <= HWRITE;    
         --cnt <= cnt + 1;    
      END IF;
   END PROCESS;

  PROCESS (HCLK)
  BEGIN
     IF (HCLK'EVENT AND HCLK = '1') THEN
        IF ((HWRITE = '0') AND (HREADY_slave = '1')) THEN
--           HRDATA_xhdl3 <= X"AAAA5555";    
--           IF (cnt = 9) THEN
--              HRESP_xhdl2 <= "01";    
--           ELSE
              HRESP_xhdl2 <= "00";    
--           END IF;
        END IF;
     END IF;
  END PROCESS;

   PROCESS (HCLK)
   BEGIN
      IF (HCLK'EVENT AND HCLK = '1') THEN
         IF ((HWRITE = '0') AND (HREADY_slave = '1')) THEN
            IF (HTRANS(1) = '1') THEN
               CASE rd_size_r(1 DOWNTO 0) IS
                  WHEN "10" =>
                           rd_golden_mem(to_integer(rd_addr_r)) <= 
                           HRDATA_xhdl3(7 DOWNTO 0);    
                           rd_golden_mem(to_integer(rd_addr_r + "00000001")) <= 
                           HRDATA_xhdl3(15 DOWNTO 8);    
                           rd_golden_mem(to_integer(rd_addr_r + "00000010")) <= 
                           HRDATA_xhdl3(23 DOWNTO 16);    
                           rd_golden_mem(to_integer(rd_addr_r + "00000011")) <= 
                           HRDATA_xhdl3(31 DOWNTO 24);    
                  WHEN "01" =>
                           IF (rd_addr_r(1 DOWNTO 0) = "00") THEN
                              rd_golden_mem(to_integer(rd_addr_r)) <= 
                              HRDATA_xhdl3(7 DOWNTO 0);    
                              rd_golden_mem(to_integer(rd_addr_r + "00000001")) 
                              <= HRDATA_xhdl3(15 DOWNTO 8);    
                           ELSE
                              IF (rd_addr_r(1 DOWNTO 0) = "10") THEN
                                 rd_golden_mem(to_integer(rd_addr_r)) <= 
                                 HRDATA_xhdl3(23 DOWNTO 16);    
                                 rd_golden_mem(to_integer(rd_addr_r + 
                                 "00000001")) <= HRDATA_xhdl3(31 DOWNTO 24);    
                              END IF;
                           END IF;
                  WHEN "00" =>
                           IF (rd_addr_r(1 DOWNTO 0) = "00") THEN
                              rd_golden_mem(to_integer(rd_addr_r)) <= 
                              HRDATA_xhdl3(7 DOWNTO 0);    
                           ELSE
                              IF (rd_addr_r(1 DOWNTO 0) = "01") THEN
                                 rd_golden_mem(to_integer(rd_addr_r)) <= 
                                 HRDATA_xhdl3(15 DOWNTO 8);    
                              ELSE
                                 IF (rd_addr_r(1 DOWNTO 0) = "10") THEN
                                    rd_golden_mem(to_integer(rd_addr_r)) <= 
                                    HRDATA_xhdl3(23 DOWNTO 16);    
                                 ELSE
                                    IF (rd_addr_r(1 DOWNTO 0) = "11") THEN
                                       rd_golden_mem(to_integer(rd_addr_r)) <= 
                                       HRDATA_xhdl3(31 DOWNTO 24);    
                                    END IF;
                                 END IF;
                              END IF;
                           END IF;
                  WHEN OTHERS =>
                           NULL;
                  
               END CASE;
            END IF;
         END IF;
      END IF;
   END PROCESS;

END ARCHITECTURE translated;
