////////////////////////////////////////////////////////////////////////////////
// ECE 485/585: Microprocessor System Design
// Portland State University - Fall 2012 
// Final Project: 
// 
// File:    memtest.v (Test Bench)
// Authors: 
// Description:
//
// This module reads in a stimulus file provided by the
// command line and passes commands to the cache.
//
////////////////////////////////////////////////////////////////////////////////

module test();

  parameter CLOCK_CYCLE  = 20;
  parameter CLOCK_WIDTH  = CLOCK_CYCLE/2;
  parameter TRUE   = 1'b1;
  parameter FALSE  = 1'b0;

  reg Clock;
  integer file;     // the file handle 
  reg  done;
  reg  [3:0]        command;
  reg  [31:0]       value;
  reg  [9000:0]     filename;
  wire [25:0]       add_out;
  wire [1:0]        cmd_out;
  integer count;

  PROJECT project(
	  .clk(Clock),
	  .n(command),
	  .add_in(value),
	  .done(done),
	  .add_out(add_out),
	  .cmd_out(cmd_out)
	  );
	  
  L_NEXT l_next(
		.add_in(add_out),
		.cmd_in(cmd_out)
  );

  initial
  begin
	 Clock = FALSE;
	 done = FALSE;

	 // Check to make sure that a stimulus file was provided
	 if ($value$plusargs("stimulus=%s", filename) == FALSE) 
	 begin
	   $display("ERROR: No Stimulus specified. Please specify +stimulus=<filename> to start.");
	   $finish;
	 end

	 // If it was, open the file
	 file = $fopen(filename, "r");
	 count = 2;

	 // simulate initial reset
	 #CLOCK_WIDTH Clock = FALSE;
	 command = 4'd8;
	 #CLOCK_WIDTH Clock = TRUE;

	 // While there are lines left to be read:
	 while (count > 1) 
	 begin
		// Parse the line
		#CLOCK_WIDTH Clock = FALSE;
		count = $fscanf(file, "%d %x", command, value);
		#CLOCK_WIDTH Clock = TRUE;
	 end

	 // Close the file, and finish up
	 $fclose(file);
	 done = TRUE;
  end
endmodule
