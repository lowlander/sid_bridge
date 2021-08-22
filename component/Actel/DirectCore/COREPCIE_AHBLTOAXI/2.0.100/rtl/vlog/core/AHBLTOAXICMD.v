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
// SVN $URL: svn://hoppin/G4/G4_data/Design/source/g4main/G4M_AHBTOAXI/tags/4.0.100/soft/AHBLTOAXICMD.v $
//
// Description: G4 AHB 32-bit to AXI 64-bit Bridge Top Module for PCIE
//
// Revision  Information:
// Date    who SAR    Description
// 18Feb21 IPB        Initial version - copied from ASIC code no functional change
//
//
// ******************************************************************************************************/

module AHBLTOAXICMD (
        input      [31:0]   HADDRREG,
        input      [2:0]    HBURSTREG,
        input      [1:0]    HSIZEREG,
        input               HWRITEREG,
        input               HMASTLOCKREG,
        output reg [31:0]   ARADDR,
        output reg [1:0]    ARBURST,
        output reg [3:0]    ARLEN,
        output reg [1:0]    ARSIZE,
        output reg [31:0]   AWADDR,
        output reg [1:0]    AWBURST,
        output reg [3:0]    AWLEN,
        output reg [1:0]    AWSIZE,
        output reg          AWLOCK,
        output reg          ARLOCK
    );

//*********************Local parameters************************//
localparam k_WRITE    = 1;
localparam k_READ     = 0;

//*********************Other Signals***************************//
reg [1:0]      BURSTTYPETRAN;
reg [3:0]      BURSTLENTRAN;

//*********************BURST TRANSLATION LOGIC******************//

always @(*)
begin : burst_translation_block

  case(HBURSTREG)
     3'b000 :
       begin
         BURSTLENTRAN  = 4'b0000;
         BURSTTYPETRAN = 2'b01;
       end
     3'b001 : //Undefined INCR converted to Single
       begin
         BURSTLENTRAN  = 4'b0000;
         BURSTTYPETRAN = 2'b01;
       end
     3'b010 :
       begin
         BURSTLENTRAN  = 4'b0011;
         BURSTTYPETRAN = 2'b10;
       end
     3'b011 :
       begin
         BURSTLENTRAN  = 4'b0011;
         BURSTTYPETRAN = 2'b01;
       end
     3'b100 :
       begin
         BURSTLENTRAN  = 4'b0111;
         BURSTTYPETRAN = 2'b10;
       end
     3'b101 :
       begin
         BURSTLENTRAN  = 4'b0111;
         BURSTTYPETRAN = 2'b01;
       end
     3'b110 :
       begin
         BURSTLENTRAN  = 4'b1111;
         BURSTTYPETRAN = 2'b10;
       end
     3'b111 :
       begin
         BURSTLENTRAN  = 4'b1111;
         BURSTTYPETRAN = 2'b01;
       end
   endcase
end


//*********************Command Generation Logic****************//
always @(*)
begin : Cmd_Control_Block

  ARADDR  = 32'h0;
  ARBURST = 2'b0;
  ARLEN   = 4'b0;
  ARSIZE  = 2'b0;
  AWADDR  = 32'h0;
  AWBURST = 2'b0;
  AWLEN   = 4'b0;
  AWSIZE  = 2'b0;
  ARLOCK  = 1'b0 ;
  AWLOCK  = 1'b0 ;

  case(HWRITEREG)
    k_WRITE :
      begin
        AWADDR  = HADDRREG;
        AWSIZE  = HSIZEREG;
        AWLEN   = BURSTLENTRAN;
        AWBURST = BURSTTYPETRAN;
        AWLOCK  = HMASTLOCKREG;
      end
    k_READ :
      begin
        ARADDR  = HADDRREG;
        ARSIZE  = HSIZEREG;
        ARLEN   = BURSTLENTRAN;
        ARBURST = BURSTTYPETRAN;
        ARLOCK  = HMASTLOCKREG;
      end
  endcase
end

endmodule
