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
    logic [ADDRESSWIDTH-1:0] addr_in;
    logic [DATAWIDTH-1:0] d_in;
    logic [ADDRESSWIDTH-1:0] addr_out;
    logic [DATAWIDTH-1:0] d_out;

    // control signals - 4 phase signals for variable cache latency
    logic request;
    logic valid;
    logic evict;

    modport master(
        output operation,
        output addr_in,
        output d_in,
        input  addr_out,
        input  d_out,
        output request,
        input  valid,
        input  evict,
        input  clock,
        input  reset);

    modport slave (
        input  operation,
        input  addr_in,
        input  d_in,
        output addr_out,
        output d_out,
        input  request,
        output valid,
        output evict,
        input  clock,
        input  reset);

endinterface

