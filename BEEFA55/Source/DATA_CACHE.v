////////////////////////////////////////////////////////////////////////////////
// ECE 485/585: Microprocessor System Design
// Portland State University - Fall 2012 
// Final Project: 
// 
// File:    DATA_CACHE.v (Data Cache)
// Authors: 
// Description:
//
//
//
////////////////////////////////////////////////////////////////////////////////
`define SETS 1024*16
`define WAYS 4
`define SETBITS 14
`define TAGBITS 12

module DATA_CACHE(
  // INPUTS
  input [3:0] n,      // from trace file
  input [31:0] add_in,  // from trace file
  input clk,
  
  // OUTPUTS
  output reg [25:0] add_out = 32'bZ,  // to next-level cache
  output reg [1:0]  cmd_out = 2'b00,      // to next-level cache
  output reg [31:0] hit = 32'b0,    // to statistics module
  output reg [31:0] miss = 32'b0,   // to statistics module
  output reg [31:0] reads = 32'b0, // to statistics module
  output reg [31:0] writes = 32'b0 // to statistics module
  );
  
  // data cache only reponds to following values of n
  parameter RESET     = 4'd8;
  parameter INVALIDATE  = 4'd3;
  parameter READ      = 4'd0;
  parameter WRITE     = 4'd1;
  parameter PRINT     = 4'd9;
  
  // data cache sends following commands to next-level cache
  parameter READ_OUT    = 2'b01;
  parameter WRITE_OUT   = 2'b10;
  // Read with intent to write
  parameter RW_OUT      = 2'b10;

  // instantiate cache elements
  //  size          sets      ways
  reg [5:0] LRU   [`SETS-1:0]       ;//  1=LRU is way 1.  0 = LRU way is 0
  reg Valid [`SETS-1:0] [`WAYS-1:0];
  reg [11:0]      Tag   [`SETS-1:0] [`WAYS-1:0];
  
  // loop counters
  integer set_cnt,way_cnt;
   
  // internal
  reg done = 1'b0;
  reg [1:0]lru_way;
  wire [5:0]new_lru;
  reg [5:0]lru_calc_in;
  reg go;
  
  // assignments
  wire [11:0] curr_tag = add_in[31:20];
  wire [13:0] curr_index = add_in[19:6];
  
  
  always @(posedge clk)
  begin 
    add_out = 26'bZ;
    done  = 1'b0;
    
    case(n)
      RESET: 
      // clear all Valid bits in the Data Cache
      // and reset the statistics counters
      begin
        hit   = 32'b0;
        miss  = 32'b0;
        reads = 32'b0;
        writes = 32'b0;
        for (set_cnt = 0; set_cnt < `SETS; set_cnt = set_cnt + 1'b1)  // for every set
        begin
          LRU[set_cnt] = 6'b0;  
          for (way_cnt = 0; way_cnt < `WAYS; way_cnt = way_cnt + 1'b1)  // for all ways
          begin
            Valid [set_cnt][way_cnt]  = 1'b0; 
            Tag   [set_cnt][way_cnt]  = 24'b0;
          end
        end
      end
      
      INVALIDATE:
      begin
        // when an invalidate command is passed in, check to see if
        // any line in the cache matches the address passed in, if
        // it does, clear the Valid bit for that line.
        for (way_cnt = 0; way_cnt < `WAYS; way_cnt = way_cnt + 1'b1)
          if (!done)
            if (Tag[curr_index][way_cnt] == curr_tag)
            begin
              done = 1'b1;
              Valid[curr_index][way_cnt] = 1'b0;
            end
      end 
      
      READ:
      begin
        // increment the number of total reads since reset occurred 
        reads = reads + 1'b1;
        // search the ways within the set, if there is a hit, update the LRU
        // and increment the hit counter
        for (way_cnt = 0; way_cnt < `WAYS; way_cnt = way_cnt + 1'b1)
        begin
          if (!done)
            if (Tag[curr_index][way_cnt] == curr_tag && Valid[curr_index][way_cnt] == 1'b1)
            begin 
              lru_calc_in       = next_lru(LRU[curr_index], way_cnt[1:0]);
              LRU[curr_index]   = lru_calc_in;
              done              = 1'b1;
              cmd_out           = READ_OUT;
              hit               = hit + 1'b1;
            end
        end 
        
        // if there was no hit, increment the miss counter
        if (!done)
          miss = miss + 1'b1;
        
        // if there was no hit, check to see if there is an empty
        // line in the set, if not, evict the LRU of the line
        // and replace it with the newly read in value.
        for (way_cnt = 0; way_cnt < `WAYS; way_cnt = way_cnt + 1'b1)
        begin
          if (!done)
            if (Valid[curr_index][way_cnt] == 1'b0)
            begin
              add_out                    = add_in[31:6];   // generate read
              cmd_out                    = READ_OUT;       // generate read
              lru_calc_in       = next_lru(LRU[curr_index], way_cnt[1:0]);
              LRU[curr_index]   = lru_calc_in;
              Tag[curr_index][way_cnt]   = curr_tag;
              Valid[curr_index][way_cnt] = 1'b1;
              done                       = 1'b1;
            end
        end
        
        if (!done)
          begin
            add_out                    = add_in[31:6];  // generate read
            cmd_out                    = READ_OUT;      // generate read
            lru_way                    = decode_lru(LRU[curr_index]);            
            Tag[curr_index][lru_way]   = curr_tag;  
            Valid[curr_index][lru_way] = 1'b1;   
            lru_calc_in       = next_lru(LRU[curr_index], way_cnt[1:0]);
            LRU[curr_index]   = lru_calc_in;
          end
      end
      
      WRITE:
      begin
        // increment the number of total writes since reset occurred 
        writes = writes + 1;
        
        // search the ways within the set, if there is a hit, update the LRU
        // and increment the hit counter
        for (way_cnt = 0; way_cnt < `WAYS; way_cnt = way_cnt + 1'b1)
        begin
          if (!done)
            if (Tag[curr_index][way_cnt] == curr_tag && Valid[curr_index][way_cnt] == 1'b1)
            begin
              add_out         = add_in[31:6]; 
              cmd_out         = WRITE_OUT;
              lru_calc_in       = next_lru(LRU[curr_index], way_cnt[1:0]);
              LRU[curr_index]   = lru_calc_in;
              done            = 1'b1;
              hit             = hit + 1'b1;
            end
        end 
        
        // if there was no hit, increment the miss counter
        if (!done)
          miss = miss + 1'b1;

        // if there was no hit, check to see if there is an empty
        // line in the set, if not, evict the LRU of the line
        // and replace it with the newly read in value.
        for (way_cnt = 0; way_cnt < `WAYS; way_cnt = way_cnt + 1'b1)
        begin
          if (!done)
            if (Valid[curr_index][way_cnt] == 1'b0)
            begin
              add_out                     = add_in[31:6];
              cmd_out                     = RW_OUT;
              lru_calc_in       = next_lru(LRU[curr_index], way_cnt[1:0]);
              LRU[curr_index]   = lru_calc_in;
              done                        = 1'b1;
              Tag[curr_index][way_cnt]    = curr_tag;
              Valid[curr_index][way_cnt]  = 1'b1;
              add_out                     = add_in[31:6];
              cmd_out                     = WRITE_OUT;              
            end
        end     

        if (!done)
          begin
            add_out                     = add_in[31:6]; // read in with intent to write
            cmd_out                     = RW_OUT;       // read in with intent to write

            lru_way                     = decode_lru(LRU[curr_index]);            
            Tag[curr_index][lru_way]    = curr_tag;  
            Valid[curr_index][lru_way]  = 1'b1;   
            lru_calc_in       = next_lru(LRU[curr_index], way_cnt[1:0]);
            LRU[curr_index]   = lru_calc_in;
            add_out                     = add_in[31:6]; // write back out
            cmd_out                     = WRITE_OUT;    // write back out

          end
      end
          
      // Print all of the contents of the Data Cache
      PRINT:
      begin
        // print header
        $display("----------- DATA CACHE CONTENTS ----------");
        $display(" INDEX | LRU | V[0]|Tag[0]| V[1]|Tag[1]| V[2]|Tag[2]| V[3]|Tag[3]");
        // cycle through all of the ways within a set
        for (set_cnt = 0; set_cnt < `SETS; set_cnt = set_cnt+1)
        begin
          // print out the whole set if there are any valid lines
          if (Valid[set_cnt][3] | Valid[set_cnt][2] | Valid[set_cnt][1] | Valid[set_cnt][0] )
          begin
            $display(" %4h  |  %d  |  %d  | %3h  |  %d  | %3h  |  %d  | %3h  |  %d  | %3h", 
              set_cnt[`SETBITS-1:0], 
              decode_lru(LRU[set_cnt]), 
              Valid[set_cnt][0], 
              Valid[set_cnt][0] ? Tag[set_cnt][0] : `TAGBITS'hX, 
              Valid[set_cnt][1], 
              Valid[set_cnt][1] ? Tag[set_cnt][1] : `TAGBITS'hX,
              Valid[set_cnt][2], 
              Valid[set_cnt][2] ? Tag[set_cnt][2] : `TAGBITS'hX, 
              Valid[set_cnt][3], 
              Valid[set_cnt][3] ? Tag[set_cnt][3] : `TAGBITS'hX             
            ); 
          end
        end
        $display("------- END OF DATA CACHE CONTENTS -------");
      end
      
      default: ;  // commands this module doesn't respond to
    endcase   
  end

  function [1:0] decode_lru;
  input [5:0]lru_bits;
    begin
        if 		(!(|lru_bits[5:3]))     decode_lru = 2'd0;
        else if (!(|lru_bits[2:1]))   decode_lru = 2'd1;
        else if (!  lru_bits[0]) 	    decode_lru = 2'd2;
        else    		 		              decode_lru = 2'd3;	
    end
  endfunction
  
  function [5:0] next_lru;
    input [5:0]lru_bits;
    input [1:0]way_accessed;
    begin
      case (way_accessed)
      // Set the first 3 bits (this defines MRU 0)
      2'd0: next_lru = (lru_bits | 6'b111000);  

      // Clear bit 0, Set bits 3 & 4 (MRU 1)
      2'd1: next_lru = ((lru_bits & 6'b011111) | 6'b000110); 
      
      // Clear bits 1 & 3, Set bit 5 (MRU 2)
      2'd2: next_lru = ((lru_bits & 6'b101011) | 6'b000001); 

      // Clear bits 2,4,5 (MRU 3)
      2'd3: next_lru = (lru_bits & 6'b110100);  
      endcase
    end
  endfunction

endmodule



  
