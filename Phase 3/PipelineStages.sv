module EX_Register(clk, rst, stall_en, d_cache_miss, flush_en, ALUSrc_in, ALUOp_in, ALUSrc_out, ALUOp_out);
input clk, rst, stall_en, flush_en, d_cache_miss;
input ALUSrc_in;
input [3:0] ALUOp_in;

output ALUSrc_out;
output [3:0] ALUOp_out; 

wire rst_or_stall;
assign rst_or_stall = rst | stall_en | flush_en;

dff 		ALUSrc(.q(ALUSrc_out), .d(ALUSrc_in), .wen(~stall_en & ~d_cache_miss), .clk(clk), .rst(rst_or_stall));
dff_4bit	ALUOp(.q(ALUOp_out),  .d(ALUOp_in), .wen(~stall_en & ~d_cache_miss), .clk(clk), .rst(rst_or_stall));


endmodule

module M_Register(clk, rst, stall_en, d_cache_miss, flush_en, MemRead_in, MemWrite_in, MemRead_out, MemWrite_out);
input clk, rst, stall_en,flush_en, d_cache_miss;
input MemRead_in, MemWrite_in;

output MemRead_out, MemWrite_out;

wire rst_or_stall;
assign rst_or_stall = rst | stall_en | flush_en;


dff 	MemRead(.q(MemRead_out), .d(MemRead_in), .wen(~stall_en & ~d_cache_miss), .clk(clk), .rst(rst_or_stall)),
	MemWrite(.q(MemWrite_out), .d(MemWrite_in), .wen(~stall_en & ~d_cache_miss), .clk(clk), .rst(rst_or_stall));

endmodule

module WB_Register(clk, rst, stall_en, d_cache_miss, flush_en, RegWrite_in, MemToReg_in, RegWrite_out, MemToReg_out);
input clk, rst, stall_en,flush_en, d_cache_miss;
input RegWrite_in, MemToReg_in;

output RegWrite_out, MemToReg_out;

wire rst_or_stall;
assign rst_or_stall = rst | stall_en | flush_en;


dff 	RegWrite(.q(RegWrite_out), .d(RegWrite_in), .wen(~stall_en & ~d_cache_miss), .clk(clk), .rst(rst_or_stall)),
	MemToReg(.q(MemToReg_out), .d(MemToReg_in), .wen(~stall_en & ~d_cache_miss), .clk(clk), .rst(rst_or_stall));

endmodule
