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

     enum { READ       = 0,
            WRITE      = 1,
            INST_FETCH = 2,
            INVALIDATE = 3, 
            RESET      = 8, 
            PRINT      = 9} nub;

     task automatic trans(
         int    address, 
         cachepkg::inst_t operation,
         ref valid, 
         ref int addr, 
         ref int data);

         @(posedge data.clock)
         data.operation = operation;
         data.addr      = address;

         if(operation == WRITE)
             data.d         = 'hDEADBEEF; 

         wait(data.valid);
         data.operation = cachepkg::IDLE;
         data.addr      = 'z;
         data.d         = 'z;
     endtask

     task automatic execute_tracefile(integer filehandle);
         traceline_t line;

         while(!$feof(filehandle)) begin
             getparsedline(line, filehandle);

             unique case(line.operation)
                 READ:       trans(line.address, 
                                   cachepkg::READ, 
                                   data.valid, 
                                   data.addess, 
                                   data.d); 

                 WRITE:       trans(line.address, 
                                   cachepkg::WRITE, 
                                   data.valid, 
                                   data.addess, 
                                   data.d); 

                 INST_FETCH:       trans(line.address, 
                                   cachepkg::READ, 
                                   instructon.valid, 
                                   instruction.addess, 
                                   instruction.d); 

                 INVALIDATE:       trans(line.address, 
                                   cachepkg::INVALIDATE, 
                                   instructon.valid, 
                                   instruction.addess, 
                                   instruction.d); 


                 INVALIDATE: invalidate(line.address, dataNL);

                 RESET:      reset(instruction, data);
                 PRINT:      display("magic print function %d", line.operation);

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

