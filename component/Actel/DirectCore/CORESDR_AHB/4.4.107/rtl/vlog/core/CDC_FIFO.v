`timescale 1ns / 1ns
///////////////////////////////////////////////////////////////////////////////////////////////////
// Company: MICROSEMI
//
// IP Core: COREAXI4INTERCONNECT
//
//  Description  : The AMBA AXI4 Interconnect core connects one or more AXI memory-mapped master devices to one or
//                 more memory-mapped slave devices. The AMBA AXI protocol supports high-performance, high-frequency
//                 system designs.
//
//  COPYRIGHT 2017 BY MICROSEMI 
//  THE INFORMATION CONTAINED IN THIS DOCUMENT IS SUBJECT TO LICENSING RESTRICTIONS 
//  FROM MICROSEMI CORP.  IF YOU ARE NOT IN POSSESSION OF WRITTEN AUTHORIZATION FROM 
//  MICROSEMI FOR USE OF THIS FILE, THEN THE FILE SHOULD BE IMMEDIATELY DESTROYED AND 
//  NO BACK-UP OF THE FILE SHOULD BE MADE. 
//
//
/////////////////////////////////////////////////////////////////////////////////////////////////// 



module CDC_FIFO #

  (
    parameter integer  MEM_DEPTH         = 4,
    parameter FAMILY                     = 16,
    parameter ECC                        = 1,
    parameter integer  DATA_WIDTH        = 20
  )
  (
    input wire W_RST_N,
    input wire R_RST_N,
    input wire CLK_WR,
    input wire CLK_RD,
    input wire terminate_wr,
    input wire terminate_rd,

    input wire WR_EN, // write enable
    input wire RD_EN, // read enable

    input wire [DATA_WIDTH-1:0] DATA_IN,

    output wire [DATA_WIDTH-1:0] DATA_OUT,
    output wire FIFO_FULL,  // ~full 
    output wire FIFO_EMPTY   // ~empty
  );



  parameter SYNC_RESET = (FAMILY == 25) ? 1 : 0;

  localparam FIFO_ADDR_WIDTH = (MEM_DEPTH < 4) ? 2 : $clog2(MEM_DEPTH);

  wire AW_RST_N;
  wire SW_RST_N;
  wire AR_RST_N;
  wire SR_RST_N;

  assign AW_RST_N = (SYNC_RESET == 1) ? 1'b1 : W_RST_N;
  assign SW_RST_N = (SYNC_RESET == 1) ? W_RST_N : 1'b1;
  assign AR_RST_N = (SYNC_RESET == 1) ? 1'b1 : R_RST_N;
  assign SR_RST_N = (SYNC_RESET == 1) ? R_RST_N : 1'b1;

  reg [FIFO_ADDR_WIDTH-1:0] wrPtr_s1, wrPtr_s2 /* synthesis syn_preserve = 1 */;
  reg [FIFO_ADDR_WIDTH-1:0] rdPtr_s1, rdPtr_s2;
  wire [FIFO_ADDR_WIDTH-1:0] wrPtr;
  wire [FIFO_ADDR_WIDTH-1:0] rdPtr;

  wire [FIFO_ADDR_WIDTH-1:0] wrPtrP1, wrPtrP2;
  wire [FIFO_ADDR_WIDTH-1:0] rdPtrP1;

  wire fifoWe;
  wire fifoRe;
  wire syncRstWrCnt;
  wire syncRstRdCnt;

  wire FIFO_EMPTY_wire;
  assign FIFO_EMPTY = !FIFO_EMPTY_wire;

  wire [DATA_WIDTH-1:0] infoOut_reg;

  assign        DATA_OUT = infoOut_reg;

   
   generate 
     if (ECC == 1) begin   
 
     SDRAHB_RAM_BLOCK_ECC#
     (
        .MEM_DEPTH    ( 2**(FIFO_ADDR_WIDTH) ),
        .ADDR_WIDTH   ( FIFO_ADDR_WIDTH ),
        .DATA_WIDTH   ( DATA_WIDTH ) 
     )
     ram (
        .clk_wr       ( CLK_WR ),
        .clk_rd       ( CLK_RD ),
        .wr_en        ( fifoWe ),
        .wr_addr      ( wrPtr ),
        .rd_addr      ( rdPtr ),
        .data_in      ( DATA_IN ),
        .data_out     ( infoOut_reg )
    );
    end
    else if (ECC ==0 ) begin
 
    SDRAHB_RAM_BLOCK#
     (
        .MEM_DEPTH    ( 2**(FIFO_ADDR_WIDTH) ),
        .ADDR_WIDTH   ( FIFO_ADDR_WIDTH ),
        .DATA_WIDTH   ( DATA_WIDTH ) 
     )
     ram (
        .clk_wr       ( CLK_WR ),
        .clk_rd       ( CLK_RD ),
        .wr_en        ( fifoWe ),
        .wr_addr      ( wrPtr ),
        .rd_addr      ( rdPtr ),
        .data_in      ( DATA_IN ),
        .data_out     ( infoOut_reg )
    );
    end
    endgenerate

  // Write clock domain
  caxi4interconnect_CDC_grayCodeCounter #
    (
	.bin_rstValue ( 1 ),
        .gray_rstValue ( 0 ),
	.FAMILY ( FAMILY ),
        .n_bits ( FIFO_ADDR_WIDTH )
    )
    wrGrayCounter
    (    
        .clk (CLK_WR),
	.sysRst (W_RST_N),
	.terminate(terminate_wr),
	.syncRst (1'b1),
	.inc(fifoWe),
	.cntGray(wrPtr),
	.syncRstOut(syncRstWrCnt)
    );

    caxi4interconnect_CDC_grayCodeCounter #
    (
	.bin_rstValue ( 2 ),
        .gray_rstValue ( 1 ),
	.FAMILY ( FAMILY ),
        .n_bits ( FIFO_ADDR_WIDTH )
    )
    wrGrayCounterP1
    (    
        .clk (CLK_WR),
	.sysRst (W_RST_N),
        .terminate(terminate_wr),
	.syncRst (syncRstWrCnt),
	.inc(fifoWe),
	.cntGray(wrPtrP1),
	.syncRstOut ()
    );

    caxi4interconnect_CDC_grayCodeCounter #
    (
	.bin_rstValue ( 3 ),
        .gray_rstValue ( 3 ),
	.FAMILY ( FAMILY ),
        .n_bits ( FIFO_ADDR_WIDTH )
    )
    wrGrayCounterP2
    (    
        .clk (CLK_WR),
	.sysRst (W_RST_N),
	.terminate(terminate_wr),
	.syncRst (syncRstWrCnt),
	.inc(fifoWe),
	.cntGray(wrPtrP2),
	.syncRstOut ()
    );
    
    always @(posedge CLK_WR or negedge AW_RST_N) begin
       if ((!AW_RST_N) || (!SW_RST_N)) begin
          rdPtr_s1 <= 0;
	  rdPtr_s2 <= 0;
       end else if(terminate_wr) begin
          rdPtr_s1 <= 0;
	  rdPtr_s2 <= 0;
       end else begin
	  rdPtr_s1 <= rdPtr;
	  rdPtr_s2 <= rdPtr_s1;
      end
    end

    caxi4interconnect_CDC_wrCtrl # (
	.FAMILY ( FAMILY ),
        .ADDR_WIDTH ( FIFO_ADDR_WIDTH )
    )	  
    CDC_wrCtrl_inst (
	    .clk (CLK_WR),
	    .rst (W_RST_N),
	    .terminate(terminate_wr),
	    .wrPtr_gray (wrPtrP1),
	    .rdPtr_gray (rdPtr_s2),
	    .nextwrPtr_gray (wrPtrP2),
	    .readyForInfo (FIFO_FULL),
	    .infoInValid (WR_EN),
	    .fifoWe (fifoWe)
    );


  // read clock domain
  caxi4interconnect_CDC_grayCodeCounter #
    (
	.bin_rstValue ( 1 ),
        .gray_rstValue ( 0 ),
	.FAMILY ( FAMILY ),
        .n_bits ( FIFO_ADDR_WIDTH )
    )
    rdGrayCounter
    (    
        .clk (CLK_RD),
	.sysRst (R_RST_N),
        .terminate(terminate_rd),
	.syncRst (1'b1),
	.inc(fifoRe),
	.cntGray(rdPtr),
	.syncRstOut (syncRstRdCnt)
    );

    caxi4interconnect_CDC_grayCodeCounter #
    (
	.bin_rstValue ( 2 ),
        .gray_rstValue ( 1 ),
	.FAMILY ( FAMILY ),
        .n_bits ( FIFO_ADDR_WIDTH )
    )
    rdGrayCounterP1
    (    
        .clk (CLK_RD),
	.sysRst (R_RST_N),
        .terminate(terminate_rd),
	.syncRst (syncRstRdCnt),
	.inc(fifoRe),
	.cntGray(rdPtrP1),
	.syncRstOut ()
    );
    

    always @(posedge CLK_RD or negedge AR_RST_N) begin
       if ((!AR_RST_N) || (!SR_RST_N)) begin
	 wrPtr_s1 <= 0;
	 wrPtr_s2 <= 0;
       end else if(terminate_rd) begin
         wrPtr_s1 <= 0;
	 wrPtr_s2 <= 0;
       end else begin
	  wrPtr_s1 <= wrPtr;
	  wrPtr_s2 <= wrPtr_s1;
       end
    end

    caxi4interconnect_CDC_rdCtrl # (
	.FAMILY ( FAMILY ),
        .ADDR_WIDTH ( FIFO_ADDR_WIDTH )
    )	   
    CDC_rdCtrl_inst (
	    .clk (CLK_RD),
	    .rst (R_RST_N),
	    .terminate(terminate_rd),
	    .rdPtr_gray (rdPtr),
	    .wrPtr_gray (wrPtr_s2),
	    .nextrdPtr_gray (rdPtrP1),
	    .readyForOut (RD_EN),
	    .infoOutValid (FIFO_EMPTY_wire),
	    .fifoRe (fifoRe)
    );

endmodule

