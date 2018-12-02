module PC_Register(clk, rst, stall_en, next_pc, pc_out);

input clk, rst, stall_en;
input [15:0] next_pc;
output [15:0] pc_out;

dff 	b0(.q(pc_out[0]), .d(next_pc[0]), .wen(~stall_en), .clk(clk), .rst(rst)),
	b1(.q(pc_out[1]), .d(next_pc[1]), .wen(~stall_en), .clk(clk), .rst(rst)),
	b2(.q(pc_out[2]), .d(next_pc[2]), .wen(~stall_en), .clk(clk), .rst(rst)),
	b3(.q(pc_out[3]), .d(next_pc[3]), .wen(~stall_en), .clk(clk), .rst(rst)),
	b4(.q(pc_out[4]), .d(next_pc[4]), .wen(~stall_en), .clk(clk), .rst(rst)),
	b5(.q(pc_out[5]), .d(next_pc[5]), .wen(~stall_en), .clk(clk), .rst(rst)),
	b6(.q(pc_out[6]), .d(next_pc[6]), .wen(~stall_en), .clk(clk), .rst(rst)),
	b7(.q(pc_out[7]), .d(next_pc[7]), .wen(~stall_en), .clk(clk), .rst(rst)),
	b8(.q(pc_out[8]), .d(next_pc[8]), .wen(~stall_en), .clk(clk), .rst(rst)),
	b9(.q(pc_out[9]), .d(next_pc[9]), .wen(~stall_en), .clk(clk), .rst(rst)),
	b10(.q(pc_out[10]), .d(next_pc[10]), .wen(~stall_en), .clk(clk), .rst(rst)),
	b11(.q(pc_out[11]), .d(next_pc[11]), .wen(~stall_en), .clk(clk), .rst(rst)),
	b12(.q(pc_out[12]), .d(next_pc[12]), .wen(~stall_en), .clk(clk), .rst(rst)),
	b13(.q(pc_out[13]), .d(next_pc[13]), .wen(~stall_en), .clk(clk), .rst(rst)),
	b14(.q(pc_out[14]), .d(next_pc[14]), .wen(~stall_en), .clk(clk), .rst(rst)),
	b15(.q(pc_out[15]), .d(next_pc[15]), .wen(~stall_en), .clk(clk), .rst(rst));

endmodule
