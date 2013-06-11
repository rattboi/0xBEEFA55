/**
* cache interface to read and write to a generic cache
*/

`include "cachepkg.pkg"

interface cacheinterface
   #( parameter DATAWIDTH = 8, 
       parameter ADDRESSWIDTH= 32)
    (input clock);

    import cachepkg::*;

    inst_t operation;
    wire[ADDRESSWIDTH-1:0] addr;
    wire[DATAWIDTH-1:0] data;

    // timing signals - 4 phase signals for variable cache latency
    logic request; 
    logic valid;
    logic evict;

    modport master(
        output operation, 
        inout  addr, 
        inout  data, 
        output request,
        input  valid,
        input  evict,
        input  clock);

    modport slave (
        input  operation, 
        inout  addr, 
        inout  data,
        input  request,
        output valid,
        output evict,
        input  clock);

endinterface

