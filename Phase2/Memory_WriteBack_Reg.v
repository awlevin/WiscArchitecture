module Memory_WriteBack_Reg(clk, rst_n, read_data_in, read_data_out, alu_result_in, alu_result_out ,dstReg_in, dstReg_out);

input clk, rst_n;
input [15:0] read_data_in, alu_result_in;
input [3:0] dstReg_in;

output [3:0] dstReg_out;
output [15:0] read_data_out, alu_result_out;

dff_16bit read_data(.clk(clk), .rst(~rst_n), .q(read_data_out), .d(read_data_in), .wen(1'b1));
dff_16bit alu_result(.clk(clk), .rst(~rst_n), .q(alu_result_out), .d(alu_result_in), .wen(1'b1));
dff_4bit dstReg(.clk(clk), .rst(~rst_n), .q(dstReg_out), .d(dstReg_in), .wen(1'b1));

endmodule
