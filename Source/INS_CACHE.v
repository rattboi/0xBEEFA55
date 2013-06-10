////////////////////////////////////////////////////////////////////////////////
// ECE 485/585: Microprocessor System Design
// Portland State University - Fall 2012 
// Final Project: 
// 
// File:    INS_CACHE.v 
// Authors: Andy Goetz, Bradon Kanyid, Eric Krause, and Kevin Riedl
// Description: Simulates an instruction cache.
//
////////////////////////////////////////////////////////////////////////////////
`define SETS 1024*16
`define WAYS 2
`define SETBITS 14
`define  TAGBITS 12

module INS_CACHE(
  // INPUTS
  input [3:0]  n,        // from trace file
  input [31:0] add_in,  // from trace file
  input clk,
  
  // OUTPUTS
  output reg [25:0] add_out = 26'bZ,  // to next-level cache
  output reg [1:0]  cmd_out = NOP,    // to next-level cache
  output reg [31:0] hit     = 32'b0,  // to statistics module
  output reg [31:0] miss    = 32'b0,  // to statistics module
  output reg [31:0] reads    = 32'b0    // to statistics module
  );
  
  parameter TRUE       = 1'b1;
  parameter FALSE      = 1'b0;
  
  // instruction cache only reponds to following values of n:
  parameter RESET        = 4'd8;
  parameter INVALIDATE   = 4'd3;
  parameter INST_FETCH   = 4'd2;
  parameter PRINT        = 4'd9;
  
  // instruction cache sends following commands to next-level cache
  parameter READ_OUT    = 2'b01;
  parameter NOP         = 2'b00;
  
  // CACHE ELEMENTS
  // LRU: 1 bit per set. Encoding:  1 = Way 1 is LRU.  0 = Way 0 is LRU
  reg LRU [`SETS-1:0];
  // Valid: 1 bit per way.  Encoding:  1 = way is valid, 0 = not valid
  reg Valid [`SETS-1:0][`WAYS-1:0];
  // Tag: Tag is of size TAGBITS.  One tag per way.
  reg [`TAGBITS-1:0] Tag [`SETS-1:0][`WAYS-1:0];
  
  // loop counters
  integer set_cnt, way_cnt;
   
  // internal
  reg done = 1'b0;
  
  // assignments
  wire [11:0] curr_tag = add_in[31:20];
  wire [13:0] curr_index = add_in[19:6];

  always @(posedge clk)
  begin  
    add_out = 26'bZ;  // always initialize address out to high-z
    cmd_out = NOP;    // default to NOP, if a read happens, it will be updated
    done    = FALSE;  // and set internal done signal to false
    
    case(n)
      // RESET: iterates through all elements in the cache and sets
      //    everything to 0.  Also initializes hit/miss/read counters.
      RESET:
      begin
        hit    = 32'b0;
        miss   = 32'b0;
        reads  = 32'b0;
        
        // for every set... 
        for (set_cnt = 0; set_cnt < `SETS; set_cnt = set_cnt + 1'b1) 
        begin
          LRU[set_cnt] = 1'b0;  // set the LRU to 0
          // for each way of set...
          for (way_cnt = 0; way_cnt < `WAYS; way_cnt = way_cnt + 1'b1) 
          begin
            // clear valid and tag bits. 
            Valid  [set_cnt][way_cnt]  = FALSE;  
            Tag    [set_cnt][way_cnt]  = `TAGBITS'b0;
          end
        end
      end
      
      
      // INVALIDATE: use address passed in with invalidate command as an 
      //    index to a given line.  Then, invalidate the line for which the
      //    stored tag equals the tag passed in add_in.
      INVALIDATE:
      begin
        for (way_cnt = 0; way_cnt < `WAYS; way_cnt = way_cnt + 1'b1)
        begin
          if (!done)
          begin
            if (Tag[curr_index][way_cnt] == curr_tag)
            begin
              done                        = TRUE;
              Valid[curr_index][way_cnt]  = FALSE;
            end
          end
        end
      end  
      
      
      INST_FETCH:
      begin
        reads = reads + 1'b1;  // always increment read count
        
        // First, look at both lines.  if for either, the tags match
        //    and the line is valid, then the read was a hit.  done 
        //    is set to true, and execution will drop through the rest 
        //    of the INST_FETCH routine.
        for (way_cnt = 0; way_cnt < `WAYS; way_cnt = way_cnt + 1'b1)
        begin
          if (done == FALSE)
            if (Tag[curr_index][way_cnt] == curr_tag &&
                Valid[curr_index][way_cnt] == TRUE)
            begin
              LRU[curr_index] = ~way_cnt[0];
              hit             = hit + 1'b1;
              done             = TRUE;
            end
          else ;
        end
        
        //  at this point, if done is still false, then the fetch was not a hit.
        if (done == FALSE)
          miss = miss + 1'b1;
        
        // Next, look at both lines.  If either is empty then 
        //    do a read and and put result in the empty line, then set
        //    done to true, and execution will drop through the rest of 
        //    the INST_FETCH routine. 
        for (way_cnt = 0; way_cnt < `WAYS; way_cnt = way_cnt + 1'b1)
        begin
          if (done == FALSE)
            if (Valid[curr_index][way_cnt] == FALSE)
            begin
              // set L_NEXT command/address
              add_out                      = add_in[31:6]; // perform read
              cmd_out                      = READ_OUT;     // perform read

              Tag[curr_index][way_cnt]     = curr_tag;
              Valid[curr_index][way_cnt]   = TRUE;
              LRU[curr_index]              = ~way_cnt[0]; 
              done                         = TRUE;
            end
        end
        
        // Reaching this point means an eviction is needed because the
        //    instruction fetch was a miss, and there was no empty line
        //    in which to put the incoming read.  So evict the LRU
        if (done == FALSE)
          begin
            // set L_NEXT command/address
            add_out                              = add_in[31:6]; // perform read
            cmd_out                              = READ_OUT;     // perform read

            Tag[curr_index][LRU[curr_index]]    = curr_tag;  
            LRU[curr_index]                     = ~LRU[curr_index]; 
          end
      end
    
      PRINT:
      begin    
        // print header      
        $display("\n------- INSTRUCTION CACHE CONTENTS -------");
        $display(" Index | LRU | V[0]|Tag[0]| V[1]|Tag[1]");
        // cycle through all of the ways within a set
        for (way_cnt = 0;  way_cnt < `SETS; way_cnt = way_cnt+1)
        begin
          // print out the whole set if there are any valid lines
          if (Valid[way_cnt][0] | Valid[way_cnt][1])
          begin
            $display(" %4h  |  %d  |  %d  | %3h  |  %d  | %3h", 
              way_cnt[`SETBITS-1:0], 
              LRU[way_cnt], 
              Valid[way_cnt][0],
              // print X's if invalid
              Valid[way_cnt][0] ? Tag[way_cnt][0] : `TAGBITS'hX,
              Valid[way_cnt][1],
              // print X's if invalid
              Valid[way_cnt][1] ? Tag[way_cnt][1] : `TAGBITS'hX  
            ); 
          end
        end
        $display("--- END OF INSTRUCTION CACHE CONTENTS ----\n");
      end
      
      default: ;  // commands this module doesn't respond to
    endcase
  end    
  
endmodule
