/**
* cache interface to read and write to a generic cache
*/

interface cacheinterface(
    operation,
    addr,
    data,
    clock
);

    import cachepkg::*;

    parameter type WORD      = bit[7:0];
    parameter type ADDRSPACE = bit[31:0];

    parameter cas_latency = 1;

    inst_t operation;
    ADDRSPACE addr;
    WORD data;
    bit clock;

    modport master(output operation, output addr, inout data, input clock);
    modport slave (input  operation, input  addr, inout data, input clock);

endinterface
