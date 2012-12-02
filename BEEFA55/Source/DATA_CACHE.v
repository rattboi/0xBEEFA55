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
`define	TAGBITS 12

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
	reg [11:0] 			Tag 	[`LINES-1:0] [`WAYS-1:0];
	
	// loop counters
	integer line_cnt,way_cnt;
	 
	// internal
	reg done = 1'b0;
	wire [1:0]lru_way;
	wire [5:0]new_lru;
	reg [5:0]lru_calc_in;
  reg go;
	
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
				writes = 32'b0;
				for (line_cnt = 0; line_cnt < `LINES; line_cnt = line_cnt + 1'b1) 	// for every line
				begin
					LRU[line_cnt] = 6'b0;	
					for (way_cnt = 0; way_cnt < `WAYS; way_cnt = way_cnt + 1'b1)	// for all ways
					begin
						Valid	[line_cnt][way_cnt]	= 1'b0;	
						Tag  	[line_cnt][way_cnt]	= 24'b0;
					end
				end
			end
			
			INVALIDATE:
			begin
				for (way_cnt = 0; way_cnt < `WAYS; way_cnt = way_cnt + 1'b1)
					if (!done)
						if (Tag[curr_index][way_cnt] == curr_tag)
						begin
							done = 1'b1;
							Valid[curr_index][way_cnt] = 1'b0;
						end
			end	
			
			READ:
			begin
				reads = reads + 1'b1;
				for (way_cnt = 0; way_cnt < `WAYS; way_cnt = way_cnt + 1'b1)
				begin
					if (!done)
						if (Tag[curr_index][way_cnt] == curr_tag && Valid[curr_index][way_cnt] == 1'b1)
						begin
							lru_calc_in			= LRU[curr_index];					
							LRU[curr_index] 	= new_lru; // is this logic right? (Yes, I think it is, NOW --rattboi)
							done 				= 1'b1;
							hit 				= hit + 1'b1;
						end
				end	
				
				if (!done)
					miss = miss + 1'b1;
				
				for (way_cnt = 0; way_cnt < `WAYS; way_cnt = way_cnt + 1'b1)
				begin
					if (!done)
						if (Valid[curr_index][way_cnt] == 1'b0)
						begin
							lru_calc_in				= LRU[curr_index];
							go = 1'b1; 
							#1 go = 1'b0;
							done 					= 1'b1;
							add_out					= add_in[31:6]; 
							Tag[curr_index][way_cnt] 		= curr_tag;
							Valid[curr_index][way_cnt]	= 1'b1;
							LRU[curr_index] 		= new_lru;
						end
				end
				
				if (!done)
					
					begin
						lru_calc_in					= LRU[curr_index];
                  go = 1'b1; 
						#1 go = 1'b0;
						add_out						= add_in[31:6]; 
						Tag[curr_index][lru_way] 	= curr_tag;  
						Valid[curr_index][lru_way] 	= 1'b1;   
						LRU[curr_index] 			= new_lru;
					end
			end
			
			WRITE:
			begin
				writes = writes + 1;
				
				for (way_cnt = 0; way_cnt < `WAYS; way_cnt = way_cnt + 1'b1)
				begin
					if (!done)
						if (Tag[curr_index][way_cnt] == curr_tag && Valid[curr_index][way_cnt] == 1'b1)
						begin
							lru_calc_in				= LRU[curr_index];					
                     go = 1'b1; 
							#1 go = 1'b0;
							add_out					= add_in[31:6]; 
							LRU[curr_index] 		= new_lru; // is this logic right? (Yes, I think it is, NOW --rattboi)
							done 					= 1'b1;
							hit 					= hit + 1'b1;
						end
				end	
				
				if (!done)
					miss = miss + 1'b1;
				
				for (way_cnt = 0; way_cnt < `WAYS; way_cnt = way_cnt + 1'b1)
				begin
					if (!done)
						if (Valid[curr_index][way_cnt] == 1'b0)
						begin
							lru_calc_in				= LRU[curr_index];
                     go = 1'b1; 
							#1 go = 1'b0;
							done 					= 1'b1;
							add_out					= add_in[31:6]; 
							Tag[curr_index][way_cnt] 		= curr_tag;
							Valid[curr_index][way_cnt]	= 1'b1;
							LRU[curr_index] 		= new_lru;
							add_out					= add_in[31:6]; 							
						end
				end			

				if (!done)
					begin
						lru_calc_in					= LRU[curr_index];
                  go = 1'b1; 
						#1 go = 1'b0;
						add_out						= add_in[31:6]; 
						Tag[curr_index][lru_way] 	= curr_tag;  
						Valid[curr_index][lru_way] 	= 1'b1;   
						LRU[curr_index] 			= new_lru;
						add_out						= add_in[31:6]; 							
					end
			end
					
			PRINT:
			begin
				$display("----------- DATA CACHE CONTENTS ----------");
				$display(" INDEX | LRU | V[0]|Tag[0]| V[1]|Tag[1]| V[2]|Tag[2]| V[3]|Tag[3]");
				for (way_cnt = 0;	way_cnt < `LINES; way_cnt = way_cnt+1)
				begin
					if (Valid[way_cnt][3] | Valid[way_cnt][2] | Valid[way_cnt][1] | Valid[way_cnt][0] )
					begin
						lru_calc_in	= LRU[way_cnt];
						go = 1'b1; 
						#1 go = 1'b0;
						$display(" %4h  |  %d  |  %d  | %3h  |  %d  | %3h  |  %d  | %3h  |  %d  | %3h", 
							way_cnt[`LINEBITS-1:0], 
							lru_way, 
							Valid[way_cnt][0], 
							Valid[way_cnt][0] ? Tag[way_cnt][0] : `TAGBITS'hX, 
							Valid[way_cnt][1], 
							Valid[way_cnt][1] ? Tag[way_cnt][1] : `TAGBITS'hX,
							Valid[way_cnt][2], 
							Valid[way_cnt][2] ? Tag[way_cnt][2] : `TAGBITS'hX, 
							Valid[way_cnt][3], 
							Valid[way_cnt][3] ? Tag[way_cnt][3] : `TAGBITS'hX							
						); 
					end
				end
				$display("------- END OF DATA CACHE CONTENTS -------");
			end
			
			default: ;	// commands this module doesn't respond to
		endcase		
	end
				
LRU_BITS LRU_CALC (
    .go(go),		   
    .LRU_in(lru_calc_in), 
    .Way(way_cnt[1:0]), 
    .LRU(lru_way), 
    .LRU_out(new_lru)
    );

endmodule

