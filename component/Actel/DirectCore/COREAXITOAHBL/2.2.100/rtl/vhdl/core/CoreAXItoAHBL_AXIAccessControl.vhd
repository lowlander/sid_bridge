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

ENTITY CoreAXItoAHBL_AXIAccessControl IS
   GENERIC (
      -----------------------------------------------------
      -- Global parameters
      -----------------------------------------------------
      AHB_AWIDTH                     :  integer := 32;    
      AHB_DWIDTH                     :  integer := 32;    
      AXI_AWIDTH                     :  integer := 32;    
      AXI_DWIDTH                     :  integer := 64;    
      CLOCKS_ASYNC                   :  integer := 1;    
      CUST_WR_DWIDTH                 :  integer := 64 + 8);    
   PORT (
      -----------------------------------------------------
-- Input-Output Ports
-----------------------------------------------------
-- Inputs on AXI Interface

      ACLK                    : IN std_logic;   
      ARESETn                 : IN std_logic;   
      AWID                    : IN std_logic_vector(3 DOWNTO 0);   
      AWADDR                  : IN std_logic_vector(AXI_AWIDTH - 1 DOWNTO 0);   
      AWLEN                   : IN std_logic_vector(3 DOWNTO 0);   
      AWSIZE                  : IN std_logic_vector(2 DOWNTO 0);   
      AWBURST                 : IN std_logic_vector(1 DOWNTO 0);   
      AWLOCK                  : IN std_logic_vector(1 DOWNTO 0);   
      AWVALID                 : IN std_logic;   
      -- Outputs on AXI Interface

      AWREADY                 : OUT std_logic;   
      WID                     : IN std_logic_vector(3 DOWNTO 0);   
      WDATA                   : IN std_logic_vector(AXI_DWIDTH - 1 DOWNTO 0);   
      WSTRB                   : IN std_logic_vector((AXI_DWIDTH/8) - 1 DOWNTO 0);   
      WLAST                   : IN std_logic;   
      WVALID                  : IN std_logic;   
      WREADY                  : OUT std_logic;   
      BREADY                  : IN std_logic;   
      BID                     : OUT std_logic_vector(3 DOWNTO 0);   
      BRESP                   : OUT std_logic_vector(1 DOWNTO 0);   
      BVALID                  : OUT std_logic;   
      ARID                    : IN std_logic_vector(3 DOWNTO 0);   
      ARADDR                  : IN std_logic_vector(AXI_AWIDTH - 1 DOWNTO 0);   
      ARLEN                   : IN std_logic_vector(3 DOWNTO 0);   
      ARSIZE                  : IN std_logic_vector(2 DOWNTO 0);   
      ARBURST                 : IN std_logic_vector(1 DOWNTO 0);   
      ARLOCK                  : IN std_logic_vector(1 DOWNTO 0);   
      ARVALID                 : IN std_logic;   
      ARREADY                 : OUT std_logic;   
      RREADY                  : IN std_logic;   
      RID                     : OUT std_logic_vector(3 DOWNTO 0);   
      RDATA                   : OUT std_logic_vector(AXI_DWIDTH - 1 DOWNTO 0);  
      RRESP                   : OUT std_logic_vector(1 DOWNTO 0);   
      RLAST                   : OUT std_logic;   
      RVALID                  : OUT std_logic;   
      ahb2axi_ahb_read_done_syn: IN std_logic;   --  indicates that AHB read transactions are over
      rdch2axi_fifo_rd_data1   : IN std_logic_vector(AHB_DWIDTH - 1 DOWNTO 0);   -- SAR 58944  read channel fifo read data
      rdch2axi_rd_resp_data   : IN std_logic_vector(1 DOWNTO 0);   --  read channel AXI read response data
      h_send_ahb_resp_en_syn  : IN std_logic;   --  synchronised AHB response enable signal
      hresp_err_count         : IN std_logic_vector(4 DOWNTO 0);   --  counts number of AHB errors from slave
      -- Outputs to Write Channel FIFO

      axi2wrchfifo_wrdata     : OUT std_logic_vector(CUST_WR_DWIDTH - 1 DOWNTO 0);   --  Write channel fifo write data
      axi2wrchfifo_wr_en      : OUT std_logic;   --  Write channel fifo write enable
      valid_axicmd            : OUT std_logic;   --  axi valid command start
      -- Outputs to AXI to AHB Synchronizer

      axi2xhsync_awlatch      : OUT std_logic;   --  control pulse to latch write address channel in AHB domain
      axi2xhsync_arlatch      : OUT std_logic;   --  control pulse to latch read address channel in AHB domain
      axi2ahb_wr_fifo_done    : OUT std_logic;   --  indicates AXI write channel fifo write operation done
      -- Outputs to AHB Access Control

      axi2ahb_WID             : OUT std_logic_vector(3 DOWNTO 0);   
      axi2ahb_AWID            : OUT std_logic_vector(3 DOWNTO 0);   
      axi2ahb_AWADDR          : OUT std_logic_vector(AXI_AWIDTH - 1 DOWNTO 0);  
      axi2ahb_AWLEN           : OUT std_logic_vector(3 DOWNTO 0);   
      axi2ahb_AWSIZE          : OUT std_logic_vector(2 DOWNTO 0);   
      axi2ahb_AWBURST         : OUT std_logic_vector(1 DOWNTO 0);   
      axi2ahb_AWLOCK          : OUT std_logic_vector(1 DOWNTO 0);   
      -- Outputs to Write Strobe RAM

      wrstb_wr_addr           : OUT std_logic_vector(4 DOWNTO 0);   --  write strobe fifo write address
      wrstb_wr_data           : OUT std_logic_vector(9 DOWNTO 0);   --  write strobe fifo write data - strobe information
      wrstb_fifo_wren         : OUT std_logic;   --  write strobe fifo write enable
      -- Outputs to Read Channel FIFO

      axi2rdch_fifo_rd_en     : OUT std_logic;   --  read channel fifo read enable
      UNALIGNED_ADDR_OUT      : OUT std_logic);   
END ENTITY CoreAXItoAHBL_AXIAccessControl;

