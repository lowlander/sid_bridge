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

ENTITY CoreAXItoAHBL_AHBAccessControl IS
   GENERIC (
      -----------------------------------------------------
      -- Global parameters
      -----------------------------------------------------
      AHB_AWIDTH                     :  integer := 32;    
      AXI_AWIDTH                     :  integer := 32;    
      AHB_DWIDTH                     :  integer := 32;    
      AXI_DWIDTH                     :  integer := 64;    
      CLOCKS_ASYNC                   :  integer := 1;    
      CUSTOM_WR_DWIDTH               :  integer := 64 + 8);    
   PORT (
      -----------------------------------------------------
-- Input-Output Ports
-----------------------------------------------------
-- Inputs on the AHBL interface

      HCLK                    : IN std_logic;   
      HRESETn                 : IN std_logic;   
      -- Outputs on the AHBL Interface

      HSEL                    : OUT std_logic;   
      HADDR                   : OUT std_logic_vector(AHB_AWIDTH - 1 DOWNTO 0);  
      HWRITE                  : OUT std_logic;   
      HREADYIN                : IN std_logic;   
      -- Other control inputs

      axi2xhsync_awlatch_syn  : IN std_logic;   --  Synchronized control signal - write
      axi2xhsync_arlatch_syn  : IN std_logic;   --  Synchronized control signal - read
      axi2ahb_wr_fifo_done_syn: IN std_logic;   --  indicates AXI write channel fifo write operation done
      -- Inputs from AHB Access Control

      axi2ahb_WID             : IN std_logic_vector(3 DOWNTO 0);   
      axi2ahb_AWID            : IN std_logic_vector(3 DOWNTO 0);   
      axi2ahb_AWADDR          : IN std_logic_vector(AXI_AWIDTH - 1 DOWNTO 0);   
      axi2ahb_AWLEN           : IN std_logic_vector(3 DOWNTO 0);   
      axi2ahb_AWSIZE          : IN std_logic_vector(2 DOWNTO 0);   
      axi2ahb_AWBURST         : IN std_logic_vector(1 DOWNTO 0);   
      axi2ahb_AWLOCK          : IN std_logic_vector(1 DOWNTO 0);   
      wrstb_ram_rd_data       : IN std_logic_vector(9 DOWNTO 0);   --  write strobe fifo read data - strobe information
      wrstb_fifo_wren_syn     : IN std_logic;   --  sync control signal to latch last RAM address
      wrstb_wr_addr           : IN std_logic_vector(4 DOWNTO 0);   --  write strobe fifo write address
      ahb2wrchfifo_rddata     : IN std_logic_vector(CUSTOM_WR_DWIDTH - 1 DOWNTO 0);   --  Write channel fifo write data
      rdch2ahb_fifo_full      : IN std_logic;   --  read channel fifo full signal
      wrch2ahb_fifo_empty     : IN std_logic;   
      HTRANS                  : OUT std_logic_vector(1 DOWNTO 0);   
      HSIZE                   : OUT std_logic_vector(2 DOWNTO 0);   
      HWDATA                  : OUT std_logic_vector(AHB_DWIDTH - 1 DOWNTO 0);  
      HBURST                  : OUT std_logic_vector(2 DOWNTO 0);   
      HMASTLOCK               : OUT std_logic;   
      HREADYOUT               : OUT std_logic;   
      HRESP                   : IN std_logic_vector(1 DOWNTO 0);   
      HRDATA                  : IN std_logic_vector(AHB_DWIDTH - 1 DOWNTO 0);   
      -- Other Control Outputs 

      wrstb_ram_rd_en         : OUT std_logic;   --  write strobe ram read enable
      wrstb_ram_rd_addr       : OUT std_logic_vector(3 DOWNTO 0);   --  write strobe ram read address
      ahb2wrchfifo_rd_en      : OUT std_logic;   --  Write Channel FIFO read enable
      -- AHB response outputs

      h_send_ahb_resp_en_r    : OUT std_logic;   
      hresp_err_count         : OUT std_logic_vector(4 DOWNTO 0);   --  counts number of AHB errors from slave
      wrch_fifo_rd_clear      : OUT std_logic;   
      -- Read Channel FIFO Interface

      ahb2rdch_fifo_wr_en     : OUT std_logic;   --  read channel fifo write enable
      ahb2rdch_fifo_wr_data   : OUT std_logic_vector(AHB_DWIDTH - 1 DOWNTO 0);   --  read channel fifo write data
      ahb2rdch_rd_resp_data   : OUT std_logic_vector(1 DOWNTO 0);   --  read channel read response write data
      ahb2axi_ahb_read_done_r : OUT std_logic);   
END ENTITY CoreAXItoAHBL_AHBAccessControl;

