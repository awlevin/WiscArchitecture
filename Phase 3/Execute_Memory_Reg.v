module Execute_Memory_Reg(instr_in, instr_out, clk, rst_n, stall_en, zero_in, zero_out, alu_result_in, alu_result_out, dataIn_in, dataIn_out,dstReg_in, dstReg_out,srcReg1_in,srcReg1_out,srcReg2_in,srcReg2_out);

input clk, rst_n, stall_en, zero_in;
output zero_out;
input [15:0] alu_result_in, dataIn_in;
input [3:0] dstReg_in,srcReg1_in,srcReg2_in;

input [15:0] instr_in;
output [15:0] instr_out;

output [3:0] dstReg_out,srcReg1_out,srcReg2_out;
output [15:0] alu_result_out, dataIn_out;

dff_16bit dataIn(.clk(clk), .rst(~rst_n), .q(dataIn_out), .d(dataIn_in), .wen(~stall_en));
dff_16bit alu_result(.clk(clk), .rst(~rst_n), .q(alu_result_out), .d(alu_result_in), .wen(~stall_en));
dff zero(.clk(clk), .rst(~rst_n), .q(zero_out), .d(zero_in), .wen(~stall_en));
dff_4bit dstReg(.clk(clk), .rst(~rst_n), .q(dstReg_out), .d(dstReg_in), .wen(~stall_en));
dff_4bit srcReg1(.clk(clk), .rst(~rst_n), .q(srcReg1_out), .d(srcReg1_in), .wen(~stall_en));
dff_4bit srcReg2(.clk(clk), .rst(~rst_n), .q(srcReg2_out), .d(srcReg2_in), .wen(~stall_en));


dff_16bit instr(.clk(clk), .rst(~rst_n), .q(instr_out), .d(instr_in), .wen(~stall_en));

endmodule
