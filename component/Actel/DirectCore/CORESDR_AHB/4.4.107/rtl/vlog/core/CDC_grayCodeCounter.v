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


module caxi4interconnect_CDC_grayCodeCounter #
  (
    parameter bin_rstValue = 1,
    parameter gray_rstValue = 0,
    parameter FAMILY        = 16,

    parameter integer n_bits = 4
  )
  (
    input wire clk,
    input wire sysRst,
    input      terminate,
    input wire syncRst,
    input wire inc,

    output wire syncRstOut,
    output reg [n_bits-1:0] cntGray

  );
  


  parameter SYNC_RESET = (FAMILY == 25) ? 1 : 0;



  wire asysRst;
  wire ssysRst;

  assign asysRst = (SYNC_RESET == 1) ? 1'b1 : sysRst;
  assign ssysRst = (SYNC_RESET == 1) ? sysRst : 1'b1;
 

  reg  [n_bits-1:0]  cntBinary;
  wire [n_bits-1:0]  nextGray, cntBinary_next;

 
 
   always @(posedge clk or negedge asysRst)begin
      if ((!asysRst) || (!ssysRst)) begin
         cntBinary               <= bin_rstValue;
         cntGray                 <= gray_rstValue;
      end else if(terminate) begin
         cntBinary               <= bin_rstValue;
         cntGray                 <= gray_rstValue;
      end else begin
         if (inc) begin
            if (!syncRst) begin
               cntBinary               <= bin_rstValue;
               cntGray                 <= gray_rstValue;
            end else begin
               cntBinary               <= cntBinary_next;
               cntGray                 <= nextGray;
            end
         end	
      end
   end
  
assign cntBinary_next = cntBinary + 1;
assign syncRstOut = (cntBinary == 0) ? 1'b0 : 1'b1;

caxi4interconnect_Bin2Gray #
(
        .n_bits(n_bits)
)
 bin2gray_inst(
        .cntBinary(cntBinary),
        .nextGray(nextGray)
);

endmodule
