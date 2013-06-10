/**
* cache interface to read and write to a generic cache
*/

`include "cachepkg.sv"

interface cacheinterface
   #( parameter type WORD = logic[7:0], 
       parameter type ADDRSPACE = logic[31:0])
    (input clock);

    import cachepkg::*;

    inst_t operation;
    ADDRSPACE addr;
    WORD data;

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

