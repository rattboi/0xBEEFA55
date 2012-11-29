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
`define LINES 1024*16
`define WAYS 2
`define LINEBITS 14
`define	TAGBITS 24

module DATA_CACHE(
	// INPUTS
	input [3:0] n,			// from trace file
	input [31:0] add_in,	// from trace file
	
	// OUTPUTS
	output reg [25:0] add_out,	// to next-level cache
	output reg [31:0] hit,		// to statistics module
	output reg [31:0] miss,		// to statistics module
	output reg [31:0] reads
  );

endmodule
