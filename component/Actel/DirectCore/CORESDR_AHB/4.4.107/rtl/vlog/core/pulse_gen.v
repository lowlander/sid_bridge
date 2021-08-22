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

module pulse_gen(
                  input  src_clk,
                  input  src_reset,
		  input  pulse_in,
                  
                  output reg toggle_out
                  ) /* synthesis syn_preserve=1 */;

   // --------------------------------------------------------------------------
   // PARAMETER Declaration
   // --------------------------------------------------------------------------
 
   always @( posedge src_clk or negedge src_reset) begin
      if (!src_reset)
         toggle_out <= 1'b0;
      else begin
         if(pulse_in)
	    toggle_out <= ~toggle_out;
      end
   end


endmodule
   
   // --------------------------------------------------------------------------
   //                             End - of - Code
   // --------------------------------------------------------------------------
