This project is a Verilog simulation of a split instruction/data L1 cache for a 32-bit processor in a system with multiple processors.  The system employs MESI protocol to ensure cache coherence.  

Theinstruction cache is 2-way set associative, consists of 16K sets, and
has 64-byte lines. The data cache is 4-way set associative, consists
of 16K sets, and has 64-byte lines.  

Both caches employ LRU replacement policy and are backed by an L2 cache (which is modeled as a stub in this simulation).  Statistics regarding number of reads, writes, hits, and misses are generated, as well as a hit percentage rate.  This simulation has a single-cycle interface between a
processor and L1, and between L1 and L2.  All processor reads and
writes are a single byte.

Project Contents:   
/BEEFA55 -- Xilinx Project Directory
/doc	 -- Documentation/Report (LaTeX)
/vectors -- Provided trace file (cc1.din) as well as new test files (*.trace) and descriptions