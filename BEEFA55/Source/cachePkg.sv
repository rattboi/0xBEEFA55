`ifndef cachePkg__
`define cackePkg__

package cachePkg;

parameter TRUE      = 1'b1;
parameter FALSE     = 1'b0;


typedef enum { RESET,
               INVALIDATE,
               INST_FETCH,
               READ,
               WRITE    } inst_t;

typedef enum { READ_OUT,
               WRITE_OUT,
               RW_OUT,
               NOP      } output_t;

endpackage
`endif
