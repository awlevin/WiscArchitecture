

module LRUArray(input clk, input rst, input writeEn, input [63:0] SetEnable, input Block, output block0_isLRU, output block1_isLRU);
	Set set[63:0]( .clk(clk), .rst(rst), .writeEn(writeEn), .Block(Block), .Enable(SetEnable), .block0_isLRU(block0_isLRU), .block1_isLRU(block1_isLRU));
endmodule

module Set(input clk, input rst, input writeEn, input Enable, input Block, output block0_isLRU, output block1_isLRU);
	
	wire block0_LRUbit, block1_LRUbit, set_inital_LRU_values,block0_in,block1_in;

	LRUCell block0(.clk(clk), .rst(rst), .Din(~Block), .WriteEnable(writeEn | ~LRU_valid), .Enable(Enable), .Dout(block0_LRUbit));
	LRUCell block1(.clk(clk), .rst(rst), .Din(Block), .WriteEnable(writeEn | ~LRU_valid), .Enable(Enable), .Dout(block1_LRUbit));

	assign LRU_valid = block0_LRUbit ^ block1_LRUbit;
	assign block0_isLRU = (Enable) ?
					(~LRU_valid) ? 1'b1 : block0_LRUbit :
					'bz;
	assign block1_isLRU = (Enable) ?
					(~LRU_valid) ? 1'b0 : block1_LRUbit:
					'bz;
	
endmodule

module LRUCell( input clk,  input rst, input Din, input WriteEnable, input Enable, output Dout);
	
	dff dffm(.q(Dout), .d(Din), .wen(Enable & WriteEnable), .clk(clk), .rst(rst));

endmodule
