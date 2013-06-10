////////////////////////////////////////////////////////////////////////////////
// ECE 510: SystemVerilog
// Portland State University - Spring 2013
// Final Project:
//
// File:    cachePkg.sv
// Authors: Eric Krause, Bradon Kanyid, Tyler Tricker
// Description: it is a package
//
////////////////////////////////////////////////////////////////////////////////

`ifndef cachePkg__
`define cackePkg__

package cachePkg;

parameter TRUE      = 1'b1;
parameter FALSE     = 1'b0;

parameter VALID     = 1'b1;
parameter INVALID   = 1'b0;

typedef enum { RESET,
               INVALIDATE,
               READ,
               WRITE    } inst_t;

typedef enum { READ_OUT,
               WRITE_OUT,
               RW_OUT,
               NOP      } output_t;



endpackage
`endif
