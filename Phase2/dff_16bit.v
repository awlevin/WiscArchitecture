module dff_16bit(clk, rst, q, d, wen);

input wen, clk, rst;
input [15:0] d;
output [15:0] q;

dff	b15(.q(q[15]), .d(d[15]), .wen(wen), .clk(clk), .rst(rst)),
    	b14(.q(q[14]), .d(d[14]), .wen(wen), .clk(clk), .rst(rst)),
   	b13(.q(q[13]), .d(d[13]), .wen(wen), .clk(clk), .rst(rst)),
    	b12(.q(q[12]), .d(d[12]), .wen(wen), .clk(clk), .rst(rst)),
    	b11(.q(q[11]), .d(d[11]), .wen(wen), .clk(clk), .rst(rst)),
    	b10(.q(q[10]), .d(d[10]), .wen(wen), .clk(clk), .rst(rst)),
    	b9(.q(q[9]), .d(d[9]), .wen(wen), .clk(clk), .rst(rst)),
    	b8(.q(q[8]), .d(d[8]), .wen(wen), .clk(clk), .rst(rst)),
    	b7(.q(q[7]), .d(d[7]), .wen(wen), .clk(clk), .rst(rst)),
    	b6(.q(q[6]), .d(d[6]), .wen(wen), .clk(clk), .rst(rst)),
    	b5(.q(q[5]), .d(d[5]), .wen(wen), .clk(clk), .rst(rst)),
    	b4(.q(q[4]), .d(d[4]), .wen(wen), .clk(clk), .rst(rst)),
    	b3(.q(q[3]), .d(d[3]), .wen(wen), .clk(clk), .rst(rst)),
    	b2(.q(q[2]), .d(d[2]), .wen(wen), .clk(clk), .rst(rst)),
    	b1(.q(q[1]), .d(d[1]), .wen(wen), .clk(clk), .rst(rst)),
    	b0(.q(q[0]), .d(d[0]), .wen(wen), .clk(clk), .rst(rst));

endmodule
