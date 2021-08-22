// syncr.v

// ********************************************************************/
// Actel Corporation Proprietary and Confidential
//  Copyright 2011 Actel Corporation.  All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
// ACCORDANCE WITH THE ACTEL LICENSE AGREEMENT AND MUST BE APPROVED
// IN ADVANCE IN WRITING.
//
// Description: Reset synchroniser.v
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

module pulse_cdc(
                  input  clk,
                  input  reset,
		  input  data_in,
                  
                  output sync_pulse
                  ) /* synthesis syn_preserve=1 syn_hier = "fixed" syn_noprune=1*/;

   // --------------------------------------------------------------------------
   // PARAMETER Declaration
   // --------------------------------------------------------------------------
 parameter NUM_STAGES = 2;
 

reg  [NUM_STAGES:0] sync_ff ;


   always @( posedge clk or negedge reset) begin
      if (!reset)
         sync_ff <= 'h0;
      else
         sync_ff <= {sync_ff[NUM_STAGES-1:0], data_in};
   end
    
 assign sync_pulse = sync_ff[NUM_STAGES] ^ sync_ff[NUM_STAGES-1];

endmodule
   
   // --------------------------------------------------------------------------
   //                             End - of - Code
   // --------------------------------------------------------------------------
