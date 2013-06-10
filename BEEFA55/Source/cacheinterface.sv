/**
* cache interface to read and write to a generic cache
*/

interface cacheinterface(
    operation,
    addr,
    data);

    import cachepkg::*;

    parameter type WORD      = bit[7:0];
    parameter type ADDRSPACE = bit[31:0];

    inst_t operation;
    ADDRSPACE addr;
    WORD data;

    modport master(output operation, output addr, inout data);
    modport slave (input  operation, input  addr, inout data);


endinterface
