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

     import "DPI-C" function string getenv(input string name);

     typedef struct packed {
         int operation;
         int address;
     } traceline_t;

     task automatic opentrace(output integer filehandle, input string filename);
         filehandle = $fopen(filename, "r"); 
     endtask

     task automatic getparsedline(
         output traceline_t line, 
         input filehandle 
     );
         int parsed = 0;
         parsed = $fscanf(filehandle, "%d %d", line.operation, line.address); 
         assert(line.operation != 9 && parsed < 2) else $warning("invalid line");
     endtask


endpackage



program tracedriver(
     cacheinterface.master data, 
     cacheinterface.slave  dataNL,         // Next Level
     cacheinterface.master instruction,
     cacheinterface.slave  instructionNL);

     import tracetools::*;

     task automatic execute_tracefile(filehandle);
         while(!$feof(filehandle)) begin
         ; // main loop
         end
     endtask

     string trace_file_name = "";
     int filelist = $fopen("TRACEFILE", "r");
     int current_trace_handle;

     int dont_care;

     initial begin
         while(!$feof(filelist)) 
              dont_care = $fgets(trace_file_name, filelist);
              opentrace(current_trace_handle, trace_file_name );
              execute_tracefile(current_trace_handle);
         $fclose(filelist);
     end

endprogram

