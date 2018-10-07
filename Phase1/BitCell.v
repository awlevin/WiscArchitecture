
module BitCell(clk, rst, D, WriteEnable, ReadEnable1, ReadEnable2, Bitline1, Bitline2);

input clk;
input rst;
input D;
input WriteEnable, ReadEnable1, ReadEnable2;
inout Bitline1, Bitline2;

wire q;

dff dflip(.q(q), .d(D), .wen(WriteEnable), .clk(clk), .rst(rst));

assign Bitline1 = (ReadEnable1) ? q : 1'bz;
assign Bitline2 = (ReadEnable2) ? q : 1'bz;

endmodule
