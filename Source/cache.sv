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
  localparam LINEBITS  = LINEITEMS * bus.DATAWIDTH;
  localparam ADDRBITS  = $bits(bus.ADDRESSWIDTH);
  localparam WORDBITS  = $clog2(bus.DATAWIDTH);
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

  // bus assignments
  wire curr_tag   = bus.addr_in[(ADDRBITS-1)-:TAGBITS]; // 32 - 3(tag)-14(line)
  wire curr_index = bus.addr_in[(WORDBITS+LINEBITS-1)-:LINEBITS];
  wire curr_set   = bus.addr_in[(WORDBITS+LINEBITS+SETBITS-1)-:SETBITS];
  wire curr_way   = getway(set[curr_set], curr_tag);

  wire nl_tag   = nextlevel.addr_out[(ADDRBITS-1)-:TAGBITS]; // 32 - 3(tag)-14(line)
  wire nl_index = nextlevel.addr_out[(WORDBITS+LINEBITS-1)-:LINEBITS];
  wire nl_set   = nextlevel.addr_out[(WORDBITS+LINEBITS+SETBITS-1)-:SETBITS];
  wire nl_way   = getway(set[nl_set], nl_tag);

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
        RESET_STATE:    next = (bus.request == RESET_STATE)? RESET_STATE : IDLE;

        IDLE:           next = (nextlevel.evict)        ? EVICT_CONFLICT :
                               (bus.operation == RESET) ? RESET_STATE    :
                               (bus.request)            ? LOOKUP         : IDLE;

        EVICT_CONFLICT: next = (exists(set[nl_set], nl_tag) &&
                               set[nl_set].way[nl_way].dirty == TRUE ) ?
                               WRITEBACK : CLEAR_IRQ;

        WRITEBACK:      next = CLEAR_IRQ;

        CLEAR_IRQ:      next = IDLE;

        LOOKUP:         next = (exists(set[curr_set], curr_tag)) ? RW : MISS;

        MISS:           next = (nextlevel.evict || is_full(set[curr_set])) ?
                                EVICT_CONFLICT : GET_NEXT;

        GET_NEXT:       next = (nextlevel.valid) ? RW : GET_NEXT;

        RW:             next = IDLE;
      endcase

// outputs
  // simple outputs
  assign bus.valid = (state == RW) ? VALID : INVALID;
  assign bus.evict = nextlevel.evict; //(state == MISS || state == EVICT_CONFLICT) ? 1'b1 : 1'b0;
  assign nextlevel.request = (state == WRITEBACK || state == GET_NEXT) ? 1'b1 : 1'b0;

  // not simple outputs
  always_comb
  begin

    {nextlevel.d_in, nextlevel.addr_in} = 'z; //'
    {bus.d_out, bus.addr_out} = 'z; //'
    nextlevel.operation = NOP;


    // nextlevel data and address
    if ( state == WRITEBACK ) // criteria for writes to lower level
    begin
      nextlevel.addr_in = '0; //'
      nextlevel.addr_in[ADDRBITS-1:BYTESEL] = {curr_tag, curr_set, curr_index};
      nextlevel.d_in = set[nl_set].way[nl_way].d;
      nextlevel.operation = WRITE;
    end

    else if ( state == GET_NEXT ) // criteria for reads from lower level
    begin
      nextlevel.addr_in = '0; //'
      nextlevel.addr_in[ADDRBITS-1:BYTESEL] = bus.addr_in[ADDRBITS-1:BYTESEL]; 
      if (bus.operation == WRITE)
        nextlevel.operation = RFO;
      else
        nextlevel.operation = READ;
      set[curr_set].way[empty_way(set[curr_set])].tag = curr_tag;
      set[curr_set].way[curr_way].d = nextlevel.d_in;
      set[curr_set].way[curr_way].dirty = FALSE;
      set[curr_set].way[curr_way].valid = VALID;
    end

    else if ( state == RW ) // criteria for reads/writes from CPU
    begin

      counter_update(curr_way, curr_set);

      if (bus.operation == READ)
        bus.d_out = set[curr_set].way[curr_way].d;
      else if (bus.operation == WRITE)
      begin
        set[curr_set].way[curr_way].d = bus.d_in;
        set[curr_set].way[curr_way].dirty = TRUE;
      end
      else
        $error(1,"RW State w/ neither READ or WRITE op");
    end

    else if ( state == EVICT_CONFLICT )
      ; // no work here

    else if ( state == LOOKUP )
      ; // no work here

    else if ( state == CLEAR_IRQ)
    begin
      if (nextlevel.evict)
        set[nl_set].way[get_victim(nl_set)].valid = INVALID;
      else
        set[curr_set].way[get_victim(curr_set)].valid = INVALID;
    end

    else if ( state == MISS )
    begin

    end


    else if ( state == RESET_STATE)
    begin
      invalidate_all();
      counter_init();
    end
  end

  task automatic invalidate_all();
    // SysV way - broken
    /*
    foreach(set[i])
      foreach(set[i].way[j])
        set[i].way[j].valid = INVALID;
    */

    // Stupid way - works
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
    for (int i = 0; i < SETS; i++)
      for (int j = 0; j < WAYS; j++)
        set[i].way[j].counter= j;
  endtask

  // given way_accessed, updates the counters at cache line given in index
  task automatic counter_update(input int way_accessed, input int index);

    automatic int way_value = set[index].way[way_accessed].counter;

    for (int i = 0; i < WAYS; i++) // increase all counters

      // if a counter is lower than that of the way used, and less than the max
      //   count (saturating counter) then increase it
       if ( set[index].way[i].counter < way_value &&
            set[index].way[i].counter < (WAYS - 1) )
          set[index].way[i].counter++;

       set[index].way[way_accessed].counter = 0; // set way_accessed to 0 (MRU)
  endtask

  function automatic int get_victim(input int index);
    for (int i = 0; i < WAYS; i++)
      if (set[index].way[i].counter == (WAYS-1))
        return i;
  endfunction

  function automatic bool_t is_full(input set_t set);
    foreach (set.way[i])
      if (set.way[i].valid == INVALID)
        return FALSE;

    return TRUE;
  endfunction

  function automatic int empty_way(input set_t set);
    foreach ( set.way[i] )
      if (set.way[i].valid == INVALID)
        return i;

    return -1;
  endfunction

endmodule
