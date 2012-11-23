# This makefile builds all of the tests and runs them. 

# The name of the verilog simulator
CC=iverilog
# List of executables built as part of this makefile
TESTOBJS := memtest a.vcd
# List of individual tests that are run
TESTS := memory-test
# Directory test vectors are stored in. 
VECTORDIR=../vectors/

# macro to print out the name of the test being executed
HEADER = echo "executing test '$@'"

# By default, build all of the test objects, but do not run the tests
all: $(TESTOBJS)


# This executable just prints the loaded stimulus file to stdout
memtest: memtest.v
	iverilog -o $@ $^

# This test uses the test_vector stimulus to verify that the memtest
# executable actually prints the contents of the stimulus file
memory-test: memtest
	$(HEADER)
	./$< +stimulus=$(VECTORDIR)test_vector +tracefile=a.vcd


test: $(TESTS)

list:

	echo 'Available tests are:'
	$(foreach tst, $(TESTS), printf  '\t$(tst)\n')

clean:
	rm $(TESTOBJS)
