//Tag Array of 128  blocks
//Each block will have 1 byte
//SetEnable is one-hot
//WriteEnable is one on writes and zero on reads

module MetaDataArray(input clk, input rst, input [7:0] DataIn, input [63:0] SetEnable, input Write0, input Write1, output [7:0] DataOut0, output [7:0] DataOut1);
	MBlock Mblk0[63:0]( .clk(clk), .rst(rst), .Din(DataIn), .WriteEnable(Write0), .Enable(SetEnable), .Dout(DataOut0));
	MBlock Mblk1[63:0]( .clk(clk), .rst(rst), .Din(DataIn), .WriteEnable(Write1), .Enable(SetEnable), .Dout(DataOut1));
endmodule

module MBlock( input clk,  input rst, input [7:0] Din, input WriteEnable, input Enable, output [7:0] Dout);
	MCell mc[7:0]( .clk(clk), .rst(rst), .Din(Din[7:0]), .WriteEnable(WriteEnable), .Enable(Enable), .Dout(Dout[7:0]));
endmodule

module MCell( input clk,  input rst, input Din, input WriteEnable, input Enable, output Dout);
	wire q;
	assign Dout = (Enable & ~WriteEnable) ? q:'bz;
	dff dffm(.q(q), .d(Din), .wen(Enable & WriteEnable), .clk(clk), .rst(rst));
endmodule

