module Execute_Memory_Reg(clk, rst_n, zero_in, zero_out, alu_result_in, alu_result_out, dataIn_in, dataIn_out,dstReg_in, dstReg_out);

input clk, rst_n, zero_in;
output zero_out;
input [15:0] alu_result_in, dataIn_in;
input [3:0] dstReg_in;

output [3:0] dstReg_out;
output [15:0] alu_result_out, dataIn_out;

dff_16bit dataIn(.clk(clk), .rst(~rst_n), .q(dataIn_out), .d(dataIn_in), .wen(1'b1));
dff_16bit alu_result(.clk(clk), .rst(~rst_n), .q(alu_result_out), .d(alu_result_in), .wen(1'b1));
dff zero(.clk(clk), .rst(~rst_n), .q(zero_out), .d(zero_in), .wen(1'b1));
dff_4bit dstReg(.clk(clk), .rst(~rst_n), .q(dstReg_out), .d(dstReg_in), .wen(1'b1));

endmodule
