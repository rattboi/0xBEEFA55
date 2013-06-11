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

  localparam SETBITS   = $clog2(SETS);
  localparam WAYBITS   = $clog2(WAYS);
  localparam LINEBITS  = LINEITEMS * $bits(bus.WORD);
  localparam ADDRBITS  = $bits(bus.ADDRSPACE);
  localparam WORDBITS  = $clog2($bits(bus.WORD));
  localparam TAGBITS   = ADDRBITS - SETBITS - LINEBITS - WORDBITS;
  localparam BYTESEL   = ADDRBITS - (TAGBITS+SETBITS+LINEBITS);
  localparam TIMERBITS = $clog2(WAYS);

  typedef struct packed{
    bit [TIMERBITS-1:0] counter;
    valid_t valid;
    bool_t dirty;
    bit [TAGBITS-1:0] tag;
    bit [WORDBITS-1:0] [LINEITEMS-1:0] d;
  } line_t;

  typedef struct packed {
      line_t [WAYS-1:0] way;
  } set_t;

  set_t [SETS-1:0] set;

  // assignments
  wire curr_tag   = bus.addr[(ADDRBITS-1)-:TAGBITS]; // 32 - 3(tag)-14(line)
  wire curr_index = bus.addr[(WORDBITS+LINEBITS-1)-:LINEBITS];
  wire curr_set   = bus.addr[(WORDBITS+LINEBITS+SETBITS-1)-:SETBITS];
  wire curr_way = getway(set[curr_set], curr_tag);

  state_t state = RESET_STATE;
  state_t next  = RESET_STATE;

// advance state on each clock
  always_ff @(posedge bus.clock or posedge bus.reset)
    state <= (bus.reset) ? RESET_STATE : next;

// next state logics
  always_comb
    if (bus.reset)
      next = RESET_STATE;  // is this right?
    else
      case(state)
        RESET_STATE:    next = IDLE;

        IDLE:           next = (bus.evict) ? EVICT_CONFLICT :
                               (bus.request) ? LOOKUP : IDLE;

        EVICT_CONFLICT: next = (exists(set[curr_set], curr_tag) &&
                               set[curr_set].way[curr_way].dirty ) ?
                               WRITEBACK : CLEAR_IRQ;

        WRITEBACK:      next = CLEAR_IRQ;

        CLEAR_IRQ:      next = IDLE;

        LOOKUP:         next = (exists(set[curr_set], curr_tag)) ? RW : MISS;

        MISS:           next = (bus.invalidate) ? EVICT_CONFLICT : GET_NEXT;

        GET_NEXT:       next = RW;

        RW:             next = IDLE;
      endcase


// outputs
  // simple outputs
  assign bus.valid = (state == RW) ? 1'b1 : 1'b0;
  assign bus.evict = (state == MISS || state == EVICT_CONFLICT) ? 1'b1 : 1'b0;
  assign nextlevel.request = (state == WRITEBACK || state == GET_NEXT) ? 1'b1 : 1'b0;

  // not simple outputs
  always_comb
  begin
    // nextlevel data and address
    if ( state == WRITEBACK || state == GET_NEXT ) // criteria for writes
    begin
      nextlevel.d    = set[curr_set].way[curr_way].d;
      nextlevel.addr = '0; //'
      nextlevel.addr[ADDRBITS-1:BYTESEL] = {curr_tag, curr_set, curr_index};
    end

    else if ( state == RW ) // criteria for reads
    begin
      set[curr_set].way[curr_way].d = nextlevel.d;
      nextlevel.addr = '0; //'
      nextlevel.addr[ADDRBITS-1:BYTESEL] = {curr_tag, curr_set, curr_index};
    end

    else // otherwise, tristate both address and data
      {nextlevel.d, nextlevel.addr} = 'z; //'


  end


  task automatic invalidateAll();
    // TODO: choose one of these
    // SysV way
    foreach(set[i])
      foreach(set[i].way[j])
        set[i].way[j].valid = INVALID;

    // Stupid way
    for (int i = 0; i < SETS; i++)
      for (int j = 0; j < WAYS; j++)
        set[i].way[j].valid = INVALID;
  endtask

  // returns true if the tag is found in a set
  function automatic bool_t exists(input set_t set, input bit [TAGBITS-1:0] tag);
    foreach(set.way[i])
    begin
      if (set.way[i].tag == tag)
      begin
        if (set.way[i].valid == VALID)
          return TRUE;
        else
          return FALSE;
      end
    end
    return FALSE;
  endfunction

  // returns an index indicating which way has the shit
  function automatic int getway(input set_t set, input bit [TAGBITS-1:0] tag);
    foreach(set.way[i]) begin
      if (set.way[i].tag == tag)
        return i;
    end
    return -1;  //probably not necessary
  endfunction


  task automatic counter_init();
    foreach(set[i])
      foreach(set[i].way[j])
        set[i].way[j].counter = j;
  endtask

// given way_accessed, updates the counters at cache line given in index
  task automatic counter_update(input int way_accessed, input int index);

    automatic int way_value = set[curr_set].way[way_accessed].counter;

    for (int i = 0; i < WAYS; i++) // increase all counters

      // if a counter is lower than that of the way used, and less than the max
      //   count (saturating counter) then increase it
       if ( set[curr_set].way[i].counter < way_value &&
            set[curr_set].way[i].counter < (WAYS - 1) )
        set[curr_set].way[i].counter++;

       set[curr_set].way[way_accessed].counter = 0; // set way_accessed to 0 (MRU)
  endtask

  function automatic int get_victim(input int index);
    for (int i = 0; i < WAYS; i++)
      if (set[curr_set].way[i].counter == (WAYS-1))
        return i;
  endfunction

endmodule
