// *********************************************************************/ 
// Copyright (c) 2009 Actel Corporation.  All rights reserved.  
// 
// Any use or redistribution in part or in whole must be handled in 
// accordance with the Actel license agreement and must be approved 
// in advance in writing.  
//  
// File : CORESDRAHB.v 
//     
// Description: This module is interfaces with the AHB I/F and Local bus of 
//              SDRAM controller.
//
// Notes:
//   - add HBURST port to AHBLite interface in order to support multiple burst lengths
// *********************************************************************/ 
`timescale 1ns/1ps

module CORESDR_AHB_BURST_32DQ (HCLK, HRESETN, HADDR, HSIZE, HSEL, HTRANS, HWRITE, HWDATA, HREADYIN, HRESP, HRDATA, HREADY, SDRCLK_IN ,SDRCLK_OUT, OE, SA, BA, CS_N, DQM, CKE, RAS_N, CAS_N, WE_N, DQ, SDRCLK_RESETN, HBURST);

   parameter ECC  = 1;
   parameter FAMILY  = 16;
   parameter SYS_FREQ  = 0;                // 0=HCLK; 1=2*HCLK; 2=4*HCLK
   parameter SDRAM_RASIZE  = 31;
   parameter SDRAM_CHIPS  = 8;
   parameter SDRAM_COLBITS  = 12;
   parameter SDRAM_ROWBITS  = 14;
   parameter SDRAM_CHIPBITS  = 3;
   parameter SDRAM_BANKSTATMODULES  = 4;
   parameter SDRAM_DQSIZE  = 32;

   parameter [3:0] RAS = 2;                // Minimum ACTIVE to PRECHARGE
   parameter [2:0] RCD = 1;                // Minimum time between ACTIVATE and READ/WRITE
   parameter [1:0] RRD = 1;                // Minimum time between ACTIVATE to ACTIVATE in different banks
   parameter [2:0] RP = 1;                 // Minimum PRECHARGE to ACTIVATE.
   parameter [3:0] RC = 3;                 // Minimum ACTIVATE to ACTIVATE in same bank.
   parameter [3:0] RFC = 10;               // Minimum AUTO-REFRESH to ACTIVATE/AUTO-REFRESH in same bank  
   parameter [1:0] WR = 2;                 // Minimum delay from write to PRECHARGE
   parameter [2:0] MRD = 2;                // Minimum LOADMODE to ACTIVATE command.
   parameter [2:0] CL = 3;                 // Cas latency.
   parameter [15:0] DELAY = 6800;          // Initialization delay
   parameter [15:0] REF = 4096;            // Refresh Period.
   parameter [1:0] ROWBITS = 3;            // # of row bits on sdram device(s)
   parameter [2:0] COLBITS = 7;            // # of column bits on sdram device(s)
   parameter [0:0] REGDIMM = 0;            // Registered/Buffered DIMMS
   parameter [0:0] AUTO_PCH = 0;           // issues read with auto precharge or write with auto precharge
  
   parameter SYNC_RESET = (FAMILY == 25) ? 1 : 0;

   localparam SDRAM_DQMSIZE  = SDRAM_DQSIZE / 8;
   localparam COMMAND_SIZE  = SDRAM_RASIZE + 7;
   
   input             HCLK; 
   input             HRESETN; 
   input             HSEL; 
   input             HWRITE; 
   input             HREADYIN; 
   input[1:0]        HTRANS; 
   input[2:0]        HSIZE;
   input [2:0]       HBURST;
   input[31:0]       HWDATA; 
   input[31:0]       HADDR; 
   output reg        HREADY; 
   output reg [1:0]  HRESP; 
   output reg [31:0] HRDATA; 

   input             SDRCLK_IN;
   input             SDRCLK_RESETN;
   output            SDRCLK_OUT; 
   output            OE; 
   output[13:0]      SA; 
   output[1:0]       BA; 
   output            CKE; 
   output            RAS_N; 
   output            CAS_N; 
   output            WE_N;
   output[SDRAM_CHIPS - 1:0]   CS_N; 
   output[SDRAM_DQMSIZE - 1:0] DQM; 
 
   inout[SDRAM_DQSIZE - 1:0]   DQ; 

   
   parameter[3:0] IDLE           = 4'b0000; 
   parameter[3:0] ADDRESS        = 4'b0001; 
   parameter[3:0] TX_FIFO_WR     = 4'b0010;
   parameter[3:0] SDR_WR         = 4'b0011;
   parameter[3:0] SDR_WR_TER     = 4'b1110;
   parameter[3:0] SDR_WR_1       = 4'b0100;
   parameter[3:0] SDR_WR_2       = 4'b0101;
   parameter[3:0] SDR_RD_DECODE  = 4'b0110;
   parameter[3:0] SDR_RD         = 4'b0111;
   parameter[3:0] SDR_RD1        = 4'b1000;
   parameter[3:0] SDR_RD2        = 4'b1001;
   parameter[3:0] AHB_RD_BUFFER  = 4'b1010;
   parameter[3:0] AHB_RD_BUFFER1 = 4'b1011;
   parameter[3:0] AHB_RD_BUFFER2 = 4'b1100;
   parameter[3:0] AHB_RD         = 4'b1101;




   wire ASDRCLK_RESETN;
   wire SSDRCLK_RESETN;
   wire AHRESETN;
   wire SHRESETN;


   assign ASDRCLK_RESETN = (SYNC_RESET == 1) ? 1'b1 : SDRCLK_RESETN;
   assign SSDRCLK_RESETN = (SYNC_RESET == 1) ? SDRCLK_RESETN : 1'b1;
   assign AHRESETN = (SYNC_RESET == 1) ? 1'b1 : HRESETN;
   assign SHRESETN = (SYNC_RESET == 1) ? HRESETN : 1'b1;


   reg [3:0]   byte_en; 
   reg         HSELREG; 
   wire        acen;
   reg [31:0] haddr_reg; 
   reg [2:0]  hsize_reg; 
   wire [31:0] dataout; 
   wire [31:0] hdataout_reg; 
   wire        RW_ACK; 
   wire        R_VALID; 
   wire        D_REQ; 
   wire        W_VALID; 
   reg [3:0]   B_SIZE_ahb;
   reg [3:0]   B_SIZE_sdr_d;
   reg [3:0]   B_SIZE_sdr;
   reg [4:0]   B_SIZE_ovride;
   reg         B_SIZE_ovride_en;
   reg [1:0]   HTRANS_d;
   reg [1:0]   HTRANS_d1;
   
   wire        dqm_sdr;
 
   reg [SDRAM_RASIZE-1 : 0] raddr_ahb;
   reg [SDRAM_RASIZE-1 : 0] raddr_sdr;
   reg [SDRAM_RASIZE-1 : 0] raddr_sdr_d;
 

   wire [31:0]  data_out_fifo;
   wire [31:0]  rd_data_out_fifo;
   wire         w_valid_negedge;
   wire         w_valid_negedge_ahb;
   wire         r_valid_negedge;
   wire         r_valid_negedge_ahb;
   wire         tx_fifo_wr_en;
   wire         rx_fifo_rd_en_ahb;
   wire         HSEL_S;
   
   reg          HWRITE_d;
   reg          w_valid_d;
   reg          r_valid_d;
   reg          rx_fifo_rd_en_ahb_d;
   reg          HREADY_AHB;
   reg          rx_fifo_rd_done ;
   reg          command_latch_en;
   reg          R_REQ_sdr ;
   reg          W_REQ_sdr ;
   reg          one_time_sdr_read  ;
   reg          one_time_sdr1_read ;
   reg          one_time_sdr2_read ;
   reg          one_time_sdr_wr    ;
   reg          one_time_sdr1_wr   ;
   reg          one_time_sdr2_wr   ;
   reg          rx_fifo_first_read ;



   reg          burst_terminate_ahb  /* synthesis syn_preserve=1 */;
   reg          burst_terminate_sdr;
   reg          burst_terminate_sdr_s /* synthesis syn_preserve=1 */;
   reg [3:0]    state_ahb/* synthesis syn_preserve=1 */;
   reg [3:0]    state_sdr/* synthesis syn_preserve=1 */;
   reg [3:0]    state_sdr_d;
   reg [3:0]    state_sdr_d1;
   reg [3:0]    state_sdr_d2;
   reg [3:0]    state_sdr_d3;
   reg [1:0]    tx_split_transaction;
   reg [1:0]    rx_split_transaction;
   reg [4:0]    rx_fifo_rd_cnt;
   reg [COMMAND_SIZE-2:0]   command;
   reg [COMMAND_SIZE-1:0]   command_latch;
   reg [4:0]    tx_fifo_data_en_count;
   reg [3:0]    B_SIZE_reg;
   reg [3:0]    B_SIZE1_reg;
   reg [3:0]    B_SIZE2_reg;
   reg [SDRAM_RASIZE-1 : 0] RADDR_reg;
   reg [SDRAM_RASIZE-1 : 0] RADDR1_reg;
   reg [SDRAM_RASIZE-1 : 0] RADDR2_reg;

   

   assign dataout[SDRAM_DQSIZE-1:0] = DQ[SDRAM_DQSIZE-1:0] ;
   assign SDRCLK_OUT = SDRCLK_IN ;
   assign HSEL_S =  (HSEL== 1) ? ((HTRANS == 0) ? 1'b0 : 1'b1 ) : 1'b0 ;
    
   always @(posedge HCLK or negedge AHRESETN)begin
      if ((!AHRESETN) || (!SHRESETN))
       begin
         HSELREG <= 1'b0 ;
       end
      else
       begin
         if (HREADYIN == 1'b1)
          begin
            HSELREG <= HSEL_S ; 
          end 
       end 
    end 

   assign acen = HSEL_S & HREADYIN;
  
   always @(*) begin
      byte_en = 4'b1111 ;
      if (OE == 1'b1) begin
         case (command[COMMAND_SIZE-2:COMMAND_SIZE-4])
         3'b000 : // for byte size
         begin
            case (command[1:0])
            2'b00 :
            begin
               byte_en = 4'b1110 ; // Byte0 enabled
            end
            2'b01 :
            begin
               byte_en = 4'b1101 ; // Byte1 enabled
            end
            2'b10 :
            begin
               byte_en = 4'b1011 ; // Byte2 enabled
            end
            2'b11 :
            begin
               byte_en = 4'b0111 ; // Byte3 enabled
            end
            default :
            begin
               byte_en = 4'b1111 ; // None of the byte lanes are enabled
            end
            endcase 
         end
         3'b001 :  // for half word
         begin
            case (command[1])
            1'b0 :
            begin
               byte_en = 4'b1100 ; // lower half bytes are enabled 
            end
            1'b1 :
            begin
               byte_en = 4'b0011 ;  // upper half bytes are enabled
            end
            default :
            begin
               byte_en = 4'b1111 ; // None of the byte lanes are enabled
            end
            endcase 
         end
         3'b010 : // for word
         begin
            byte_en = 4'b0000 ; // all the byte lanes are enabled
         end
         default :
         begin
            byte_en = 4'b1111 ; // all the byte lanes are disabled
         end
         endcase 
      end
   end

   assign DQM[0] = dqm_sdr | (OE & (byte_en[0]) );
   assign DQM[1] = dqm_sdr | (OE & (byte_en[1]) ) ;
   assign DQM[2] = dqm_sdr | (OE & byte_en[2]) ;
   assign DQM[3] = dqm_sdr | (OE & byte_en[3]) ;


 always @(posedge HCLK or negedge AHRESETN)begin
    if ((!AHRESETN) || (!SHRESETN)) begin
       haddr_reg <= 32'b0 ; 
       hsize_reg <= 3'b0 ; 
    end
    else begin 
       if (acen == 1'b1) begin
          haddr_reg <= HADDR ; 
          hsize_reg <= HSIZE ; 
       end 
    end 
 end 

   // Generate HREADY which is sent out to AHB interface
   always @(*)
    begin 
      HREADY = 1'b1 ; 
      HRESP = 2'b0 ; 
      HRDATA = 32'b0 ;
      if (HSELREG == 1'b1)
      begin
        HREADY = HREADY_AHB ; 
        case (hsize_reg)
        3'b000 :   // for byte size
        begin
           case (haddr_reg[1:0])
           2'b00 :
           begin
              HRDATA = ({hdataout_reg[7:0], hdataout_reg[7:0], hdataout_reg[7:0], hdataout_reg[7:0]}) ; 
           end
           2'b01 :
           begin
              HRDATA = ({hdataout_reg[15:8], hdataout_reg[15:8], hdataout_reg[15:8], hdataout_reg[15:8]}) ; 
           end
           2'b10 :
           begin
              HRDATA = ({hdataout_reg[23:16], hdataout_reg[23:16], hdataout_reg[23:16], hdataout_reg[23:16]}) ; 
           end
           2'b11 :
           begin
              HRDATA = ({hdataout_reg[31:24], hdataout_reg[31:24], hdataout_reg[31:24], hdataout_reg[31:24]}) ; 
           end
           default :
           begin
              HRDATA = hdataout_reg[31:0] ; 
           end
           endcase 
        end
        3'b001 :  // for half word
        begin
           case (haddr_reg[1])
           1'b0 :
           begin
              HRDATA = ({hdataout_reg[15:0], hdataout_reg[15:0]}) ; 
           end
           1'b1 :
           begin
              HRDATA = ({hdataout_reg[31:16], hdataout_reg[31:16]}) ;
           end
           default :
           begin
             HRDATA = hdataout_reg[31:0] ; 
           end
           endcase 
        end
        3'b010 :  // for word
        begin
           HRDATA = hdataout_reg[31:0] ; 
        end
        default :
        begin
           HRDATA = hdataout_reg[31:0] ; 
        end
        endcase 
      end
    end 


   always @(posedge HCLK or negedge AHRESETN)begin
      if ((!AHRESETN) || (!SHRESETN)) begin
         command_latch_en        <= 1'b0;
         burst_terminate_ahb     <= 1'b0;
         command                 <= {(COMMAND_SIZE-1){1'd0}};
         command_latch           <= {(COMMAND_SIZE){1'd0}};
         tx_fifo_data_en_count   <= 5'd1;
         rx_fifo_first_read      <= 1'b0;
         raddr_ahb               <= {(SDRAM_RASIZE){1'd0}};
         B_SIZE_ahb              <= 4'd0;
         HREADY_AHB              <= 1'b1;
         state_ahb                   <= IDLE ; 
         B_SIZE_ovride           <=5'b0; 
         B_SIZE_ovride_en        <=1'b0;
      end else begin
         case (state_ahb)
         IDLE :
         begin
            HREADY_AHB              <= 1'b1;
            state_ahb             <= ADDRESS ; 
         end
         ADDRESS :
         begin
            tx_fifo_data_en_count   <= 5'd1;
            burst_terminate_ahb     <= 1'b0;
            if((( acen ==1'b1) & (HTRANS == 2'b10)) | ((acen ==1'b1) & (HBURST ==3'b001 |((HBURST ==3'b010 | HBURST ==3'b011 | HBURST ==3'b100 | HBURST ==3'b101 | HBURST ==3'b110 | HBURST ==3'b111) & (HSIZE==3'b0 | HSIZE==3'b1))) & (HTRANS == 2'b11)))begin
               command            <= { HSIZE,HBURST,HADDR[SDRAM_RASIZE-1 : 0]};
               command_latch_en   <=  1'b0;
               if (HWRITE) begin
                  HREADY_AHB        <= 1'b1;
                  state_ahb             <= TX_FIFO_WR ;
               end else begin
                  HREADY_AHB        <= 1'b0;
                  state_ahb             <= SDR_RD_DECODE ;
               end
            end else begin
               HREADY_AHB        <= 1'b1;
               state_ahb             <= ADDRESS ;
            end
         end
         TX_FIFO_WR :
         begin
            if((((acen ==1'b1) & (HTRANS == 2'b10)) | ((acen ==1'b1) & (HBURST ==3'b001|((HBURST ==3'b010 | HBURST ==3'b011 | HBURST ==3'b100 | HBURST ==3'b101 | HBURST ==3'b110 | HBURST ==3'b111) & (HSIZE==3'b0 | HSIZE==3'b1))) & (HTRANS == 2'b11)))) begin
               command_latch       <= { HWRITE,HSIZE,HBURST,HADDR[SDRAM_RASIZE-1 : 0]};
               command_latch_en    <=  1'b1;
            end 
            
            if (tx_fifo_wr_en) begin
               if((((command [(COMMAND_SIZE-5):(COMMAND_SIZE-7)] == 3'd0) || (command [(COMMAND_SIZE-5):(COMMAND_SIZE-7)] == 3'd1))| (command[(COMMAND_SIZE-2):(COMMAND_SIZE-4)] == 3'd0) | (command[(COMMAND_SIZE-2):(COMMAND_SIZE-4)] == 3'd1) ) ) begin
                  if(HTRANS==2'b01) begin
                     HREADY_AHB                <= 1'b1;
                     state_ahb                     <= SDR_WR ;
                  end else begin
                     HREADY_AHB                <= 1'b0;
                     state_ahb                     <= SDR_WR ;
                  end
               end else if ((command [(COMMAND_SIZE-5):(COMMAND_SIZE-7)]  ==3'd2 | command [(COMMAND_SIZE-5):(COMMAND_SIZE-7)]  ==3'd3) ) begin
                  if(tx_fifo_data_en_count == 5'd4 ) begin
                     tx_fifo_data_en_count     <=5'd1;
                     HREADY_AHB                <= 1'b0;
                     state_ahb                     <= SDR_WR ;
                  end else begin
                     if( tx_fifo_data_en_count != 5'd4 & HTRANS == 2'b00 & acen ==1'b0) begin
                        tx_fifo_data_en_count     <=5'd1;
                        state_ahb                     <= SDR_WR_TER ;
                        B_SIZE_ovride             <=tx_fifo_data_en_count; 
                        B_SIZE_ovride_en          <=1'b1;
                        HREADY_AHB                <=1'b0;
                     end else begin
                        tx_fifo_data_en_count     <= tx_fifo_data_en_count +1'b1;
                        HREADY_AHB                <= 1'b1;
                     end
                  end
               end else if (command [(COMMAND_SIZE-5):(COMMAND_SIZE-7)]  ==3'd4 | command [(COMMAND_SIZE-5):(COMMAND_SIZE-7)]  ==3'd5) begin
                  if(tx_fifo_data_en_count == 5'd8 ) begin
                     tx_fifo_data_en_count     <=5'd1;
                     HREADY_AHB                <= 1'b0;
                     state_ahb                     <= SDR_WR;
                  end else begin
                     if( tx_fifo_data_en_count != 5'd8 & HTRANS == 2'b00 & acen ==1'b0) begin
                        tx_fifo_data_en_count     <=5'd1;
                        state_ahb                     <= SDR_WR_TER ;
                        B_SIZE_ovride             <=tx_fifo_data_en_count;
                        B_SIZE_ovride_en          <=1'b1;
                        HREADY_AHB                <=1'b0;
                     end else begin
                        tx_fifo_data_en_count     <= tx_fifo_data_en_count +1'b1;
                        HREADY_AHB                <= 1'b1;
                     end
                  end
               end else if (command [(COMMAND_SIZE-5):(COMMAND_SIZE-7)]  ==3'd6 | command [(COMMAND_SIZE-5):(COMMAND_SIZE-7)]  ==3'd7) begin
                  if(tx_fifo_data_en_count == 5'd16 ) begin
                     tx_fifo_data_en_count     <=5'd1;
                     HREADY_AHB                <= 1'b0;
                     state_ahb                     <= SDR_WR;
                  end else begin
                     if( tx_fifo_data_en_count != 5'd16 & HTRANS == 2'b00 & acen ==1'b0) begin
                        tx_fifo_data_en_count     <=5'd1;
                        state_ahb                     <= SDR_WR_TER ;
                        B_SIZE_ovride             <=tx_fifo_data_en_count; 
                        B_SIZE_ovride_en          <=1'b1; 
                        HREADY_AHB                <=1'b0;
                     end
                     else begin
                        tx_fifo_data_en_count     <= tx_fifo_data_en_count +1'b1;
                        HREADY_AHB                <= 1'b1;
                     end
                  end
               end
            end
         end
         SDR_WR_TER :
         begin
            if((( acen ==1'b1) & (HTRANS == 2'b10)) | ((acen ==1'b1) & (HBURST ==3'b001 |((HBURST ==3'b010 | HBURST ==3'b011 | HBURST ==3'b100 | HBURST ==3'b101 | HBURST ==3'b110 | HBURST ==3'b111) & (HSIZE==3'b0 | HSIZE==3'b1))) & (HTRANS == 2'b11)))begin
               command_latch       <= { HWRITE,HSIZE,HBURST,HADDR[SDRAM_RASIZE-1 : 0]};
               command_latch_en    <=  1'b1;
            end 
               state_ahb               <= SDR_WR;
               HREADY_AHB          <= 1'b0;
         end
         SDR_WR :
         begin
            raddr_ahb  <= {2'b00,RADDR_reg[SDRAM_RASIZE-1 : 2]};
            B_SIZE_ahb <= B_SIZE_reg;
            tx_fifo_data_en_count<=1'b1;
            if((( acen ==1'b1) & (HTRANS == 2'b10)) | ((acen ==1'b1) & (HTRANS == 2'b11) & ((HBURST ==3'b001)|((HBURST==3'b010 | HBURST==3'b011 | HBURST==3'b100 | HBURST==3'b101 | HBURST==3'b110 | HBURST==3'b111) & (HSIZE ==3'b001 | HSIZE == 3'b000 ) & (HTRANS_d==2'b01))))) begin
               command_latch       <= { HWRITE,HSIZE,HBURST,HADDR[SDRAM_RASIZE-1 : 0]};
               command_latch_en    <=  1'b1;
            end 

            if(w_valid_negedge_ahb && tx_split_transaction ==2'b00 )begin
               B_SIZE_ovride_en      <=1'b0; 
               if(command_latch_en) begin
                  command             <=command_latch[COMMAND_SIZE-2:0];
                  command_latch_en     <=1'b0;
                  if (command_latch[COMMAND_SIZE-1]) begin
                     HREADY_AHB        <= 1'b1;
                     state_ahb             <= TX_FIFO_WR ;
                  end else begin
                     HREADY_AHB        <= 1'b0;
                     state_ahb             <= SDR_RD_DECODE ;
                  end
               end else if((( acen ==1'b1) & (HTRANS == 2'b10)) | ((acen ==1'b1) & (HBURST ==3'b001 |((HBURST ==3'b010 | HBURST ==3'b011 | HBURST ==3'b100 | HBURST ==3'b101 | HBURST ==3'b110 | HBURST ==3'b111) & (HSIZE==3'b0 | HSIZE==3'b1))) & (HTRANS == 2'b11)))begin
               command            <= { HSIZE,HBURST,HADDR[SDRAM_RASIZE-1 : 0]};
               command_latch_en   <=  1'b0;
                  if(HWRITE==1'b1) begin
                     HREADY_AHB        <= 1'b1;
                     state_ahb             <= TX_FIFO_WR ;
                  end else begin
                     HREADY_AHB        <= 1'b0;
                     state_ahb             <= SDR_RD_DECODE ;
                  end
               end else begin 
                  state_ahb             <= ADDRESS ;
                  HREADY_AHB        <= 1'b1;
               end
            end else if(w_valid_negedge_ahb && tx_split_transaction !=2'b00 )begin
               HREADY_AHB        <= 1'b0;
               state_ahb             <= SDR_WR_1 ;
            end else begin
               HREADY_AHB        <= 1'b0;
               state_ahb             <= SDR_WR ;
            end 
         end
         SDR_WR_1 :
         begin
            raddr_ahb <={2'b00,RADDR1_reg[SDRAM_RASIZE-1 : 2]};
            B_SIZE_ahb<= B_SIZE1_reg;
            if((( acen ==1'b1) & (HTRANS == 2'b10)) | ((acen ==1'b1) & (HTRANS == 2'b11) & ((HBURST ==3'b001)|((HBURST==3'b010 | HBURST==3'b011 | HBURST==3'b100 | HBURST==3'b101 | HBURST==3'b110 | HBURST==3'b111) & (HSIZE ==3'b001 | HSIZE == 3'b000 ) & (HTRANS_d==2'b01))))) begin
               command_latch       <= { HWRITE,HSIZE,HBURST,HADDR[SDRAM_RASIZE-1 : 0]};
               command_latch_en    <=  1'b1;
            end 

            if(w_valid_negedge_ahb && tx_split_transaction ==2'b01 )begin
               B_SIZE_ovride_en      <=1'b0; 
               if(command_latch_en) begin
                  command             <=command_latch[COMMAND_SIZE-2:0];
                  command_latch_en     <=1'b0;
                  if (command_latch[COMMAND_SIZE-1]) begin
                     HREADY_AHB        <= 1'b1;
                     state_ahb             <= TX_FIFO_WR ;
                  end else begin
                     HREADY_AHB        <= 1'b0;
                     state_ahb             <= SDR_RD_DECODE ;
                  end
              end else if((( acen ==1'b1) & (HTRANS == 2'b10)) | ((acen ==1'b1) & (HBURST ==3'b001 |((HBURST ==3'b010 | HBURST ==3'b011 | HBURST ==3'b100 | HBURST ==3'b101 | HBURST ==3'b110 | HBURST ==3'b111) & (HSIZE==3'b0 | HSIZE==3'b1))) & (HTRANS == 2'b11)))begin
               command            <= { HSIZE,HBURST,HADDR[SDRAM_RASIZE-1 : 0]};
               command_latch_en   <=  1'b0;
                  if(HWRITE==1'b1) begin
                     HREADY_AHB        <= 1'b1;
                     state_ahb             <= TX_FIFO_WR ;
                  end else begin
                     HREADY_AHB        <= 1'b0;
                     state_ahb             <= SDR_RD_DECODE ;
                  end
               end else begin 
                  state_ahb             <= ADDRESS ;
                  HREADY_AHB        <= 1'b1;
               end
            end else if(w_valid_negedge_ahb && tx_split_transaction ==2'b10 )begin
               HREADY_AHB        <= 1'b0;
               state_ahb             <= SDR_WR_2 ;
            end else begin
               HREADY_AHB        <= 1'b0;
               state_ahb             <= SDR_WR_1 ;
            end 
         end
         SDR_WR_2 :
         begin
            raddr_ahb <={2'b00,RADDR2_reg[SDRAM_RASIZE-1 : 2]};
            B_SIZE_ahb<= B_SIZE2_reg;
            if((( acen ==1'b1) & (HTRANS == 2'b10)) | ((acen ==1'b1) & (HTRANS == 2'b11) & ((HBURST ==3'b001)|((HBURST==3'b010 | HBURST==3'b011 | HBURST==3'b100 | HBURST==3'b101 | HBURST==3'b110 | HBURST==3'b111) & (HSIZE ==3'b001 | HSIZE == 3'b000 ) & (HTRANS_d==2'b01))))) begin
               command_latch       <= { HWRITE,HSIZE,HBURST,HADDR[SDRAM_RASIZE-1 : 0]};
               command_latch_en    <=  1'b1;
            end 
  
            if( w_valid_negedge_ahb == 1'b1 )begin
               B_SIZE_ovride_en      <=1'b0; 
               if(command_latch_en) begin
                  command             <=command_latch[COMMAND_SIZE-2:0];
                  command_latch_en     <=1'b0;
                  if (command_latch[COMMAND_SIZE-1]) begin
                     HREADY_AHB        <= 1'b1;
                     state_ahb             <= TX_FIFO_WR ;
                  end else begin
                     HREADY_AHB        <= 1'b0;
                     state_ahb             <= SDR_RD_DECODE ;
                  end
               end else if((( acen ==1'b1) & (HTRANS == 2'b10)) | ((acen ==1'b1) & (HBURST ==3'b001 |((HBURST ==3'b010 | HBURST ==3'b011 | HBURST ==3'b100 | HBURST ==3'b101 | HBURST ==3'b110 | HBURST ==3'b111) & (HSIZE==3'b0 | HSIZE==3'b1))) & (HTRANS == 2'b11)))begin
               command            <= { HSIZE,HBURST,HADDR[SDRAM_RASIZE-1 : 0]};
               command_latch_en   <=  1'b0;
                  if(HWRITE==1'b1) begin
                     HREADY_AHB        <= 1'b1;
                     state_ahb             <= TX_FIFO_WR ;
                  end else begin
                     HREADY_AHB        <= 1'b0;
                     state_ahb             <= SDR_RD_DECODE ;
                  end
               end else begin 
                  state_ahb             <= ADDRESS ;
                  HREADY_AHB        <= 1'b1;
               end
            end else begin
               HREADY_AHB        <= 1'b0;
               state_ahb             <= SDR_WR_2 ;
            end 
         end
         
         SDR_RD_DECODE :
         begin
            HREADY_AHB          <=1'b0;
            state_ahb               <= SDR_RD ;
            if (command_latch_en ==1'b1) begin
               command             <=command_latch[COMMAND_SIZE-2:0];
               command_latch_en    <=  1'b0;
            end
          end
         SDR_RD :
         begin
            raddr_ahb  <={2'b00,RADDR_reg[SDRAM_RASIZE-1 : 2]};
            B_SIZE_ahb <= B_SIZE_reg;
            HREADY_AHB <=1'b0;
            if (r_valid_negedge_ahb ==1'b1 && (rx_split_transaction !==2'b00)) begin
               state_ahb <= SDR_RD1 ; 
            end else if (r_valid_negedge_ahb == 1'b1) begin
               state_ahb <= AHB_RD_BUFFER ;
            end
         end
    
         SDR_RD1 :
         begin
            raddr_ahb  <={2'b00,RADDR1_reg[SDRAM_RASIZE-1 : 2]};
            B_SIZE_ahb <= B_SIZE1_reg;
            HREADY_AHB <=1'b0;
            if (r_valid_negedge_ahb ==1'b1 &&  rx_split_transaction ==2'b10 ) begin
               state_ahb <= SDR_RD2 ; 
            end
            else if (r_valid_negedge_ahb == 1'b1 ) begin
               state_ahb <= AHB_RD_BUFFER ; 
            end
         end
         SDR_RD2 :
         begin
            raddr_ahb  <={2'b00,RADDR2_reg[SDRAM_RASIZE-1 : 2]};
            B_SIZE_ahb <= B_SIZE2_reg;
            HREADY_AHB <=1'b0;
            if (r_valid_negedge_ahb ==1'b1 ) begin
               state_ahb <= AHB_RD_BUFFER ; 
            end
         end
         AHB_RD_BUFFER :
         begin
            HREADY_AHB <=1'b0;
            state_ahb <= AHB_RD_BUFFER1 ; 
         end
         AHB_RD_BUFFER1 :
         begin
            HREADY_AHB <=1'b0;
            state_ahb <= AHB_RD_BUFFER2 ; 
         end
         AHB_RD_BUFFER2 :
         begin
            HREADY_AHB <=1'b0;
            rx_fifo_first_read <=1'b1;
            state_ahb <= AHB_RD ; 
         end
         AHB_RD :
         begin
            rx_fifo_first_read <=1'b0;
            if((( acen ==1'b1)& (HTRANS == 2'b10)) | ((acen ==1'b1) & (HBURST ==3'b001|((HBURST ==3'b010 | HBURST ==3'b011 | HBURST ==3'b100 | HBURST ==3'b101 | HBURST ==3'b110 | HBURST ==3'b111) & (HSIZE==3'b0 | HSIZE==3'b1 ))) & (HTRANS == 2'b11)))begin
               command       <= { HSIZE,HBURST,HADDR[SDRAM_RASIZE-1 : 0]};
               if( rx_fifo_rd_done ==1'b1 ) begin
                  if(HWRITE) begin
                     state_ahb             <= TX_FIFO_WR ;
                     HREADY_AHB        <= 1'b1;
                  end else begin
                     state_ahb             <= SDR_RD_DECODE ;
                     HREADY_AHB        <= 1'b0;
                  end
               end
            end else if (HTRANS ==2'b00 & (command [(COMMAND_SIZE-5):(COMMAND_SIZE-7)]  !=3'd0 )) begin
               burst_terminate_ahb <=1'b1;
               state_ahb             <= ADDRESS ;
               HREADY_AHB        <= 1'b1;
            end else if (rx_fifo_rd_done ) begin
               state_ahb             <= ADDRESS ;
               HREADY_AHB        <= 1'b1;
            end else begin
               state_ahb             <= AHB_RD ;
               HREADY_AHB        <= 1'b1;
            end
         end
         default :
         begin
            command_latch_en        <= 1'b0;
            burst_terminate_ahb     <= 1'b0;
            command                 <= {(COMMAND_SIZE-1){1'd0}};
            command_latch           <= {(COMMAND_SIZE){1'd0}};
            tx_fifo_data_en_count   <= 5'd1;
            rx_fifo_first_read      <= 1'b0;
            raddr_ahb               <= {(SDRAM_RASIZE){1'd0}};
            B_SIZE_ahb              <= 4'd0;
            HREADY_AHB              <= 1'b1;
            state_ahb                   <= IDLE ; 
         end
         endcase 
      end 
   end

//////////read and write request generation logic//////////////
   always @(posedge SDRCLK_IN or negedge ASDRCLK_RESETN) begin
      if ((!ASDRCLK_RESETN) || (!SSDRCLK_RESETN)) begin
         W_REQ_sdr               <=1'b0;
         R_REQ_sdr               <=1'b0;
         one_time_sdr_read       <=1'b0;
         one_time_sdr1_read      <=1'b0;
         one_time_sdr2_read      <=1'b0;
         one_time_sdr_wr         <=1'b0; 
         one_time_sdr1_wr        <=1'b0; 
         one_time_sdr2_wr        <=1'b0; 
      end else begin
         case (state_sdr_d2)
         ADDRESS :
         begin
            one_time_sdr_read    <=1'b0; 
            one_time_sdr1_read   <=1'b0; 
            one_time_sdr2_read   <=1'b0;
            one_time_sdr_wr      <=1'b0; 
            one_time_sdr1_wr     <=1'b0; 
            one_time_sdr2_wr     <=1'b0; 
         end
         TX_FIFO_WR :
         begin
            one_time_sdr_read    <=1'b0; 
            one_time_sdr1_read   <=1'b0; 
            one_time_sdr2_read   <=1'b0;
            one_time_sdr_wr      <=1'b0; 
            one_time_sdr1_wr     <=1'b0; 
            one_time_sdr2_wr     <=1'b0; 
         end
         SDR_WR :
         begin
            if(RW_ACK)begin
               W_REQ_sdr <=1'b0;
            end else if (one_time_sdr_wr == 1'b0 && state_sdr_d3== SDR_WR)begin
               W_REQ_sdr <=1'b1;
               one_time_sdr_wr  <=1'b1;
            end
            one_time_sdr_read    <=1'b0; 
            one_time_sdr1_read   <=1'b0; 
            one_time_sdr2_read   <=1'b0;
            one_time_sdr1_wr     <=1'b0; 
            one_time_sdr2_wr     <=1'b0; 
         end
         SDR_WR_1 :
         begin
            if(RW_ACK)begin
               W_REQ_sdr <=1'b0;
            end else if (one_time_sdr1_wr == 1'b0 && state_sdr_d3== SDR_WR_1)begin
               W_REQ_sdr       <=1'b1;
               one_time_sdr1_wr  <=1'b1;
            end
            one_time_sdr_read    <=1'b0; 
            one_time_sdr1_read   <=1'b0; 
            one_time_sdr2_read   <=1'b0;
            one_time_sdr_wr      <=1'b0; 
            one_time_sdr2_wr     <=1'b0; 
         end
         SDR_WR_2 :
         begin
            if(RW_ACK)begin
               W_REQ_sdr <=1'b0;
            end else if (one_time_sdr2_wr == 1'b0 && state_sdr_d3== SDR_WR_2)begin
               W_REQ_sdr <=1'b1;
               one_time_sdr2_wr  <=1'b1;
            end
            one_time_sdr_read    <=1'b0; 
            one_time_sdr1_read   <=1'b0; 
            one_time_sdr2_read   <=1'b0;
            one_time_sdr_wr      <=1'b0; 
            one_time_sdr1_wr     <=1'b0; 
         end
         SDR_RD_DECODE :
         begin
            one_time_sdr_read    <=1'b0; 
            one_time_sdr1_read   <=1'b0; 
            one_time_sdr2_read   <=1'b0;
            one_time_sdr_wr      <=1'b0; 
            one_time_sdr1_wr     <=1'b0; 
            one_time_sdr2_wr     <=1'b0; 
         end
         SDR_RD :
         begin
            if(RW_ACK)begin
               R_REQ_sdr <=1'b0;
            end else if (one_time_sdr_read == 1'b0 && state_sdr_d3== SDR_RD)begin
               R_REQ_sdr <=1'b1;
               one_time_sdr_read  <=1'b1;
            end
            one_time_sdr1_read   <=1'b0; 
            one_time_sdr2_read   <=1'b0;
            one_time_sdr_wr      <=1'b0; 
            one_time_sdr1_wr     <=1'b0; 
            one_time_sdr2_wr     <=1'b0; 
         end
         SDR_RD1 :
         begin
            if(RW_ACK)begin
               R_REQ_sdr <=1'b0;
            end else if (one_time_sdr1_read == 1'b0 && state_sdr_d3== SDR_RD1)begin
               R_REQ_sdr <=1'b1;
               one_time_sdr1_read  <=1'b1;
            end
            one_time_sdr_read    <=1'b0; 
            one_time_sdr2_read   <=1'b0;
            one_time_sdr_wr      <=1'b0; 
            one_time_sdr1_wr     <=1'b0; 
            one_time_sdr2_wr     <=1'b0; 
         end
         SDR_RD2 :
         begin
            if(RW_ACK)begin
               R_REQ_sdr <=1'b0;
            end else if (one_time_sdr2_read == 1'b0 && state_sdr_d3== SDR_RD2)begin
               R_REQ_sdr <=1'b1;
               one_time_sdr2_read  <=1'b1;
            end
            one_time_sdr_read    <=1'b0; 
            one_time_sdr1_read   <=1'b0; 
            one_time_sdr_wr      <=1'b0; 
            one_time_sdr1_wr     <=1'b0; 
            one_time_sdr2_wr     <=1'b0; 
         end
         default:
         begin
            W_REQ_sdr               <=1'b0;
            R_REQ_sdr               <=1'b0;
            one_time_sdr_read       <=1'b0;
            one_time_sdr1_read      <=1'b0;
            one_time_sdr2_read      <=1'b0;
            one_time_sdr_wr         <=1'b0; 
            one_time_sdr1_wr        <=1'b0; 
            one_time_sdr2_wr        <=1'b0; 
         end
         endcase
      end
   end


//////////////////////Address and B_size decoding///////////////////

   always @(posedge HCLK or negedge AHRESETN)begin
      if ((!AHRESETN) || (!SHRESETN)) begin
         RADDR_reg               <= {(SDRAM_RASIZE){1'd0}};
         RADDR1_reg              <= {(SDRAM_RASIZE){1'd0}};
         RADDR2_reg              <= {(SDRAM_RASIZE){1'd0}};
         tx_split_transaction    <= 2'b00;
         rx_split_transaction    <= 2'b00;
         B_SIZE_reg              <= 4'd0;
         B_SIZE1_reg             <= 4'd0;
         B_SIZE2_reg             <= 4'd0; 
      end else begin
         case (command [(COMMAND_SIZE-5):(COMMAND_SIZE-7)])
         3'b000 :
	 begin
            RADDR_reg              <= command [(SDRAM_RASIZE-1):0];
            tx_split_transaction   <=2'b00;
            rx_split_transaction   <=2'b00;
            B_SIZE_reg             <=4'b0001;
         end        
         3'b001 :
	 begin
            RADDR_reg              <= command [(SDRAM_RASIZE-1):0];
	    tx_split_transaction   <=2'b00;
            rx_split_transaction   <=2'b00;
            B_SIZE_reg             <=4'b0001;
         end 
         3'b010 : 
	 begin
            if(command [(COMMAND_SIZE-2):(COMMAND_SIZE-4)]==3'b0 | command [(COMMAND_SIZE-2):(COMMAND_SIZE-4)]==3'b1)begin
               RADDR_reg              <= command [(SDRAM_RASIZE-1):0];
               tx_split_transaction   <=2'b00;
               rx_split_transaction   <=2'b00;
               B_SIZE_reg             <=4'b0001;
            end
            else begin
               case(command [4:2])
               3'b000,3'b100 :
               begin
                  if (B_SIZE_ovride_en ==1) begin
                     RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                     tx_split_transaction    <=2'b00;
                     B_SIZE_reg              <=B_SIZE_ovride[3:0];
                  end else begin
                     RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                     tx_split_transaction   <=2'b00;
                     rx_split_transaction   <=2'b00;
                     B_SIZE_reg             <=4'b0100;
                  end
               end
               3'b001, 3'b101 : 
	       begin
                  if (B_SIZE_ovride_en ==1) begin
                     RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                     tx_split_transaction    <=2'b00;
                     B_SIZE_reg              <=B_SIZE_ovride[3:0];
                  end else begin
                     RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                     RADDR1_reg              <= command[(SDRAM_RASIZE-1):0] - 4'b0100;
                     tx_split_transaction   <=2'b01;
                     rx_split_transaction   <=2'b01;
                     B_SIZE_reg             <=4'b0011;
                     B_SIZE1_reg            <=4'b0001;
                  end
               end
               3'b010 ,3'b110: 
	       begin
                  if (B_SIZE_ovride_en ==1) begin
                     if(B_SIZE_ovride < 5'd3) begin
                        RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                        tx_split_transaction   <=2'b00;
                        B_SIZE_reg             <=B_SIZE_ovride[3:0];
                     end else begin
                        RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                        RADDR1_reg              <= command[(SDRAM_RASIZE-1):0] - 4'b1000;
                        tx_split_transaction   <=2'b01;
                        B_SIZE_reg             <=4'b0010;
                        B_SIZE1_reg            <=4'b0001;
                     end
                  end else begin
                     RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                     RADDR1_reg              <= command[(SDRAM_RASIZE-1):0] - 4'b1000;
                     tx_split_transaction   <=2'b01;
                     rx_split_transaction   <=2'b01;
                     B_SIZE_reg             <=4'b0010;
                     B_SIZE1_reg            <=4'b0010;
                  end
               end
               3'b011, 3'b111 : 
	       begin
                  if (B_SIZE_ovride_en ==1) begin
                     if(B_SIZE_ovride == 5'd1) begin
                        RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                        tx_split_transaction   <=2'b00;
                        B_SIZE_reg             <=4'b0001;
                     end else if(B_SIZE_ovride == 5'd2) begin
                        RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                        RADDR1_reg              <= command[(SDRAM_RASIZE-1):0] - 4'b1100;
                        tx_split_transaction   <=2'b01;
                        B_SIZE_reg             <=4'b0001;
                        B_SIZE1_reg            <=4'b0001;
                     end else if(B_SIZE_ovride == 5'd3) begin
                        RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                        RADDR1_reg              <= command[(SDRAM_RASIZE-1):0] - 4'b1100;
                        tx_split_transaction   <=2'b01;
                        B_SIZE_reg             <=4'b0001;
                        B_SIZE1_reg            <=4'b0010;
                     end
                  end else begin
                     RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                     RADDR1_reg              <= command[(SDRAM_RASIZE-1):0] - 4'b1100;
                     tx_split_transaction   <=2'b01;
                     rx_split_transaction   <=2'b01;
                     B_SIZE_reg             <=4'b0001;
                     B_SIZE1_reg            <=4'b0011;
                  end
               end
               endcase
            end
         end 
         3'b011 : 
	 begin
            if(command [(COMMAND_SIZE-2):(COMMAND_SIZE-4)]==3'b0 | command [(COMMAND_SIZE-2):(COMMAND_SIZE-4)]==3'b1)begin
               RADDR_reg              <= command [(SDRAM_RASIZE-1):0];
               tx_split_transaction   <=2'b00;
               rx_split_transaction   <=2'b00;
               B_SIZE_reg             <=4'b0001;
            end else begin
               case(command [4:2])
               3'b000,3'b001,3'b010,3'b011,3'b100 :
               begin
                  if (B_SIZE_ovride_en ==1) begin
                     RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                     tx_split_transaction    <=2'b00;
                     B_SIZE_reg              <=B_SIZE_ovride[3:0];
                  end else begin
                     RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                     tx_split_transaction   <=2'b00;
                     rx_split_transaction   <=2'b00;
                     B_SIZE_reg             <=4'b0100;
                  end
               end
               3'b101 : 
	       begin
                  if (B_SIZE_ovride_en ==1) begin
                     RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                     tx_split_transaction    <=2'b00;
                     B_SIZE_reg              <=B_SIZE_ovride[3:0];
                  end else begin
                     RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                     RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+ 4'b1100;
                     tx_split_transaction   <=2'b01;
                     rx_split_transaction   <=2'b01;
                     B_SIZE_reg             <=4'b0011;
                     B_SIZE1_reg            <=4'b0001;
                  end
               end
               3'b110 : 
	       begin
                  if (B_SIZE_ovride_en ==1) begin
                     if(B_SIZE_ovride < 5'd3) begin
                        RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                        tx_split_transaction   <=2'b00;
                        B_SIZE_reg             <=B_SIZE_ovride[3:0];
                     end else begin
                        RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                        RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+ 4'b1000;
                        tx_split_transaction   <=2'b01;
                        B_SIZE_reg             <=4'b0010;
                        B_SIZE1_reg            <=4'b0001;
                     end
                  end else begin
                     RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                     RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+ 4'b1000;
                     tx_split_transaction   <=2'b01;
                     rx_split_transaction   <=2'b01;
                     B_SIZE_reg             <=4'b0010;
                     B_SIZE1_reg            <=4'b0010;
                  end
               end
               3'b111 :
	       begin
                  if (B_SIZE_ovride_en ==1) begin
                     if(B_SIZE_ovride == 5'd1) begin
                        RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                        tx_split_transaction   <=2'b00;
                        B_SIZE_reg             <=4'b0001;
                     end else if(B_SIZE_ovride == 5'd2) begin
                        RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                        RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+4'b0100;
                        tx_split_transaction   <=2'b01;
                        B_SIZE_reg             <=4'b0001;
                        B_SIZE1_reg            <=4'b0001;
                     end else if(B_SIZE_ovride == 5'd3) begin
                        RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                        RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+4'b0100;
                        tx_split_transaction   <=2'b01;
                        B_SIZE_reg             <=4'b0001;
                        B_SIZE1_reg            <=4'b0010;
                     end
	          end else begin
                     RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                     RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+4'b0100;
                     tx_split_transaction   <=2'b01;
                     rx_split_transaction   <=2'b01;
                     B_SIZE_reg             <=4'b0001;
                     B_SIZE1_reg            <=4'b0011;
                  end
               end
               endcase
            end
         end 
         3'b100 : 
	 begin
            if(command [(COMMAND_SIZE-2):(COMMAND_SIZE-4)]==3'b0 | command [(COMMAND_SIZE-2):(COMMAND_SIZE-4)]==3'b1)begin
               RADDR_reg              <= command [(SDRAM_RASIZE-1):0];
               tx_split_transaction   <=2'b00;
               rx_split_transaction   <=2'b00;
               B_SIZE_reg             <=4'b0001;
            end else begin
               if (B_SIZE_ovride_en ==1) begin
                  RADDR_reg              <= command[(SDRAM_RASIZE-1):0];
                  tx_split_transaction   <=2'b00;
                  B_SIZE_reg             <=B_SIZE_ovride[3:0];
               end else begin
                  RADDR_reg              <= command[(SDRAM_RASIZE-1):0];
                  tx_split_transaction   <=2'b00;
                  rx_split_transaction   <=2'b00;
                  B_SIZE_reg             <=4'b1000;
               end
            end
         end
         3'b101 : 
	 begin
            if(command [(COMMAND_SIZE-2):(COMMAND_SIZE-4)]==3'b0 | command [(COMMAND_SIZE-2):(COMMAND_SIZE-4)]==3'b1)begin
               RADDR_reg              <= command [(SDRAM_RASIZE-1):0];
               tx_split_transaction   <=2'b00;
               rx_split_transaction   <=2'b00;
               B_SIZE_reg             <=4'b0001;
            end else begin
               case(command [4:2])
               3'b000 : 
	       begin
                  if (B_SIZE_ovride_en ==1) begin
                     RADDR_reg              <= command[(SDRAM_RASIZE-1):0];
                     tx_split_transaction   <=2'b00;
                     B_SIZE_reg             <=B_SIZE_ovride[3:0];
                  end else begin
                     RADDR_reg              <= command[(SDRAM_RASIZE-1):0];
                     tx_split_transaction   <=2'b00;
                     rx_split_transaction   <=2'b00;
                     B_SIZE_reg             <=4'b1000;
                  end
               end
               3'b001 :
	       begin
                  if (B_SIZE_ovride_en ==1) begin
                     RADDR_reg              <= command[(SDRAM_RASIZE-1):0];
                     tx_split_transaction   <=2'b00;
                     B_SIZE_reg             <=B_SIZE_ovride[3:0];
                  end else begin
                     RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                     RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+ 5'b11100;
                     tx_split_transaction   <=2'b01;
                     rx_split_transaction   <=2'b01;
                     B_SIZE_reg             <=4'b0111;
                     B_SIZE1_reg            <=4'b0001;
                  end
               end
               3'b010 :
	       begin
                  if (B_SIZE_ovride_en ==1) begin
                     if(B_SIZE_ovride < 5'd7) begin
                        RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                        tx_split_transaction   <=2'b00;
                        B_SIZE_reg             <=B_SIZE_ovride[3:0];
                     end else begin
                        RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                        RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+ 5'b11000;
                        tx_split_transaction   <=2'b01;
                        B_SIZE_reg             <=4'b0110;
                        B_SIZE1_reg            <=4'b0001;
                     end
                  end else begin
                     RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                     RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+ 5'b11000;
                     tx_split_transaction   <=2'b01;
                     rx_split_transaction   <=2'b01;
                     B_SIZE_reg             <=4'b0110;
                     B_SIZE1_reg            <=4'b0010;
                  end
               end
               3'b011 :
	       begin
                  if (B_SIZE_ovride_en ==1) begin
                     if(B_SIZE_ovride < 5'd6) begin
                        RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                        tx_split_transaction   <=2'b00;
                        B_SIZE_reg             <=B_SIZE_ovride[3:0];
                     end else begin
                        RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                        RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+5'b10100;
                        tx_split_transaction   <=2'b01;
                        B_SIZE_reg             <=4'b0101;
                        B_SIZE1_reg            <=B_SIZE_ovride- 4'b0101; 
                     end
                  end else begin
                     RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                     RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+5'b10100;
                     tx_split_transaction   <=2'b01;
                     rx_split_transaction   <=2'b01;
                     B_SIZE_reg             <=4'b0101;
                     B_SIZE1_reg            <=4'b0011;
                  end
               end
               3'b100 : 
	       begin
                  if (B_SIZE_ovride_en ==1) begin
                     if(B_SIZE_ovride < 5'd5) begin
                        RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                        tx_split_transaction   <=2'b00;
                        B_SIZE_reg             <=B_SIZE_ovride[3:0];
                     end else begin
                        RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                        RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+5'b10000;
                        tx_split_transaction   <=2'b01;
                        B_SIZE_reg             <=4'b0100;
                        B_SIZE1_reg            <=B_SIZE_ovride- 4'b0100;  
                     end
                  end else begin
                     RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                     RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+5'b10000;
                     tx_split_transaction   <=2'b01;
                     rx_split_transaction   <=2'b01;
                     B_SIZE_reg             <=4'b0100;
                     B_SIZE1_reg            <=4'b0100;
                  end
               end
               3'b101 : 
	       begin
                  if (B_SIZE_ovride_en ==1) begin
                     if(B_SIZE_ovride < 5'd4) begin
                        RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                        tx_split_transaction   <=2'b00;
                        B_SIZE_reg             <=B_SIZE_ovride[3:0];
                     end else begin
                        RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                        RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+5'b01100;
                        tx_split_transaction   <=2'b01;
                        B_SIZE_reg             <=4'b0011;
                        B_SIZE1_reg            <=B_SIZE_ovride- 4'b0011;
                     end
                  end else begin
                     RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                     RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+5'b01100;
                     tx_split_transaction   <=2'b01;
                     rx_split_transaction   <=2'b01;
                     B_SIZE_reg             <=4'b0011;
                     B_SIZE1_reg            <=4'b0101;
                  end
               end
               3'b110 :
	       begin
                  if (B_SIZE_ovride_en ==1) begin
                     if(B_SIZE_ovride < 5'd3) begin
                        RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                        tx_split_transaction   <=2'b00;
                        B_SIZE_reg             <=B_SIZE_ovride[3:0];
                     end else begin
                        RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                        RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+5'b01000;
                        tx_split_transaction    <=2'b01;
                        B_SIZE_reg              <=4'b0010;
                        B_SIZE1_reg             <=B_SIZE_ovride- 4'b0010;
                     end
                  end else begin
                     RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                     RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+5'b01000;
                     tx_split_transaction   <=2'b01;
                     rx_split_transaction   <=2'b01;
                     B_SIZE_reg             <=4'b0010;
                     B_SIZE1_reg            <=4'b0110;
                  end
               end
               3'b111 : 
	       begin
                  if (B_SIZE_ovride_en ==1) begin
                     if(B_SIZE_ovride < 5'd2) begin
                        RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                        tx_split_transaction   <=2'b00;
                        B_SIZE_reg             <=B_SIZE_ovride[3:0];
                     end else begin
                        RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                        RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+5'b00100;
                        tx_split_transaction    <=2'b01;
                        B_SIZE_reg              <=4'b0001;
                        B_SIZE1_reg             <=B_SIZE_ovride- 4'b0001;
                     end
                  end else begin
                     RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                     RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+5'b00100;
                     tx_split_transaction   <=2'b01;
                     rx_split_transaction   <=2'b01;
                     B_SIZE_reg             <=4'b0001;
                     B_SIZE1_reg            <=4'b0111;
                  end
               end
               endcase
            end
         end
         3'b110 : 
	 begin
            if(command [(COMMAND_SIZE-2):(COMMAND_SIZE-4)]==3'b0 | command [(COMMAND_SIZE-2):(COMMAND_SIZE-4)]==3'b1)begin
               RADDR_reg              <= command [(SDRAM_RASIZE-1):0];
               tx_split_transaction   <=2'b00;
               rx_split_transaction   <=2'b00;
               B_SIZE_reg             <=4'b0001;
            end else begin
               case(command [5:2])
               4'b0000 : 
	       begin
                  if (B_SIZE_ovride_en ==1) begin
                     if(B_SIZE_ovride < 5'd9) begin
                        RADDR_reg              <= command[(SDRAM_RASIZE-1):0];
                        tx_split_transaction   <=2'b00;
                        B_SIZE_reg             <=B_SIZE_ovride[3:0];
                     end else begin
                        RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                        RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+6'b100000;
                        tx_split_transaction    <=2'b01;
                        B_SIZE_reg              <=4'b1000;
                        B_SIZE1_reg             <=B_SIZE_ovride- 4'b1000;
                     end
                  end else begin
                     RADDR_reg              <= command[(SDRAM_RASIZE-1):0];
                     RADDR1_reg             <= command[(SDRAM_RASIZE-1):0]+6'b100000;
                     tx_split_transaction   <=2'b01;
                     rx_split_transaction   <=2'b01;
                     B_SIZE_reg             <=4'b1000;
                     B_SIZE1_reg            <=4'b1000;
                  end 
               end
               4'b0001 :
	       begin
                  if (B_SIZE_ovride_en ==1) begin
                     if(B_SIZE_ovride < 5'd8) begin
                        RADDR_reg              <= command[(SDRAM_RASIZE-1):0];
                        tx_split_transaction   <=2'b00;
                        B_SIZE_reg             <=B_SIZE_ovride[3:0];
                     end else begin
                        RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                        RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+ 6'b011100;
                        tx_split_transaction    <=2'b01;
                        B_SIZE_reg              <=4'b0111;
                        B_SIZE1_reg             <=B_SIZE_ovride- 4'b0111;
                     end
                  end else begin
                     RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                     RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+ 6'b011100;
                     RADDR2_reg              <= command[(SDRAM_RASIZE-1):0]- 6'b000100;
                     tx_split_transaction   <=2'b10;
                     rx_split_transaction   <=2'b10;
                     B_SIZE_reg             <=4'b0111;
                     B_SIZE1_reg            <=4'b1000;
                     B_SIZE2_reg            <=4'b0001; 
                  end
	       end
               4'b0010 :
	       begin
                  if (B_SIZE_ovride_en ==1) begin
                     if(B_SIZE_ovride < 5'd7) begin
                        RADDR_reg              <= command[(SDRAM_RASIZE-1):0];
                        tx_split_transaction   <=2'b00;
                        B_SIZE_reg             <=B_SIZE_ovride[3:0];
                     end else if ( B_SIZE_ovride > 5'd6 & B_SIZE_ovride < 5'd15)begin
                        RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                        RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+ 6'b011000;
                        tx_split_transaction    <=2'b01;
                        B_SIZE_reg              <=4'b0110;
                        B_SIZE1_reg             <=B_SIZE_ovride- 4'b0110;
		     end else begin
                        RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                        RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+ 6'b011000;
                        RADDR2_reg              <= command[(SDRAM_RASIZE-1):0]- 6'b001000;
                        tx_split_transaction    <=2'b10;
                        B_SIZE_reg              <=4'b0110;
                        B_SIZE1_reg             <=4'b1000 ;
                        B_SIZE2_reg             <=4'b0001; 
		     end
                  end else begin
                     RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                     RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+ 6'b011000;
                     RADDR2_reg              <= command[(SDRAM_RASIZE-1):0]- 6'b001000;
                     tx_split_transaction   <=2'b10;
                     rx_split_transaction   <=2'b10;
                     B_SIZE_reg             <=4'b0110;
                     B_SIZE1_reg            <=4'b1000;
                     B_SIZE2_reg            <=4'b0010; 
                  end
               end
               4'b0011 :
	       begin
                  if (B_SIZE_ovride_en ==1) begin
                     if(B_SIZE_ovride < 5'd6) begin
                        RADDR_reg              <= command[(SDRAM_RASIZE-1):0];
                        tx_split_transaction   <=2'b00;
                        B_SIZE_reg             <=B_SIZE_ovride[3:0];
                     end else if ( B_SIZE_ovride > 5'd5 & B_SIZE_ovride < 5'd14)begin
                        RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                        RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+6'b010100;
                        tx_split_transaction    <=2'b01;
                        B_SIZE_reg              <=4'b0101;
                        B_SIZE1_reg             <=B_SIZE_ovride- 4'b0101;
                     end else begin
                        RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                        RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+6'b010100;
                        RADDR2_reg              <= command[(SDRAM_RASIZE-1):0]-6'b001100;
                        tx_split_transaction    <=2'b10;
                        B_SIZE_reg              <=4'b0101;
                        B_SIZE1_reg             <=4'b1000 ;
                        B_SIZE2_reg             <=B_SIZE_ovride- 4'b1101; 
		     end
                  end else begin
                     RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                     RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+6'b010100;
                     RADDR2_reg              <= command[(SDRAM_RASIZE-1):0]-6'b001100;
                     tx_split_transaction   <=2'b10;
                     rx_split_transaction   <=2'b10;
                     B_SIZE_reg             <=4'b0101;
                     B_SIZE1_reg            <=4'b1000;
                     B_SIZE2_reg            <=4'b0011; 
                  end
               end
               4'b0100 :
	       begin
                  if (B_SIZE_ovride_en ==1) begin
                     if(B_SIZE_ovride < 5'd5) begin
                        RADDR_reg              <= command[(SDRAM_RASIZE-1):0];
                        tx_split_transaction   <=2'b00;
                        B_SIZE_reg             <=B_SIZE_ovride[3:0];
                     end else if ( B_SIZE_ovride > 5'd4 & B_SIZE_ovride < 5'd13)begin
                        RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                        RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+6'b010000;
                        tx_split_transaction    <=2'b01;
                        B_SIZE_reg              <=4'b0100;
                        B_SIZE1_reg             <=B_SIZE_ovride- 4'b0100;
  		     end else begin
                        RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                        RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+6'b010000;
                        RADDR2_reg              <= command[(SDRAM_RASIZE-1):0]-6'b010000;
                        tx_split_transaction    <=2'b10;
                        B_SIZE_reg              <=4'b0100;
                        B_SIZE1_reg             <=4'b1000 ;
                        B_SIZE2_reg             <=B_SIZE_ovride- 4'b1100; 
  		     end
                  end else begin
                     RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                     RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+6'b010000;
                     RADDR2_reg              <= command[(SDRAM_RASIZE-1):0]-6'b010000;
                     tx_split_transaction   <=2'b10;
                     rx_split_transaction   <=2'b10;
                     B_SIZE_reg             <=4'b0100;
                     B_SIZE1_reg            <=4'b1000;
                     B_SIZE2_reg            <=4'b0100; 
                  end
               end
               4'b0101 :
	       begin
                  if (B_SIZE_ovride_en ==1) begin
                     if(B_SIZE_ovride < 5'd4) begin
                        RADDR_reg              <= command[(SDRAM_RASIZE-1):0];
                        tx_split_transaction   <=2'b00;
                        B_SIZE_reg             <=B_SIZE_ovride[3:0];
                     end else if ( B_SIZE_ovride > 5'd3 & B_SIZE_ovride < 5'd12)begin
                        RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                        RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+6'b001100;
                        tx_split_transaction    <=2'b01;
                        B_SIZE_reg              <=4'b0011;
                        B_SIZE1_reg             <=B_SIZE_ovride- 4'b0011;
      	             end else begin
                        RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                        RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+6'b001100;
                        RADDR2_reg              <= command[(SDRAM_RASIZE-1):0]-6'b010100;
                        tx_split_transaction    <=2'b10;
                        B_SIZE_reg              <=4'b0011;
                        B_SIZE1_reg             <=4'b1000 ;
                        B_SIZE2_reg             <=B_SIZE_ovride- 4'b1011; 
      	             end
                  end else begin
                     RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                     RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+6'b001100;
                     RADDR2_reg              <= command[(SDRAM_RASIZE-1):0]-6'b010100;
                     tx_split_transaction   <=2'b10;
                     rx_split_transaction   <=2'b10;
                     B_SIZE_reg             <=4'b0011;
                     B_SIZE1_reg            <=4'b1000;
                     B_SIZE2_reg            <=4'b0101;
                  end 
               end
               4'b0110 : 
	       begin
                   if (B_SIZE_ovride_en ==1) begin
                      if(B_SIZE_ovride < 5'd3) begin
                          RADDR_reg              <= command[(SDRAM_RASIZE-1):0];
                          tx_split_transaction   <=2'b00;
                          B_SIZE_reg             <=B_SIZE_ovride[3:0];
                      end else if ( B_SIZE_ovride > 5'd2 & B_SIZE_ovride < 5'd11)begin
                          RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                          RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+6'b001000;
                          tx_split_transaction    <=2'b01;
                          B_SIZE_reg              <=4'b0010;
                          B_SIZE1_reg             <=B_SIZE_ovride- 4'b0010;
	              end else begin
                          RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                          RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+6'b001000;
                          RADDR2_reg              <= command[(SDRAM_RASIZE-1):0]-6'b011000;
                          tx_split_transaction    <=2'b10;
                          B_SIZE_reg              <=4'b0010;
                          B_SIZE1_reg             <=4'b1000 ;
                          B_SIZE2_reg             <=B_SIZE_ovride- 4'b1010; 
		      end
                   end else begin
                      RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                      RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+6'b001000;
                      RADDR2_reg              <= command[(SDRAM_RASIZE-1):0]-6'b011000;
                      tx_split_transaction   <=2'b10;
                      rx_split_transaction   <=2'b10;
                      B_SIZE_reg             <=4'b0010;
                      B_SIZE1_reg            <=4'b1000;
                      B_SIZE2_reg            <=4'b0110; 
                   end
               end
               4'b0111 :
	       begin
                   if (B_SIZE_ovride_en ==1) begin
                      if(B_SIZE_ovride < 5'd2) begin
                         RADDR_reg              <= command[(SDRAM_RASIZE-1):0];
                         tx_split_transaction   <=2'b00;
                         B_SIZE_reg             <=B_SIZE_ovride[3:0];
                      end else if ( B_SIZE_ovride > 5'd1 & B_SIZE_ovride < 5'd10)begin
                         RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                         RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+6'b000100;
                         tx_split_transaction    <=2'b01;
                         B_SIZE_reg              <=4'b0001;
                         B_SIZE1_reg             <=B_SIZE_ovride- 4'b0001;
		      end else begin
                         RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                         RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+6'b000100;
                         RADDR2_reg              <= command[(SDRAM_RASIZE-1):0]-6'b011100;
                         tx_split_transaction    <=2'b10;
                         B_SIZE_reg              <=4'b0001;
                         B_SIZE1_reg             <=4'b1000 ;
                         B_SIZE2_reg             <=B_SIZE_ovride- 4'b1001; 
		      end
                   end else begin
                       RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                       RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+6'b000100;
                       RADDR2_reg              <= command[(SDRAM_RASIZE-1):0]-6'b011100;
                       tx_split_transaction   <=2'b10;
                       rx_split_transaction   <=2'b10;
                       B_SIZE_reg             <=4'b0001;
                       B_SIZE1_reg            <=4'b1000;
                       B_SIZE2_reg            <=4'b0111; 
                   end
               end
               4'b1000 : 
	       begin
                  if (B_SIZE_ovride_en ==1) begin
                     if(B_SIZE_ovride < 5'd9) begin
                        RADDR_reg              <= command[(SDRAM_RASIZE-1):0];
                        tx_split_transaction   <=2'b00;
                        B_SIZE_reg             <=B_SIZE_ovride[3:0];
                     end else begin
                        RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                        RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]-6'b100000;
                        tx_split_transaction    <=2'b01;
                        B_SIZE_reg              <=4'b1000;
                        B_SIZE1_reg             <=B_SIZE_ovride- 4'b1000;
                     end
                  end else begin
                     RADDR_reg              <= command[(SDRAM_RASIZE-1):0];
                     RADDR1_reg             <= command[(SDRAM_RASIZE-1):0]-6'b100000;
                     tx_split_transaction   <=2'b01;
                     rx_split_transaction   <=2'b01;
                     B_SIZE_reg             <=4'b1000;
                     B_SIZE1_reg            <=4'b1000; 
                  end
               end
               4'b1001 :
	       begin
                  if (B_SIZE_ovride_en ==1) begin
                     if(B_SIZE_ovride < 5'd8) begin
                        RADDR_reg              <= command[(SDRAM_RASIZE-1):0];
                        tx_split_transaction   <=2'b00;
                        B_SIZE_reg             <=B_SIZE_ovride[3:0];
                     end else begin
                        RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                        RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]- 6'b100100;
                        tx_split_transaction    <=2'b01;
                        B_SIZE_reg              <=4'b0111;
                        B_SIZE1_reg             <=B_SIZE_ovride- 4'b0111;
                     end 
                  end else begin
                     RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                     RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]- 6'b100100;
                     RADDR2_reg              <= command[(SDRAM_RASIZE-1):0]- 6'b000100;
                     tx_split_transaction   <=2'b10;
                     rx_split_transaction   <=2'b10;
                     B_SIZE_reg             <=4'b0111;
                     B_SIZE1_reg            <=4'b1000;
                     B_SIZE2_reg            <=4'b0001; 
                  end
               end
               4'b1010 : 
	       begin
                  if (B_SIZE_ovride_en ==1) begin
                     if(B_SIZE_ovride < 5'd7) begin
                         RADDR_reg              <= command[(SDRAM_RASIZE-1):0];
                         tx_split_transaction   <=2'b00;
                         B_SIZE_reg             <=B_SIZE_ovride[3:0];
                     end else if ( B_SIZE_ovride > 5'd6 & B_SIZE_ovride < 5'd15)begin
                         RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                         RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]- 6'b101000;
                         tx_split_transaction    <=2'b01;
                         B_SIZE_reg              <=4'b0110;
                         B_SIZE1_reg             <=B_SIZE_ovride- 4'b0110;
		     end else begin
                         RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                         RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]- 6'b101000;
                         RADDR2_reg              <= command[(SDRAM_RASIZE-1):0]- 6'b001000;
                         tx_split_transaction    <=2'b10;
                         B_SIZE_reg              <=4'b0110;
                         B_SIZE1_reg             <=4'b1000 ;
                         B_SIZE2_reg             <=B_SIZE_ovride- 4'b1110; 
		     end 
	          end else begin
                      RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                      RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]- 6'b101000;
                      RADDR2_reg              <= command[(SDRAM_RASIZE-1):0]- 6'b001000;
                      tx_split_transaction   <=2'b10;
                      rx_split_transaction   <=2'b10;
                      B_SIZE_reg             <=4'b0110;
                      B_SIZE1_reg            <=4'b1000;
                      B_SIZE2_reg            <=4'b0010; 
                  end
               end
               4'b1011 :
	       begin
                  if (B_SIZE_ovride_en ==1) begin
                     if(B_SIZE_ovride < 5'd6) begin
                         RADDR_reg              <= command[(SDRAM_RASIZE-1):0];
                         tx_split_transaction   <=2'b00;
                         B_SIZE_reg             <=B_SIZE_ovride[3:0];
                     end else if ( B_SIZE_ovride > 5'd5 & B_SIZE_ovride < 5'd14)begin
                         RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                         RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]- 6'b101100;
                         tx_split_transaction    <=2'b01;
                         B_SIZE_reg              <=4'b0101;
                         B_SIZE1_reg             <=B_SIZE_ovride- 4'b0101;
		     end else begin
                         RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                         RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]- 6'b101100;
                         RADDR2_reg              <= command[(SDRAM_RASIZE-1):0]- 6'b001100;
                         tx_split_transaction    <=2'b10;
                         B_SIZE_reg              <=4'b0101;
                         B_SIZE1_reg             <=4'b1000 ;
                         B_SIZE2_reg             <=B_SIZE_ovride- 4'b1101; 
		     end
                  end else begin
                     RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                     RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]-6'b101100;
                     RADDR2_reg              <= command[(SDRAM_RASIZE-1):0]-6'b001100;
                     tx_split_transaction   <=2'b10;
                     rx_split_transaction   <=2'b10;
                     B_SIZE_reg             <=4'b0101;
                     B_SIZE1_reg            <=4'b1000;
                     B_SIZE2_reg            <=4'b0011; 
                  end
               end
               4'b1100 : 
	       begin
                  if (B_SIZE_ovride_en ==1) begin
                     if(B_SIZE_ovride < 5'd5) begin
                        RADDR_reg              <= command[(SDRAM_RASIZE-1):0];
                        tx_split_transaction   <=2'b00;
                        B_SIZE_reg             <=B_SIZE_ovride[3:0];
                     end else if ( B_SIZE_ovride > 5'd4 & B_SIZE_ovride < 5'd13)begin
                        RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                        RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]- 6'b110000;
                        tx_split_transaction    <=2'b01;
                        B_SIZE_reg              <=4'b0100;
                        B_SIZE1_reg             <=B_SIZE_ovride- 4'b0100;
		     end else begin
                        RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                        RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]- 6'b110000;
                        RADDR2_reg              <= command[(SDRAM_RASIZE-1):0]- 6'b010000;
                        tx_split_transaction    <=2'b10;
                        B_SIZE_reg              <=4'b0100;
                        B_SIZE1_reg             <=4'b1000 ;
                        B_SIZE2_reg             <=B_SIZE_ovride- 4'b1100; 
		     end
                  end else begin
                     RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                     RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]-6'b110000;
                     RADDR2_reg              <= command[(SDRAM_RASIZE-1):0]-6'b010000;
                     tx_split_transaction   <=2'b10;
                     rx_split_transaction   <=2'b10;
                     B_SIZE_reg             <=4'b0100;
                     B_SIZE1_reg            <=4'b1000;
                     B_SIZE2_reg            <=4'b0100; 
                  end
               end
               4'b1101 : 
	       begin
                  if (B_SIZE_ovride_en ==1) begin
                     if(B_SIZE_ovride < 5'd4) begin
                        RADDR_reg              <= command[(SDRAM_RASIZE-1):0];
                        tx_split_transaction   <=2'b00;
                        B_SIZE_reg             <=B_SIZE_ovride[3:0];
                     end else if ( B_SIZE_ovride > 5'd3 & B_SIZE_ovride < 5'd12)begin
                        RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                        RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]- 6'b110100;
                        tx_split_transaction    <=2'b01;
                        B_SIZE_reg              <=4'b0011;
                        B_SIZE1_reg             <=B_SIZE_ovride- 4'b0011;
		     end else begin
                        RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                        RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]- 6'b110100;
                        RADDR2_reg              <= command[(SDRAM_RASIZE-1):0]- 6'b010100;
                        tx_split_transaction    <=2'b10;
                        B_SIZE_reg              <=4'b0011;
                        B_SIZE1_reg             <=4'b1000 ;
                        B_SIZE2_reg             <=B_SIZE_ovride- 4'b1011; 
		     end
                  end else begin
                     RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                     RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]-6'b110100;
                     RADDR2_reg              <= command[(SDRAM_RASIZE-1):0]-6'b010100;
                     tx_split_transaction   <=2'b10;
                     rx_split_transaction   <=2'b10;
                     B_SIZE_reg             <=4'b0011;
                     B_SIZE1_reg            <=4'b1000;
                     B_SIZE2_reg            <=4'b0101; 
                  end
               end
               4'b1110 : 
	       begin
                  if (B_SIZE_ovride_en ==1) begin
                     if(B_SIZE_ovride < 5'd3) begin
                        RADDR_reg              <= command[(SDRAM_RASIZE-1):0];
                        tx_split_transaction   <=2'b00;
                        B_SIZE_reg             <=B_SIZE_ovride[3:0];
                     end else if ( B_SIZE_ovride > 5'd2 & B_SIZE_ovride < 5'd11)begin
                        RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                        RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]- 6'b111000;
                        tx_split_transaction    <=2'b01;
                        B_SIZE_reg              <=4'b0010;
                        B_SIZE1_reg             <=B_SIZE_ovride- 4'b0010;
		     end else begin
                        RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                        RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]- 6'b111000;
                        RADDR2_reg              <= command[(SDRAM_RASIZE-1):0]- 6'b011000;
                        tx_split_transaction    <=2'b10;
                        B_SIZE_reg              <=4'b0010;
                        B_SIZE1_reg             <=4'b1000 ;
                        B_SIZE2_reg             <=B_SIZE_ovride- 4'b1010; 
		     end
                  end else begin
                     RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                     RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]-6'b111000;
                     RADDR2_reg              <= command[(SDRAM_RASIZE-1):0]-6'b011000;
                     tx_split_transaction   <=2'b10;
                     rx_split_transaction   <=2'b10;
                     B_SIZE_reg             <=4'b0010;
                     B_SIZE1_reg            <=4'b1000;
                     B_SIZE2_reg            <=4'b0110; 
                  end
               end
               4'b1111 : 
	       begin
                  if (B_SIZE_ovride_en ==1) begin
                     if(B_SIZE_ovride < 5'd2) begin
                         RADDR_reg              <= command[(SDRAM_RASIZE-1):0];
                         tx_split_transaction   <=2'b00;
                         B_SIZE_reg             <=B_SIZE_ovride[3:0];
                     end else if ( B_SIZE_ovride > 5'd1 & B_SIZE_ovride < 5'd10)begin
                         RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                         RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]- 6'b111100;
                         tx_split_transaction    <=2'b01;
                         B_SIZE_reg              <=4'b0001;
                         B_SIZE1_reg             <=B_SIZE_ovride- 4'b0001;
		     end else begin
                         RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                         RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]- 6'b111100;
                         RADDR2_reg              <= command[(SDRAM_RASIZE-1):0]- 6'b011100;
                         tx_split_transaction    <=2'b10;
                         B_SIZE_reg              <=4'b0001;
                         B_SIZE1_reg             <=4'b1000 ;
                         B_SIZE2_reg             <=B_SIZE_ovride- 4'b1001; 
		     end
                  end else begin
                     RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                     RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]-6'b111100;
                     RADDR2_reg              <= command[(SDRAM_RASIZE-1):0]-6'b011100;
                     tx_split_transaction   <=2'b10;
                     rx_split_transaction   <=2'b10;
                     B_SIZE_reg             <=4'b0001;
                     B_SIZE1_reg            <=4'b1000;
                     B_SIZE2_reg            <=4'b0111; 
                  end
               end
               endcase
            end
         end 
         3'b111 : 
	 begin
            if(command [(COMMAND_SIZE-2):(COMMAND_SIZE-4)]==3'b0 | command [(COMMAND_SIZE-2):(COMMAND_SIZE-4)]==3'b1)begin
               RADDR_reg              <= command [(SDRAM_RASIZE-1):0];
               tx_split_transaction   <=2'b00;
               rx_split_transaction   <=2'b00;
               B_SIZE_reg             <=4'b0001;
            end else begin
               case(command [4:2])
               3'b000 :
	       begin
                  if (B_SIZE_ovride_en ==1) begin
                     if(B_SIZE_ovride < 5'd9) begin
                        RADDR_reg              <= command[(SDRAM_RASIZE-1):0];
                        tx_split_transaction   <=2'b00;
                        B_SIZE_reg             <=B_SIZE_ovride[3:0];
                     end else begin
                        RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                        RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+6'b100000;
                        tx_split_transaction    <=2'b01;
                        B_SIZE_reg              <=4'b1000;
                        B_SIZE1_reg             <=B_SIZE_ovride- 4'b1000;
                     end
                  end else begin
                        RADDR_reg              <= command[(SDRAM_RASIZE-1):0];
                        RADDR1_reg             <= command[(SDRAM_RASIZE-1):0]+6'b100000;
                        tx_split_transaction   <=2'b01;
                        rx_split_transaction   <=2'b01;
                        B_SIZE_reg             <=4'b1000;
                        B_SIZE1_reg            <=4'b1000; 
                  end
               end
               3'b001 :
	       begin
                  if (B_SIZE_ovride_en ==1) begin
                     if(B_SIZE_ovride < 5'd8) begin
                         RADDR_reg              <= command[(SDRAM_RASIZE-1):0];
                         tx_split_transaction   <=2'b00;
                         B_SIZE_reg             <=B_SIZE_ovride[3:0];
                     end else begin
                         RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                         RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+ 6'b011100;
                         tx_split_transaction    <=2'b01;
                         B_SIZE_reg              <=4'b0111;
                         B_SIZE1_reg             <=B_SIZE_ovride- 4'b0111;
                     end
                  end else begin
                     RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                     RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+ 6'b011100;
                     RADDR2_reg              <= command[(SDRAM_RASIZE-1):0]+ 6'b111100;
                     tx_split_transaction   <=2'b10;
                     rx_split_transaction   <=2'b10;
                     B_SIZE_reg             <=4'b0111;
                     B_SIZE1_reg            <=4'b1000;
                     B_SIZE2_reg            <=4'b0001; 
                  end
               end
               3'b010 : 
	       begin
                  if (B_SIZE_ovride_en ==1) begin
                     if(B_SIZE_ovride < 5'd7) begin
                         RADDR_reg              <= command[(SDRAM_RASIZE-1):0];
                         tx_split_transaction   <=2'b00;
                         B_SIZE_reg             <=B_SIZE_ovride[3:0];
                     end else if ( B_SIZE_ovride > 5'd6 & B_SIZE_ovride < 5'd15)begin
                         RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                         RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+ 6'b011000;
                         tx_split_transaction    <=2'b01;
                         B_SIZE_reg              <=4'b0110;
                         B_SIZE1_reg             <=B_SIZE_ovride- 4'b0110;
	             end else begin
                         RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                         RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+ 6'b011000;
                         RADDR2_reg              <= command[(SDRAM_RASIZE-1):0]+ 6'b111000;
                         tx_split_transaction    <=2'b10;
                         B_SIZE_reg              <=4'b0110;
                         B_SIZE1_reg             <=4'b1000 ;
                         B_SIZE2_reg             <=B_SIZE_ovride- 4'b1110; 
		     end
                  end else begin
                     RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                     RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+ 6'b011000;
                     RADDR2_reg              <= command[(SDRAM_RASIZE-1):0]+ 6'b111000;
                     tx_split_transaction   <=2'b10;
                     rx_split_transaction   <=2'b10;
                     B_SIZE_reg             <=4'b0110;
                     B_SIZE1_reg            <=4'b1000;
                     B_SIZE2_reg            <=4'b0010; 
                  end
               end
               3'b011 :
	       begin
                  if (B_SIZE_ovride_en ==1) begin
                     if(B_SIZE_ovride < 5'd6) begin
                        RADDR_reg              <= command[(SDRAM_RASIZE-1):0];
                        tx_split_transaction   <=2'b00;
                        B_SIZE_reg             <=B_SIZE_ovride[3:0];
                     end else if ( B_SIZE_ovride > 5'd5 & B_SIZE_ovride < 5'd14)begin
                        RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                        RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+ 6'b010100;
                        tx_split_transaction    <=2'b01;
                        B_SIZE_reg              <=4'b0101;
                        B_SIZE1_reg             <=B_SIZE_ovride- 4'b0101;
		     end else begin
                        RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                        RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+ 6'b010100;
                        RADDR2_reg              <= command[(SDRAM_RASIZE-1):0]+ 6'b110100;
                        tx_split_transaction    <=2'b10;
                        B_SIZE_reg              <=4'b0101;
                        B_SIZE1_reg             <=4'b1000 ;
                        B_SIZE2_reg             <=B_SIZE_ovride- 4'b1101; 
		     end
                  end else begin
                     RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                     RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+6'b010100;
                     RADDR2_reg              <= command[(SDRAM_RASIZE-1):0]+6'b110100;
                     tx_split_transaction   <=2'b10;
                     rx_split_transaction   <=2'b10;
                     B_SIZE_reg             <=4'b0101;
                     B_SIZE1_reg            <=4'b1000;
                     B_SIZE2_reg            <=4'b0011; 
                  end
               end
               3'b100 :
	       begin
                  if (B_SIZE_ovride_en ==1) begin
                     if(B_SIZE_ovride < 5'd5) begin
                        RADDR_reg              <= command[(SDRAM_RASIZE-1):0];
                        tx_split_transaction   <=2'b00;
                        B_SIZE_reg             <=B_SIZE_ovride[3:0];
                     end else if ( B_SIZE_ovride > 5'd4 & B_SIZE_ovride < 5'd13)begin
                        RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                        RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+ 6'b010000;
                        tx_split_transaction    <=2'b01;
                        B_SIZE_reg              <=4'b0100;
                        B_SIZE1_reg             <=B_SIZE_ovride- 4'b0100;
		     end else begin
                        RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                        RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+ 6'b010000;
                        RADDR2_reg              <= command[(SDRAM_RASIZE-1):0]+ 6'b110000;
                        tx_split_transaction    <=2'b10;
                        B_SIZE_reg              <=4'b0100;
                        B_SIZE1_reg             <=4'b1000 ;
                        B_SIZE2_reg             <=B_SIZE_ovride- 4'b1100; 
		     end
                  end else begin
                     RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                     RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+6'b010000;
                     RADDR2_reg              <= command[(SDRAM_RASIZE-1):0]+6'b110000;
                     tx_split_transaction   <=2'b10;
                     rx_split_transaction   <=2'b10;
                     B_SIZE_reg             <=4'b0100;
                     B_SIZE1_reg            <=4'b1000;
                     B_SIZE2_reg            <=4'b0100; 
                  end
               end
               3'b101 : 
	       begin
                  if (B_SIZE_ovride_en ==1) begin
                     if(B_SIZE_ovride < 5'd4) begin
                         RADDR_reg              <= command[(SDRAM_RASIZE-1):0];
                         tx_split_transaction   <=2'b00;
                         B_SIZE_reg             <=B_SIZE_ovride[3:0];
                     end else if ( B_SIZE_ovride > 5'd3 & B_SIZE_ovride < 5'd12)begin
                         RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                         RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+ 6'b001100;
                         tx_split_transaction    <=2'b01;
                         B_SIZE_reg              <=4'b0011;
                         B_SIZE1_reg             <=B_SIZE_ovride- 4'b0011;
		     end else begin
                         RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                         RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+ 6'b001100;
                         RADDR2_reg              <= command[(SDRAM_RASIZE-1):0]+ 6'b101100;
                         tx_split_transaction    <=2'b10;
                         B_SIZE_reg              <=4'b0011;
                         B_SIZE1_reg             <=4'b1000 ;
                         B_SIZE2_reg             <=B_SIZE_ovride- 4'b1011;
		     end 
                  end else begin
                     RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                     RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+6'b001100;
                     RADDR2_reg              <= command[(SDRAM_RASIZE-1):0]+6'b101100;
                     tx_split_transaction   <=2'b10;
                     rx_split_transaction   <=2'b10;
                     B_SIZE_reg             <=4'b0011;
                     B_SIZE1_reg            <=4'b1000;
                     B_SIZE2_reg            <=4'b0101; 
                  end
               end
               3'b110 : 
	       begin
                  if (B_SIZE_ovride_en ==1) begin
                     if(B_SIZE_ovride < 5'd3) begin
                        RADDR_reg              <= command[(SDRAM_RASIZE-1):0];
                        tx_split_transaction   <=2'b00;
                        B_SIZE_reg             <=B_SIZE_ovride[3:0];
                     end else if ( B_SIZE_ovride > 5'd2 & B_SIZE_ovride < 5'd11)begin
                        RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                        RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+ 6'b001000;
                        tx_split_transaction    <=2'b01;
                        B_SIZE_reg              <=4'b0010;
                        B_SIZE1_reg             <=B_SIZE_ovride- 4'b0010;
		     end else begin
                        RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                        RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+ 6'b001000;
                        RADDR2_reg              <= command[(SDRAM_RASIZE-1):0]+ 6'b101000;
                        tx_split_transaction    <=2'b10;
                        B_SIZE_reg              <=4'b0010;
                        B_SIZE1_reg             <=4'b1000 ;
                        B_SIZE2_reg             <=B_SIZE_ovride- 4'b1010; 
		     end
                  end else begin
                     RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                     RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+6'b001000;
                     RADDR2_reg              <= command[(SDRAM_RASIZE-1):0]+6'b101000;
                     tx_split_transaction   <=2'b10;
                     rx_split_transaction   <=2'b10;
                     B_SIZE_reg             <=4'b0010;
                     B_SIZE1_reg            <=4'b1000;
                     B_SIZE2_reg            <=4'b0110;
                  end
               end
               3'b111 :
	       begin
                  if (B_SIZE_ovride_en ==1) begin
                     if(B_SIZE_ovride < 5'd2) begin
                        RADDR_reg              <= command[(SDRAM_RASIZE-1):0];
                        tx_split_transaction   <=2'b00;
                        B_SIZE_reg             <=B_SIZE_ovride[3:0];
                     end else if ( B_SIZE_ovride > 5'd1 & B_SIZE_ovride < 5'd10)begin
                        RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                        RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+ 6'b000100;
                        tx_split_transaction    <=2'b01;
                        B_SIZE_reg              <=4'b0001;
                        B_SIZE1_reg             <=B_SIZE_ovride- 4'b0001;
		     end else begin
                        RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                        RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+ 6'b000100;
                        RADDR2_reg              <= command[(SDRAM_RASIZE-1):0]+ 6'b100100;
                        tx_split_transaction    <=2'b10;
                        B_SIZE_reg              <=4'b0001;
                        B_SIZE1_reg             <=4'b1000 ;
                        B_SIZE2_reg             <=B_SIZE_ovride- 4'b1001; 
		     end
                  end else begin
                     RADDR_reg               <= command[(SDRAM_RASIZE-1):0];
                     RADDR1_reg              <= command[(SDRAM_RASIZE-1):0]+6'b000100;
                     RADDR2_reg              <= command[(SDRAM_RASIZE-1):0]+6'b100100;
                     tx_split_transaction   <=2'b10;
                     rx_split_transaction   <=2'b10;
                     B_SIZE_reg             <=4'b0001;
                     B_SIZE1_reg            <=4'b1000;
                     B_SIZE2_reg            <=4'b0111; 
                  end
               end
               endcase
            end
         end
         endcase
      end
   end


   always @(posedge HCLK or negedge AHRESETN)begin
      if ((!AHRESETN) || (!SHRESETN)) begin
         rx_fifo_rd_cnt  <= 5'd0 ; 
         rx_fifo_rd_done <= 1'b0;
      end else if (rx_fifo_first_read == 1'b1 | (((state_ahb==AHB_RD) & (acen ==1'b1)) & ((HTRANS == 2'b10) | (HTRANS == 2'b11))) ) begin
         if(command [(COMMAND_SIZE-5):(COMMAND_SIZE-7)] == 3'd0 | command [(COMMAND_SIZE-5):(COMMAND_SIZE-7)] == 3'd1 | command [(COMMAND_SIZE-2):(COMMAND_SIZE-4)] == 3'd0 | command [(COMMAND_SIZE-2):(COMMAND_SIZE-4)] == 3'd1 ) begin
            rx_fifo_rd_done <= 1'b1;
         end else if(command [(COMMAND_SIZE-5):(COMMAND_SIZE-7)] == 3'd2 | command [(COMMAND_SIZE-5):(COMMAND_SIZE-7)]  == 3'd3) begin 
            if(rx_fifo_rd_cnt == 5'd4 ) begin
               rx_fifo_rd_cnt     <= 5'd0 ; 
               rx_fifo_rd_done    <= 1'b0;
            end else begin
               rx_fifo_rd_cnt <= rx_fifo_rd_cnt + 1 ; 
            end
            if(rx_fifo_rd_cnt == 5'd3 ) begin
               rx_fifo_rd_done    <= 1'b1;
            end
         end else if(command [(COMMAND_SIZE-5):(COMMAND_SIZE-7)]  == 3'd4 | command [(COMMAND_SIZE-5):(COMMAND_SIZE-7)]  == 3'd5) begin 
            if(rx_fifo_rd_cnt == 5'd8 ) begin
               rx_fifo_rd_cnt     <= 5'd0 ; 
               rx_fifo_rd_done    <= 1'b0;
            end else begin
               rx_fifo_rd_cnt <= rx_fifo_rd_cnt + 1 ; 
            end

            if(rx_fifo_rd_cnt == 5'd7 ) begin
               rx_fifo_rd_done    <= 1'b1;
            end
         end else if(command [(COMMAND_SIZE-5):(COMMAND_SIZE-7)]  == 3'd6 | command [(COMMAND_SIZE-5):(COMMAND_SIZE-7)]  == 3'd7) begin 
            if(rx_fifo_rd_cnt == 5'd16 ) begin
               rx_fifo_rd_cnt     <= 5'd0 ; 
               rx_fifo_rd_done    <= 1'b0;
            end else begin
               rx_fifo_rd_cnt <= rx_fifo_rd_cnt + 1 ; 
            end

            if(rx_fifo_rd_cnt == 5'd15 ) begin
               rx_fifo_rd_done    <= 1'b1;
            end
         end
      end else if ((acen ==1'b1) & (HTRANS == 2'b01)) begin
         rx_fifo_rd_done <=rx_fifo_rd_done;
         rx_fifo_rd_cnt  <=rx_fifo_rd_cnt ; 
      end else begin
         rx_fifo_rd_done <=1'b0;
         rx_fifo_rd_cnt  <= 5'd0 ; 
      end
   end
   
   
   always @(posedge HCLK or negedge AHRESETN)begin
      if ((!AHRESETN) || (!SHRESETN)) begin
         rx_fifo_rd_en_ahb_d <= 1'b0 ;
      end else begin
         rx_fifo_rd_en_ahb_d <=rx_fifo_rd_en_ahb;
      end
   end

   always @(posedge SDRCLK_IN or negedge ASDRCLK_RESETN) begin
      if ((!ASDRCLK_RESETN) || (!SSDRCLK_RESETN)) begin
         w_valid_d    <= 1'b0; 
         r_valid_d    <= 1'b0;
      end else begin
         w_valid_d    <= W_VALID;
         r_valid_d    <= R_VALID;
      end 
   end 

 always @(posedge SDRCLK_IN or negedge ASDRCLK_RESETN) begin
      if ((!ASDRCLK_RESETN) || (!SSDRCLK_RESETN)) begin
         state_sdr       <= 4'd0; 
         state_sdr_d     <= 4'd0;
         state_sdr_d1    <= 4'd0;
         state_sdr_d2    <= 4'd0;
         state_sdr_d3    <= 4'd0;
      end else begin
         state_sdr      <= state_ahb;
         state_sdr_d    <= state_sdr;
         state_sdr_d1   <= state_sdr_d;
         state_sdr_d2   <= state_sdr_d1;
         state_sdr_d3   <= state_sdr_d2;
      end 
   end 
 
   always @(posedge SDRCLK_IN or negedge ASDRCLK_RESETN) begin
      if ((!ASDRCLK_RESETN) || (!SSDRCLK_RESETN)) begin
         raddr_sdr         <= {(SDRAM_RASIZE){1'd0}};
         raddr_sdr_d       <= {(SDRAM_RASIZE){1'd0}};
      end else begin
         raddr_sdr_d       <= raddr_ahb ;
         raddr_sdr         <= raddr_sdr_d;
      end 
   end 
always @(posedge SDRCLK_IN or negedge ASDRCLK_RESETN) begin
      if ((!ASDRCLK_RESETN) || (!SSDRCLK_RESETN)) begin
         B_SIZE_sdr_d       <= 4'd0;
         B_SIZE_sdr         <= 4'd0;
      end else begin
         B_SIZE_sdr_d       <= B_SIZE_ahb ;
         B_SIZE_sdr         <= B_SIZE_sdr_d;
      end 
   end 

   always @(posedge SDRCLK_IN or negedge ASDRCLK_RESETN) begin
      if ((!ASDRCLK_RESETN) || (!SSDRCLK_RESETN)) begin
         burst_terminate_sdr      <= 1'b0; 
         burst_terminate_sdr_s    <= 1'b0;
      end else begin
         burst_terminate_sdr_s  <= burst_terminate_ahb;
         burst_terminate_sdr    <= burst_terminate_sdr_s;
      end 
   end 



   always @(posedge HCLK or negedge AHRESETN)begin
      if ((!AHRESETN) || (!SHRESETN)) begin
         HWRITE_d       <= 0 ;
      end else begin
         if (acen == 1'b1) begin 
            HWRITE_d  <= HWRITE ;
         end
      end
   end
  always @(posedge HCLK or negedge AHRESETN)begin
      if ((!AHRESETN) || (!SHRESETN)) begin
         HTRANS_d       <= 2'b00 ;
         HTRANS_d1       <= 2'b00 ;
      end else begin
         HTRANS_d1<= HTRANS ;
         if (acen == 1'b1) begin 
            HTRANS_d<= HTRANS ;
         end
      end
   end


assign r_valid_negedge         = (!R_VALID) & r_valid_d;
assign w_valid_negedge         = (!W_VALID) & w_valid_d;
assign tx_fifo_wr_en =  (((HREADYIN ==1'b1) & (HWRITE_d == 1'b1 )) & ((HTRANS == 2'b11 & HTRANS_d !=2'b01 ) | (HTRANS == 2'b00 & ( HSELREG == 1'b1 ) & (HTRANS_d ==2'b01 | HTRANS_d ==2'b11 | HTRANS_d ==2'b10 )) | (HTRANS == 2'b10 & HTRANS_d1 !=2'b00 ) | (HTRANS == 2'b01 & HTRANS_d !=2'b01))); 
assign DQ[SDRAM_DQSIZE-1:0]    = (OE == 1'b1) ? data_out_fifo[SDRAM_DQSIZE-1:0] : {SDRAM_DQSIZE{1'bz}} ;
assign hdataout_reg            = rx_fifo_rd_en_ahb_d ? rd_data_out_fifo :  32'd0 ;
assign rx_fifo_rd_en_ahb       = (((state_ahb==AHB_RD) & (acen ==1'b1)) & (HTRANS != 2'b01) & (!rx_fifo_rd_done )) | rx_fifo_first_read ;




CORESYNC_PULSE_CDC # (.NUM_STAGES(2),.SYNC_RESET (SYNC_RESET)) rvalid_ahb (

   .SRC_CLK    (SDRCLK_IN),
   .DSTN_CLK   (HCLK),
   .SRC_RESET  (SDRCLK_RESETN),
   .DSTN_RESET (HRESETN),
   .PULSE_IN   (r_valid_negedge),
   .SYNC_PULSE (r_valid_negedge_ahb)
 ) ;


CORESYNC_PULSE_CDC # (.NUM_STAGES(2),.SYNC_RESET (SYNC_RESET)) wvalid_ahb (

   .SRC_CLK    (SDRCLK_IN),
   .DSTN_CLK   (HCLK),
   .SRC_RESET  (SDRCLK_RESETN),
   .DSTN_RESET (HRESETN),
   .PULSE_IN   (w_valid_negedge),
   .SYNC_PULSE (w_valid_negedge_ahb)
 ) ;

 CDC_FIFO # (.MEM_DEPTH(16),.FAMILY(FAMILY),.ECC(ECC),.DATA_WIDTH(32)) tx_data_fifo_async (
      .CLK_WR     (HCLK),              // write clock input
      .CLK_RD     (SDRCLK_IN),         // read Clock input
      .W_RST_N    (HRESETN), 
      .R_RST_N    (SDRCLK_RESETN),
      .terminate_wr(1'b0),
      .terminate_rd(1'b0),
      .DATA_IN    (HWDATA),            // Data input
      .WR_EN      (tx_fifo_wr_en) ,    // Write Enable
      .RD_EN      (D_REQ),             // Read enable
      .DATA_OUT   (data_out_fifo),     // Data Output
      .FIFO_EMPTY (),                  // FIFO empty
      .FIFO_FULL  ()                   // FIFO full

  );

 CDC_FIFO # (.MEM_DEPTH(16),.FAMILY(FAMILY),.ECC(ECC),.DATA_WIDTH(32)) rx_data_fifo_async (
      .CLK_WR     (SDRCLK_IN),          // write clock input
      .CLK_RD     (HCLK),               // read Clock input
      .W_RST_N    (SDRCLK_RESETN), 
      .R_RST_N    (HRESETN ),
      .terminate_wr(burst_terminate_sdr),
      .terminate_rd(burst_terminate_ahb),
      .DATA_IN    (dataout),            // Data input
      .WR_EN      (R_VALID) ,           // Write Enable
      .RD_EN      (rx_fifo_rd_en_ahb),  // Read enable
      .DATA_OUT   (rd_data_out_fifo),   // Data Output
      .FIFO_EMPTY (),                   // FIFO empty
      .FIFO_FULL  ()                    // FIFO full
  );
     
 // Instantiation SDR controller top level
   sdr_CORESDR #(.FAMILY(FAMILY), .SDRAM_RASIZE(SDRAM_RASIZE), .SDRAM_CHIPS(SDRAM_CHIPS), .SDRAM_COLBITS(SDRAM_COLBITS), .SDRAM_ROWBITS(SDRAM_ROWBITS), .SDRAM_CHIPBITS(SDRAM_CHIPBITS), .SDRAM_BANKSTATMODULES(SDRAM_BANKSTATMODULES)) CoreSDR_0(
      .CLK     (SDRCLK_IN), 
      .RESET_N (SDRCLK_RESETN), 
      .RADDR   (raddr_sdr), 
      .B_SIZE  (B_SIZE_sdr),  
      .R_REQ   (R_REQ_sdr),
      .W_REQ   (W_REQ_sdr), 
      .AUTO_PCH(AUTO_PCH), 
      .RW_ACK  (RW_ACK), 
      .D_REQ   (D_REQ), 
      .W_VALID (W_VALID), 
      .R_VALID (R_VALID), 
      .SD_INIT (1'b0), 
      .RAS     (RAS), 
      .RCD     (RCD), 
      .RRD     (RRD), 
      .RP      (RP), 
      .RC      (RC), 
      .RFC     (RFC), 
      .MRD     (MRD), 
      .CL      (CL), 
      .BL      (2'b11), 
      .WR      (WR), 
      .DELAY   (DELAY), 
      .REF     (REF), 
      .COLBITS (COLBITS), 
      .ROWBITS (ROWBITS), 
      .REGDIMM (REGDIMM), 
      .SA      (SA), 
      .BA      (BA), 
      .CS_N    (CS_N), 
      .CKE     (CKE), 
      .RAS_N   (RAS_N), 
      .CAS_N   (CAS_N), 
      .WE_N    (WE_N), 
      .OE      (OE), 
      .DQM     (dqm_sdr)
   ); 

endmodule


