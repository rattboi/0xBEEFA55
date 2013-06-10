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

    clocking cb

    // testing parameters
    localparam type WORD      = logic[7:0];
    localparam type ADDRSPACE = logic[31:0];

    // from cpu
    cacheinterface datainf 
       #(.WORD(WORD), .ADDRSPACE(ADDRSPACE)
        (clock);

    cacheinterface data_next 
       #(.WORD(WORD), .ADDRSPACE(ADDRSPACE))
        (clock);

    cacheinterface instructioninf 
       #(.WORD(WORD), .ADDRSPACE(ADDRSPACE))
        (clock);

    cacheinterface instruction_next
       #(.WORD(WORD), .ADDRSPACE(ADDRSPACE))
        (clock);

    // program driving the test simulation data
    // driver dr(datainf, instructioninf);

    // checker modules
    //bind data_cache        cachechecker chkdata(); 
    //bind instruction_cache cachechecker chkinstr(); 


    cache data_cache(bus.slave);
    cache instruction_cache(bus.slave);


endmodule
