////////////////////////////////////////////////////////////////////////////////
// ECE 485/585: Microprocessor System Design
// Portland State University - Fall 2012 
// Final Project: 
// 
// File:    PROJECT.v (Top-level wrapper module for project)
// Authors: 
// Description:
//
////////////////////////////////////////////////////////////////////////////////
module PROJECT(
  input clk, 
  input clear, 
  input [3:0] n, 
  input [31:0] add_in,
  input done,
  output reg [25:0] add_out,
  output reg [1:0]  cmd_out
  );

  // valid commands from tracefile
  parameter RESET       = 4'd8;
  parameter INVALIDATE  = 4'd3;
  parameter READ        = 4'd0;
  parameter WRITE       = 4'd1;
  parameter INST_FETCH 	= 4'd2;
  parameter PRINT       = 4'd9;

  // signals from file to caches
  wire [31:0] i_add, d_add;
  assign i_add = add_in;
  assign d_add = add_in;

  // signals between caches and next-level cache
  wire [1:0]   l2_i_cmd, l2_d_cmd;
  wire [25:0]  l2_i_add,  l2_d_add;

  // signals to/from stats
  wire [31:0] i_hit;
  wire [31:0] d_hit;
  wire [31:0] i_miss;
  wire [31:0] d_miss;
  wire [31:0] i_reads;
  wire [31:0] d_reads;
  wire [31:0] d_writes;

  //mux the L2 outputs
  always @(n)
  begin
		if(n == INST_FETCH)
    begin
      add_out = l2_i_add;
      cmd_out = l2_i_cmd;
    end
		else
    begin
      add_out = l2_d_add;
      cmd_out = l2_d_cmd;
    end
  end

	INS_CACHE i_cache (
		.clk(clk), 
		.n(n), 
		.add_in(add_in), 
		.add_out(l2_i_add),  
		.cmd_out(l2_i_cmd),  
		.hit(i_hit), 
		.miss(i_miss),
		.reads(i_reads)
		);

	DATA_CACHE d_cache (
		.n(n), 
		.add_in(add_in), 
		.clk(clk), 
		.add_out(l2_d_add), 
		.cmd_out(l2_d_cmd), 
		.hit(d_hit), 
		.miss(d_miss), 
		.reads(d_reads), 
		.writes(d_writes)
		);

	STATS stats(
		.print(done),
		.ins_reads(i_reads),
		.ins_hit(i_hit),
		.ins_miss(i_miss),
		.data_reads(d_reads),
		.data_writes(d_writes),
		.data_hit(d_hit),
		.data_miss(d_miss)
		);

endmodule
