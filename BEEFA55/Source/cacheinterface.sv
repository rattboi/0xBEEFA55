/**
* cache interface to read and write to a generic cache
*/

`include "cachepkg.sv"

interface cacheinterface
#( parameter type WORD = logic[7:0], 
   parameter type ADDRSPACE = logic[31:0],
   parameter cas_latency = 1
)
(
    inst_t operation,
    ADDRSPACE addr,
    WORD data,
    logic clock
);

    import cachepkg::*;

    modport master(output operation, output addr, inout data, input clock);
    modport slave (input  operation, input  addr, inout data, input clock);

endinterface
