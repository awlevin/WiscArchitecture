module Decode_Execute_Reg(clk, rst_n, rd1_in, rd2_in, rd1_out, rd2_out, sign_ext_in, sign_ext_out, pc_add_in, pc_add_out);

input clk, rst_n;
input [15:0] rd1_in, rd2_in, sign_ext_in, pc_add_in;

output [15:0] rd1_out, rd2_out, sign_ext_out, pc_add_out;

dff_16bit rd1(.clk(clk), .rst(~rst_n), .q(rd1_out), .d(rd1_in), .wen(1'b1));
dff_16bit rd2(.clk(clk), .rst(~rst_n), .q(rd2_out), .d(rd2_in), .wen(1'b1));
dff_16bit sign_ext(.clk(clk), .rst(~rst_n), .q(sign_ext_out), .d(sign_ext_in), .wen(1'b1));
dff_16bit pc_add(.clk(clk), .rst(~rst_n), .q(pc_add_out), .d(pc_add_in), .wen(1'b1));

endmodule
