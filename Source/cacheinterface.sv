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

    input clock;
    input reset;

    inst_t operation;
    trireg [ADDRESSWIDTH-1:0] addr;
    trireg [DATAWIDTH-1:0] d;

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

