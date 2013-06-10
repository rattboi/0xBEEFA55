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

`include "cachepkg.sv"

//             from lower level cache    to higher level cache
module cache( cacheinterface.slave bus , cacheinterface.master nextbus);

  import cachepkg::*;

  parameter SETS = 16384;
  parameter WAYS = 2;
  parameter LINEITEMS = 64;

  localparam SETBITS  = $clog2(SETS);
  localparam WAYBITS  = $clog2(WAYS);
  localparam LINEBITS = LINEITEMS * $bits(bus.WORD);
  localparam ADDRBITS = $bits(bus.ADDRSPACE);
  localparam WORDBITS = $clog2($bits(bus.WORD));
  localparam TAGBITS  = ADDRBITS - SETBITS - LINEBITS - WORDBITS;

  typedef struct packed{
    valid_t valid;
    bit [WAYBITS-1:0]lru;
    bit [TAGBITS-1:0] tag;
    bit [WORDBITS-1:0] [LINEITEMS-1:0] data;
  } line_t;

  typedef struct packed {
      line_t [WAYS-1:0] way;
  } set_t;

  set_t [SETS-1:0] set;

  // internal
  bool_t done = FALSE;

  // assignments
  alias curr_tag   = bus.addr[(ADDRBITS-1)-:TAGBITS]; // 32 - 3(tag)-14(line)
  alias curr_index = bus.addr[(WORDBITS+LINEBITS):WORDBITS];

  always @(posedge bus.clock)
  begin
      addr = 'z;  //'// always initialize address out to high-z
      operation = NOP;    // default to NOP, if a read happens, it will be updated
      done      = FALSE;  // and set internal done signal to false

      case(bus.operation)

        // invalidate everything in the cache
        RESET: invalidateAll();

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

task invalidateAll();
  for (int i = 0; i < SETS; i++)
    for (int j = 0; j < WAYS; j++)
      set[i].way[j].valid = INVALID;
endtask

endmodule
