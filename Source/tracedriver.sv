package tracetools;
     import "DPI-C" function int opendir(string path);

     typedef struct packed {
         int operation;
         int address;
     } traceline_t;

     task automatic opentrace(output integer filehandle, input string filename);
         filehandle = $fopenr(filename); 
     endtask

     task automatic getparsedline(
         output traceline_t linei, 
         input filehandle 
     );
         int parsed = 0;
         parsed = $fscanf(filehandle, "%d %d", line.operation, line.address); 
         assert(line.operation != 9 && parsed < 2) else $warning("invalid line");
     endtask

     task automatic execute_tracefile(filehandle);
     endtask


endpackage



program tracedriver(
     cacheinterface.master data, 
     cacheinterface.slave  dataNL,         // Next Level
     cacheinterface.master instruction,
     cacheinterface.slave  instructionNL);

     import tracetools::*;

     initial begin
         traceline_t currentop;

         while(!$feof(file)) begin
         ; // main loop
         end

     end


endprogram

