module dff_4bit(clk, rst, q, d, wen);

input wen, clk, rst;
input [3:0] d; //input
output [3:0] q; //output

dff	b3(.q(q[3]), .d(d[3]), .wen(wen), .clk(clk), .rst(rst)),
    	b2(.q(q[2]), .d(d[2]), .wen(wen), .clk(clk), .rst(rst)),
    	b1(.q(q[1]), .d(d[1]), .wen(wen), .clk(clk), .rst(rst)),
    	b0(.q(q[0]), .d(d[0]), .wen(wen), .clk(clk), .rst(rst));

endmodule
