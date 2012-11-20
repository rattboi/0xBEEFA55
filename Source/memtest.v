// This simple module simply reads in a stimulus file provided by the
// command line, and displays the commands in that file

module test();
   
   integer file;		// the file handle 
   
   reg [3:0] command;
   reg [31:0] value;
   reg [9000:0] filename;
   integer count;
   initial begin

      // Check to make sure that a stimulus file was provided
      if (! $value$plusargs("stimulus=%s", filename)) begin
         $display("ERROR: No Stimulus specified. Please specify +stimulus=<filename> to start.");
         $finish;
      end

      // If it was, open the file
      file = $fopenr(filename);
      count = 2;
      // While there are lines left to be read:
      while (count > 0) begin
	 // Parse the line
	 count = $fscanf(file, "%d %x", command, value);
	 if(count > 0)
	   // Display each line
	   $display("command = %d value = %x", command, value);
      end
      // Close the file, and finish up
      $fclose(file);
      $finish;
   end
endmodule
