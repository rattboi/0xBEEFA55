////////////////////////////////////////////////////////////////////////////////
// ECE 485/585: Microprocessor System Design
// Portland State University - Fall 2012 
// Final Project: 
// 
// File:		PROJECT.v (Top-level wrapper module for project)
// Authors: 
// Description:
//
//
//
////////////////////////////////////////////////////////////////////////////////
module PROJECT(
    );
	
	// parameters
	parameter CLK_WIDTH = 2;
	
	
	reg clk;
	
	// signals from file to caches
	wire [3:0]n;
	wire [31:0]i_add, d_add;
	
	// signals between caches and next-level cache
	wire [511:0] l2_i_data, l2_d_data;
	wire [31:0] l2_i_add, l2_d_add;
	
	// signals to/from stats
	wire i_hit, d_hit, i_miss, d_miss;
	
	// generate clk
	initial 
	begin
		clk = 1'b0;
		forever #(CLK_WIDTH) clk = ~clk;
	end
	
	// do file input and stream to caches

	INS_CACHE Instruction (
    .clk(clk), 
    .n(n), 
    .add_in(i_add), 
    .d_in(l2_d_data), 
	.add_out(l2_i_add),	
    .hit(i_hit), 
    .miss(i_miss)
    );
	
	DATA_CACHE Data (
    .clk(clk), 
    .n(n), 
    .add_in(d_add), 
    .d_in(l2_i_data), 
	.add_out(l2_d_add),
    .hit(d_hit), 
    .miss(d_miss)
    );
	
	L_NEXT L2 (
    .i_add_in(l2_i_add), 
    .d_add_in(l2_d_add), 
    .i_data_out(l2_i_data), 
    .d_data_out(l2_d_data)
    );
	
	STATS Statistics (
    .clk(clk), 
    .n(n), 
    .i_hit(i_hit), 
    .i_miss(i_miss),
    .d_hit(d_hit), 
    .d_miss(d_miss)	
    );


endmodule
