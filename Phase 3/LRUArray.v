

module LRUArray(input clk, input rst, input writeEn, input [63:0] SetEnable, input Block, output block0_isLRU, output block1_isLRU);
	Set set[63:0]( .clk(clk), .rst(rst), .writeEn(writeEn), .Block(Block), .Enable(SetEnable), .block0_isLRU(block0_isLRU), .block1_isLRU(block1_isLRU));
endmodule

module Set(input clk, input rst, input writeEn, input Enable, input Block, output block0_isLRU, output block1_isLRU);
	
	wire block0_LRUbit, block1_LRUbit;
	LRUCell block0(.clk(clk), .rst(rst), .Din(~Block), .WriteEnable(writeEn), .Enable(Enable), .Dout(block0_LRUbit));
	LRUCell block1(.clk(clk), .rst(rst), .Din(Block), .WriteEnable(writeEn), .Enable(Enable), .Dout(block1_LRUbit));

	assign LRU_valid = block0_LRUbit ^ block1_LRUbit;
	assign block0_isLRU = (~LRU_valid) ? 1'b1 : block0_LRUbit;
	assign block1_isLRU = (~LRU_valid) ? 1'b0 : block1_LRUbit;
	
endmodule

module LRUCell( input clk,  input rst, input Din, input WriteEnable, input Enable, output Dout);
	wire q;
	assign Dout = (Enable & ~WriteEnable) ? q:1'b0;
	dff dffm(.q(q), .d(Din), .wen(Enable & WriteEnable), .clk(clk), .rst(rst));

endmodule
