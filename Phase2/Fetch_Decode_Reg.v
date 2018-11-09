module Fetch_Decode_Reg(clk, rst_n, flush_en, stall_en, pc_add_in, pc_add_out, instr_in, instr_out);

input clk, rst_n, stall_en, flush_en;
input [15:0] pc_add_in, instr_in;
output [15:0] pc_add_out, instr_out;

wire rst;

assign rst = (~rst_n | flush_en);

dff_16bit pc_add(.clk(clk), .rst(rst), .q(pc_add_out), .d(pc_add_in), .wen(~stall_en));
dff_16bit instr(.clk(clk), .rst(rst), .q(instr_out), .d(instr_in), .wen(~stall_en));

endmodule
