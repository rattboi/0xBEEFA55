/**
* cache interface to read and write to a generic cache
*/

`include "cachepkg.pkg"

interface cacheinterface
   #( parameter DATAWIDTH = 8,
       parameter ADDRESSWIDTH= 32)
    (clock,
     reset );

    import cachepkg::*;

    inst_t operation;
    tri [ADDRESSWIDTH-1:0] addr;
    tri [DATAWIDTH-1:0] d;

    input clock;
    input reset;

    // control signals - 4 phase signals for variable cache latency
    logic request;
    logic valid;
    logic evict;

    modport master(
        output operation,
        inout  addr,
        inout  d,
        output request,
        input  valid,
        input  evict,
        input  clock,
        input  reset);

    modport slave (
        input  operation,
        inout  addr,
        inout  d,
        input  request,
        output valid,
        output evict,
        input  clock,
        input  reset);

endinterface

