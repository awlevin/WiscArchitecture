module PC_Register(clk, rst_n, set, flags_in, flags_out);

input clk, rst_n, set;
input [2:0] flags_in;
output [2:0] flags_out;

dff 	zflag(.q(flags_out[0]), .d(flags_in[0]), .wen(set), .clk(clk), .rst(~rst)),
	vflag(.q(flags_out[1]), .d(flags_in[1]), .wen(set), .clk(clk), .rst(~rst)),
	nflag(.q(flags_out[2]), .d(flags_in[2]), .wen(set), .clk(clk), .rst(~rst));

endmodule
