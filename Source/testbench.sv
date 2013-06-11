////////////////////////////////////////////////////////////////////////////////
// ECE 510: SystemVerilog
// Portland State University - Spring 2013
// Final Project:
//
// File:    testbench.sv
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
    localparam DATAWIDTH    = 32;
    localparam ADDRESSWIDTH = 32;

    wire reset;

    // from cpu
    cacheinterface #(.DATAWIDTH(DATAWIDTH), .ADDRESSWIDTH(ADDRESSWIDTH))
        datainf (clock, reset);

    cacheinterface #(.DATAWIDTH(DATAWIDTH), .ADDRESSWIDTH(ADDRESSWIDTH)) 
        data_next (clock, reset);

    cacheinterface #(.DATAWIDTH(DATAWIDTH), .ADDRESSWIDTH(ADDRESSWIDTH))
        instructioninf (clock, reset);

    cacheinterface #(.DATAWIDTH(DATAWIDTH), .ADDRESSWIDTH(ADDRESSWIDTH))
        instruction_next (clock, reset);

    // program driving the test simulation data
    tracedriver td(datainf, data_next, instructioninf, instruction_next);

    // checker modules
    //bind data_cache        cachechecker chkdata(); 
    //bind instruction_cache cachechecker chkinstr(); 

    // monitor modules - counts statistics on cache hits and evictions


    cache data_cache(datainf.slave, data_next.master);
    cache instruction_cache(instructioninf.slave, instruction_next.master);


endmodule
