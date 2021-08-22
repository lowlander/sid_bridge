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

module CORESDR_AHB_C1_CORESDR_AHB_C1_0_CORESDR_AHB (HCLK, HRESETN, HADDR, HSIZE, HSEL, HTRANS, HWRITE, HWDATA, HREADYIN, HRESP, HRDATA, HREADY, SDRCLK_IN ,SDRCLK_OUT, OE, SA, BA, CS_N, DQM, CKE, RAS_N, CAS_N, WE_N, DQ, SDRCLK_RESETN, HBURST);

   parameter BURST_SUPPORT  = 1;
   parameter FAMILY  = 16;
   parameter ECC  = 0;
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
  

   localparam SDRAM_DQMSIZE  = SDRAM_DQSIZE / 8;
   
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
   output            HREADY; 
   output     [1:0]  HRESP; 
   output     [31:0] HRDATA; 

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
 
   inout[SDRAM_DQSIZE - 1:0] DQ; 

   

generate 
   if (BURST_SUPPORT == 1 & SDRAM_DQSIZE == 32 ) begin   

CORESDR_AHB_BURST_32DQ
#(.FAMILY(FAMILY), .ECC(ECC),.SDRAM_RASIZE(SDRAM_RASIZE), .SDRAM_CHIPS(SDRAM_CHIPS), .SDRAM_COLBITS(SDRAM_COLBITS), .SDRAM_ROWBITS(SDRAM_ROWBITS), .SDRAM_CHIPBITS(SDRAM_CHIPBITS), .SDRAM_BANKSTATMODULES(SDRAM_BANKSTATMODULES), .SDRAM_DQSIZE(SDRAM_DQSIZE), .RAS(RAS), .RCD(RCD), .RRD(RRD), .RP(RP), .RC(RC), .RFC(RFC), .WR(WR), .MRD(MRD), .CL(CL), .DELAY(DELAY), .REF(REF), .ROWBITS(ROWBITS), .COLBITS(COLBITS), .REGDIMM(REGDIMM), .AUTO_PCH(AUTO_PCH)) 
   CoreSDR_0(
      .HCLK          (HCLK), 
      .HRESETN       (HRESETN), 
      .HADDR         (HADDR), 
      .HSIZE         (HSIZE),  
      .HSEL          (HSEL),
      .HTRANS        (HTRANS), 
      .HWRITE        (HWRITE), 
      .HWDATA        (HWDATA), 
      .HREADYIN      (HREADYIN), 
      .HRESP         (HRESP), 
      .HBURST        (HBURST), 
      .HRDATA        (HRDATA), 
      .HREADY        (HREADY), 
      .SDRCLK_IN     (SDRCLK_IN), 
      .SDRCLK_OUT    (SDRCLK_OUT), 
      .OE            (OE), 
      .SA            (SA), 
      .BA            (BA), 
      .CS_N          (CS_N), 
      .DQM           (DQM), 
      .CKE           (CKE), 
      .RAS_N         (RAS_N), 
      .CAS_N         (CAS_N), 
      .WE_N          (WE_N), 
      .DQ            (DQ), 
      .SDRCLK_RESETN (SDRCLK_RESETN) 
   );

   end

   else if (BURST_SUPPORT == 1 & SDRAM_DQSIZE ==16) begin 

CORESDR_AHB_BURST_16DQ
#(.FAMILY(FAMILY), .ECC(ECC), .SDRAM_RASIZE(SDRAM_RASIZE), .SDRAM_CHIPS(SDRAM_CHIPS), .SDRAM_COLBITS(SDRAM_COLBITS), .SDRAM_ROWBITS(SDRAM_ROWBITS), .SDRAM_CHIPBITS(SDRAM_CHIPBITS), .SDRAM_BANKSTATMODULES(SDRAM_BANKSTATMODULES),
  .SDRAM_DQSIZE(SDRAM_DQSIZE), .RAS(RAS), .RCD(RCD), .RRD(RRD), .RP(RP), .RC(RC), .RFC(RFC), .WR(WR), .MRD(MRD), .CL(CL), .DELAY(DELAY), .REF(REF), .ROWBITS(ROWBITS), .COLBITS(COLBITS), .REGDIMM(REGDIMM), .AUTO_PCH(AUTO_PCH)) 
   CoreSDR_0(
      .HCLK          (HCLK), 
      .HRESETN       (HRESETN), 
      .HADDR         (HADDR), 
      .HSIZE         (HSIZE),  
      .HSEL          (HSEL),
      .HTRANS        (HTRANS), 
      .HWRITE        (HWRITE), 
      .HWDATA        (HWDATA), 
      .HREADYIN      (HREADYIN), 
      .HRESP         (HRESP), 
      .HBURST        (HBURST), 
      .HRDATA        (HRDATA), 
      .HREADY        (HREADY), 
      .SDRCLK_IN     (SDRCLK_IN), 
      .SDRCLK_OUT    (SDRCLK_OUT), 
      .OE            (OE), 
      .SA            (SA), 
      .BA            (BA), 
      .CS_N          (CS_N), 
      .DQM           (DQM), 
      .CKE           (CKE), 
      .RAS_N         (RAS_N), 
      .CAS_N         (CAS_N), 
      .WE_N          (WE_N), 
      .DQ            (DQ), 
      .SDRCLK_RESETN (SDRCLK_RESETN) 
   );

   end

   else if (BURST_SUPPORT == 0) begin 

CORESDR_AHB_SINGLE 
#(.FAMILY(FAMILY), .SDRAM_RASIZE(SDRAM_RASIZE),.SDRAM_CHIPS(SDRAM_CHIPS), .SDRAM_COLBITS(SDRAM_COLBITS), .SDRAM_ROWBITS(SDRAM_ROWBITS), .SDRAM_CHIPBITS(SDRAM_CHIPBITS), .SDRAM_BANKSTATMODULES(SDRAM_BANKSTATMODULES), 
  .SDRAM_DQSIZE(SDRAM_DQSIZE),.SYS_FREQ(SYS_FREQ),.RAS(RAS), .RCD(RCD), .RRD(RRD), .RP(RP), .RC(RC), .RFC(RFC), .WR(WR), .MRD(MRD), .CL(CL), .DELAY(DELAY), .REF(REF), .ROWBITS(ROWBITS), .COLBITS(COLBITS), .REGDIMM(REGDIMM), 
  .AUTO_PCH(AUTO_PCH)) 
   CoreSDR_0(
      .HCLK          (HCLK), 
      .HRESETN       (HRESETN), 
      .HADDR         (HADDR), 
      .HSIZE         (HSIZE),  
      .HSEL          (HSEL),
      .HTRANS        (HTRANS), 
      .HWRITE        (HWRITE), 
      .HWDATA        (HWDATA), 
      .HREADYIN      (HREADYIN), 
      .HRESP         (HRESP), 
      .HBURST        (HBURST), 
      .HRDATA        (HRDATA), 
      .HREADY        (HREADY), 
      .SDRCLK_IN     (SDRCLK_IN), 
      .SDRCLK_OUT    (SDRCLK_OUT), 
      .OE            (OE), 
      .SA            (SA), 
      .BA            (BA), 
      .CS_N          (CS_N), 
      .DQM           (DQM), 
      .CKE           (CKE), 
      .RAS_N         (RAS_N), 
      .CAS_N         (CAS_N), 
      .WE_N          (WE_N), 
      .DQ            (DQ), 
      .SDRCLK_RESETN (SDRCLK_RESETN)
   ); 

   end			   	
endgenerate


endmodule
