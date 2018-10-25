module Decode_Execute_Reg(clk, rst_n, rd1_in, rd2_in, rd1_out, rd2_out, sign_ext_in, sign_ext_out, dstReg_in, dstReg_out);

input clk, rst_n;
input [15:0] rd1_in, rd2_in, sign_ext_in; // rd1 and rd2 are the outputs of the register file (i.e. read_data)
input [3:0] dstReg_in;

output [3:0] dstReg_out;
output [15:0] rd1_out, rd2_out, sign_ext_out;

dff_16bit rd1(.clk(clk), .rst(~rst_n), .q(rd1_out), .d(rd1_in), .wen(1'b1));
dff_16bit rd2(.clk(clk), .rst(~rst_n), .q(rd2_out), .d(rd2_in), .wen(1'b1));
dff_16bit sign_ext(.clk(clk), .rst(~rst_n), .q(sign_ext_out), .d(sign_ext_in), .wen(1'b1));
dff_4bit dstReg(.clk(clk), .rst(~rst_n), .q(dstReg_out), .d(dstReg_in), .wen(1'b1));

endmodule
