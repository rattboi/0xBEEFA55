////////////////////////////////////////////////////////////////////////////////
// ECE 485/585: Microprocessor System Design
// Portland State University - Fall 2012 
// Final Project: 
// 
// File:		INS_CACHE.v (Instruction Cache)
// Authors: 
// Description:
//
////////////////////////////////////////////////////////////////////////////////
`define LINES 1024*16
`define WAYS 2
`define LINEBITS 14
`define	TAGBITS 24

module INS_CACHE(
	// INPUTS
	input [3:0] n,			// from trace file
	input [31:0] add_in,	// from trace file
	input clk,
	// OUTPUTS
	output reg [25:0] add_out,	// to next-level cache
	output reg [31:0] hit,		// to statistics module
	output reg [31:0] miss,		// to statistics module
	output reg [31:0] reads
  );
	
	// instruction cache only reponds to following values of n
	parameter RESET 	 	= 4'd8;
	parameter INVALIDATE 	= 4'd3;
	parameter INST_FETCH 	= 4'd2;
	parameter PRINT			= 4'd9;
	
	initial begin
	hit = 0;
	miss = 0;
	reads = 0;
	end
	
	// instantiate cache elements
	//	size					lines			ways
	reg 				LRU 	[`LINES-1:0] 			;//  1=LRU is way 1.  0 = LRU way is 0
	reg  				Valid	[`LINES-1:0] [`WAYS-1:0];
	reg [23:0] 			Tag 	[`LINES-1:0] [`WAYS-1:0];
	
	// loop counters
	integer i,j;
	 
	// internal
	reg done = 1'b0;
	
	// assignments
	wire [11:0] curr_tag = add_in[31:20];
	wire [13:0] curr_index = add_in[19:6];
	 
	always @(posedge clk)
	begin	
		add_out = 26'bZ;
		done	= 1'b0;
				
		case(n)
			RESET:	// clear all bits in cache
			begin
				hit 	= 32'b0;
				miss 	= 32'b0;
				reads	= 32'b0;
				
				for (i = 0; i < `LINES; i = i+1'b1) 	// for every line
				begin
					LRU[i] = 1'b0;	
					for (j = 0; j < `WAYS; j = j+1'b1)	// for all ways
					begin
						Valid	[i][j]	= 1'b0;	
						Tag  	[i][j]	= 24'b0;
					end
				end
			end
			
			INVALIDATE:
			begin
				for (j = 0; j < `WAYS; j = j+1'b1)
					if (!done)
						if (Tag[curr_index][j] == curr_tag)
						begin
							done = 1'b1;
							Valid[curr_index][j] = 1'b0;
						end
			end	
			
			INST_FETCH:
			begin
				reads = reads + 1'b1;
				
				//	look at all (both) ways.  if for either, the tags match
				//	and the valid bit is set, this is a hit.  on a hit, the 
				//  if(!done) will evaluate false and execution drops through.
				for (j = 0; j < `WAYS; j = j+1'b1)
				begin
					if (!done)
						if (Tag[curr_index][j] == curr_tag && Valid[curr_index][j] == 1'b1)
						begin
							LRU[curr_index] 	= ~j[0]; // is this logic right? (Yes, I think it is, NOW --rattboi)
							done 				= 1'b1;
							hit 				= hit + 1'b1;
						end
					else ;
				end
				
				//	if execution exits this loop and done still == 0, then 
				// 	the ins. fetch was not a hit.  so increase miss.	
				if (!done)
					miss = miss + 1'b1;
				
				// look at both ways.  If either is empty (valid == 0) then 
				// do a read and and put it in the empty way.  If this happens,
				// done is set true, and execution will drop out of the loop.
				for (j = 0; j < `WAYS; j = j+1'b1)
				begin
					if (!done)
						if (Valid[curr_index][j] == 1'b0)
						begin
							done 				= 1'b1;
							add_out				= add_in[31:6]; // is this right?
							Tag[curr_index][j] 	= curr_tag;
							Valid[curr_index][j]= 1'b1;
						end
				end
				
				// reaching this point means an eviction is needed
				// so evict the LRU
				if (!done)
					begin
						add_out	= add_in[31:6]; // is this right?
						Tag[curr_index][LRU[curr_index]] = curr_tag;  
						Valid[curr_index][LRU[curr_index]] = 1'b1;   
					end
				
			end
			
			PRINT:
			begin
				$display("------- INSTRUCTION CACHE CONTENTS -------");
				$display(" LINE  | LRU | V[1]| Tag[1] | V[0]| Tag[0]");
				for (j = 0;	j < `LINES; j = j+1)
					if (Valid[j][0] | Valid[j][1])
						$display(" %4h  |  %d  |  %d  | %6h |  %d  | %6h", 
							j[`LINEBITS-1:0], 
							LRU[j], 
							Valid[j][1], 
							Valid[j][1] ? Tag[j][1] : `TAGBITS'hX, 
							Valid[j][0], 
							Valid[j][0] ? Tag[j][0] : `TAGBITS'hX
						); 
				$display("--- END OF INSTRUCTION CACHE CONTENTS ----");
			end
			
			default: ;	// commands this module doesn't respond to
		endcase
	end		
	
endmodule
