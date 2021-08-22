//////////////////////////////////////////////////////////////////////
// Created by SmartDesign Sat Aug 21 22:24:14 2021
// Version: v2021.2 2021.2.0.11
//////////////////////////////////////////////////////////////////////

`timescale 1ns / 100ps

//////////////////////////////////////////////////////////////////////
// Component Description (Tcl) 
//////////////////////////////////////////////////////////////////////
/*
# Exporting Component Description of CORESDR_AHB_C1 to TCL
# Family: SmartFusion2
# Part Number: M2S010-VF400
# Create and Configure the core component CORESDR_AHB_C1
create_and_configure_core -core_vlnv {Actel:DirectCore:CORESDR_AHB:4.4.107} -component_name {CORESDR_AHB_C1} -params {\
"AUTO_PCH:0"  \
"BURST_SUPPORT:1"  \
"CL:2"  \
"COLBITS:3"  \
"DELAY:10000"  \
"ECC:0"  \
"MRD:2"  \
"RAS:5"  \
"RC:7"  \
"RCD:3"  \
"REF:1040"  \
"REGDIMM:0"  \
"RFC:7"  \
"ROWBITS:1"  \
"RP:3"  \
"RRD:2"  \
"SDRAM_BANKSTATMODULES:4"  \
"SDRAM_CHIPBITS:1"  \
"SDRAM_CHIPS:1"  \
"SDRAM_COLBITS:8"  \
"SDRAM_DQSIZE:16"  \
"SDRAM_RASIZE:31"  \
"SDRAM_ROWBITS:12"  \
"SYS_FREQ:0"  \
"WR:2"   }
# Exporting Component Description of CORESDR_AHB_C1 to TCL done
*/

// CORESDR_AHB_C1
module CORESDR_AHB_C1(
    // Inputs
    HADDR,
    HBURST,
    HCLK,
    HREADYIN,
    HRESETN,
    HSEL,
    HSIZE,
    HTRANS,
    HWDATA,
    HWRITE,
    SDRCLK_IN,
    SDRCLK_RESETN,
    // Outputs
    BA,
    CAS_N,
    CKE,
    CS_N,
    DQM,
    HRDATA,
    HREADY,
    HRESP,
    OE,
    RAS_N,
    SA,
    SDRCLK_OUT,
    WE_N,
    // Inouts
    DQ
);

//--------------------------------------------------------------------
// Input
//--------------------------------------------------------------------
input  [31:0] HADDR;
input  [2:0]  HBURST;
input         HCLK;
input         HREADYIN;
input         HRESETN;
input         HSEL;
input  [2:0]  HSIZE;
input  [1:0]  HTRANS;
input  [31:0] HWDATA;
input         HWRITE;
input         SDRCLK_IN;
input         SDRCLK_RESETN;
//--------------------------------------------------------------------
// Output
//--------------------------------------------------------------------
output [1:0]  BA;
output        CAS_N;
output        CKE;
output [0:0]  CS_N;
output [1:0]  DQM;
output [31:0] HRDATA;
output        HREADY;
output [1:0]  HRESP;
output        OE;
output        RAS_N;
output [13:0] SA;
output        SDRCLK_OUT;
output        WE_N;
//--------------------------------------------------------------------
// Inout
//--------------------------------------------------------------------
inout  [15:0] DQ;
//--------------------------------------------------------------------
// Nets
//--------------------------------------------------------------------
wire   [31:0] HADDR;
wire   [2:0]  HBURST;
wire   [31:0] AHBSlave_HRDATA;
wire          HREADYIN;
wire          AHBSlave_HREADYOUT;
wire   [1:0]  AHBSlave_HRESP;
wire          HSEL;
wire   [2:0]  HSIZE;
wire   [1:0]  HTRANS;
wire   [31:0] HWDATA;
wire          HWRITE;
wire   [1:0]  BA_net_0;
wire          CAS_N_net_0;
wire          CKE_net_0;
wire   [0:0]  CS_N_net_0;
wire   [15:0] DQ;
wire   [1:0]  DQM_net_0;
wire          HCLK;
wire          HRESETN;
wire          OE_net_0;
wire          RAS_N_net_0;
wire   [13:0] SA_net_0;
wire          SDRCLK_IN;
wire          SDRCLK_OUT_net_0;
wire          SDRCLK_RESETN;
wire          WE_N_net_0;
wire          OE_net_1;
wire          RAS_N_net_1;
wire          CAS_N_net_1;
wire          WE_N_net_1;
wire          CKE_net_1;
wire          SDRCLK_OUT_net_1;
wire   [13:0] SA_net_1;
wire   [1:0]  BA_net_1;
wire   [0:0]  CS_N_net_1;
wire   [1:0]  DQM_net_1;
wire   [31:0] AHBSlave_HRDATA_net_0;
wire          AHBSlave_HREADYOUT_net_0;
wire   [1:0]  AHBSlave_HRESP_net_0;
//--------------------------------------------------------------------
// Top level output port assignments
//--------------------------------------------------------------------
assign OE_net_1                 = OE_net_0;
assign OE                       = OE_net_1;
assign RAS_N_net_1              = RAS_N_net_0;
assign RAS_N                    = RAS_N_net_1;
assign CAS_N_net_1              = CAS_N_net_0;
assign CAS_N                    = CAS_N_net_1;
assign WE_N_net_1               = WE_N_net_0;
assign WE_N                     = WE_N_net_1;
assign CKE_net_1                = CKE_net_0;
assign CKE                      = CKE_net_1;
assign SDRCLK_OUT_net_1         = SDRCLK_OUT_net_0;
assign SDRCLK_OUT               = SDRCLK_OUT_net_1;
assign SA_net_1                 = SA_net_0;
assign SA[13:0]                 = SA_net_1;
assign BA_net_1                 = BA_net_0;
assign BA[1:0]                  = BA_net_1;
assign CS_N_net_1[0]            = CS_N_net_0[0];
assign CS_N[0:0]                = CS_N_net_1[0];
assign DQM_net_1                = DQM_net_0;
assign DQM[1:0]                 = DQM_net_1;
assign AHBSlave_HRDATA_net_0    = AHBSlave_HRDATA;
assign HRDATA[31:0]             = AHBSlave_HRDATA_net_0;
assign AHBSlave_HREADYOUT_net_0 = AHBSlave_HREADYOUT;
assign HREADY                   = AHBSlave_HREADYOUT_net_0;
assign AHBSlave_HRESP_net_0     = AHBSlave_HRESP;
assign HRESP[1:0]               = AHBSlave_HRESP_net_0;
//--------------------------------------------------------------------
// Component instances
//--------------------------------------------------------------------
//--------CORESDR_AHB_C1_CORESDR_AHB_C1_0_CORESDR_AHB   -   Actel:DirectCore:CORESDR_AHB:4.4.107
CORESDR_AHB_C1_CORESDR_AHB_C1_0_CORESDR_AHB #( 
        .AUTO_PCH              ( 0 ),
        .BURST_SUPPORT         ( 1 ),
        .CL                    ( 2 ),
        .COLBITS               ( 3 ),
        .DELAY                 ( 10000 ),
        .ECC                   ( 0 ),
        .FAMILY                ( 19 ),
        .MRD                   ( 2 ),
        .RAS                   ( 5 ),
        .RC                    ( 7 ),
        .RCD                   ( 3 ),
        .REF                   ( 1040 ),
        .REGDIMM               ( 0 ),
        .RFC                   ( 7 ),
        .ROWBITS               ( 1 ),
        .RP                    ( 3 ),
        .RRD                   ( 2 ),
        .SDRAM_BANKSTATMODULES ( 4 ),
        .SDRAM_CHIPBITS        ( 1 ),
        .SDRAM_CHIPS           ( 1 ),
        .SDRAM_COLBITS         ( 8 ),
        .SDRAM_DQSIZE          ( 16 ),
        .SDRAM_RASIZE          ( 31 ),
        .SDRAM_ROWBITS         ( 12 ),
        .SYS_FREQ              ( 0 ),
        .WR                    ( 2 ) )
CORESDR_AHB_C1_0(
        // Inputs
        .HCLK          ( HCLK ),
        .HSEL          ( HSEL ),
        .HREADYIN      ( HREADYIN ),
        .HRESETN       ( HRESETN ),
        .HWRITE        ( HWRITE ),
        .SDRCLK_IN     ( SDRCLK_IN ),
        .SDRCLK_RESETN ( SDRCLK_RESETN ),
        .HADDR         ( HADDR ),
        .HSIZE         ( HSIZE ),
        .HTRANS        ( HTRANS ),
        .HWDATA        ( HWDATA ),
        .HBURST        ( HBURST ),
        // Outputs
        .HREADY        ( AHBSlave_HREADYOUT ),
        .OE            ( OE_net_0 ),
        .RAS_N         ( RAS_N_net_0 ),
        .CAS_N         ( CAS_N_net_0 ),
        .WE_N          ( WE_N_net_0 ),
        .CKE           ( CKE_net_0 ),
        .SDRCLK_OUT    ( SDRCLK_OUT_net_0 ),
        .HRDATA        ( AHBSlave_HRDATA ),
        .HRESP         ( AHBSlave_HRESP ),
        .SA            ( SA_net_0 ),
        .BA            ( BA_net_0 ),
        .CS_N          ( CS_N_net_0 ),
        .DQM           ( DQM_net_0 ),
        // Inouts
        .DQ            ( DQ ) 
        );


endmodule
