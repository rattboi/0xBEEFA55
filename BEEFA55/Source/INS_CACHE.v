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
`define	TAGBITS 12

module INS_CACHE(
	// INPUTS
	input [3:0] n,			// from trace file
	input [31:0] add_in,	// from trace file
	
	input clk,
	// OUTPUTS
	output reg [25:0] add_out = 32'bZ,	// to next-level cache
	output reg [1:0]  cmd_out = 2'b00,			// to next-level cache
	output reg [31:0] hit = 32'b0,		// to statistics module
	output reg [31:0] miss = 32'b0,		// to statistics module
	output reg [31:0] reads	= 32'b0	// to statistics module
  );
  
	parameter TRUE 			= 1'b1;
	parameter FALSE			= 1'b0;
	
	// instruction cache only reponds to following values of n:
	parameter RESET 	 	= 4'd8;
	parameter INVALIDATE 	= 4'd3;
	parameter INST_FETCH 	= 4'd2;
	parameter PRINT			= 4'd9;
	
	// instruction cache sends following commands to next-level cache
	parameter READ_OUT		= 2'b01;
	
//	CACHE ELEMENTS
	// LRU: 1 bit per line. Encoding:  1 = Way 1 is LRU.  0 = Way 0 is LRU
	reg LRU [`LINES-1:0];
	// Valid: 1 bit per way.  Encoding:  1 = Location is valid, 0 = not valid
	reg Valid [`LINES-1:0][`WAYS-1:0];
	// Tag: Tag is of size TAGBITS.  One tag per way.
	reg [`TAGBITS-1:0] Tag [`LINES-1:0][`WAYS-1:0];
	
	// loop counters
	integer line_cnt, way_cnt;
	 
	// internal
	reg done = 1'b0;
	
	// assignments
	wire [11:0] curr_tag = add_in[31:20];
	wire [13:0] curr_index = add_in[19:6];

	always @(posedge clk)
	begin	
		add_out = 26'bZ;	// always initialize address out to high-z
		done	= FALSE;		// and set internal done signal to false
		
		case(n)
			// RESET: iterates through all elements in the cache and 
			RESET:
			begin
				hit 	= 32'b0;
				miss 	= 32'b0;
				reads	= 32'b0;
				
				for (line_cnt = 0; line_cnt < `LINES; line_cnt = line_cnt + 1'b1) 	// for every line
				begin
					LRU[line_cnt] = 1'b0;	
					for (way_cnt = 0; way_cnt < `WAYS; way_cnt = way_cnt + 1'b1)	// for all ways
					begin
						Valid	[line_cnt][way_cnt]	= 1'b0;	
						Tag  	[line_cnt][way_cnt]	= `TAGBITS'b0;
					end
				end
			end
			
			INVALIDATE:
			begin
				for (way_cnt = 0; way_cnt < `WAYS; way_cnt = way_cnt+1'b1)
					if (!done)
						if (Tag[curr_index][way_cnt] == curr_tag)
						begin
							done = 1'b1;
							Valid[curr_index][way_cnt] = 1'b0;
						end
			end	
			
			INST_FETCH:
			begin
				reads = reads + 1'b1;
				
				//	look at all (both) ways.  if for either, the tags match
				//	and the valid bit is set, this is a hit.  on a hit, the 
				//  if(!done) will evaluate false and execution drops through.
				for (way_cnt = 0; way_cnt < `WAYS; way_cnt = way_cnt+1'b1)
				begin
					if (!done)
						if (Tag[curr_index][way_cnt] == curr_tag && Valid[curr_index][way_cnt] == 1'b1)
						begin
							LRU[curr_index] 	= ~way_cnt[0]; // is this logic right? (Yes, I think it is, NOW --rattboi)
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
				for (way_cnt = 0; way_cnt < `WAYS; way_cnt = way_cnt+1'b1)
				begin
					if (!done)
						if (Valid[curr_index][way_cnt] == 1'b0)
						begin
							done 				= 1'b1;
							add_out				= add_in[31:6]; // is this right?
							Tag[curr_index][way_cnt] 	= curr_tag;
							Valid[curr_index][way_cnt]= 1'b1;
							LRU[curr_index] 	= ~way_cnt[0]; 
						end
				end
				
				// reaching this point means an eviction is needed
				// so evict the LRU
				if (!done)
					begin
						add_out	= add_in[31:6]; // is this right?
						Tag[curr_index][LRU[curr_index]] = curr_tag;  
						Valid[curr_index][LRU[curr_index]] = 1'b1; 
						LRU[curr_index] 	= ~LRU[curr_index]; 
					end
				
			end
			
			PRINT:
			begin				
				$display("\n------- INSTRUCTION CACHE CONTENTS -------");
				$display(" Index | LRU | V[0]|Tag[0]| V[1]|Tag[1]");
				for (way_cnt = 0;	way_cnt < `LINES; way_cnt = way_cnt+1)
					if (Valid[way_cnt][0] | Valid[way_cnt][1])
						$display(" %4h  |  %d  |  %d  | %3h  |  %d  | %3h", 
							way_cnt[`LINEBITS-1:0], 
							LRU[way_cnt], 
							Valid[way_cnt][0], 
							Valid[way_cnt][0] ? Tag[way_cnt][0] : `TAGBITS'hX, 
							Valid[way_cnt][1], 
							Valid[way_cnt][1] ? Tag[way_cnt][1] : `TAGBITS'hX
						); 
				$display("--- END OF INSTRUCTION CACHE CONTENTS ----\n");
			end
			
			default: ;	// commands this module doesn't respond to
		endcase
	end		
	
endmodule
