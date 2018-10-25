module Execute_Memory_Reg(clk, rst_n, add_result_in, add_result_out, zero_in, zero_out, alu_result_in, alu_result_out, rd2_in, rd2_out);

input clk, rst_n, zero_in;
output zero_out;
input [15:0] add_result_in, alu_result_in, rd2_in;
output [15:0] add_result_out, alu_result_out, rd2_out;

dff_16bit rd2(.clk(clk), .rst(~rst_n), .q(rd2_out), .d(rd2_in), .wen(1'b1));
dff_16bit add_result(.clk(clk), .rst(~rst_n), .q(add_result_out), .d(add_result_in), .wen(1'b1));
dff_16bit alu_result(.clk(clk), .rst(~rst_n), .q(alu_result_out), .d(alu_result_in), .wen(1'b1));
dff zero(.clk(clk), .rst(~rst_n), .q(zero_out), .d(zero_in), .wen(1'b1));

endmodule
