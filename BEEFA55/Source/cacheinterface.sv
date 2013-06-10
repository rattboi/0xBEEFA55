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

    modport master(
        output operation, 
        output addr, 
        inout  data, 
        output request,
        input  valid,
        input  clock);

    modport slave (
        input  operation, 
        input  addr, 
        inout  data,
        input  request,
        output valid,
        input  clock);

endinterface

