////////////////////////////////////////////////////////////////////////////////
// ECE 485/585: Microprocessor System Design
// Portland State University - Fall 2012 
// Final Project: 
// 
// File:		INS_CACHE.v (Instruction Cache)
// Authors: 
// Description:
//
//
//
////////////////////////////////////////////////////////////////////////////////
`define LINES 8
`define WAYS 2

module INS_CACHE(
	// INPUTS
  input clk,
  input [3:0] n,			// from trace file
  input [31:0] add_in,	// from trace file
  input [511:0] d_in,		// from next-level stub
	
	// OUTPUTS
	output reg [31:0] add_out,	// to next-level cache
  output reg hit,				// to statistics module
  output reg miss				// to statistics module
  );
	
	// instruction cache only reponds to following values of n
	parameter RESET = 4'd8;
	parameter INVALIDATE = 4'd3;
	parameter INST_FETCH = 4'd2;
	
	// instantiate cache
	//	size			lines			ways
	reg 				LRU 	[`LINES-1:0] 			;//  1=LRU is way 1.  0 = LRU way is 0
	reg  				Valid	[`LINES-1:0] [`WAYS-1:0];
	reg [23:0] 	Tag 	[`LINES-1:0] [`WAYS-1:0];
	reg [511:0] Data	[`LINES-1:0] [`WAYS-1:0];
	
	// bit/byte selection
	// Data[2][1] = 512 bit array from line 2, way 1
	// Data[2][1][43] 43rd bit from above data array
	
	// loop counters
	integer i,j;
	
	// internal signals
	reg done = 1'b0;
	
	wire [11:0] curr_tag = add_in[31:20];
	wire [13:0] curr_index = add_in[19:6];
	
	always @*
	begin	
		add_out = 32'bZZZZ_ZZZZ_ZZZZ_ZZZZ_ZZZZ_ZZZZ_ZZZZ_ZZZZ;
		case(n)
			RESET:	// clear all bits in cache
			begin
				done = 1'b0;
				hit = 1'b0;
				miss = 1'b0;
				
				for (i = 0; i < `LINES; i = i+1'b1) 	// for every line
				begin
					LRU[i] = 1'b0;	
					for (j = 0; j < `WAYS; j = i+1'b1)	// for all ways
					begin
						Valid	[i][j]	= 1'b0;	
						Tag  	[i][j]	= 24'b0;
						Data 	[i][j]	= 512'b0;
					end
				end
			end
			
			INVALIDATE:
			begin
				done = 1'b0;
				hit  = 1'b0;
				miss = 1'b0;
				
				for (j = 0; j < `WAYS; j = i+1'b1)			// for all ways
					if (Tag[curr_index][i] == curr_tag)
						Valid[curr_index][i] = 1'b0;
			end	
			
			INST_FETCH:
			begin
				done = 1'b0;
				hit = 1'b0;
				miss = 1'b0;
				
				// hit condition(s) (one for each way)
				// LRU Values:  1=LRU is way 1.  0 = LRU way is 0
				if (Tag[curr_index][0] == curr_tag && Valid[curr_index][0] == 1'b1)
					{hit, LRU[curr_index]} = {1'b1, 1'b1};
				
				else if (Tag[curr_index][1] == curr_tag && Valid[curr_index][1] == 1'b1)
					{hit, LRU[curr_index]} = {1'b1, 1'b0};	
				
				else
				begin
					miss = 1'b1;
					
					for (j = 0; j < `WAYS; j = i+1'b1)  // if one way is empty (invalid) put data there
					begin
						if (!done)
							if (Valid[curr_index][j] == 1'b0)
							begin
								done = 1'b1;
								add_out = add_in;
								Tag[curr_index][j] = curr_tag;  
								Data[curr_index][j] = d_in;     
								Valid[curr_index][j] = 1'b1;
							end
					end
					
					if (!done) // both ways were full... LRU gets the data
					begin
						add_out = add_in;
						Tag[curr_index][LRU[curr_index]] = curr_tag;  
						Data[curr_index][LRU[curr_index]] = d_in;     
						// Valid[curr_index][LRU] == 1'b1;   
					end
				end
			end
					
			default:	// commands this module doesn't respond to
			begin
				done = 1'b0;
				hit = 1'b0;
				miss = 1'b0;
			end
		endcase
	end		
	
endmodule
