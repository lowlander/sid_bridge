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
// SVN $Date: 2021-02-18 18:23:50 +0000 (Thu, 18 Feb 2021) $
// SVN $Author: ian.bryant $
// SVN $URL: svn://hoppin/G4/G4_data/Design/source/g4main/G4M_AHBTOAXI/trunk/soft/COREPCIE_AHBLTOAXI.v $
//
// Description: G4 AHB 32-bit to AXI 64-bit Bridge Top Module for PCIE
//
// Revision  Information:
// Date    who SAR    Description
// 18Feb21 IPB        Initial version - copied from ASIC code no functional change
// 23Mar21 IPB        Added NO_BURST parameter
//
// ******************************************************************************************************/

module COREPCIE_AHBLTOAXI (

  input             HCLK,
  input             HRESETN,

  // AHB Interface
  input             HSEL,
  input [31:0]      HADDR,
  input             HWRITE,
  input             HREADY,
  input [1:0]       HTRANS,
  input [1:0]       HSIZE,
  input [31:0]      HWDATA,
  input [2:0]       HBURST,
  output            HREADYOUT,
  output            HRESP,
  output [31:0]     HRDATA,

  // AXI Interface
  input             AWREADY,
  input             WREADY,
  input [1:0]       BRESP,
  input             BVALID,
  input             ARREADY,
  input [1:0]       RRESP,
  input             RLAST,
  input             RVALID,
  input [63:0]      RDATA,
  input [3:0]       BID,
  input [3:0]       RID,
  output [3:0]      AWID,
  output [3:0]      WID,
  output [3:0]      ARID,
  output [7:0]      WSTRB,
  output            WLAST,
  output            WVALID,
  output            BREADY,
  output [31:0]     ARADDR,
  output [3:0]      ARLEN,
  output [1:0]      ARSIZE,
  output [1:0]      ARBURST,
  output            ARVALID,
  output            RREADY,
  output [63:0]     WDATA,
  output [1:0]      ARLOCK,
  output [1:0]      AWLOCK,
  output [31:0]     AWADDR,
  output [3:0]      AWLEN,
  output [1:0]      AWSIZE,
  output [1:0]      AWBURST,
  output            AWVALID
 );

localparam NO_BURST = 1; // Convert AHB bursts to single beat AXI commands

wire [31:0]   HADDRREG;
wire [2:0]    HBURSTREG;
wire          HWRITEREG;
wire [1:0]    HSIZEREG;

//**************Read & Write Data is a feed through the Bridge*******//

wire SELUDATA;

assign WDATA  [63:0] =  {HWDATA[31:0],HWDATA[31:0]};                     // replicate AXI WDATA on both bus halves
assign HRDATA [31:0] =  ((SELUDATA) ? RDATA [63:32] : RDATA[31:0]); // Send appropiate half to AHB

// The AWID, WID, and ARID signals are tied low as the AHBL Interface 
// can only generate one read or write transaction at a given time 
assign AWID = 'b0;
assign WID  = 'b0;
assign ARID = 'b0;

// The AXI lock signals (AWLOCK and ARLOCK) are tied low as the 
// core does not support AHBL lock signal (HMASTLOCK) 
assign AWLOCK = 'b0;
assign ARLOCK = 'b0;

AHBLTOAXICMD
 UCMD ( .HADDRREG     (HADDRREG),
        .HBURSTREG    (HBURSTREG),
        .HWRITEREG    (HWRITEREG),
        .HSIZEREG     (HSIZEREG),
        .ARADDR       (ARADDR),
        .ARBURST      (ARBURST),
        .ARLEN        (ARLEN),
        .ARSIZE       (ARSIZE),
        .AWADDR       (AWADDR),
        .AWBURST      (AWBURST),
        .AWLEN        (AWLEN),
        .AWSIZE       (AWSIZE),
        .HMASTLOCKREG (HMASTLOCKREG),
        .AWLOCK       (      ),
        .ARLOCK       (      )
        );

// SAR118629
wire [2:0] HBURSTX = (NO_BURST ? 3'b001           : HBURST);
wire [1:0] HTRANSX = (NO_BURST ? {HTRANS[1],1'b0} : HTRANS);

AHBLTOAXISM
  UFSM (.HCLK         (HCLK),
        .HRESETn      (HRESETN),
        .HSEL         (HSEL),
        .HADDR        (HADDR),
        .HWRITE       (HWRITE),
        .HREADY       (HREADY),
        .HTRANS       (HTRANSX),
        .HSIZE        (HSIZE),
        .HBURST       (HBURSTX),
        .HREADYOUT    (HREADYOUT),
        .HRESP        (HRESP),
        .AWREADY      (AWREADY),
        .WREADY       (WREADY),
        .BVALID       (BVALID),
        .BRESP        (BRESP[1]),
        .ARREADY      (ARREADY),
        .RVALID       (RVALID),
        .RRESP        (RRESP[1]),
        .RLAST        (RLAST),
        .AWVALID      (AWVALID),
        .WLAST        (WLAST),
        .WVALID       (WVALID),
        .WSTRB        (WSTRB),
        .BREADY       (BREADY),
        .RREADY       (RREADY),
        .ARVALID      (ARVALID),
        .HBURSTREG    (HBURSTREG),
        .HSIZEREG     (HSIZEREG),
        .HADDRREG     (HADDRREG),
        .HWRITEREG    (HWRITEREG),
        .HMASTLOCK    (1'b0),
        .HMASTLOCKREG (HMASTLOCKREG),
        .SELUDATA     (SELUDATA)
        );

endmodule
