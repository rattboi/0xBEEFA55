////////////////////////////////////////////////////////////////////////////////
// ECE 485/585: Microprocessor System Design
// Portland State University - Fall 2012 
// Final Project: 
// 
// File:		L_NEXT.v (Next Level Cache/Memory stub)
// Authors: 
// Description:
//
//
//
////////////////////////////////////////////////////////////////////////////////
module L_NEXT(
	// INPUTS
    input [25:0]  i_add_in,		// instruction cache address in
	input [25:0]  d_add_in,		// data cache address in
	
	// OUTPUTS
    output [511:0] i_data_out,	// function of i_add_in
    output [511:0] d_data_out	// function of d_add_in
    );
	
	assign i_data_out = { i_add_in, 6'd0,
						  i_add_in, 6'd1,
                          i_add_in, 6'd2,
                          i_add_in, 6'd3,
                          i_add_in, 6'd4,
                          i_add_in, 6'd5,
                          i_add_in, 6'd6,
                          i_add_in, 6'd7,
                          i_add_in, 6'd8,
                          i_add_in, 6'd9,
                          i_add_in, 6'd10,
                          i_add_in, 6'd11,
                          i_add_in, 6'd12,
                          i_add_in, 6'd13,
                          i_add_in, 6'd14,
                          i_add_in, 6'd15};

	assign d_data_out = { d_add_in, 6'd0,
						  d_add_in, 6'd1,
                          d_add_in, 6'd2,
                          d_add_in, 6'd3,
                          d_add_in, 6'd4,
                          d_add_in, 6'd5,
                          d_add_in, 6'd6,
                          d_add_in, 6'd7,
                          d_add_in, 6'd8,
                          d_add_in, 6'd9,
                          d_add_in, 6'd10,
                          d_add_in, 6'd11,
                          d_add_in, 6'd12,
                          d_add_in, 6'd13,
                          d_add_in, 6'd14,
                          d_add_in, 6'd15};				  
endmodule