ARCHITECTURE translated OF CoreAXItoAHBL_AHBAccessControl IS
   -------------------------------------------------------------------------------
   -- Functions
   -------------------------------------------------------------------------------
 
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

   FUNCTION ShiftRight (
      val      : std_logic_vector;
      shft     : integer) RETURN std_logic_vector IS
      
      VARIABLE int      : std_logic_vector(val'LENGTH+shft-1 DOWNTO 0);
      VARIABLE rtn      : std_logic_vector(val'RANGE);
      VARIABLE fill     : std_logic_vector(shft-1 DOWNTO 0) := (others => '0');
   BEGIN
      int := fill & val;
      rtn := int(val'LENGTH+shft-1 DOWNTO shft);
      RETURN(rtn);
   END ShiftRight;  

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
   -- Main State machine variables
   CONSTANT  H_IDLE                :  std_logic_vector(2 DOWNTO 0) := "000";    
   CONSTANT  H_RD_RAM              :  std_logic_vector(2 DOWNTO 0) := "001";    
   CONSTANT  H_SUB_START           :  std_logic_vector(2 DOWNTO 0) := "010";    
   CONSTANT  H_AHB_TRANS           :  std_logic_vector(2 DOWNTO 0) := "011";    
   CONSTANT  H_AHB_DONE            :  std_logic_vector(2 DOWNTO 0) := "100";    
   -- Single Transfer State machine variables
   CONSTANT  S_IDLE                :  std_logic_vector(2 DOWNTO 0) := "000";    
   CONSTANT  S_RD_FIFO             :  std_logic_vector(2 DOWNTO 0) := "001";    
   CONSTANT  S_GET_DATA            :  std_logic_vector(2 DOWNTO 0) := "010";    
   CONSTANT  S_SEND_ADDRDATA0      :  std_logic_vector(2 DOWNTO 0) := "011";    
   CONSTANT  S_SEND_ADDRDATA1      :  std_logic_vector(2 DOWNTO 0) := "100";    
   -- Multiple Transfer read fifo State machine variables
   CONSTANT  M1_IDLE               :  std_logic_vector(1 DOWNTO 0) := "00";    
   CONSTANT  M1_RD_FIFO            :  std_logic_vector(1 DOWNTO 0) := "01";    
   CONSTANT  M1_GET_DATA           :  std_logic_vector(1 DOWNTO 0) := "10";    
   CONSTANT  M1_WAIT               :  std_logic_vector(1 DOWNTO 0) := "11";    
   -- Multiple Transfer State machine variables
   CONSTANT  M2_IDLE               :  std_logic_vector(2 DOWNTO 0) := "000";    
   CONSTANT  M2_DECIDE_CYC         :  std_logic_vector(2 DOWNTO 0) := "001";    
   CONSTANT  M2_SEND_AD0           :  std_logic_vector(2 DOWNTO 0) := "010";    
   CONSTANT  M2_SEND_AD1           :  std_logic_vector(2 DOWNTO 0) := "011";    
   CONSTANT  M2_BURST_COUNT        :  std_logic_vector(2 DOWNTO 0) := "100";    
   CONSTANT  M2_WAIT4SINGLE        :  std_logic_vector(2 DOWNTO 0) := "101";    
   CONSTANT  INCR16                :  integer := 16;    
   CONSTANT  INCR8                 :  integer := 8;    
   CONSTANT  INCR4                 :  integer := 4;    
   CONSTANT  SINGLE                :  integer := 1;    
   CONSTANT  IDLE                  :  std_logic_vector(1 DOWNTO 0) := "00";    --  indicates that no data transfer is required
   CONSTANT  NONSEQ                :  std_logic_vector(1 DOWNTO 0) := "10";    --  indicates first transfer of a single burst
   CONSTANT  SEQ                   :  std_logic_vector(1 DOWNTO 0) := "11";    --  indicates remaining transfers in the burst
   CONSTANT  TYPE_SINGLE           :  std_logic_vector(2 DOWNTO 0) := "000";    
   CONSTANT  TYPE_WRAP4            :  std_logic_vector(2 DOWNTO 0) := "010";    
   CONSTANT  TYPE_INCR4            :  std_logic_vector(2 DOWNTO 0) := "011";    
   CONSTANT  TYPE_WRAP8            :  std_logic_vector(2 DOWNTO 0) := "100";    
   CONSTANT  TYPE_INCR8            :  std_logic_vector(2 DOWNTO 0) := "101";    
   CONSTANT  TYPE_WRAP16           :  std_logic_vector(2 DOWNTO 0) := "110";    
   CONSTANT  TYPE_INCR16           :  std_logic_vector(2 DOWNTO 0) := "111";    
   CONSTANT  c_ERR_RESP            :  std_logic_vector(1 DOWNTO 0) := "01";    
   CONSTANT  c_OKAY_RESP           :  std_logic_vector(1 DOWNTO 0) := "00";    
   -- Parameter for AHB read state machine
   CONSTANT  R_IDLE                :  std_logic_vector(2 DOWNTO 0) := "000";    
   CONSTANT  R_DECIDE_CYC          :  std_logic_vector(2 DOWNTO 0) := "001";    
   CONSTANT  R_SEND_START_ADDR     :  std_logic_vector(2 DOWNTO 0) := "010";    
   CONSTANT  R_GET_DATA_N_ADDR     :  std_logic_vector(2 DOWNTO 0) := "011";    
   CONSTANT  R_GET_LAST_DATA       :  std_logic_vector(2 DOWNTO 0) := "100";    
   -------------------------------------------------------------------------------
   -- Register Declarations
   -------------------------------------------------------------------------------
   SIGNAL axi2ahb_WID_r            :  std_logic_vector(3 DOWNTO 0);   
   SIGNAL axi2ahb_AWID_r           :  std_logic_vector(3 DOWNTO 0);   
   SIGNAL axi2ahb_AWADDR_r         :  std_logic_vector(AXI_AWIDTH - 1 DOWNTO 0)
   ;   
   SIGNAL axi2ahb_AWLEN_r          :  std_logic_vector(3 DOWNTO 0);   
   SIGNAL axi2ahb_AWSIZE_r         :  std_logic_vector(2 DOWNTO 0);   
   SIGNAL axi2ahb_AWBURST_r        :  std_logic_vector(1 DOWNTO 0);   
   SIGNAL axi2ahb_AWLOCK_r         :  std_logic_vector(1 DOWNTO 0);   
   SIGNAL axi2ahb_ARID_r           :  std_logic_vector(3 DOWNTO 0);   
   SIGNAL axi2ahb_ARADDR_r         :  std_logic_vector(AXI_AWIDTH - 1 DOWNTO 0)
   ;   
   SIGNAL axi2ahb_ARLEN_r          :  std_logic_vector(3 DOWNTO 0);   
   SIGNAL axi2ahb_ARSIZE_r         :  std_logic_vector(2 DOWNTO 0);   
   SIGNAL axi2ahb_ARBURST_r        :  std_logic_vector(1 DOWNTO 0);   
   SIGNAL axi2ahb_ARLOCK_r         :  std_logic_vector(1 DOWNTO 0);   
   SIGNAL hsize_r                  :  std_logic_vector(2 DOWNTO 0);   --  AHB transfer size
   SIGNAL hburst_r                 :  std_logic_vector(2 DOWNTO 0);   --  AHB burst size
   SIGNAL H_next_state             :  std_logic_vector(2 DOWNTO 0);   --  main FSM next state
   SIGNAL H_curr_state             :  std_logic_vector(2 DOWNTO 0);   --  main FSM current state
   SIGNAL s_next_state             :  std_logic_vector(2 DOWNTO 0);   --  single transfer FSM next state
   SIGNAL s_curr_state             :  std_logic_vector(2 DOWNTO 0);   --  single transfer FSM current state
   SIGNAL m2_next_state            :  std_logic_vector(2 DOWNTO 0);   --  multiple transfer FSM next state
   SIGNAL m2_curr_state            :  std_logic_vector(2 DOWNTO 0);   --  multiple transfer FSM current state
   SIGNAL h_loopcount_en           :  std_logic;   
   SIGNAL h_hsel_write             :  std_logic;   
   SIGNAL h_hsel_write_r           :  std_logic;   
   SIGNAL h_loopcount              :  std_logic_vector(4 DOWNTO 0);   
   SIGNAL h_ram_rd_en              :  std_logic;   --  read enable for write strobe ram
   SIGNAL h_start_single_transfer  :  std_logic;   --  Start for single transfer fsm
   SIGNAL h_start_multiple_transfer:  std_logic;   --  Start for multiple transfer fsm
   SIGNAL h_start_multiple_transfer_d     :  std_logic;   --  Start for multiple transfer fsm
   SIGNAL h_start_multiple_transfer_d1    :  std_logic;   --  Start for multiple transfer fsm   - By AP 09/08/11 - 2a
   SIGNAL h_send_ahb_resp_en       :  std_logic;   
   SIGNAL wrstb_ram_rd_en_d        :  std_logic;   --  write strobe ram read enable
   SIGNAL h_ram_rd_en_d            :  std_logic;   
   SIGNAL max_ram_addr             :  std_logic_vector(4 DOWNTO 0);   --  max write address of write strobe ram
   SIGNAL ram_rd_data              :  std_logic_vector(9 DOWNTO 0);   --  write strobe fifo read data - strobe information
   SIGNAL ahb2wrchfifo_rd_en_d     :  std_logic;   --  Write Channel FIFO read enable
   SIGNAL ahb_trans_count          :  std_logic_vector(1 DOWNTO 0);   --  number of single ahb transfer count
   SIGNAL addr_incr                :  std_logic_vector(2 DOWNTO 0);   
   SIGNAL trans_size_0             :  std_logic_vector(1 DOWNTO 0);   
   SIGNAL trans_size_1             :  std_logic_vector(1 DOWNTO 0);   
   SIGNAL trans_size_2             :  std_logic_vector(1 DOWNTO 0);   
   SIGNAL s_wait_count             :  std_logic_vector(1 DOWNTO 0);   
   SIGNAL s_len_wr_count           :  std_logic_vector(2 DOWNTO 0);   
   SIGNAL s_single_trans_done      :  std_logic;   --  all single transfer are completed
   SIGNAL s_wr_channel_rd_en       :  std_logic;   
   SIGNAL s_set_ahb_addr           :  std_logic;   --  set AHB address on AHB bus
   SIGNAL s_set_ahb_addr_data      :  std_logic;   --  set AHB address/data on AHB bus
   SIGNAL s_single_tras_active     :  std_logic;   
   SIGNAL s_write_en               :  std_logic;   --  AHB write enable
   SIGNAL s_trans_length_en        :  std_logic;   
   SIGNAL wrch_fifo_rd_data        :  std_logic_vector(AXI_DWIDTH - 1 DOWNTO 0);   --  write channel fifo read data
   SIGNAL wrch_fifo_rd_data_wrstb  :  std_logic_vector(AXI_WRSTB - 1 DOWNTO 0);   --  write channel fifo read data write strobe
   SIGNAL wrch_fifo_rd_data_wrstb_d  :  std_logic_vector(AXI_WRSTB - 1 DOWNTO 0);   --  write channel fifo read data write strobe      -- SAR#46417
   SIGNAL m2_wr_channel_rd_en      :  std_logic;   
   SIGNAL m2_wr_channel_rd_en_int2 :  std_logic_vector(1 DOWNTO 0);   
   SIGNAL m2_multi_trans_done      :  std_logic;   
   SIGNAL m2_multi_trans_done_r    :  std_logic;   
   SIGNAL m2_set_ahb_addr          :  std_logic;   
   SIGNAL m2_set_ahb_addr_reg      :  std_logic;   
   SIGNAL m2_single_tras_active    :  std_logic;   
   SIGNAL m2_super_no_of_burst_count      :  std_logic_vector(2 DOWNTO 0);   
   SIGNAL m2_super_no_of_burst_count_en   :  std_logic;   
   SIGNAL m2_ahb_cyc_info          :  std_logic_vector(7 DOWNTO 0);   
   SIGNAL m2_ahb_cyc_info_dummy    :  std_logic_vector(7 DOWNTO 0);   
   SIGNAL m2_ahb_cyc_info_dummy_load      :  std_logic;   
   SIGNAL m2_ahb_cyc_info_dummy_shen      :  std_logic;   
   SIGNAL m2_burst_len_count       :  std_logic_vector(4 DOWNTO 0);   
   SIGNAL m2_burst_len_count_en    :  std_logic;   
   SIGNAL m2_burst_size            :  std_logic_vector(4 DOWNTO 0);   --  INCR16,INCR8,INCR4 burst length
   SIGNAL m2_burst_size_c          :  std_logic_vector(2 DOWNTO 0);   --  INCR16,INCR8,INCR4 burst length
   SIGNAL m2_burst_size_count_en   :  std_logic;   --  burst length count enable
   SIGNAL m2_no_of_burst_count_en  :  std_logic;   
   SIGNAL m2_no_of_burst_count     :  std_logic_vector(1 DOWNTO 0);   
   SIGNAL m2_set_addr_4_last_single_cyc   :  std_logic;   
   SIGNAL wrch2ahb_fifo_empty_r    :  std_logic;   
   SIGNAL m2_ahb_addr_set_r        :  std_logic;   
   SIGNAL haddr_r                  :  std_logic_vector(AHB_AWIDTH - 1 DOWNTO 0)
   ;   
   SIGNAL hwdata_r                 :  std_logic_vector(AHB_DWIDTH - 1 DOWNTO 0)
   ;   
   SIGNAL htrans_r                 :  std_logic_vector(1 DOWNTO 0);   
   SIGNAL hwrite_r                 :  std_logic;   
   SIGNAL hreadyout_r              :  std_logic;   
   SIGNAL hresp_r                  :  std_logic_vector(1 DOWNTO 0);   --  latch the current AHB response (okay / error)
   SIGNAL m2_fifo_rd_count         :  std_logic_vector(4 DOWNTO 0);   
   SIGNAL remaining_dec_en         :  std_logic;   
   SIGNAL add_len                  :  std_logic_vector(3 DOWNTO 0);   
   SIGNAL axi2ahb_rd_start_syn     :  std_logic;   --  Start signal for AHB read transfer
   SIGNAL R_ahb_cyc_info           :  std_logic_vector(7 DOWNTO 0);   
   SIGNAL R_ahb_cyc_info_r         :  std_logic_vector(7 DOWNTO 0);   
   SIGNAL R_curr_state             :  std_logic_vector(2 DOWNTO 0);   
   SIGNAL R_next_state             :  std_logic_vector(2 DOWNTO 0);   
   SIGNAL R_top_count              :  std_logic_vector(2 DOWNTO 0);   
   SIGNAL R_max_len_count          :  std_logic_vector(4 DOWNTO 0);   
   SIGNAL R_len_count              :  std_logic_vector(4 DOWNTO 0);   
   SIGNAL R_max_subtop_count       :  std_logic_vector(1 DOWNTO 0);   
   SIGNAL R_subtop_count           :  std_logic_vector(1 DOWNTO 0);   
   SIGNAL R_max_subtop_count_load  :  std_logic;   
   SIGNAL R_len_count_reset        :  std_logic;   
   SIGNAL R_ahb_cyc_info_load      :  std_logic;   
   SIGNAL R_len_count_en           :  std_logic;   
   SIGNAL R_top_count_en           :  std_logic;   
   SIGNAL R_subtop_count_en        :  std_logic;   
   SIGNAL R_ahb_cyc_info_shift_en  :  std_logic;   
   SIGNAL R_read_cycle_en          :  std_logic;   
   SIGNAL R_read_addr_incr_en      :  std_logic;   
   SIGNAL R_read_addr_incr_en_1    :  std_logic;   
   SIGNAL R_ahb_read_done          :  std_logic;   
   SIGNAL R_haddr_r                :  std_logic_vector(AHB_AWIDTH - 1 DOWNTO 0)
   ;   
   SIGNAL R_hread_r                :  std_logic;   
   SIGNAL R_htrans_r               :  std_logic_vector(1 DOWNTO 0);   
   SIGNAL R_hburst_r               :  std_logic_vector(2 DOWNTO 0);   
   SIGNAL R_hsize_r                :  std_logic_vector(2 DOWNTO 0);   
   -- Added By AP - 15/07/11   
   SIGNAL axi2ahb_wr_fifo_done_syn_d      :  std_logic;   
   -------------------------   
   -------------------------------------------------------------------------------
   -- Wire Declarations
   -------------------------------------------------------------------------------
   SIGNAL wr_strobe                :  std_logic_vector(7 DOWNTO 0);   
   SIGNAL m2_ahb_addr_set          :  std_logic;   
   SIGNAL m2_ahb_addr_set_custom   :  std_logic;   
   SIGNAL m2_htrans_c              :  std_logic_vector(1 DOWNTO 0);   
   SIGNAL s_htrans_c               :  std_logic_vector(1 DOWNTO 0);   
   SIGNAL custom_awlen             :  std_logic_vector(4 DOWNTO 0);   
   SIGNAL wrstb_msb_en             :  std_logic;   --  Enable with upper write strobe nibble has single one.
   SIGNAL hwdata_1                 :  std_logic_vector(AHB_DWIDTH - 1 DOWNTO 0)
   ;   
   SIGNAL hwdata_2                 :  std_logic_vector(AHB_DWIDTH - 1 DOWNTO 0);   
   SIGNAL m2_prev_state            :  std_logic_vector(2 DOWNTO 0);   
   SIGNAL ping_lower_w             :  std_logic_vector(AHB_DWIDTH - 1 DOWNTO 0);   
   SIGNAL ping_upper_w             :  std_logic_vector(AHB_DWIDTH - 1 DOWNTO 0);   
   SIGNAL ping_lower_b             :  std_logic_vector(AHB_DWIDTH - 1 DOWNTO 0);   
   SIGNAL ping_upper_b             :  std_logic_vector(AHB_DWIDTH - 1 DOWNTO 0);   
   SIGNAL ping_lower_hw             :  std_logic_vector(AHB_DWIDTH - 1 DOWNTO 0);   
   SIGNAL ping_upper_hw             :  std_logic_vector(AHB_DWIDTH - 1 DOWNTO 0);   
   SIGNAL ping_lower_wreg          :  std_logic_vector(AHB_DWIDTH - 1 DOWNTO 0);   
   SIGNAL ping_upper_wreg          :  std_logic_vector(AHB_DWIDTH - 1 DOWNTO 0);   
   SIGNAL ping_lower_breg          :  std_logic_vector(AHB_DWIDTH - 1 DOWNTO 0);   
   SIGNAL ping_upper_breg          :  std_logic_vector(AHB_DWIDTH - 1 DOWNTO 0);   
   SIGNAL ping_lower_hwreg          :  std_logic_vector(AHB_DWIDTH - 1 DOWNTO 0);   
   SIGNAL ping_upper_hwreg          :  std_logic_vector(AHB_DWIDTH - 1 DOWNTO 0);   
   SIGNAL m2_wr_channel_rd_en_d    :  std_logic;   
   SIGNAL arlen_custom             :  std_logic_vector(4 DOWNTO 0);   
   SIGNAL arsize_8                 :  std_logic;   
   SIGNAL R_hreadyout              :  std_logic;   
   SIGNAL R_wrap_en                :  std_logic;   
   SIGNAL m2_htrans_c_r            :  std_logic_vector(1 DOWNTO 0);   
   SIGNAL s_htrans_c_r             :  std_logic_vector(1 DOWNTO 0);   
   SIGNAL s_htrans_c_r2             :  std_logic_vector(1 DOWNTO 0);   
   -------------------------------------------------------------------------------
   -- Assign AHB Bus signals
   -------------------------------------------------------------------------------
   SIGNAL temp_xhdl20              :  std_logic_vector(AHB_AWIDTH - 1 DOWNTO 0)
   ;   
   SIGNAL temp_xhdl21              :  std_logic;   
   SIGNAL temp_xhdl22              :  std_logic_vector(1 DOWNTO 0);   
   SIGNAL temp_xhdl23              :  std_logic_vector(2 DOWNTO 0);   
   SIGNAL temp_xhdl24              :  std_logic;   
   SIGNAL temp_xhdl25              :  std_logic_vector(2 DOWNTO 0);   
   SIGNAL temp_xhdl26              :  std_logic;   --  not supporting Exclusive access
   SIGNAL temp_xhdl27              :  std_logic;   
   SIGNAL temp_xhdl28              :  std_logic;   
   SIGNAL temp_xhdl29              :  std_logic_vector(AHB_DWIDTH - 1 DOWNTO 0)
   ;   
   SIGNAL temp_xhdl30              :  std_logic_vector(AHB_DWIDTH - 1 DOWNTO 0)
   ;   
   SIGNAL temp_xhdl31              :  std_logic_vector(AHB_DWIDTH - 1 DOWNTO 0)
   ;   
   SIGNAL temp_xhdl32              :  std_logic_vector(1 DOWNTO 0);   
   SIGNAL temp_xhdl33              :  std_logic_vector(1 DOWNTO 0);   
   SIGNAL temp_xhdl76              :  std_logic_vector(1 DOWNTO 0);   
   SIGNAL HSEL_xhdl1               :  std_logic;   
   SIGNAL HADDR_xhdl2              :  std_logic_vector(AHB_AWIDTH - 1 DOWNTO 0)
   ;   
   SIGNAL HWRITE_xhdl3             :  std_logic;   
   SIGNAL HTRANS_xhdl4             :  std_logic_vector(1 DOWNTO 0);   
   SIGNAL HSIZE_xhdl5              :  std_logic_vector(2 DOWNTO 0);   
   SIGNAL HWDATA_xhdl6             :  std_logic_vector(AHB_DWIDTH - 1 DOWNTO 0)
   ;   
   SIGNAL HBURST_xhdl7             :  std_logic_vector(2 DOWNTO 0);   
   SIGNAL HMASTLOCK_xhdl8          :  std_logic;   
   SIGNAL HREADYOUT_xhdl9          :  std_logic;   
   SIGNAL wrstb_ram_rd_en_xhdl10   :  std_logic;   
   SIGNAL wrstb_ram_rd_addr_xhdl11 :  std_logic_vector(3 DOWNTO 0);   
   SIGNAL ahb2wrchfifo_rd_en_xhdl12:  std_logic;   
   SIGNAL h_send_ahb_resp_en_r_xhdl13     :  std_logic;   
   SIGNAL hresp_err_count_xhdl14   :  std_logic_vector(4 DOWNTO 0);   
   SIGNAL wrch_fifo_rd_clear_xhdl15:  std_logic;   
   SIGNAL ahb2rdch_fifo_wr_en_xhdl16      :  std_logic;   
   SIGNAL ahb2rdch_fifo_wr_data_xhdl17    :  std_logic_vector(AHB_DWIDTH - 1 
   DOWNTO 0);   
   SIGNAL ahb2rdch_rd_resp_data_xhdl18    :  std_logic_vector(1 DOWNTO 0);   
   SIGNAL ahb2axi_ahb_read_done_r_xhdl19  :  std_logic;   
   SIGNAL s_write_en_d1                   :  std_logic;
   SIGNAL hwrite_r2                       :  std_logic;
BEGIN
   HSEL <= HSEL_xhdl1;
   HADDR <= HADDR_xhdl2;
   HWRITE <= HWRITE_xhdl3;
   HTRANS <= HTRANS_xhdl4;
   HSIZE <= HSIZE_xhdl5;
   HWDATA <= HWDATA_xhdl6;
   HBURST <= HBURST_xhdl7;
   HMASTLOCK <= HMASTLOCK_xhdl8;
   HREADYOUT <= HREADYOUT_xhdl9;
   wrstb_ram_rd_en <= wrstb_ram_rd_en_xhdl10;
   wrstb_ram_rd_addr <= wrstb_ram_rd_addr_xhdl11;
   ahb2wrchfifo_rd_en <= ahb2wrchfifo_rd_en_xhdl12;
   h_send_ahb_resp_en_r <= h_send_ahb_resp_en_r_xhdl13;
   hresp_err_count <= hresp_err_count_xhdl14;
   wrch_fifo_rd_clear <= wrch_fifo_rd_clear_xhdl15;
   ahb2rdch_fifo_wr_en <= ahb2rdch_fifo_wr_en_xhdl16;
   ahb2rdch_fifo_wr_data <= ahb2rdch_fifo_wr_data_xhdl17;
   ahb2rdch_rd_resp_data <= ahb2rdch_rd_resp_data_xhdl18;
   ahb2axi_ahb_read_done_r <= ahb2axi_ahb_read_done_r_xhdl19;

   -------------------------------------------------------------------------------
   -- Latch the AXI signals into AHB clock domain on AXI signal control pulse
   -------------------------------------------------------------------------------
   
   latch_axi_into_ahb : PROCESS (HCLK, HRESETn)

      FUNCTION floor (
         awaddr                  : IN std_logic_vector(AXI_AWIDTH - 1 DOWNTO 0)
         ;   
         awsize                  : IN std_logic_vector(2 DOWNTO 0)) RETURN 
         std_logic_vector IS
      
         VARIABLE floor        : std_logic_vector(AXI_AWIDTH - 1 DOWNTO 0);
      BEGIN
         CASE awsize(2 DOWNTO 0) IS
            WHEN "011" =>
                     floor := awaddr(AXI_AWIDTH - 1 DOWNTO 3) & "000";    
            WHEN "010" =>
                     IF (awaddr(2) = '0') THEN
                        floor := awaddr(AXI_AWIDTH - 1 DOWNTO 3) & "000";    
                     ELSE
                        IF (awaddr(2) = '1') THEN
                           floor := awaddr(AXI_AWIDTH - 1 DOWNTO 3) & "100";    
                        END IF;
                     END IF;
            WHEN "001" =>
                     IF (awaddr(2 DOWNTO 1) = "00") THEN
                        floor := awaddr(AXI_AWIDTH - 1 DOWNTO 3) & "000";    
                     ELSE
                        IF (awaddr(2 DOWNTO 1) = "01") THEN
                           floor := awaddr(AXI_AWIDTH - 1 DOWNTO 3) & "010";    
                        ELSE
                           IF (awaddr(2 DOWNTO 1) = "10") THEN
                              floor := awaddr(AXI_AWIDTH - 1 DOWNTO 3) & "100"; 
                           ELSE
                              IF (awaddr(2 DOWNTO 1) = "11") THEN
                                 floor := awaddr(AXI_AWIDTH - 1 DOWNTO 3) & 
                                 "110";    
                              END IF;
                           END IF;
                        END IF;
                     END IF;
            WHEN "000" =>
                     IF (awaddr(2 DOWNTO 0) = "000") THEN
                        floor := awaddr(AXI_AWIDTH - 1 DOWNTO 3) & "000";    
                     ELSE
                        IF (awaddr(2 DOWNTO 0) = "001") THEN
                           floor := awaddr(AXI_AWIDTH - 1 DOWNTO 3) & "001";    
                        ELSE
                           IF (awaddr(2 DOWNTO 0) = "010") THEN
                              floor := awaddr(AXI_AWIDTH - 1 DOWNTO 3) & "010"; 
                           ELSE
                              IF (awaddr(2 DOWNTO 0) = "011") THEN
                                 floor := awaddr(AXI_AWIDTH - 1 DOWNTO 3) & 
                                 "011";    
                              ELSE
                                 IF (awaddr(2 DOWNTO 0) = "100") THEN
                                    floor := awaddr(AXI_AWIDTH - 1 DOWNTO 3) & 
                                    "100";    
                                 ELSE
                                    IF (awaddr(2 DOWNTO 0) = "101") THEN
                                       floor := awaddr(AXI_AWIDTH - 1 DOWNTO 3) 
                                       & "101";    
                                    ELSE
                                       IF (awaddr(2 DOWNTO 0) = "110") THEN
                                          floor := awaddr(AXI_AWIDTH - 1 DOWNTO 
                                          3) & "110";    
                                       ELSE
                                          IF (awaddr(2 DOWNTO 0) = "111") THEN
                                             floor := awaddr(AXI_AWIDTH - 1 
                                             DOWNTO 3) & "111";    
                                          END IF;
                                       END IF;
                                    END IF;
                                 END IF;
                              END IF;
                           END IF;
                        END IF;
                     END IF;
            WHEN OTHERS  =>
                     floor := awaddr(AXI_AWIDTH - 1 DOWNTO 0);    
            
         END CASE;
         RETURN(floor);
      END FUNCTION floor;

      FUNCTION rd_floor (
         awaddr                  : IN std_logic_vector(AXI_AWIDTH - 1 DOWNTO 0)
         ;   
         awsize                  : IN std_logic_vector(2 DOWNTO 0)) RETURN 
         std_logic_vector IS
      
         VARIABLE rd_floor        : std_logic_vector(AXI_AWIDTH - 1 DOWNTO 0);
      BEGIN
         CASE awsize(2 DOWNTO 0) IS
            WHEN "011" =>
                     IF (awaddr(2) = '0') THEN
                        rd_floor := awaddr(AXI_AWIDTH - 1 DOWNTO 3) & "000";    
                     ELSE
                        IF (awaddr(2) = '1') THEN
                           rd_floor := awaddr(AXI_AWIDTH - 1 DOWNTO 3) & "100"; 
                        END IF;
                     END IF;
            WHEN "010" =>
                     IF (awaddr(2) = '0') THEN
                        rd_floor := awaddr(AXI_AWIDTH - 1 DOWNTO 3) & "000";    
                     ELSE
                        IF (awaddr(2) = '1') THEN
                           rd_floor := awaddr(AXI_AWIDTH - 1 DOWNTO 3) & "100"; 
                        END IF;
                     END IF;
            WHEN "001" =>
                     IF (awaddr(2 DOWNTO 1) = "00") THEN
                        rd_floor := awaddr(AXI_AWIDTH - 1 DOWNTO 3) & "000";    
                     ELSE
                        IF (awaddr(2 DOWNTO 1) = "01") THEN
                           rd_floor := awaddr(AXI_AWIDTH - 1 DOWNTO 3) & "010"; 
                        ELSE
                           IF (awaddr(2 DOWNTO 1) = "10") THEN
                              rd_floor := awaddr(AXI_AWIDTH - 1 DOWNTO 3) & 
                              "100";    
                           ELSE
                              IF (awaddr(2 DOWNTO 1) = "11") THEN
                                 rd_floor := awaddr(AXI_AWIDTH - 1 DOWNTO 3) & 
                                 "110";    
                              END IF;
                           END IF;
                        END IF;
                     END IF;
            WHEN "000" =>
                     IF (awaddr(2 DOWNTO 0) = "000") THEN
                        rd_floor := awaddr(AXI_AWIDTH - 1 DOWNTO 3) & "000";    
                     ELSE
                        IF (awaddr(2 DOWNTO 0) = "001") THEN
                           rd_floor := awaddr(AXI_AWIDTH - 1 DOWNTO 3) & "001"; 
                        ELSE
                           IF (awaddr(2 DOWNTO 0) = "010") THEN
                              rd_floor := awaddr(AXI_AWIDTH - 1 DOWNTO 3) & 
                              "010";    
                           ELSE
                              IF (awaddr(2 DOWNTO 0) = "011") THEN
                                 rd_floor := awaddr(AXI_AWIDTH - 1 DOWNTO 3) & 
                                 "011";    
                              ELSE
                                 IF (awaddr(2 DOWNTO 0) = "100") THEN
                                    rd_floor := awaddr(AXI_AWIDTH - 1 DOWNTO 3) 
                                    & "100";    
                                 ELSE
                                    IF (awaddr(2 DOWNTO 0) = "101") THEN
                                       rd_floor := awaddr(AXI_AWIDTH - 1 DOWNTO 
                                       3) & "101";    
                                    ELSE
                                       IF (awaddr(2 DOWNTO 0) = "110") THEN
                                          rd_floor := awaddr(AXI_AWIDTH - 1 
                                          DOWNTO 3) & "110";    
                                       ELSE
                                          IF (awaddr(2 DOWNTO 0) = "111") THEN
                                             rd_floor := awaddr(AXI_AWIDTH - 1 
                                             DOWNTO 3) & "111";    
                                          END IF;
                                       END IF;
                                    END IF;
                                 END IF;
                              END IF;
                           END IF;
                        END IF;
                     END IF;
            WHEN OTHERS  =>
                     rd_floor := awaddr(AXI_AWIDTH - 1 DOWNTO 0);    
            
         END CASE;
         RETURN(rd_floor);
      END FUNCTION rd_floor;
   BEGIN
      IF (HRESETn = '0') THEN
         axi2ahb_WID_r <= "0000";    
         axi2ahb_AWID_r <= "0000";    
         axi2ahb_AWADDR_r <= (OTHERS => '0');    
         axi2ahb_AWLEN_r <= "0000";    
         axi2ahb_AWSIZE_r <= "000";    
         axi2ahb_AWBURST_r <= "00";    
         axi2ahb_AWLOCK_r <= "00";    
      ELSIF (HCLK'EVENT AND HCLK = '1') THEN
         IF (axi2xhsync_awlatch_syn = '1') THEN
            axi2ahb_WID_r <= axi2ahb_WID;    
            axi2ahb_AWID_r <= axi2ahb_AWID;    
            --axi2ahb_AWADDR_r <= (others => '0');
            --axi2ahb_AWADDR_r(0) <= floor(axi2ahb_AWADDR, axi2ahb_AWSIZE)-- <<X-HDL>> Warning - Subprogram floor referenced before declared. Parameter size/type may be wrong
            --;    
            axi2ahb_AWADDR_r <= floor(axi2ahb_AWADDR, axi2ahb_AWSIZE);
	    axi2ahb_AWLEN_r <= axi2ahb_AWLEN;    
            axi2ahb_AWSIZE_r <= axi2ahb_AWSIZE;    
            axi2ahb_AWBURST_r <= axi2ahb_AWBURST;    
            axi2ahb_AWLOCK_r <= axi2ahb_AWLOCK;    
         END IF;
         IF (axi2xhsync_arlatch_syn = '1') THEN
            axi2ahb_ARID_r <= axi2ahb_AWID;    
            --axi2ahb_ARADDR_r  <= axi2ahb_AWADDR;
            
            --axi2ahb_ARADDR_r <= (others => '0');
            --axi2ahb_ARADDR_r(0) <= rd_floor(axi2ahb_AWADDR, axi2ahb_AWSIZE)-- <<X-HDL>> Warning - Subprogram rd_floor referenced before declared. Parameter size/type may be wrong
            --;
	    axi2ahb_ARADDR_r <= rd_floor(axi2ahb_AWADDR, axi2ahb_AWSIZE);
            axi2ahb_ARLEN_r <= axi2ahb_AWLEN;    
            axi2ahb_ARSIZE_r <= axi2ahb_AWSIZE;    
            axi2ahb_ARBURST_r <= axi2ahb_AWBURST;    
            axi2ahb_ARLOCK_r <= axi2ahb_AWLOCK;    
         END IF;
      END IF;
   END PROCESS latch_axi_into_ahb;

   -------------------------------------------------------------------------------
   -- Extract AXI size information and decide AHB Transfer size encoding
   -------------------------------------------------------------------------------
   
   set_ahb_hsize : PROCESS (HCLK, HRESETn)
   BEGIN
      IF (HRESETn = '0') THEN
         hsize_r(2 DOWNTO 0) <= "000";    
      ELSIF (HCLK'EVENT AND HCLK = '1') THEN
         --IF ((s_set_ahb_addr = '1') OR (s_set_ahb_addr_data = '1')) THEN
         IF ((((s_curr_state = S_GET_DATA) AND s_wait_count = "00"))  OR (s_set_ahb_addr = '1')) THEN  -- SAR#46417
--            CASE s_len_wr_count(2 DOWNTO 0) IS
--               WHEN "000" =>
--                        hsize_r(2 DOWNTO 0) <= "0" & trans_size_0;    --  Byte transfer
--               WHEN "001" =>
--                        hsize_r(2 DOWNTO 0) <= "0" & trans_size_1;    --  Halfword transfer
--               WHEN "010" =>
--                        hsize_r(2 DOWNTO 0) <= "0" & trans_size_2;    --  Word transfer
--               WHEN "011" =>
--                        hsize_r(2 DOWNTO 0) <= "0" & trans_size_2;    --  Word transfer (double words are converted into two word transfers)
--               WHEN OTHERS  =>
--                        hsize_r(2 DOWNTO 0) <= "000";    
--               
--            END CASE;

            CASE axi2ahb_AWSIZE_r(2 DOWNTO 0) IS
               WHEN "000" =>
                        hsize_r(2 DOWNTO 0) <= "000";    --  Byte transfer
               WHEN "001" =>
                        hsize_r(2 DOWNTO 0) <= "001";    --  Halfword transfer
               WHEN "010" =>
                        hsize_r(2 DOWNTO 0) <= "010";    --  Word transfer
               WHEN "011" =>
                        hsize_r(2 DOWNTO 0) <= "010";    --  Word transfer (double words are converted into two word transfers)
               WHEN OTHERS  =>
                        hsize_r(2 DOWNTO 0) <= "000";    
               
            END CASE;		 
         ELSE
            IF (m2_set_ahb_addr = '1') THEN
               IF (axi2ahb_AWSIZE_r(1 DOWNTO 0) > "10") THEN
                  hsize_r(2 DOWNTO 0) <= "010";    
               ELSE
                  hsize_r(2 DOWNTO 0) <= axi2ahb_AWSIZE_r(2 DOWNTO 0);    
               END IF;
            END IF;
         END IF;
      END IF;
   END PROCESS set_ahb_hsize;

   temp_xhdl20 <= R_haddr_r(AHB_AWIDTH - 1 DOWNTO 0) WHEN (R_read_cycle_en) = 
   '1' ELSE haddr_r(AHB_AWIDTH - 1 DOWNTO 0);
   HADDR_xhdl2 <= temp_xhdl20 ;
   temp_xhdl21 <= R_hread_r WHEN (R_read_cycle_en) = '1' ELSE hwrite_r;
   HWRITE_xhdl3 <= temp_xhdl21 ;
   temp_xhdl22 <= R_htrans_r(1 DOWNTO 0) WHEN (R_read_cycle_en) = '1' ELSE 
   htrans_r(1 DOWNTO 0);
   HTRANS_xhdl4 <= temp_xhdl22 ;
   temp_xhdl23 <= R_hsize_r(2 DOWNTO 0) WHEN (R_read_cycle_en) = '1' ELSE 
   hsize_r(2 DOWNTO 0);
   HSIZE_xhdl5 <= temp_xhdl23 ;
   HWDATA_xhdl6 <= hwdata_r(AHB_DWIDTH - 1 DOWNTO 0) ;
   temp_xhdl24 <= R_hreadyout WHEN (R_read_cycle_en) = '1' ELSE hreadyout_r;
   HREADYOUT_xhdl9 <= temp_xhdl24 ;
   temp_xhdl25 <= R_hburst_r(2 DOWNTO 0) WHEN (R_read_cycle_en) = '1' ELSE 
   hburst_r(2 DOWNTO 0);
   HBURST_xhdl7 <= temp_xhdl25 ;
   temp_xhdl26 <= axi2ahb_ARLOCK_r(1) WHEN (R_read_cycle_en) = '1' ELSE 
   axi2ahb_AWLOCK_r(1);
   HMASTLOCK_xhdl8 <= temp_xhdl26 ;
   temp_xhdl27 <= '1' WHEN (R_read_cycle_en) = '1' ELSE h_hsel_write_r;
   HSEL_xhdl1 <= temp_xhdl27 ;

   PROCESS (HCLK, HRESETn)
   BEGIN
      -- 14/02/13 - 1B CHANGE
      
      IF (HRESETn = '0') THEN
         s_htrans_c_r <= "00";    
         s_htrans_c_r2 <= "00";    
         m2_htrans_c_r <= "00";    
      ELSIF (HCLK'EVENT AND HCLK = '1') THEN
         s_htrans_c_r <= s_htrans_c;    
         s_htrans_c_r2 <= s_htrans_c_r;    -- SAR#46417
         m2_htrans_c_r <= m2_htrans_c;    
      END IF;
   END PROCESS;

   PROCESS (m2_curr_state,  
   s_single_tras_active,  
   m2_htrans_c_r, m2_burst_size_c, 
   s_htrans_c_r,  m2_set_ahb_addr,
   m2_single_tras_active  
   )
   BEGIN
      -- 14/02/13 - 1B CHANGE
      
      IF (((m2_set_ahb_addr AND CONV_STD_LOGIC((m2_curr_state = M2_SEND_AD0) OR 
      (m2_curr_state = M2_SEND_AD1))) OR s_single_tras_active) = '1') THEN
         IF (s_single_tras_active = '1') THEN
            hburst_r <= "000";    
         ELSE
            hburst_r <= m2_burst_size_c;    
         END IF;

         --IF (s_single_tras_active = '1') THEN
         IF (s_single_tras_active = '1' AND s_set_ahb_addr_data = '1') THEN  -- SAR#46417
            --htrans_r <= s_htrans_c_r(1 DOWNTO 0);    
           IF (axi2ahb_AWSIZE(2 downto 0) = "000" AND axi2ahb_AWLEN(3 downto 0) = "0000") THEN
              htrans_r <= s_htrans_c(1 DOWNTO 0);    
           ELSE
              htrans_r <= s_htrans_c(1 DOWNTO 0);    
           END	IF;
	 ELSIF (m2_single_tras_active = '1') THEN
              htrans_r <= m2_htrans_c_r(1 DOWNTO 0);    
         ELSE
              htrans_r <= "00";    
         END IF;         
      ELSE
         htrans_r <= "00";    
         hburst_r <= "000";    
      END IF;
   END PROCESS;

   -------------------------------------------------------------------------------
   -------------------------------------------------------------------------------
   
   PROCESS (HCLK, HRESETn)

      FUNCTION ahb_addr (
         ahb_start_addr          : IN std_logic_vector(AHB_AWIDTH - 1 DOWNTO 0)
         ;   
         previous_haddr          : IN std_logic_vector(AHB_AWIDTH - 1 DOWNTO 0)
         ;   
         adr_incr                : IN std_logic_vector(2 DOWNTO 0);   
         length                  : IN std_logic_vector(2 DOWNTO 0)) RETURN 
         std_logic_vector IS
      
         VARIABLE ahb_addr        : std_logic_vector(AHB_AWIDTH - 1 DOWNTO 0);
      BEGIN
         IF (adr_incr = "000") THEN
            ahb_addr := previous_haddr + "00000000000000000000000000000100";    
         END IF;
         IF (adr_incr = "001") THEN
            CASE length(2 DOWNTO 0) IS
               WHEN "000" =>
                        ahb_addr := ahb_start_addr + 
                        "00000000000000000000000000000001";    
               WHEN "001" =>
                        ahb_addr := ahb_start_addr + 
                        "00000000000000000000000000000010";    
               WHEN "010" =>
                        ahb_addr := ahb_start_addr + 
                        "00000000000000000000000000000100";    
               WHEN OTHERS  =>
                        ahb_addr := ahb_addr;    
               
            END CASE;
         END IF;
         IF (adr_incr = "010") THEN
            CASE length(2 DOWNTO 0) IS
               WHEN "000" =>
                        ahb_addr := ahb_start_addr + 
                        "00000000000000000000000000000010";    
               WHEN "001" =>
                        ahb_addr := ahb_start_addr + 
                        "00000000000000000000000000000100";    
               WHEN OTHERS  =>
                        ahb_addr := ahb_addr;    
               
            END CASE;
         END IF;
         IF (adr_incr = "011") THEN
            CASE length(2 DOWNTO 0) IS
               WHEN "000" =>
                        ahb_addr := ahb_start_addr + 
                        "00000000000000000000000000000011";    
               WHEN "001" =>
                        ahb_addr := ahb_start_addr + 
                        "00000000000000000000000000000100";    
               WHEN OTHERS  =>
                        ahb_addr := ahb_addr;    
               
            END CASE;
         END IF;
         IF (adr_incr = "100") THEN
            CASE length(2 DOWNTO 0) IS
               WHEN "000" =>
                        ahb_addr := ahb_start_addr + 
                        "00000000000000000000000000000100";    
               WHEN OTHERS  =>
                        ahb_addr := ahb_addr;    
               
            END CASE;
         END IF;
         IF (adr_incr = "101") THEN
            CASE length(2 DOWNTO 0) IS
               WHEN "000" =>
                        ahb_addr := ahb_start_addr + 
                        "00000000000000000000000000000101";    
               WHEN "001" =>
                        ahb_addr := ahb_start_addr + 
                        "00000000000000000000000000000110";    
               WHEN OTHERS  =>
                        ahb_addr := ahb_addr;    
               
            END CASE;
         END IF;
         IF (adr_incr = "110") THEN
            CASE length(2 DOWNTO 0) IS
               WHEN "000" =>
                        ahb_addr := ahb_start_addr + 
                        "00000000000000000000000000000110";    
               WHEN OTHERS  =>
                        ahb_addr := ahb_addr;    
               
            END CASE;
         END IF;
         IF (adr_incr = "111") THEN
            CASE length(2 DOWNTO 0) IS
               WHEN "000" =>
                        ahb_addr := ahb_start_addr + 
                        "00000000000000000000000000000111";    
               WHEN OTHERS  =>
                        ahb_addr := ahb_addr;    
               
            END CASE;
         END IF;
         RETURN(ahb_addr);
      END FUNCTION ahb_addr;

      --//////////////////////////////////
      FUNCTION m2_ahb_addr (
         m2_ahb_start_addr       : IN std_logic_vector(AHB_AWIDTH - 1 DOWNTO 0)
         ;   
         axi2ahb_AWSIZE_r        : IN std_logic_vector(1 DOWNTO 0)) RETURN 
         std_logic_vector IS
      
         VARIABLE start_addr             :  std_logic_vector(AHB_AWIDTH - 1 
         DOWNTO 0);   
         VARIABLE m2_ahb_addr        : std_logic_vector(AHB_AWIDTH - 1 DOWNTO 0)
         ;
      BEGIN
         IF (axi2ahb_AWSIZE_r(1) = '1') THEN
            IF (m2_ahb_start_addr(2 DOWNTO 0) = "110") THEN
               start_addr := m2_ahb_start_addr(AHB_AWIDTH - 1 DOWNTO 0) - 
               "00000000000000000000000000000010";    
            ELSE
               IF (m2_ahb_start_addr(2 DOWNTO 0) = "111") THEN
                  start_addr := m2_ahb_start_addr(AHB_AWIDTH - 1 DOWNTO 0) - 
                  "00000000000000000000000000000011";    
               ELSE
                  start_addr := m2_ahb_start_addr(AHB_AWIDTH - 1 DOWNTO 0);    
               END IF;
            END IF;
         ELSE
            start_addr := m2_ahb_start_addr(AHB_AWIDTH - 1 DOWNTO 0);    
         END IF;
         CASE axi2ahb_AWSIZE_r(1 DOWNTO 0) IS
            WHEN "11" =>
                     m2_ahb_addr := start_addr + 
                     "00000000000000000000000000000100";    
            WHEN "10" =>
                     m2_ahb_addr := start_addr + 
                     "00000000000000000000000000000100";    
            WHEN "01" =>
                     m2_ahb_addr := start_addr + 
                     "00000000000000000000000000000010";    
            WHEN "00" =>
                     m2_ahb_addr := start_addr + 
                     "00000000000000000000000000000001";    
            WHEN OTHERS  =>
                     m2_ahb_addr := start_addr;    
            
         END CASE;
         RETURN(m2_ahb_addr);
      END FUNCTION m2_ahb_addr;
   BEGIN
      IF (HRESETn = '0') THEN
         haddr_r <= (OTHERS => '0');    
      ELSIF (HCLK'EVENT AND HCLK = '1') THEN
         IF ((((remaining_dec_en) AND CONV_STD_LOGIC(m2_next_state = 
         M2_SEND_AD0)) AND CONV_STD_LOGIC(m2_curr_state = M2_DECIDE_CYC)) = '1')
         THEN
            IF (axi2ahb_AWSIZE_r(1 DOWNTO 0) = "10") THEN
               -- word transfer
               
               IF (m2_htrans_c = "10") THEN
--                  IF ((wr_strobe(3 DOWNTO 0) = "0000") OR ((wrch_fifo_rd_data_wrstb(3 DOWNTO 0) = "0000") AND (wrch_fifo_rd_data_wrstb(7 DOWNTO 4) /= "0000"))) THEN  -- SAR#46417
		  IF ((wr_strobe(3 DOWNTO 0) = "0000")) THEN   -- for SAR#46417		       
                     IF (axi2ahb_AWADDR_r(2 DOWNTO 0) = "100") THEN
                        haddr_r <= axi2ahb_AWADDR_r(AHB_AWIDTH - 1 DOWNTO 0);   
                     ELSE
                        haddr_r <= axi2ahb_AWADDR_r(AHB_AWIDTH - 1 DOWNTO 0) + 
                        "00000000000000000000000000000100";    
                     END IF;
                  ELSE
                     IF (((wr_strobe(1 DOWNTO 0) = "00") AND (wr_strobe(7 
                     DOWNTO 4) = "0000")) OR ((wrch_fifo_rd_data_wrstb(1 DOWNTO 
                     0) = "00") AND (wrch_fifo_rd_data_wrstb(7 DOWNTO 2) /= 
                     "000000"))) THEN
                        haddr_r <= axi2ahb_AWADDR_r(AHB_AWIDTH - 1 DOWNTO 0) + 
                        "00000000000000000000000000000010";    
                     END IF;
                  END IF;
               ELSE
                  haddr_r <= axi2ahb_AWADDR_r(AHB_AWIDTH - 1 DOWNTO 0);    
               END IF;
            ELSE
               IF (axi2ahb_AWSIZE_r(1 DOWNTO 0) = "01") THEN       
                  -- halfword transfer
                  
                  IF (m2_htrans_c = "10") THEN
                     --IF ((wr_strobe(5 DOWNTO 0) = "000000") OR ((wrch_fifo_rd_data_wrstb(5 DOWNTO 0) = "000000") AND (wrch_fifo_rd_data_wrstb(7 DOWNTO 6) /= "00"))) THEN  -- for hword 02/03/13
                     IF ((wr_strobe(5 DOWNTO 0) = "000000")) THEN
                        IF (axi2ahb_AWADDR_r(2 DOWNTO 0) = "110") THEN
                           haddr_r <= axi2ahb_AWADDR_r(AHB_AWIDTH - 1 DOWNTO 0)
                           ;    
                        ELSE
                           IF (axi2ahb_AWADDR_r(2 DOWNTO 0) = "100") THEN
                              haddr_r <= axi2ahb_AWADDR_r(AHB_AWIDTH - 1 DOWNTO 
                              0) + "00000000000000000000000000000010";    
                           ELSE
                              haddr_r <= axi2ahb_AWADDR_r(AHB_AWIDTH - 1 DOWNTO 
                              0) + "00000000000000000000000000000110";    
                           END IF;
                        END IF;
                     ELSE
                        --IF (((wr_strobe(7 DOWNTO 4) = "0000") AND (wr_strobe(1 DOWNTO 0) = "00")) OR (((wrch_fifo_rd_data_wrstb(7 DOWNTO 4) = "0000") AND (wrch_fifo_rd_data_wrstb(1 
                        IF (((wr_strobe(7 DOWNTO 4) = "0000") AND (wr_strobe(1 DOWNTO 0) = "00"))) THEN
                           IF (axi2ahb_AWADDR_r(2 DOWNTO 0) = "010") THEN
                              haddr_r <= axi2ahb_AWADDR_r(AHB_AWIDTH - 1 DOWNTO 
                              0);    
                           ELSE
                              haddr_r <= axi2ahb_AWADDR_r(AHB_AWIDTH - 1 DOWNTO 
                              0) + "00000000000000000000000000000010";    
                           END IF;
                        ELSE
                           --IF (((wr_strobe(7 DOWNTO 6) = "00") AND (wr_strobe(3 DOWNTO 0) = "0000")) OR (((wrch_fifo_rd_data_wrstb(7 DOWNTO 6) = "00") AND (wrch_fifo_rd_data_wrstb(3 DOWNTO 0) = "0000")) AND (wrch_fifo_rd_data_wrstb(5 DOWNTO 4) /= "00"))) THEN
                           IF (((wr_strobe(7 DOWNTO 6) = "00") AND (wr_strobe(3 DOWNTO 0) = "0000"))) THEN
                              IF (axi2ahb_AWADDR_r(2 DOWNTO 0) = "100") THEN
                                 haddr_r <= axi2ahb_AWADDR_r(AHB_AWIDTH - 1 
                                 DOWNTO 0);    
                              ELSE
                                 haddr_r <= axi2ahb_AWADDR_r(AHB_AWIDTH - 1 
                                 DOWNTO 0) + 
                                 "00000000000000000000000000000100";    
                              END IF;
                           END IF;
                        END IF;
                     END IF;
                  ELSE
                     haddr_r <= axi2ahb_AWADDR_r(AHB_AWIDTH - 1 DOWNTO 0);    
                  END IF;
               ELSE
                  IF (axi2ahb_AWSIZE_r(1 DOWNTO 0) = "00") THEN
                     -- byte transfer
                     
                     IF (m2_htrans_c = "10") THEN
                        --IF ((wr_strobe(7 DOWNTO 0) = "00000010") OR (wrch_fifo_rd_data_wrstb(7 DOWNTO 0) = "00000010")) // 02/03/13 - for byte
                        IF ((wr_strobe(7 DOWNTO 0) = "00000010")) 
                        THEN
                           IF (axi2ahb_AWADDR_r(2 DOWNTO 0) = "001") THEN
                              haddr_r <= axi2ahb_AWADDR_r(AHB_AWIDTH - 1 DOWNTO
                              0);    
                           ELSE
                              haddr_r <= axi2ahb_AWADDR_r(AHB_AWIDTH - 1 DOWNTO 
                              0) + "00000000000000000000000000000001";    
                           END IF;
                        END IF;
                        --IF ((wr_strobe(7 DOWNTO 0) = "00000100") OR (wrch_fifo_rd_data_wrstb(7 DOWNTO 0) = "00000100")) 
                        IF ((wr_strobe(7 DOWNTO 0) = "00000100") ) 
                        THEN
                           IF (axi2ahb_AWADDR_r(2 DOWNTO 0) = "010") THEN
                              haddr_r <= axi2ahb_AWADDR_r(AHB_AWIDTH - 1 DOWNTO 
                              0);    
                           ELSE
                              haddr_r <= axi2ahb_AWADDR_r(AHB_AWIDTH - 1 DOWNTO 
                              0) + "00000000000000000000000000000010";    
                           END IF;
                        END IF;
                        --IF ((wr_strobe(7 DOWNTO 0) = "00001000") OR (wrch_fifo_rd_data_wrstb(7 DOWNTO 0) = "00001000")) 
                        IF ((wr_strobe(7 DOWNTO 0) = "00001000") ) 
                        THEN
                           IF (axi2ahb_AWADDR_r(2 DOWNTO 0) = "011") THEN
                              haddr_r <= axi2ahb_AWADDR_r(AHB_AWIDTH - 1 DOWNTO 
                              0);    
                           ELSE
                              haddr_r <= axi2ahb_AWADDR_r(AHB_AWIDTH - 1 DOWNTO 
                              0) + "00000000000000000000000000000011";    
                           END IF;
                        END IF;
                        --IF ((wr_strobe(7 DOWNTO 0) = "00010000") OR (wrch_fifo_rd_data_wrstb(7 DOWNTO 0) = "00010000")) 
                        IF ((wr_strobe(7 DOWNTO 0) = "00010000") ) 
                        THEN
                           IF (axi2ahb_AWADDR_r(2 DOWNTO 0) = "100") THEN
                              haddr_r <= axi2ahb_AWADDR_r(AHB_AWIDTH - 1 DOWNTO 
                              0);    
                           ELSE
                              haddr_r <= axi2ahb_AWADDR_r(AHB_AWIDTH - 1 DOWNTO 
                              0) + "00000000000000000000000000000100";    
                           END IF;
                        END IF;
                        --IF ((wr_strobe(7 DOWNTO 0) = "00100000") OR (wrch_fifo_rd_data_wrstb(7 DOWNTO 0) = "00100000")) 
                        IF ((wr_strobe(7 DOWNTO 0) = "00100000") ) 
                        THEN
                           IF (axi2ahb_AWADDR_r(2 DOWNTO 0) = "101") THEN
                              haddr_r <= axi2ahb_AWADDR_r(AHB_AWIDTH - 1 DOWNTO 
                              0);    
                           ELSE
                              haddr_r <= axi2ahb_AWADDR_r(AHB_AWIDTH - 1 DOWNTO 
                              0) + "00000000000000000000000000000101";    
                           END IF;
                        END IF;
                        --IF ((wr_strobe(7 DOWNTO 0) = "01000000") OR (wrch_fifo_rd_data_wrstb(7 DOWNTO 0) = "01000000")) 
                        IF ((wr_strobe(7 DOWNTO 0) = "01000000")) 
                        THEN
                           IF (axi2ahb_AWADDR_r(2 DOWNTO 0) = "110") THEN
                              haddr_r <= axi2ahb_AWADDR_r(AHB_AWIDTH - 1 DOWNTO 
                              0);    
                           ELSE
                              haddr_r <= axi2ahb_AWADDR_r(AHB_AWIDTH - 1 DOWNTO 
                              0) + "00000000000000000000000000000110";    
                           END IF;
                        END IF;
                        --IF ((wr_strobe(7 DOWNTO 0) = "10000000") OR (wrch_fifo_rd_data_wrstb(7 DOWNTO 0) = "10000000")) 
                        IF ((wr_strobe(7 DOWNTO 0) = "10000000") ) 
                        THEN
                           IF (axi2ahb_AWADDR_r(2 DOWNTO 0) = "111") THEN
                              haddr_r <= axi2ahb_AWADDR_r(AHB_AWIDTH - 1 DOWNTO 
                              0);    
                           ELSE
                              haddr_r <= axi2ahb_AWADDR_r(AHB_AWIDTH - 1 DOWNTO 
                              0) + "00000000000000000000000000000111";    
                           END IF;
                        END IF;
                     ELSE
                        haddr_r <= axi2ahb_AWADDR_r(AHB_AWIDTH - 1 DOWNTO 0);   
                     END IF;
                  END IF;
               END IF;
            END IF;
         ELSE
             IF ((H_next_state = H_RD_RAM) AND (H_curr_state = H_IDLE)) THEN
               haddr_r <= axi2ahb_AWADDR_r(AHB_AWIDTH - 1 DOWNTO 0);    
--            ELSE
--               IF (((m2_set_ahb_addr OR s_single_tras_active) = '1' ) AND (HREADYIN = '1') AND (htrans_r /= "00"))  
--               THEN
--                  IF ((s_set_ahb_addr = '1') OR (s_set_ahb_addr_data = '1')) THEN
--                     haddr_r(AHB_AWIDTH - 1 DOWNTO 0) <= ahb_addr(axi2ahb_AWADDR_r, haddr_r, addr_incr(2 DOWNTO 0), s_len_wr_count(2 DOWNTO 0));
--                  ELSE
--                     IF ((m2_next_state = M2_SEND_AD0) OR (m2_next_state = M2_SEND_AD1)) THEN
--			haddr_r(AHB_AWIDTH - 1 DOWNTO 0) <= m2_ahb_addr(haddr_r, axi2ahb_AWSIZE_r(1 DOWNTO 0));
--                     ELSE
--                        haddr_r(AHB_AWIDTH - 1 DOWNTO 0) <= haddr_r(AHB_AWIDTH - 1 DOWNTO 0);    
--                     END IF;
--                  END IF;
                  --------------------------------------  SAR#46417 
             ELSIF ((m2_set_ahb_addr = '1' ) AND (HREADYIN = '1') AND (htrans_r /= "00")) THEN
                  IF ((m2_next_state = M2_SEND_AD0) OR (m2_next_state = M2_SEND_AD1)) THEN
			haddr_r(AHB_AWIDTH - 1 DOWNTO 0) <= m2_ahb_addr(haddr_r, axi2ahb_AWSIZE_r(1 DOWNTO 0));
                  ELSE 
                        haddr_r(AHB_AWIDTH - 1 DOWNTO 0) <= haddr_r(AHB_AWIDTH - 1 DOWNTO 0);    
	          END IF;
	     ELSIF ((s_single_tras_active = '1' ) AND (HREADYIN = '1') AND (htrans_r /= "00")) THEN
                  IF ((s_set_ahb_addr = '1') OR (s_set_ahb_addr_data = '1')) THEN
			haddr_r(AHB_AWIDTH - 1 DOWNTO 0) <= axi2ahb_AWADDR_r(AHB_AWIDTH - 1 DOWNTO 0);
                  ELSE 
                        haddr_r(AHB_AWIDTH - 1 DOWNTO 0) <= haddr_r(AHB_AWIDTH - 1 DOWNTO 0);  
	          END IF;	
	     --END IF;


	       ------------------------------------------
             ELSE
                  IF ((m2_next_state = M2_SEND_AD0) AND (m2_curr_state = M2_DECIDE_CYC)) THEN
                     IF ((m2_htrans_c = "10") AND (axi2ahb_AWSIZE_r(1 DOWNTO 0) = "10")) THEN
                        IF (haddr_r(3 DOWNTO 0) = "0110") THEN
                           haddr_r <= haddr_r(AHB_AWIDTH - 1 DOWNTO 0) + 
                           "00000000000000000000000000000010";    
                        ELSE
                           IF (haddr_r(3 DOWNTO 0) = "0111") THEN
                              haddr_r <= haddr_r(AHB_AWIDTH - 1 DOWNTO 0) + 
                              "00000000000000000000000000000001";    
                           END IF;
                        END IF;
                     END IF;
                  END IF;
              END IF;
            END IF;
         END IF;
   END PROCESS;
   temp_xhdl28 <= m2_ahb_addr_set WHEN (axi2ahb_AWSIZE_r = "011") ELSE 
   m2_ahb_addr_set_r;
   m2_ahb_addr_set_custom <= temp_xhdl28 ;

   -------------------------------------------------------------------------------
   --
   -------------------------------------------------------------------------------
   
   PROCESS (m2_curr_state,  
   m2_set_ahb_addr, 
   s_write_en 
   )
   BEGIN
      --14/02/13 - 1B CHANGE
      
      --IF ((s_write_en OR ((m2_set_ahb_addr AND CONV_STD_LOGIC(m2_curr_state = M2_SEND_AD0)) OR CONV_STD_LOGIC(m2_curr_state = M2_SEND_AD1))) = '1') 
      IF ((s_write_en_d1 OR ((m2_set_ahb_addr AND CONV_STD_LOGIC(m2_curr_state = M2_SEND_AD0)) OR CONV_STD_LOGIC(m2_curr_state = M2_SEND_AD1))) = '1')  -- SAR#46417
      THEN
         hwrite_r <= '1';    
      ELSE
         hwrite_r <= '0';    
      END IF;
   END PROCESS;
   temp_xhdl29 <= hwdata_1 WHEN (axi2ahb_AWSIZE_r(1 DOWNTO 0) = "11") ELSE 
   hwdata_2;

   PROCESS (HCLK, HRESETn)  -- SAR#46417
   BEGIN
      IF (HRESETn = '0') THEN
         s_write_en_d1 <= '0';    
         hwrite_r2     <= '0';    
      ELSIF (HCLK'EVENT AND HCLK = '1') THEN
         s_write_en_d1 <= s_write_en;    
         hwrite_r2     <= hwrite_r;    
      END IF;
   END PROCESS;


   PROCESS (HCLK, HRESETn)
   BEGIN
      IF (HRESETn = '0') THEN
         --hwrite_r       <= 1'b0;                 //14/02/13 - 1B CHANGE
         
         hwdata_r <= (OTHERS => '0');    
         hreadyout_r <= '0';    
         h_hsel_write_r <= '0';    
         m2_multi_trans_done_r <= '0';    
         h_send_ahb_resp_en_r_xhdl13 <= '0';    
         m2_ahb_addr_set_r <= '0';    
         wrch2ahb_fifo_empty_r <= '0';    
         h_start_multiple_transfer_d <= '0';    
         h_start_multiple_transfer_d1 <= '0';    
      ELSIF (HCLK'EVENT AND HCLK = '1') THEN
         --h_hsel_write_r <= h_hsel_write; 
	 IF (h_hsel_write = '1') THEN  -- SAR#46417
           h_hsel_write_r <= '1'; 
         ELSE
	   IF(s_curr_state = S_IDLE AND HREADYIN = '1') THEN
             h_hsel_write_r <= '0'; 
           END IF;
	 END IF;

         hreadyout_r <= s_write_en OR m2_set_ahb_addr;    
         h_start_multiple_transfer_d <= h_start_multiple_transfer;    
         h_start_multiple_transfer_d1 <= h_start_multiple_transfer_d;    
         m2_multi_trans_done_r <= m2_multi_trans_done;    
         h_send_ahb_resp_en_r_xhdl13 <= h_send_ahb_resp_en;    
         m2_ahb_addr_set_r <= m2_ahb_addr_set;    
         wrch2ahb_fifo_empty_r <= wrch2ahb_fifo_empty;    

         -- 24/02/13 - 2J - pingpong
	 IF (axi2ahb_AWSIZE_r(1 DOWNTO 0) = "11") THEN 
	    IF ((s_set_ahb_addr_data = '1') OR ((m2_set_ahb_addr = '1') AND ((m2_curr_state = M2_SEND_AD0) OR (m2_curr_state = M2_SEND_AD1)))) THEN
	       IF ((m2_prev_state = M2_SEND_AD1) AND (m2_curr_state = M2_SEND_AD0)) THEN
                 IF(haddr_r(2) = '0') THEN
                   hwdata_r <= ahb2wrchfifo_rddata(AHB_DWIDTH-1 DOWNTO 0);                                            
  	         ELSE
                   hwdata_r <= wrch_fifo_rd_data(AXI_DWIDTH-1 DOWNTO AHB_DWIDTH);
                 END IF;
	       ELSIF ((m2_prev_state = M2_SEND_AD0) AND (m2_curr_state = M2_SEND_AD1)) THEN
                 IF(haddr_r(2) = '1') THEN
                   hwdata_r <= hwdata_1;                                            
  	         ELSE
                   hwdata_r <= wrch_fifo_rd_data(AXI_DWIDTH-1 DOWNTO AHB_DWIDTH);
                 END IF;
               --END IF;
               --ELSIF(NOT((m2_prev_state = M2_SEND_AD0) AND (m2_curr_state = M2_SEND_AD1))) THEN
               ELSIF(NOT((m2_prev_state = M2_SEND_AD0) AND (m2_curr_state = M2_SEND_AD1))) THEN
                 IF(haddr_r(2) = '0') THEN
                   hwdata_r <= wrch_fifo_rd_data(AHB_DWIDTH-1 DOWNTO 0);                                            
  	         ELSE
                   hwdata_r <= wrch_fifo_rd_data(AXI_DWIDTH-1 DOWNTO AHB_DWIDTH);
                 END IF;
               END IF;               
            END IF;	       
         --THEN
         --   hwdata_r <= temp_xhdl29;    
         ELSE 
          IF((axi2ahb_AWSIZE_r(1 DOWNTO 0) = "10")) THEN   -- WORD
             IF ((s_set_ahb_addr_data = '1') OR ((m2_set_ahb_addr = '1') AND (m2_curr_state = M2_SEND_AD0))) THEN
               IF(haddr_r(2) = '1') THEN
                 hwdata_r <= ping_upper_w; 
	       ELSE
                 hwdata_r <= ping_lower_w;
               END IF;
             ELSIF ((s_set_ahb_addr_data = '1') OR ((m2_set_ahb_addr = '1') AND (m2_curr_state = M2_SEND_AD1))) THEN
               IF(haddr_r(2) = '1') THEN
                 hwdata_r <= ping_upper_w; 
	       ELSE
                 hwdata_r <= ping_lower_w;
               END IF;
             END IF;

--          ELSIF((axi2ahb_AWSIZE_r(1 DOWNTO 0) = "00")) THEN   -- for byte 02/03/13
--             IF ((s_set_ahb_addr_data = '1') OR ((m2_set_ahb_addr = '1') AND ((m2_curr_state = M2_SEND_AD0) OR (m2_curr_state = M2_SEND_AD1)))) THEN
--	       IF ((m2_prev_state = M2_SEND_AD1) AND (m2_curr_state = M2_SEND_AD0) AND (HREADYIN = '1')) THEN
--                 IF(haddr_r(2 DOWNTO 0) >= "100") THEN
--                   hwdata_r <= ahb2wrchfifo_rddata(AXI_DWIDTH-1 DOWNTO AHB_DWIDTH);                                            
--  	         ELSE
--                   hwdata_r <= ahb2wrchfifo_rddata(AHB_DWIDTH-1 DOWNTO 0);
--                 END IF;
--	       ELSIF ((m2_prev_state = M2_SEND_AD0) AND (m2_curr_state = M2_SEND_AD1) AND (HREADYIN = '1')) THEN
--                 IF(haddr_r(2 DOWNTO 0) >= "100") THEN
--                   hwdata_r <= ahb2wrchfifo_rddata(AXI_DWIDTH-1 DOWNTO AHB_DWIDTH);                                            
--  	         ELSE
--                   hwdata_r <= ahb2wrchfifo_rddata(AHB_DWIDTH-1 DOWNTO 0);
--                 END IF;
--               ELSE
--                 IF(haddr_r(2 DOWNTO 0) >= "100") THEN
--                   hwdata_r <= wrch_fifo_rd_data(AXI_DWIDTH-1 DOWNTO AHB_DWIDTH); 
--	         ELSE
--                   hwdata_r <= wrch_fifo_rd_data(AHB_DWIDTH-1 DOWNTO 0);
--                 END IF;
--               END IF;
--             END IF;

-- SAR#46417	     
          ELSIF((axi2ahb_AWSIZE_r(1 DOWNTO 0) = "00")) THEN   -- for byte 02/03/13
             IF ((s_set_ahb_addr_data = '1') AND (axi2ahb_AWLEN_r(3 DOWNTO 0) = "0000")) THEN
               IF(haddr_r(2 DOWNTO 0) >= "100") THEN
                 hwdata_r <= ping_upper_b; 
	       ELSE
                 hwdata_r <= ping_lower_b;
               END IF;
             END IF;

             IF (((m2_set_ahb_addr = '1') AND ((m2_curr_state = M2_SEND_AD0) OR (m2_curr_state = M2_SEND_AD1)))) THEN
               IF (((m2_set_ahb_addr = '1') AND (m2_curr_state = M2_SEND_AD0))) THEN
                 IF(haddr_r(2) >= '1') THEN
                   hwdata_r <= ping_upper_b; 
	         ELSE
                   hwdata_r <= ping_lower_b;
                 END IF;
	       ELSIF (((m2_set_ahb_addr = '1') AND (m2_curr_state = M2_SEND_AD1))) THEN
                 IF(haddr_r(2) >= '1') THEN
                   hwdata_r <= ping_upper_b; 
	         ELSE
                   hwdata_r <= ping_lower_b;
                 END IF;
               END IF;
	     END IF;
          --END IF;
-----------	  
--          ELSIF((axi2ahb_AWSIZE_r(1 DOWNTO 0) = "01")) THEN   -- for hword 02/03/13
--             IF ((s_set_ahb_addr_data = '1') OR ((m2_set_ahb_addr = '1') AND ((m2_curr_state = M2_SEND_AD0) OR (m2_curr_state = M2_SEND_AD1)))) THEN
--	       IF ((m2_prev_state = M2_SEND_AD1) AND (m2_curr_state = M2_SEND_AD0) AND (HREADYIN = '1')) THEN
--                 IF(haddr_r(2 DOWNTO 0) >= "100") THEN
--                   hwdata_r <= ahb2wrchfifo_rddata(AXI_DWIDTH-1 DOWNTO AHB_DWIDTH);                                            
--  	         ELSE
--                   hwdata_r <= ahb2wrchfifo_rddata(AHB_DWIDTH-1 DOWNTO 0);
--                 END IF;
--	       ELSIF ((m2_prev_state = M2_SEND_AD0) AND (m2_curr_state = M2_SEND_AD1) AND (HREADYIN = '1')) THEN
--                 IF(haddr_r(2 DOWNTO 0) >= "100") THEN
--                   hwdata_r <= ahb2wrchfifo_rddata(AXI_DWIDTH-1 DOWNTO AHB_DWIDTH);                                            
--  	         ELSE
--                   hwdata_r <= ahb2wrchfifo_rddata(AHB_DWIDTH-1 DOWNTO 0);
--                 END IF;
--               ELSE
--                 IF(haddr_r(2 DOWNTO 0) >= "100") THEN
--                   hwdata_r <= wrch_fifo_rd_data(AXI_DWIDTH-1 DOWNTO AHB_DWIDTH); 
--	         ELSE
--                   hwdata_r <= wrch_fifo_rd_data(AHB_DWIDTH-1 DOWNTO 0);
--                 END IF;
--               END IF;
--             END IF;

--SAR#46417	     
          ELSIF((axi2ahb_AWSIZE_r(1 DOWNTO 0) = "01")) THEN   -- for hword 02/03/13
             IF (s_set_ahb_addr_data = '1') THEN
                 IF(haddr_r(2 DOWNTO 0) >= "100") THEN
                   hwdata_r <= ping_upper_hw; 
	         ELSE
                   hwdata_r <= ping_lower_hw; 
                 END IF;
             END IF;

             IF (((m2_set_ahb_addr = '1') AND ((m2_curr_state = M2_SEND_AD0) OR (m2_curr_state = M2_SEND_AD1)))) THEN
                 IF(haddr_r(2 DOWNTO 0) >= "100") THEN
                   hwdata_r <= ping_upper_hw; 
	         ELSE
                   hwdata_r <= ping_lower_hw; 
                 END IF;
             END IF;
------------
          ELSE  -- Others
            hwdata_r <= hwdata_2;
          END IF;
         END IF;
       END IF;
   END PROCESS;
   
   temp_xhdl30 <= wrch_fifo_rd_data(AHB_DWIDTH - 1 DOWNTO 0) WHEN (haddr_r(2) = 
   '0') ELSE wrch_fifo_rd_data(AXI_DWIDTH - 1 DOWNTO AHB_DWIDTH);
   hwdata_1 <= temp_xhdl30 ;
   temp_xhdl31 <= wrch_fifo_rd_data(AHB_DWIDTH - 1 DOWNTO 0) WHEN (wrstb_msb_en 
   = '0') ELSE wrch_fifo_rd_data(AXI_DWIDTH - 1 DOWNTO AHB_DWIDTH);
   hwdata_2 <= temp_xhdl31 ;

   PROCESS (wr_strobe, ahb2wrchfifo_rd_en_d, ahb2wrchfifo_rddata, ping_lower_wreg, ping_upper_wreg)
   BEGIN   -- 24/02/13 - 2J - pingpong
       IF((wr_strobe = X"0F")  AND (ahb2wrchfifo_rd_en_d = '1')) THEN
          ping_lower_w <= ahb2wrchfifo_rddata(AHB_DWIDTH-1 DOWNTO 0);
       ELSE
          ping_lower_w <= ping_lower_wreg;
       END IF; 

       IF((wr_strobe = X"F0") AND (ahb2wrchfifo_rd_en_d = '1')) THEN
          ping_upper_w <= ahb2wrchfifo_rddata(AXI_DWIDTH-1 DOWNTO AHB_DWIDTH);
       ELSE
          ping_upper_w <= ping_upper_wreg;
       END IF; 
  END PROCESS;

-- SAR#46417 for byte write data
   PROCESS (wr_strobe, ahb2wrchfifo_rd_en_d, ahb2wrchfifo_rddata, ping_lower_breg, ping_upper_breg, axi2ahb_AWSIZE_r)
   BEGIN   -- 24/02/13 - 2J - pingpong
       IF((ahb2wrchfifo_rd_en_d = '1') AND axi2ahb_AWSIZE_r(1 DOWNTO 0) = "00") THEN
         IF(wr_strobe = X"01") THEN
            ping_lower_b <= ping_lower_breg(31 DOWNTO 8) & ahb2wrchfifo_rddata(7 DOWNTO 0);
         ELSIF(wr_strobe = X"02") THEN
            ping_lower_b <= ping_lower_breg(31 DOWNTO 16) & ahb2wrchfifo_rddata(15 DOWNTO 8) & ping_lower_breg(7 DOWNTO 0);
         ELSIF(wr_strobe = X"04") THEN
            ping_lower_b <= ping_lower_breg(31 DOWNTO 24) & ahb2wrchfifo_rddata(23 DOWNTO 16) & ping_lower_breg(15 DOWNTO 0);
         ELSIF(wr_strobe = X"08") THEN
            ping_lower_b <= ahb2wrchfifo_rddata(31 DOWNTO 24) & ping_lower_breg(23 DOWNTO 0);
         ELSE
            ping_lower_b <= ping_lower_breg;
         END IF; 
       ELSE 
          ping_lower_b <= ping_lower_breg;
       END IF;

       IF((ahb2wrchfifo_rd_en_d = '1') AND axi2ahb_AWSIZE_r(1 DOWNTO 0) = "00") THEN
         IF(wr_strobe = X"10") THEN
            ping_upper_b <= ping_upper_breg(31 DOWNTO 8) & ahb2wrchfifo_rddata(39 DOWNTO 32);
         ELSIF(wr_strobe = X"20") THEN
            ping_upper_b <= ping_upper_breg(31 DOWNTO 16) & ahb2wrchfifo_rddata(47 DOWNTO 40) & ping_upper_breg(7 DOWNTO 0);
         ELSIF(wr_strobe = X"40") THEN
            ping_upper_b <= ping_upper_breg(31 DOWNTO 24) & ahb2wrchfifo_rddata(55 DOWNTO 48) & ping_upper_breg(15 DOWNTO 0);
         ELSIF(wr_strobe = X"80") THEN
            ping_upper_b <= ahb2wrchfifo_rddata(63 DOWNTO 56) & ping_upper_breg(23 DOWNTO 0);
         ELSE
            ping_upper_b <= ping_upper_breg;
         END IF; 
       ELSE
          ping_upper_b <= ping_upper_breg;
       END IF;
  END PROCESS;

   PROCESS (HCLK, HRESETn)
   BEGIN
      IF (HRESETn = '0') THEN
         ping_lower_breg <= (OTHERS => '0');    
         ping_upper_breg <= (OTHERS => '0');  
      ELSIF (HCLK'EVENT AND HCLK = '1') THEN
          ping_lower_breg <= ping_lower_b;
          ping_upper_breg <= ping_upper_b;
      END IF;
   END PROCESS;


-- SAR#46417 for hw write data
   PROCESS (wr_strobe, ahb2wrchfifo_rd_en_d, ahb2wrchfifo_rddata, ping_lower_hwreg, ping_upper_hwreg, axi2ahb_AWSIZE_r)
   BEGIN   -- 24/02/13 - 2J - pingpong
       IF((ahb2wrchfifo_rd_en_d = '1') AND axi2ahb_AWSIZE_r(1 DOWNTO 0) = "01") THEN
         IF(wr_strobe = X"03") THEN
            ping_lower_hw <= ping_lower_hwreg(31 DOWNTO 16) & ahb2wrchfifo_rddata(15 DOWNTO 0);
         ELSIF(wr_strobe = X"0C") THEN
            ping_lower_hw <= ahb2wrchfifo_rddata(31 DOWNTO 16) & ping_lower_hwreg(15 DOWNTO 0);
         ELSE
            ping_lower_hw <= ping_lower_hwreg;
         END IF; 
       ELSE
          ping_lower_hw <= ping_lower_hwreg;
       END IF;

       IF((ahb2wrchfifo_rd_en_d = '1') AND axi2ahb_AWSIZE_r(1 DOWNTO 0) = "01") THEN
         IF(wr_strobe = X"30") THEN
            ping_upper_hw <= ping_upper_hwreg(31 DOWNTO 16) & ahb2wrchfifo_rddata(47 DOWNTO 32);
         ELSIF(wr_strobe = X"C0") THEN
            ping_upper_hw <= ahb2wrchfifo_rddata(63 DOWNTO 48) & ping_upper_hwreg(15 DOWNTO 0);
         ELSE
            ping_upper_hw <= ping_upper_hwreg;
         END IF; 
       ELSE 
          ping_upper_hw <= ping_upper_hwreg;
       END IF;
  END PROCESS;

   PROCESS (HCLK, HRESETn)
   BEGIN
      IF (HRESETn = '0') THEN
         ping_lower_hwreg <= (OTHERS => '0');    
         ping_upper_hwreg <= (OTHERS => '0');  
      ELSIF (HCLK'EVENT AND HCLK = '1') THEN
          ping_lower_hwreg <= ping_lower_hw;
          ping_upper_hwreg <= ping_upper_hw;
      END IF;
   END PROCESS;
------------------------------

     -- pingpong

   PROCESS (HCLK, HRESETn)
   BEGIN
      IF (HRESETn = '0') THEN
         ping_lower_wreg <= (OTHERS => '0');    
         ping_upper_wreg <= (OTHERS => '0');  
         m2_set_ahb_addr_reg <= '0';       	 
      ELSIF (HCLK'EVENT AND HCLK = '1') THEN
       IF((wr_strobe = X"0F")  AND (ahb2wrchfifo_rd_en_d = '1')) THEN
          ping_lower_wreg <= ahb2wrchfifo_rddata(AHB_DWIDTH-1 DOWNTO 0);
       END IF;

       IF((wr_strobe = X"F0") AND (ahb2wrchfifo_rd_en_d = '1')) THEN
          ping_upper_wreg <= ahb2wrchfifo_rddata(AXI_DWIDTH-1 DOWNTO AHB_DWIDTH);
       END IF;

       m2_set_ahb_addr_reg <= m2_set_ahb_addr;

      END IF;
   END PROCESS;

   PROCESS (HCLK, HRESETn)
   BEGIN
      IF (HRESETn = '0') THEN
         remaining_dec_en <= '1';    
      ELSIF (HCLK'EVENT AND HCLK = '1') THEN
         IF ((CONV_STD_LOGIC((m2_curr_state = M2_DECIDE_CYC) AND (m2_next_state 
         = M2_SEND_AD0)) OR (h_start_single_transfer)) = '1') THEN
            remaining_dec_en <= '0';    
         ELSE
            IF (H_curr_state = H_IDLE) THEN
               remaining_dec_en <= '1';    
            END IF;
         END IF;
      END IF;
   END PROCESS;
   temp_xhdl32 <= NONSEQ WHEN ((m2_curr_state = M2_DECIDE_CYC) OR 
   (m2_curr_state = M2_BURST_COUNT) OR (m2_curr_state = M2_WAIT4SINGLE)) ELSE 
   SEQ;
   m2_htrans_c(1 DOWNTO 0) <= temp_xhdl32 ;
   temp_xhdl33 <= IDLE WHEN (s_len_wr_count(1 DOWNTO 0) = ahb_trans_count(1 
   DOWNTO 0)) ELSE NONSEQ;
   s_htrans_c(1 DOWNTO 0) <= temp_xhdl33 ;

   -------------------------------------------------------------------------------
   -- Sequential block for State Machine
   -------------------------------------------------------------------------------
   
   ahb_fsm_seq_logic : PROCESS (HCLK, HRESETn)
   BEGIN
      IF (HRESETn = '0') THEN
         H_curr_state <= H_IDLE;    
         s_curr_state <= S_IDLE;    
         m2_curr_state <= M2_IDLE;    
         m2_wr_channel_rd_en_d <= '0';    -- 23/02/13 - 1I - for word last data
         m2_prev_state <= "000";            -- 24/02/13 - 2J - for word
      ELSIF (HCLK'EVENT AND HCLK = '1') THEN
         H_curr_state <= H_next_state;    
         s_curr_state <= s_next_state;    
         m2_wr_channel_rd_en_d <= m2_wr_channel_rd_en;    
         m2_prev_state <= m2_curr_state;  -- 24/02/13 - 2J - for word
         m2_curr_state <= m2_next_state;
      END IF;
   END PROCESS ahb_fsm_seq_logic;

   -------------------------------------------------------------------------------
   -- Combinational block for Main State Machine
   -------------------------------------------------------------------------------
   
   ahb_main_fsm_combo_logic : PROCESS (H_curr_state,
axi2ahb_wr_fifo_done_syn_d, wrstb_ram_rd_data, s_single_trans_done, 
m2_multi_trans_done_r, h_loopcount, max_ram_addr, axi2ahb_AWLEN_r,
axi2ahb_AWSIZE_r)
      VARIABLE H_next_state_xhdl34  : std_logic_vector(2 DOWNTO 0);
      VARIABLE h_loopcount_en_xhdl35  : std_logic;
      VARIABLE h_ram_rd_en_xhdl36  : std_logic;
      VARIABLE h_start_single_transfer_xhdl37  : std_logic;
      VARIABLE h_start_multiple_transfer_xhdl38  : std_logic;
      VARIABLE h_send_ahb_resp_en_xhdl39  : std_logic;
      VARIABLE h_hsel_write_xhdl40  : std_logic;
   BEGIN
      H_next_state_xhdl34 := H_curr_state;    
      h_loopcount_en_xhdl35 := '0';    
      h_ram_rd_en_xhdl36 := '0';    
      h_start_single_transfer_xhdl37 := '0';    
      h_start_multiple_transfer_xhdl38 := '0';    
      h_send_ahb_resp_en_xhdl39 := '0';    
      h_hsel_write_xhdl40 := '0';    
      CASE H_curr_state IS
         ----------------------------------------------------- 
         -- IDLE state
         ----------------------------------------------------- 
         
         WHEN H_IDLE =>
                  h_ram_rd_en_xhdl36 := '0';    
                  -- Commented below line by AP - 15/07/11
                  --          if (axi2ahb_wr_fifo_done_syn == 1'b1) begin
                  -- Added by AP - 15/07/11 - Delayed by one clock
                  
                  IF (axi2ahb_wr_fifo_done_syn_d = '1') THEN
                     H_next_state_xhdl34 := H_RD_RAM;    
                     h_ram_rd_en_xhdl36 := '1';    
                     h_hsel_write_xhdl40 := '1';    
                  END IF;
         ----------------------------------------------------- 
         -- Read RAM for Write Strobe information
         ----------------------------------------------------- 
         
         WHEN H_RD_RAM =>
                  h_ram_rd_en_xhdl36 := '0';    
                  h_loopcount_en_xhdl35 := '1';    
                  H_next_state_xhdl34 := H_SUB_START;    
                  h_hsel_write_xhdl40 := '1';    
         WHEN H_SUB_START =>
                  h_hsel_write_xhdl40 := '1';    
                  h_loopcount_en_xhdl35 := '0';    
                  IF (wrstb_ram_rd_data(5 DOWNTO 0) = "000001") THEN
                     h_start_single_transfer_xhdl37 := '1';    
                  ELSE
                     h_start_multiple_transfer_xhdl38 := '1';    
                  END IF;
                  H_next_state_xhdl34 := H_AHB_TRANS;    
         WHEN H_AHB_TRANS =>
                  h_hsel_write_xhdl40 := '1';    
                  h_loopcount_en_xhdl35 := '0';    
                  h_start_single_transfer_xhdl37 := '0';    
                  h_start_multiple_transfer_xhdl38 := '0';    
                  IF ((s_single_trans_done = '1') OR (m2_multi_trans_done_r = 
                  '1')) THEN
                     -- all transer done
                     
                     IF (h_loopcount < max_ram_addr) THEN
                        IF ((axi2ahb_AWLEN_r(3 DOWNTO 0) = "0000") AND 
                        (axi2ahb_AWSIZE_r(1 DOWNTO 0) /= "11")) THEN
                           H_next_state_xhdl34 := H_AHB_DONE;    
                        ELSE
                           H_next_state_xhdl34 := H_RD_RAM;    
                           h_ram_rd_en_xhdl36 := '1';    
                        END IF;
                     ELSE
                        H_next_state_xhdl34 := H_AHB_DONE;    
                     END IF;
                  END IF;
         ----------------------------------------------------- 
         -- AHB transfer completion 
         ----------------------------------------------------- 
         
         WHEN H_AHB_DONE =>
                  h_hsel_write_xhdl40 := '1';    
                  H_next_state_xhdl34 := H_IDLE;    
                  h_send_ahb_resp_en_xhdl39 := '1';    
         WHEN OTHERS  =>
                  H_next_state_xhdl34 := H_curr_state;    
         
      END CASE;
      H_next_state <= H_next_state_xhdl34;
      h_loopcount_en <= h_loopcount_en_xhdl35;
      h_ram_rd_en <= h_ram_rd_en_xhdl36;
      h_start_single_transfer <= h_start_single_transfer_xhdl37;
      h_start_multiple_transfer <= h_start_multiple_transfer_xhdl38;
      h_send_ahb_resp_en <= h_send_ahb_resp_en_xhdl39;
      h_hsel_write <= h_hsel_write_xhdl40;
   END PROCESS ahb_main_fsm_combo_logic;

   -------------------------------------------------------------------------------
   -- Combinational block for Single Transfer State Machine
   -------------------------------------------------------------------------------
   
   ahb_single_fsm_combo_logic : PROCESS (ahb_trans_count, s_len_wr_count, 
   s_wait_count,    
   s_curr_state, HREADYIN, h_start_single_transfer)
      VARIABLE s_next_state_xhdl41  : std_logic_vector(2 DOWNTO 0);
      VARIABLE s_single_trans_done_xhdl42  : std_logic;
      VARIABLE s_wr_channel_rd_en_xhdl43  : std_logic;
      VARIABLE s_set_ahb_addr_xhdl44  : std_logic;
      VARIABLE s_set_ahb_addr_data_xhdl45  : std_logic;
      VARIABLE s_single_tras_active_xhdl46  : std_logic;
      VARIABLE s_trans_length_en_xhdl47  : std_logic;
      VARIABLE s_write_en_xhdl48  : std_logic;
   BEGIN
      s_next_state_xhdl41 := s_curr_state;    
      s_single_trans_done_xhdl42 := '0';    
      s_wr_channel_rd_en_xhdl43 := '0';    
      s_set_ahb_addr_xhdl44 := '0';    
      s_set_ahb_addr_data_xhdl45 := '0';    
      s_single_tras_active_xhdl46 := '0';    
      s_trans_length_en_xhdl47 := '0';    
      s_write_en_xhdl48 := '0';    
      CASE s_curr_state IS
         ----------------------------------------------------- 
         -- IDLE state
         ----------------------------------------------------- 
         
         WHEN S_IDLE =>
                  s_write_en_xhdl48 := '0';    
                  s_set_ahb_addr_xhdl44 := '0';    
                  s_set_ahb_addr_data_xhdl45 := '0';    
                  s_single_trans_done_xhdl42 := '0';    
                  s_wr_channel_rd_en_xhdl43 := '0';    
                  s_single_tras_active_xhdl46 := '0';    
                  s_trans_length_en_xhdl47 := '0';    
                  IF (h_start_single_transfer = '1') THEN
                     s_next_state_xhdl41 := S_RD_FIFO;    
                     s_wr_channel_rd_en_xhdl43 := '1';    
                  END IF;
         ----------------------------------------------------- 
         -- Read AHB Write data from FIFO
         ----------------------------------------------------- 
         
         WHEN S_RD_FIFO =>
                  s_single_tras_active_xhdl46 := '1';    
                  s_wr_channel_rd_en_xhdl43 := '0';    
                  s_next_state_xhdl41 := S_GET_DATA;    
         ----------------------------------------------------- 
         -- Get FIFO data and decide AHB transactions
         ----------------------------------------------------- 
         
         WHEN S_GET_DATA =>
                  s_wr_channel_rd_en_xhdl43 := '0';    
                  s_single_tras_active_xhdl46 := '1';    
                  IF (s_wait_count = "01") THEN
                     s_next_state_xhdl41 := S_SEND_ADDRDATA0;    
                     s_set_ahb_addr_xhdl44 := '1';    
                     s_trans_length_en_xhdl47 := '1';    
                     s_write_en_xhdl48 := '1';    
                  END IF;
         ----------------------------------------------------- 
         -- Send AHB address/data on AHB bus
         ----------------------------------------------------- 
         
         WHEN S_SEND_ADDRDATA0 =>
                  s_single_tras_active_xhdl46 := '1';    
                  s_set_ahb_addr_xhdl44 := '0';    
                  s_set_ahb_addr_data_xhdl45 := '1';    
                  s_write_en_xhdl48 := '1';    -- SAR#46417
                  IF (HREADYIN = '1') THEN
                     IF (s_len_wr_count<=ahb_trans_count) THEN
                        s_next_state_xhdl41 := S_SEND_ADDRDATA1;    
                        s_trans_length_en_xhdl47 := '1';    
                        s_set_ahb_addr_data_xhdl45 := '1';    
                        s_write_en_xhdl48 := '1';    
                     ELSE
                        s_next_state_xhdl41 := S_IDLE;    
                        s_trans_length_en_xhdl47 := '0';    
                        s_write_en_xhdl48 := '0';    
                        s_single_trans_done_xhdl42 := '1';    
                     END IF;
                  END IF;
         ----------------------------------------------------- 
         -- Send AHB address/data on AHB bus
         ----------------------------------------------------- 
         
         WHEN S_SEND_ADDRDATA1 =>
                  s_single_trans_done_xhdl42 := '0';    
                  s_single_tras_active_xhdl46 := '1';    
                  s_set_ahb_addr_data_xhdl45 := '0';    
                  IF (HREADYIN = '1') THEN
                     IF (s_len_wr_count<=ahb_trans_count) THEN
                        s_next_state_xhdl41 := S_SEND_ADDRDATA0;    
                        s_trans_length_en_xhdl47 := '1';    
                        s_set_ahb_addr_data_xhdl45 := '1';    
                        s_write_en_xhdl48 := '1';    
                     ELSE
                        s_next_state_xhdl41 := S_IDLE;    
                        s_trans_length_en_xhdl47 := '0';    
                        s_write_en_xhdl48 := '0';    
                        s_single_trans_done_xhdl42 := '1';    
                     END IF;
                  END IF;
         ----------------------------------------------------- 
         -- Decide AHB transfers from RAM count and Write strobe
         ----------------------------------------------------- 
         
         WHEN OTHERS  =>
                  s_next_state_xhdl41 := s_curr_state;    
         
      END CASE;
      s_next_state <= s_next_state_xhdl41;
      s_single_trans_done <= s_single_trans_done_xhdl42;
      s_wr_channel_rd_en <= s_wr_channel_rd_en_xhdl43;
      s_set_ahb_addr <= s_set_ahb_addr_xhdl44;
      s_set_ahb_addr_data <= s_set_ahb_addr_data_xhdl45;
      s_single_tras_active <= s_single_tras_active_xhdl46;
      s_trans_length_en <= s_trans_length_en_xhdl47;
      s_write_en <= s_write_en_xhdl48;
   END PROCESS ahb_single_fsm_combo_logic;

   -------------------------------------------------------------------------------
   -- Combinational block for Multi Transfer read FIFO State Machine
   -------------------------------------------------------------------------------
   
   ahb_multi_fsm_combo_logic : PROCESS (h_start_multiple_transfer_d1, 
   m2_super_no_of_burst_count, m2_curr_state, axi2ahb_AWSIZE_r, m2_wr_channel_rd_en_int2, 
   m2_burst_len_count, m2_ahb_cyc_info_dummy, m2_burst_size, 
   m2_no_of_burst_count, axi2ahb_AWLEN_r,  
   HREADYIN)
      VARIABLE m2_next_state_xhdl49  : std_logic_vector(2 DOWNTO 0);
      VARIABLE m2_super_no_of_burst_count_en_xhdl50  : std_logic;
      VARIABLE m2_burst_len_count_en_xhdl51  : std_logic;
      VARIABLE m2_ahb_cyc_info_dummy_load_xhdl52  : std_logic;
      VARIABLE m2_ahb_cyc_info_dummy_shen_xhdl53  : std_logic;
      VARIABLE m2_burst_size_count_en_xhdl54  : std_logic;
      VARIABLE m2_multi_trans_done_xhdl55  : std_logic;
      VARIABLE m2_no_of_burst_count_en_xhdl56  : std_logic;
      VARIABLE m2_wr_channel_rd_en_xhdl57  : std_logic;
      VARIABLE m2_set_ahb_addr_xhdl58  : std_logic;
      VARIABLE m2_single_tras_active_xhdl59  : std_logic;
   BEGIN
      m2_next_state_xhdl49 := m2_curr_state;    
      m2_super_no_of_burst_count_en_xhdl50 := '0';    
      m2_burst_len_count_en_xhdl51 := '0';    
      m2_ahb_cyc_info_dummy_load_xhdl52 := '0';    
      m2_ahb_cyc_info_dummy_shen_xhdl53 := '0';    
      m2_burst_size_count_en_xhdl54 := '0';    
      m2_multi_trans_done_xhdl55 := '0';    
      m2_no_of_burst_count_en_xhdl56 := '0';    
      m2_wr_channel_rd_en_xhdl57 := '0';    
      m2_wr_channel_rd_en_int2 <= "00";    
      m2_set_ahb_addr_xhdl58 := '0';    
      m2_single_tras_active_xhdl59 := '0';    
      CASE m2_curr_state IS
         ----------------------------------------------------- 
         -- IDLE state
         ----------------------------------------------------- 
         
         WHEN M2_IDLE =>
                  m2_super_no_of_burst_count_en_xhdl50 := '0';    
                  m2_burst_len_count_en_xhdl51 := '0';    
                  m2_ahb_cyc_info_dummy_load_xhdl52 := '0';    
                  m2_ahb_cyc_info_dummy_shen_xhdl53 := '0';    
                  IF (h_start_multiple_transfer_d1 = '1') THEN
                     m2_next_state_xhdl49 := M2_DECIDE_CYC;    
                     m2_ahb_cyc_info_dummy_load_xhdl52 := '1';    
                     m2_wr_channel_rd_en_xhdl57 := '1';    
                  END IF;
         WHEN M2_DECIDE_CYC =>
                  m2_single_tras_active_xhdl59 := '1';    
                  IF (m2_super_no_of_burst_count = "100") THEN
                     m2_next_state_xhdl49 := M2_IDLE;    
                     m2_multi_trans_done_xhdl55 := '1';    
                  ELSE
                     IF (m2_ahb_cyc_info_dummy(1 DOWNTO 0) = "00") THEN
                        m2_next_state_xhdl49 := M2_DECIDE_CYC;    
                        m2_super_no_of_burst_count_en_xhdl50 := '1';    
                        m2_ahb_cyc_info_dummy_shen_xhdl53 := '1';    
                     ELSE
                        m2_next_state_xhdl49 := M2_SEND_AD0;    
                        m2_set_ahb_addr_xhdl58 := '1';    
                     END IF;
                  END IF;
         WHEN M2_SEND_AD0 =>
                  m2_single_tras_active_xhdl59 := '1';

                  IF (HREADYIN = '1') THEN
                     IF (m2_burst_len_count(4 DOWNTO 0) < m2_burst_size(4 DOWNTO 0)) THEN
                        m2_next_state_xhdl49 := M2_SEND_AD1;    
                        m2_burst_len_count_en_xhdl51 := '1';    
                        m2_set_ahb_addr_xhdl58 := '1';    
 
			--IF (axi2ahb_AWSIZE_r(2 DOWNTO 0) = "010") THEN  -- original
			IF ((axi2ahb_AWSIZE_r(2 DOWNTO 0) = "010") OR (axi2ahb_AWSIZE_r(2 DOWNTO 0) = "000") OR (axi2ahb_AWSIZE_r(2 DOWNTO 0) = "001")) THEN -- For byte 02/03/13
                           m2_wr_channel_rd_en_xhdl57 := '1';
	                END IF;
                     ELSE
                        m2_next_state_xhdl49 := M2_BURST_COUNT;    
                        m2_no_of_burst_count_en_xhdl56 := '1';    
                     END IF;
                  END IF;
         WHEN M2_SEND_AD1 =>
                  m2_single_tras_active_xhdl59 := '1';    
                  IF (HREADYIN = '1') THEN
                     IF (m2_burst_len_count(4 DOWNTO 0) < m2_burst_size(4 DOWNTO 0)) THEN
                        m2_next_state_xhdl49 := M2_SEND_AD0;    
                        m2_burst_len_count_en_xhdl51 := '1';    
                        m2_set_ahb_addr_xhdl58 := '1';    
			IF ((m2_burst_len_count(4 DOWNTO 0) < (m2_burst_size(4 DOWNTO 0)-"10")) AND (axi2ahb_AWSIZE_r(2 DOWNTO 0) = "011") AND (axi2ahb_AWLEN_r(3 DOWNTO 0) /= "1111")) THEN 
		           IF (m2_burst_size /= "0001")  THEN
                               m2_wr_channel_rd_en_xhdl57 := '1';
                           END IF;
			ELSIF (((m2_burst_len_count(4 DOWNTO 0)) <= (m2_burst_size(4 DOWNTO 0)-"01")) AND (axi2ahb_AWSIZE_r(2 DOWNTO 0) = "011") AND (axi2ahb_AWLEN_r(3 DOWNTO 0) = "1111")) THEN 
		           IF (m2_burst_size /= "0001")  THEN
                               m2_wr_channel_rd_en_xhdl57 := '1';
                           END IF;
		        -- ELSIF (axi2ahb_AWSIZE_r(2 DOWNTO 0) = "010") THEN -- original
		        ELSIF ((axi2ahb_AWSIZE_r(2 DOWNTO 0) = "010") OR (axi2ahb_AWSIZE_r(2 DOWNTO 0) = "000") OR (axi2ahb_AWSIZE_r(2 DOWNTO 0) = "001")) THEN -- For byte 02/03/13
                           m2_wr_channel_rd_en_xhdl57 := '1';
                        END IF;
                     ELSE
                        m2_next_state_xhdl49 := M2_BURST_COUNT;    
                        m2_no_of_burst_count_en_xhdl56 := '1';    
                     END IF;
                  END IF;
         WHEN M2_BURST_COUNT =>
                  m2_single_tras_active_xhdl59 := '1';    
                  IF (m2_no_of_burst_count(1 DOWNTO 0) < m2_ahb_cyc_info_dummy(1 DOWNTO 0)) THEN
                     m2_next_state_xhdl49 := M2_WAIT4SINGLE;    
                  ELSE
                     m2_next_state_xhdl49 := M2_DECIDE_CYC;    
                     m2_super_no_of_burst_count_en_xhdl50 := '1';    
                     m2_ahb_cyc_info_dummy_shen_xhdl53 := '1';    
		     -- IF (axi2ahb_AWSIZE_r(2 DOWNTO 0) /= "010") THEN  -- For byte 02/03/13
		     --IF ((axi2ahb_AWSIZE_r(2 DOWNTO 0) /= "010") OR (axi2ahb_AWSIZE_r(2 DOWNTO 0) /= "000") OR (axi2ahb_AWSIZE_r(2 DOWNTO 0) /= "001")) THEN 
		     IF ((axi2ahb_AWSIZE_r(2 DOWNTO 0) = "011")) THEN 
                       m2_wr_channel_rd_en_xhdl57 := '1';
	             END IF;
                  END IF;
         ----------------------------------------------------- 
         -- WAIT state inserted only for multiple SINGLE AHB transfers
         ----------------------------------------------------- 
         
         WHEN M2_WAIT4SINGLE =>
                  m2_single_tras_active_xhdl59 := '1';    
                  m2_next_state_xhdl49 := M2_SEND_AD0;    
                  m2_set_ahb_addr_xhdl58 := '1';    
		  IF (axi2ahb_AWSIZE_r(2 DOWNTO 0) = "010") THEN 
                     m2_wr_channel_rd_en_xhdl57 := '1';    
                  END IF;
         WHEN OTHERS  =>
                  m2_next_state_xhdl49 := m2_curr_state;    
         
      END CASE;
      m2_next_state <= m2_next_state_xhdl49;
      m2_super_no_of_burst_count_en <= m2_super_no_of_burst_count_en_xhdl50;
      m2_burst_len_count_en <= m2_burst_len_count_en_xhdl51;
      m2_ahb_cyc_info_dummy_load <= m2_ahb_cyc_info_dummy_load_xhdl52;
      m2_ahb_cyc_info_dummy_shen <= m2_ahb_cyc_info_dummy_shen_xhdl53;
      m2_burst_size_count_en <= m2_burst_size_count_en_xhdl54;
      m2_multi_trans_done <= m2_multi_trans_done_xhdl55;
      m2_no_of_burst_count_en <= m2_no_of_burst_count_en_xhdl56;
      m2_wr_channel_rd_en <= m2_wr_channel_rd_en_xhdl57;
      --m2_wr_channel_rd_en_int2 <= m2_wr_channel_rd_en_int;
      m2_set_ahb_addr <= m2_set_ahb_addr_xhdl58;
      m2_single_tras_active <= m2_single_tras_active_xhdl59;
   END PROCESS ahb_multi_fsm_combo_logic;

   PROCESS (HCLK, HRESETn)
   BEGIN
      IF (HRESETn = '0') THEN
         m2_no_of_burst_count <= "00";    
      ELSIF (HCLK'EVENT AND HCLK = '1') THEN
         IF (m2_curr_state = M2_DECIDE_CYC) THEN
            m2_no_of_burst_count <= "00";    
         ELSE
            IF (m2_no_of_burst_count_en = '1') THEN
               m2_no_of_burst_count <= m2_no_of_burst_count + "01";    
            END IF;
         END IF;
      END IF;
   END PROCESS;

   PROCESS (HCLK, HRESETn)
   BEGIN
      IF (HRESETn = '0') THEN
         m2_burst_size <= "00000";    
      ELSIF (HCLK'EVENT AND HCLK = '1') THEN
         IF (m2_curr_state = M2_IDLE) THEN
            m2_burst_size <= "00000";    
         ELSE
            IF (m2_curr_state = M2_DECIDE_CYC) THEN
               CASE m2_super_no_of_burst_count(2 DOWNTO 0) IS
                  WHEN "000" =>
                           m2_burst_size <= CONV_STD_LOGIC_VECTOR(INCR16, 5);   
                  WHEN "001" =>
                           m2_burst_size <= CONV_STD_LOGIC_VECTOR(INCR8, 5);    
                  WHEN "010" =>
                           m2_burst_size <= CONV_STD_LOGIC_VECTOR(INCR4, 5);    
                  WHEN "011" =>
                           m2_burst_size <= CONV_STD_LOGIC_VECTOR(SINGLE, 5);   
                  WHEN OTHERS =>
                           NULL;
                  
               END CASE;
            END IF;
         END IF;
      END IF;
   END PROCESS;

   PROCESS (m2_super_no_of_burst_count)
      VARIABLE m2_burst_size_c_xhdl60  : std_logic_vector(2 DOWNTO 0);
   BEGIN
      CASE m2_super_no_of_burst_count(2 DOWNTO 0) IS
         WHEN "000" =>
                  m2_burst_size_c_xhdl60 := "111";    -- INCR16;
         WHEN "001" =>
                  m2_burst_size_c_xhdl60 := "101";    -- INCR8;
         WHEN "010" =>
                  m2_burst_size_c_xhdl60 := "011";    -- INCR4;
         WHEN "011" =>
                  m2_burst_size_c_xhdl60 := "000";    -- SINGLE;
         WHEN OTHERS  =>
                  m2_burst_size_c_xhdl60 := "000";    
         
      END CASE;
      m2_burst_size_c <= m2_burst_size_c_xhdl60;
   END PROCESS;

   PROCESS (HCLK, HRESETn)
   BEGIN
      IF (HRESETn = '0') THEN
         m2_super_no_of_burst_count <= "000";    
      ELSIF (HCLK'EVENT AND HCLK = '1') THEN
         IF (m2_curr_state = M2_IDLE) THEN
            m2_super_no_of_burst_count <= "000";    
         ELSE
            IF (m2_super_no_of_burst_count_en = '1') THEN
               m2_super_no_of_burst_count <= m2_super_no_of_burst_count + 
               "001";    
            END IF;
         END IF;
      END IF;
   END PROCESS;

   PROCESS (HCLK, HRESETn)
   BEGIN
      IF (HRESETn = '0') THEN
         m2_ahb_cyc_info_dummy <= "00000000";    
      ELSIF (HCLK'EVENT AND HCLK = '1') THEN
         IF (m2_ahb_cyc_info_dummy_load = '1') THEN
            m2_ahb_cyc_info_dummy <= m2_ahb_cyc_info(7 DOWNTO 0);    
         ELSE
            IF (m2_ahb_cyc_info_dummy_shen = '1') THEN
               m2_ahb_cyc_info_dummy <= "00" & m2_ahb_cyc_info_dummy(7 DOWNTO 2)
               ;    
            END IF;
         END IF;
      END IF;
   END PROCESS;

   PROCESS (HCLK, HRESETn)
   BEGIN
      IF (HRESETn = '0') THEN
         m2_burst_len_count <= "00000";    
      ELSIF (HCLK'EVENT AND HCLK = '1') THEN
         IF (m2_curr_state = M2_BURST_COUNT) THEN
            m2_burst_len_count <= "00000";    
         ELSE
            IF (m2_burst_len_count_en = '1') THEN
               m2_burst_len_count <= m2_burst_len_count + "00001";    
            END IF;
         END IF;
      END IF;
   END PROCESS;

   PROCESS (HCLK, HRESETn)
   BEGIN
      IF (HRESETn = '0') THEN
         h_loopcount <= "00000";    
      ELSIF (HCLK'EVENT AND HCLK = '1') THEN
         IF (H_curr_state = H_IDLE) THEN
            h_loopcount <= "00000";    
         ELSE
            IF (h_loopcount_en = '1') THEN
               h_loopcount <= h_loopcount + "00001";    
            END IF;
         END IF;
      END IF;
   END PROCESS;

   PROCESS (axi2ahb_AWSIZE_r)
      VARIABLE add_len_xhdl61  : std_logic_vector(3 DOWNTO 0);
   BEGIN
      CASE axi2ahb_AWSIZE_r(2 DOWNTO 0) IS
         WHEN "011" =>
                  add_len_xhdl61(3 DOWNTO 0) := "0001";    
         WHEN "010" =>
                  add_len_xhdl61(3 DOWNTO 0) := "0010";    
         WHEN "001" =>
                  add_len_xhdl61(3 DOWNTO 0) := "0100";    
         WHEN "000" =>
                  add_len_xhdl61(3 DOWNTO 0) := "1000";    
         WHEN OTHERS  =>
                  add_len_xhdl61(3 DOWNTO 0) := "0000";    
         
      END CASE;
      add_len <= add_len_xhdl61;
   END PROCESS;

   PROCESS (HCLK, HRESETn)
   BEGIN
      IF (HRESETn = '0') THEN
         custom_awlen(4 DOWNTO 0) <= "00000";    
      ELSIF (HCLK'EVENT AND HCLK = '1') THEN
         IF (H_curr_state = H_IDLE) THEN
            custom_awlen(4 DOWNTO 0) <= "0" & axi2ahb_AWLEN_r(3 DOWNTO 0) + 
            add_len(3 DOWNTO 0) + "0001";    
         ELSE
            IF (h_start_single_transfer = '1') THEN
               custom_awlen(4 DOWNTO 0) <= custom_awlen(4 DOWNTO 0) - "00001";  
            END IF;
         END IF;
      END IF;
   END PROCESS;

   -- Added by AP - 09/08/11 - 02a
   
   PROCESS (HCLK, HRESETn)
   BEGIN
      IF (HRESETn = '0') THEN
         h_ram_rd_en_d <= '0';    
      ELSIF (HCLK'EVENT AND HCLK = '1') THEN
         h_ram_rd_en_d <= h_ram_rd_en;    
      END IF;
   END PROCESS;

   ----------------------------------------------
   
   PROCESS (HCLK, HRESETn)
   BEGIN
      IF (HRESETn = '0') THEN
         wrstb_ram_rd_addr_xhdl11 <= "0000";    
         wrstb_ram_rd_en_xhdl10 <= '0';    
         wrstb_ram_rd_en_d <= '0';    
         ahb2wrchfifo_rd_en_d <= '0';    
         wrch_fifo_rd_data <= (OTHERS => '0');    
         wrch_fifo_rd_data_wrstb <= '0' & '0' & '0' & '0' & '0' & '0' & '0' & 
         '0';    
         wrch_fifo_rd_clear_xhdl15 <= '0';    
      ELSIF (HCLK'EVENT AND HCLK = '1') THEN
         --wrstb_ram_rd_en    <= h_ram_rd_en; // By AP - 09/08/11 - 2a
         
         wrstb_ram_rd_en_xhdl10 <= h_ram_rd_en_d;    --  By AP - 09/08/11 - 2a
         wrstb_ram_rd_en_d <= wrstb_ram_rd_en_xhdl10;    
         --wrch_fifo_rd_clear_xhdl15 <= CONV_STD_LOGIC((m2_next_state = M2_IDLE) AND (m2_curr_state = M2_DECIDE_CYC));     -- SAR#46417
         wrch_fifo_rd_clear_xhdl15 <= CONV_STD_LOGIC(((m2_next_state = M2_IDLE) AND (m2_curr_state = M2_DECIDE_CYC))OR ((s_next_state = S_IDLE) AND (s_curr_state = S_SEND_ADDRDATA0))); -- SAR#46417  

         IF (H_next_state = H_IDLE) THEN
            wrstb_ram_rd_addr_xhdl11 <= "0000";    
         --else if (h_ram_rd_en == 1'b1) begin // Commented By AP - 09/08/11 - 2a         
         ELSE
            --IF (h_ram_rd_en_d = '1') THEN
            IF (h_ram_rd_en = '1') THEN  --  SAR#46417
               -- By AP - 09/08/11 - 2a
               
               wrstb_ram_rd_addr_xhdl11 <= wrstb_ram_rd_addr_xhdl11 + "0001";   
            END IF;
         END IF;

         IF ((m2_burst_size(4 DOWNTO 0) = "00001") AND (axi2ahb_AWSIZE_r(2 
         DOWNTO 0) = "011")) THEN
            wrch_fifo_rd_data <= wrch_fifo_rd_data;    
            wrch_fifo_rd_data_wrstb <= wrch_fifo_rd_data_wrstb;    
         ELSE
            --IF (ahb2wrchfifo_rd_en_d = '1') THEN   -- SAR#46417
            IF (((ahb2wrchfifo_rd_en_xhdl12 = '1') AND axi2ahb_AWSIZE_r = "010") OR 
                ((ahb2wrchfifo_rd_en_d = '1') AND axi2ahb_AWSIZE_r = "011")) THEN  -- SAR#46417
               IF (m2_fifo_rd_count(4 DOWNTO 0)<=custom_awlen(4 DOWNTO 0)) 
               THEN
                  IF (wrch2ahb_fifo_empty_r = '0') THEN
                     wrch_fifo_rd_data <= ahb2wrchfifo_rddata(AXI_DWIDTH - 1 DOWNTO 0);    
                     wrch_fifo_rd_data_wrstb <= wr_strobe(7 DOWNTO 0);    
                  END IF;
               END IF;
            END IF;
         END IF;
         ahb2wrchfifo_rd_en_d <= ahb2wrchfifo_rd_en_xhdl12;    
      END IF;
   END PROCESS;
   ahb2wrchfifo_rd_en_xhdl12 <= s_wr_channel_rd_en OR m2_wr_channel_rd_en ;
   -------------------------------------------------------------------------------
   -- Check the write strobe bits and send correct MSB/LSB word on AHB bus.
   -------------------------------------------------------------------------------
   wrstb_msb_en <= or_br(wrch_fifo_rd_data_wrstb(7 DOWNTO 4)) ;

   PROCESS (HCLK, HRESETn)
   BEGIN
      IF (HRESETn = '0') THEN
         m2_fifo_rd_count <= "00000";    
      ELSIF (HCLK'EVENT AND HCLK = '1') THEN
         IF (H_curr_state = H_IDLE) THEN
            m2_fifo_rd_count <= "00000";    
         ELSE
            IF (ahb2wrchfifo_rd_en_xhdl12 = '1') THEN
               m2_fifo_rd_count <= m2_fifo_rd_count + "00001";    
            END IF;
         END IF;
      END IF;
   END PROCESS;

   -------------------------------------------------------------------------------
   -- Latch max write address of write strobe ram
   -------------------------------------------------------------------------------
   
   PROCESS (HCLK, HRESETn)
   BEGIN
      IF (HRESETn = '0') THEN
         max_ram_addr <= "00000";    
      ELSIF (HCLK'EVENT AND HCLK = '1') THEN
         IF (wrstb_fifo_wren_syn = '1') THEN
            max_ram_addr <= wrstb_wr_addr(4 DOWNTO 0);    
         END IF;
      END IF;
   END PROCESS;

   -------------------------------------------------------------------------------
   -- Latch write strobe ram data - AHB transfer count
   -- ram_rd_data[9:6] are implemented for future use.
   -------------------------------------------------------------------------------
   
   PROCESS (HCLK, HRESETn)
   BEGIN
      IF (HRESETn = '0') THEN
         ram_rd_data <= "0000000000";    
      ELSIF (HCLK'EVENT AND HCLK = '1') THEN
         IF (wrstb_ram_rd_en_d = '1') THEN
            IF (axi2ahb_AWSIZE_r(2 DOWNTO 0) = "011") THEN
               IF (remaining_dec_en = '0') THEN
                  ram_rd_data <= wrstb_ram_rd_data(9 DOWNTO 0);    
               ELSE
                  ram_rd_data <= wrstb_ram_rd_data(9 DOWNTO 0) - "0000000010";  
               END IF;
            ELSE
               ram_rd_data <= wrstb_ram_rd_data(9 DOWNTO 0);    
            END IF;
         END IF;
      END IF;
   END PROCESS;

   PROCESS (HCLK, HRESETn)
   BEGIN
      IF (HRESETn = '0') THEN
         s_wait_count <= "00";    
      ELSIF (HCLK'EVENT AND HCLK = '1') THEN
         IF (s_curr_state = S_GET_DATA) THEN
            s_wait_count <= s_wait_count + "01";    
         ELSE
            s_wait_count <= "00";    
         END IF;
      END IF;
   END PROCESS;

   PROCESS (HCLK, HRESETn)
   BEGIN
      IF (HRESETn = '0') THEN
         s_len_wr_count <= "000";    
      ELSIF (HCLK'EVENT AND HCLK = '1') THEN
         IF (s_curr_state = S_IDLE) THEN
            s_len_wr_count <= "000";    
         ELSE
            IF (s_trans_length_en = '1') THEN
               s_len_wr_count <= s_len_wr_count + "001";    
            END IF;
         END IF;
      END IF;
   END PROCESS;
   -------------------------------------------------------------------------------
   -- Extract Write Strobe 
   -------------------------------------------------------------------------------
   wr_strobe(7 DOWNTO 0) <= ahb2wrchfifo_rddata(CUSTOM_WR_DWIDTH - 1 DOWNTO 
   CUSTOM_WR_DWIDTH - 8) ;

   PROCESS (HCLK)
   BEGIN
      IF (HCLK'EVENT AND HCLK = '1') THEN
         CASE wr_strobe(7 DOWNTO 0) IS
            WHEN "11111111" =>
                     ahb_trans_count <= "00";    
                     trans_size_0 <= "00";    
                     trans_size_1 <= "00";    
                     trans_size_2 <= "00";    
                     addr_incr <= "000";    
            WHEN "11111110" =>
                     ahb_trans_count <= "11";    --  three - single ahb transfers
                     trans_size_0 <= "00";    
                     trans_size_1 <= "01";    
                     trans_size_2 <= "10";    
                     addr_incr <= "001";    
            WHEN "11111100" =>
                     ahb_trans_count <= "10";    --  two - single ahb transfers
                     trans_size_0 <= "01";    
                     trans_size_1 <= "10";    
                     trans_size_2 <= "00";    
                     addr_incr <= "010";    
            WHEN "11111000" =>
                     ahb_trans_count <= "10";    --  two - single ahb transfers
                     trans_size_0 <= "00";    
                     trans_size_1 <= "10";    
                     trans_size_2 <= "00";    
                     addr_incr <= "011";    
            WHEN "11110000" =>
                     ahb_trans_count <= "01";    --  one - single ahb transfers
                     trans_size_0 <= "10";    
                     trans_size_1 <= "00";    
                     trans_size_2 <= "00";    
                     --addr_incr    <= 3'b100;
                     
                     IF ((axi2ahb_AWSIZE_r(1 DOWNTO 0) = "10") AND 
                     (axi2ahb_AWADDR(2 DOWNTO 0) = "100")) THEN
                        addr_incr <= "000";    
                     ELSE
                        addr_incr <= "100";    
                     END IF;
            WHEN "11100000" =>
                     ahb_trans_count <= "10";    --  two - single ahb transfers
                     trans_size_0 <= "00";    
                     trans_size_1 <= "01";    
                     trans_size_2 <= "00";    
                     --addr_incr    <= 3'b101;
                     
                     IF ((axi2ahb_AWSIZE_r(1 DOWNTO 0) = "10") AND 
                     (axi2ahb_AWADDR(2 DOWNTO 0) = "101")) THEN
                        addr_incr <= "001";    
                     ELSE
                        addr_incr <= "101";    
                     END IF;
            WHEN "11000000" =>
                     ahb_trans_count <= "01";    --  one - single ahb transfers
                     trans_size_0 <= "01";    
                     trans_size_1 <= "00";    
                     trans_size_2 <= "00";    
                     IF ((axi2ahb_AWSIZE_r(1 DOWNTO 0) = "10") AND 
                     (axi2ahb_AWADDR(2 DOWNTO 0) = "110")) THEN
                        addr_incr <= "010";    
                     ELSE
                        addr_incr <= "110";    
                     END IF;
            WHEN "10000000" =>
                     ahb_trans_count <= "01";    --  one - single ahb transfers
                     trans_size_0 <= "00";    
                     trans_size_1 <= "00";    
                     trans_size_2 <= "00";    
                     IF ((axi2ahb_AWSIZE_r(1 DOWNTO 0) = "10") AND 
                     (axi2ahb_AWADDR(2 DOWNTO 0) = "111")) THEN
                        addr_incr <= "011";    
                     ELSE
                        addr_incr <= "111";    
                     END IF;
            -- SAR#46417
            WHEN "00001111" =>
                     ahb_trans_count <= "01";    --  one - single ahb transfers
                     trans_size_0 <= "10";    
                     trans_size_1 <= "00";    
                     trans_size_2 <= "00";    
                     IF ((axi2ahb_AWSIZE_r(1 DOWNTO 0) = "10") AND 
                     (axi2ahb_AWADDR(2 DOWNTO 0) = "100")) THEN
                        addr_incr <= "100";    
                     ELSE
                        addr_incr <= "000";    
                     END IF;


            WHEN "00001110" =>
                     ahb_trans_count <= "10";    --  two - single ahb transfers
                     trans_size_0 <= "00";    
                     trans_size_1 <= "01";    
                     trans_size_2 <= "00";    
                     addr_incr <= "001";    
            WHEN "00001100" =>
                     ahb_trans_count <= "01";    --  one - single ahb transfers
                     trans_size_0 <= "01";    
                     trans_size_1 <= "00";    
                     trans_size_2 <= "00";    
                     addr_incr <= "010";    
            WHEN "00001000" =>
                     ahb_trans_count <= "01";    --  one - single ahb transfers
                     trans_size_0 <= "00";    
                     trans_size_1 <= "00";    
                     trans_size_2 <= "00";    
                     addr_incr <= "011";    
            WHEN "00000010" =>
                     ahb_trans_count <= "01";    --  one - single ahb transfers
                     trans_size_0 <= "00";    
                     trans_size_1 <= "00";    
                     trans_size_2 <= "00";    
                     addr_incr <= "001";    
            WHEN "00100000" =>
                     ahb_trans_count <= "01";    --  one - single ahb transfers
                     trans_size_0 <= "00";    
                     trans_size_1 <= "00";    
                     trans_size_2 <= "00";    
                     addr_incr <= "101";    
            WHEN OTHERS =>  --SAR#46417
                     ahb_trans_count <= "00";    --  one - single ahb transfers
                     trans_size_0 <= "00";    
                     trans_size_1 <= "00";    
                     trans_size_2 <= "00";    
                     addr_incr <= "000"; 		    
            
         END CASE;
      END IF;
   END PROCESS;

   PROCESS (HCLK, HRESETn)
   BEGIN
      IF (HRESETn = '0') THEN
         m2_set_addr_4_last_single_cyc <= '0';    
      ELSIF (HCLK'EVENT AND HCLK = '1') THEN
         IF (m2_curr_state = M2_BURST_COUNT) THEN
            m2_set_addr_4_last_single_cyc <= '1';    
         ELSE
            m2_set_addr_4_last_single_cyc <= '0';    
         END IF;
      END IF;
   END PROCESS;
   -------------------------------------------------------------------------------
   -- AHB Address Calculations
   -------------------------------------------------------------------------------
   m2_ahb_addr_set <= CONV_STD_LOGIC((m2_set_ahb_addr = '1') AND 
   ((m2_burst_len_count < m2_burst_size - "00001") OR 
   (m2_set_addr_4_last_single_cyc = '1'))) ;

   -------------------------------------------------------------------------------
   -- Decide number of AHB cycles and their Burst types from AXI count.
   -- m2_ahb_cyc_info = {no of single cycle, no of incr4 cyc, no of incr8 cyc, no of incr16 cyc}
   -------------------------------------------------------------------------------
   
   PROCESS ( 
   ram_rd_data 
   )
      VARIABLE m2_ahb_cyc_info_xhdl62  : std_logic_vector(7 DOWNTO 0);
   BEGIN
      CASE ram_rd_data(5 DOWNTO 0) IS
         -- single, incr4, incr8, incr16  
         
         WHEN "000000" =>
                  m2_ahb_cyc_info_xhdl62 := "00" & "00" & "00" & "00";    
         WHEN "000001" |
              "000010" |
              "000011" =>
                  m2_ahb_cyc_info_xhdl62 := ram_rd_data(1 DOWNTO 0) & "00" & 
                  "00" & "00";    
         WHEN "000100" =>
                  m2_ahb_cyc_info_xhdl62 := "00" & "01" & "00" & "00";    
         WHEN "000101" |
              "000110" |
              "000111" =>
                  m2_ahb_cyc_info_xhdl62 := ram_rd_data(1 DOWNTO 0) & "01" & 
                  "00" & "00";    
         WHEN "001000" =>
                  m2_ahb_cyc_info_xhdl62 := "00" & "00" & "01" & "00";    
         WHEN "001001" |
              "001010" |
              "001011" =>
                  m2_ahb_cyc_info_xhdl62 := ram_rd_data(1 DOWNTO 0) & "00" & "01" & "00";    --  9 to 11
         WHEN "001100" =>
                  m2_ahb_cyc_info_xhdl62 := "00" & "01" & "01" & "00";    --  12
         WHEN "001101" |
              "001110" |
              "001111" =>
                  m2_ahb_cyc_info_xhdl62 := ram_rd_data(1 DOWNTO 0) & "01" & "01" & "00";    --  13 to 15
         WHEN "010000" =>
                  m2_ahb_cyc_info_xhdl62 := "00" & "00" & "00" & "01";    --  16
         WHEN "010001" |
              "010010" |
              "010011" =>
                  m2_ahb_cyc_info_xhdl62 := ram_rd_data(1 DOWNTO 0) & "00" & "00" & "01";    --  17 to 19
         WHEN "010100" =>
                  m2_ahb_cyc_info_xhdl62 := "00" & "01" & "00" & "01";    --  20
         WHEN "010101" |
              "010110" |
              "010111" =>
                  m2_ahb_cyc_info_xhdl62 := ram_rd_data(1 DOWNTO 0) & "01" & "00" & "01";    --  21 to 23
         WHEN "011000" =>
                  m2_ahb_cyc_info_xhdl62 := "00" & "00" & "01" & "01";    --  24
         WHEN "011001" |
              "011010" |
              "011011" =>
                  m2_ahb_cyc_info_xhdl62 := ram_rd_data(1 DOWNTO 0) & "00" & "01" & "01";    --  25 to 27
         WHEN "011100" =>
                  m2_ahb_cyc_info_xhdl62 := "00" & "01" & "01" & "01";    --  28
         WHEN "011101" |
              "011110" |
              "011111" =>
                  m2_ahb_cyc_info_xhdl62 := ram_rd_data(1 DOWNTO 0) & "01" & "01" & "01";    --  29 to 31
         WHEN "100000" =>
                  m2_ahb_cyc_info_xhdl62 := "00" & "00" & "00" & "10";    --  32
         WHEN OTHERS  =>
                  m2_ahb_cyc_info_xhdl62 := "00000000";    
         
      END CASE;
      m2_ahb_cyc_info <= m2_ahb_cyc_info_xhdl62;
   END PROCESS;

   -------------------------------------------------------------------------------
   -- Latch AHB write/read response from Slave
   -------------------------------------------------------------------------------
   
   ahb_response : PROCESS (HCLK, HRESETn)
   BEGIN
      IF (HRESETn = '0') THEN
         hresp_r <= "00";    
      ELSIF (HCLK'EVENT AND HCLK = '1') THEN
         IF ((H_curr_state /= H_IDLE) AND (HREADYOUT_xhdl9 = '1')) THEN
            hresp_r <= HRESP(1 DOWNTO 0);    
         END IF;
      END IF;
   END PROCESS ahb_response;

   -------------------------------------------------------------------------------
   -- Below counter counts the number of AHB write/read respnose error conditions
   -------------------------------------------------------------------------------
   
   ahb_resp_err_count : PROCESS (HCLK, HRESETn)
   BEGIN
      IF (HRESETn = '0') THEN
         hresp_err_count_xhdl14 <= "00000";    
      ELSIF (HCLK'EVENT AND HCLK = '1') THEN
         IF (H_curr_state = H_IDLE) THEN
            hresp_err_count_xhdl14 <= "00000";    
         ELSE
            IF (HREADYOUT_xhdl9 = '1') THEN
               IF (hresp_r(1 DOWNTO 0) = c_ERR_RESP) THEN
                  -- error response
                  
                  hresp_err_count_xhdl14 <= hresp_err_count_xhdl14 + "00001";   
               END IF;
            END IF;
         END IF;
      END IF;
   END PROCESS ahb_resp_err_count;
   --/////////////////////////////////////////////////////////////////////////////
   -------------------------------------------------------------------------------
   -- Decide number of AHB read cycles and their Burst types from AXI count.
   -- R_ahb_cyc_info = {no of single cycle, no of incr4 cyc, no of incr8 cyc, no of incr16 cyc}
   -------------------------------------------------------------------------------
   arsize_8 <= axi2ahb_ARSIZE_r(1) AND axi2ahb_ARSIZE_r(0) ;
   arlen_custom(4 DOWNTO 0) <= arsize_8 & axi2ahb_ARLEN_r(3 DOWNTO 0) ;

   PROCESS (arlen_custom, axi2ahb_ARLEN_r)
      VARIABLE R_ahb_cyc_info_xhdl63  : std_logic_vector(7 DOWNTO 0);
   BEGIN
      CASE arlen_custom(4 DOWNTO 0) IS
         -- single, incr4, incr8, incr16  
         
         WHEN "10000" =>
                  R_ahb_cyc_info_xhdl63 := "10" & "00" & "00" & "00";    
         WHEN "10001" =>
                  R_ahb_cyc_info_xhdl63 := "00" & "01" & "00" & "00";    
         WHEN "10010" =>
                  R_ahb_cyc_info_xhdl63 := "10" & "01" & "00" & "00";    
         WHEN "10011" =>
                  R_ahb_cyc_info_xhdl63 := "00" & "00" & "01" & "00";    
         WHEN "10100" =>
                  R_ahb_cyc_info_xhdl63 := "10" & "00" & "01" & "00";    
         WHEN "10101" =>
                  R_ahb_cyc_info_xhdl63 := "00" & "01" & "01" & "00";    
         WHEN "10110" =>
                  R_ahb_cyc_info_xhdl63 := "10" & "01" & "01" & "00";    
         WHEN "10111" =>
                  R_ahb_cyc_info_xhdl63 := "00" & "00" & "00" & "01";    
         WHEN "11000" =>
                  R_ahb_cyc_info_xhdl63 := "10" & "00" & "00" & "01";    
         WHEN "11001" =>
                  R_ahb_cyc_info_xhdl63 := "00" & "01" & "00" & "01";    
         WHEN "11010" =>
                  R_ahb_cyc_info_xhdl63 := "10" & "01" & "00" & "01";    
         WHEN "11011" =>
                  R_ahb_cyc_info_xhdl63 := "00" & "00" & "01" & "01";    
         WHEN "11100" =>
                  R_ahb_cyc_info_xhdl63 := "10" & "00" & "01" & "01";    
         WHEN "11101" =>
                  R_ahb_cyc_info_xhdl63 := "00" & "01" & "01" & "01";    
         WHEN "11110" =>
                  R_ahb_cyc_info_xhdl63 := "10" & "01" & "01" & "01";    
         WHEN "11111" =>
                  R_ahb_cyc_info_xhdl63 := "00" & "00" & "00" & "10";    
         WHEN "00000" |
              "00001" |
              "00010" =>
                  R_ahb_cyc_info_xhdl63 := (axi2ahb_ARLEN_r(1 DOWNTO 0) + "01") 
                  & "00" & "00" & "00";    
         WHEN "00011" =>
                  R_ahb_cyc_info_xhdl63 := "00" & "01" & "00" & "00";    
         WHEN "00100" |
              "00101" |
              "00110" =>
                  R_ahb_cyc_info_xhdl63 := (axi2ahb_ARLEN_r(1 DOWNTO 0) + "01") 
                  & "01" & "00" & "00";    
         WHEN "00111" =>
                  R_ahb_cyc_info_xhdl63 := "00" & "00" & "01" & "00";    
         WHEN "01000" |
              "01001" |
              "01010" =>
                  R_ahb_cyc_info_xhdl63 := (axi2ahb_ARLEN_r(1 DOWNTO 0) + "01") 
                  & "00" & "01" & "00";    
         WHEN "01011" =>
                  R_ahb_cyc_info_xhdl63 := "00" & "01" & "01" & "00";    
         WHEN "01100" |
              "01101" |
              "01110" =>
                  R_ahb_cyc_info_xhdl63 := (axi2ahb_ARLEN_r(1 DOWNTO 0) + "01") 
                  & "01" & "01" & "00";    
         WHEN "01111" =>
                  R_ahb_cyc_info_xhdl63 := "00" & "00" & "00" & "01";    
         WHEN OTHERS  =>
                  R_ahb_cyc_info_xhdl63 := "00000000";    
         
      END CASE;
      R_ahb_cyc_info <= R_ahb_cyc_info_xhdl63;
   END PROCESS;

   -------------------------------------------------------------------------------
   -- Sequential block for AHB Read State Machine
   -------------------------------------------------------------------------------
   
   ahb_rd_fsm_seq_logic : PROCESS (HCLK, HRESETn)
   BEGIN
      IF (HRESETn = '0') THEN
         R_curr_state <= R_IDLE;    
      ELSIF (HCLK'EVENT AND HCLK = '1') THEN
         R_curr_state <= R_next_state;    
      END IF;
   END PROCESS ahb_rd_fsm_seq_logic;

   -------------------------------------------------------------------------------
   -- Combinational block for AHB Read Main State Machine
   -------------------------------------------------------------------------------
   
   ahb_rd_fsm_combo_logic : PROCESS (R_ahb_cyc_info_r, 
   R_len_count, R_subtop_count, R_max_len_count, HREADYIN, R_top_count, 
   R_next_state, rdch2ahb_fifo_full, R_curr_state, R_htrans_r, 
   axi2ahb_rd_start_syn, R_max_subtop_count 
   )
      VARIABLE R_next_state_xhdl64  : std_logic_vector(2 DOWNTO 0);
      VARIABLE R_top_count_en_xhdl65  : std_logic;
      VARIABLE R_subtop_count_en_xhdl66  : std_logic;
      VARIABLE R_max_subtop_count_load_xhdl67  : std_logic;
      VARIABLE R_ahb_cyc_info_shift_en_xhdl68  : std_logic;
      VARIABLE R_len_count_reset_xhdl69  : std_logic;
      VARIABLE R_ahb_cyc_info_load_xhdl70  : std_logic;
      VARIABLE R_len_count_en_xhdl71  : std_logic;
      VARIABLE R_read_cycle_en_xhdl72  : std_logic;
      VARIABLE R_read_addr_incr_en_xhdl73  : std_logic;
      VARIABLE R_read_addr_incr_en_1_xhdl74  : std_logic;
      VARIABLE R_ahb_read_done_xhdl75  : std_logic;
   BEGIN
      R_next_state_xhdl64 := R_curr_state;    
      R_top_count_en_xhdl65 := '0';    
      R_subtop_count_en_xhdl66 := '0';    
      R_max_subtop_count_load_xhdl67 := '0';    
      R_ahb_cyc_info_shift_en_xhdl68 := '0';    
      R_len_count_reset_xhdl69 := '0';    
      R_ahb_cyc_info_load_xhdl70 := '0';    
      R_len_count_en_xhdl71 := '0';    
      R_read_cycle_en_xhdl72 := '0';    
      R_read_addr_incr_en_xhdl73 := '0';    
      R_read_addr_incr_en_1_xhdl74 := '0';    
      R_ahb_read_done_xhdl75 := '0';    
      CASE R_curr_state IS
         ----------------------------------------------------- 
         -- IDLE state
         ----------------------------------------------------- 
         
         WHEN R_IDLE =>
                  IF (axi2ahb_rd_start_syn = '1') THEN
                     R_next_state_xhdl64 := R_DECIDE_CYC;    
                     R_ahb_cyc_info_load_xhdl70 := '1';    
                     R_read_cycle_en_xhdl72 := '1';    
                  END IF;
         WHEN R_DECIDE_CYC =>
                  R_read_cycle_en_xhdl72 := '1';    
                  IF (R_top_count(2 DOWNTO 0) = "101") THEN
                     R_next_state_xhdl64 := R_IDLE;    
                     R_ahb_read_done_xhdl75 := '1';    
                  ELSE
                     IF (R_ahb_cyc_info_r(1 DOWNTO 0) /= "00") THEN
                        R_next_state_xhdl64 := R_SEND_START_ADDR;    
                        R_len_count_reset_xhdl69 := '1';      -- 23/02/13 - 1H
                        R_top_count_en_xhdl65 := '1';    
                        R_max_subtop_count_load_xhdl67 := '1';    
                     ELSE
                        IF (R_ahb_cyc_info_r(1 DOWNTO 0) = "00") THEN
                           R_next_state_xhdl64 := R_DECIDE_CYC;    
                           R_top_count_en_xhdl65 := '1';    
                           R_ahb_cyc_info_shift_en_xhdl68 := '1';    
                        END IF;
                     END IF;
                  END IF;
         WHEN R_SEND_START_ADDR =>
                  R_read_cycle_en_xhdl72 := '1';    
                  --R_len_count_reset_xhdl69 := '1';     // 23/02/13 - 1H
                  IF (HREADYIN = '1') THEN
                     IF (R_top_count(2 DOWNTO 0) = "100") THEN
                        -- SINGLE transfers
                        
                        R_next_state_xhdl64 := R_GET_LAST_DATA;    
                        R_subtop_count_en_xhdl66 := '1';
			IF (R_htrans_r /= "00") THEN
                          R_read_addr_incr_en_xhdl73   := '1';         
                          R_read_addr_incr_en_1_xhdl74 := '1';
			END IF;
                     ELSE
                        -- INCR4/8/16 transfers
                        
                        R_next_state_xhdl64 := R_GET_DATA_N_ADDR;    
                        R_read_addr_incr_en_xhdl73 := '1';    -- 23/02/13 - 1H
                        R_read_addr_incr_en_1_xhdl74 := '1';  -- 23/02/13 - 1H  
                        R_subtop_count_en_xhdl66 := '1';    
                     END IF;
                  END IF;
         WHEN R_GET_DATA_N_ADDR =>
                  R_read_cycle_en_xhdl72 := '1';    
                  R_next_state_xhdl64 := R_GET_DATA_N_ADDR;   
		  -- Removal of synthesis warning 
                  --IF ((HREADYIN = '1' AND rdch2ahb_fifo_full = '0') AND (R_len_count(4 DOWNTO 0) < R_max_len_count(4 DOWNTO 0)) AND R_htrans_r /= "00")  -- 23/02/13 - 1H
                  IF ((HREADYIN = '1' AND rdch2ahb_fifo_full = '0') AND (R_len_count(4 DOWNTO 0) < (R_max_len_count(4 DOWNTO 0) - "00001")))
                  THEN
                     R_next_state_xhdl64 := R_GET_DATA_N_ADDR;    
                     R_len_count_en_xhdl71 := '1';    
                     R_read_addr_incr_en_xhdl73 := '1';    
                     R_read_addr_incr_en_1_xhdl74 := '1';    
                  ELSE
                     IF (rdch2ahb_fifo_full = '0' AND (R_len_count(4 DOWNTO 0) >= (R_max_len_count(4 DOWNTO 0) - "00001"))) THEN      -- 23/02/13 - 1H
                        R_next_state_xhdl64 := R_GET_LAST_DATA;    
                     END IF;
                  END IF;
         WHEN R_GET_LAST_DATA =>
                  R_read_cycle_en_xhdl72 := '1';    
                  IF (HREADYIN = '1') THEN
                     --if (rdch2ahb_fifo_full == 1'b0) begin
                     
                     IF (R_subtop_count(1 DOWNTO 0) < R_max_subtop_count(1 
                     DOWNTO 0)) THEN
                        R_next_state_xhdl64 := R_SEND_START_ADDR;    
                        R_len_count_reset_xhdl69 := '1';     -- 23/02/13 - 1H
                        R_read_addr_incr_en_xhdl73 := '1';    
			--IF (axi2ahb_AWSIZE_r = "011" AND R_next_state = R_SEND_START_ADDR) THEN -- 23/02/13 - 1H
                        --   R_read_addr_incr_en_1_xhdl74 := '0';     -- 23/02/13 - 1H
			--ELSE
			IF (R_htrans_r /= "00") THEN 
                           R_read_addr_incr_en_1_xhdl74 := '1';     -- 23/02/13 - 1I
			END IF;
                     ELSE
                        IF (R_top_count(2 DOWNTO 0) < "101") THEN
                           R_next_state_xhdl64 := R_DECIDE_CYC;    
                           R_ahb_cyc_info_shift_en_xhdl68 := '1';    
                           R_read_addr_incr_en_xhdl73 := '1';    
                        ELSE
                           R_next_state_xhdl64 := R_IDLE;    
                           R_ahb_read_done_xhdl75 := '1';    
                        END IF;
                     END IF;
                     --end
                     
                     
                  END IF;
         WHEN OTHERS  =>
                  R_next_state_xhdl64 := R_curr_state;    
         
      END CASE;
      R_next_state <= R_next_state_xhdl64;
      R_top_count_en <= R_top_count_en_xhdl65;
      R_subtop_count_en <= R_subtop_count_en_xhdl66;
      R_max_subtop_count_load <= R_max_subtop_count_load_xhdl67;
      R_ahb_cyc_info_shift_en <= R_ahb_cyc_info_shift_en_xhdl68;
      R_len_count_reset <= R_len_count_reset_xhdl69;
      R_ahb_cyc_info_load <= R_ahb_cyc_info_load_xhdl70;
      R_len_count_en <= R_len_count_en_xhdl71;
      R_read_cycle_en <= R_read_cycle_en_xhdl72;
      R_read_addr_incr_en <= R_read_addr_incr_en_xhdl73;
      R_read_addr_incr_en_1 <= R_read_addr_incr_en_1_xhdl74;
      R_ahb_read_done <= R_ahb_read_done_xhdl75;
   END PROCESS ahb_rd_fsm_combo_logic;

   -------------------------------------------------------------------------------
   -- Counter to count INCR16/INCR8/INCR4/SINGLE AHB transfers
   -------------------------------------------------------------------------------
   
   PROCESS (HCLK, HRESETn)
   BEGIN
      IF (HRESETn = '0') THEN
         R_top_count(2 DOWNTO 0) <= "000";    
      ELSIF (HCLK'EVENT AND HCLK = '1') THEN
         IF (R_curr_state = R_IDLE) THEN
            R_top_count(2 DOWNTO 0) <= "000";    
         ELSE
            IF (R_top_count_en = '1') THEN
               R_top_count(2 DOWNTO 0) <= R_top_count(2 DOWNTO 0) + "001";    
            END IF;
         END IF;
      END IF;
   END PROCESS;

   -------------------------------------------------------------------------------
   -- Counter to count INCR16/INCR8/INCR4/SINGLE AHB transfers
   -------------------------------------------------------------------------------
   
   PROCESS (HCLK, HRESETn)
   BEGIN
      IF (HRESETn = '0') THEN
         R_ahb_cyc_info_r(7 DOWNTO 0) <= "00000000";    
      ELSIF (HCLK'EVENT AND HCLK = '1') THEN
         IF (R_ahb_cyc_info_load = '1') THEN
            R_ahb_cyc_info_r(7 DOWNTO 0) <= R_ahb_cyc_info(7 DOWNTO 0);    
         ELSE
            IF (R_ahb_cyc_info_shift_en = '1') THEN
               --R_ahb_cyc_info_r(7 DOWNTO 0) <= R_ahb_cyc_info_r(7 DOWNTO 0) SRL "10";    
               R_ahb_cyc_info_r(7 DOWNTO 0) <= ShiftRight(R_ahb_cyc_info_r(7 DOWNTO 0),2);    
            END IF;
         END IF;
      END IF;
   END PROCESS;

   -------------------------------------------------------------------------------
   -- Hold the maximum count value of INCR16/8/4 transfers
   -------------------------------------------------------------------------------
   
   PROCESS (HCLK, HRESETn)
   BEGIN
      IF (HRESETn = '0') THEN
         R_max_len_count <= "00000";    
      ELSIF (HCLK'EVENT AND HCLK = '1') THEN
         CASE R_top_count(2 DOWNTO 0) IS
            WHEN "001" =>
                     R_max_len_count <= "10000";    
            WHEN "010" =>
                     R_max_len_count <= "01000";    
            WHEN "011" =>
                     R_max_len_count <= "00100";    
            WHEN "100" =>
                     R_max_len_count <= "00001";    
            WHEN OTHERS  =>
                     R_max_len_count <= "00000";    
            
         END CASE;
      END IF;
   END PROCESS;

   -------------------------------------------------------------------------------
   -- Count the number of AHB transfers in each burst
   -------------------------------------------------------------------------------
   
   PROCESS (HCLK, HRESETn)
   BEGIN
      IF (HRESETn = '0') THEN
         R_len_count <= "00000";    
      ELSIF (HCLK'EVENT AND HCLK = '1') THEN
         IF (R_len_count_reset = '1') THEN
            R_len_count <= "00000";    
         ELSE
            IF (R_len_count_en = '1') THEN
               R_len_count <= R_len_count + "00001";    
            END IF;
         END IF;
      END IF;
   END PROCESS;

   -------------------------------------------------------------------------------
   -- Maximum number of each type of AHB transfers
   -------------------------------------------------------------------------------
   
   PROCESS (HCLK, HRESETn)
   BEGIN
      IF (HRESETn = '0') THEN
         R_max_subtop_count <= "00";    
      ELSIF (HCLK'EVENT AND HCLK = '1') THEN
         IF (R_curr_state = R_IDLE) THEN
            R_max_subtop_count <= "00";    
         ELSE
            IF (R_max_subtop_count_load = '1') THEN
               R_max_subtop_count <= R_ahb_cyc_info_r(1 DOWNTO 0);    
            END IF;
         END IF;
      END IF;
   END PROCESS;

   -------------------------------------------------------------------------------
   -- This counter counts the number of AHB transfers of one type.
   -------------------------------------------------------------------------------
   
   PROCESS (HCLK, HRESETn)
   BEGIN
      IF (HRESETn = '0') THEN
         R_subtop_count <= "00";    
      ELSIF (HCLK'EVENT AND HCLK = '1') THEN
         IF (R_curr_state = R_DECIDE_CYC) THEN
            R_subtop_count <= "00";    
         ELSE
            IF (R_subtop_count_en = '1') THEN
               R_subtop_count <= R_subtop_count + "01";    
            END IF;
         END IF;
      END IF;
   END PROCESS;

   -------------------------------------------------------------------------------
   -- Registers 
   -------------------------------------------------------------------------------
   
   PROCESS (HCLK, HRESETn)
   BEGIN
      IF (HRESETn = '0') THEN
         axi2ahb_rd_start_syn <= '0';    
         ahb2axi_ahb_read_done_r_xhdl19 <= '0';    
      ELSIF (HCLK'EVENT AND HCLK = '1') THEN
         axi2ahb_rd_start_syn <= axi2xhsync_arlatch_syn;    
         ahb2axi_ahb_read_done_r_xhdl19 <= R_ahb_read_done;    
      END IF;
   END PROCESS;

   -------------------------------------------------------------------------------
   -- Generate Read cycle AHB Address
   -------------------------------------------------------------------------------
   
   PROCESS (HCLK, HRESETn)
   BEGIN
      IF (HRESETn = '0') THEN
         R_haddr_r <= (OTHERS => '0');    
      ELSIF (HCLK'EVENT AND HCLK = '1') THEN
         IF (R_ahb_cyc_info_load = '1') THEN
            R_haddr_r <= axi2ahb_ARADDR_r(AHB_AWIDTH - 1 DOWNTO 0);    
         ELSE
            IF (R_read_addr_incr_en_1 = '1') THEN
               CASE axi2ahb_ARSIZE_r(1 DOWNTO 0) IS
                  WHEN "11" =>
                           R_haddr_r <= R_haddr_r + 
                           "00000000000000000000000000000100";    
                  WHEN "10" =>
                           R_haddr_r <= R_haddr_r + 
                           "00000000000000000000000000000100";    
                  WHEN "01" =>
                           R_haddr_r <= R_haddr_r + 
                           "00000000000000000000000000000010";    
                  WHEN "00" =>
                           R_haddr_r <= R_haddr_r + 
                           "00000000000000000000000000000001";    
                  WHEN OTHERS =>
                           NULL;
                  
               END CASE;
            END IF;
         END IF;
      END IF;
   END PROCESS;
   R_hreadyout <= R_read_addr_incr_en ;

   PROCESS (HCLK, HRESETn)
   BEGIN
      IF (HRESETn = '0') THEN
         R_hread_r <= '0';    
      ELSIF (HCLK'EVENT AND HCLK = '1') THEN
         R_hread_r <= NOT R_read_cycle_en;    
      END IF;
   END PROCESS;


--  PROCESS (HCLK, HRESETn)
--  BEGIN
--     IF (HRESETn = '0') THEN
--        R_htrans_r <= "00";    
--     ELSIF (HCLK'EVENT AND HCLK = '1') THEN
--        CASE R_curr_state(2 DOWNTO 0) IS
--           WHEN R_SEND_START_ADDR =>
--                    R_htrans_r <= NONSEQ;    
--           WHEN R_GET_DATA_N_ADDR =>
--                    R_htrans_r <= temp_xhdl76;    
--           WHEN R_GET_LAST_DATA =>
--                    R_htrans_r <= IDLE;    
--           WHEN OTHERS =>
--                    NULL;
--           
--        END CASE;
--     END IF;
--  END PROCESS;

--   temp_xhdl76 <= IDLE WHEN ((R_hburst_r = TYPE_SINGLE) OR (R_next_state = R_GET_LAST_DATA) OR (((R_max_len_count-'1') = R_len_count) AND (R_len_count_en='1'))) ELSE SEQ;     -- 22/02/13 - 1H
   temp_xhdl76 <= IDLE WHEN ((R_hburst_r = TYPE_SINGLE) OR (R_next_state = R_GET_LAST_DATA) OR (((R_max_len_count-'1') = R_len_count))) ELSE SEQ;  -- SAR#46417

-- 22/02/13 - 1H - For assertion on Read side beats
   PROCESS (R_curr_state, temp_xhdl76)
   BEGIN
         CASE R_curr_state(2 DOWNTO 0) IS
            WHEN R_IDLE =>                         -- 23/02/13 - 1H
                     R_htrans_r <= IDLE;    
            WHEN R_SEND_START_ADDR =>
                     R_htrans_r <= NONSEQ;    
            WHEN R_GET_DATA_N_ADDR =>
                     R_htrans_r <= temp_xhdl76;    
            WHEN R_GET_LAST_DATA =>
                     R_htrans_r <= IDLE;    
            WHEN OTHERS =>
                     R_htrans_r <= IDLE;
            
         END CASE;
   END PROCESS;



   R_wrap_en <= CONV_STD_LOGIC(axi2ahb_ARBURST_r(1 DOWNTO 0) = "10") ;

--  PROCESS (HCLK, HRESETn)  -- 23/02/13 - 1H
--  BEGIN
--     IF (HRESETn = '0') THEN
--        R_hburst_r <= "000";    
--     ELSIF (HCLK'EVENT AND HCLK = '1') THEN
--        IF (R_wrap_en = '1') THEN
--           CASE R_top_count(2 DOWNTO 0) IS
--              WHEN "001" =>
--                       R_hburst_r <= TYPE_WRAP16;    
--              WHEN "010" =>
--                       R_hburst_r <= TYPE_WRAP8;    
--              WHEN "011" =>
--                       R_hburst_r <= TYPE_WRAP4;    
--              WHEN "100" =>
--                       R_hburst_r <= TYPE_SINGLE;    
--              WHEN OTHERS =>
--                       NULL;
--              
--           END CASE;
--        ELSE
--           CASE R_top_count(2 DOWNTO 0) IS
--              WHEN "001" =>
--                       R_hburst_r <= TYPE_INCR16;    
--              WHEN "010" =>
--                       R_hburst_r <= TYPE_INCR8;    
--              WHEN "011" =>
--                       R_hburst_r <= TYPE_INCR4;    
--              WHEN "100" =>
--                       R_hburst_r <= TYPE_SINGLE;    
--              WHEN OTHERS =>
--                       NULL;
--              
--           END CASE;
--        END IF;
--     END IF;
--  END PROCESS;

   PROCESS (R_wrap_en, R_top_count)      -- 23/02/13 - 1H
   BEGIN
         IF (R_wrap_en = '1') THEN
            CASE R_top_count(2 DOWNTO 0) IS
               WHEN "001" =>
                        R_hburst_r <= TYPE_WRAP16;    
               WHEN "010" =>
                        R_hburst_r <= TYPE_WRAP8;    
               WHEN "011" =>
                        R_hburst_r <= TYPE_WRAP4;    
               WHEN "100" =>
                        R_hburst_r <= TYPE_SINGLE;    
               WHEN OTHERS =>
                        R_hburst_r <= "000";
               
            END CASE;
         ELSE
            CASE R_top_count(2 DOWNTO 0) IS
               WHEN "001" =>
                        R_hburst_r <= TYPE_INCR16;    
               WHEN "010" =>
                        R_hburst_r <= TYPE_INCR8;    
               WHEN "011" =>
                        R_hburst_r <= TYPE_INCR4;    
               WHEN "100" =>
                        R_hburst_r <= TYPE_SINGLE;    
               WHEN OTHERS => R_hburst_r <= "000";
               
            END CASE;
         END IF;
   END PROCESS;



   PROCESS (HCLK, HRESETn)
   BEGIN
      IF (HRESETn = '0') THEN
         R_hsize_r <= "000";    
      ELSIF (HCLK'EVENT AND HCLK = '1') THEN
         CASE axi2ahb_ARSIZE_r(2 DOWNTO 0) IS
            WHEN "000" =>
                     R_hsize_r <= "000";    --  Byte transfer
            WHEN "001" =>
                     R_hsize_r <= "001";    --  Halfword transfer
            WHEN "010" =>
                     R_hsize_r <= "010";    --  Word transfer
            WHEN "011" =>
                     R_hsize_r <= "010";    --  Word transfer
            WHEN OTHERS =>
                     NULL;
            
         END CASE;
      END IF;
   END PROCESS;
   -------------------------------------------------------------------------------
   -- Write AHB data into Read Channel FIFO
   -------------------------------------------------------------------------------
   ahb2rdch_fifo_wr_en_xhdl16 <= R_read_addr_incr_en AND 
   CONV_STD_LOGIC(R_htrans_r /= NONSEQ) ;
   ahb2rdch_fifo_wr_data_xhdl17 <= HRDATA(AHB_DWIDTH - 1 DOWNTO 0) ;
   ahb2rdch_rd_resp_data_xhdl18 <= HRESP(1 DOWNTO 0) ;

   -- Added by AP - 15/07/11 - (This is done to delay the AHB state machine by 1 cycle)
   
   PROCESS (HCLK, HRESETn)
   BEGIN
      IF (HRESETn = '0') THEN
         axi2ahb_wr_fifo_done_syn_d <= '0';    
      ELSIF (HCLK'EVENT AND HCLK = '1') THEN
         axi2ahb_wr_fifo_done_syn_d <= axi2ahb_wr_fifo_done_syn;    
      END IF;
   END PROCESS;

END ARCHITECTURE translated;
