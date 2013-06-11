////////////////////////////////////////////////////////////////////////////////
// ECE 510: SystemVerilog
// Portland State University - Spring 2013
// Final Project:
//
// File:    tracedriver.sv
// Authors: Eric Krause, Bradon Kanyid, Tyler Tricker
// Description: dut
//
////////////////////////////////////////////////////////////////////////////////

package tracetools;

     typedef struct {
          integer d_ino;                  /* inode number */
          integer d_off;                  /* offset to the next dirent */
          byte    d_reclen[2];              /* length of this record */
          byte    d_type;                 /* type of file; not supported
                                         by all file system types */
          string d_name;                 /* filename */
           } dirent;

     import "DPI-C" function int opendir(input string path);
     import "DPI-C" function int readdir(output dirent dir, input int);

     typedef struct packed {
         int operation;
         int address;
     } traceline_t;

     task automatic opentrace(output integer filehandle, input string filename);
         filehandle = $fopenr(filename); 
     endtask

     task automatic getparsedline(
         output traceline_t line, 
         input filehandle 
     );
         int parsed = 0;
         parsed = $fscanf(filehandle, "%d %d", line.operation, line.address); 
         assert(line.operation != 9 && parsed < 2) else $warning("invalid line");
     endtask



     task automatic execute_tracefile(filehandle);
         while(!$feof(filehandle)) begin
         ; // main loop
         end
     endtask


endpackage



program tracedriver(
     cacheinterface.master data, 
     cacheinterface.slave  dataNL,         // Next Level
     cacheinterface.master instruction,
     cacheinterface.slave  instructionNL);

     import tracetools::*;

     initial begin
         ;

     end


endprogram

