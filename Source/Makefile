PROJECT=beefa55

CC=iverilog
TESTS := memtest
SRC=memtest.v
all: $(TESTS)



memtest: memtest.v
	iverilog -o $@ $^



test: $(TESTS)
	$(foreach tst,$(TESTS),./$(tst) +stimulus=../vectors/test_vector)

clean:
	rm $(TESTS)

