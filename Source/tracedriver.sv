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

     task automatic opentrace(ref integer filehandle, string filename);
         filehandle = $fopen(filename, "r"); 
         assert(filehandle) else $fatal(1, "Failed to open file :%s handle=%d", filename, filehandle);
     endtask

     task automatic getparsedline(
         output traceline_t line, 
         input integer filehandle 
     );
         int parsed = 0;
         parsed = $fscanf(filehandle, "%d %d", line.operation, line.address); 
         assert(parsed <= 2) 
             else $warning("invalid command, parsed=%d %d", parsed, line.operation);
     endtask


endpackage

program tracedriver(
     cacheinterface.master data, 
     cacheinterface.slave  dataNL,         // Next Level
     cacheinterface.master instruction,
     cacheinterface.slave  instructionNL);

     import tracetools::*;

     task automatic execute_tracefile(integer filehandle);
         traceline_t line;

         while(!$feof(filehandle)) begin
             getparsedline(line, filehandle);

             unique case(line.operation)
                 0: $display("%d", line.operation);
                 1: $display("%d", line.operation);
                 2: $display("%d", line.operation);
                 3: $display("%d", line.operation);
                 4: $display("%d", line.operation);
                 5: $display("%d", line.operation);
                 6: $display("%d", line.operation);
                 7: $display("%d", line.operation);
                 8: $display("%d", line.operation);
                 9: $display("%d", line.operation);
                 default: $warning("unknown operation");
             endcase
        end
     endtask

     string trace_file_name = "";
     integer filelist = $fopen("TRACEFILE", "r");
     integer current_trace_handle;

     integer bytesread;

     initial begin
         assert(filelist) else $fatal(1, "Failed to open file : TRACEFILE");

         bytesread = $fgets(trace_file_name, filelist);
         trace_file_name = trace_file_name.substr(0, trace_file_name.len()-2);

         while(!$feof(filelist)) begin
              opentrace(current_trace_handle, trace_file_name );
              execute_tracefile(current_trace_handle);
              $fclose(current_trace_handle);
              bytesread       = $fgets(trace_file_name, filelist);
              trace_file_name = trace_file_name.substr(0, trace_file_name.len()-2);
         end
         $fclose(filelist);
     end

endprogram

