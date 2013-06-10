module IC_test();


localparam type ADDR = bit[31:0];
localparam type WORD = bit[7:0];


        parameter RESET = 4'd8;
        parameter INVALIDATE = 4'd3;
        parameter INST_FETCH = 4'd2;
        parameter PRINT = 4'd9;


reg [3:0] N;
reg [31:0] ADD;

initial 
begin
	N = RESET;
	ADD = 32'bZZZZ_ZZZZ_ZZZZ_ZZZZ_ZZZZ_ZZZZ_ZZZZ_ZZZZ;
	
	# 100
	
	N = INST_FETCH;
	ADD = 32'hFACEB00B;
	# 10
	ADD = 32'hDEADBEEF;
	#10 
	ADD = 32'h0BEEFA55;
	
	# 100
	N = PRINT;
	
	#10 $finish;
end

INS_CACHE SUT (
    .n(N),
	.add_in(ADD),
    .add_out(), 
    .hit(), 
    .miss()
    );
	
endmodule 
