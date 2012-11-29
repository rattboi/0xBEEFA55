////////////////////////////////////////////////////////////////////////////////
// ECE 485/585: Microprocessor System Design
// Portland State University - Fall 2012 
// Final Project: 
// 
// File:		N_BUFF.v (n buffer)
// Authors: 
// Description: prevents interleaving output on print command.
//
//
//
////////////////////////////////////////////////////////////////////////////////
module N_BUFF(
	input n,
	output reg [3:0] ni,
	output reg [3:0] nd,
	output reg ns
	);
	
	always @*
	begin
		if (n==4'd9)
		begin
			   {ni, nd, ns} = {4'd9,	4'bZZZZ,	1'b0};
			#1 {ni, nd, ns} = {4'bZZZZ,	4'd9,		1'b0};
			#1 {ni, nd, ns} = {4'bZZZZ,	4'bZZZZ,	1'b1};
			#1 {ni, nd, ns} = {4'bZZZZ,	4'bZZZZ,	1'b0}
		end
	
		else
			{ni, nd, ns} = {n, n, 1'b0};
	end