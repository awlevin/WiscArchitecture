module Decode_Execute_Reg(clk, rst_n, stall_en, rd1_in, rd2_in, rd1_out, rd2_out, sign_ext_in, sign_ext_out, dstReg_in, dstReg_out,srcReg1_in,srcReg1_out,srcReg2_in,srcReg2_out,is_LLB_or_LHB_in,is_LLB_or_LHB_out,is_PCS_in,is_PCS_out);

input clk, rst_n, stall_en;
input [15:0] rd1_in, rd2_in, sign_ext_in; // rd1 and rd2 are the outputs of the register file (i.e. read_data)
input [3:0] dstReg_in,srcReg1_in,srcReg2_in;
input is_LLB_or_LHB_in,is_PCS_in;

output is_LLB_or_LHB_out,is_PCS_out;
output [3:0] dstReg_out,srcReg1_out,srcReg2_out;
output [15:0] rd1_out, rd2_out, sign_ext_out;

wire rst;
assign rst = ~rst_n | stall_en;

dff_16bit rd1(.clk(clk), .rst(rst), .q(rd1_out), .d(rd1_in), .wen(1'b1));
dff_16bit rd2(.clk(clk), .rst(rst), .q(rd2_out), .d(rd2_in), .wen(1'b1));
dff_16bit sign_ext(.clk(clk), .rst(rst), .q(sign_ext_out), .d(sign_ext_in), .wen(1'b1));

dff_4bit dstReg(.clk(clk), .rst(rst), .q(dstReg_out), .d(dstReg_in), .wen(1'b1));
dff_4bit srcReg1(.clk(clk), .rst(rst), .q(srcReg1_out), .d(srcReg1_in), .wen(1'b1));
dff_4bit srcReg2(.clk(clk), .rst(rst), .q(srcReg2_out), .d(srcReg2_in), .wen(1'b1));

dff is_llb_or_lhb(.clk(clk), .rst(rst), .q(is_LLB_or_LHB_out), .d(is_LLB_or_LHB_in), .wen(~stall_en));
dff is_PCS(.clk(clk), .rst(rst), .q(is_PCS_out), .d(is_PCS_in), .wen(~stall_en));
endmodule
