////////////////////////////////////////////////////////////////////////////////
// ECE 510: SystemVerilog
// Portland State University - Spring 2013
// Final Project:
//
// File:    top.sv
// Authors: Eric Krause, Bradon Kanyid, Tyler Tricker
// Description: dut
//
////////////////////////////////////////////////////////////////////////////////

module testbench();

    import cachepkg::*;

    bit clock = 0;
    initial forever #10 clock++;

    clocking cb @(posedge clock);
        default input #2ps output #1ps;
    endclocking

    // testing parameters
    localparam type WORD      = logic[7:0];
    localparam type ADDRSPACE = logic[31:0];

    // from cpu
    cacheinterface #(.WORD(WORD), .ADDRSPACE(ADDRSPACE))
        datainf (clock);

    cacheinterface #(.WORD(WORD), .ADDRSPACE(ADDRSPACE)) 
        data_next (clock);

    cacheinterface #(.WORD(WORD), .ADDRSPACE(ADDRSPACE))
        instructioninf (clock);

    cacheinterface #(.WORD(WORD), .ADDRSPACE(ADDRSPACE))
        instruction_next (clock);

    // program driving the test simulation data
    tracedriver(datainf, data_next, instructioninf, instruction_next);

    // checker modules
    //bind data_cache        cachechecker chkdata(); 
    //bind instruction_cache cachechecker chkinstr(); 

    // monitor modules - counts statistics on cache hits and evictions


    cache data_cache(bus.slave);
    cache instruction_cache(bus.slave);


endmodule
