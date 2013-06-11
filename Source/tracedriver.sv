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

     logic [31:0] addr;
     logic [31:0] datalines;

     enum { READ       = 0,
            WRITE      = 1,
            INST_FETCH = 2,
            INVALIDATE = 3, 
            RESET      = 8, 
            PRINT      = 9} nub;

     task execute_tracefile(integer filehandle);
         traceline_t line;

         while(!$feof(filehandle)) begin
             getparsedline(line, filehandle);
             $display("operation %d", line.operation);

             @(posedge data.clock)
             unique case(line.operation)
                 READ: begin
                     data.operation = cachepkg::READ;
                     force data.addr      = line.address;
                     data.request   = '1;
                 end

                 WRITE: begin
                     data.operation = cachepkg::WRITE;
                     force data.addr      = line.address;
                     data.request   = '1;
                     force data.d         = 'hDEADBEEF;
                 end
                 
                 INST_FETCH: begin
                     data.operation = cachepkg::WRITE;
                     force data.addr      = line.address;
                     data.request   = '1;
                 end

                 INVALIDATE: begin
                     dataNL.evict            = '1;
                     force dataNL.addr             = line.address;
                     instructionNL.evict     = '1;
                     force instructionNL.addr      = line.address;
                 end

                 RESET: begin
                     data.operation         = cachepkg::RESET;
                     data.request           = '1;
                     force instruction.operation  = cachepkg::RESET;
                     force instruction.request    = '1;
                 end

                 PRINT:      $display("magic print function %d", line.operation);
             endcase

             unique case(line.operation)
                 READ, WRITE, INST_FETCH: begin
//                     wait(data.valid); // these should be in a fork join
                     data.operation = cachepkg::NOP;
                     data.request   = '0;
                     release data.addr;
                     release data.d;
                 end

                 INVALIDATE: begin
//                     wait(data.request) // these should be in a fork join
                     instruction.evict = '0;
                     release instruction.addr;
                     release data.addr;
                 end
                 default: ;
             endcase
         end
     endtask

     string trace_file_name = "";
     integer filelist = $fopen("TRACEFILE", "r");
     integer current_trace_handle;

     integer bytesread;

     initial begin
         $display("LOADING TRACE FILES");
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