ARCHITECTURE translated OF CoreAXItoAHBL_AXIAccessControl IS
   FUNCTION to_stdlogic (
      val      : IN boolean) RETURN std_logic IS
   BEGIN
      IF (val) THEN
         RETURN('1');
      ELSE
         RETURN('0');
      END IF;
   END to_stdlogic;
   
   FUNCTION conv_std_logic (
      val      : IN boolean) RETURN std_logic IS
   BEGIN
      RETURN(to_stdlogic(val));
   END conv_std_logic;
   
   FUNCTION and_br (
      val : std_logic_vector) RETURN std_logic IS

      VARIABLE rtn : std_logic := '1';
   BEGIN
      FOR index IN val'RANGE LOOP
         rtn := rtn AND val(index);
      END LOOP;
      RETURN(rtn);
   END and_br;
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
 FUNCTION or_br (
      val : std_logic_vector) RETURN std_logic IS
   
      VARIABLE rtn : std_logic := '0';
   BEGIN
      FOR index IN val'RANGE LOOP
         rtn := rtn OR val(index);
      END LOOP;
      RETURN(rtn);
   END or_br;



   CONSTANT  AXI_WRSTB             :  integer := AXI_DWIDTH / 8;    
   CONSTANT  RESPOK_C              :  std_logic_vector(1 DOWNTO 0) := "00";    --  response OKAY from AXI
   CONSTANT  RESPERR_C             :  std_logic_vector(1 DOWNTO 0) := "10";    --  response ERROR from AXI
   -- Main State machine variables
   CONSTANT  IDLE                  :  std_logic_vector(3 DOWNTO 0) := "0000";   
   CONSTANT  W_LATCH_ADDR          :  std_logic_vector(3 DOWNTO 0) := "0001";   
   CONSTANT  W_WR_DATA             :  std_logic_vector(3 DOWNTO 0) := "0010";   
   CONSTANT  W_WAIT4_WR_RESP       :  std_logic_vector(3 DOWNTO 0) := "0011";   
   CONSTANT  W_SEND_WR_RESP        :  std_logic_vector(3 DOWNTO 0) := "0100";   
   CONSTANT  R_LATCH_ADDR          :  std_logic_vector(3 DOWNTO 0) := "0101";   
   CONSTANT  R_WAIT4_AHBRD         :  std_logic_vector(3 DOWNTO 0) := "0110";   
   CONSTANT  R_RD_DATA             :  std_logic_vector(3 DOWNTO 0) := "0111";   
   CONSTANT  R_RD_FIRST_DATA       :  std_logic_vector(3 DOWNTO 0) := "1000";   
   CONSTANT  R_SEND_RLAST          :  std_logic_vector(3 DOWNTO 0) := "1001";   
   -- state machine variables for write strobe  
   CONSTANT  START                 :  std_logic_vector(1 DOWNTO 0) := "00";    
   CONSTANT  WR_S0                 :  std_logic_vector(1 DOWNTO 0) := "01";    
   CONSTANT  COUNT                 :  std_logic_vector(1 DOWNTO 0) := "10";    
   CONSTANT  WR_S1                 :  std_logic_vector(1 DOWNTO 0) := "11";    
   -------------------------------------------------------------------------------
   -- Register Declarations
   -------------------------------------------------------------------------------
   SIGNAL WREADY_d0                :  std_logic;   
   SIGNAL WREADY_d1                :  std_logic;   --  09/08/11     -- 01a
   SIGNAL AWID_i                   :  std_logic_vector(3 DOWNTO 0);   
   SIGNAL AWADDR_i                 :  std_logic_vector(AXI_AWIDTH - 1 DOWNTO 0)
   ;   
   SIGNAL AWLEN_i                  :  std_logic_vector(3 DOWNTO 0);   
   SIGNAL AWSIZE_i                 :  std_logic_vector(2 DOWNTO 0);   
   SIGNAL AWBURST_i                :  std_logic_vector(1 DOWNTO 0);   
   SIGNAL AWLOCK_i                 :  std_logic_vector(1 DOWNTO 0);   
   SIGNAL AWVALID_i                :  std_logic;   
   SIGNAL WID_i                    :  std_logic_vector(3 DOWNTO 0);   
   SIGNAL WDATA_i                  :  std_logic_vector(AXI_DWIDTH - 1 DOWNTO 0)
   ;   
   SIGNAL WSTRB_i                  :  std_logic_vector((AXI_DWIDTH/8) - 1 DOWNTO 0); 
   SIGNAL WLAST_i                  :  std_logic;   
   SIGNAL WLAST_d0                 :  std_logic;   
   SIGNAL WLAST_d1                 :  std_logic;   
   SIGNAL WLAST_d2                 :  std_logic;   
   SIGNAL WVALID_i                 :  std_logic;   
   SIGNAL WVALID_d0                :  std_logic;   
   SIGNAL WVALID_d1                :  std_logic;   
   SIGNAL BREADY_i                 :  std_logic;   
   SIGNAL ARID_i                   :  std_logic_vector(3 DOWNTO 0);   
   SIGNAL ARADDR_i                 :  std_logic_vector(AXI_AWIDTH - 1 DOWNTO 0)
   ;   
   SIGNAL ARLEN_i                  :  std_logic_vector(3 DOWNTO 0);   
   SIGNAL ARSIZE_i                 :  std_logic_vector(2 DOWNTO 0);   
   SIGNAL ARBURST_i                :  std_logic_vector(1 DOWNTO 0);   
   SIGNAL ARLOCK_i                 :  std_logic_vector(1 DOWNTO 0);   
   SIGNAL ARVALID_i                :  std_logic;   
   SIGNAL RREADY_i                 :  std_logic;   
   SIGNAL AWID_r                   :  std_logic_vector(3 DOWNTO 0);   
   SIGNAL AWADDR_r                 :  std_logic_vector(AXI_AWIDTH - 1 DOWNTO 0)
   ;   
   SIGNAL AWLEN_r                  :  std_logic_vector(3 DOWNTO 0);   
   SIGNAL AWSIZE_r                 :  std_logic_vector(2 DOWNTO 0);   
   SIGNAL AWBURST_r                :  std_logic_vector(1 DOWNTO 0);   
   SIGNAL AWLOCK_r                 :  std_logic_vector(1 DOWNTO 0);   
   SIGNAL ARID_r                   :  std_logic_vector(3 DOWNTO 0);   
   SIGNAL ARADDR_r                 :  std_logic_vector(AXI_AWIDTH - 1 DOWNTO 0)
   ;   
   SIGNAL ARLEN_r                  :  std_logic_vector(3 DOWNTO 0);   
   SIGNAL ARSIZE_r                 :  std_logic_vector(2 DOWNTO 0);   
   SIGNAL ARBURST_r                :  std_logic_vector(1 DOWNTO 0);   
   SIGNAL ARLOCK_r                 :  std_logic_vector(1 DOWNTO 0);   
   SIGNAL cstate_d0                :  std_logic_vector(3 DOWNTO 0);   
   SIGNAL cstate_d1                :  std_logic_vector(3 DOWNTO 0);   
   SIGNAL M_current_state          :  std_logic_vector(3 DOWNTO 0);   
   SIGNAL M_next_state             :  std_logic_vector(3 DOWNTO 0);   
   SIGNAL wr_addr_chan_set         :  std_logic;   --  latch write address channel
   SIGNAL rd_addr_chan_set         :  std_logic;   --  latch read address channel
   SIGNAL AWREADY_c                :  std_logic;   
   SIGNAL ARREADY_c                :  std_logic;   
   SIGNAL WREADY_c                 :  std_logic;   
   SIGNAL awlen_load               :  std_logic;   --  load total no of data transfers in write
   SIGNAL awlen_remains            :  std_logic_vector(4 DOWNTO 0);   --  Count remaining data transfer in write
   SIGNAL idle_state               :  std_logic;   
   SIGNAL axi_wr_rd_active         :  std_logic;   --  '1'- axi write active; '0'- axi read active
   SIGNAL send_wr_resp             :  std_logic;   
   SIGNAL wrch_fifo_wr_en          :  std_logic;   --  Write channel fifo write enable
   SIGNAL wr_strobe_d              :  std_logic_vector((AXI_DWIDTH/8) - 1 DOWNTO 0); 
   SIGNAL ahb_trans_count          :  std_logic_vector(5 DOWNTO 0);   --  count ahb transfers
   SIGNAL ahb_trans_count_1        :  std_logic_vector(5 DOWNTO 0);   --  count ahb transfers
   SIGNAL add_topup                :  std_logic_vector(1 DOWNTO 0);   
   SIGNAL W_curr_state             :  std_logic_vector(1 DOWNTO 0);   
   SIGNAL W_next_state             :  std_logic_vector(1 DOWNTO 0);   
   SIGNAL WSTRB_WDATA_r            :  std_logic_vector(CUST_WR_DWIDTH - 1 DOWNTO 0);   --  Write channel fifo write data
   SIGNAL bresp_count              :  std_logic_vector(4 DOWNTO 0);   --  counts number of AHB errors from slave
   SIGNAL axi2rdch_fifo_rd_en_r    :  std_logic;   --  read channel fifo read enable
   SIGNAL read_data                :  std_logic_vector(63 DOWNTO 0);   
   SIGNAL read_resp                :  std_logic_vector(3 DOWNTO 0);   
   SIGNAL axi_rd_resp              :  std_logic_vector(1 DOWNTO 0);   
   SIGNAL read_len_count_en        :  std_logic;   
   SIGNAL read_len_count_en_r      :  std_logic;   
   SIGNAL read_len_count           :  std_logic_vector(4 DOWNTO 0);   
   SIGNAL axi_rd_addr              :  std_logic_vector(2 DOWNTO 0);   
   SIGNAL axi_rd_addr_d0           :  std_logic_vector(2 DOWNTO 0);   
   SIGNAL axi_addr_incr            :  std_logic_vector(2 DOWNTO 0);   
   SIGNAL rdch2axi_fifo_rd_data_d0 :  std_logic_vector(AHB_DWIDTH - 1 DOWNTO 0);   --  read channel fifo read data
   SIGNAL wstrb_8_active_d0        :  std_logic;   --  write strobe enable set only when burst size=8
   SIGNAL wr_strobe_valid          :  std_logic;   --  write strobe valid   
   SIGNAL wr_strobe_fix            :  std_logic;   
   SIGNAL ahb_trans_count_en       :  std_logic;   --  ahb transfer counter enable
   SIGNAL ahb_trans_count_en_1     :  std_logic;   --  ahb transfer counter enable
   SIGNAL UNALIGNED_ADDR_OUT_int_wr:  std_logic;   
   SIGNAL UNALIGNED_ADDR_OUT_int_rd:  std_logic;   
   -------------------------------------------------------------------------------
   -- Wire Declarations
   -------------------------------------------------------------------------------
   SIGNAL wstrb_8_enable           :  std_logic;   --  write strobe enable when burst size = 8
   SIGNAL wstrb_4_enable           :  std_logic;   --  write strobe enable when burst size = 4
   SIGNAL wstrb_2_enable           :  std_logic;   --  write strobe enable when burst size = 2
   SIGNAL wstrb_1_enable           :  std_logic;   --  write strobe enable when burst size = 1
   SIGNAL wstrb_8_active           :  std_logic;   --  write strobe enable set only when burst size=8
   SIGNAL wstrb_4_active           :  std_logic;   --  write strobe enable set only when burst size=4
   SIGNAL wstrb_2_active           :  std_logic;   --  write strobe enable set only when burst size=2
   SIGNAL wstrb_1_active           :  std_logic;   --  write strobe enable set only when burst size=1
   SIGNAL custom_WVALID            :  std_logic;   
   SIGNAL custom_WREADY            :  std_logic;   
   SIGNAL arlen_custom             :  std_logic_vector(4 DOWNTO 0);   
   SIGNAL temp_xhdl30              :  std_logic_vector(3 DOWNTO 0);   
   SIGNAL temp_xhdl31              :  std_logic_vector(AXI_AWIDTH - 1 DOWNTO 0)
   ;   
   SIGNAL temp_xhdl32              :  std_logic_vector(3 DOWNTO 0);   
   SIGNAL temp_xhdl33              :  std_logic_vector(2 DOWNTO 0);   
   SIGNAL temp_xhdl34              :  std_logic_vector(1 DOWNTO 0);   
   SIGNAL temp_xhdl35              :  std_logic_vector(1 DOWNTO 0);   
   SIGNAL temp_xhdl36              :  std_logic_vector(3 DOWNTO 0);   
   SIGNAL temp_xhdl56              :  std_logic;   
   --  assign custom_WREADY = (AWLEN_r[3:0] <= 4'b0001) ? WREADY_d0 : WREADY;   // By AP on 08/08/11  -- temp_last change
   --  assign custom_WREADY = (AWLEN_r[3:0] <= 4'b0001) ? WREADY_d0 : WREADY_d0;     // Added by AP on 08/08/11  - 01a
   SIGNAL temp_xhdl57              :  std_logic;   --  09/08/11 - 01a - Added WREADY_d1
   SIGNAL temp_xhdl58              :  std_logic_vector(5 DOWNTO 0);   
   --wrstb_wr_data[5:0] <= (W_curr_state == WR_S0) ? ahb_trans_count_1 : ahb_trans_count[5:0] + add_topup[1:0];
   SIGNAL temp_xhdl59              :  std_logic_vector(5 DOWNTO 0);   
   SIGNAL temp_xhdl59_int          :  std_logic_vector(5 DOWNTO 0);   
   SIGNAL temp_xhdl60              :  std_logic_vector(5 DOWNTO 0);   
   SIGNAL AWREADY_xhdl1            :  std_logic;   
   SIGNAL WREADY_xhdl2             :  std_logic;   
   SIGNAL BID_xhdl3                :  std_logic_vector(3 DOWNTO 0);   
   SIGNAL BRESP_xhdl4              :  std_logic_vector(1 DOWNTO 0);   
   SIGNAL BVALID_xhdl5             :  std_logic;   
   SIGNAL ARREADY_xhdl6            :  std_logic;   
   SIGNAL RID_xhdl7                :  std_logic_vector(3 DOWNTO 0);   
   SIGNAL RDATA_xhdl8              :  std_logic_vector(AXI_DWIDTH - 1 DOWNTO 0)
   ;   
   SIGNAL RRESP_xhdl9              :  std_logic_vector(1 DOWNTO 0);   
   SIGNAL RLAST_xhdl10             :  std_logic;   
   SIGNAL RVALID_xhdl11            :  std_logic;   
   SIGNAL axi2wrchfifo_wrdata_xhdl12      :  std_logic_vector(CUST_WR_DWIDTH - 
   1 DOWNTO 0);   
   SIGNAL axi2wrchfifo_wr_en_xhdl13:  std_logic;   
   SIGNAL valid_axicmd_xhdl14      :  std_logic;   
   SIGNAL axi2xhsync_awlatch_xhdl15:  std_logic;   
   SIGNAL axi2xhsync_arlatch_xhdl16:  std_logic;   
   SIGNAL axi2ahb_wr_fifo_done_xhdl17     :  std_logic;   
   SIGNAL axi2ahb_WID_xhdl18       :  std_logic_vector(3 DOWNTO 0);   
   SIGNAL axi2ahb_AWID_xhdl19      :  std_logic_vector(3 DOWNTO 0);   
   SIGNAL axi2ahb_AWADDR_xhdl20    :  std_logic_vector(AXI_AWIDTH - 1 DOWNTO 0)
   ;   
   SIGNAL axi2ahb_AWLEN_xhdl21     :  std_logic_vector(3 DOWNTO 0);   
   SIGNAL axi2ahb_AWSIZE_xhdl22    :  std_logic_vector(2 DOWNTO 0);   
   SIGNAL axi2ahb_AWBURST_xhdl23   :  std_logic_vector(1 DOWNTO 0);   
   SIGNAL axi2ahb_AWLOCK_xhdl24    :  std_logic_vector(1 DOWNTO 0);   
   SIGNAL wrstb_wr_addr_xhdl25     :  std_logic_vector(4 DOWNTO 0);   
   SIGNAL wrstb_wr_data_xhdl26     :  std_logic_vector(9 DOWNTO 0);   
   SIGNAL wrstb_fifo_wren_xhdl27   :  std_logic;   
   SIGNAL axi2rdch_fifo_rd_en_xhdl28 :  std_logic;   
   SIGNAL UNALIGNED_ADDR_OUT_xhdl29  :  std_logic;   
   SIGNAL axi2rdch_fifo_rd_en_clr    :  std_logic;   -- SAR 58944 
   SIGNAL axi2rdch_fifo_rd_en_r_reg  :  std_logic;   -- SAR 58944 
   SIGNAL rdch2axi_fifo_rd_data_d    :  std_logic_vector(AHB_DWIDTH - 1 DOWNTO 0);
   SIGNAL rdch2axi_fifo_rd_data_int1 :  std_logic_vector(AHB_DWIDTH - 1 DOWNTO 0);
   SIGNAL rdch2axi_fifo_rd_data      :  std_logic_vector(AHB_DWIDTH - 1 DOWNTO 0);
   SIGNAL read_data_reg              :  std_logic_vector(63 DOWNTO 0);
   SIGNAL read_data_reg_en           :  std_logic;
   SIGNAL temp1                      :  std_logic;   --  read channel fifo read enable

BEGIN
   AWREADY <= AWREADY_xhdl1;
   WREADY <= WREADY_xhdl2;
   BID <= BID_xhdl3;
   BRESP <= BRESP_xhdl4;
   BVALID <= BVALID_xhdl5;
   ARREADY <= ARREADY_xhdl6;
   RID <= RID_xhdl7;
   RDATA <= RDATA_xhdl8;
   RRESP <= RRESP_xhdl9;
   RLAST <= RLAST_xhdl10;
   RVALID <= RVALID_xhdl11;
   axi2wrchfifo_wrdata <= axi2wrchfifo_wrdata_xhdl12;
   axi2wrchfifo_wr_en <= axi2wrchfifo_wr_en_xhdl13;
   valid_axicmd <= valid_axicmd_xhdl14;
   axi2xhsync_awlatch <= axi2xhsync_awlatch_xhdl15;
   axi2xhsync_arlatch <= axi2xhsync_arlatch_xhdl16;
   axi2ahb_wr_fifo_done <= axi2ahb_wr_fifo_done_xhdl17;
   axi2ahb_WID <= axi2ahb_WID_xhdl18;
   axi2ahb_AWID <= axi2ahb_AWID_xhdl19;
   axi2ahb_AWADDR <= axi2ahb_AWADDR_xhdl20;
   axi2ahb_AWLEN <= axi2ahb_AWLEN_xhdl21;
   axi2ahb_AWSIZE <= axi2ahb_AWSIZE_xhdl22;
   axi2ahb_AWBURST <= axi2ahb_AWBURST_xhdl23;
   axi2ahb_AWLOCK <= axi2ahb_AWLOCK_xhdl24;
   wrstb_wr_addr <= wrstb_wr_addr_xhdl25;
   wrstb_wr_data <= wrstb_wr_data_xhdl26;
   wrstb_fifo_wren <= wrstb_fifo_wren_xhdl27;
   axi2rdch_fifo_rd_en <= axi2rdch_fifo_rd_en_xhdl28;
   UNALIGNED_ADDR_OUT <= UNALIGNED_ADDR_OUT_xhdl29;
   -------------------------------------------------------------------------------
   -------------------------------------------------------------------------------
   axi2wrchfifo_wrdata_xhdl12 <= WSTRB_WDATA_r(CUST_WR_DWIDTH - 1 DOWNTO 0) ;
   axi2wrchfifo_wr_en_xhdl13 <= wrch_fifo_wr_en ;
   temp_xhdl30 <= AWID_r(3 DOWNTO 0) WHEN (axi_wr_rd_active) = '1' ELSE 
   ARID_r(3 DOWNTO 0);
   axi2ahb_AWID_xhdl19 <= temp_xhdl30 ;
   temp_xhdl31 <= AWADDR_r(AXI_AWIDTH - 1 DOWNTO 0) WHEN (axi_wr_rd_active) = 
   '1' ELSE ARADDR_r(AXI_AWIDTH - 1 DOWNTO 0);
   axi2ahb_AWADDR_xhdl20 <= temp_xhdl31 ;
   temp_xhdl32 <= AWLEN_r(3 DOWNTO 0) WHEN (axi_wr_rd_active) = '1' ELSE 
   ARLEN_r(3 DOWNTO 0);
   axi2ahb_AWLEN_xhdl21 <= temp_xhdl32 ;
   temp_xhdl33 <= AWSIZE_r(2 DOWNTO 0) WHEN (axi_wr_rd_active) = '1' ELSE 
   ARSIZE_r(2 DOWNTO 0);
   axi2ahb_AWSIZE_xhdl22 <= temp_xhdl33 ;
   temp_xhdl34 <= AWBURST_r(1 DOWNTO 0) WHEN (axi_wr_rd_active) = '1' ELSE 
   ARBURST_r(1 DOWNTO 0);
   axi2ahb_AWBURST_xhdl23 <= temp_xhdl34 ;
   temp_xhdl35 <= AWLOCK_r(1 DOWNTO 0) WHEN (axi_wr_rd_active) = '1' ELSE 
   ARLOCK_r(1 DOWNTO 0);
   axi2ahb_AWLOCK_xhdl24 <= temp_xhdl35 ;
   temp_xhdl36 <= WID_i(3 DOWNTO 0) WHEN (axi_wr_rd_active) = '1' ELSE "0000";
   axi2ahb_WID_xhdl18 <= temp_xhdl36 ;

   -------------------------------------------------------------------------------
   -- Register all input signals first
   -------------------------------------------------------------------------------
   
   PROCESS (ACLK, ARESETn)
   BEGIN
      IF (ARESETn = '0') THEN
         WSTRB_i <= '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0';    
      ELSIF (ACLK'EVENT AND ACLK = '1') THEN
         IF (WVALID = '1') THEN
            WSTRB_i <= WSTRB;    
         ELSE
            WSTRB_i <= '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0';    
         END IF;
      END IF;
   END PROCESS;

   register_axi_inputs : PROCESS (ACLK, ARESETn)
   BEGIN
      IF (ARESETn = '0') THEN
         AWID_i <= "0000";    
         AWADDR_i <= (OTHERS => '0');    
         AWLEN_i <= "0000";    
         AWSIZE_i <= "000";    
         AWBURST_i <= "00";    
         AWLOCK_i <= "00";    
         AWVALID_i <= '0';    
         WID_i <= "0000";    
         WDATA_i <= (OTHERS => '0');    
         WLAST_i <= '0';    
         WLAST_d0 <= '0';    
         WLAST_d1 <= '0';    
         WLAST_d2 <= '0';    
         WVALID_i <= '0';    
         WVALID_d0 <= '0';    
         WVALID_d1 <= '0';    
         BREADY_i <= '0';    
         ARID_i <= "0000";    
         ARADDR_i <= (OTHERS => '0');    
         ARLEN_i <= "0000";    
         ARSIZE_i <= "000";    
         ARBURST_i <= "00";    
         ARLOCK_i <= "00";    
         ARVALID_i <= '0';    
         RREADY_i <= '0';    
      ELSIF (ACLK'EVENT AND ACLK = '1') THEN
         AWID_i <= AWID;    
         AWADDR_i <= AWADDR;    
         AWLEN_i <= AWLEN;    
         AWSIZE_i <= AWSIZE;    
         AWBURST_i <= AWBURST;    
         AWLOCK_i <= AWLOCK;    
         AWVALID_i <= AWVALID;    
         WID_i <= WID;    
         WDATA_i <= WDATA;    
         WLAST_i <= WLAST;    
         WLAST_d0 <= WLAST_i;    
         WLAST_d1 <= WLAST_d0;    
         WLAST_d2 <= WLAST_d1;    
         WVALID_i <= WVALID;    
         WVALID_d0 <= WVALID_i;    
         WVALID_d1 <= WVALID_d0;    
         BREADY_i <= BREADY;    
         ARID_i <= ARID;    
         ARADDR_i <= ARADDR;    
         ARLEN_i <= ARLEN;    
         ARSIZE_i <= ARSIZE;    
         ARBURST_i <= ARBURST;    
         ARLOCK_i <= ARLOCK;    
         ARVALID_i <= ARVALID;    
         RREADY_i <= RREADY;    
      END IF;
   END PROCESS register_axi_inputs;

   -- SAR 58944 
   PROCESS (ACLK, ARESETn)
   BEGIN
      IF (ARESETn = '0') THEN
         rdch2axi_fifo_rd_data_d <= (OTHERS => '0');    
      ELSIF (ACLK'EVENT AND ACLK = '1') THEN
         rdch2axi_fifo_rd_data_d <= rdch2axi_fifo_rd_data1; 
      END IF;
   END PROCESS;

   -- SAR 58944 
   rdch2axi_fifo_rd_data_int1 <= rdch2axi_fifo_rd_data_d WHEN (axi2rdch_fifo_rd_en_r = '1' AND axi2rdch_fifo_rd_en_r_reg = '1') ELSE rdch2axi_fifo_rd_data1;
   rdch2axi_fifo_rd_data <= rdch2axi_fifo_rd_data1 WHEN (ARSIZE_r = "011") ELSE rdch2axi_fifo_rd_data_int1;
  
   -------------------------------------------------------------------------------
   -- Generate output signal to indicate whether incoming AXI address is aligned
   -- or unaligned.
   -------------------------------------------------------------------------------
   
   PROCESS (ACLK, ARESETn)
   BEGIN
      IF (ARESETn = '0') THEN
         UNALIGNED_ADDR_OUT_xhdl29 <= '0';    
      ELSIF (ACLK'EVENT AND ACLK = '1') THEN
         UNALIGNED_ADDR_OUT_xhdl29 <= UNALIGNED_ADDR_OUT_int_wr OR 
         UNALIGNED_ADDR_OUT_int_rd;    
      END IF;
   END PROCESS;

   PROCESS (ACLK, ARESETn)
   BEGIN
      IF (ARESETn = '0') THEN
         UNALIGNED_ADDR_OUT_int_wr <= '0';    
      ELSIF (ACLK'EVENT AND ACLK = '1') THEN
         IF (wr_addr_chan_set = '1') THEN
            CASE AWADDR(2 DOWNTO 0) IS
               WHEN "000" =>
                        IF (AWSIZE = "000" OR AWSIZE = "001" OR AWSIZE = "010" 
                        OR AWSIZE = "011") THEN
                           UNALIGNED_ADDR_OUT_int_wr <= '0';    
                        ELSE
                           UNALIGNED_ADDR_OUT_int_wr <= '1';    
                        END IF;
               WHEN "001" |
                    "011" |
                    "101" |
                    "111" =>
                        IF (AWSIZE /= "000") THEN
                           UNALIGNED_ADDR_OUT_int_wr <= '1';    
                        ELSE
                           UNALIGNED_ADDR_OUT_int_wr <= '0';    
                        END IF;
               WHEN "110" |
                    "010" =>
                        IF (AWSIZE = "000" OR AWSIZE = "001") THEN
                           UNALIGNED_ADDR_OUT_int_wr <= '0';    
                        ELSE
                           UNALIGNED_ADDR_OUT_int_wr <= '1';    
                        END IF;
               WHEN "100" =>
                        IF (AWSIZE = "000" OR AWSIZE = "001" OR AWSIZE = "010") 
                        THEN
                           UNALIGNED_ADDR_OUT_int_wr <= '0';    
                        ELSE
                           UNALIGNED_ADDR_OUT_int_wr <= '1';    
                        END IF;
               WHEN OTHERS  =>
                        UNALIGNED_ADDR_OUT_int_wr <= '0';    
               
            END CASE;
         ELSE
            UNALIGNED_ADDR_OUT_int_wr <= UNALIGNED_ADDR_OUT_int_wr;    
         END IF;
      END IF;
   END PROCESS;

   PROCESS (ACLK, ARESETn)
   BEGIN
      IF (ARESETn = '0') THEN
         UNALIGNED_ADDR_OUT_int_rd <= '0';    
      ELSIF (ACLK'EVENT AND ACLK = '1') THEN
         IF (rd_addr_chan_set = '1') THEN
            CASE ARADDR(2 DOWNTO 0) IS
               WHEN "000" =>
                        IF (ARSIZE = "000" OR ARSIZE = "001" OR ARSIZE = "010" 
                        OR ARSIZE = "011") THEN
                           UNALIGNED_ADDR_OUT_int_rd <= '0';    
                        ELSE
                           UNALIGNED_ADDR_OUT_int_rd <= '1';    
                        END IF;
               WHEN "001" |
                    "011" |
                    "101" |
                    "111" =>
                        IF (ARSIZE /= "000") THEN
                           UNALIGNED_ADDR_OUT_int_rd <= '1';    
                        ELSE
                           UNALIGNED_ADDR_OUT_int_rd <= '0';    
                        END IF;
               WHEN "110" |
                    "010" =>
                        IF (ARSIZE = "000" OR ARSIZE = "001") THEN
                           UNALIGNED_ADDR_OUT_int_rd <= '0';    
                        ELSE
                           UNALIGNED_ADDR_OUT_int_rd <= '1';    
                        END IF;
               WHEN "100" =>
                        IF (ARSIZE = "000" OR ARSIZE = "001" OR ARSIZE = "010") 
                        THEN
                           UNALIGNED_ADDR_OUT_int_rd <= '0';    
                        ELSE
                           UNALIGNED_ADDR_OUT_int_rd <= '1';    
                        END IF;
               WHEN OTHERS  =>
                        UNALIGNED_ADDR_OUT_int_rd <= '0';    
               
            END CASE;
         ELSE
            UNALIGNED_ADDR_OUT_int_rd <= UNALIGNED_ADDR_OUT_int_rd;    
         END IF;
      END IF;
   END PROCESS;

   -------------------------------------------------------------------------------
   -------------------------------------------------------------------------------
   -- Latch the write address channel
   -------------------------------------------------------------------------------
   
   latch_wr_addr_channel : PROCESS (ACLK, ARESETn)
   BEGIN
      IF (ARESETn = '0') THEN
         AWID_r <= "0000";    
         AWADDR_r <= (OTHERS => '0');    
         AWLEN_r <= "0000";    
         AWSIZE_r <= "000";    
         AWBURST_r <= "00";    
         AWLOCK_r <= "00";    
         ARID_r <= "0000";    
         ARADDR_r <= (OTHERS => '0');    
         ARLEN_r <= "0000";    
         ARSIZE_r <= "000";    
         ARBURST_r <= "00";    
         ARLOCK_r <= "00";    
      ELSIF (ACLK'EVENT AND ACLK = '1') THEN
         IF (wr_addr_chan_set = '1') THEN
            AWID_r <= AWID_i(3 DOWNTO 0);    --  Write Address ID
            AWADDR_r <= AWADDR_i(AXI_AWIDTH - 1 DOWNTO 0);    --  Write Address
            AWLEN_r <= AWLEN_i(3 DOWNTO 0);    --  Write Burst Length - number of data transfers
            AWSIZE_r <= AWSIZE_i(2 DOWNTO 0);    --  Write Burst Size - bytes in each transfer
            AWBURST_r <= AWBURST_i(1 DOWNTO 0);    --  Write Burst Type - incr or wrap
            AWLOCK_r <= AWLOCK_i(1 DOWNTO 0);    --  Write Lock Type 
         END IF;
         IF (rd_addr_chan_set = '1') THEN
            ARID_r <= ARID_i(3 DOWNTO 0);    --  Read Address ID
            ARADDR_r <= ARADDR_i(AXI_AWIDTH - 1 DOWNTO 0);    --  Read Address
            ARLEN_r <= ARLEN_i(3 DOWNTO 0);    --  Read Burst Length - number of data transfers
            ARSIZE_r <= ARSIZE_i(2 DOWNTO 0);    --  Read Burst Size - bytes in each transfer
            ARBURST_r <= ARBURST_i(1 DOWNTO 0);    --  Read Burst Type - incr or wrap
            ARLOCK_r <= ARLOCK_i(1 DOWNTO 0);    --  Read Lock Type 
         END IF;
      END IF;
   END PROCESS latch_wr_addr_channel;

   -------------------------------------------------------------------------------
   -- AXI OUTPUTS
   -------------------------------------------------------------------------------
   
   axi_reg_output : PROCESS (ACLK, ARESETn)
   BEGIN
      IF (ARESETn = '0') THEN
         AWREADY_xhdl1 <= '0';    
         WREADY_xhdl2 <= '0';    
         WREADY_d0 <= '0';    
         WREADY_d1 <= '0';    --  Added by AP on 09/08/11          -- 01a
         ARREADY_xhdl6 <= '0';    
         RID_xhdl7 <= "0000";    
         --RDATA_xhdl8 <= (OTHERS => '0');    -- SAR 58944
         RRESP_xhdl9 <= "00";    
         RLAST_xhdl10 <= '0';    
         RVALID_xhdl11 <= '0';    
      ELSIF (ACLK'EVENT AND ACLK = '1') THEN
         AWREADY_xhdl1 <= AWREADY_c;    
         WREADY_xhdl2 <= WREADY_c;    
         WREADY_d0 <= WREADY_xhdl2;    
         WREADY_d1 <= WREADY_d0;    --  Added by AP on 09/08/11        -- 01a
         ARREADY_xhdl6 <= ARREADY_c;    
         RID_xhdl7 <= ARID_r(3 DOWNTO 0);    
        -- RDATA_xhdl8 <= read_data(AXI_DWIDTH - 1 DOWNTO 0);    -- SAR 58944
         RRESP_xhdl9 <= axi_rd_resp(1 DOWNTO 0);    
         RLAST_xhdl10 <= CONV_STD_LOGIC(M_current_state = R_SEND_RLAST) AND read_data_reg_en;    
        -- RVALID_xhdl11 <= read_len_count_en_r OR CONV_STD_LOGIC(M_current_state = R_SEND_RLAST);    
	 IF (RVALID_xhdl11 = '1' AND RREADY = '1' AND RLAST_xhdl10 = '1') THEN -- SAR 58944 SAR#57249 added on 29th April
            RLAST_xhdl10  <= '0';    
            RVALID_xhdl11 <= '0'; 
         ELSIF (RVALID_xhdl11 = '1') THEN
            IF (RREADY = '1') THEN
              RLAST_xhdl10  <= '0';    
              RVALID_xhdl11 <= '0'; 
            ELSE 
              RVALID_xhdl11 <= RVALID_xhdl11; 
              IF (M_current_state = R_SEND_RLAST )THEN
                RLAST_xhdl10  <= '1';    
              ELSE 
                RLAST_xhdl10  <= '0';    
              END IF;
            END IF;
         ELSE 
           RVALID_xhdl11 <= (read_data_reg_en AND (CONV_STD_LOGIC(read_len_count <  arlen_custom))) OR  (read_data_reg_en);
         END IF;
       END IF;
   END PROCESS axi_reg_output;
 
   -- SAR 58944
   RDATA_xhdl8 <= read_data_reg WHEN (RVALID_xhdl11 = '1') ELSE (OTHERS => '0');

   PROCESS (ACLK, ARESETn)
   BEGIN
      IF (ARESETn = '0') THEN
         cstate_d0 <= "0000";    
         cstate_d1 <= "0000";    
         axi2rdch_fifo_rd_en_r <= '0';    
      ELSIF (ACLK'EVENT AND ACLK = '1') THEN
         cstate_d0 <= M_current_state;    
         cstate_d1 <= cstate_d0;    
         axi2rdch_fifo_rd_en_r <= axi2rdch_fifo_rd_en_xhdl28;    
      END IF;
   END PROCESS;

   -------------------------------------------------------------------------------
   -- Main state machine
   -------------------------------------------------------------------------------
   
   axi_mfsm_seq_logic : PROCESS (ACLK, ARESETn)
   BEGIN
      IF (ARESETn = '0') THEN
         M_current_state <= IDLE;    
      ELSIF (ACLK'EVENT AND ACLK = '1') THEN
         M_current_state <= M_next_state;    
      END IF;
   END PROCESS axi_mfsm_seq_logic;

   -------------------------------------------------------------------------------
   -- Combinational block for Main State Machine
   -------------------------------------------------------------------------------
   
   axi_mfsm_combo_logic : PROCESS (ARSIZE_r, rd_addr_chan_set, 
   ahb2axi_ahb_read_done_syn, 
   
   AWREADY_c,  
   ARVALID_i, awlen_remains,  
   M_current_state, BREADY_i, 
   axi2rdch_fifo_rd_en_xhdl28, RREADY_i,  WLAST_i,
   WLAST,     
   M_next_state,    
   read_len_count,    
   WREADY_c, AWVALID_i,    
   arlen_custom, 
   wr_addr_chan_set, ARREADY_c, 
   h_send_ahb_resp_en_syn, 
   axi_wr_rd_active,
   RVALID_xhdl11,
   RLAST_xhdl10,
   RREADY,
  axi2rdch_fifo_rd_en_clr )
      VARIABLE M_next_state_xhdl37  : std_logic_vector(3 DOWNTO 0);
      VARIABLE wr_addr_chan_set_xhdl38  : std_logic;
      VARIABLE rd_addr_chan_set_xhdl39  : std_logic;
      VARIABLE AWREADY_c_xhdl40  : std_logic;
      VARIABLE ARREADY_c_xhdl41  : std_logic;
      VARIABLE WREADY_c_xhdl42  : std_logic;
      VARIABLE awlen_load_xhdl43  : std_logic;
      VARIABLE idle_state_xhdl44  : std_logic;
      VARIABLE axi_wr_rd_active_xhdl45  : std_logic;
      VARIABLE send_wr_resp_xhdl46  : std_logic;
      VARIABLE axi2xhsync_awlatch_xhdl15_xhdl47  : std_logic;
      VARIABLE axi2xhsync_arlatch_xhdl16_xhdl48  : std_logic;
      VARIABLE axi2ahb_wr_fifo_done_xhdl17_xhdl49  : std_logic;
      VARIABLE axi2rdch_fifo_rd_en_xhdl28_xhdl50  : std_logic;
      VARIABLE read_len_count_en_xhdl51  : std_logic;
   BEGIN
      M_next_state_xhdl37 := M_current_state;    
      wr_addr_chan_set_xhdl38 := '0';    
      rd_addr_chan_set_xhdl39 := '0';    
      AWREADY_c_xhdl40 := '0';    
      ARREADY_c_xhdl41 := '0';    
      WREADY_c_xhdl42 := '0';    
      awlen_load_xhdl43 := '0';    
      idle_state_xhdl44 := '0';    
      axi_wr_rd_active_xhdl45 := '0';    
      send_wr_resp_xhdl46 := '0';    
      axi2xhsync_awlatch_xhdl15_xhdl47 := '0';    
      axi2xhsync_arlatch_xhdl16_xhdl48 := '0';    
      axi2ahb_wr_fifo_done_xhdl17_xhdl49 := '0';    
      axi2rdch_fifo_rd_en_xhdl28_xhdl50 := '0';    
      read_len_count_en_xhdl51 := '0';    
      CASE M_current_state IS
         -----------------------------------------
         -- Main FSM IDLE STATE
         -----------------------------------------
         
         WHEN IDLE =>
                  idle_state_xhdl44 := '1';    
                  AWREADY_c_xhdl40 := '0';    
                  WREADY_c_xhdl42 := '0';    
                  IF (ARVALID_i = '1') THEN
                     M_next_state_xhdl37 := R_LATCH_ADDR;    
                     rd_addr_chan_set_xhdl39 := '1';    
                     ARREADY_c_xhdl41 := '1';    
                  ELSE
                     IF (AWVALID_i = '1') THEN
                        M_next_state_xhdl37 := W_LATCH_ADDR;    
                        wr_addr_chan_set_xhdl38 := '1';    
                        AWREADY_c_xhdl40 := '1';    
                     END IF;
                  END IF;
         ---------------------------------------------
         -- Latch write addres channel signals
         ---------------------------------------------
         
         WHEN W_LATCH_ADDR =>
                  axi_wr_rd_active_xhdl45 := '1';    
                  idle_state_xhdl44 := '0';    
                  AWREADY_c_xhdl40 := '0';    
                  wr_addr_chan_set_xhdl38 := '0';    
                  M_next_state_xhdl37 := W_WR_DATA;    
                  awlen_load_xhdl43 := '1';    
                  WREADY_c_xhdl42 := '1';    
                  axi2xhsync_awlatch_xhdl15_xhdl47 := '1';    
         ---------------------------------------------
         -- Write data channel - write data into write channel fifo
         ---------------------------------------------
         
         WHEN W_WR_DATA =>
                  axi_wr_rd_active_xhdl45 := '1';    
                  awlen_load_xhdl43 := '0';    
                  axi2xhsync_awlatch_xhdl15_xhdl47 := '0';    
                  --        WREADY_c           = 1'b1;  // Original - Commented by AP on 08/08/11 to ensure
                  --        that wready is high only for desired length
                  -- Added on 08/08/11 by AP ------------------------------
                  
                  IF (WLAST = '1') THEN
                     -- AP on 08/08/11 - When last is asserted then the wready should go to zero.
                     
                     WREADY_c_xhdl42 := '0';    --  AP
                  -- AP
                  
                  ELSE
                     -- AP
                     
                     WREADY_c_xhdl42 := '1';    
                  END IF;
                  -- AP
                  -- ------------------------------------------------------           
                  --          if ((awlen_remains == 5'b00000) && (WLAST_d0 == 1'b1)) begin      // Commented by AP - 15/07/11
                  -- Added by AP - 15/07/11 - (To make to enter next state as this condition was not getting true.)
                  --if ((awlen_remains == 5'b00000) && (WLAST_i == 1'b1)) begin    // Commented by AP - 05/08/11 changed to below line
                  
                  IF ((awlen_remains = "00000") AND (WLAST_i = '1')) THEN
                     -- Modified by AP on 05/08/11 to support infinite DMA Rd/Wr // 15/02/13 - 1D CHANGE
                     
                     M_next_state_xhdl37 := W_WAIT4_WR_RESP;    
                     --WREADY_c             = 1'b0;      // 15/02/13 - 1D CHANGE
                     
                     axi2ahb_wr_fifo_done_xhdl17_xhdl49 := '1';    
                  END IF;
         ---------------------------------------------
         -- Write resp channel - wait for write response from AHB
         ---------------------------------------------
         
         WHEN W_WAIT4_WR_RESP =>
                  axi_wr_rd_active_xhdl45 := '1';    
                  axi2ahb_wr_fifo_done_xhdl17_xhdl49 := '0';    
                  WREADY_c_xhdl42 := '0';    
                  IF (h_send_ahb_resp_en_syn = '1') THEN
                     M_next_state_xhdl37 := W_SEND_WR_RESP;    
                     send_wr_resp_xhdl46 := '1';    
                  END IF;
         ---------------------------------------------
         -- Send Write response to AXI host
         ---------------------------------------------
         -- By AP - 14/07/11
         -- -----\/----- EXCLUDED -----\/-----
         --  -----\/----- EXCLUDED -----\/-----
         --       W_SEND_WR_RESP : 
         --         begin
         --           axi_wr_rd_active = 1'b1;
         --           send_wr_resp     = 1'b0;
         --           if (BREADY_i == 1'b1) begin
         --             if (ARVALID_i == 1'b1) begin
         --               M_next_state     = R_LATCH_ADDR;
         --               rd_addr_chan_set = 1'b1;
         --               ARREADY_c        = 1'b1;
         --             end
         --             else if (AWVALID_i == 1'b1) begin
         --               M_next_state     = W_LATCH_ADDR;
         --               wr_addr_chan_set = 1'b1;
         --               AWREADY_c        = 1'b1;
         --             end
         --             else begin
         --               M_next_state = IDLE;
         --             end
         --           end
         --         end
         --  -----/\----- EXCLUDED -----/\----- 
         -- Added by AP - 14/07/11   -- (This change is done to bring state machine back to Idle state after write is over.)
         
         WHEN W_SEND_WR_RESP =>
                  axi_wr_rd_active_xhdl45 := '1';    
                  send_wr_resp_xhdl46 := '0';    
                  IF (BREADY_i = '1') THEN
                     M_next_state_xhdl37 := IDLE;    
                  END IF;
         -------------------------------------
         ---------------------------------------------
         -- Latch read addres channel signals
         ---------------------------------------------
         
         WHEN R_LATCH_ADDR =>
                  axi_wr_rd_active_xhdl45 := '0';    
                  ARREADY_c_xhdl41 := '0';    
                  axi2xhsync_arlatch_xhdl16_xhdl48 := '1';    
                  M_next_state_xhdl37 := R_WAIT4_AHBRD;    
         WHEN R_WAIT4_AHBRD =>
                  axi_wr_rd_active_xhdl45 := '0';    
                  IF (ahb2axi_ahb_read_done_syn = '1') THEN
                     IF (ARSIZE_r(2 DOWNTO 0) = "011") THEN
                        M_next_state_xhdl37 := R_RD_FIRST_DATA;    
                        axi2rdch_fifo_rd_en_xhdl28_xhdl50 := '1';    
                     ELSE
                        M_next_state_xhdl37 := R_RD_DATA;    
                        axi2rdch_fifo_rd_en_xhdl28_xhdl50 := '1';    
                     END IF;
                  END IF;
         ---------------------------------------------
         -- Read first data channel - read data from read channel fifo in case of ARSIZE = 3 
         ---------------------------------------------
         
         WHEN R_RD_FIRST_DATA =>
                  axi_wr_rd_active_xhdl45 := '0';    
                  M_next_state_xhdl37 := R_RD_DATA;    
                  axi2rdch_fifo_rd_en_xhdl28_xhdl50 := '1';    
         ---------------------------------------------
         -- Read data channel - read data from read channel fifo
         ---------------------------------------------
         -- SAR#57249 - Modified this state to remove rready dependency
         WHEN R_RD_DATA =>
                  axi_wr_rd_active_xhdl45 := '0';    
                  --IF (RREADY_i = '1') THEN  -- SAR#57249
                     IF (read_len_count(4 DOWNTO 0) < arlen_custom(4 DOWNTO 0)) THEN
                        IF (ARSIZE_r(2 DOWNTO 0) = "011") THEN
                           read_len_count_en_xhdl51 := '1';    
                           IF (axi2rdch_fifo_rd_en_clr = '0') THEN -- SAR 58944
                               M_next_state_xhdl37 := R_RD_FIRST_DATA;    
                               axi2rdch_fifo_rd_en_xhdl28_xhdl50 := '1';    
		           END IF;
                        ELSE
                           read_len_count_en_xhdl51 := '1';    
                           IF (axi2rdch_fifo_rd_en_clr = '0') THEN  -- SAR 58944
                              M_next_state_xhdl37 := R_RD_DATA;    
                              axi2rdch_fifo_rd_en_xhdl28_xhdl50 := '1';    
		           END IF;
                        END IF;
                     ELSE  -- SAR 58944
                        read_len_count_en_xhdl51 := '0';    
                        M_next_state_xhdl37 := R_SEND_RLAST;    
                        IF (axi2rdch_fifo_rd_en_clr = '0') THEN  
                           axi2rdch_fifo_rd_en_xhdl28_xhdl50 := '1';    
                        END IF;
                     END IF;
                  --END IF;
         ---------------------------------------------
         -- Send Read last data to AXI host 
         ---------------------------------------------
         WHEN R_SEND_RLAST =>   -- SAR 58944
                  axi_wr_rd_active_xhdl45 := '0';    
                  IF (axi2rdch_fifo_rd_en_r_reg = '1') THEN
                     axi2rdch_fifo_rd_en_xhdl28_xhdl50 := '0';    
		  ELSIF (read_len_count = "00000") THEN
                     axi2rdch_fifo_rd_en_xhdl28_xhdl50 := '0';    
		  ELSE 
                     axi2rdch_fifo_rd_en_xhdl28_xhdl50 := '1';    
	          END IF;
		  IF(RREADY = '1' AND RVALID_xhdl11 = '1' AND RLAST_xhdl10 = '1') THEN
                    IF(AWVALID_i = '1') THEN
                        M_next_state_xhdl37 := W_LATCH_ADDR;    
                        wr_addr_chan_set_xhdl38 := '1';    
                        AWREADY_c_xhdl40 := '1';    
                     ELSIF (ARVALID_i = '1') THEN
                        M_next_state_xhdl37 := R_LATCH_ADDR;    
                        rd_addr_chan_set_xhdl39 := '1';    
                        ARREADY_c_xhdl41 := '1';    
                     ELSE
                        M_next_state_xhdl37 := IDLE;    
                     END IF;
                  END IF;
         WHEN          
         OTHERS  =>
                  M_next_state_xhdl37 := M_current_state;    
         
      END CASE;
      M_next_state <= M_next_state_xhdl37;
      wr_addr_chan_set <= wr_addr_chan_set_xhdl38;
      rd_addr_chan_set <= rd_addr_chan_set_xhdl39;
      AWREADY_c <= AWREADY_c_xhdl40;
      ARREADY_c <= ARREADY_c_xhdl41;
      WREADY_c <= WREADY_c_xhdl42;
      awlen_load <= awlen_load_xhdl43;
      idle_state <= idle_state_xhdl44;
      axi_wr_rd_active <= axi_wr_rd_active_xhdl45;
      send_wr_resp <= send_wr_resp_xhdl46;
      axi2xhsync_awlatch_xhdl15 <= axi2xhsync_awlatch_xhdl15_xhdl47;
      axi2xhsync_arlatch_xhdl16 <= axi2xhsync_arlatch_xhdl16_xhdl48;
      axi2ahb_wr_fifo_done_xhdl17 <= axi2ahb_wr_fifo_done_xhdl17_xhdl49;
      axi2rdch_fifo_rd_en_xhdl28 <= axi2rdch_fifo_rd_en_xhdl28_xhdl50;
      read_len_count_en <= read_len_count_en_xhdl51;
   END PROCESS axi_mfsm_combo_logic;
   arlen_custom(4 DOWNTO 0) <= "0" & ARLEN_r(3 DOWNTO 0) ;

   -------------------------------------------------------------------------------
   -- 
   -------------------------------------------------------------------------------
   
   PROCESS (ACLK, ARESETn)
   BEGIN
      IF (ARESETn = '0') THEN
         awlen_remains <= "00000";    
         WSTRB_WDATA_r <= (OTHERS => '0');    
         wrch_fifo_wr_en <= '0';    
         valid_axicmd_xhdl14 <= '0';    
      ELSIF (ACLK'EVENT AND ACLK = '1') THEN
         valid_axicmd_xhdl14 <= wr_addr_chan_set OR rd_addr_chan_set;    
         -- maintain ramining no of write transfers
         
         IF (idle_state = '1') THEN
            awlen_remains <= "00000";    
         ELSE
            IF (awlen_load = '1') THEN
               --        awlen_remains <= AWLEN_r[3:0] + 1'b1; // Commented by AP on 08/08/11
               
               awlen_remains <= "0" & AWLEN_r(3 DOWNTO 0);    --  By AP on 08/08/11
            -- Added by AP - 15/07/11 - (To avoid awlen_remains from underflowing - decrementing below 0.)
            
            ELSE
               IF (awlen_remains = "00000") THEN
                  awlen_remains <= awlen_remains;    
               -- -----------
               --else if (wdata_set & WREADY & WVALID_i) begin
               
               ELSE
                  IF ((WREADY_xhdl2 AND WVALID_i) = '1') THEN
                     awlen_remains <= awlen_remains - "00001";    
                  END IF;
               END IF;
            END IF;
         END IF;
         -- Send write data and strobe to write channel FIFO
         --      if ((WREADY_c == 1'b1) && (WVALID_i == 1'b1)) begin       // Commented by AP - 18/07/11
         -- Added below line by AP - 18/07/11 - (Change done to avoid writing redundant data from AXI master side)
         --      if ((WREADY == 1'b1 && wr_strobe_valid == 1'b1) && (WVALID_i == 1'b1)) begin      // Commented by AP on 08/08/11
         --      if ((WREADY == 1'b1 && wr_strobe_valid == 1'b1) && (WVALID_i == 1'b1 || WVALID == 1'b1)) begin  // Added by AP on 08/08/11 - 1a
         
         IF ((WREADY_d0 = '1' AND wr_strobe_valid = '1') AND (WVALID_i = '1' OR 
         WVALID = '1')) THEN
            -- Added by AP on 08/08/11 - 1b	      
            
            WSTRB_WDATA_r(CUST_WR_DWIDTH - 1 DOWNTO 0) <= WSTRB_i & WDATA_i;    
            wrch_fifo_wr_en <= '1';    
         ELSE
            wrch_fifo_wr_en <= '0';    
         END IF;
      END IF;
   END PROCESS;

   -------------------------------------------------------------------------------
   -- WRITE STROBE
   -------------------------------------------------------------------------------
   -------------------------------------------------------------------------------
   --   -----------------------------------------------------------------------
   --  |               |             |                    |                    |
   --  | single/double | upper/lower | word/halfword/byte | ahb transfer count |
   --  |     1-bit     |   1-bit     |    2-bit           |       6-bit        |
   --   -----------------------------------------------------------------------
   -------------------------------------------------------------------------------
   
   PROCESS (ACLK, ARESETn)
   BEGIN
      IF (ARESETn = '0') THEN
         wr_strobe_d <= "00000000";    
         wr_strobe_valid <= '0';    
         wstrb_8_active_d0 <= '0';    
      ELSIF (ACLK'EVENT AND ACLK = '1') THEN
         wr_strobe_d <= WSTRB_i(7 DOWNTO 0);    
         --wr_strobe_valid   <= (WVALID_i == 1'b1) && (WREADY == 1'b1);  // Commented by AP on 08/08/11
         
         wr_strobe_valid <= CONV_STD_LOGIC((WVALID_i = '1' OR WVALID = '1') AND (WREADY_xhdl2 = '1'));    --  Added by AP on 08/08/11
         wstrb_8_active_d0 <= wstrb_8_active;    
      END IF;
   END PROCESS;
   wstrb_8_enable <= and_br(wr_strobe_d(7 DOWNTO 0)) ;
   wstrb_4_enable <= and_br(wr_strobe_d(7 DOWNTO 4)) OR and_br(wr_strobe_d(3 
   DOWNTO 0)) ;
   wstrb_2_enable <= and_br(wr_strobe_d(7 DOWNTO 6)) OR and_br(wr_strobe_d(5 
   DOWNTO 4)) OR and_br(wr_strobe_d(3 DOWNTO 2)) OR and_br(wr_strobe_d(1 DOWNTO 
   0)) ;
   wstrb_1_enable <= or_br(wr_strobe_d(7 DOWNTO 0)) ;
   wstrb_8_active <= CONV_STD_LOGIC(((wstrb_8_enable = '1') AND (AWSIZE_r(2 
   DOWNTO 0) = "011")) AND (wr_strobe_valid = '1')) ;
   wstrb_4_active <= CONV_STD_LOGIC(((wstrb_4_enable = '1') AND (AWSIZE_r(2 
   DOWNTO 0) = "010")) AND (wr_strobe_valid = '1')) ;
   wstrb_2_active <= CONV_STD_LOGIC(((wstrb_2_enable = '1') AND (AWSIZE_r(2 
   DOWNTO 0) = "001")) AND (wr_strobe_valid = '1')) ;
   wstrb_1_active <= CONV_STD_LOGIC(((wstrb_1_enable = '1') AND (AWSIZE_r(2 
   DOWNTO 0) = "000")) AND (wr_strobe_valid = '1')) ;

   -------------------------------------------------------------------------------
   -- Write strobe manupulation state machine
   -------------------------------------------------------------------------------
   
   wr_strobe_fsm_seq : PROCESS (ACLK, ARESETn)
   BEGIN
      IF (ARESETn = '0') THEN
         W_curr_state <= START;    
      ELSIF (ACLK'EVENT AND ACLK = '1') THEN
         W_curr_state <= W_next_state;    
      END IF;
   END PROCESS wr_strobe_fsm_seq;

   -------------------------------------------------------------------------------
   -- Combinational block for write strobe manupulation State Machine
   -------------------------------------------------------------------------------
   
   wr_strobe_fsm_combo : PROCESS (wstrb_2_active, AWSIZE_r,  
   cstate_d0, 
   cstate_d1, wstrb_4_active,  WLAST_d1,
   WSTRB_i,  
   M_current_state,  
   WLAST_d2, AWLEN_r, W_next_state, wstrb_8_active, 
   W_curr_state, wstrb_1_active  )
      VARIABLE W_next_state_xhdl52  : std_logic_vector(1 DOWNTO 0);
      VARIABLE wr_strobe_fix_xhdl53  : std_logic;
      VARIABLE ahb_trans_count_en_xhdl54  : std_logic;
      VARIABLE ahb_trans_count_en_1_xhdl55  : std_logic;
   BEGIN
      W_next_state_xhdl52 := W_curr_state;    
      wr_strobe_fix_xhdl53 := '0';    --  write data into fifo when set
      ahb_trans_count_en_xhdl54 := '0';    
      ahb_trans_count_en_1_xhdl55 := '0';    
      CASE W_curr_state IS
         -----------------------------------------
         -- START STATE or RESET state
         -----------------------------------------
         
         WHEN START =>
                  IF (((M_current_state = W_WR_DATA) AND (AWSIZE_r = "011")) OR 
                  ((cstate_d0 = W_WR_DATA OR cstate_d1 = W_WR_DATA) AND 
                  ((AWSIZE_r = "010") OR (AWSIZE_r = "001") OR (AWSIZE_r = 
                  "000")))) THEN
                     --((cstate_d1 == W_WR_DATA) && ((AWSIZE_r == 3'b010) || (AWSIZE_r == 3'b001) || (AWSIZE_r == 3'b000)))) begin  // 13/02/13 - 1A CHANGE
                     -- 15/02/13 - 1D CHANGE
                     
                     IF (((wstrb_8_active OR wstrb_4_active OR wstrb_2_active 
                     OR wstrb_1_active) OR CONV_STD_LOGIC(WSTRB_i = "11111111"))
                     = '1') THEN
                        W_next_state_xhdl52 := COUNT;    
                     ELSE
                        IF (WSTRB_i /= "00000000") THEN
                           W_next_state_xhdl52 := WR_S0;    
                           ahb_trans_count_en_1_xhdl55 := '1';    
                        END IF;
                     END IF;
                  END IF;
         -----------------------------------------
         -- Write ahb transfer Count in write strobe fifo
         -----------------------------------------
         
         WHEN WR_S0 =>
                  IF (WLAST_d2 = '1') THEN
                     W_next_state_xhdl52 := START;    
                     wr_strobe_fix_xhdl53 := '1';    
                  ELSE
                     IF (((wstrb_8_active OR wstrb_4_active OR wstrb_2_active 
                     OR wstrb_1_active) OR CONV_STD_LOGIC(AWLEN_r = "0000")) = 
                     '1') THEN
                        W_next_state_xhdl52 := COUNT;    
                        wr_strobe_fix_xhdl53 := '1';    
                     ELSE
                        IF ((WSTRB_i /= "00000000") AND (WSTRB_i /= "11111111"))
                        THEN
                           W_next_state_xhdl52 := WR_S0;    
                           wr_strobe_fix_xhdl53 := '1';    
                        END IF;
                     END IF;
                  END IF;
         -----------------------------------------
         -- Increment ahb transfer count number
         -----------------------------------------
         
         WHEN COUNT =>
                  ahb_trans_count_en_1_xhdl55 := '0';    
                  wr_strobe_fix_xhdl53 := '0';    
                  ahb_trans_count_en_xhdl54 := '1';    
                  IF (WLAST_d1 = '1') THEN
                     -- Commented By AP on 08/08/11 -- Reverted to original - 09/08/11
                     --          if (WLAST_d0 == 1'b1) begin    // Added By AP on 08/08/11   -- 01a
                     
                     W_next_state_xhdl52 := WR_S1;    
                  ELSE
                     W_next_state_xhdl52 := COUNT;    
                  END IF;
         -----------------------------------------
         -- Write ahb transfer Count in write strobe fifo
         -----------------------------------------
         
         WHEN WR_S1 =>
                  ahb_trans_count_en_xhdl54 := '0';    
                  wr_strobe_fix_xhdl53 := '1';    
                  W_next_state_xhdl52 := START;    
         WHEN -----------------------------------------
         -- Default condition
         -----------------------------------------
         
         OTHERS  =>
                  W_next_state_xhdl52 := W_curr_state;    
         
      END CASE;
      W_next_state <= W_next_state_xhdl52;
      wr_strobe_fix <= wr_strobe_fix_xhdl53;
      ahb_trans_count_en <= ahb_trans_count_en_xhdl54;
      ahb_trans_count_en_1 <= ahb_trans_count_en_1_xhdl55;
   END PROCESS wr_strobe_fsm_combo;
   temp_xhdl56 <= WVALID_d1 WHEN (AWLEN_r(3 DOWNTO 0)<="0001") ELSE WVALID_d0;
   custom_WVALID <= temp_xhdl56 ;
   temp_xhdl57 <= WREADY_d0 WHEN (AWLEN_r(3 DOWNTO 0)<="0001") ELSE WREADY_d1;
   custom_WREADY <= temp_xhdl57 ;

   PROCESS (ACLK, ARESETn)
   BEGIN
      IF (ARESETn = '0') THEN
         ahb_trans_count <= "000000";    
      ELSIF (ACLK'EVENT AND ACLK = '1') THEN
         IF (W_curr_state = START) THEN
            ahb_trans_count <= "000000";    
         ELSE
            IF ((CONV_STD_LOGIC(ahb_trans_count_en = '1') AND (custom_WVALID 
            AND custom_WREADY)) = '1') THEN
               --if (wstrb_8_active == 1'b1) begin   // Prashant - added delayed wstrb_8_active
               
               IF ((wstrb_8_active = '1') OR (wstrb_8_active_d0 = '1')) THEN
                  ahb_trans_count <= ahb_trans_count + "000010";    
               ELSE
                  ahb_trans_count <= ahb_trans_count + "000001";    
               END IF;
            END IF;
         END IF;
      END IF;
   END PROCESS;

   PROCESS (ACLK, ARESETn)
   BEGIN
      IF (ARESETn = '0') THEN
         add_topup <= "00";    
      ELSIF (ACLK'EVENT AND ACLK = '1') THEN
         IF ((CONV_STD_LOGIC(ahb_trans_count_en = '1') AND (custom_WVALID AND 
         custom_WREADY)) = '1') THEN
            IF (AWLEN_r(3 DOWNTO 1) = "000") THEN
               -- if AWLEN < 2
               
               add_topup <= "10";    
            --if (wstrb_8_active == 1'b1) begin   // Prashant - added delayed wstrb_8_active
            
            ELSE
               IF ((wstrb_8_active = '1') OR (wstrb_8_active_d0 = '1')) THEN
                  add_topup <= "10";    
               ELSE
                  add_topup <= "01";    
               END IF;
            END IF;
         END IF;
      END IF;
   END PROCESS;

   PROCESS (ACLK, ARESETn)
   BEGIN
      IF (ARESETn = '0') THEN
         ahb_trans_count_1 <= "000000";    
      ELSIF (ACLK'EVENT AND ACLK = '1') THEN
         IF (W_curr_state = WR_S1) THEN
            ahb_trans_count_1 <= "000000";    
         ELSE
            IF (ahb_trans_count_en_1 = '1') THEN
               ahb_trans_count_1 <= ahb_trans_count_1 + "000001";    
            END IF;
         END IF;
      END IF;
   END PROCESS;
   temp_xhdl58 <= ahb_trans_count_1 WHEN (W_curr_state = WR_S0) ELSE 
   ahb_trans_count(5 DOWNTO 0) + add_topup(1 DOWNTO 0);
   --temp_xhdl59 <= (ahb_trans_count(5 DOWNTO 0) + "000001") WHEN ((AWLEN_r(3 DOWNTO 0) < "0010") AND (AWSIZE_r(1 DOWNTO 0) /= "11")) ELSE 
   --               ahb_trans_count(5 DOWNTO 0) + add_topup(1 DOWNTO 0);
   temp_xhdl59_int <= (ahb_trans_count(5 DOWNTO 0) + "000001") WHEN ((AWLEN_r(3 DOWNTO 0) < "0010")) ELSE ahb_trans_count(5 DOWNTO 0);  --23/02/13 - 1I
   temp_xhdl59 <= temp_xhdl59_int WHEN ((AWSIZE_r(1 DOWNTO 0) /= "11")) ELSE (ahb_trans_count(5 DOWNTO 0) + add_topup(1 DOWNTO 0));
   temp_xhdl60 <= ahb_trans_count_1 WHEN (W_curr_state = WR_S0) ELSE (temp_xhdl59);

   -------------------------------------------------------------------------------
   -- Write Strobe FIFO write data/address/write enable.
   -------------------------------------------------------------------------------
   
   PROCESS (ACLK, ARESETn)
   BEGIN
      IF (ARESETn = '0') THEN
         wrstb_wr_data_xhdl26 <= "0000000000";    
         wrstb_wr_addr_xhdl25 <= "00000";    
      ELSIF (ACLK'EVENT AND ACLK = '1') THEN
         IF (M_current_state = IDLE) THEN
            wrstb_wr_data_xhdl26(5 DOWNTO 0) <= "000000";    
            wrstb_wr_data_xhdl26(9 DOWNTO 6) <= "0000";    
            wrstb_wr_addr_xhdl25 <= "00000";    
         ELSE
            IF (((W_curr_state = WR_S0) AND (wr_strobe_fix = '1')) AND 
            (wr_strobe_valid = '1')) THEN
               wrstb_wr_data_xhdl26(5 DOWNTO 0) <= temp_xhdl58;    
               wrstb_wr_data_xhdl26(9 DOWNTO 6) <= "0000";    
               wrstb_wr_addr_xhdl25 <= wrstb_wr_addr_xhdl25 + "00001";    
            ELSE
               IF ((wr_strobe_fix = '1') AND (wr_strobe_valid = '0')) THEN
                  wrstb_wr_data_xhdl26(5 DOWNTO 0) <= temp_xhdl60;    
                  wrstb_wr_data_xhdl26(9 DOWNTO 6) <= "0000";    
                  wrstb_wr_addr_xhdl25 <= wrstb_wr_addr_xhdl25 + "00001";    
               ELSE
                  IF (M_current_state = W_WAIT4_WR_RESP) THEN
                     wrstb_wr_data_xhdl26(5 DOWNTO 0) <= wrstb_wr_data_xhdl26(5 
                     DOWNTO 0);    
                     wrstb_wr_data_xhdl26(9 DOWNTO 6) <= wrstb_wr_data_xhdl26(9 
                     DOWNTO 6);    
                     wrstb_wr_addr_xhdl25 <= wrstb_wr_addr_xhdl25;    
                  END IF;
               END IF;
            END IF;
         END IF;
      END IF;
   END PROCESS;

   PROCESS (ACLK, ARESETn)
   BEGIN
      IF (ARESETn = '0') THEN
         wrstb_fifo_wren_xhdl27 <= '0';    
      ELSIF (ACLK'EVENT AND ACLK = '1') THEN
         wrstb_fifo_wren_xhdl27 <= wr_strobe_fix;    
      END IF;
   END PROCESS;

   -------------------------------------------------------------------------------
   -- Latch the AXI write response from AHB domain - number of errors counter
   -------------------------------------------------------------------------------
   
   latch_axi_wr_resp : PROCESS (ACLK, ARESETn)
   BEGIN
      IF (ARESETn = '0') THEN
         bresp_count <= "00000";    
      ELSIF (ACLK'EVENT AND ACLK = '1') THEN
         IF (send_wr_resp = '1') THEN
            bresp_count <= hresp_err_count(4 DOWNTO 0);    
         END IF;
      END IF;
   END PROCESS latch_axi_wr_resp;

   -------------------------------------------------------------------------------
   -- Send AXI write response back to AXI master/host
   -------------------------------------------------------------------------------
   
   send_axi_wr_resp : PROCESS (ACLK, ARESETn)
   BEGIN
      IF (ARESETn = '0') THEN
         BRESP_xhdl4 <= "00";    
         BVALID_xhdl5 <= '0';    
         BID_xhdl3 <= "0000";    
      ELSIF (ACLK'EVENT AND ACLK = '1') THEN
         IF (M_current_state = W_SEND_WR_RESP) THEN
            BVALID_xhdl5 <= '1';    
            BID_xhdl3 <= AWID_r(3 DOWNTO 0);    
            IF (bresp_count(4 DOWNTO 0) /= "00000") THEN
               -- send error response
               
               BRESP_xhdl4 <= RESPERR_C;    
            ELSE
               -- send okay response
               
               BRESP_xhdl4 <= RESPOK_C;    
            END IF;
         ELSE
            BID_xhdl3 <= "0000";    
            BVALID_xhdl5 <= '0';    
         END IF;
      END IF;
   END PROCESS send_axi_wr_resp;

   PROCESS (ACLK, ARESETn)
   BEGIN
      IF (ARESETn = '0') THEN
         read_resp <= '0' & '0' & '0' & '0';    
      ELSIF (ACLK'EVENT AND ACLK = '1') THEN
         IF (axi2rdch_fifo_rd_en_r = '1') THEN
            read_resp <= rdch2axi_rd_resp_data(1 DOWNTO 0) & read_resp(3 DOWNTO 
            2);    
         END IF;
      END IF;
   END PROCESS;

   -- --------------------------------------------------------------------
   -- SAR 58944
   PROCESS (ACLK, ARESETn)
   BEGIN
      IF (ARESETn = '0') THEN
         read_data_reg <= (OTHERS => '0');    
      ELSIF (ACLK'EVENT AND ACLK = '1') THEN
         IF (read_data_reg_en = '1') THEN
            read_data_reg <= read_data;    
         ELSE
            read_data_reg <= read_data_reg;    
         END IF;
      END IF;
   END PROCESS;    

   temp1 <= NOT (axi2rdch_fifo_rd_en_r) AND axi2rdch_fifo_rd_en_r_reg;
   read_data_reg_en <= '1' WHEN (temp1 = '1') ELSE '0';

   PROCESS (ACLK, ARESETn)
   BEGIN
      IF (ARESETn = '0') THEN
         axi2rdch_fifo_rd_en_r_reg <= '0';    
      ELSIF (ACLK'EVENT AND ACLK = '1') THEN
         axi2rdch_fifo_rd_en_r_reg <= axi2rdch_fifo_rd_en_r;    
      END IF;
   END PROCESS;    

   PROCESS (ACLK, ARESETn)
   BEGIN
      IF (ARESETn = '0') THEN
         axi2rdch_fifo_rd_en_clr <= '0';    
      ELSIF (ACLK'EVENT AND ACLK = '1') THEN
         IF (RVALID_xhdl11 = '1' AND RREADY = '1') THEN
            axi2rdch_fifo_rd_en_clr <= '0';    
         ELSIF (axi2rdch_fifo_rd_en_clr = '1') THEN
            axi2rdch_fifo_rd_en_clr <= axi2rdch_fifo_rd_en_clr;    
         ELSE
            axi2rdch_fifo_rd_en_clr <= axi2rdch_fifo_rd_en_xhdl28;    
         END IF;
      END IF;
   END PROCESS;    

   -- --------------------------------------------------------------------


   PROCESS (ACLK, ARESETn)
   BEGIN
      IF (ARESETn = '0') THEN
         read_data <= '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' 
         & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & 
         '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' 
         & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & 
         '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' 
         & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0';    
      ELSIF (ACLK'EVENT AND ACLK = '1') THEN
         IF (axi2rdch_fifo_rd_en_r = '1') THEN
            CASE ARSIZE_r(1 DOWNTO 0) IS
               WHEN "11" =>
                        IF (ARADDR_r(2 DOWNTO 0) < "100") THEN
                           IF (axi_rd_addr(2 DOWNTO 0) < "100") THEN
                              read_data <= read_data(63 DOWNTO 32) & 
                              rdch2axi_fifo_rd_data(AHB_DWIDTH - 1 DOWNTO 0);   
                           ELSE
                              IF (axi_rd_addr(2 DOWNTO 0) >= "100") THEN
                                 read_data <= rdch2axi_fifo_rd_data(AHB_DWIDTH 
                                 - 1 DOWNTO 0) & read_data(31 DOWNTO 0);    
                              END IF;
                           END IF;
                        ELSE
                           IF (axi_rd_addr_d0(2 DOWNTO 0) < "100") THEN
                              read_data <= read_data(63 DOWNTO 32) & 
                              rdch2axi_fifo_rd_data_d0(AHB_DWIDTH - 1 DOWNTO 0)
                              ;    
                           ELSE
                              IF (axi_rd_addr_d0(2 DOWNTO 0) >= "100") THEN
                                 read_data <= 
                                 rdch2axi_fifo_rd_data_d0(AHB_DWIDTH - 1 DOWNTO 
                                 0) & read_data(31 DOWNTO 0);    
                              END IF;
                           END IF;
                        END IF;
               WHEN "10" =>
                        IF (axi_rd_addr(2 DOWNTO 0) < "100") THEN
                           read_data <= read_data(63 DOWNTO 32) & 
                           rdch2axi_fifo_rd_data(AHB_DWIDTH - 1 DOWNTO 0);    
                        ELSE
                           IF (axi_rd_addr(2 DOWNTO 0) >= "100") THEN
                              read_data <= rdch2axi_fifo_rd_data(AHB_DWIDTH - 1 
                              DOWNTO 0) & read_data(31 DOWNTO 0);    
                           END IF;
                        END IF;
               WHEN "01" =>
                        IF (axi_rd_addr(2 DOWNTO 0) < "100") THEN
                           read_data <= read_data(63 DOWNTO 32) & 
                           rdch2axi_fifo_rd_data(AHB_DWIDTH - 1 DOWNTO 0);    
                        ELSE
                           IF (axi_rd_addr(2 DOWNTO 0) >= "100") THEN
                              read_data <= rdch2axi_fifo_rd_data(AHB_DWIDTH - 1 
                              DOWNTO 0) & read_data(31 DOWNTO 0);    
                           END IF;
                        END IF;
               WHEN "00" =>
                        IF (axi_rd_addr(2 DOWNTO 0) < "100") THEN
                           read_data <= read_data(63 DOWNTO 32) & 
                           rdch2axi_fifo_rd_data(AHB_DWIDTH - 1 DOWNTO 0);    
                        ELSE
                           read_data <= rdch2axi_fifo_rd_data(AHB_DWIDTH - 1 
                           DOWNTO 0) & read_data(31 DOWNTO 0);    
                        END IF;
               WHEN OTHERS =>
                        NULL;
               
            END CASE;
         END IF;
      END IF;
   END PROCESS;

   PROCESS (read_resp)
      VARIABLE axi_rd_resp_xhdl61  : std_logic_vector(1 DOWNTO 0);
   BEGIN
      CASE read_resp(3 DOWNTO 0) IS
         WHEN "0000" =>
                  axi_rd_resp_xhdl61(1 DOWNTO 0) := RESPOK_C;    
         WHEN "0101" =>
                  axi_rd_resp_xhdl61(1 DOWNTO 0) := RESPERR_C;    
         WHEN "0001" =>
                  axi_rd_resp_xhdl61(1 DOWNTO 0) := RESPERR_C;    
         WHEN "0100" =>
                  axi_rd_resp_xhdl61(1 DOWNTO 0) := RESPERR_C;    
         WHEN OTHERS  =>
                  axi_rd_resp_xhdl61(1 DOWNTO 0) := RESPOK_C;    
         
      END CASE;
      axi_rd_resp <= axi_rd_resp_xhdl61;
   END PROCESS;

   PROCESS (ACLK, ARESETn)
   BEGIN
      IF (ARESETn = '0') THEN
         read_len_count <= "00000";    
      ELSIF (ACLK'EVENT AND ACLK = '1') THEN
         IF (M_current_state = R_SEND_RLAST) THEN
            read_len_count <= "00000";    
         ELSE
            IF (read_len_count_en = '1' AND RVALID_xhdl11 = '1' AND RREADY = '1') THEN  -- SAR 58944
               read_len_count <= read_len_count + "00001";    
            END IF;
         END IF;
      END IF;
   END PROCESS;

   PROCESS (ACLK, ARESETn)
   BEGIN
      IF (ARESETn = '0') THEN
         read_len_count_en_r <= '0';    
         axi_rd_addr_d0 <= "000";    
         rdch2axi_fifo_rd_data_d0 <= (OTHERS => '0');    
      ELSIF (ACLK'EVENT AND ACLK = '1') THEN
         read_len_count_en_r <= read_len_count_en;    
         axi_rd_addr_d0 <= axi_rd_addr(2 DOWNTO 0);    
         rdch2axi_fifo_rd_data_d0 <= rdch2axi_fifo_rd_data;    
      END IF;
   END PROCESS;

   PROCESS (ACLK, ARESETn)
   BEGIN
      IF (ARESETn = '0') THEN
         axi_rd_addr <= "000";    
      ELSIF (ACLK'EVENT AND ACLK = '1') THEN
         IF (valid_axicmd_xhdl14 = '1') THEN
            axi_rd_addr <= ARADDR_r(2 DOWNTO 0);    
         ELSE
            IF (axi2rdch_fifo_rd_en_r = '1') THEN
               axi_rd_addr <= axi_rd_addr(2 DOWNTO 0) + axi_addr_incr(2 DOWNTO 
               0);    
            END IF;
         END IF;
      END IF;
   END PROCESS;

   PROCESS (ARSIZE_r)
      VARIABLE axi_addr_incr_xhdl62  : std_logic_vector(2 DOWNTO 0);
   BEGIN
      CASE ARSIZE_r(1 DOWNTO 0) IS
         WHEN "00" =>
                  axi_addr_incr_xhdl62 := "001";    
         WHEN "01" =>
                  axi_addr_incr_xhdl62 := "010";    
         WHEN "10" =>
                  axi_addr_incr_xhdl62 := "100";    
         WHEN "11" =>
                  axi_addr_incr_xhdl62 := "100";    
         WHEN OTHERS  =>
                  axi_addr_incr_xhdl62 := "000";    
         
      END CASE;
      axi_addr_incr <= axi_addr_incr_xhdl62;
   END PROCESS;

END ARCHITECTURE translated;
