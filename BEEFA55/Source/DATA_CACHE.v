////////////////////////////////////////////////////////////////////////////////
// ECE 485/585: Microprocessor System Design
// Portland State University - Fall 2012 
// Final Project: 
// 
// File:		DATA_CACHE.v (Data Cache)
// Authors: 
// Description:
//
//
//
////////////////////////////////////////////////////////////////////////////////
module DATA_CACHE(
	// INPUTS
    input clk,
    input [3:0] n,			// from trace file
    input [31:0] add_in,	// from trace file
    input [511:0] d_in,		// from next-level stub
	
	// OUTPUTS
	output [31:0] add_out,	// to next-level cache
    output hit,				// to statistics module
    output miss				// to statistics module
    );


endmodule
