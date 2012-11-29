////////////////////////////////////////////////////////////////////////////////
// ECE 485/585: Microprocessor System Design
// Portland State University - Fall 2012 
// Final Project: 
// 
// File:		STATS.v (Statistics Module aka It's a series of counters)
// Authors: 
// Description:
//
////////////////////////////////////////////////////////////////////////////////
module STATS(
	// INPUTS
    input print,			// mux to determine reads/writes
    input [31:0] ins_reads,
	input [31:0] ins_hit,
	input [31:0] ins_miss,
	
	input [31:0] data_reads,
	input [31:0] data_writes,
	input [31:0] data_hit,
	input [31:0] data_miss
    );
	
	always @(posedge print)
	begin
		$display(" STATISTICS: ");
		$display(" Hits = %d", data_hit + ins_hit);
		$display(" Miss = %d", data_miss + ins_miss);
		$display(" Reads = %d", data_reads + ins_reads);
		$display(" Writes = %d", data_writes);
		$display(" Hit Ratio = %f", (data_hit + ins_hit)/(data_reads + ins_reads + data_writes));
	end	
endmodule
