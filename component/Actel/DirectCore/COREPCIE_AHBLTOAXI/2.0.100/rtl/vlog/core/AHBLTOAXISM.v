// ******************************************************************************************************/
// Microchip Corporation Proprietary and Confidential
// Copyright 2021 Microchip Corporation. All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
// ACCORDANCE WITH THE MICROCHIP LICENSE AGREEMENT AND MUST BE APPROVED
// IN ADVANCE IN WRITING.
//
// SVN Revision Information:
// SVN $Revision: 116102 $
// SVN $Date: 2021-02-18 23:53:50 +0530 (Thu, 18 Feb 2021) $
// SVN $Author: ian.bryant $
// SVN $URL: svn://hoppin/G4/G4_data/Design/source/g4main/G4M_AHBTOAXI/tags/4.0.100/soft/AHBLTOAXISM.v $
//
// Description: G4 AHB 32-bit to AXI 64-bit Bridge Top Module for PCIE
//
// Revision  Information:
// Date    who SAR    Description
// 18Feb21 IPB        Initial version - copied from ASIC code no functional change
//
//
// ******************************************************************************************************/


module AHBLTOAXISM (
        input           HCLK,
        input           HRESETn,
        input           HSEL,
        input [31:0]    HADDR,
        input           HWRITE,
        input           HREADY,
        input [1:0]     HTRANS,
        input [1:0]     HSIZE,
        input [2:0]     HBURST,
        output  reg     HREADYOUT,
        output  reg     HRESP,
        input           AWREADY,
        input           WREADY,
        input           BVALID,
        input           BRESP,
        input           ARREADY,
        input           RVALID,
        input           RRESP,
        input           RLAST,
        output          AWVALID,
        output          WLAST,
        output          WVALID,
        output [7:0]    WSTRB,
        output          BREADY,
        output          RREADY,
        output          ARVALID,
        output [2:0]    HBURSTREG,
        output [31:0]   HADDRREG,
        output [1:0]    HSIZEREG,
        output          HWRITEREG,
        input           HMASTLOCK,
        output          HMASTLOCKREG,
        output          SELUDATA
    );



  //****************************other parameter**************************//

  localparam k_WRITE      = 1'b1;
  localparam k_READ       = 1'b0;
  localparam k_RESPOK     = 1'b0;
  localparam k_RESPERR    = 1'b1;

  // State Variables
  // Idle
  localparam k_IDLE_STATE      = 3'b000;
  localparam k_WRITE_STATE     = 3'b001;
  localparam k_READ_STATE      = 3'b010;
  localparam k_ERR_STATE       = 3'b011;
  localparam k_FLUSH_DEC_STATE = 3'b100;
  localparam k_FLUSH_STATE     = 3'b101;
  localparam k_BUSY_STATE      = 3'b110;

  //*****************************State Register***************************//
  //Synchoronous State register
  reg [2:0] AhbToAxiState_q;

  //************************Combinatorial Signals************************//
  //Next State Control && other combinational Signals
  reg [2:0] AhbToAxiNextState;
  reg       latchahbcmd;
  reg       awvalid_set;
  reg       awvalid_clr;
  reg       wvalid_set;
  reg       wvalid_clr;
  reg       bready_set;
  reg       bready_clr;
  reg       arvalid_set;
  reg       arvalid_clr;
  reg       rready_set;
  reg       rready_clr;
  reg       init_strb;
  reg       shift_strb;
  reg       burstcount_load;
  reg       burstcount_dec;

  wire      valid_ahbcmd;

  //*************************Sequential Elements*************************//
  //AHBCmdreg {HADDR,HTRANS,HBURST,HSIZE,HWRITE}
  reg [31:0]  haddr_q;
  reg                   hwrite_q;
  reg [1:0]             htrans_q;
  reg [2:0]             hburst_q;
  reg [1:0]             hsize_q;
  reg                   wvalid_q;
  reg                   awvalid_q;
  reg                   bready_q;
  reg                   rready_q;
  reg                   arvalid_q;
  reg [7:0] wstrb_q;
  reg [3:0]             burstcount_q;
  reg                   hmastlock_q ;
  reg                   rd_wr_haddr_q;

  //**************************Sequential Block of State Machine*********//

  localparam k_wstrbbits = 8;

  always @(negedge HRESETn or posedge HCLK)
  begin : AhbToAxi_Seq_logic
    if (HRESETn == 1'b0) begin
       haddr_q            <= 32'h0;
       hwrite_q           <= 1'b0;
       htrans_q           <= 2'b0;
       hburst_q           <= 3'b0;
       hsize_q            <= 2'b0;
       AhbToAxiState_q    <= 3'b0;
       wvalid_q           <= 1'b0;
       awvalid_q          <= 1'b0;
       bready_q           <= 1'b0;
       rready_q           <= 1'b0;
       arvalid_q          <= 1'b0;
       wstrb_q            <= 8'b0;
       burstcount_q       <= 4'b0;
       hmastlock_q        <= 1'b0;
       rd_wr_haddr_q      <= 1'b0;
     end else begin
       AhbToAxiState_q    <= AhbToAxiNextState;

       if (HREADYOUT) begin
          rd_wr_haddr_q   <= HADDR[2];
       end

       if (latchahbcmd) begin
          haddr_q         <= HADDR;
          htrans_q        <= HTRANS[1:0];
          hburst_q        <= HBURST[2:0];
          hsize_q         <= HSIZE[1:0] ;
          hwrite_q        <= HWRITE     ;
          hmastlock_q     <= HMASTLOCK  ;
       end

       if (awvalid_set) begin
          awvalid_q    <= 1'b1;
       end else if (awvalid_clr) begin
          awvalid_q    <= 1'b0;
       end

       if (wvalid_set) begin
           wvalid_q    <= 1'b1;
       end else if (wvalid_clr) begin
           wvalid_q    <= 1'b0;
       end

       if (bready_set) begin
          bready_q     <= 1'b1;
       end else if (bready_clr) begin
          bready_q     <= 1'b0;
       end

       if (arvalid_set) begin
          arvalid_q    <= 1'b1;
       end else if (arvalid_clr) begin
          arvalid_q    <= 1'b0;
       end

       if (rready_set) begin
          rready_q     <= 1'b1;
       end else if (rready_clr) begin
          rready_q     <= 1'b0;
       end

       if (burstcount_load) begin
          burstcount_q <= (HBURST[2:1] == 2'b0) ? 4'b0000 : (HBURST[2:1] == 2'b01) ?
                                                  4'b0011 : (HBURST[2:1] == 2'b10) ?
                                                  4'b0111 : 4'b1111;
       end else if (burstcount_dec) begin
          burstcount_q <= burstcount_q - 1'b1;
       end

       if (init_strb) begin //initial value of strobe
          case(HSIZE)
            2'b00 : wstrb_q <= 8'b00000001 << HADDR[2:0];
            2'b01 : wstrb_q <= 8'b00000011 << HADDR[2:0];
            2'b10 : wstrb_q <= 8'b00001111 << HADDR[2:0];
            2'b11 : wstrb_q <= 8'b11111111;
          endcase
       end else if (shift_strb) begin
          case(HSIZEREG)
           2'b00 : if(HBURSTREG==3'b010) begin
                      wstrb_q[3:0] <= {wstrb_q[2:0], wstrb_q[3]};
                      wstrb_q[7:4] <= {wstrb_q[6:4], wstrb_q[7]};
                    end else begin
                      wstrb_q <= {wstrb_q[k_wstrbbits-2:0], wstrb_q[k_wstrbbits-1]};
                    end
            2'b01 : wstrb_q <= {wstrb_q[k_wstrbbits-3:0], wstrb_q[k_wstrbbits-1:k_wstrbbits-2]};
            2'b10 : wstrb_q <= {wstrb_q[k_wstrbbits-5:0], wstrb_q[k_wstrbbits-1:k_wstrbbits-4]};
            2'b11 : wstrb_q <= 8'b11111111;
          endcase
       end

    end
  end

  assign SELUDATA = rd_wr_haddr_q;

  //*********************Sequential Output Assignments*********************//
  assign AWVALID      = awvalid_q;
  assign WVALID       = wvalid_q;
  assign BREADY       = bready_q;
  assign RREADY       = rready_q;
  assign ARVALID      = arvalid_q;
  assign HBURSTREG    = hburst_q;
  assign HADDRREG     = haddr_q;
  assign HWRITEREG    = hwrite_q;
  assign HMASTLOCKREG = hmastlock_q;
  assign HSIZEREG     = hsize_q;
  assign WSTRB        = wstrb_q;

  assign WLAST        = (burstcount_q == 4'b0 && wvalid_q == 1'b1) ? 1'b1 : 1'b0;
  assign valid_ahbcmd = (HSEL && HREADY && HTRANS[1]) ? 1'b1 : 1'b0;

  // *********************State Transition control block****************//
  always @(*)
  begin : AhbToAxi_State_Management

    latchahbcmd      = 1'b0;
    awvalid_set      = 1'b0;
    wvalid_set       = 1'b0;
    bready_set       = 1'b0;
    rready_set       = 1'b0;
    arvalid_set      = 1'b0;
    awvalid_clr      = 1'b0;
    wvalid_clr       = 1'b0;
    bready_clr       = 1'b0;
    rready_clr       = 1'b0;
    arvalid_clr      = 1'b0;
    init_strb        = 1'b0;
    shift_strb       = 1'b0;
    burstcount_load  = 1'b0;
    burstcount_dec   = 1'b0;
    HREADYOUT        = 1'b0;
    HRESP            = k_RESPOK;
    AhbToAxiNextState= AhbToAxiState_q;

    case (AhbToAxiState_q)

    //***********************IDLE STATE****************************8//
    k_IDLE_STATE :
      begin
        HREADYOUT         = 1'b1; //Ready for Transaction
        if (valid_ahbcmd) begin
           latchahbcmd       = 1'b1;
           // Write Signal Generation
           case (HWRITE)
              k_WRITE :
                begin
                  awvalid_set       = 1'b1;
                  wvalid_set        = 1'b1;
                  bready_set        = 1'b1;
                  init_strb         = 1'b1;
                  burstcount_load   = 1'b1;
                  AhbToAxiNextState = k_WRITE_STATE;
                end
              // Read Signal Generation
              k_READ :
                begin
                  rready_set        = 1'b1;
                  arvalid_set       = 1'b1;
                  AhbToAxiNextState = k_READ_STATE;
                end
           endcase
        end else begin
           AhbToAxiNextState = AhbToAxiState_q;
        end
      end

       //***********************WRITE STATE*********************************//
    k_WRITE_STATE :
      begin
         //Write Address Channel Response received
         if (AWREADY) begin
           awvalid_clr = 1'b1;
         end

        AhbToAxiNextState = AhbToAxiState_q;

        if (burstcount_q == 4'b0) begin // last beat
          if (BVALID) begin
            bready_clr = 1'b1;
            if (BRESP == k_RESPOK) begin //OK RESP
               HREADYOUT = 1'b1;
               HRESP = k_RESPOK;
               if (valid_ahbcmd) begin //Pipelined Trans to reduce latency
                  latchahbcmd = 1'b1;
                  case (HWRITE)
                      k_WRITE :
                        begin
                          awvalid_set       = 1'b1;
                          wvalid_set        = 1'b1;
                          bready_set        = 1'b1;
                          init_strb         = 1'b1;
                          burstcount_load   = 1'b1;
                          AhbToAxiNextState = k_WRITE_STATE;
                        end
                      // Read Signal Generation
                      k_READ :
                        begin
                          rready_set        = 1'b1;
                          arvalid_set       = 1'b1;
                          AhbToAxiNextState = k_READ_STATE;
                        end
                  endcase
               end else begin
                  AhbToAxiNextState = k_IDLE_STATE;
               end
            end else begin // ERROR RESP
               HREADYOUT = 1'b0;
               HRESP = k_RESPERR;
               AhbToAxiNextState = k_ERR_STATE;
            end
          end
          if (WREADY) begin
             wvalid_clr = 1'b1;
          end else begin
             wvalid_clr = 1'b0;
          end
        end else begin //If burst count is not 0
          if (WREADY) begin
             HREADYOUT = 1'b1;
             HRESP     = k_RESPOK;
             if (WVALID) begin //Valid Data
               burstcount_dec = 1'b1;
               shift_strb     = 1'b1;
             end
          end else begin
             HREADYOUT = 1'b0;
          end
          // IS Master Busy -Ensuring that previous trans data is written
          if (HTRANS == 2'b01 && WREADY) begin
            wvalid_clr  = 1'b1;
            AhbToAxiNextState = k_BUSY_STATE;
          end else begin
            wvalid_set  = 1'b1;
            AhbToAxiNextState = AhbToAxiState_q;
          end
        end
      end

    //********************************** READ STATE*************************//
    k_READ_STATE :
      begin
        //READ Address Channel Response received
        if (ARREADY) begin
          arvalid_clr = 1'b1;
        end

        // If Last Cycle of Read Data
        if (RLAST && RVALID) begin
           rready_clr = 1'b1;
           if (RRESP == k_RESPOK) begin //OK RESP
             HREADYOUT = 1'b1;
             HRESP = k_RESPOK;
             if (valid_ahbcmd) begin //Pipelined Trans to reduce latency
                latchahbcmd = 1'b1;
                case (HWRITE)
                    k_WRITE :
                      begin
                        awvalid_set       = 1'b1;
                        wvalid_set        = 1'b1;
                        bready_set        = 1'b1;
                        init_strb         = 1'b1;
                        burstcount_load   = 1'b1;
                        AhbToAxiNextState = k_WRITE_STATE;
                      end
                    // Read Signal Generation
                    k_READ :
                      begin
                        rready_set        = 1'b1;
                        arvalid_set       = 1'b1;
                        AhbToAxiNextState = k_READ_STATE;
                      end
                endcase
             end else begin
                AhbToAxiNextState = k_IDLE_STATE;
             end
           end else begin // ERROR RESP
             HREADYOUT = 1'b0;
             HRESP = k_RESPERR;
             AhbToAxiNextState = k_ERR_STATE;
           end
        // If Other Beats of Burst Response
        end else begin
          AhbToAxiNextState = AhbToAxiState_q;
         // Is Master Busy to Receive Data -- Atleast Previous transaction is served
          if (HTRANS == 2'b01 && RVALID) begin
            rready_clr   = 1'b1;
          end else begin
            rready_set   = 1'b1;
          end
          // Slave is ready with next data -- but an error
          if (RVALID && RREADY && RRESP == k_RESPERR) begin
             HREADYOUT = 1'b0;
          end else if (RVALID) begin // Slave ready with data
             HREADYOUT = 1'b1;
          end else begin
             HREADYOUT = 1'b0;
          end
          // Valid Response Generation for Intermediate beats
          if (RREADY && RVALID) begin
            if (RRESP == k_RESPOK) begin //OK RESP
               HRESP = k_RESPOK;
               if (HTRANS == 2'b01) begin // priority to BUSY change state
                 AhbToAxiNextState = k_BUSY_STATE;
               end else begin
                 AhbToAxiNextState = AhbToAxiState_q;
               end
            end else begin // ERROR RESP
               AhbToAxiNextState = k_FLUSH_DEC_STATE;
               HRESP = k_RESPERR;
            end
          end  //  Valid Response Generation
        end    // Other Cycle of Response
      end      // Case Begin


    //***********************************ERROR STATE************************//
    k_ERR_STATE :
      begin
         HRESP     = k_RESPERR;
         case (hwrite_q)
         k_WRITE :
           begin // For Writes response is only for last cycle
             AhbToAxiNextState = k_IDLE_STATE; // Cannot be busy in last cycle
             HREADYOUT    = 1'b1;
             if (valid_ahbcmd) begin //Pipelined Trans to reduce latency
                  latchahbcmd = 1'b1;
                  case (HWRITE)
                      // Write Signal Generation
                      k_WRITE :
                        begin
                          awvalid_set       = 1'b1;
                          wvalid_set        = 1'b1;
                          bready_set        = 1'b1;
                          init_strb         = 1'b1;
                          burstcount_load   = 1'b1;
                          AhbToAxiNextState = k_WRITE_STATE;
                        end
                      // Read Signal Generation
                      k_READ :
                        begin
                          rready_set        = 1'b1;
                          arvalid_set       = 1'b1;
                          AhbToAxiNextState = k_READ_STATE;
                        end
                  endcase
             end else begin
                AhbToAxiNextState = k_IDLE_STATE;
             end
           end
         k_READ : //LAST BEAT OF BURST/SINGLE TRANSFER
           begin
             if (HTRANS == 2'b00) begin // IDLE so wait for Changed Transaction
                HREADYOUT  = 1'b1;
                AhbToAxiNextState = k_IDLE_STATE;
             end else begin // Next Transaction is pipelined even with Error
               HREADYOUT = 1'b1;
               if (valid_ahbcmd) begin //Pipelined Trans to reduce latency
                  latchahbcmd = 1'b1;
                  case (HWRITE)
                      // Write Signal Generation
                      k_WRITE :
                        begin
                          awvalid_set       = 1'b1;
                          wvalid_set        = 1'b1;
                          bready_set        = 1'b1;
                          init_strb         = 1'b1;
                          burstcount_load   = 1'b1;
                          AhbToAxiNextState = k_WRITE_STATE;
                        end
                      // Read Signal Generation
                      k_READ :
                        begin
                          rready_set        = 1'b1;
                          arvalid_set       = 1'b1;
                          AhbToAxiNextState = k_READ_STATE;
                        end
                  endcase
               end else begin
                  AhbToAxiNextState = k_IDLE_STATE;
               end
             end
           end
         endcase
      end

    //***********************************FLUSH STATE**********************//
    k_FLUSH_DEC_STATE :
      begin

        HRESP     = k_RESPERR;
        HREADYOUT = 1'b1;

        // Check whether Flush Needed or not
        // If HTRANS is IDLE flush is needed.
        if (HTRANS == 2'b00) begin // IDLE
          AhbToAxiNextState = k_FLUSH_STATE;
        end else if (HTRANS == 2'b01) begin // busy
          AhbToAxiNextState = k_BUSY_STATE;
        end else begin        //Continuing with BURST - only SEQ State possible
          AhbToAxiNextState = k_READ_STATE;
        end

      end

    //***********************************FLUSH STATE**********************//
    k_FLUSH_STATE :
      begin

        HRESP     = k_RESPOK;
        HREADYOUT = 1'b0;

        if (RLAST) begin
          rready_clr = 1'b1;
          HREADYOUT  = 1'b1;
          if (valid_ahbcmd) begin //Pipelined Trans to reduce latency
            latchahbcmd = 1'b1;
            case (HWRITE)
               // Write Signal Generation
               k_WRITE :
                 begin
                   awvalid_set       = 1'b1;
                   wvalid_set        = 1'b1;
                   bready_set        = 1'b1;
                   init_strb         = 1'b1;
                   burstcount_load   = 1'b1;
                   AhbToAxiNextState = k_WRITE_STATE;
                 end
               // Read Signal Generation
               k_READ :
                 begin
                   rready_set        = 1'b1;
                   arvalid_set       = 1'b1;
                   AhbToAxiNextState = k_READ_STATE;
                 end
            endcase
          end else begin
            AhbToAxiNextState = k_IDLE_STATE;
          end
        end else begin
          rready_set = 1'b1;
          AhbToAxiNextState = AhbToAxiState_q;
        end

      end

    //***********************************BUSY STATE************************//
    k_BUSY_STATE :
      begin
        HREADYOUT  = 1'b1;  // Minimizes latency as for seq imm. effect
		
		//--------------------------------------------------------      
        //* SAR 118320
        if (AWREADY && AWVALID) begin
           awvalid_clr = 1'b1;
        end   
        //--------------------------------------------------------

        if (hwrite_q) begin
          if (HTRANS == 2'b11) begin
             wvalid_clr = 1'b0;
             wvalid_set = 1'b1;
             AhbToAxiNextState = k_WRITE_STATE;
          end else begin
             wvalid_clr = 1'b1;
             wvalid_set = 1'b0;
             AhbToAxiNextState = AhbToAxiState_q;
          end
        end else begin
          if (HTRANS == 2'b11) begin // Can only be seq in this state
            rready_clr = 1'b0;
            rready_set = 1'b1;
            AhbToAxiNextState = k_READ_STATE;
          end else begin
            rready_clr = 1'b1;
            rready_set = 1'b0;
            AhbToAxiNextState = AhbToAxiState_q;
          end
        end
      end

    //***********************************DEFAULT STATE*********************//
    default :
      begin
        AhbToAxiNextState = k_IDLE_STATE;
      end

   endcase
 end

endmodule
