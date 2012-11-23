// This simple module simply reads in a stimulus file provided by the
// command line, and displays the commands in that file

module test();

   parameter IDLE_CLOCKS = 2;
   parameter CLOCK_CYCLE  = 20;
   parameter CLOCK_WIDTH  = CLOCK_CYCLE/2;
   parameter TRUE   = 1'b1;
   parameter FALSE  = 1'b0;

   reg Clock;
   reg Clear;
   integer file;		// the file handle 
   
   reg [3:0] command;
   reg [31:0] value;
   reg [9000:0] filename;
   reg [9000:0] tracefile;
   integer count;

   initial
     begin
	Clock = FALSE;
	forever #CLOCK_WIDTH Clock = ~Clock;
     end

   
   initial begin

      // If a tracefile has been specified, generate a vcd file
      if($value$plusargs("tracefile=%s", tracefile)) begin
	 $dumpfile(tracefile);
	 $dumpvars();
	 end
      
      // Check to make sure that a stimulus file was provided
      if (! $value$plusargs("stimulus=%s", filename)) begin
         $display("ERROR: No Stimulus specified. Please specify +stimulus=<filename> to start.");
         $finish;
      end

	Clear = TRUE;
	repeat (IDLE_CLOCKS) @(negedge Clock);
	Clear = FALSE;

      // If it was, open the file
      file = $fopenr(filename);
      count = 2;
      // While there are lines left to be read:
      while (count > 0) begin
	 // Parse the line
	 count = $fscanf(file, "%d %x", command, value);
	 if(count > 0) begin
	   // Display each line
	    repeat(1) @(negedge Clock);
	    $display("command = %d value = %x", command, value);
	 end
      end
      // Close the file, and finish up
      $fclose(file);
      $finish;
   end
endmodule
