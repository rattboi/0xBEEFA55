////////////////////////////////////////////////////////////////////////////////
// ECE 510: SystemVerilog
// Portland State University - Spring 2013
// Final Project:
//
// File:    cache.sv
// Authors: Eric Krause, Bradon Kanyid, Tyler Tricker
// Description: it is a cache
//
////////////////////////////////////////////////////////////////////////////////

`include "cachePkg.sv"

module cache( cacheinterface.slave bus );

  import cachePkg::*;

  parameter SETS = 16384;
  parameter WAYS = 2;
  parameter LINEITEMS = 64

  localparam SETBITS = $clog2(SETS);
  localparam LINEBITS = LINEITEMS * $bits(bus.WORD);
  localparam ADDRBITS = $bits(bus.ADDRSPACE);
  localparam WORDBITS = $clog2($bits(bus.WORD));
  localparam TAGBITS = ADDRBITS - SETBITS - LINEBITS - WORDBITS;


  typedef struct {
      bit [$clog2(WAYS):0]lru;
      bit valid;
      bit [TAGBITS-1:0] tag;
      bit [$bits(bus.WORD)-1:0] data[LINEITEMS-1:0];
  } line_t;

  typedef struct {
      line_t [WAYS] way;
  } set_t;

  set_t [SETS-1:0] set;

  // internal
  reg done = 1'b0;

  // assignments
  wire [11:0] curr_tag = add_in[31:20];
  wire [13:0] curr_index = add_in[19:6];

    always @(posedge clk) begin
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
            for (way_cnt = 0; way_cnt < `WAYS; way_cnt = way_cnt + 1'b1)
              if (!done)
                if (Tag[curr_index][way_cnt] == curr_tag)
                begin
                  done                        = TRUE;
                  Valid[curr_index][way_cnt]  = FALSE;
                end
    
    
          INST_FETCH:
          begin
            reads++; // always increment read count
    
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
    
          default: ;  // commands this module doesn't respond to
        endcase
  end

endmodule
