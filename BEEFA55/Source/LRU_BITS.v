// Bradon Kanyid
// ECE485
//
// LRU_BITS
//
// Defines a funky LRU scheme for a cache
//

module LRU_BITS(LRU_in, Way, LRU, LRU_out, go);
input      [5:0] LRU_in;
input      [1:0] Way;
output reg [1:0] LRU;
output reg [5:0] LRU_out;
input go;

//
// LRU depends only upon old LRU (Moore machine)
//

	always @(posedge go)
	begin
	  casex(LRU_in)
		6'b000xxx: LRU = 2'd0; // LRU 0 - bits 0,1,2 clear 
		6'b1xx00x: LRU = 2'd1; // LRU 1 - bit  0 set, bit 3,4 clear 
		6'bx1x1x0: LRU = 2'd2; // LRU 2 - bits 1,3 set, bit 5 clear
		6'bxx1x11: LRU = 2'd3; // LRU 3 - bits 2,4,5 set 
	  endcase
	  
	  case (Way)
		  // Set the first 3 bits (this defines MRU 0)
		  2'd0: LRU_out = (LRU_in | 6'b111000);  

		  // Clear bit 0, Set bits 3 & 4 (MRU 1)
		  2'd1: LRU_out = ((LRU_in & 6'b011111) | 6'b000110); 
		  
		  // Clear bits 1 & 3, Set bit 5 (MRU 2)
		  2'd2: LRU_out = ((LRU_in & 6'b101011) | 6'b000001); 

		  // Clear bits 2,4,5 (MRU 3)
		  2'd3: LRU_out = (LRU_in & 6'b110100);  
		endcase
	end
endmodule
