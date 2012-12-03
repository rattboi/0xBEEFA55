////////////////////////////////////////////////////////////////////////////////
// ECE 485/585: Microprocessor System Design
// Portland State University - Fall 2012 
// Final Project: 
// 
// File:		L_NEXT.v (Next Level Cache/Memory stub)
// Authors: 
// Description:
//
//
//
////////////////////////////////////////////////////////////////////////////////
module L_NEXT(
	// INPUTS
	input [25:0]  add_in,		// address in from L1
	input [1:0]   cmd_in		   // command from L1 
   );
	
  parameter READ_OUT    = 2'b01;
  parameter WRITE_OUT   = 2'b10;
  parameter RW_OUT      = 2'b10;  // Read with intent to write
  parameter NOP         = 2'b00;

endmodule

