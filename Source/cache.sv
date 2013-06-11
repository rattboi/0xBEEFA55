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

`include "cachepkg.pkg"

//             from lower level cache    to higher level cache
module cache( cacheinterface.slave bus , cacheinterface.master nextlevel);

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
    bool_t dirty;
    bit [WAYBITS-1:0]lru;
    bit [TAGBITS-1:0] tag;
    bit [WORDBITS-1:0] [LINEITEMS-1:0] data;
  } line_t;

  typedef struct packed {
      line_t [WAYS-1:0] way;
  } set_t;

  set_t [SETS-1:0] set;

  state_t state = RESET;
  state_t next  = RESET;

  // advance state on each clock
  always_ff (@ posedge bus.clock or posedge bus.reset)
    state <= (bus.reset) ? RESET : next;

  // next state logics
  always_comb
    if (bus.reset)
    next_st = RESET;  // is this right?

    else
      case(current_st)
        RESET:          next_st = IDLE;

        IDLE:           next_st = (bus.evict) ? EVICT_CONFLICT :
                          (bus.request) ? LOOKUP : IDLE;

        EVICT_CONFLICT: next_st = ( ( exists(set[curr_set], curr_tag) ) &&
                          set[curr_set].way[getway(set[curr_set], curr_tag)].dirty ) ?
                          WRITEBACK : CLEAR_IRQ;

        WRITEBACK:      next_st = CLEAR_IRQ;

        CLEAR_IRQ:      next_st = IDLE;

        LOOKUP:
        MISS:
        GET_NEXT:
        RW:
      endcase

  // outputs
  always_comb
    case(state)
      RESET:
      IDLE:
      EVICT_CONFLICT:
      WRITEBACK:
      CLEAR_IRQ:
      LOOKUP:
      MISS:
      GET_NEXT:
      RW:
    endcase

  task invalidateAll();
    for (int i = 0; i < SETS; i++)
      for (int j = 0; j < WAYS; j++)
        set[i].way[j].valid = INVALID;
  endtask

endmodule
