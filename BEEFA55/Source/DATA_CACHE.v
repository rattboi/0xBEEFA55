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
`define WAYS 4
`define LINEBITS 14
`define	TAGBITS 24

module DATA_CACHE(
	// INPUTS
	input [3:0] n,			// from trace file
	input [31:0] add_in,	// from trace file
	input clk,
	
	// OUTPUTS
	output reg [25:0] add_out,	// to next-level cache
	output reg [31:0] hit,		// to statistics module
	output reg [31:0] miss,		// to statistics module
	output reg [31:0] reads,
	output reg [31:0] writes
  );
  
	// instruction cache only reponds to following values of n
	parameter RESET 	 	= 4'd8;
	parameter INVALIDATE 	= 4'd3;
	parameter READ		 	= 4'd0;
	parameter WRITE			= 4'd1;
	parameter PRINT			= 4'd9;
	
	// instantiate cache elements
	//	size					lines			ways
	reg [5:0]			LRU 	[`LINES-1:0] 			;//  1=LRU is way 1.  0 = LRU way is 0
	reg  				Valid	[`LINES-1:0] [`WAYS-1:0];
	reg [23:0] 			Tag 	[`LINES-1:0] [`WAYS-1:0];
	
	// loop counters
	integer i,j;
	 
	// internal
	reg done = 1'b0;
	reg [1:0]lru_way;
	reg [5:0]new_lru;
	
	// assignments
	wire [11:0] curr_tag = add_in[31:20];
	wire [13:0] curr_index = add_in[19:6];
	
	
	always @*
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
					LRU[i] = 6'b0;	
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
			
			READ:
			begin
				reads = reads + 1'b1;
				for (j = 0; j < `WAYS; j = j+1'b1)
				begin
					if (!done)
						if (Tag[curr_index][j] == curr_tag && Valid[curr_index][j] == 1'b1)
						begin
							LRU[curr_index] 	= new_lru; // is this logic right? (Yes, I think it is, NOW --rattboi)
							done 				= 1'b1;
							hit 				= hit + 1'b1;
						end
				end	
				
				if (!done)
					miss = miss + 1'b1;
				
				for (j = 0; j < `WAYS; j = j+1'b1)
				begin
					if (!done)
						if (Valid[curr_index][j] == 1'b0)
						begin
							done 					= 1'b1;
							add_out					= add_in[31:6]; 
							Tag[curr_index][j] 		= curr_tag;
							Valid[curr_index][j]	= 1'b1;
							LRU[curr_index] 		= new_lru;
						end
				end
				
				if (!done)
					begin
						add_out						= add_in[31:6]; 
						Tag[curr_index][lru_way] 	= curr_tag;  
						Valid[curr_index][lru_way] 	= 1'b1;   
						LRU[curr_index] 			= new_lru;
					end
			end
			
			WRITE:
			begin
				writes = writes + 1;
				
				for (j = 0; j < `WAYS; j = j+1'b1)
				begin
					if (!done)
						if (Tag[curr_index][j] == curr_tag && Valid[curr_index][j] == 1'b1)
						begin
							add_out					= add_in[31:6]; 
							LRU[curr_index] 		= new_lru; // is this logic right? (Yes, I think it is, NOW --rattboi)
							done 					= 1'b1;
							hit 					= hit + 1'b1;
						end
				end	
				
				if (!done)
					miss = miss + 1'b1;
				
				for (j = 0; j < `WAYS; j = j+1'b1)
				begin
					if (!done)
						if (Valid[curr_index][j] == 1'b0)
						begin
							done 					= 1'b1;
							add_out					= add_in[31:6]; 
							Tag[curr_index][j] 		= curr_tag;
							Valid[curr_index][j]	= 1'b1;
							LRU[curr_index] 		= new_lru;
							add_out					= add_in[31:6]; 							
						end
				end			

				if (!done)
					begin
						add_out						= add_in[31:6]; 
						Tag[curr_index][lru_way] 	= curr_tag;  
						Valid[curr_index][lru_way] 	= 1'b1;   
						LRU[curr_index] 			= new_lru;
						add_out						= add_in[31:6]; 							
					end
					
			PRINT:
			begin
			//	$display("--- END OF INSTRUCTION CACHE CONTENTS ----");
				$display("----------- DATA CACHE CONTENTS ----------");
				$display(" INDEX | LRU | V[3]| Tag[3] | V[2]| Tag[2]| V[1]| Tag[1] | V[0]| Tag[0]");
				for (j = 0;	j < `LINES; j = j+1)
					if (Valid[j][0] | Valid[j][1])
						$display(" %4h  |  %d  |  %d  | %6h |  %d  | %6h |  %d  | %6h |  %d  | %6h", 
							j[`LINEBITS-1:0], 
							lru_way, 
							Valid[j][3], 
							Valid[j][3] ? Tag[j][3] : `TAGBITS'hX, 
							Valid[j][2], 
							Valid[j][2] ? Tag[j][2] : `TAGBITS'hX
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
				
LRU_BITS LRU_CALC (
    .LRU_in(LRU[curr_index]), 
    .Way(j[1:0]), 
    .LRU(lru_way), 
    .LRU_out(new_lru)
    );


				
endmodule

