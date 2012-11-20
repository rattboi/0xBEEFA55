module test();
   integer file;
   
   reg [3:0] command;
   reg [31:0] value;
   reg [9000:0] filename;
   integer count;
   initial begin
      
      if (! $value$plusargs("stimulus=%s", filename)) begin
         $display("ERROR: No Stimulus specified. Please specify +stimulus=<filename> to start.");
         $finish;
      end
      
      file = $fopenr(filename);
      count = 2;
      while (count > 0) begin
	 count = $fscanf(file, "%d %x", command, value);
	 if(count > 0)
	   $display("command = %d value = %x", command, value);
      end
      $fclose(file);
      $finish;
   end
endmodule
