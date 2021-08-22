// ********************************************************************/
// Actel Corporation Proprietary and Confidential
//  Copyright 2011 Actel Corporation.  All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
// ACCORDANCE WITH THE ACTEL LICENSE AGREEMENT AND MUST BE APPROVED
// IN ADVANCE IN WRITING.
//
// Description: doubleSync.v
//               
//
//
// Revision Information:
// Date     Description
//
// SVN Revision Information:
// SVN $Revision: 4805 $
// SVN $Date: 2012-06-21 17:48:48 +0530 (Thu, 21 Jun 2012) $
//
// Resolved SARs
// SAR      Date     Who   Description
//
// Notes:
//
// ********************************************************************/

`timescale 1ns / 100ps

module CORESYNC_PULSE_CDC(
                              input      SRC_CLK,
                              input      DSTN_CLK,
                              input      SRC_RESET,
                              input      DSTN_RESET,
                              input      PULSE_IN,
                              output     SYNC_PULSE
                             ) ;

   // --------------------------------------------------------------------------
   // PARAMETER Declaration
   // --------------------------------------------------------------------------
  parameter NUM_STAGES = 2;
  parameter SYNC_RESET = 1;
  
wire toggle;
 

//////////// toggle generator 




generate 
   if (SYNC_RESET == 1) begin   
      
      pulse_gen_sync pulse_gen_i	
      (
      .src_clk       (SRC_CLK),
      .src_reset     (SRC_RESET),
      .pulse_in      (PULSE_IN),
      .toggle_out    (toggle)
      );		 
   end
   else if (SYNC_RESET == 0) begin 

      pulse_gen pulse_gen_i	
      (
      .src_clk       (SRC_CLK),
      .src_reset     (SRC_RESET),
      .pulse_in      (PULSE_IN),
      .toggle_out    (toggle)
      );		 
   
   end			   	
endgenerate



/////////////////// pulse synchronizer 



generate 
   if (SYNC_RESET == 1) begin   

      pulse_cdc_sync  # (
               .NUM_STAGES     (NUM_STAGES)  
			) 
      pulse_cdc_sync_i   
            (
	       .clk             (DSTN_CLK),
	       .reset           (DSTN_RESET),
	       .data_in         (toggle),
	       .sync_pulse      (SYNC_PULSE)
	     );
					 
   
   end
   else if (SYNC_RESET == 0) begin 

      pulse_cdc  # (
               .NUM_STAGES     (NUM_STAGES)  
			) 
      pulse_cdc_sync_i   
            (
	       .clk             (DSTN_CLK),
	       .reset           (DSTN_RESET),
	       .data_in         (toggle),
	       .sync_pulse      (SYNC_PULSE)
	     );
   end			   	
endgenerate




endmodule // corefifo_doubleSync
   // --------------------------------------------------------------------------
   //                             End - of - Code
   // --------------------------------------------------------------------------
